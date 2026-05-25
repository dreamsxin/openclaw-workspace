#!/usr/bin/env python3
"""Export a Godot-friendly index for hero battle prefab/audio resources."""

from __future__ import annotations

import csv
import json
import re
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HERO_MAP_PATH = ROOT / "standalone/godot-mvp/data/hero_resource_map.json"
PHYSICAL_MAP_PATH = ROOT / "reverse-output/assets/yoo-physical-map/physical-asset-map.csv"
SPINE_ASSET_DIR = ROOT / "standalone/godot-mvp/assets/spine"
OUTPUT_PATH = ROOT / "standalone/godot-mvp/assets/battle/hero_battle_resources.json"


def load_physical_rows() -> list[dict[str, str]]:
    with PHYSICAL_MAP_PATH.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def first_token(value: str) -> str:
    return str(value or "").split("|")[0].strip()


def natural_key(text: str):
    return [int(part) if part.isdigit() else part.lower() for part in re.split(r"(\d+)", text)]


def row_payload(row: dict[str, str]) -> dict[str, object]:
    address = row.get("address", "")
    return {
        "name": Path(address).name,
        "address": address,
        "bundleName": row.get("bundleName", ""),
        "hashFileName": row.get("hashFileName", ""),
        "physicalPath": row.get("physicalPath", ""),
        "physicalExists": str(row.get("physicalExists", "")).lower() == "true",
        "fileSize": int(row.get("fileSize", "0") or 0),
    }


def clips_for_spine(spine_key: str) -> list[str]:
    baked_path = SPINE_ASSET_DIR / spine_key / f"{spine_key}.baked.json"
    if not baked_path.exists():
        return []
    try:
        data = load_json(baked_path)
    except (OSError, json.JSONDecodeError):
        return []
    clips = data.get("clips", {})
    if not isinstance(clips, dict):
        return []
    return sorted(
        [
            str(name)
            for name, clip in clips.items()
            if isinstance(clip, dict) and len(clip.get("frames", [])) > 0
        ],
        key=natural_key,
    )


def collect_rows_for(hero_key: str, rows: list[dict[str, str]]) -> dict[str, list[dict[str, object]]]:
    match = re.search(r"hero_(\d+)", hero_key)
    if match is None:
        return {"prefabs3d": [], "skillPrefabs": [], "sounds": []}

    number = match.group(1)
    q_key = f"hero_{number}q"
    lower_prefixes = {
        "prefabs3d": f"assets/game/rawassets/prefabs/3d/{q_key}_",
        "sounds": f"assets/game/rawassets/sound/battle/{q_key}_",
    }
    skill_prefix = f"assets/game/rawassets/prefabs/skill/hero_{number}q"
    collected: dict[str, list[dict[str, object]]] = {"prefabs3d": [], "skillPrefabs": [], "sounds": []}

    for row in rows:
        address = row.get("address", "")
        lower_address = address.lower()
        if lower_address.startswith(lower_prefixes["prefabs3d"]) and lower_address.endswith(".prefab"):
            collected["prefabs3d"].append(row_payload(row))
        elif lower_address.startswith(skill_prefix) and lower_address.endswith(".prefab"):
            collected["skillPrefabs"].append(row_payload(row))
        elif lower_address.startswith(lower_prefixes["sounds"]) and lower_address.endswith(".wav"):
            collected["sounds"].append(row_payload(row))

    for group in collected.values():
        group.sort(key=lambda item: natural_key(str(item.get("address", ""))))
    return collected


def build_index() -> dict[str, object]:
    heroes = load_json(HERO_MAP_PATH)
    physical_rows = load_physical_rows()
    entries: list[dict[str, object]] = []

    for hero in heroes:
        spine_key = first_token(hero.get("spine", ""))
        match = re.search(r"hero_(\d+)", spine_key)
        if not spine_key or match is None:
            continue
        resources = collect_rows_for(spine_key, physical_rows)
        if not any(resources.values()):
            continue
        baked_res_path = f"res://assets/spine/{spine_key}/{spine_key}.baked.json"
        baked_disk_path = ROOT / "standalone/godot-mvp" / baked_res_path.replace("res://", "")
        clips = clips_for_spine(spine_key)
        entries.append(
            {
                "heroId": int(hero.get("heroId", 0) or 0),
                "name": hero.get("nameText", "") or hero.get("jNameText", "") or spine_key,
                "rare": int(hero.get("rare", 0) or 0),
                "spine": spine_key,
                "qKey": f"hero_{match.group(1)}q",
                "galSpine": first_token(hero.get("galSpine", "")),
                "baked": baked_res_path,
                "bakedExists": baked_disk_path.exists(),
                "clips": clips,
                "prefabs3d": resources["prefabs3d"],
                "skillPrefabs": resources["skillPrefabs"],
                "sounds": resources["sounds"],
            }
        )

    entries.sort(key=lambda item: (str(item.get("spine", "")), int(item.get("heroId", 0))))
    return {
        "schema": "shaonv-hero-battle-preview-v1",
        "generatedAt": date.today().isoformat(),
        "source": {
            "heroMap": str(HERO_MAP_PATH.relative_to(ROOT)).replace("\\", "/"),
            "physicalMap": str(PHYSICAL_MAP_PATH.relative_to(ROOT)).replace("\\", "/"),
        },
        "summary": {
            "heroes": len(entries),
            "prefabs3d": sum(len(hero["prefabs3d"]) for hero in entries),
            "skillPrefabs": sum(len(hero["skillPrefabs"]) for hero in entries),
            "sounds": sum(len(hero["sounds"]) for hero in entries),
            "withBakedPreview": sum(1 for hero in entries if hero["bakedExists"]),
        },
        "heroes": entries,
    }


def main() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    index = build_index()
    with OUTPUT_PATH.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(index, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    summary = index["summary"]
    print(
        "Exported {heroes} heroes, {prefabs3d} 3d prefabs, {skillPrefabs} skill prefabs, "
        "{sounds} sounds, {withBakedPreview} baked previews -> {path}".format(
            path=OUTPUT_PATH.relative_to(ROOT),
            **summary,
        )
    )


if __name__ == "__main__":
    main()
