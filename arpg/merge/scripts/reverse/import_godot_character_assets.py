#!/usr/bin/env python3
import csv
import json
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "reverse-output/assets/derived/character_asset_inventory.csv"
TARGET_ROOT = ROOT / "godot-project/assets/characters"
MANIFEST = ROOT / "reverse-output/assets/derived/godot_character_asset_import_manifest.json"

INCLUDED_CATEGORIES = {
    "maid_base",
    "maid_costume",
    "customer",
    "maid_chat",
}


def safe_name(name: str, extension: str) -> str:
    ext = extension if extension.startswith(".") else f".{extension}"
    return f"{name}{ext}"


def main() -> None:
    copied: list[dict] = []
    missing: list[dict] = []
    TARGET_ROOT.mkdir(parents=True, exist_ok=True)

    with SOURCE.open(encoding="utf-8", newline="") as fh:
        for row in csv.DictReader(fh):
            category = row["category"]
            if category not in INCLUDED_CATEGORIES:
                continue
            source = ROOT / row["path"]
            if not source.exists():
                missing.append(row)
                continue
            target_dir = TARGET_ROOT / category
            target_dir.mkdir(parents=True, exist_ok=True)
            target = target_dir / safe_name(row["name"], row["extension"])
            shutil.copy2(source, target)
            copied.append(
                {
                    "category": category,
                    "character_id": row["character_id"],
                    "asset_type": row["asset_type"],
                    "name": row["name"],
                    "source": str(source.relative_to(ROOT)),
                    "target": str(target.relative_to(ROOT)),
                }
            )

    manifest = {
        "source": str(SOURCE.relative_to(ROOT)),
        "target_root": str(TARGET_ROOT.relative_to(ROOT)),
        "included_categories": sorted(INCLUDED_CATEGORIES),
        "copied": len(copied),
        "missing": len(missing),
        "files": copied,
        "missing_files": missing,
    }
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"copied={len(copied)}")
    print(f"missing={len(missing)}")
    print(TARGET_ROOT)
    print(MANIFEST)


if __name__ == "__main__":
    main()
