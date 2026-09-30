# chatgambles4me

A working Michigan scratch-off research prototype, written in Jac 0.37.23. The frontend, server endpoints, calculation engine, fixtures, ingestion command and tests are `.jac` files. Jac generates the React/JavaScript browser bundle and HTTP bridge. No AI credentials are needed.

## Run

From this directory:

```sh
jac install --npm
jac run --dev
```

Open http://localhost:8000. If that port is occupied, use `jac run --dev --port 8001`. Jac provides its own runtime and Bun; you do not need a separate Node project. Jac automatically provisions its local Postgres storage when the graph is first accessed; the first run may need internet and permission to write its user cache. The compiler version is pinned in `jac.toml`.

```sh
jac check --nowarn
jac test
jac build --as client
```

`jac check` currently emits upstream JSX/state-variable warnings; `--nowarn` hides those without disabling errors. The generated files under `.jac/` should not be edited.

## What works

- Responsive dashboard with Michigan selection, price range, name/ID search and seven ranking choices.
- Deterministic gross/net expected value, any-prize and profit probabilities, jackpot probability, top-prize retention, EV change since launch and jackpot enrichment.
- Prize-tier details and chronological snapshot history.
- Typed public Jac function endpoints, with loading, empty and error states in the UI.
- Six **fictional** games with two fixed observations each. Fixtures include missing inventory and exhausted top prizes. These are not real Michigan games or live observations.
- A deliberately limited rule-based question demo supporting Michigan, dollar amounts, numeric `top N`/`best N`, and a few ranking keywords.
- Validated append-only graph snapshot storage and an ingestion CLI, with an empty-store fixture fallback.

Live website collection, general language understanding, authentication, scheduled jobs, inventory estimation and production deployment are left for later. No scraping or model call occurs at startup.

## Where to add features

| File | Responsibility |
| --- | --- |
| `models.jac` | Shared typed snapshots, prizes, metrics, queries and answers |
| `analysis.jac` | Validation, pure calculations, filtering and ranking |
| `adapters/michigan.jac` | Fictional fixtures; replace `fetch_live()` with official-source collection |
| `repository.jac` | Graph persistence, observation deduplication and latest-per-game selection |
| `ingest.jac` | Private ingestion command; validates the full batch before storing |
| `assistant.jac` | Replace rule-based interpretation with a typed byLLM query interpreter |
| `endpoints.jac` | Public read-only Jac RPC functions |
| `frontend.jac` | Reactive dashboard and server calls |
| `components/` | Detail view, formatting and styles, all authored in Jac |
| `tests/analysis_tests.jac` | Arithmetic, validation, rankings, persistence and service tests |

The `models` and `endpoints` server placement pins keep RPC data contracts on the server boundary. Import frontend RPC types from `endpoints` alongside the functions to avoid duplicate generated model declarations in this compiler version.

### Add live collection

Implement `fetch_live()` to return `list[GameSnapshot]`. Keep HTTP/parsing code inside the adapter; Jac can import Python ecosystem libraries directly, with dependencies declared in `jac.toml`. Do not put scraping in the UI.

Preserve state/game ID, timestamp with timezone, source URL, launch date, advertised odds, original ticket count and every positive prize tier. Tier amounts represent gross cash paid; free-ticket, annuity and multi-prize-per-ticket games need an explicit normalization policy before using this calculator. Mark real data `is_demo=False`. Source prize amounts must be unique after aggregation. `remaining` means unclaimed as reported by the source, and `original - remaining` is reported as claimed/removed.

If a trustworthy remaining-inventory estimate is unavailable, set `remaining_tickets=None` and `inventory_method="unknown"`. Supported known methods are `"estimate"`, `"published unsold"` and `"demo assumption"`. Original inventory is currently required; do not silently derive it from rounded advertised odds. Add an explicit launch-inventory estimate/provenance model before supporting sources that omit it.

Stop the app before running the ingestion command: this compiler treats a script inside the project as a project entry and can rewrite its generated client artifacts. Restart `jac run --dev` afterward. For validation while the app is running, add `--no-takeover` to the dry-run command.

