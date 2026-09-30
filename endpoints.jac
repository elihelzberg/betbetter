"""Read-only public API; scraping and model calls stay behind server seams."""
import from models { Query, RankedGame, Answer, GameSnapshot }
import from analysis { calculate, rank_games }
import from repository { latest_snapshots, all_snapshots }
import from assistant { answer_question }
import from datetime { datetime }

def:pub list_games(query: Query) -> list[RankedGame] { return rank_games(latest_snapshots(), query); }

def:pub game_history(game_id: str, state: str = "MI") -> list[RankedGame] {
    history = [g for g in all_snapshots() if g.game_id == game_id and g.state == state.upper()];
    history.sort(key=lambda (g: GameSnapshot) -> float { return datetime.fromisoformat(g.observed_at).timestamp(); });
    return [RankedGame(game=g, metrics=calculate(g)) for g in history];
}

def:pub ask_question(question: str) -> Answer { return answer_question(question, latest_snapshots()); }
