"""Refresh the complete official Michigan scratch-off catalog."""
from michigan_live import load_snapshots

if __name__ == "__main__":
    games = load_snapshots(force=True)
    print(f"Collected {len(games)} Michigan scratch-off games.")
