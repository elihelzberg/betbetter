"""Official public GraphQL collector and atomic SQLite snapshot cache.

curl uses the OS certificate store; TLS verification is never disabled.
"""
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess
import threading
import time
from datetime import datetime, timezone
from urllib.parse import quote

API = 'https://www.michiganlottery.com/api'
CATALOG = '{ getCMSGames(removeHiddenGames: true) { name identifier igtId gameCategoryIdentifier displayedTicketPrice overallOdds dateAdded } }'
PRIZES = '''query RetailPrizesRemaining($id: Int!) {
 getRetailTopPrizesRemainingForGameDetails(cms_game_igt_id: $id) {
 prize_level prize_amount prizes_remaining starting_amount updatedAt
 } }'''
_LOCK = threading.Lock()
_RETRY_AFTER = 0.0


def request(operations):
    result = subprocess.run(
        ['curl', '--silent', '--show-error', '--fail-with-body', '--max-time', '45',
         API, '-H', 'Content-Type: application/json', '-H', 'cms-type: production',
         '-H', 'Origin: https://www.michiganlottery.com',
         '-H', 'Referer: https://www.michiganlottery.com/', '--data-binary', '@-'],
        input=json.dumps(operations), text=True, capture_output=True, timeout=50,
        check=True,
    )
    responses = json.loads(result.stdout)
    if not isinstance(responses, list) or len(responses) != len(operations):
        raise ValueError('Incomplete Michigan API response')
    for response in responses:
        if response.get('errors') or not isinstance(response.get('data'), dict):
            raise ValueError(f'Michigan API error: {response.get("errors")}')
    return [response['data'] for response in responses]


def number(value):
    match = re.fullmatch(r'\s*\$?([\d,]+(?:\.\d+)?)\s*', str(value))
    if not match:
        raise ValueError(f'Unsupported monetary amount: {value!r}')
    return float(match[1].replace(',', ''))


def normalize(game, tiers, observed):
    if not tiers:
        raise ValueError(f'No prize data for game {game["igtId"]}')
    amounts = {}
    for tier in tiers:
        amount = number(tier['prize_amount'])
        original, remaining = int(tier['starting_amount']), int(tier['prizes_remaining'])
        if amount <= 0 or original <= 0 or not 0 <= remaining <= original:
            raise ValueError(f'Invalid prize counts for {game["igtId"]}')
        previous = amounts.setdefault(amount, {'amount': amount, 'original': 0, 'remaining': 0})
        previous['original'] += original
        previous['remaining'] += remaining
    odds = re.fullmatch(r'1\s+in\s+([\d.]+)', game['overallOdds'].strip(), re.I)
    if not odds or float(odds[1]) < 1:
        raise ValueError(f'Invalid advertised odds for {game["igtId"]}')
    price = number(game['displayedTicketPrice'])
    if price <= 0:
        raise ValueError('Invalid ticket price')
    return dict(game_id=str(game['igtId']), name=game['name'], state='MI',
                ticket_price=price, prizes=sorted(amounts.values(), key=lambda p: p['amount']),
                original_tickets=None, remaining_tickets=None, observed_at=observed,
                launch_date=game['dateAdded'][:10], advertised_odds=float(odds[1]),
                inventory_method='unknown', is_demo=False, status='active',
                source_url='https://www.michiganlottery.com/games/' + quote(game['identifier'].lower().replace('_', '-'), safe=''),
                source_updated_at=max((t['updatedAt'] for t in tiers if t.get('updatedAt')), default=''))


def collect():
    games = [g for g in request([{'query': CATALOG}])[0]['getCMSGames']
             if g['gameCategoryIdentifier'] == 'RETAIL_INSTANT_GAMES_CATEGORY']
    if not games or len({g['igtId'] for g in games}) != len(games):
        raise ValueError('Empty or duplicate Michigan catalog')
    observed = datetime.now(timezone.utc).isoformat()
    snapshots = []
    for start in range(0, len(games), 10):
        batch = games[start:start + 10]
        responses = request([{'operationName': 'RetailPrizesRemaining',
                              'variables': {'id': g['igtId']}, 'query': PRIZES} for g in batch])
        snapshots.extend(normalize(g, r['getRetailTopPrizesRemainingForGameDetails'], observed)
                         for g, r in zip(batch, responses))
    return snapshots


def estimate_snapshot(snapshot):
    """Model inventory from pooled prizes up to twice the ticket price.

    Applied on read so historical/raw cached collections remain compatible.
    """
    result = dict(snapshot)
    tiers = sorted(snapshot['prizes'], key=lambda p: p['amount'])
    original_winners = sum(p['original'] for p in tiers)
    remaining_winners = sum(p['remaining'] for p in tiers)
    original = max(original_winners, round(original_winners * snapshot['advertised_odds']))
    baseline = [p for p in tiers if p['amount'] <= 2 * snapshot['ticket_price']]
    fallback = not baseline
    if fallback:
        baseline = tiers[:min(3, max(1, len(tiers) - 1))]
    fraction = sum(p['remaining'] for p in baseline) / sum(p['original'] for p in baseline)
    modeled = round(original * fraction)
    # Enforce a feasible pool without creating probabilities above 100%.
    remaining = min(original, max(modeled, remaining_winners))
    result.update(original_tickets=original, remaining_tickets=remaining,
                  inventory_method='estimate',
                  inventory_note=('Launch tickets ≈ starting winning tickets × advertised odds. '
                                  'Remaining fraction uses pooled ' +
                                  ('lowest available prize tiers' if fallback else 'prizes up to 2× ticket price') +
                                  '. Unclaimed prizes are treated as available; claim delays are not adjusted.' +
                                  (' Inventory raised to fit remaining winning tickets.' if remaining > modeled else '')))
    return result


def estimated_snapshots(history: bool = False) -> list[dict]:
    return [estimate_snapshot(row) for row in load_snapshots(history=history)]


def database():
    path = Path(os.environ.get('MICHIGAN_CACHE_PATH', str(Path(__file__).parent / '.data/michigan.sqlite3')))
    path.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(path, timeout=60)
    db.execute('CREATE TABLE IF NOT EXISTS batches (id INTEGER PRIMARY KEY, fetched REAL NOT NULL, payload TEXT NOT NULL)')
    return db


def load_snapshots(history: bool = False, force: bool = False) -> list[dict]:
    global _RETRY_AFTER
    with _LOCK, database() as db:
        latest = db.execute('SELECT fetched, payload FROM batches ORDER BY id DESC LIMIT 1').fetchone()
        if force or ((not latest or time.time() - latest[0] >= 21600) and time.time() >= _RETRY_AFTER):
            try:
                snapshots = collect()
                db.execute('INSERT INTO batches(fetched, payload) VALUES (?, ?)', (time.time(), json.dumps(snapshots)))
                db.commit()
                latest = (time.time(), json.dumps(snapshots))
                _RETRY_AFTER = 0
            except Exception:
                _RETRY_AFTER = time.time() + 300
                if force or not latest:
                    raise
        if not latest:
            raise RuntimeError('Michigan data unavailable; retry shortly')
        if history:
            return [s for (payload,) in db.execute('SELECT payload FROM batches ORDER BY id') for s in json.loads(payload)]
        return json.loads(latest[1])


if __name__ == '__main__':
    print(f'Refreshed {len(load_snapshots(force=True))} official Michigan games.')
