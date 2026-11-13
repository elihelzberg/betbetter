"""Live deployment verification, intentionally separate from deterministic PR tests."""
import argparse
import json
from datetime import datetime
from urllib.parse import quote, urlparse
from urllib.request import Request, urlopen


def check(base_url: str, timeout: float = 60):
    def request(path, payload=None):
        body = None if payload is None else json.dumps(payload).encode()
        with urlopen(Request(base_url + path, data=body, headers={
            'Content-Type': 'application/json', 'Accept': 'application/json',
        }), timeout=timeout) as response:
            return json.load(response)

    with urlopen(base_url, timeout=timeout) as response:
        if response.status != 200 or 'text/html' not in response.headers.get('Content-Type', ''):
            raise RuntimeError('Public dashboard did not return an HTML page')
    query = {'state': 'MI', 'min_price': 0, 'max_price': 100, 'sort_by': 'jackpot_boost', 'search': '', 'limit': 1000}
    mobile = request('/api/games', query)
    if not isinstance(mobile, list) or not mobile:
        raise RuntimeError('Mobile API did not return a game catalog')
    if any(row['game']['is_demo'] for row in mobile):
        raise RuntimeError('The public catalog contains demo fixtures')
    typed_query = {**query, '__type__': 'Query', '_jac_type_id': '["","models.jac","type","Query"]'}
    rpc = request('/function/list_games', {'query': typed_query})
    web = rpc.get('data', {}).get('result') if rpc.get('ok') else None
    if not isinstance(web, list):
        raise RuntimeError('Web RPC did not return a typed game catalog')
    identity = lambda rows: [(row['game']['game_id'], row['game']['observed_at']) for row in rows]
    if identity(web) != identity(mobile):
        raise RuntimeError('Web and mobile disagree on game ordering or collection timestamps')
    game = mobile[0]['game']
    game_id = game['game_id']
    history = request('/api/games/' + quote(game_id, safe='') + '/history?state=MI')
    web_history = request('/function/game_history', {'game_id': game_id, 'state': 'MI'})
    if not isinstance(history, list) or not history:
        raise RuntimeError('The selected game has no collected history')
    dates = [datetime.fromisoformat(row['game']['observed_at']) for row in history]
    if dates != sorted(dates) or any(row['game']['game_id'] != game_id for row in history):
        raise RuntimeError('History contains an incorrect game or is not chronological')
    if not web_history.get('ok') or identity(web_history.get('data', {}).get('result', [])) != identity(history):
        raise RuntimeError('Web and mobile disagree on history')
    price = game['ticket_price']
    filtered = request('/api/games', {**query, 'min_price': price, 'max_price': price})
    if not filtered or any(row['game']['ticket_price'] != price for row in filtered):
        raise RuntimeError('Exact-price filtering failed')
    answer = request('/api/ask', {'question': f'Top 3 ${price:g} scratchers'})
    if not isinstance(answer, dict) or not answer.get('games'):
        raise RuntimeError('The simple ranking question did not return real games')
    if any(row['game']['ticket_price'] != price for row in answer['games']):
        raise RuntimeError('Question results do not respect the requested price')
    print(f'PASS: public dashboard and {len(mobile)} official games')
    print(f'PASS: web/mobile match game {game_id} ({game["name"]}), collected {game["observed_at"]}')
    print(f'PASS: {len(history)} chronological observations match across clients')
    print('PASS: exact-price filtering and a live rule-based ranking question')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('url', help='Public HTTPS app URL, without /api')
    parser.add_argument('--allow-local-http', action='store_true', help='Allow an HTTP loopback URL for local verification')
    parser.add_argument('--timeout', type=float, default=60)
    args = parser.parse_args()
    base = args.url.rstrip('/')
    parsed = urlparse(base)
    local_http = args.allow_local_http and parsed.scheme == 'http' and parsed.hostname in {'localhost', '127.0.0.1', '::1'}
    if parsed.scheme != 'https' and not local_http:
        parser.error('Use an HTTPS URL; --allow-local-http permits loopback development only')
    if parsed.username or parsed.password or parsed.query or parsed.fragment or not parsed.hostname:
        parser.error('Use a plain app URL without credentials, query parameters, or fragments')
    check(base, args.timeout)
