# betBetter

Michigan scratch-off research built with Jac 0.37.23 and official Michigan Lottery data.

```sh
jac install --npm
python3 test_lottery.py
jac run --dev
```

Open http://localhost:8000. The collector requires `curl` on PATH and verifies TLS certificates using its certificate store.

The website discovers **every game in the official retail instant-game catalog** rather than keeping a fixed ID list. On October 8, 2026 this was 107 games. It uses the GraphQL prize query from the original `test_lottery.py`, batching ten games per request. Catalog counts can change as games launch or disappear. Draw games, online games, pull tabs and Fast Cash are separate categories.

## Collection and storage

`michigan_live.py` stores complete, validated collections atomically in `.data/michigan.sqlite3`. Reads share that cache for six hours. The first read collects if the database is empty; the first read after expiry refreshes it. Failed refreshes retain the last successful collection and retry after five minutes. A failed initial collection produces an error, never fictional games. The details view shows collection and source-update timestamps. The dashboard defaults to estimated jackpot probability change since launch.

For a refresh independent of visitor traffic, schedule this command every six hours using cron or your hosting provider's job scheduler:

```sh
cd /absolute/path/to/betBetter && python3 test_lottery.py
```

This command refreshes the database used by the website, without rebuilding the frontend. A scheduler is not installed automatically. `MICHIGAN_CACHE_PATH` optionally sets a durable database location shared by the server and refresh job. Back up this file to preserve history. SQLite fits a single-server deployment; use a shared Postgres database and one refresh worker for multiple application servers. An in-process lock prevents concurrent refreshes within one server process; scheduled collectors or multiple processes should be coordinated by a single writer. Snapshot history grows with successful collections.

Public reads no longer use the old Jac graph fixture fallback. Existing fictional graph records are ignored. The legacy `ingest.jac` graph command is not needed for the website.

## Data and calculations

Official data supplies ticket price, advertised overall odds, catalog date, original and unclaimed prize counts, and source update time. Duplicate cash amounts are aggregated. Unrecognized amounts, missing tiers, invalid counts or API errors reject the complete refresh rather than publishing a partial catalog.

The catalog's `dateAdded` is displayed as the launch date; it is catalog metadata, not independently verified first-sale timing. Both ticket inventories are modeled because the official queries do not publish them. Estimated launch tickets = starting winning-prize counts × advertised overall odds (rounded to an integer). Estimated remaining fraction = pooled remaining / starting prize counts for tiers paying at most twice the ticket price. If no such tier exists, the lowest three tiers excluding the jackpot where possible are used. Estimated remaining tickets = launch tickets × that fraction, rounded and bounded between the count of remaining winners and launch inventory. A bound adjustment is disclosed in game details. These assumptions do not correct for sold-but-unclaimed winners or discarded tickets. Rounded published odds add uncertainty. Top-prize retention is remaining divided by original count of the largest prize. Estimated relative probability change = (remaining category winners / estimated remaining tickets) / (starting category winners / estimated launch tickets) − 1; positive means a modeled boost, negative a modeled drop. EV change remains a difference in return per dollar, expressed in percentage points. Each cached observation, including older snapshots, is evaluated using the same model on read. Zero-inventory games are excluded from rankings. Categories with no starting profit prizes are labeled “No launch profit prizes” rather than assigning a fictional change. Advertised overall odds are the published launch odds, not current odds.

Unclaimed prizes can belong to purchased tickets. Prize retention alone does not establish favorable current odds or positive expected value. Demo snapshots remain available only as arithmetic test fixtures. The question feature remains a limited rule-based parser.

## Validation

```sh
jac check --nowarn
jac test
jac build --as client
python3 -m unittest discover -s tests -p 'test_*.py'
```

The Jac tests cover calculation, filtering, all 107 results without truncation, missing inventory, estimated probability changes, ingestion idempotency and service history with a mocked source. Python tests cover collector parsing, complete batch storage, cache reuse, failed-refresh retention, pooled estimates, fallbacks and feasibility bounds. Live collection can be verified with `python3 test_lottery.py`.

## Jackpot and smaller-prize metrics

The dashboard keeps total gross EV per dollar and also shows estimated jackpot odds and estimated net EV per ticket excluding jackpot. Jackpot means the largest cash prize tier. Non-jackpot net EV = sum of smaller prize amounts × remaining counts / estimated remaining tickets − ticket price. Jackpot-winning tickets remain in the denominator, with their payout omitted from this particular metric. It is not conditional on avoiding a jackpot. Negative amounts mean an expected loss from the smaller-prize contribution. Both metrics are available for ranking and in game details; all rely on the same inventory assumptions.
