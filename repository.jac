"""Live reads use the SQLite collector cache; graph ingestion is a private legacy helper."""
import from models { GameSnapshot }
import from analysis { validate_snapshot }
import from adapters.michigan { fetch_live }
import from datetime { datetime }

node StoredSnapshot { has snapshot: GameSnapshot; }

def save_snapshot(snapshot: GameSnapshot) -> bool {
    validate_snapshot(snapshot);
    for record in [root.shared-->][?:StoredSnapshot] {
        previous = record.snapshot;
        if previous.state == snapshot.state and previous.game_id == snapshot.game_id and previous.observed_at == snapshot.observed_at {
            return False;
        }
    }
    root.shared ++> StoredSnapshot(snapshot=snapshot);
    return True;
}

def all_snapshots() -> list[GameSnapshot] {
    return fetch_live(history=True);
}

def latest_snapshots() -> list[GameSnapshot] {
    latest: dict[str, GameSnapshot] = {};
    for snapshot in fetch_live() {
        key = snapshot.state + ":" + snapshot.game_id;
        if key not in latest or datetime.fromisoformat(snapshot.observed_at) > datetime.fromisoformat(latest[key].observed_at) {
            latest[key] = snapshot;
        }
    }
    return list(latest.values());
}
