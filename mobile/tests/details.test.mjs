import assert from 'node:assert/strict';
import { test } from 'node:test';
import { readFileSync } from 'node:fs';
import ts from 'typescript';

const source = readFileSync(new URL('../src/services/details.ts', import.meta.url), 'utf8');
const compiled = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText;
const { loadGameDetails } = await import(`data:text/javascript;base64,${Buffer.from(compiled).toString('base64')}`);
const flush = () => new Promise(resolve => setImmediate(resolve));
function deferred() {
  let resolve, reject;
  const promise = new Promise((yes, no) => { resolve = yes; reject = no; });
  return { promise, resolve, reject };
}
function game(id) {
  return { game: { game_id: id, prizes: [{ amount: id === 'A' ? 100 : 200, remaining: 2 }] }, metrics: {} };
}

test('switching from A to B keeps B prizes and history when A history finishes late', async () => {
  const pending = { A: deferred(), B: deferred() };
  const client = {
    async getGames(query) { return [game(query.search)]; },
    getGameHistory(id) { return pending[id].promise; },
  };
  let displayed;
  const publish = value => { displayed = value; };
  const cancelA = loadGameDetails(client, 'A', 'MI', publish);
  await flush();
  assert.equal(displayed.item.game.game_id, 'A');
  cancelA();
  const cancelB = loadGameDetails(client, 'B', 'MI', publish);
  await flush();
  pending.B.resolve([game('B')]);
  await flush();
  pending.A.resolve([game('A')]);
  await flush();
  assert.equal(displayed.item.game.game_id, 'B');
  assert.equal(displayed.item.game.prizes[0].amount, 200);
  assert.deepEqual(displayed.history.map(row => row.game.game_id), ['B']);
  assert.equal(displayed.loading, false);
  assert.equal(displayed.error, '');
  cancelB();
});

test('late catalog response from A cannot start A history or replace B', async () => {
  const catalogA = deferred();
  const histories = [];
  const client = {
    getGames(query) { return query.search === 'A' ? catalogA.promise : Promise.resolve([game('B')]); },
    async getGameHistory(id) { histories.push(id); return [game(id)]; },
  };
  let displayed;
  const cancelA = loadGameDetails(client, 'A', 'MI', value => { displayed = value; });
  cancelA();
  const cancelB = loadGameDetails(client, 'B', 'MI', value => { displayed = value; });
  await flush();
  catalogA.resolve([game('A')]);
  await flush();
  assert.equal(displayed.item.game.game_id, 'B');
  assert.deepEqual(histories, ['B']);
  cancelB();
});

test('empty history preserves the selected game without reporting an error', async () => {
  let displayed;
  const cancel = loadGameDetails({ async getGames() { return [game('B')]; }, async getGameHistory() { return []; } }, 'B', 'MI', value => { displayed = value; });
  await flush();
  assert.equal(displayed.item.game.game_id, 'B');
  assert.deepEqual(displayed.history, []);
  assert.equal(displayed.loading, false);
  assert.equal(displayed.error, '');
  cancel();
});

test('failed history keeps the game prizes available and gives a retryable error', async () => {
  let displayed;
  const cancel = loadGameDetails({ async getGames() { return [game('B')]; }, async getGameHistory() { throw new Error('offline'); } }, 'B', 'MI', value => { displayed = value; });
  await flush();
  assert.equal(displayed.item.game.game_id, 'B');
  assert.deepEqual(displayed.history, []);
  assert.equal(displayed.loading, false);
  assert.match(displayed.error, /Please retry/);
  cancel();
});

test('a late failure from A cannot add an error to successful B details', async () => {
  const historyA = deferred();
  let displayed;
  const client = { async getGames(query) { return [game(query.search)]; }, getGameHistory(id) { return id === 'A' ? historyA.promise : Promise.resolve([game('B')]); } };
  const cancelA = loadGameDetails(client, 'A', 'MI', value => { displayed = value; });
  await flush();
  cancelA();
  const cancelB = loadGameDetails(client, 'B', 'MI', value => { displayed = value; });
  await flush();
  historyA.reject(new Error('late failure'));
  await flush();
  assert.equal(displayed.item.game.game_id, 'B');
  assert.equal(displayed.error, '');
  assert.equal(displayed.history[0].game.game_id, 'B');
  cancelB();
});
