#!/usr/bin/env python3
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "reverse-output/assets/derived/table_block_catalog.json"
OUTPUT = ROOT / "godot-project/data/blocks.json"
SPRITE_DIR = ROOT / "godot-project/assets/sprites"


def sprite_path(sprite_key: str) -> str:
    candidate = SPRITE_DIR / f"{sprite_key}.png"
    if candidate.exists():
        return f"res://assets/sprites/{sprite_key}.png"
    return "res://assets/sprites/Block_Unknown.png"


def main() -> None:
    rows = json.loads(SOURCE.read_text(encoding="utf-8"))
    grouped: dict[str, list[dict]] = {}
    for row in rows:
        if row["category_name"].startswith("Currency"):
            continue
        grouped.setdefault(row["group_name"], []).append(row)

    chains = {}
    for group_name, group_rows in sorted(grouped.items()):
        ordered = sorted(group_rows, key=lambda item: (int(item["level"]), int(item["id"])))
        chain = []
        for index, row in enumerate(ordered):
            block_id = str(row["id"])
            next_id = str(ordered[index + 1]["id"]) if index + 1 < len(ordered) else ""
            chain.append(
                {
                    "id": block_id,
                    "level": int(row["level"]),
                    "name": row["block_name"],
                    "sprite": sprite_path(row["block_image"]),
                    "sprite_key": row["block_image"],
                    "category": row["category_name"],
                    "sub_category": row["sub_category_name"],
                    "block_type": int(row["block_type"]),
                    "produce_energy": int(row.get("produce_energy", 0)),
                    "cool_time": int(row.get("cool_time", 0)),
                    "parent_block_id": int(row.get("parent_block_id", 0)),
                    "produce_reward_type": int(row.get("produce_reward_type", 0)),
                    "produce_reward_id": int(row.get("produce_reward_id", 0)),
                    "produce_reward_value": int(row.get("produce_reward_value", 0)),
                    "next": next_id,
                }
            )
        chains[group_name] = chain

    payload = {
        "source": "reverse-output/assets/assetstudio-cli-data-monobehaviour-raw/MonoBehaviour/Table_Block.dat",
        "note": "Generated from recovered Table_Block main fields and decoded BlockTableData primitive tail.",
        "chains": chains,
    }
    OUTPUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"chains={len(chains)}")
    print(f"blocks={sum(len(chain) for chain in chains.values())}")
    print(OUTPUT)


if __name__ == "__main__":
    main()
