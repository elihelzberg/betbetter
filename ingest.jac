"""Private ingestion CLI. Never expose source ingestion as an anonymous endpoint."""
import argparse;
import from adapters.michigan { demo_snapshots, fetch_live }
import from analysis { validate_snapshot }
import from repository { save_snapshot }

with entry:__main__ {
    parser = argparse.ArgumentParser(description="Validate and store Michigan snapshots.");
    parser.add_argument("--source", choices=["demo", "live"], `default="demo");
    parser.add_argument("--dry-run", action="store_true");
    args = parser.parse_args();
    snapshots = demo_snapshots() if args.source == "demo" else fetch_live();
    # Validate the full batch before writing anything.
    for snapshot in snapshots { validate_snapshot(snapshot); }
    if args.dry_run { print(f"Validated {len(snapshots)} snapshots; no data written."); }
    else {
        inserted = 0;
        for snapshot in snapshots {
            if save_snapshot(snapshot) { inserted += 1; }
        }
        print(f"Inserted {inserted} snapshots; duplicate observation keys skipped.");
    }
}
