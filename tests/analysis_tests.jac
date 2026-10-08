import from models { GameSnapshot, PrizeTier, Query }
import from analysis { calculate, validate_snapshot, rank_games, metric_value }
import from adapters.michigan { demo_snapshots, fetch_live }
import from assistant { answer_question }
import from repository { save_snapshot, latest_snapshots, all_snapshots }
import from endpoints { list_games, game_history }
import from unittest.mock { patch }


def demo_latest() -> list[GameSnapshot] {
    return [g for g in demo_snapshots() if g.observed_at == "2026-09-29T12:00:00+00:00"];
}

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
    games = demo_latest();
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
    games = demo_latest();
    rows = rank_games(games, Query(min_price=10.0, max_price=20.0));
    assert len(rows) == 3;
    assert len(rank_games(games, Query(state="OH"))) == 0;
    assert len(rank_games(games, Query(search="GREAT LAKES"))) == 1;
    assert len(rank_games(games, Query(limit=2))) == 2;
    game = fixture(); game.status = "ended";
    assert rank_games([game], Query()) == [];
}

test "history is chronological and service uses live adapter" {
    with patch("repository.fetch_live", return_value=demo_snapshots()) {
        assert len(latest_snapshots()) == 6;
        history = game_history("DEMO-MI-001");
        assert len(history) == 2;
        assert history[0].game.observed_at < history[1].game.observed_at;
        assert game_history("does-not-exist") == [];
        assert len(list_games(Query())) == 6;
    }
}

test "ingestion is idempotent" {
    game = fixture();
    assert save_snapshot(game);
    assert not save_snapshot(game);
}

test "question demo invokes same deterministic price filtering" {
    answer = answer_question("What are the five best $10–$20 scratchers in Michigan?", demo_latest());
    assert len(answer.games) == 3;
    assert answer.mode == "demo rules";
    assert answer.games[0].game.game_id == "DEMO-MI-001";
    assert answer_question("hello", latest_snapshots()).games == [];
    with testraises(ValueError) { answer_question("", []); }
}

test "missing official inventories do not fabricate metrics" {
    game = fixture();
    game.original_tickets = None;
    game.remaining_tickets = None;
    game.inventory_method = "unknown";
    game.is_demo = False;
    m = calculate(game);
    assert m.launch_ev_per_dollar is None and m.ev_per_dollar is None;
    assert m.top_prizes_remaining == 0.5;
    games = [game for i in range(107)];
    assert len(rank_games(games, Query())) == 107;
}

test "probability boosts compare current and launch probabilities" {
    m = calculate(fixture());
    assert abs((m.any_boost as float) - 0.25) < 1e-10;
    assert abs((m.profit_boost as float) - 0.25) < 1e-10;
    assert abs((m.jackpot_boost as float) - 0.25) < 1e-10;
    game = fixture(); game.prizes[2].remaining = 0;
    assert calculate(game).jackpot_boost == -1.0;
    assert len(rank_games([game], Query(sort_by="jackpot_boost"))) == 1;
}

test "non jackpot net EV excludes payout but preserves full inventory" {
    game = fixture();
    m = calculate(game);
    assert m.non_jackpot_net_ev == -5.0;
    assert m.jackpot_probability == 0.025;
    assert m.net_ev == (m.non_jackpot_net_ev as float) + 100.0 / 40;
    game.prizes[2].remaining = 0;
    assert calculate(game).non_jackpot_net_ev == -5.0;
    assert calculate(game).jackpot_probability == 0;
    game = fixture(); game.remaining_tickets = None; game.inventory_method = "unknown";
    assert calculate(game).non_jackpot_net_ev is None;
    game = fixture(); game.prizes = [game.prizes[2]];
    assert calculate(game).non_jackpot_net_ev == -10.0;
}

test "non jackpot ranking favors smaller prize return over jackpot size" {
    first = fixture(); first.game_id = "A";
    second = fixture(); second.game_id = "B";
    second.prizes[0].remaining = 20;
    second.prizes[2].remaining = 0;
    rows = rank_games([first, second], Query(sort_by="non_jackpot_net_ev"));
    assert rows[0].game.game_id == "B";
    assert rows[0].metrics.non_jackpot_net_ev == -2.5;
}
