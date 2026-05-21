#!/usr/bin/env python3
import csv
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "reverse-output/assets/assetstudio-cli-inventory.csv"
OUT_CSV = ROOT / "reverse-output/assets/derived/character_asset_inventory.csv"
OUT_JSON = ROOT / "reverse-output/assets/derived/character_asset_summary.json"

PATTERNS = [
    ("maid_base", re.compile(r"^Ch_Maid(?P<id>\d+)_")),
    ("maid_costume", re.compile(r"^Cos_Maid(?P<id>\d+)_")),
    ("customer", re.compile(r"^Ch_Customer(?P<id>\d+)_")),
    ("maid_chat", re.compile(r"MaidChat|MaidAIChat|Chat")),
    ("character_ui", re.compile(r"Npc|NPC|Maid|Customer|Character|Profile|Episode|Skin|Costume")),
]


def classify(name: str) -> tuple[str, str]:
    for category, pattern in PATTERNS:
        match = pattern.search(name)
        if match:
            return category, match.groupdict().get("id", "")
    return "", ""


def main() -> None:
    rows: list[dict] = []
    summary: dict[str, dict] = {}
    with SOURCE.open(encoding="utf-8", newline="") as fh:
        reader = csv.DictReader(fh, fieldnames=["asset_type", "name", "extension", "size", "path"])
        for row in reader:
            category, character_id = classify(row["name"])
            if not category:
                continue
            output = {
                "category": category,
                "character_id": character_id,
                "asset_type": row["asset_type"],
                "name": row["name"],
                "extension": row["extension"],
                "size": row["size"],
                "path": row["path"],
            }
            rows.append(output)
            bucket = summary.setdefault(category, {"asset_count": 0, "character_ids": set(), "samples": []})
            bucket["asset_count"] += 1
            if character_id:
                bucket["character_ids"].add(int(character_id))
            if len(bucket["samples"]) < 20:
                bucket["samples"].append(row["name"])

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.DictWriter(
            fh,
            fieldnames=["category", "character_id", "asset_type", "name", "extension", "size", "path"],
        )
        writer.writeheader()
        writer.writerows(rows)

    json_summary = {
        category: {
            "asset_count": data["asset_count"],
            "character_ids": sorted(data["character_ids"]),
            "unique_character_count": len(data["character_ids"]),
            "samples": data["samples"],
        }
        for category, data in sorted(summary.items())
    }
    OUT_JSON.write_text(json.dumps(json_summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"rows={len(rows)}")
    for category, data in json_summary.items():
        print(f"{category}: assets={data['asset_count']} ids={data['character_ids']}")
    print(OUT_CSV)
    print(OUT_JSON)


if __name__ == "__main__":
    main()
