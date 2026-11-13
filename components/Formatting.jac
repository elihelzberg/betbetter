"""Display helpers shared by research components. Missing estimates stay explicit."""
import from models { RankedGame }
def:pub money(value: float | None) -> str {
    if value is None {
        return "Not applicable";
    }
    # JavaScript numbers expose locale formatting outside Jac's float type.
    number: any = value;
    return str(
        number.toLocaleString("en-US", {"style": "currency", "currency": "USD"})
    );
}

def:pub percent(value: float | None) -> str {
    return "Not applicable" if value is None else f"{value * 100:.2f}%";
}

def:pub odds(value: float | None) -> str {
    if value is None {
        return "Not applicable";
    }
    if value == 0 {
        return "No prizes left";
    }
    number: any = 1 / value;
    return "1 in " + str(number.toLocaleString("en-US", {"maximumFractionDigits": 0}));
}

def:pub count_label(value: int | None) -> str {
    if value is None {
        return "Not published";
    }
    number: any = value;
    return str(number.toLocaleString("en-US"));
}

def:pub change(value: float | None) -> str {
    if value is None {
        return "Not applicable";
    }
    return ("+" if value > 0 else "") + f"{value * 100:.2f} pp";
}

def:pub boost(value: float | None) -> str {
    if value is None {
        return "No launch profit prizes";
    }
    return ("+" if value > 0 else "") + f"{value * 100:.2f}%";
}

def:pub date_label(value: str) -> str {
    if not value {
        return "Not available";
    }
    return new(Date, value).toLocaleDateString(
        "en-US",
        {"month": "short", "day": "numeric", "year": "numeric", "timeZone": "UTC"}
    );
}

def:pub metric_label(metric: str) -> str {
    labels = {
        "jackpot_boost": "Jackpot change",
        "profit_boost": "Profit change",
        "any_boost": "Any-prize change",
        "ev_per_dollar": "Gross EV / $1",
        "non_jackpot_net_ev": "Net EV excl. jackpot",
        "any_probability": "Any-prize probability",
        "profit_probability": "Profit probability",
        "jackpot_probability": "Jackpot odds",
        "top_prizes_remaining": "Top-prize retention",
        "ev_change": "EV change",
        "jackpot_enrichment": "Jackpot enrichment"
    };
    return labels.get(metric, "Gross EV / $1");
}

def:pub metric_display(item: RankedGame, metric: str) -> str {
    m = item.metrics;
    if metric == "jackpot_boost" {
        return boost(m.jackpot_boost);
    }
    if metric == "profit_boost" {
        return boost(m.profit_boost);
    }
    if metric == "any_boost" {
        return boost(m.any_boost);
    }
    if metric == "non_jackpot_net_ev" {
        return money(m.non_jackpot_net_ev);
    }
    if metric == "any_probability" {
        return percent(m.any_probability);
    }
    if metric == "profit_probability" {
        return percent(m.profit_probability);
    }
    if metric == "jackpot_probability" {
        return odds(m.jackpot_probability);
    }
    if metric == "top_prizes_remaining" {
        return percent(m.top_prizes_remaining);
    }
    if metric == "ev_change" {
        return change(m.ev_change);
    }
    if metric == "jackpot_enrichment" {
        return "Not applicable"
            if m.jackpot_enrichment is None
            else f"{m.jackpot_enrichment:.2f}×";
    }
    return money(m.ev_per_dollar);
}
