"""Research dashboard shell. Data handlers live in frontend.impl.jac."""
import from endpoints {
    list_games,
    game_history,
    ask_question,
    RankedGame,
    Query,
    Answer
}
import from .components.Icon { Icon }
import from .components.Formatting { metric_label }
import from .components.ResearchOverview { ResearchOverview }
import from .components.RankingsTable { RankingsTable }
import from .components.GameDetails { GameDetails }
import from .components.QuestionPanel { QuestionPanel }
import from .components.ResearchNotes { ResearchNotes }
import from .components.Styles { Styles }

def:pub Dashboard -> JsxElement {
    has games: list[RankedGame] = [],
        minimum: str = "0",
        maximum: str = "100",
        search: str = "",
        sort_by: str = "jackpot_boost",
        ranked_by: str = "jackpot_boost",
        loading: bool = True,
        error: str = "",
        selected: RankedGame | None = None,
        history: list[RankedGame] = [],
        history_loading: bool = False,
        history_error: str = "",
        question: str = "",
        answer: Answer | None = None,
        asking: bool = False,
        question_error: str = "",
        active_section: str = "rankings";

    async can with entry {
        await refresh();
    }
    can with [selected] entry {
        if selected {
            details: any = document.getElementById("game-details");
            if details {
                details.scrollIntoView({"behavior": "smooth", "block": "start"});
            }
        }
    }

    async def load(query: Query) -> None;
    async def refresh -> None;
    async def apply_filters(e: FormEvent) -> None;
    async def choose_price(price: str) -> None;
    async def reset_filters -> None;
    async def inspect(item: RankedGame) -> None;
    async def ask(e: FormEvent) -> None;

    return
        <div className="app-layout">
            <title>betBetter · Michigan scratch-off research</title>
            <link rel="icon" type="image/svg+xml" href="/static/assets/favicon.svg"/>
            <Styles/>
            <a className="skip-link" href="#main-content">Skip to research</a>
            <aside className="sidebar" aria-label="Main navigation">
                <a
                    className="wordmark"
                    href="#main-content"
                    aria-label="betBetter home"
                >
                    <span className="brand-symbol">
                        <Icon name="chart" size={24}/>
                    </span>
                    <span>
                        bet
                        <span className="brand-emphasis">Better</span>
                        <span className="brand-period">.</span>
                    </span>
                </a>
                <span className="workspace-label">THE RESEARCH DESK</span>
                <nav>
                    <a
                        href="#rankings"
                        className={"nav-link active"
                            if active_section == "rankings"
                            else "nav-link"}
                        aria-current={"location"
                            if active_section == "rankings"
                            else None}
                        onClick={lambda { active_section = "rankings"; }}
                    >
                        <Icon name="grid"/>
                        Game explorer
                        <span className="nav-count">MI</span>
                    </a>
                    <a
                        href="#ask"
                        className={"nav-link active"
                            if active_section == "ask"
                            else "nav-link"}
                        aria-current={"location" if active_section == "ask" else None}
                        onClick={lambda { active_section = "ask"; }}
                    >
                        <Icon name="spark"/>
                        Ask the data
                    </a>
                    <a
                        href="#methodology"
                        className={"nav-link active"
                            if active_section == "methodology"
                            else "nav-link"}
                        aria-current={"location"
                            if active_section == "methodology"
                            else None}
                        onClick={lambda { active_section = "methodology"; }}
                    >
                        <Icon name="book"/>
                        Methodology
                    </a>
                </nav>
                <div className="sidebar-bottom">
                    <div className="source-note">
                        <span className="source-icon">
                            <Icon name="shield" size={21}/>
                        </span>
                        <strong>Real data. Clear assumptions.</strong>
                        <p>
                            Independent research powered by official Michigan Lottery data.
                        </p>
                        <a
                            href="#methodology"
                            onClick={lambda { active_section = "methodology"; }}
                        >
                            See how it works
                            <Icon name="arrow" size={15}/>
                        </a>
                    </div>
                    <span className="sidebar-foot">
                        <span className="status-dot"/>
                        Michigan, USA
                    </span>
                </div>
            </aside>
            <div className="app-content">
                <header className="topbar">
                    <div className="breadcrumb">
                        Research desk
                        <span>/</span>
                        <strong>Game explorer</strong>
                    </div>
                    <span className="source-status">
                        <span className="status-dot"/>
                        Official Michigan data
                    </span>
                </header>
                <main id="main-content" className="shell">
                    <section className="hero">
                        <div>
                            <span className="eyebrow">
                                <span className="eyebrow-line"/>
                                THE NUMBERS BEHIND THE TICKET
                            </span>
                            <h1>
                                Less guesswork.
                                <br/>
                                <span>More perspective.</span>
                            </h1>
                            <p>
                                Look beyond the printed odds. Explore Michigan scratch-offs with transparent data and a little more clarity.
                            </p>
                        </div>
                        <div className="hero-card">
                            <span className="hero-card-icon">
                                <Icon name="chart" size={26}/>
                            </span>
                            <div>
                                <span className="hero-card-label">
                                    A CLEARER VIEW OF THE DATA
                                </span>
                                <strong>
                                    Research. Compare.
                                    <br/>
                                    Keep perspective.
                                </strong>
                                <a
                                    href="#methodology"
                                    onClick={lambda { active_section = "methodology"; }}
                                >
                                    Understand the model
                                    <Icon name="arrow" size={17}/>
                                </a>
                            </div>
                            <span className="hero-card-orbit" aria-hidden="true"/>
                        </div>
                    </section>
                    <ResearchOverview games={games} loading={loading}/>
                    <section
                        id="rankings"
                        className="panel rankings-panel"
                        aria-labelledby="rankings-heading"
                    >
                        <div className="rankings-heading">
                            <div>
                                <span className="section-kicker">
                                    EXPLORE THE CATALOG
                                </span>
                                <h2 id="rankings-heading">Scratch-off explorer.</h2>
                                <p className="section-description">
                                    Compare games. Follow the data. See the whole picture.
                                </p>
                            </div>
                            <button
                                className="secondary"
                                type="button"
                                disabled={loading or history_loading}
                                onClick={lambda { refresh(); }}
                            >
                                <Icon name="refresh" size={16}/>
                                Refresh results
                            </button>
                        </div>
                        <form className="filters" onSubmit={apply_filters}>
                            <div className="filter-top">
                                <label className="search-field">
                                    <span className="sr-only">Search games</span>
                                    <Icon name="search" size={19}/>
                                    <input
                                        aria-label="Search games"
                                        placeholder="Search by game name or ID…"
                                        value={search}
                                        onChange={lambda (e: ChangeEvent) { search = e.target.value; }}
                                    />
                                </label>
                                <label className="sort-field">
                                    <Icon name="filter" size={16}/>
                                    <span>Rank by</span>
                                    <select
                                        aria-label="Ranking metric"
                                        value={sort_by}
                                        onChange={lambda (e: ChangeEvent) { sort_by = e.target.value; }}
                                    >
                                        <option value="jackpot_boost">
                                            Est. jackpot change vs launch
                                        </option>
                                        <option value="profit_boost">
                                            Est. profit change vs launch
                                        </option>
                                        <option value="any_boost">
                                            Est. any-prize change vs launch
                                        </option>
                                        <option value="ev_per_dollar">
                                            Est. gross EV per dollar
                                        </option>
                                        <option value="non_jackpot_net_ev">
                                            Est. net EV excluding jackpot
                                        </option>
                                        <option value="any_probability">
                                            Est. any-prize probability
                                        </option>
                                        <option value="profit_probability">
                                            Est. profit probability
                                        </option>
                                        <option value="jackpot_probability">
                                            Est. jackpot odds
                                        </option>
                                        <option value="top_prizes_remaining">
                                            Top-prize retention
                                        </option>
                                        <option value="ev_change">
                                            Est. EV change since launch
                                        </option>
                                        <option value="jackpot_enrichment">
                                            Est. jackpot enrichment
                                        </option>
                                    </select>
                                </label>
                                <button
                                    className="primary filter-submit"
                                    type="submit"
                                    disabled={loading or history_loading}
                                >
                                    {"Loading…" if loading else "Apply filters"}
                                    <Icon name="arrow" size={16}/>
                                </button>
                            </div>
                            <div className="filter-bottom">
                                <div
                                    className="price-chips"
                                    aria-label="Quick ticket price filters"
                                >
                                    <span>Ticket price</span>
                                    {[
                                        <button
                                            type="button"
                                            key={price}
                                            className={"price-chip selected"
                                                if (
                                                    price == "All"
                                                    and minimum == "0"
                                                    and maximum == "100"
                                                )
                                                    or (
                                                        minimum == price
                                                        and maximum == price
                                                    )
                                                else "price-chip"}
                                            aria-pressed={(
                                                price == "All"
                                                and minimum == "0"
                                                and maximum == "100"
                                            )
                                                or (
                                                    minimum == price
                                                    and maximum == price
                                                )}
                                            disabled={loading or history_loading}
                                            onClick={lambda { choose_price(price); }}
                                        >
                                            {"All prices"
                                                if price == "All"
                                                else "$" + price}
                                        </button>
                                        for price in [
                                            "All",
                                            "1",
                                            "2",
                                            "5",
                                            "10",
                                            "20",
                                            "30",
                                            "50"
                                        ]
                                    ]}
                                </div>
                                <details className="price-range">
                                    <summary>
                                        Custom range
                                        <Icon name="filter" size={14}/>
                                    </summary>
                                    <div className="range-inputs">
                                        <label>
                                            Min ($)
                                            <input
                                                aria-label="Minimum ticket price"
                                                type="number"
                                                min="0"
                                                max="100"
                                                step="1"
                                                value={minimum}
                                                onChange={lambda (e: ChangeEvent) { minimum = e.target.value; }}
                                            />
                                        </label>
                                        <span>–</span>
                                        <label>
                                            Max ($)
                                            <input
                                                aria-label="Maximum ticket price"
                                                type="number"
                                                min="0"
                                                max="100"
                                                step="1"
                                                value={maximum}
                                                onChange={lambda (e: ChangeEvent) { maximum = e.target.value; }}
                                            />
                                        </label>
                                        <button
                                            className="primary small-button"
                                            type="submit"
                                            disabled={loading or history_loading}
                                        >
                                            Apply
                                        </button>
                                    </div>
                                </details>
                            </div>
                        </form>
                        <div className="results-caption">
                            <span>
                                <span className="status-dot"/>
                                {str(len(games)) + " games"}
                                <span className="caption-separator">·</span>
                                {"Ranked by " + metric_label(ranked_by).lower()}
                            </span>
                            <button
                                type="button"
                                className="text-button"
                                onClick={lambda { reset_filters(); }}
                                disabled={loading or history_loading}
                            >
                                Reset filters
                            </button>
                        </div>
                        {<p className="error rankings-error" role="alert">{error}</p>
                            if error
                            else None}
                        <RankingsTable
                            games={games}
                            loading={loading}
                            busy={history_loading}
                            metric={ranked_by}
                            onInspect={inspect}
                        />
                    </section>
                    <div className="data-note">
                        <Icon name="info" size={17}/>
                        <p>
                            All probabilities and EVs use estimated ticket inventory. Prize retention alone does not establish favorable odds or a profitable game.
                            <a
                                href="#methodology"
                                onClick={lambda { active_section = "methodology"; }}
                            >
                                How we calculate
                                <Icon name="arrow" size={13}/>
                            </a>
                        </p>
                    </div>
                    {<GameDetails
                        item={selected}
                        history={history}
                        loading={history_loading}
                        error={history_error}
                        onClose={lambda { selected = None; }}
                        onRetry={lambda { if selected { inspect(selected); }}}
                    />
                        if selected is not None
                        else None}
                    <div className="bottom-grid">
                        <QuestionPanel
                            question={question}
                            answer={answer}
                            asking={asking}
                            error={question_error}
                            onQuestion={lambda (value: str) { question = value; }}
                            onAsk={ask}
                            onInspect={inspect}
                            busy={history_loading}
                        />
                        <ResearchNotes/>
                    </div>
                    <footer>
                        <a className="footer-brand" href="#main-content">
                            betBetter
                            <span>.</span>
                        </a>
                        <p>
                            Independent research. Transparent math. No outcome guarantees.
                        </p>
                        <span>
                            Made for a clearer perspective
                            <Icon name="chart" size={15}/>
                        </span>
                    </footer>
                </main>
            </div>
        </div>;
}