```sh
# Works now; validates fixtures without writing.
jac run --no-serve ingest.jac --source demo --dry-run

# Optional: persist the demo snapshots.
jac run --no-serve ingest.jac --source demo

# After implementing fetch_live():
jac run --no-serve ingest.jac --source live --dry-run
jac run --no-serve ingest.jac --source live
```

Once the graph contains snapshots, the repository uses stored data exclusively. Duplicate `(state, game_id, observed_at)` observations are skipped, not updated. Corrections need a new timestamp or a future explicit revision mechanism. Ingestion is designed for one local writer; add a database uniqueness constraint/transaction strategy before parallel ingestion. Batch validation prevents malformed input writes but is not a full transactional import/rollback system. Do not mix demo and live datasets in the same project store. The UI banner currently describes the demo; update it when switching to live data.

For additional states, create another adapter with the same output contract, route it through ingestion, and add that state to the UI. The calculator already filters by state.

### Add AI

Replace the parser in `assistant.jac` with a byLLM function that returns a validated `Query`. Continue calling `rank_games()` to produce every number. Use a separate explanation step if desired; feed it calculated results and provenance. Set provider configuration on the server, keep keys in environment variables, and never let the model invent odds or silently select a different state. The current parser always reports its Michigan-only interpretation and has no conversational memory.

## Math and interpretation

For remaining inventory **N**, ticket price **c**, prize amounts **vᵢ**, remaining prize counts **rᵢ**, original counts **oᵢ**, and original inventory **N₀**:

| Metric | Formula |
| --- | --- |
| Gross EV per ticket | Σ(vᵢ × rᵢ) / N |
| Net EV per ticket | Gross EV − c |
| Gross EV per dollar | Gross EV / c |
| Any-prize probability | Σrᵢ / N |
| Profit probability | Σrᵢ where vᵢ > c, divided by N |
| Jackpot probability | Remaining count of largest prize / N |
| Top prizes remaining | Remaining / original count of largest prize |
| EV change | Current gross EV per dollar − launch gross EV per dollar |
| Jackpot enrichment | (Top remaining / top original) / (N / N₀) |

EV change is displayed in percentage points, not relative percent. All rankings descend; higher probability means better odds, and unknown metrics sort last. Game IDs break ties. Ended/sold-out games are omitted from rankings. No remaining top prizes gives probability zero; unavailable inventory gives `None`, never a fabricated probability. Calculations retain full float precision; rounding is display-only.

**Unclaimed is not unsold.** Reported unclaimed prizes may belong to tickets already purchased. Even a correct unsold-ticket denominator cannot make those counts an exact current probability. The prototype treats prize counts as available under an explicit scenario, so its estimates depend on that assumption. Gross EV below $1 per dollar is an expected loss. Enrichment alone does not imply positive EV. Taxes, travel costs, prize valuation, retailer inventory and claim delays are not modeled.

## API

Jac serves `POST /function/list_games`, `POST /function/game_history`, and `POST /function/ask_question`, plus generated documentation at `/docs`. The Jac client handles the typed wire format automatically. For a raw REST client:

```sh
curl http://localhost:8000/function/list_games \
  -H 'Content-Type: application/json' \
  -d '{"query":{"state":"MI","min_price":10,"max_price":20,"sort_by":"ev_per_dollar","search":"","limit":5}}'
```

Responses use Jac's envelope; function results are in `data.result`. Ingestion helpers are private and are not exposed as anonymous endpoints. A public deployment still needs rate limits and an operational freshness/error policy.

## Verification

Verified with Jac 0.37.23: project and ingestion type checks, 12 passing Jac tests, the production browser build, and the ingestion dry run (12 valid snapshots). Browser checks covered initial load, $10–$20 filtering (three results), game details, two historical observations, the question demo, an empty search and the mobile layout.

Jac references: [full-stack framework](https://www.jac-lang.org/reference/plugins/jac-client/). For commands matching the installed version, use `jac guide jac-fullstack-patterns`, `jac guide jac-by-llm` and `jac --help`; this compiler uses `jac run --dev` and `jac build --as client`.
