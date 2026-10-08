"""Jac reactive dashboard. All data and analysis arrive through typed server RPC."""
import from endpoints { list_games, game_history, ask_question, RankedGame, Query, Answer }
import from .components.Formatting { money, percent, change, boost, odds }
import from .components.GameDetails { GameDetails }
import from .components.Styles { Styles }

def:pub Dashboard -> JsxElement {
    has games: list[RankedGame] = [],
        minimum: str = "0", maximum: str = "100", search: str = "",
        sort_by: str = "jackpot_boost", loading: bool = True,
        error: str = "", selected: RankedGame | None = None,
        history: list[RankedGame] = [], history_loading: bool = False,
        question: str = "What are the five best $10–$20 scratchers in Michigan?",
        answer: Answer | None = None, asking: bool = False;

    async can with entry { await refresh(); }

    async def refresh {
        loading = True;
        error = "";
        try {
            games = await list_games(Query(min_price=float(minimum or "0"), max_price=float(maximum or "100"), sort_by=sort_by, search=search));
            selected = None;
            history = [];
        } except Exception {
            error = "Could not load games. Check your price range and that the Jac server is running, then try again.";
        } finally { loading = False; }
    }
    async def apply_filters(e: FormEvent) { e.preventDefault(); await refresh(); }
    async def inspect(item: RankedGame) {
        selected = item;
        history = [];
        history_loading = True;
        error = "";
        try { history = await game_history(item.game.game_id, item.game.state); }
        except Exception { error = "Could not load snapshot history. Try selecting the game again."; }
        finally { history_loading = False; }
    }
    async def ask(e: FormEvent) {
        e.preventDefault();
        asking = True;
        error = "";
        try { answer = await ask_question(question); }
        except Exception { error = "Could not answer. Use a valid price range and a result count from 1 to 100."; }
        finally { asking = False; }
    }

    return <div>
        <title>betBetter · Scratch-off research</title>
        <Styles/>
        <header className="topbar"><img className="brand" src="/static/assets/logo.png" alt="betBetter" width={552} height={414}/><small>Scratch-off research, made transparent.</small><span className="status">Michigan · prototype</span></header>
        <main className="shell">
            <section className="hero"><div><span className="eyebrow">LOTTERY RESEARCH LAB</span><h1>Look beyond the<br/>printed odds.</h1><p>Explore prize pools, compare expected returns, and see how the numbers move over time.</p></div><div className="hero-mark" aria-hidden="true">↗</div></section>
            <div className="notice"><strong>Official Michigan Lottery data.</strong> All scratch-off games are collected and cached for six hours. If refresh fails, the last successful collection stays available; check observation dates in game details. EV and probabilities use estimated ticket inventory from common low-value prize retention. These are model estimates, not verified current odds.</div>
            {<div className="error" role="alert">{error}</div> if error else None}
            <section className="panel" aria-label="Game rankings">
                <div className="section-heading"><div><span className="eyebrow">EXPLORE THE DATA</span><h2>Scratch-off rankings</h2></div><span className="tag">{str(len(games)) + " results · higher ranks first"}</span></div>
                <form className="filters" onSubmit={apply_filters}>
                    <label>State<select aria-label="State"><option value="MI">Michigan</option></select></label>
                    <label>Min ticket ($)<input aria-label="Minimum ticket price" type="number" min="0" step="1" value={minimum} onChange={lambda (e: ChangeEvent) { minimum = e.target.value; }}/></label>
                    <label>Max ticket ($)<input aria-label="Maximum ticket price" type="number" min="0" step="1" value={maximum} onChange={lambda (e: ChangeEvent) { maximum = e.target.value; }}/></label>
                    <label>Rank by<select aria-label="Ranking metric" value={sort_by} onChange={lambda (e: ChangeEvent) { sort_by = e.target.value; }}>
                        <option value="non_jackpot_net_ev">Est. net EV / ticket excluding jackpot</option><option value="jackpot_boost">Est. jackpot change vs launch</option><option value="profit_boost">Est. profit change vs launch</option><option value="any_boost">Est. any-prize change vs launch</option><option value="ev_per_dollar">Est. gross EV per dollar</option><option value="any_probability">Est. any prize probability</option><option value="profit_probability">Est. profit probability</option><option value="jackpot_probability">Est. jackpot probability</option><option value="top_prizes_remaining">Top prizes remaining</option><option value="ev_change">Est. EV change since launch</option><option value="jackpot_enrichment">Est. jackpot enrichment</option>
                    </select></label>
                    <label>Find a game<input aria-label="Search games" placeholder="Name or game ID" value={search} onChange={lambda (e: ChangeEvent) { search = e.target.value; }}/></label>
                    <button className="primary" type="submit" disabled={loading or history_loading}>{"Loading…" if loading else "Apply filters"}</button>
                </form>
                {<p className="empty" role="status">Loading game snapshots…</p> if loading else <div className="table-scroll"><table>
                    <thead><tr><th>Game / ticket</th><th>Est. total gross EV / $1</th><th>Est. jackpot odds</th><th>Est. net EV / ticket excluding jackpot</th><th>Est. any prize</th><th>Est. profit</th><th>Top prizes left</th><th>Est. EV vs launch</th><th>Est. jackpot change</th><th>Est. profit change</th></tr></thead>
                    <tbody>{[<tr key={item.game.game_id}>
                        <td><button className="link" disabled={history_loading} onClick={lambda { inspect(item); }}>{item.game.name}</button><small>{money(item.game.ticket_price) + " · " + item.game.inventory_method}</small></td>
                        <td className="ev">{money(item.metrics.ev_per_dollar)}</td><td>{odds(item.metrics.jackpot_probability)}</td><td>{money(item.metrics.non_jackpot_net_ev)}</td><td>{percent(item.metrics.any_probability)}</td><td>{percent(item.metrics.profit_probability)}</td><td>{percent(item.metrics.top_prizes_remaining)}</td><td>{change(item.metrics.ev_change)}</td><td>{boost(item.metrics.jackpot_boost)}</td><td>{boost(item.metrics.profit_boost)}</td>
                    </tr> for item in games]}</tbody>
                </table></div>}
                {<p className="empty">No games match these filters. Try a wider price range or another search.</p> if not loading and len(games) == 0 else None}
                <p className="muted">Select a game for prize tiers and history. Jackpot odds describe the largest prize. Net EV excluding jackpot counts all tickets, omits the largest prize payout, and subtracts the ticket cost. Gross EV includes the ticket stake; below $1 means an expected loss per dollar. Changes compare estimated current probabilities with launch probabilities.</p>
            </section>
            {<GameDetails item={selected} history={history} loading={history_loading}/> if selected is not None else None}
            <div className="bottom-grid">
                <section className="panel"><span className="eyebrow">ASK THE DATA</span><h2>A starting point for your AI.</h2><p className="muted">Working rule-based demo · Michigan only · no API key needed</p>
                    <form className="question-form" onSubmit={ask}><input aria-label="Ask about games" maxLength={500} required value={question} onChange={lambda (e: ChangeEvent) { question = e.target.value; }}/><button className="primary" type="submit" disabled={asking}>{"Working…" if asking else "Ask"}</button></form>
                    {<div className="answer" aria-live="polite"><p>{answer.message}</p><ol>{[<li key={r.game.game_id}>{r.game.name + " · " + money(r.game.ticket_price) + " ticket · " + money(r.metrics.ev_per_dollar) + " gross EV / $1"}</li> for r in answer.games]}</ol></div> if answer is not None else None}
                </section>
                <section className="panel method"><span className="eyebrow">THE MATH, EXPLAINED</span><h2>Assumptions stay visible.</h2><div className="formula">Total gross EV = Σ(prize × remaining count) / estimated remaining tickets</div><p>Net EV excluding jackpot sums every smaller prize payout, divides by the same estimated ticket inventory, and subtracts the full ticket price. Jackpot odds use the remaining count of the largest prize divided by estimated remaining tickets.</p><p>Net EV subtracts the ticket price. Profit means a prize strictly larger than the ticket cost. EV change is the difference in gross return per dollar, shown in percentage points.</p><p>Unclaimed prizes can include already-sold tickets. Even a published unsold-ticket count does not fix that mismatch. Launch inventory is estimated from starting winning tickets × advertised odds. Remaining inventory uses the pooled retention of prizes up to twice the ticket price, falling back to the lowest tiers. The pool is bounded to fit all remaining winners.</p><p>Jackpot enrichment compares the fraction of top prizes left with the fraction of tickets left. An enrichment above 1 does not by itself imply a profitable game. Prize claim delays can create apparent boosts; small differences may reflect model error.</p></section>
            </div>
            <footer>Built with Jac · Deterministic analysis · Official Michigan Lottery data · No outcome guarantees</footer>
        </main>
    </div>;
}
