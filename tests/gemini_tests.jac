import from assistant { answer_question }
import from models { Query }
import from unittest.mock { patch }

test "greetings do not require a model call" {
    with patch("assistant.interpret_question", side_effect=RuntimeError("must not call")) {
        answer = answer_question("Hi!", []);
        assert answer.mode == "greeting";
        assert "Hi!" in answer.message;
        assert answer.games == [];
    }
}

test "Gemini query output is constrained before calculating results" {
    query = Query(state="CA", min_price=10.0, max_price=10.0, limit=500, sort_by="invented");
    with patch("assistant.interpret_question", return_value=query) {
        answer = answer_question("Best ten dollar games", []);
        assert answer.mode == "AI-assisted";
        assert query.state == "MI";
        assert query.limit == 20;
        assert query.sort_by == "ev_per_dollar";
    }
}

test "model failure is disclosed in the response" {
    with patch("assistant.interpret_question", side_effect=RuntimeError("provider unavailable")) {
        answer = answer_question("hello there", []);
        assert answer.mode == "rules fallback";
        assert "Gemini is temporarily unavailable" in answer.message;
    }
}
