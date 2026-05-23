#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Batch extract and analyze ALL physically available UI prefabs.
Auto-generates one markdown doc per prefab in docs/prefabs/
"""

import csv
import json
import os
import re
import subprocess
from pathlib import Path
from collections import defaultdict

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PHYSICAL_MAP = PROJECT_ROOT / "reverse-output" / "assets" / "yoo-physical-map" / "physical-asset-map.csv"
INSPECT_SCRIPT = PROJECT_ROOT / "scripts" / "assets" / "inspect_unity_prefab_layout.py"
LAYOUT_DIR = PROJECT_ROOT / "reverse-output" / "godot-layout-inspect"
DOCS_DIR = PROJECT_ROOT / "docs" / "prefabs"

def read_available_prefabs():
    """Read physical-asset-map.csv and return list of available prefab paths."""
    prefabs = []
    with open(PHYSICAL_MAP, "r", encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            address = row.get("address", "")
            physical_path = row.get("physicalPath", "")
            physical_exists = row.get("physicalExists", "False")
            if not address or not physical_path or physical_exists != "True":
                continue
            if not address.endswith(".prefab"):
                continue
            if not address.startswith("Assets/Game/RawAssets/Prefabs/UI/"):
                continue
            prefabs.append({
                "address": address,
                "physicalPath": physical_path,
                "bundleSize": int(row.get("fileSize", 0)),
            })
    return prefabs

def categorize_prefab(address: str) -> str:
    """Extract category from prefab path.
    Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab -> LotteryDraw
    """
    prefix = "Assets/Game/RawAssets/Prefabs/UI/"
    rel = address[len(prefix):]
    parts = rel.replace("\\", "/").split("/")
    if len(parts) >= 2:
        return parts[0]  # e.g., LotteryDraw, Login, MainUI
    return "Root"

def classify_prefab(address: str) -> str:
    """Classify prefab as View, Grid, Item, or Other."""
    basename = Path(address).stem
    if any(x in basename for x in ["Panel", "View", "MainView", "MainUI", "Popup"]):
        return "View"
    if any(x in basename for x in ["Grid", "Item", "Card", "Cell"]):
        return "Grid"
    if any(x in basename for x in ["Icon", "Tab", "Tag", "Dot", "Button"]):
        return "Component"
    return "Other"

def extract_prefab(address: str) -> Path | None:
    """Extract a single prefab layout using inspect_unity_prefab_layout.py."""
    safe_name = re.sub(r"[<>:\"/\\|?*\s]", "_", address.split("/")[-1].replace(".prefab", ""))
    out_json = LAYOUT_DIR / f"{safe_name}.json"

    if out_json.exists():
        return out_json

    cmd = [
        "python",
        str(INSPECT_SCRIPT),
        address,
        "--repo-root", str(PROJECT_ROOT),
        "--output-json", str(out_json),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))
    if result.returncode != 0:
        print(f"  ERROR extracting {address}: {result.stderr[:200]}")
        return None
    return out_json

def analyze_layout(json_path: Path) -> dict:
    """Analyze a layout JSON and return structured summary."""
    with open(json_path) as f:
        data = json.load(f)

    nodes = {}
    def walk(n, depth=0):
        r = n.get("rect", {})
        nodes[n["name"]] = {
            "name": n["name"],
            "depth": depth,
            "active": n.get("active", True),
            "size": r.get("sizeDelta", [0, 0]) if r else None,
            "pos": r.get("anchoredPosition", [0, 0]) if r else None,
            "anc_min": r.get("anchorMin", [0, 0]) if r else None,
            "anc_max": r.get("anchorMax", [1, 1]) if r else None,
            "components": [c for c in n.get("components", []) if c not in ("RectTransform", "CanvasRenderer")],
        }
        for c in n.get("children", []):
            walk(c, depth + 1)
    for r in data.get("roots", []):
        walk(r)

    return {
        "address": data.get("address", ""),
        "nodeCount": data.get("nodeCount", 0),
        "typeCounts": data.get("typeCounts", {}),
        "nodes": nodes,
    }

def generate_doc(address: str, analysis: dict, category: str) -> str:
    """Generate markdown document for a prefab."""
    basename = Path(address).stem
    node_count = analysis["nodeCount"]
    type_counts = analysis["typeCounts"]
    nodes = analysis["nodes"]

    lines = []
    lines.append(f"# {basename} Prefab 布局分析")
    lines.append("")
    lines.append(f"自动生成 · {category} 分类 · {node_count} 节点")
    lines.append("")
    lines.append("## 基本信息")
    lines.append("")
    lines.append(f"| 字段 | 值 |")
    lines.append(f"|------|-----|")
    lines.append(f"| Asset 路径 | `{address}` |")
    lines.append(f"| 节点数 | {node_count} |")
    comps = ", ".join(f"{k} x {v}" for k, v in sorted(type_counts.items(), key=lambda x: -x[1]))
    lines.append(f"| 组件 | {comps} |")
    lines.append("")

    # View nodes (top-level panels)
    view_nodes = {k: v for k, v in nodes.items() if v["depth"] <= 1}
    other_nodes = {k: v for k, v in nodes.items() if v["depth"] > 1 and v["depth"] <= 2}

    if view_nodes:
        lines.append("## 顶层结构")
        lines.append("")
        lines.append("| 节点 | 尺寸 | active | 组件 |")
        lines.append("|------|------|--------|------|")
        for name in sorted(view_nodes.keys(), key=lambda n: nodes[n].get("depth", 0)):
            n = nodes[name]
            sz = n["size"] or [0, 0]
            comp_str = ", ".join(n.get("components", [])[:3]) or "-"
            lines.append(f"| {name} | ({sz[0]:.0f}, {sz[1]:.0f}) | {n['active']} | {comp_str} |")
        lines.append("")

    if other_nodes:
        lines.append("## 二级子节点")
        lines.append("")
        lines.append("| 节点 | 尺寸 | 位置 | active |")
        lines.append("|------|------|------|--------|")
        for name in sorted(other_nodes.keys()):
            n = nodes[name]
            sz = n["size"] or [0, 0]
            pos = n["pos"] or [0, 0]
            lines.append(f"| {name} | ({sz[0]:.0f}, {sz[1]:.0f}) | ({pos[0]:.0f}, {pos[1]:.0f}) | {n['active']} |")
        lines.append("")

    # Deep nodes summary
    deep_nodes = {k: v for k, v in nodes.items() if v["depth"] > 2}
    if deep_nodes:
        lines.append(f"## 深层节点 (depth 3+, {len(deep_nodes)} 个)")
        lines.append("")
        lines.append("| 节点 | depth | 尺寸 | active |")
        lines.append("|------|-------|------|--------|")
        for name in sorted(deep_nodes.keys()):
            n = nodes[name]
            sz = n["size"] or [0, 0]
            lines.append(f"| {name} | {n['depth']} | ({sz[0]:.0f}, {sz[1]:.0f}) | {n['active']} |")
        lines.append("")

    # ParticleSystems
    ps_nodes = [k for k, v in nodes.items() if "ParticleSystem" in str(v.get("components", []))]
    if ps_nodes:
        lines.append(f"## 粒子系统 ({len(ps_nodes)} 个)")
        lines.append("")
        lines.append(", ".join(f"`{n}`" for n in sorted(ps_nodes)))
        lines.append("")

    return "\n".join(lines)

def main():
    print("Reading physical asset map...")
    prefabs = read_available_prefabs()
    print(f"Found {len(prefabs)} UI prefabs with physical files")

    # Classify
    by_category = defaultdict(list)
    by_class = defaultdict(list)
    for p in prefabs:
        cat = categorize_prefab(p["address"])
        cls = classify_prefab(p["address"])
        by_category[cat].append(p)
        by_class[cls].append(p)

    print(f"\nCategories: {dict((k, len(v)) for k, v in sorted(by_category.items()))}")
    print(f"Classes: {dict((k, len(v)) for k, v in sorted(by_class.items())))}")

    # Focus: extract only View-class prefabs (main panels)
    views = by_class.get("View", [])
    print(f"\nFocusing on {len(views)} main View prefabs")

    os.makedirs(LAYOUT_DIR, exist_ok=True)
    os.makedirs(DOCS_DIR, exist_ok=True)

    extracted = 0
    for i, p in enumerate(views):
        address = p["address"]
        basename = Path(address).stem
        category = categorize_prefab(address)

        print(f"[{i+1}/{len(views)}] {category}/{basename} ...")

        # Extract layout
        json_path = extract_prefab(address)
        if json_path is None:
            continue

        # Analyze
        analysis = analyze_layout(json_path)

        # Generate doc
        doc = generate_doc(address, analysis, category)
        doc_path = DOCS_DIR / f"{category}_{basename}.md"
        doc_path.write_text(doc, encoding="utf-8")

        extracted += 1
        if extracted % 10 == 0:
            print(f"  ... {extracted}/{len(views)} extracted")

    print(f"\nDone! Extracted and analyzed {extracted} prefabs")
    print(f"Layout JSONs: {LAYOUT_DIR}")
    print(f"Docs: {DOCS_DIR}")

if __name__ == "__main__":
    main()
