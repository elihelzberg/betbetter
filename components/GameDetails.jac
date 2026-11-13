import from models { RankedGame }
import from .Formatting { money, percent, odds, change, boost, date_label, count_label }
import from .Icon { Icon }

def:pub GameDetails(
    item: RankedGame,
    history: list[RankedGame],
    loading: bool,
    error: str,
    onClose: Callable[[], None],
    onRetry: Callable[[], None]
) -> JsxElement {
    has history_page: int = 0;
    can with [item] entry {
        history_page = 0;
    }
    history_pages = max(1, int((len(history) + 9) / 10));
    current_page = min(history_page, history_pages - 1);
    history_end = len(history) - current_page * 10;
    history_start = max(0, history_end - 10);
    visible_history = history[history_start:history_end];
    g = item.game;
    m = item.metrics;
    return
        <section
            id="game-details"
            className="panel details-panel"
            aria-labelledby="details-heading"
        >
            <div className="details-heading">
                <div>
                    <span className="section-kicker">
                        A CLOSER LOOK · GAME #{g.game_id}
                    </span>
                    <h2 id="details-heading">{g.name}</h2>
                    <p>{money(g.ticket_price) + " ticket · Michigan · " + g.status}</p>
                </div>
                <div className="detail-actions">
                    {<a
                        className="secondary"
                        href={g.source_url}
                        target="_blank"
                        rel="noreferrer"
                    >
                        Official source
                        <Icon name="external" size={15}/>
                    </a>
                        if g.source_url
                        else <span className="tag">Fictional test fixture</span>}
                    <button
                        className="icon-button"
                        aria-label="Close game details"
                        onClick={lambda { onClose(); }}
                    >
                        <Icon name="close"/>
                    </button>
                </div>
            </div>
            <div className="detail-stats">
                <div>
                    <small>Est. gross payout / ticket</small>
                    <strong>{money(m.gross_ev)}</strong>
                    <span>Before ticket cost</span>
                </div>
                <div>
                    <small>Est. net EV / ticket</small>
                    <strong>{money(m.net_ev)}</strong>
                    <span>After ticket cost</span>
                </div>
                <div>
                    <small>Est. net EV excl. jackpot</small>
                    <strong>{money(m.non_jackpot_net_ev)}</strong>
                    <span>Smaller-prize contribution</span>
                </div>
                <div>
                    <small>Est. jackpot odds</small>
                    <strong>{odds(m.jackpot_probability)}</strong>
                    <span>Largest cash prize tier</span>
                </div>
            </div>
            <div className="detail-columns">
                <div className="prize-section">
                    <div className="subsection-heading">
                        <h3>Inside the prize pool</h3>
                        <span className="tag">
                            {str(len(g.prizes)) + " prize tiers"}
                        </span>
                    </div>
                    <div
                        className="table-scroll"
                        tabIndex={0}
                        role="region"
                        aria-label="Prize tiers"
                    >
                        <table>
                            <thead>
                                <tr>
                                    <th scope="col">Prize</th>
                                    <th scope="col">At launch</th>
                                    <th scope="col">Remaining</th>
                                    <th scope="col">Claimed / removed</th>
                                </tr>
                            </thead>
                            <tbody>
                                {[
                                    <tr key={p.amount}>
                                        <td className="numeric">
                                            <strong>{money(p.amount)}</strong>
                                        </td>
                                        <td>{count_label(p.original)}</td>
                                        <td>{count_label(p.remaining)}</td>
                                        <td>{count_label(p.original - p.remaining)}</td>
                                    </tr> for p in g.prizes
                                ]}
                            </tbody>
                        </table>
                    </div>
                </div>
                <aside className="model-notes">
                    <h3>The model behind this game</h3>
                    <dl>
                        <div>
                            <dt>Inventory method</dt>
                            <dd>{g.inventory_method}</dd>
                        </div>
                        <div>
                            <dt>Est. launch tickets</dt>
                            <dd>{count_label(g.original_tickets)}</dd>
                        </div>
                        <div>
                            <dt>Est. remaining tickets</dt>
                            <dd>{count_label(g.remaining_tickets)}</dd>
                        </div>
                        <div>
                            <dt>Advertised launch odds</dt>
                            <dd>{"1 in " + str(g.advertised_odds)}</dd>
                        </div>
                        <div>
                            <dt>Est. jackpot enrichment</dt>
                            <dd>
                                {"Not applicable"
                                    if m.jackpot_enrichment is None
                                    else f"{m.jackpot_enrichment:.2f}×"}
                            </dd>
                        </div>
                    </dl>
                    <p>{g.inventory_note}</p>
                    <p>
                        Net EV excluding jackpot omits the largest prize payout and subtracts ticket cost. Every ticket stays in the denominator.
                    </p>
                </aside>
            </div>
            <div className="supporting-metrics">
                <div>
                    <span>Est. any-prize probability</span>
                    <strong>{percent(m.any_probability)}</strong>
                </div>
                <div>
                    <span>Est. profit probability</span>
                    <strong>{percent(m.profit_probability)}</strong>
                </div>
                <div>
                    <span>Top-prize retention</span>
                    <strong>{percent(m.top_prizes_remaining)}</strong>
                </div>
                <div>
                    <span>Est. EV change vs launch</span>
                    <strong>{change(m.ev_change)}</strong>
                </div>
            </div>
            <div className="change-strip">
                <span>Est. probability change vs launch</span>
                <div>
                    <small>Any prize</small>
                    <strong>{boost(m.any_boost)}</strong>
                </div>
                <div>
                    <small>Profit</small>
                    <strong>{boost(m.profit_boost)}</strong>
                </div>
                <div>
                    <small>Jackpot</small>
                    <strong>{boost(m.jackpot_boost)}</strong>
                </div>
            </div>
            <div className="history-section">
                <div className="subsection-heading">
                    <div>
                        <h3>Snapshot history</h3>
                        <p className="muted">
                            Each observation, evaluated with the same model.
                        </p>
                    </div>
                    <Icon name="clock" size={20}/>
                </div>
                {<div className="loading-state" role="status">
                    <span className="loader"/>
                    Loading snapshot history…
                </div>
                    if loading
                    else <div>
                        {<div className="error" role="alert">
                            {error}
                            <button
                                type="button"
                                className="text-button"
                                onClick={lambda { onRetry(); }}
                            >
                                Retry history
                            </button>
                        </div>
                            if error
                            else <div
                                className="table-scroll"
                                tabIndex={0}
                                role="region"
                                aria-label="Snapshot history"
                            >
                                <table>
                                    <thead>
                                        <tr>
                                            <th scope="col">Observation (UTC)</th>
                                            <th scope="col">Est. gross EV / $1</th>
                                            <th scope="col">
                                                Est. EV change vs launch
                                            </th>
                                            <th scope="col">Top-prize retention</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {[
                                            <tr key={h.game.observed_at}>
                                                <td>
                                                    {h.game.observed_at.replace(
                                                        "T", " "
                                                    )}
                                                </td>
                                                <td>
                                                    {money(h.metrics.ev_per_dollar)}
                                                </td>
                                                <td>{change(h.metrics.ev_change)}</td>
                                                <td>
                                                    {percent(
                                                        h.metrics.top_prizes_remaining
                                                    )}
                                                </td>
                                            </tr> for h in visible_history
                                        ]}
                                    </tbody>
                                </table>
                                {<p className="empty-state">
                                    No historical observations are available yet.
                                </p>
                                    if not history
                                    else None}
                            </div>}
                    </div>}
            </div>
            {<div className="history-pagination">
                <span>
                    {str(history_start + 1)
                        + "–"
                        + str(history_end)
                        + " of "
                        + str(len(history))
                        + " observations · oldest to newest"}
                </span>
                <div className="pagination">
                    <button
                        type="button"
                        className="secondary small-button"
                        disabled={current_page + 1 >= history_pages}
                        onClick={lambda { history_page = current_page + 1; }}
                    >
                        Older
                    </button>
                    <button
                        type="button"
                        className="secondary small-button"
                        disabled={current_page == 0}
                        onClick={lambda { history_page = current_page - 1; }}
                    >
                        Newer
                        <Icon name="chevron" size={14}/>
                    </button>
                </div>
            </div>
                if history and not loading and not error
                else None}
            <div className="source-dates">
                <span>{"Catalog date: " + date_label(g.launch_date)}</span>
                <span title={g.source_updated_at}>
                    {"Source updated: " + date_label(g.source_updated_at)}
                </span>
                <span title={g.observed_at}>
                    {"Collected: " + date_label(g.observed_at) + " (UTC)"}
                </span>
            </div>
        </section>;
}
