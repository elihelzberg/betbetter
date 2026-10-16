"""Explicit rule-based demo. Replace interpretation with byLLM later."""
import re;
import from models { Query, GameSnapshot, Answer }
import from analysis { rank_games }

def interpret_question(question: str) -> Query by llm();

sem interpret_question = "Convert a user's Michigan lottery scratch-off question into a Query. Use state MI. Set min_price and max_price from the requested ticket prices. Choose sort_by from ev_per_dollar, profit_probability, jackpot_probability, any_probability, or ev_change. Set limit from the requested number of results, or use 5 by default. Never invent lottery statistics.";

def rule_based_answer(question: str, games: list[GameSnapshot]) -> Answer {
    if not question.strip() or len(question) > 500 { raise ValueError("Enter a question between 1 and 500 characters."); }
    text = question.lower();
    if "michigan" not in text and "scratch" not in text and "best" not in text {
        return Answer(message="This is a rule-based demo, not AI yet. Try: What are the five best $10–$20 scratchers in Michigan?", games=[]);
    }
    query = Query(limit=5);
    prices = re.findall(r"\$(\d+(?:\.\d+)?)", text);
    if len(prices) == 1 { query.min_price = float(prices[0]); query.max_price = float(prices[0]); }
    elif len(prices) == 2 { query.min_price = float(prices[0]); query.max_price = float(prices[1]); }
    counts = re.findall(r"(?:top|best)\s+(\d+)", text);
    if counts { query.limit = int(counts[0]); }
    if "profit" in text { query.sort_by = "profit_probability"; }
    elif "jackpot" in text { query.sort_by = "jackpot_probability"; }
    elif "any prize" in text { query.sort_by = "any_probability"; }
    elif "improved" in text { query.sort_by = "ev_change"; }
    return Answer(
        message=f"Demo parser: Michigan, ${query.min_price:g}–${query.max_price:g}, up to {query.limit} games ranked by {query.sort_by}. Results use the dashboard calculator. Unknown estimates sort last. This parser only supports Michigan and explicit dollar amounts; it is not a general chatbot.",
        games=rank_games(games, query)
    );
}

def answer_question(question: str, games: list[GameSnapshot]) -> Answer {
    if not question.strip() or len(question) > 500 {
        raise ValueError("Enter a question between 1 and 500 characters.");
    }

    try {
        query = interpret_question(question);

        # Restrict queries to Michigan
        query.state = "MI";

        # Validate the price range
        if (
            query.min_price < 0 or
            query.max_price > 100 or
            query.max_price < query.min_price
        ) {
            raise ValueError("Invalid ticket price range.");
        }

        # Limit how many results we return
        query.limit = max(1, min(query.limit, 20));

        # Only accept supported ranking metrics
        allowed_sorts = [
            "ev_per_dollar",
            "profit_probability",
            "jackpot_probability",
            "any_probability",
            "ev_change"
        ];

        if query.sort_by not in allowed_sorts {
            query.sort_by = "ev_per_dollar";
        }

        # Use BetBetter's calculations, not AI-generated odds
        ranked = rank_games(games, query);

        return Answer(
            message=f"AI interpreted your question: Michigan tickets from ${query.min_price:g} to ${query.max_price:g}, ranked by {query.sort_by}. These are calculated estimates, not guaranteed outcomes.",
            games=ranked,
            mode="AI-assisted"
        );

        } except Exception as e {
            print(f"Gemini chatbot error: {type(e).__name__}: {e}");
            return rule_based_answer(question, games);
        }
}
