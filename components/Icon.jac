"""Small, consistent line icons used across the research dashboard."""
def:pub Icon(name: str, size: int = 20) -> JsxElement {
    paths = {
        "grid": "M3 3h7v7H3z M14 3h7v7h-7z M3 14h7v7H3z M14 14h7v7h-7z",
        "chart": "M4 19V5 M4 19h16 M8 15l4-5 4 2 4-7",
        "spark": "m12 3 2.5 6.5L21 12l-6.5 2.5L12 21l-2.5-6.5L3 12l6.5-2.5L12 3z",
        "book": "M12 5v15 M12 5C9 3 5 3 2 4v15c3-1 7-1 10 1 3-2 7-2 10-1V4c-3-1-7-1-10 1z",
        "arrow": "M5 12h14 M13 6l6 6-6 6",
        "external": "M14 3h7v7 M21 3 10 14 M10 3H4v17h17v-6",
        "search": "M21 21l-5-5 M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0",
        "filter": "M3 6h18 M6 12h12 M10 18h4",
        "refresh": "M20 7v5h-5 M4 17v-5h5 M6 6a8 8 0 0 1 13 3 M18 18A8 8 0 0 1 5 15",
        "check": "m5 12 4 4L19 6",
        "clock": "M12 8v5l3 2 M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0",
        "info": "M12 11v6 M12 7h.01 M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0",
        "close": "m6 6 12 12 M6 18 18 6",
        "chevron": "m9 5 7 7-7 7",
        "ticket": "M3 5h18v5a2 2 0 0 0 0 4v5H3v-5a2 2 0 0 0 0-4V5z M15 5v3 M15 11v2 M15 16v3",
        "shield": "m12 3 9 4v5c0 5-9 9-9 9s-9-4-9-9V7l9-4z m-4 9 3 3 5-5"
    };
    return
        <svg
            width={size}
            height={size}
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth={1.7}
            strokeLinecap="round"
            strokeLinejoin="round"
            aria-hidden="true"
        >
            <path d={paths.get(name, paths["chart"])}/>
        </svg>;
}
