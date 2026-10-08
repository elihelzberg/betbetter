"""Pure calculations over published or explicitly estimated inventory."""
import from math { isfinite }
import from datetime { date, datetime }
import from models { GameSnapshot, Metrics, RankedGame, Query, PrizeTier }

def validate_snapshot(game: GameSnapshot) -> None {
    if not game.game_id.strip() or not game.name.strip() or len(game.state) != 2 {
        raise ValueError("Game ID, name and two-letter state are required.");
    }
    if not isfinite(game.ticket_price) or game.ticket_price <= 0 {
        raise ValueError("Ticket price must be finite and positive.");
    }
    if (game.original_tickets is not None and game.original_tickets <= 0) or not game.prizes {
        raise ValueError("Original ticket inventory and prize tiers are required.");
    }
    if not isfinite(game.advertised_odds) or game.advertised_odds < 1 {
        raise ValueError("Advertised odds must be a finite 1-in-N denominator.");
    }
    date.fromisoformat(game.launch_date);
    observed = datetime.fromisoformat(game.observed_at);
    if observed.tzinfo is None { raise ValueError("Observation timestamp must include a timezone."); }
    if game.status not in ["active", "ended"] { raise ValueError("Unknown game status."); }
    original_winners = 0;
    remaining_winners = 0;
    amounts: list[float] = [];
    for tier in game.prizes {
        if not isfinite(tier.amount) or tier.amount <= 0 or tier.amount in amounts {
            raise ValueError("Prize amounts must be unique, positive and finite.");
        }
        if tier.original <= 0 or tier.remaining < 0 or tier.remaining > tier.original {
            raise ValueError("Invalid prize counts.");
        }
        amounts.append(tier.amount);
        original_winners += tier.original;
        remaining_winners += tier.remaining;
    }
    if game.original_tickets is not None and original_winners > game.original_tickets { raise ValueError("More winning tickets than original inventory."); }
    if game.remaining_tickets is not None {
        inventory = game.remaining_tickets;
        if inventory < 0 or (game.original_tickets is not None and inventory > game.original_tickets) or remaining_winners > inventory {
            raise ValueError("Remaining inventory is incompatible with prize counts.");
        }
        if game.inventory_method not in ["demo assumption", "published unsold", "estimate"] {
            raise ValueError("Known inventory requires an explicit inventory method.");
        }
    } elif game.inventory_method != "unknown" { raise ValueError("Missing inventory must have method unknown."); }
}

def calculate(game: GameSnapshot) -> Metrics {
    validate_snapshot(game);
    original_value = 0.0;
    remaining_value = 0.0;
    winners = 0;
    profit_winners = 0;
    original_winners = 0;
    original_profit_winners = 0;
    top = max(game.prizes, key=lambda (p: PrizeTier) -> float { return p.amount; });
    for tier in game.prizes {
        original_value += tier.amount * tier.original;
        remaining_value += tier.amount * tier.remaining;
        winners += tier.remaining;
        original_winners += tier.original;
        if tier.amount > game.ticket_price { profit_winners += tier.remaining; original_profit_winners += tier.original; }
    }
    result = Metrics(launch_ev_per_dollar=(original_value / game.original_tickets / game.ticket_price) if game.original_tickets is not None else None,
        top_prizes_remaining=top.remaining / top.original);
    inventory = game.remaining_tickets;
    if inventory is None or inventory == 0 { return result; }
    result.gross_ev = remaining_value / inventory;
    result.net_ev = remaining_value / inventory - game.ticket_price;
    # Keep every ticket in the denominator; exclude only the largest prize payout.
    result.non_jackpot_net_ev = (remaining_value - top.amount * top.remaining) / inventory - game.ticket_price;
    result.ev_per_dollar = remaining_value / inventory / game.ticket_price;
    result.any_probability = winners / inventory;
    result.profit_probability = profit_winners / inventory;
    result.jackpot_probability = top.remaining / inventory;
    if result.launch_ev_per_dollar is not None {
        result.ev_change = remaining_value / inventory / game.ticket_price - result.launch_ev_per_dollar;
    }
    if game.original_tickets is not None {
        result.jackpot_enrichment = (top.remaining / top.original) / (inventory / game.original_tickets);
        result.jackpot_boost = result.jackpot_enrichment - 1;
        result.any_boost = (winners / inventory) / (original_winners / game.original_tickets) - 1;
        if original_profit_winners > 0 {
            result.profit_boost = (profit_winners / inventory) / (original_profit_winners / game.original_tickets) - 1;
        }
    }
    return result;
}

def metric_value(item: RankedGame, metric: str) -> float | None {
    m = item.metrics;
    if metric == "non_jackpot_net_ev" { return m.non_jackpot_net_ev; }
    if metric == "any_boost" { return m.any_boost; }
    if metric == "profit_boost" { return m.profit_boost; }
    if metric == "jackpot_boost" { return m.jackpot_boost; }
    if metric == "ev_per_dollar" { return m.ev_per_dollar; }
    if metric == "any_probability" { return m.any_probability; }
    if metric == "profit_probability" { return m.profit_probability; }
    if metric == "jackpot_probability" { return m.jackpot_probability; }
    if metric == "top_prizes_remaining" { return m.top_prizes_remaining; }
    if metric == "ev_change" { return m.ev_change; }
    if metric == "jackpot_enrichment" { return m.jackpot_enrichment; }
    raise ValueError("Unsupported ranking metric.");
}

def rank_games(games: list[GameSnapshot], query: Query) -> list[RankedGame] {
    if not isfinite(query.min_price) or not isfinite(query.max_price) or query.min_price < 0 or query.max_price < query.min_price {
        raise ValueError("Provide a valid ticket-price range.");
    }
    if query.limit < 1 or query.limit > 1000 { raise ValueError("Limit must be 1 to 1000."); }
    if query.sort_by not in ["non_jackpot_net_ev", "any_boost", "profit_boost", "jackpot_boost", "ev_per_dollar", "any_probability", "profit_probability", "jackpot_probability", "top_prizes_remaining", "ev_change", "jackpot_enrichment"] {
        raise ValueError("Unsupported ranking metric.");
    }
    rows: list[RankedGame] = [];
    for game in games {
        if game.state != query.state.upper() or game.status != "active" or game.remaining_tickets == 0 { continue; }
        if not (query.min_price <= game.ticket_price <= query.max_price) { continue; }
        if query.search.lower() not in (game.name + " " + game.game_id).lower() { continue; }
        rows.append(RankedGame(game=game, metrics=calculate(game)));
    }
    rows.sort(key=lambda (r: RankedGame) -> str { return r.game.game_id; });
    def score(row: RankedGame) -> float {
        value = metric_value(row, query.sort_by);
        return value if value is not None else float("-inf");
    }
    rows.sort(key=score, reverse=True);
    return rows[:query.limit];
}
