import assert from 'node:assert/strict';
import { test } from 'node:test';
import { readFileSync } from 'node:fs';
import ts from 'typescript';
const source = readFileSync(new URL('../src/services/client.ts', import.meta.url), 'utf8');
const compiled = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText;
const { createApi, resolveApiUrl } = await import(`data:text/javascript;base64,${Buffer.from(compiled).toString('base64')}`);
test('mobile always reaches the shared fixed entry port, independent of Expo port', () => {
  assert.equal(resolveApiUrl(undefined, '192.168.1.5:8081'), 'http://192.168.1.5:8000/api');
  assert.equal(resolveApiUrl(undefined, 'http://192.168.1.5:8082'), 'http://192.168.1.5:8000/api');
  assert.equal(resolveApiUrl('https://example.com/api///'), 'https://example.com/api');
  assert.equal(resolveApiUrl(undefined, '[::1]:8081'), 'http://[::1]:8000/api');
});
test('rankings send numeric defaults and preserve explicit filters', async () => {
  const requests = [];
  const api = createApi('http://server/api', async (url, init) => {
    requests.push({ url, body: JSON.parse(init.body) });
    return Response.json([]);
  });
  await api.getGames();
  assert.deepEqual(requests[0], { url: 'http://server/api/games', body: { state: 'MI', min_price: 0, max_price: 100, sort_by: 'jackpot_boost', search: '', limit: 1000 } });
  await api.getGames({ min_price: 10, max_price: 20, search: 'Cash', sort_by: 'profit_boost' });
  assert.equal(requests[1].body.min_price, 10);
  assert.equal(requests[1].body.search, 'Cash');
});
test('history and questions use separate shared backend routes', async () => {
  const requests = [];
  const api = createApi('http://server/api', async (url, init) => {
    requests.push({ url, init });
    return Response.json(url.endsWith('/ask') ? { message: 'Answer', games: [] } : []);
  });
  await api.getGameHistory('a/b', 'MI');
  await api.askQuestion('best games');
  assert.equal(requests[0].url, 'http://server/api/games/a%2Fb/history?state=MI');
  assert.equal(requests[0].init.method, 'GET');
  assert.deepEqual(JSON.parse(requests[1].init.body), { question: 'best games' });
});
test('API failures and malformed responses produce usable errors', async () => {
  const api = createApi('http://server/api', async () => Response.json({ error: { message: 'Invalid price range' } }, { status: 400 }));
  await assert.rejects(api.getGames(), /Invalid price range/);
  const bad = createApi('http://server/api', async () => Response.json({ games: [] }));
  await assert.rejects(bad.getGames(), /unexpected games response/);
  const offline = createApi('http://server/api', async () => { throw new TypeError('Failed to fetch'); });
  await assert.rejects(offline.getGames(), /same Wi-Fi/);
});
