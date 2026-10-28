"""Refresh official Michigan lottery data when the dev server starts."""
import from michigan_live { load_snapshots }

with entry {
    try {
        games = load_snapshots(force=True);
        print(f"Refreshed {len(games)} Michigan scratch-off games.");
    } except Exception as error {
        print(f"Michigan Lottery refresh failed; the app will use its cached data: {error}");
    }
}
