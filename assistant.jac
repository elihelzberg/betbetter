"""Explicit rule-based demo. Replace interpretation with byLLM later."""
import re;
import from models { Query, GameSnapshot, Answer }
import from analysis { rank_games }
import from models { Query, GameSnapshot, RankedGame, Answer }


# Cache validated question interpretations
glob interpretation_cache: dict[str, Query] = {};


def normalize_question(question: str) -> str {
    return " ".join(question.lower().split());
}

def cached_interpret_question(question: str) -> Query {
    key = normalize_question(question);

    if key in interpretation_cache {
        print("Gemini cache hit");
        saved = interpretation_cache[key];
    } else {
        print("Gemini cache miss");
        saved = interpret_question(question);

        # Validate before caching
        saved.state = "MI";

        if (
            saved.min_price < 0 or
            saved.max_price > 100 or
            saved.max_price < saved.min_price
        ) {
            raise ValueError("Invalid ticket price range.");
        }

        saved.limit = max(1, min(saved.limit, 20));

        allowed_sorts = [
            "ev_per_dollar",
            "profit_probability",
            "jackpot_probability",
            "any_probability",
            "ev_change"
        ];

        if saved.sort_by not in allowed_sorts {
            saved.sort_by = "ev_per_dollar";
        }

        interpretation_cache[key] = saved;
    }

    # Return a separate Query so callers cannot modify the cache
    return Query(
        state=saved.state,
        min_price=saved.min_price,
        max_price=saved.max_price,
        sort_by=saved.sort_by,
        search=saved.search,
        limit=saved.limit
    );
}

def interpret_question(question: str) -> Query by llm();

def format_ranked_facts(ranked: list[RankedGame]) -> str {
    lines: list[str] = [];

    for item in ranked {
        game = item.game;
        m = item.metrics;

        lines.append(f"Game: {game.name}");
        lines.append(f"Ticket price: ${game.ticket_price:.2f}");
        lines.append(f"Inventory method: {game.inventory_method}");

        if m.gross_ev is not None {
            lines.append(f"Gross expected payout: ${m.gross_ev:.2f}");
        } else {
            lines.append("Gross expected payout: unavailable");
        }

        if m.net_ev is not None {
            lines.append(f"Net expected value: ${m.net_ev:.2f}");
        } else {
            lines.append("Net expected value: unavailable");
        }

        if m.ev_per_dollar is not None {
            lines.append(f"Gross return per dollar: ${m.ev_per_dollar:.3f}");
        } else {
            lines.append("Gross return per dollar: unavailable");
        }

        if m.jackpot_probability is not None {
            lines.append(f"Jackpot probability: {m.jackpot_probability:.6f}");
        } else {
            lines.append("Jackpot probability: unavailable");
        }

        if m.profit_probability is not None {
            lines.append(f"Profit probability: {m.profit_probability:.6f}");
        } else {
            lines.append("Profit probability: unavailable");
        }

        lines.append("---");
    }

    return "\n".join(lines);
}

def basic_explanation(ranked: list[RankedGame], sort_by: str) -> str {
    if not ranked {
        return "No matching games were found.";
    }

    labels = {
        "ev_per_dollar": "gross expected return per dollar",
        "profit_probability": "estimated probability of making a profit",
        "jackpot_probability": "estimated jackpot probability",
        "any_probability": "estimated probability of winning any prize",
        "ev_change": "change in estimated expected return"
    };

    label = labels.get(sort_by, sort_by);
    first = ranked[0];
    m = first.metrics;

    message = f"These games are ranked by {label}. ";

    if sort_by == "ev_per_dollar" and m.ev_per_dollar is not None {
        message += (
            f"{first.game.name} ranks first with an estimated "
            f"gross return of ${m.ev_per_dollar:.3f} per dollar spent. "
        );
    } elif sort_by == "profit_probability" and m.profit_probability is not None {
        message += (
            f"{first.game.name} ranks first with an estimated "
            f"profit probability of {m.profit_probability * 100:.2f}%. "
        );
    } elif sort_by == "jackpot_probability" and m.jackpot_probability is not None {
        message += (
            f"{first.game.name} ranks first with an estimated "
            f"jackpot probability of {m.jackpot_probability * 100:.4f}%. "
        );
    } else {
        message += f"{first.game.name} is ranked first among the matching games. ";
    }

    if len(ranked) > 1 {
        second = ranked[1];
        message += f"{second.game.name} ranks second. ";
    }

    message += (
        "These rankings are based on estimated remaining ticket "
        "inventory and do not guarantee winnings or profits."
    );

    return message;
}

