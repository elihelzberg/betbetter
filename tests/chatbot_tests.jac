"""Current rule routing and OpenRouter interpretation contracts; no live model calls."""
import from assistant { answer_question, cached_interpret_question }
import from models { Query }
import from unittest.mock { patch }

test "simple rankings do not require a model call" {
    with patch(
        "assistant.interpret_question", side_effect=RuntimeError("must not call")
    ) {
        answer = answer_question("Best $10 scratchers", []);
        assert answer.mode == "demo rules";
        assert answer.games == [];
    }
}

test "AI interpretation normalizes prices state limit and generic search" {
    query = Query(
        state="CA", min_price=0.0, max_price=0.0, limit=500, search="Michigan lottery"
    );
    with patch("assistant.interpretation_cache", {}), patch(
        "assistant.allow_request", return_value=True
    ), patch("assistant.interpret_question", return_value=query) {
        result = cached_interpret_question("Compare expected returns for research");
        assert result.state == "MI";
        assert result.min_price == 0.0 and result.max_price == 100.0;
        assert result.limit == 20;
        assert result.search == "";
        assert result.sort_by == "ev_per_dollar";
    }
}

test "unsupported model rankings fail explicitly" {
    with patch("assistant.interpretation_cache", {}), patch(
        "assistant.allow_request", return_value=True
    ), patch("assistant.interpret_question", return_value=Query(sort_by="invented")) {
        with testraises(ValueError) {
            cached_interpret_question("Compare unknown metrics");
        }
    }
}

test "cached interpretations are copied and avoid repeated model requests" {
    with patch("assistant.interpretation_cache", {}), patch(
        "assistant.allow_request", return_value=True
    ), patch(
        "assistant.interpret_question", return_value=Query(max_price=20.0)
    ) as model {
        first = cached_interpret_question(" Compare games ");
        first.max_price = 99.0;
        second = cached_interpret_question("compare games");
        assert second.max_price == 20.0;
        assert model.call_count == 1;
    }
}

test "model failure is disclosed without fabricated results" {
    with patch("assistant.interpretation_cache", {}), patch(
        "assistant.allow_request", return_value=True
    ), patch(
        "assistant.interpret_question", side_effect=RuntimeError("provider unavailable")
    ) {
        answer = answer_question("Explain the difference between these games", []);
        assert answer.mode == "AI unavailable";
        assert "AI service is temporarily unavailable" in answer.message;
        assert answer.games == [];
    }
}
