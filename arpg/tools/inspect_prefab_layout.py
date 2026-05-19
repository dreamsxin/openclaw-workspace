#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")


def load_manifest() -> list[dict]:
    return json.loads((ROOT / "data" / "prefab_layouts.json").read_text(encoding="utf-8"))


def resolve_layout(target: str) -> Path:
    path = Path(target)
    if path.exists():
        return path
    manifest = load_manifest()
    for item in manifest:
        if target in {str(item.get("label", "")), str(item.get("prefab", "")), Path(str(item.get("layout", ""))).stem}:
            return ROOT / str(item["layout"])
    raise SystemExit(f"layout not found: {target}")


def fmt_vec(value: object) -> str:
    if isinstance(value, list) and len(value) >= 2:
        return f"({float(value[0]):.1f},{float(value[1]):.1f})"
    return ""


def print_nodes(layout: dict, limit: int) -> None:
    nodes = [
        node for node in layout.get("nodes", [])
        if node.get("texture_path") or node.get("label_text") or "cc.Mask" in node.get("component_types", []) or "cc.ScrollView" in node.get("component_types", [])
    ]
    print(f"nodes with texture/label/mask/scroll: {len(nodes)}")
    for node in nodes[:limit]:
        tags = []
        if node.get("texture_path"):
            tags.append(Path(str(node["texture_path"])).name)
        if node.get("sprite_name"):
            tags.append(str(node["sprite_name"]))
        if node.get("label_text"):
            tags.append(f"text={node['label_text']}")
        comps = [c for c in node.get("component_types", []) if c in {"cc.Mask", "cc.ScrollView", "cc.ProgressBar", "cc.Toggle", "cc.Button", "cc.Label"}]
        if comps:
            tags.append(",".join(comps))
        print(f"  #{node.get('index'):>3} {node.get('name',''):<24} pos={fmt_vec(node.get('global_position')):<14} size={fmt_vec(node.get('size')):<14} {' | '.join(tags)}")


def print_bindings(layout: dict, limit: int) -> None:
    bindings = layout.get("component_bindings", [])
    print(f"component bindings: {len(bindings)}")
    for binding in bindings[:limit]:
        fields = binding.get("fields", {})
        unresolved = binding.get("unresolved_fields", {})
        print(f"  owner #{binding.get('owner_index')} {binding.get('owner_name')} component={binding.get('component')}")
        if fields:
            field_text = ", ".join(f"{name}->{value.get('name')}#{value.get('index')}" for name, value in fields.items())
            print(f"    fields: {field_text}")
        if unresolved:
            names = ", ".join(list(unresolved.keys())[:12])
            print(f"    unresolved: {names}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect exported Cocos prefab layout JSON.")
    parser.add_argument("layout", help="manifest label, prefab path, layout stem, or JSON file path")
    parser.add_argument("--limit", type=int, default=80)
    args = parser.parse_args()

    layout_path = resolve_layout(args.layout)
    layout = json.loads(layout_path.read_text(encoding="utf-8"))
    print(f"layout: {layout_path}")
    print(f"prefab: {layout.get('prefab')}")
    print(f"import: {layout.get('import')}")
    print(f"nodes: {len(layout.get('nodes', []))}")
    print_nodes(layout, args.limit)
    print_bindings(layout, args.limit)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