def explain_rankings(question: str, facts: str) -> str by llm();

sem explain_rankings = """
    You are BetBetter's educational Michigan lottery analysis assistant.

    Explain the ranking using ONLY the supplied calculated facts.

    Rules:
    1. Write in plain text. Do not use Markdown, asterisks, or headings.
    2. Keep the entire explanation under 150 words.
    3. Start by explaining which metric determines the ranking.
    4. Explain why the first game ranks highest.
    5. Briefly compare the first game with the second game.
    6. Explain what the ranking metric means in simple language.
    7. Use only game names and numerical values supplied in the facts.
    8. Never invent, recalculate, or convert probabilities or dollar values.
    9. Do not confuse jackpot probability with profit probability.
    10. Clearly distinguish gross expected payout from net expected value.
    11. If a metric is unavailable, state that it is unavailable.
    12. Explain that lottery calculations depend on estimated
        remaining inventory and do not guarantee winnings.
    13. Never promise a profit or encourage gambling.

    Use short, readable sentences.
""";

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
    if "jackpot" in text and ("odds" in text or "probability" in text) {
        query.sort_by = "jackpot_probability";
    } elif "profit" in text and ("odds" in text or "probability" in text) {
        query.sort_by = "profit_probability";
    } elif "any prize" in text or "winning anything" in text {
        query.sort_by = "any_probability";
    } elif "improved" in text or "ev change" in text {
        query.sort_by = "ev_change";
    } elif "expected return" in text or "expected value" in text {
        query.sort_by = "ev_per_dollar";
    }
    ranked = rank_games(games, query);
    if ranked {
        message = basic_explanation(ranked, query.sort_by);
    } else {
        message = "No matching Michigan scratch-off games were found.";
    }

    return Answer(
        message=message,
        games=ranked,
        mode="demo rules"
    );
}

def is_simple_question(question: str) -> bool {
    text = question.lower().strip();

    if "michigan" not in text and "scratch" not in text {
        return False;
    }

    prices = re.findall(r"\$(\d+(?:\.\d+)?)", text);
    if len(prices) < 1 or len(prices) > 2 {
        return False;
    }

    # Only simple ranking questions, not detailed analysis.
    if any(word in text for word in [
        "why", "explain", "compare", "difference",
        "recommend", "should i", "versus", " vs "
    ]) {
        return False;
    }

    # Don't interpret jackpot amounts as jackpot odds.
    if "jackpot" in text {
        return "odds" in text or "probability" in text;
    }

    if "profit" in text {
        return "odds" in text or "probability" in text;
    }

    if "any prize" in text or "winning anything" in text {
        return True;
    }

    if "expected return" in text or "expected value" in text {
        return True;
    }

    if "best" in text or "top" in text {
        return True;
    }

    return False;
}

def answer_question(question: str, games: list[GameSnapshot]) -> Answer {
    if not question.strip() or len(question) > 500 {
        raise ValueError("Enter a question between 1 and 500 characters.");
    }

    if is_simple_question(question) {
        return rule_based_answer(question, games);
}
    try {
        query = cached_interpret_question(question);

        query.state = "MI";

        if (
            query.min_price < 0 or
            query.max_price > 100 or
            query.max_price < query.min_price
        ) {
            raise ValueError("Invalid ticket price range.");
        }

        query.limit = max(1, min(query.limit, 20));

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

        ranked = rank_games(games, query);

        if ranked {
            message = basic_explanation(ranked, query.sort_by);
        } else {
            message = "No matching Michigan scratch-off games were found.";
        }

        return Answer(
            message=message,
            games=ranked,
            mode="AI-assisted"
        );

        } except Exception as e {
            print(f"Gemini chatbot error: {type(e).__name__}: {e}");
            return rule_based_answer(question, games);
        }
}
