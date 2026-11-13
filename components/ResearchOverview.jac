import from models { RankedGame }
import from .Formatting { date_label }
import from .Icon { Icon }

def:pub ResearchOverview(games: list[RankedGame], loading: bool) -> JsxElement {
    prices = [g.game.ticket_price for g in games];
    latest = max([g.game.observed_at for g in games]) if games else "";
    return
        <div className="overview" aria-label="Research overview" aria-busy={loading}>
            <div className="overview-stat">
                <span className="stat-label">
                    <Icon name="grid" size={16}/>{" "}
                    Games in view
                </span>
                <strong>
                    {"—" if loading else str(len(games))}
                    <span>scratch-offs</span>
                </strong>
                <small>Official Michigan catalog</small>
            </div>
            <div className="overview-stat">
                <span className="stat-label">
                    <Icon name="ticket" size={16}/>{" "}
                    Ticket price range
                </span>
                <strong>
                    {"—"
                        if loading or not prices
                        else f"${min(prices):.0f}–${max(prices):.0f}"}
                    <span>per ticket</span>
                </strong>
                <small>Based on your current results</small>
            </div>
            <div className="overview-stat">
                <span className="stat-label">
                    <Icon name="clock" size={16}/>{" "}
                    Latest collection in view
                </span>
                <strong className="date-stat">
                    {"—" if loading else date_label(latest)}
                </strong>
                <small>UTC · cache refreshes every 6 hours</small>
            </div>
        </div>;
}
