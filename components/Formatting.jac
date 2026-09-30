"""Display helpers shared by the dashboard components."""
def:pub money(value: float | None) -> str {
    return "Unknown" if value is None else f"${value:.2f}";
}
def:pub percent(value: float | None) -> str {
    return "Unknown" if value is None else f"{value * 100:.2f}%";
}
def:pub odds(value: float | None) -> str {
    if value is None { return "Unknown"; }
    if value == 0 { return "No prizes left"; }
    return f"1 in {1 / value:.0f}";
}
def:pub change(value: float | None) -> str {
    if value is None { return "Unknown"; }
    return ("+" if value > 0 else "") + f"{value * 100:.2f} pp";
}
