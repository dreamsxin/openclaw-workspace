#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
map_text_to_controls.py — 将 Prefab mb-fields Text 组件映射到 lang key

输入:
  reverse-output/monobehaviour-fields/<View>.mb-fields.json
  reverse-output/godot-layout-inspect/<View>.layout.json
  reverse-output/story-texts/lang_extra_parsed.json

输出: 控制台文本映射表

用法:
  python tools/map_text_to_controls.py MainUIView
"""

import json, os, sys, argparse
from collections import defaultdict


def load_layout(layout_path: str) -> dict:
    """加载 layout.json，构建 pathId → {name, parentPathId}"""
    with open(layout_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    lookup = {}
    for n in data["nodes"]:
        lookup[n["pathId"]] = {
            "name": n["name"],
            "parentPathId": n.get("parentPathId", 0),
        }
    return lookup


def get_full_path(lookup: dict, pid: int, depth: int = 0) -> str:
    """根据 pathId 递归溯源完整层级路径"""
    if depth > 10:
        return "..."
    info = lookup.get(pid)
    if not info:
        return f"?{pid}"
    ppid = info["parentPathId"]
    if ppid == 0:
        return info["name"]
    return get_full_path(lookup, ppid, depth + 1) + "/" + info["name"]


def load_mb_fields(mb_path: str, layout_lookup: dict) -> list:
    """提取所有 Text 组件及其完整路径"""
    with open(mb_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    texts = []
    for t in data.get("texts", []):
        go_id = t.get("gameObjectPathId", 0)
        path = get_full_path(layout_lookup, go_id)
        texts.append({
            "path": path,
            "text": t.get("text", ""),
            "fontSize": t.get("fontSize", 0),
            "gameObject": t.get("gameObject", ""),
        })
    return texts


def load_lang_keys(parsed_path: str) -> dict:
    """构建 value → [keys] 反向索引"""
    with open(parsed_path, "r", encoding="utf-8") as f:
        entries = json.load(f)
    val_to_keys = defaultdict(list)
    for k, v in entries:
        v_clean = v.strip().replace("\n", "")
        val_to_keys[v_clean].append(k)
    return dict(val_to_keys)


def main():
    parser = argparse.ArgumentParser(description="映射 Text 控件到 lang key")
    parser.add_argument(
        "view", default="MainUIView", nargs="?",
        help="View 名称（如 MainUIView, LoginView）",
    )
    parser.add_argument(
        "--mb-dir", default="reverse-output/monobehaviour-fields",
        help="mb-fields 目录",
    )
    parser.add_argument(
        "--layout-dir", default="reverse-output/godot-layout-inspect",
        help="layout JSON 目录",
    )
    parser.add_argument(
        "--lang-parsed", default="reverse-output/story-texts/lang_extra_parsed.json",
        help="已解析的 UI 语言包",
    )
    args = parser.parse_args()

    mb_path = os.path.join(args.mb_dir, f"{args.view}.mb-fields.json")
    layout_path = os.path.join(args.layout_dir, f"{args.view}.layout.json")

    if not os.path.isfile(mb_path):
        print(f"ERROR: {mb_path} not found", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(layout_path):
        print(f"ERROR: {layout_path} not found", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(args.lang_parsed):
        print(f"ERROR: {args.lang_parsed} not found", file=sys.stderr)
        sys.exit(1)

    layout_lookup = load_layout(layout_path)
    text_nodes = load_mb_fields(mb_path, layout_lookup)
    val_to_keys = load_lang_keys(args.lang_parsed)

    print(f"# {args.view} Text → Lang Key Mapping\n")
    for node in text_nodes:
        ntext = node["text"]
        if not ntext or ntext == "Default":
            continue
        keys = val_to_keys.get(ntext)
        if keys:
            print(f"  {node['path']}: \"{ntext}\" → {keys}")
        else:
            print(f"  {node['path']}: \"{ntext}\" → (no lang match)")


if __name__ == "__main__":
    main()
