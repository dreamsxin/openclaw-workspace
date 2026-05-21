#!/usr/bin/env python3
import csv
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHILD_DIR = ROOT / "reverse-output/assets/derived/table_block_children"
OUTPUT = ROOT / "godot-project/data/block_rules.json"


def load_csv(name: str) -> list[dict]:
    path = CHILD_DIR / f"{name}.csv"
    if not path.exists():
        return []
    with path.open(encoding="utf-8", newline="") as fh:
        return list(csv.DictReader(fh))


def as_int(value: str) -> int:
    return int(value) if value not in ("", None) else 0


def main() -> None:
    drops_by_id: dict[str, list[dict]] = {}
    for row in load_csv("BlockDropTableData"):
        drops_by_id.setdefault(row["id"], []).append(
            {
                "block_id": row["block_id"],
                "ratio": as_int(row["ratio"]),
                "weight": as_int(row["weight"]),
            }
        )

    designed_by_id: dict[str, list[dict]] = {}
    for row in load_csv("BlockDesignedDropTableData"):
        designed_by_id.setdefault(row["id"], []).append(
            {
                "block_id": row["block_id"],
                "count_min": as_int(row["count_min"]),
                "count_max": as_int(row["count_max"]),
            }
        )

    produce_by_block: dict[str, dict] = {}
    for row in load_csv("BlockProduceTableData"):
        block_id = row["id"]
        drop_id = row["drop_id"]
        designed_drop_id = row["designed_drop_id"]
        produce_by_block[block_id] = {
            "drop_id": drop_id,
            "designed_drop_id": designed_drop_id,
            "drops": drops_by_id.get(drop_id, []),
            "designed_drops": designed_by_id.get(designed_drop_id, []),
        }

    cooldown_by_group: dict[str, list[dict]] = {}
    for row in load_csv("BlockCoolTimeTableData"):
        cooldown_by_group.setdefault(row["group_name"], []).append(
            {
                "currency_type": as_int(row["currency_type"]),
                "min_value": as_int(row["min_value"]),
                "cool_time_during": as_int(row["cool_time_during"]),
                "cool_time_during_value": as_int(row["cool_time_during_value"]),
            }
        )

    merge_drop_rates: dict[str, list[dict]] = {}
    for row in load_csv("BlockMergeDropRateTableData"):
        merge_drop_rates.setdefault(row["block_id"], []).append(
            {
                "pool_group_id": row["pool_group_id"],
                "rate": as_int(row["rate"]),
            }
        )

    merge_drop_pools: dict[str, list[dict]] = {}
    for row in load_csv("BlockMergeDropPoolTableData"):
        merge_drop_pools.setdefault(row["pool_group_id"], []).append(
            {
                "drop_block_id": row["drop_block_id"],
                "map_cell_type": as_int(row["map_cell_type"]),
            }
        )

    payload = {
        "source": "reverse-output/assets/derived/table_block_children/*.csv",
        "produce_by_block": produce_by_block,
        "cooldown_by_group": cooldown_by_group,
        "merge_drop_rates": merge_drop_rates,
        "merge_drop_pools": merge_drop_pools,
    }
    OUTPUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"produce_blocks={len(produce_by_block)}")
    print(f"cooldown_groups={len(cooldown_by_group)}")
    print(f"merge_drop_rate_blocks={len(merge_drop_rates)}")
    print(OUTPUT)


if __name__ == "__main__":
    main()
