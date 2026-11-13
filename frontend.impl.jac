"""Request state belongs to the shell; presentation stays in section components."""
impl Dashboard.load(query: Query) -> None {
    loading = True;
    error = "";
    try {
        games = await list_games(query);
        ranked_by = query.sort_by;
        selected = None;
        history = [];
        history_error = "";
    } except Exception {
        error = "Could not load games. Check your price range and try again. Your previous results are still available.";
    } finally {
        loading = False;
    }
}

impl Dashboard.refresh -> None {
    await load(
        Query(
            min_price=float(minimum or "0"),
            max_price=float(maximum or "100"),
            sort_by=sort_by,
            search=search
        )
    );
}

impl Dashboard.apply_filters(e: FormEvent) -> None {
    e.preventDefault();
    range: any = document.querySelector(".price-range");
    if range {
        range.open = False;
    }
    await refresh();
}

impl Dashboard.choose_price(price: str) -> None {
    low = "0" if price == "All" else price;
    high = "100" if price == "All" else price;
    minimum = low;
    maximum = high;
    await load(
        Query(
            min_price=float(low), max_price=float(high), sort_by=sort_by, search=search
        )
    );
}

impl Dashboard.reset_filters -> None {
    minimum = "0";
    maximum = "100";
    search = "";
    sort_by = "jackpot_boost";
    await load(Query(sort_by="jackpot_boost"));
}

impl Dashboard.inspect(item: RankedGame) -> None {
    selected = item;
    history = [];
    history_loading = True;
    history_error = "";
    try {
        history = await game_history(item.game.game_id, item.game.state);
    } except Exception {
        history_error = "Snapshot history could not be loaded. The game details are still available.";
    } finally {
        history_loading = False;
    }
}

impl Dashboard.ask(e: FormEvent) -> None {
    e.preventDefault();
    if not question.strip() {
        return;
    }
    asking = True;
    question_error = "";
    answer = None;
    try {
        answer = await ask_question(question);
    } except Exception {
        question_error = "Could not answer this question. Try a simple ranking question with a valid price range.";
    } finally {
        asking = False;
    }
}
