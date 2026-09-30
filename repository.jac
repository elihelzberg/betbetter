"""Graph snapshots. Empty stores use fixtures; ingestion is a private operation."""
import from models { GameSnapshot }
import from analysis { validate_snapshot }
import from adapters.michigan { demo_snapshots }
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
    records = [root.shared-->][?:StoredSnapshot];
    if not records { return demo_snapshots(); }
    return [record.snapshot for record in records];
}

def latest_snapshots() -> list[GameSnapshot] {
    latest: dict[str, GameSnapshot] = {};
    for snapshot in all_snapshots() {
        key = snapshot.state + ":" + snapshot.game_id;
        if key not in latest or datetime.fromisoformat(snapshot.observed_at) > datetime.fromisoformat(latest[key].observed_at) {
            latest[key] = snapshot;
        }
    }
    return list(latest.values());
}
