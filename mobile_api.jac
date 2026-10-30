"""Mobile REST routes backed by the same services as the web dashboard."""
import from http { HTTPMethod }
import from models { Query, RankedGame, Answer }
import from endpoints { list_games, game_history, ask_question }

@restspec(method=HTTPMethod.POST, path="/api/games", produces="application/json", envelope=False)
def:pub mobile_games(
    state: str = "MI", min_price: float = 0.0, max_price: float = 100.0,
    sort_by: str = "jackpot_boost", search: str = "", limit: int = 1000
) -> list[RankedGame] {
    return list_games(Query(state=state, min_price=min_price, max_price=max_price,
        sort_by=sort_by, search=search, limit=limit));
}

@restspec(method=HTTPMethod.GET, path="/api/games/{game_id}/history", produces="application/json", envelope=False)
def:pub mobile_game_history(game_id: str, state: str = "MI") -> list[RankedGame] {
    return game_history(game_id=game_id, state=state);
}

@restspec(method=HTTPMethod.POST, path="/api/ask", produces="application/json", envelope=False)
def:pub mobile_ask(question: str) -> Answer {
    return ask_question(question);
}
