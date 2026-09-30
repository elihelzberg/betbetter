import from models { GameSnapshot, PrizeTier, Query }
import from analysis { calculate, validate_snapshot, rank_games, metric_value }
import from adapters.michigan { demo_snapshots, fetch_live }
import from assistant { answer_question }
import from repository { save_snapshot, latest_snapshots, all_snapshots }
import from endpoints { list_games, game_history }

def fixture() -> GameSnapshot {
    return GameSnapshot(game_id="TEST", name="Known arithmetic", state="MI", ticket_price=10.0,
        prizes=[PrizeTier(amount=10.0, original=20, remaining=10), PrizeTier(amount=20.0, original=10, remaining=5), PrizeTier(amount=100.0, original=2, remaining=1)],
        original_tickets=100, remaining_tickets=40, observed_at="2026-09-29T12:00:00+00:00",
        launch_date="2026-01-01", advertised_odds=3.125, inventory_method="demo assumption", source_url="");
}

test "hand calculated EV probabilities and enrichment" {
    m = calculate(fixture());
    assert m.gross_ev == 7.5;
    assert m.net_ev == -2.5;
    assert m.ev_per_dollar == 0.75;
    assert m.launch_ev_per_dollar == 0.6;
    assert m.any_probability == 0.4;
    assert m.profit_probability == 0.15;
    assert m.jackpot_probability == 0.025;
    assert m.top_prizes_remaining == 0.5;
    assert m.jackpot_enrichment == 1.25;
    assert abs((m.ev_change as float) - 0.15) < 1e-10;
}

test "unknown inventory preserves only inventory independent metrics" {
    game = fixture(); game.remaining_tickets = None; game.inventory_method = "unknown";
    m = calculate(game);
    assert m.ev_per_dollar is None and m.net_ev is None;
    assert m.any_probability is None and m.jackpot_enrichment is None;
    assert m.top_prizes_remaining == 0.5;
}

test "no top prizes is zero probability not unknown" {
    game = fixture(); game.prizes[2].remaining = 0;
    m = calculate(game);
    assert m.jackpot_probability == 0.0;
    assert m.jackpot_enrichment == 0.0;
}

test "sold out inventory is not divided by zero or ranked" {
    game = fixture(); game.remaining_tickets = 0;
    for p in game.prizes { p.remaining = 0; }
    assert calculate(game).gross_ev is None;
    assert rank_games([game], Query()) == [];
}

test "invalid source counts are rejected" {
    game = fixture(); game.prizes[0].remaining = 21;
    with testraises(ValueError) { validate_snapshot(game); }
    game = fixture(); game.remaining_tickets = 5;
    with testraises(ValueError) { validate_snapshot(game); }
    game = fixture(); game.ticket_price = float("nan");
    with testraises(ValueError) { validate_snapshot(game); }
    game = fixture(); game.prizes.append(game.prizes[0]);
    with testraises(ValueError) { validate_snapshot(game); }
}

test "queries reject reversed prices nonfinite values and unknown rankings" {
    with testraises(ValueError) { rank_games([], Query(min_price=20.0, max_price=10.0)); }
    with testraises(ValueError) { rank_games([], Query(min_price=float("nan"))); }
    with testraises(ValueError) { rank_games([], Query(sort_by="made_up")); }
    with testraises(ValueError) { rank_games([], Query(limit=0)); }
}

test "all rankings descend with unknown values last" {
    games = latest_snapshots();
    for metric in ["ev_per_dollar", "any_probability", "profit_probability", "jackpot_probability", "top_prizes_remaining", "ev_change", "jackpot_enrichment"] {
        rows = rank_games(games, Query(sort_by=metric));
        previous = float("inf");
        for row in rows {
            value = metric_value(row, metric);
            score = value if value is not None else float("-inf");
            assert score <= previous;
            previous = score;
        }
    }
    assert rank_games(games, Query())[-1].game.game_id == "DEMO-MI-004";
}

test "filter by price state name status and limit" {
    games = latest_snapshots();
    rows = rank_games(games, Query(min_price=10.0, max_price=20.0));
    assert len(rows) == 3;
    assert len(rank_games(games, Query(state="OH"))) == 0;
    assert len(rank_games(games, Query(search="GREAT LAKES"))) == 1;
    assert len(rank_games(games, Query(limit=2))) == 2;
    game = fixture(); game.status = "ended";
    assert rank_games([game], Query()) == [];
}

test "history is chronological and latest snapshots are deduplicated" {
    assert len(latest_snapshots()) == 6;
    history = game_history("DEMO-MI-001");
    assert len(history) == 2;
    assert history[0].game.observed_at < history[1].game.observed_at;
    assert game_history("does-not-exist") == [];
    assert len(list_games(Query())) == 6;
}

test "ingestion is idempotent and uses persisted snapshots instead of fixtures" {
    game = fixture();
    assert save_snapshot(game);
    assert not save_snapshot(game);
    assert len(all_snapshots()) == 1;
    newer = fixture(); newer.observed_at = "2026-09-30T12:00:00+00:00";
    assert save_snapshot(newer);
    assert len(all_snapshots()) == 2;
    assert latest_snapshots()[0].observed_at == newer.observed_at;
}

test "question demo invokes same deterministic price filtering" {
    answer = answer_question("What are the five best $10–$20 scratchers in Michigan?", latest_snapshots());
    assert len(answer.games) == 3;
    assert answer.mode == "demo rules";
    assert answer.games[0].game.game_id == "DEMO-MI-001";
    assert answer_question("hello", latest_snapshots()).games == [];
    with testraises(ValueError) { answer_question("", []); }
}

test "live adapter cannot silently return sample data" {
    with testraises(NotImplementedError) { fetch_live(); }
    for game in demo_snapshots() { validate_snapshot(game); assert game.is_demo; }
}
