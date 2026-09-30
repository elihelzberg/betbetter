"""Explicit rule-based demo. Replace interpretation with byLLM later."""
import re;
import from models { Query, GameSnapshot, Answer }
import from analysis { rank_games }

def answer_question(question: str, games: list[GameSnapshot]) -> Answer {
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
