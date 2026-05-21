#!/usr/bin/env python3
import json
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BLOCKS_JSON = ROOT / "godot-project/data/blocks.json"
SPRITE_SOURCE = ROOT / "reverse-output/assets/assetstudio-cli-data-sprite"
SPRITE_TARGET = ROOT / "godot-project/assets/sprites"
MANIFEST = ROOT / "reverse-output/assets/derived/godot_block_sprite_import_manifest.json"


def collect_sprite_keys() -> list[str]:
    data = json.loads(BLOCKS_JSON.read_text(encoding="utf-8"))
    keys = {
        block.get("sprite_key", "")
        for chain in data.get("chains", {}).values()
        for block in chain
    }
    return sorted(key for key in keys if key)


def build_source_index() -> dict[str, Path]:
    index: dict[str, Path] = {}
    for path in SPRITE_SOURCE.rglob("*.png"):
        key = path.stem.lower()
        current = index.get(key)
        if current is None or len(path.parts) < len(current.parts):
            index[key] = path
    return index


def main() -> None:
    keys = collect_sprite_keys()
    index = build_source_index()
    SPRITE_TARGET.mkdir(parents=True, exist_ok=True)

    copied = []
    missing = []
    for key in keys:
        source = index.get(key.lower())
        if source is None:
            missing.append(key)
            continue
        target = SPRITE_TARGET / f"{key}.png"
        shutil.copy2(source, target)
        copied.append(
            {
                "sprite_key": key,
                "source": str(source.relative_to(ROOT)),
                "target": str(target.relative_to(ROOT)),
            }
        )

    manifest = {
        "source_root": str(SPRITE_SOURCE.relative_to(ROOT)),
        "target_root": str(SPRITE_TARGET.relative_to(ROOT)),
        "requested": len(keys),
        "copied": len(copied),
        "missing": missing,
        "files": copied,
    }
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"requested={len(keys)}")
    print(f"copied={len(copied)}")
    print(f"missing={len(missing)}")
    print(MANIFEST)


if __name__ == "__main__":
    main()
