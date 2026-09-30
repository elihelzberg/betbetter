"""Normalized adapter input and typed API output. Money is gross cash in USD."""
obj PrizeTier {
    has amount: float, original: int, remaining: int;
}
obj GameSnapshot {
    has game_id: str, name: str, state: str, ticket_price: float,
        prizes: list[PrizeTier], original_tickets: int,
        remaining_tickets: int | None, observed_at: str,
        launch_date: str, advertised_odds: float,
        inventory_method: str, source_url: str,
        is_demo: bool = True, status: str = "active";
}
obj Metrics {
    has launch_ev_per_dollar: float, top_prizes_remaining: float,
        gross_ev: float | None = None, net_ev: float | None = None,
        ev_per_dollar: float | None = None, any_probability: float | None = None,
        profit_probability: float | None = None, jackpot_probability: float | None = None,
        ev_change: float | None = None, jackpot_enrichment: float | None = None;
}
obj RankedGame { has game: GameSnapshot, metrics: Metrics; }
obj Query {
    has state: str = "MI", min_price: float = 0.0,
        max_price: float = 100.0, sort_by: str = "ev_per_dollar",
        search: str = "", limit: int = 100;
}
obj Answer { has message: str, games: list[RankedGame], mode: str = "demo rules"; }
