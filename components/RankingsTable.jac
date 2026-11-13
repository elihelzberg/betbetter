import from models { RankedGame }
import from .Formatting { money, percent, odds, metric_label, metric_display }
import from .Icon { Icon }

def:pub RankingsTable(
    games: list[RankedGame],
    loading: bool,
    busy: bool,
    metric: str,
    onInspect: Callable[[RankedGame], None]
) -> JsxElement {
    has page: int = 0;
    can with [games] entry {
        page = 0;
    }
    pages = max(1, int((len(games) + 11) / 12));
    current = min(page, pages - 1);
    start = current * 12;
    visible = games[start:start + 12];

    return
        <div className="rankings-results" aria-busy={loading}>
            {<div className="loading-state" role="status">
                <span className="loader"/>
                Loading Michigan game snapshots…
            </div>
                if loading
                else <div
                    className="table-scroll"
                    tabIndex={0}
                    role="region"
                    aria-label="Scratch-off rankings table"
                >
                    <table className="rankings-table">
                        <thead>
                            <tr>
                                <th className="rank-column" scope="col">#</th>
                                <th scope="col">Game</th>
                                <th scope="col">Ticket</th>
                                <th scope="col" className="selected-column">
                                    {"Est. " + metric_label(metric)}
                                    <span aria-hidden="true"> ↓</span>
                                </th>
                                <th scope="col">Est. gross EV / $1</th>
                                <th scope="col">Est. jackpot odds</th>
                                <th scope="col">Top prizes left</th>
                                <th scope="col">
                                    <span className="sr-only">View details</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            {[
                                <tr key={item.game.game_id}>
                                    <td className="rank-number">{start + i + 1}</td>
                                    <td>
                                        <button
                                            className="game-name"
                                            disabled={busy}
                                            onClick={lambda { onInspect(item); }}
                                        >
                                            <span
                                                className={"game-tile tile-"
                                                    + str((start + i) % 4)}
                                                aria-hidden="true"
                                            >
                                                <Icon name="ticket" size={22}/>
                                            </span>
                                            <span>
                                                <strong>{item.game.name}</strong>
                                                <small>
                                                    {"MI · Game #" + item.game.game_id}
                                                </small>
                                            </span>
                                        </button>
                                    </td>
                                    <td>
                                        <span className="price-tag">
                                            {money(item.game.ticket_price)}
                                        </span>
                                    </td>
                                    <td className="selected-column">
                                        <span className="metric-value">
                                            {metric_display(item, metric)}
                                        </span>
                                    </td>
                                    <td className="numeric">
                                        {money(item.metrics.ev_per_dollar)}
                                    </td>
                                    <td className="numeric">
                                        {odds(item.metrics.jackpot_probability)}
                                    </td>
                                    <td>
                                        <span className="retention-value">
                                            {percent(item.metrics.top_prizes_remaining)}
                                        </span>
                                        <div
                                            className="retention-track"
                                            aria-hidden="true"
                                        >
                                            <span
                                                style={{
                                                    "width": str(
                                                        item.metrics.top_prizes_remaining
                                                            * 100
                                                    )
                                                        + "%"
                                                }}
                                            />
                                        </div>
                                    </td>
                                    <td>
                                        <button
                                            className="icon-button row-open"
                                            aria-label={"View "
                                                + item.game.name
                                                + " details"}
                                            disabled={busy}
                                            onClick={lambda { onInspect(item); }}
                                        >
                                            <Icon name="chevron" size={17}/>
                                        </button>
                                    </td>
                                </tr> for (i, item) in enumerate(visible)
                            ]}
                        </tbody>
                    </table>
                    {<div className="empty-state">
                        <Icon name="search" size={30}/>
                        <h3>No matching games</h3>
                        <p>Try another name, game ID, or a wider ticket price range.</p>
                    </div>
                        if not games
                        else None}
                </div>}
            <div className="table-footer">
                <p>
                    {"Showing "
                        + str(start + 1)
                        + "–"
                        + str(min(start + 12, len(games)))
                        + " of "
                        + str(len(games))
                        + " games"
                        if games and not loading
                        else (
                            "Fetching game snapshots…"
                                if loading
                                else "0 games match these filters"
                        )}
                </p>
                <div className="pagination" aria-label="Results pagination">
                    <button
                        type="button"
                        className="secondary small-button"
                        disabled={loading or current == 0}
                        onClick={lambda { page = current - 1; }}
                    >
                        Previous
                    </button>
                    <span>{str(current + 1) + " / " + str(pages)}</span>
                    <button
                        type="button"
                        className="secondary small-button"
                        disabled={loading or current + 1 >= pages}
                        onClick={lambda { page = current + 1; }}
                    >
                        Next
                        <Icon name="chevron" size={14}/>
                    </button>
                </div>
            </div>
        </div>;
}
