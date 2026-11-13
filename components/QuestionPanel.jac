import from models { Answer, RankedGame }
import from .Formatting { money, metric_label, metric_display }
import from .Icon { Icon }

def:pub QuestionPanel(
    question: str,
    answer: Answer | None,
    asking: bool,
    error: str,
    onQuestion: Callable[[str], None],
    onAsk: Callable[[FormEvent], None],
    onInspect: Callable[[RankedGame], None],
    busy: bool
) -> JsxElement {
    return
        <section
            id="ask"
            className="panel question-panel"
            aria-labelledby="ask-heading"
        >
            <div className="section-heading">
                <span className="section-kicker">
                    <Icon name="spark" size={18}/>{" "}
                    YOUR RESEARCH ASSISTANT
                </span>
                <span className="tag">AI assisted</span>
            </div>
            <h2 id="ask-heading">A question is a good place to start.</h2>
            <p className="section-description">
                Ask in plain English. Get rankings backed by the same data and calculations.
            </p>
            <form className="question-form" onSubmit={onAsk}>
                <label className="sr-only" htmlFor="research-question">
                    Ask about games
                </label>
                <textarea
                    id="research-question"
                    maxLength={500}
                    required
                    rows={3}
                    placeholder="What are the five best $10–$20 scratchers in Michigan?"
                    value={question}
                    onChange={lambda (e: ChangeEvent) { onQuestion(e.target.value); }}
                />
                <div className="question-actions">
                    <span>Michigan scratch-offs only</span>
                    <button className="primary" type="submit" disabled={asking}>
                        {"Thinking…" if asking else "Ask the data"}
                        <Icon name="arrow" size={17}/>
                    </button>
                </div>
            </form>
            <div className="suggestions">
                <span>Try asking</span>
                {[
                    <button
                        type="button"
                        key={prompt}
                        onClick={lambda { onQuestion(prompt); }}
                        disabled={asking}
                    >
                        {prompt}
                    </button>
                    for prompt in [
                        "Best $10 scratchers",
                        "Top 5 games by jackpot odds",
                        "Best expected return under $20"
                    ]
                ]}
            </div>
            {<p className="error" role="alert">{error}</p> if error else None}
            {<div className="answer" aria-live="polite">
                <span className="answer-mode">
                    {"Calculated ranking"
                        if answer.mode == "demo rules"
                        else answer.mode}
                </span>
                <p>{answer.message}</p>
                {<ol>
                    {[
                        <li key={r.game.game_id}>
                            <button
                                className="answer-game"
                                disabled={busy}
                                onClick={lambda { onInspect(r); }}
                            >
                                <span>
                                    <strong>{r.game.name}</strong>
                                    <small>
                                        {money(r.game.ticket_price) + " ticket"}
                                    </small>
                                </span>
                                <span>
                                    {metric_display(r, answer.sort_by)}
                                    <small>{metric_label(answer.sort_by)}</small>
                                </span>
                                <Icon name="chevron" size={16}/>
                            </button>
                        </li> for r in answer.games
                    ]}
                </ol>
                    if answer.games
                    else None}
            </div>
                if answer is not None
                else None}
            <details className="ai-disclaimer">
                <summary>
                    <Icon name="info" size={15}/>{" "}
                    About AI and responsible research
                </summary>
                <p>
                    AI can produce inaccurate or incomplete information. Lottery odds, rankings, and expected returns are estimates, not guarantees. This information is educational and is not financial or gambling advice. Gambling involves financial risk. Please play responsibly.
                </p>
            </details>
        </section>;
}
