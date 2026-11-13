import from .Icon { Icon }

def:pub ResearchNotes -> JsxElement {
    return
        <section
            id="methodology"
            className="panel method"
            aria-labelledby="method-heading"
        >
            <span className="section-kicker">
                <Icon name="book" size={18}/>{" "}
                UNDERSTAND THE NUMBERS
            </span>
            <h2 id="method-heading">Good research shows its work.</h2>
            <p className="section-description">
                A few things to know before comparing games.
            </p>
            <details open={True}>
                <summary>
                    <span className="note-number">01</span>
                    Expected value, in plain English
                    <Icon name="chevron" size={16}/>
                </summary>
                <div className="note-body">
                    <p>
                        Gross EV is the estimated average payout across all tickets. A gross EV of $0.75 per $1 means an expected loss of $0.25 per dollar over many tickets.
                    </p>
                    <div className="formula">
                        Gross EV = Σ(prize × remaining count)
                        <br/>
                        ÷ estimated remaining tickets
                    </div>
                    <p>
                        Net EV subtracts the ticket price. Net EV excluding jackpot omits the largest prize payout, keeps every ticket in the denominator, and subtracts the full ticket cost.
                    </p>
                </div>
            </details>
            <details>
                <summary>
                    <span className="note-number">02</span>
                    Why these odds are estimates
                    <Icon name="chevron" size={16}/>
                </summary>
                <div className="note-body">
                    <p>
                        Michigan Lottery publishes prize counts, ticket prices, and advertised launch odds. It does not publish current ticket inventory in these queries. Unclaimed prizes may belong to already-purchased tickets.
                    </p>
                    <p>
                        Launch tickets are estimated from starting winning-ticket counts × advertised odds. Remaining tickets use pooled prize retention for tiers paying up to twice the ticket cost, falling back to the lowest tiers. The estimate is bounded to fit remaining winners. Prize claim delays and rounded odds add uncertainty.
                    </p>
                </div>
            </details>
            <details>
                <summary>
                    <span className="note-number">03</span>
                    Change is relative to launch
                    <Icon name="chevron" size={16}/>
                </summary>
                <div className="note-body">
                    <p>
                        Probability change compares the modeled current probability with its launch probability. Profit means a prize strictly greater than the ticket price. A positive change does not mean positive expected value.
                    </p>
                    <p>
                        EV change is measured in percentage points of gross return per dollar. Jackpot enrichment compares top-prize retention with estimated ticket retention. Small differences may reflect model error.
                    </p>
                </div>
            </details>
            <details>
                <summary>
                    <span className="note-number">04</span>
                    Sources, collection &amp; history
                    <Icon name="chevron" size={16}/>
                </summary>
                <div className="note-body">
                    <p>
                        The complete official Michigan retail instant-game catalog is cached for six hours. Failed refreshes keep the last successful collection available; check the collection date in game details.
                    </p>
                    <p>
                        Each successful collection adds a snapshot. Historical observations use the same model when read. The displayed launch date is the catalog date, not an independently verified first-sale date.
                    </p>
                    <a
                        href="https://www.michiganlottery.com/games/instant-games"
                        target="_blank"
                        rel="noreferrer"
                    >
                        Visit Michigan Lottery
                        <Icon name="external" size={14}/>
                    </a>
                </div>
            </details>
            <div className="research-principle">
                <Icon name="shield" size={19}/>
                <span>
                    Transparent assumptions.
                    <br/>
                    <strong>No outcome guarantees.</strong>
                </span>
            </div>
        </section>;
}
