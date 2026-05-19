#!/usr/bin/env python3
"""Export all hero RoleLh Spine runtimes from Prefab/HerolhPrefab/<id>."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from export_cocos_prefab_layout import ROOT, export_layout, rel
from export_spine_runtime_data import export as export_spine


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--inventory", default=str(ROOT / "data" / "hero_resource_inventory.json"))
    parser.add_argument("--out-dir", default=str(ROOT / "data" / "spine_runtime"))
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--include-variants", action="store_true", default=True)
    parser.add_argument("--limit", type=int, default=0)
    return parser.parse_args()


def all_lh_prefab_ids() -> set[str]:
    config = json.loads((ROOT / "assets" / "resources" / "config.json").read_text(encoding="utf-8"))
    result: set[str] = set()
    for item in config.get("paths", {}).values():
        if not item:
            continue
        path = str(item[0])
        if path.startswith("Prefab/HerolhPrefab/"):
            item_id = path.rsplit("/", 1)[-1]
            if item_id.isdigit():
                result.add(item_id)
    return result


def main() -> int:
    args = parse_args()
    inventory_path = Path(args.inventory)
    out_dir = Path(args.out_dir)
    inventory = json.loads(inventory_path.read_text(encoding="utf-8"))
    hero_ids = {str(item["id"]) for item in inventory.get("heroes", []) if item.get("has_lh_prefab")}
    if args.include_variants:
        hero_ids.update(all_lh_prefab_ids())
    heroes = [{"id": item_id} for item_id in sorted(hero_ids, key=lambda x: (len(x), x))]
    if args.limit > 0:
        heroes = heroes[: args.limit]

    index: dict[str, dict] = {}
    errors: list[dict] = []
    for hero in heroes:
        hero_id = str(hero["id"])
        prefab_path = f"Prefab/HerolhPrefab/{hero_id}"
        out_path = out_dir / f"{hero_id}.json"
        try:
            layout = export_layout(prefab_path)
            skeleton_nodes = [node for node in layout.get("nodes", []) if node.get("skeleton_uuid")]
            if not skeleton_nodes:
                errors.append({"id": hero_id, "prefab": prefab_path, "error": "no skeleton node"})
                continue
            node = skeleton_nodes[0]
            skeleton_uuid = str(node["skeleton_uuid"])
            if args.force or not out_path.exists():
                export_spine(skeleton_uuid, out_path)
            runtime = json.loads(out_path.read_text(encoding="utf-8"))
            animation_names = sorted((runtime.get("skeleton", {}).get("animations", {}) or {}).keys())
            index[hero_id] = {
                "id": hero_id,
                "prefab": prefab_path,
                "runtime": "res://" + rel(out_path),
                "skeleton_uuid": skeleton_uuid,
                "skeleton_name": runtime.get("name", node.get("skeleton_name", "")),
                "animations": animation_names,
                "texture_paths": runtime.get("texture_paths", []),
                "node": {
                    "name": node.get("name", ""),
                    "position": node.get("position", []),
                    "global_position": node.get("global_position", []),
                    "scale": node.get("scale", []),
                    "size": node.get("size", []),
                },
            }
        except Exception as exc:  # noqa: BLE001 - batch exporter should report and continue.
            errors.append({"id": hero_id, "prefab": prefab_path, "error": repr(exc)})

    payload = {
        "source": str(inventory_path),
        "count": len(index),
        "error_count": len(errors),
        "heroes": index,
        "errors": errors,
    }
    out_index = ROOT / "data" / "hero_spine_runtime_index.json"
    out_index.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"exported={len(index)} errors={len(errors)} index={out_index}")
    if errors:
        for item in errors[:20]:
            print(f"ERROR {item['id']}: {item['error']}")
    return 1 if args.strict and errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
