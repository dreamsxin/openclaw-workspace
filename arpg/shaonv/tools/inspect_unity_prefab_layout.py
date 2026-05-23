#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Inspect Unity UGUI prefab layout data from YooAsset bundles.

The shaonv bundles obfuscate the first bytes with XOR.  This tool resolves a
prefab address through the physical map, decodes the bundle header, rebuilds the
GameObject/RectTransform hierarchy, and writes compact JSON/Markdown summaries.
It is meant to turn prefab layout analysis into a repeatable step before
recreating screens in Godot.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any

import UnityPy


DEFAULT_PREFABS = [
    "Assets/Game/RawAssets/Prefabs/UI/Launch/LaunchView.prefab",
    "Assets/Game/RawAssets/Prefabs/UI/Login/LoginView.prefab",
    "Assets/Game/RawAssets/Prefabs/UI/Login/LoadingView.prefab",
    "Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab",
    "Assets/Game/RawAssets/Prefabs/UI/Common/TopResGrid.prefab",
]


def safe_name(value: str) -> str:
    name = re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", value).strip(" .")
    return name or "prefab"


def pptr_id(value: Any) -> int:
    return int(getattr(value, "path_id", getattr(value, "m_PathID", 0)) or 0)


def vec2(value: Any) -> list[float]:
    if value is None:
        return [0.0, 0.0]
    return [float(getattr(value, "x", 0.0)), float(getattr(value, "y", 0.0))]


def vec3(value: Any) -> list[float]:
    if value is None:
        return [0.0, 0.0, 0.0]
    return [float(getattr(value, "x", 0.0)), float(getattr(value, "y", 0.0)), float(getattr(value, "z", 0.0))]


def load_source(path: Path, xor_prefix: int, xor_key: int):
    data = bytearray(path.read_bytes())
    for index in range(min(xor_prefix, len(data))):
        data[index] ^= xor_key
    return UnityPy.load(bytes(data))


def read_physical_map(path: Path) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            address = row.get("address", "")
            if address:
                rows[address.lower()] = row
    return rows


def object_name(obj: Any, data: Any) -> str:
    return str(getattr(data, "m_Name", "") or getattr(data, "name", "") or f"{obj.type.name}_{obj.path_id}")


def component_type_by_path(env: Any) -> dict[int, str]:
    return {int(obj.path_id): obj.type.name for obj in env.objects}


def inspect_prefab(address: str, source: Path, xor_prefix: int, xor_key: int) -> dict[str, Any]:
    env = load_source(source, xor_prefix, xor_key)
    type_counts = Counter(obj.type.name for obj in env.objects)
    component_types = component_type_by_path(env)
    gameobjects: dict[int, dict[str, Any]] = {}
    rects_by_go: dict[int, dict[str, Any]] = {}
    rects_by_path: dict[int, dict[str, Any]] = {}

    for obj in env.objects:
        if obj.type.name != "GameObject":
            continue
        data = obj.read()
        components = []
        for pair in getattr(data, "m_Component", []):
            comp = getattr(pair, "component", None)
            comp_id = pptr_id(comp)
            if comp_id:
                components.append({"pathId": comp_id, "type": component_types.get(comp_id, "Unknown")})
        gameobjects[int(obj.path_id)] = {
            "pathId": int(obj.path_id),
            "name": object_name(obj, data),
            "active": bool(getattr(data, "m_IsActive", True)),
            "layer": int(getattr(data, "m_Layer", 0)),
            "components": components,
        }

    for obj in env.objects:
        if obj.type.name != "RectTransform":
            continue
        data = obj.read()
        go_id = pptr_id(getattr(data, "m_GameObject", None))
        rect = {
            "rectPathId": int(obj.path_id),
            "gameObjectPathId": go_id,
            "fatherRectPathId": pptr_id(getattr(data, "m_Father", None)),
            "childrenRectPathIds": [pptr_id(child) for child in getattr(data, "m_Children", []) if pptr_id(child)],
            "anchorMin": vec2(getattr(data, "m_AnchorMin", None)),
            "anchorMax": vec2(getattr(data, "m_AnchorMax", None)),
            "pivot": vec2(getattr(data, "m_Pivot", None)),
            "sizeDelta": vec2(getattr(data, "m_SizeDelta", None)),
            "anchoredPosition": vec2(getattr(data, "m_AnchoredPosition", None)),
            "localPosition": vec3(getattr(data, "m_LocalPosition", None)),
            "localScale": vec3(getattr(data, "m_LocalScale", None)),
        }
        rects_by_path[int(obj.path_id)] = rect
        if go_id:
            rects_by_go[go_id] = rect

    nodes = []
    for go_id, go in gameobjects.items():
        rect = rects_by_go.get(go_id)
        parent_rect = rect.get("fatherRectPathId", 0) if rect else 0
        parent_go_id = rects_by_path.get(parent_rect, {}).get("gameObjectPathId", 0) if parent_rect else 0
        components = [component["type"] for component in go["components"]]
        node = {
            **go,
            "parentPathId": parent_go_id,
            "parentName": gameobjects.get(parent_go_id, {}).get("name", ""),
            "componentTypes": components,
            "rect": rect,
        }
        nodes.append(node)

    children_by_parent: dict[int, list[dict[str, Any]]] = {}
    for node in nodes:
        children_by_parent.setdefault(int(node.get("parentPathId", 0)), []).append(node)

    def sort_key(node: dict[str, Any]) -> tuple[int, str]:
        rect = node.get("rect") or {}
        parent_rect = int(rect.get("fatherRectPathId", 0) or 0)
        siblings = rects_by_path.get(parent_rect, {}).get("childrenRectPathIds", [])
        try:
            index = siblings.index(rect.get("rectPathId"))
        except ValueError:
            index = 9999
        return (index, node.get("name", ""))

    for bucket in children_by_parent.values():
        bucket.sort(key=sort_key)

    def build_tree(node: dict[str, Any], depth: int = 0) -> dict[str, Any]:
        return {
            "name": node["name"],
            "pathId": node["pathId"],
            "active": node["active"],
            "components": node["componentTypes"],
            "rect": node.get("rect"),
            "children": [build_tree(child, depth + 1) for child in children_by_parent.get(node["pathId"], [])],
        }

    roots = [node for node in nodes if int(node.get("parentPathId", 0)) not in gameobjects]
    roots.sort(key=sort_key)

    return {
        "address": address,
        "source": str(source),
        "typeCounts": dict(sorted(type_counts.items())),
        "nodeCount": len(nodes),
        "roots": [build_tree(root) for root in roots],
        "nodes": sorted(nodes, key=lambda node: (node.get("parentName", ""), node.get("name", ""))),
    }


