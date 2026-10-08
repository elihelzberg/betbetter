"""Official live snapshots; fictional fixtures are for isolated tests only."""
import from models { GameSnapshot, PrizeTier }

import from michigan_live { estimated_snapshots }

def fetch_live(history: bool = False) -> list[GameSnapshot] {
    rows = estimated_snapshots(history=history);
    snapshots: list[GameSnapshot] = [];
    for row in rows {
        prizes = [PrizeTier(amount=p["amount"], original=p["original"], remaining=p["remaining"]) for p in row["prizes"]];
        snapshots.append(GameSnapshot(game_id=row["game_id"], name=row["name"], state="MI",
            ticket_price=row["ticket_price"], prizes=prizes, original_tickets=row["original_tickets"], remaining_tickets=row["remaining_tickets"],
            observed_at=row["observed_at"], launch_date=row["launch_date"], advertised_odds=row["advertised_odds"],
            inventory_method="estimate", inventory_note=row["inventory_note"], source_url=row["source_url"], is_demo=False,
            source_updated_at=row["source_updated_at"]));
    }
    return snapshots;
}

def demo_snapshots() -> list[GameSnapshot] {
    snapshots: list[GameSnapshot] = [];
    names = ["Great Lakes Gold", "Motor City Millions", "Northern Lights", "Copper Country Cash", "Mitten Money", "Lakeside Fortune"];
    prices = [10.0, 20.0, 5.0, 10.0, 2.0, 30.0];
    inventories = [420000, 550000, 680000, 600000, 750000, 500000];
    for i in range(len(names)) {
        price = prices[i];
        for historical in [True, False] {
            fraction = 0.8 if historical else 0.5;
            inventory: int | None = 800000 if historical else inventories[i];
            if i == 3 { inventory = None; }
            snapshots.append(GameSnapshot(
                game_id=f"DEMO-MI-{i + 1:03d}", name=names[i], state="MI",
                ticket_price=price, original_tickets=1000000, remaining_tickets=inventory,
                prizes=[
                    PrizeTier(amount=price, original=200000, remaining=int(200000 * fraction)),
                    PrizeTier(amount=price * 2, original=50000, remaining=int(50000 * fraction)),
                    PrizeTier(amount=price * 10, original=10000, remaining=int(10000 * fraction)),
                    PrizeTier(amount=price * 100000, original=4, remaining=3 if historical else (0 if i == 4 else 2))
                ],
                observed_at="2026-09-22T12:00:00+00:00" if historical else "2026-09-29T12:00:00+00:00",
                launch_date="2026-01-01", advertised_odds=3.846,
                inventory_method="unknown" if inventory is None else "demo assumption",
                source_url="", is_demo=True
            ));
        }
    }
    return snapshots;
}
