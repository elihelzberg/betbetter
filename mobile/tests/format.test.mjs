import assert from 'node:assert/strict';
import { test } from 'node:test';
import { readFileSync } from 'node:fs';
import ts from 'typescript';
const source = readFileSync(new URL('../src/utils/format.ts', import.meta.url), 'utf8');
const compiled = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText;
const { boost, change, money, odds, percent } = await import(`data:text/javascript;base64,${Buffer.from(compiled).toString('base64')}`);
test('unavailable estimates stay distinct from zero and depleted prizes', () => {
  assert.equal(money(null), 'Not applicable');
  assert.equal(money(0), '$0.00');
  assert.equal(odds(null), 'Not applicable');
  assert.equal(odds(0), 'No prizes left');
  assert.equal(boost(null), 'No launch profit prizes');
  assert.equal(boost(0), '0.00%');
});
test('probability changes and EV changes use different units', () => {
  assert.equal(percent(0.125), '12.50%');
  assert.equal(change(0.125), '+12.50 pp');
  assert.equal(boost(0.125), '+12.50%');
  assert.equal(change(-0.125), '-12.50 pp');
  assert.equal(money(-9.5), '$-9.50');
  assert.equal(odds(0.000001), '1 in 1,000,000');
});