def flatten_tree(root: dict[str, Any], max_depth: int, rows: list[str], depth: int = 0) -> None:
    if depth > max_depth:
        return
    rect = root.get("rect") or {}
    pos = rect.get("anchoredPosition", [0, 0])
    size = rect.get("sizeDelta", [0, 0])
    active = "" if root.get("active", True) else " inactive"
    rows.append("%s- %s%s pos=(%.1f, %.1f) size=(%.1f, %.1f)" % ("  " * depth, root["name"], active, pos[0], pos[1], size[0], size[1]))
    for child in root.get("children", []):
        flatten_tree(child, max_depth, rows, depth + 1)


def write_markdown(layouts: list[dict[str, Any]], path: Path, max_depth: int) -> None:
    lines = [
        "# Unity Prefab Layout Snapshot",
        "",
        "Generated from closed YooAsset prefab bundles. Coordinates are raw Unity RectTransform values and should be used as the first-pass source for Godot layout reconstruction.",
        "",
    ]
    for layout in layouts:
        lines.extend(
            [
                f"## {layout['address']}",
                "",
                f"- Source: `{layout['source']}`",
                f"- Nodes: {layout['nodeCount']}",
                f"- Types: `{json.dumps(layout['typeCounts'], ensure_ascii=False)}`",
                "",
                "```text",
            ]
        )
        rows: list[str] = []
        for root in layout["roots"]:
            flatten_tree(root, max_depth, rows)
        lines.extend(rows)
        lines.extend(["```", ""])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect Unity prefab RectTransform layouts.")
    parser.add_argument("prefabs", nargs="*", help="Prefab addresses. Defaults to startup/main MVP prefabs.")
    parser.add_argument("--repo-root", default=".", help="Repository root.")
    parser.add_argument("--physical-map", default="reverse-output/assets/yoo-physical-map/physical-asset-map.csv")
    parser.add_argument("--out", default="reverse-output/godot-layout-inspect", help="Output directory.")
    parser.add_argument("--markdown", default="", help="Optional Markdown summary path.")
    parser.add_argument("--markdown-depth", type=int, default=3, help="Tree depth for Markdown summary.")
    parser.add_argument("--xor-prefix", type=int, default=222)
    parser.add_argument("--xor-key", type=lambda value: int(value, 0), default=0x16)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    physical_map = read_physical_map(repo_root / args.physical_map)
    out_dir = (repo_root / args.out).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    prefabs = args.prefabs or DEFAULT_PREFABS
    layouts: list[dict[str, Any]] = []
    failures = 0

    for address in prefabs:
        row = physical_map.get(address.lower())
        if not row:
            print(f"missing map row: {address}")
            failures += 1
            continue
        source = (repo_root / row["physicalPath"]).resolve()
        try:
            layout = inspect_prefab(address, source, args.xor_prefix, args.xor_key)
        except Exception as exc:
            print(f"failed: {address}: {exc}")
            failures += 1
            continue
        layouts.append(layout)
        output = out_dir / f"{safe_name(Path(address).stem)}.layout.json"
        output.write_text(json.dumps(layout, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"wrote: {output.relative_to(repo_root)}")

    if args.markdown and layouts:
        markdown = (repo_root / args.markdown).resolve()
        write_markdown(layouts, markdown, args.markdown_depth)
        print(f"wrote: {markdown.relative_to(repo_root)}")

    print(f"prefabs inspected: {len(layouts)}, failures: {failures}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
