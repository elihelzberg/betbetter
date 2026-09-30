import from models { RankedGame }
import from .Formatting { money, percent, odds, change }

def:pub GameDetails(item: RankedGame, history: list[RankedGame], loading: bool) -> JsxElement {
    g = item.game;
    m = item.metrics;
    return <section className="panel details" aria-label="Game details">
        <div className="section-heading"><div><span className="eyebrow">BEHIND THE NUMBERS</span><h2>{g.name}</h2></div><span className="tag">{g.game_id}</span></div>
        <div className="detail-stats">
            <div><small>Gross payout / ticket</small><strong>{money(m.gross_ev)}</strong></div>
            <div><small>Net EV / ticket</small><strong>{money(m.net_ev)}</strong></div>
            <div><small>Jackpot odds</small><strong>{odds(m.jackpot_probability)}</strong></div>
            <div><small>Jackpot enrichment</small><strong>{"Unknown" if m.jackpot_enrichment is None else f"{m.jackpot_enrichment:.2f}×"}</strong></div>
        </div>
        <p className="muted">{"Inventory: " + g.inventory_method + ". Launched " + g.launch_date + ". Observed " + g.observed_at + "."}</p>
        <p className="muted">{"Original tickets: " + str(g.original_tickets) + " · Remaining ticket inventory: " + ("unknown" if g.remaining_tickets is None else str(g.remaining_tickets)) + " · Advertised odds: 1 in " + str(g.advertised_odds)}</p>
        {<a href={g.source_url} target="_blank" rel="noreferrer">Official source</a> if g.source_url else <p className="muted">Fictional fixture — no official source.</p>}
        <div className="table-scroll"><table><thead><tr><th>Prize</th><th>Original</th><th>Remaining</th><th>Claimed / removed</th></tr></thead>
        <tbody>{[<tr key={p.amount}><td>{money(p.amount)}</td><td>{p.original}</td><td>{p.remaining}</td><td>{p.original - p.remaining}</td></tr> for p in g.prizes]}</tbody></table></div>
        <h3>Snapshot history</h3>
        {<p role="status">Loading history…</p> if loading else <div className="table-scroll"><table><thead><tr><th>Observation (UTC)</th><th>Gross EV / $1</th><th>Change vs launch</th><th>Top prizes left</th></tr></thead>
        <tbody>{[<tr key={h.game.observed_at}><td>{h.game.observed_at}</td><td>{money(h.metrics.ev_per_dollar)}</td><td>{change(h.metrics.ev_change)}</td><td>{percent(h.metrics.top_prizes_remaining)}</td></tr> for h in history]}</tbody></table></div>}
    </section>;
}
