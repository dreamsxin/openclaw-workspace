#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Extract MonoBehaviour serialized fields from Unity YooAsset prefab bundles.

Resolves Image.sprite → Sprite name, Text.text, and Button.onClick targets
by cross-referencing SpriteAtlas pathID→name maps.  Outputs JSON suitable for
Godot MVP sprite binding and documentation.

Usage:
  python extract_prefab_monobehaviour_fields.py MainUIView
  python extract_prefab_monobehaviour_fields.py MainUIView LotteryDrawMainView
  python extract_prefab_monobehaviour_fields.py --all
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

import UnityPy


# ── Config ────────────────────────────────────────────────────────────────
DEFAULT_PREFABS = [
    ("MainUIView", "Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab"),
    ("LotteryDrawMainView", "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab"),
    ("LotteryDrawFinishView", "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab"),
    ("HeroRecruitView", "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab"),
    ("LoginView", "Assets/Game/RawAssets/Prefabs/UI/Login/LoginView.prefab"),
    ("LaunchView", "Assets/Game/RawAssets/Prefabs/UI/Launch/LaunchView.prefab"),
    ("LoadingView", "Assets/Game/RawAssets/Prefabs/UI/Login/LoadingView.prefab"),
    ("TopResGrid", "Assets/Game/RawAssets/Prefabs/UI/Common/TopResGrid.prefab"),
]

# Prefab → known SpriteAtlas address (for sprite resolution)
PREFAB_SPRITEATLAS_MAP: dict[str, list[str]] = {
    "MainUIView": ["Assets/Game/RawAssets/Sprite/MainUI/MainUI.spriteatlas"],
    # LotteryDraw sprites are individual PNG bundles (not a unified atlas).
    # Common atlas provides shared sprites (lottery_btn, common icons).
    "LotteryDrawMainView": ["Assets/Game/RawAssets/Sprite/Common/Common.spriteatlas"],
    "LotteryDrawFinishView": ["Assets/Game/RawAssets/Sprite/Common/Common.spriteatlas"],
    "HeroRecruitView": ["Assets/Game/RawAssets/Sprite/Common/Common.spriteatlas"],
    "LoginView": ["Assets/Game/RawAssets/Sprite/Login/Login.spriteatlas"],
    "LaunchView": [],
    "LoadingView": [],
    "TopResGrid": ["Assets/Game/RawAssets/Sprite/Common/Common.spriteatlas"],
}


# ── Helpers ───────────────────────────────────────────────────────────────
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


def pptr_id(value: Any) -> int:
    return int(getattr(value, "path_id", getattr(value, "m_PathID", 0)) or 0)


def build_sprite_map(
    physical_map: dict[str, dict[str, str]],
    repo_root: Path,
    atlas_addresses: list[str],
    xor_prefix: int,
    xor_key: int,
) -> dict[int, str]:
    """Build pathID → sprite_name map from SpriteAtlas bundles."""
    sprite_names: dict[int, str] = {}
    for addr in atlas_addresses:
        row = physical_map.get(addr.lower())
        if not row:
            print(f"  [warn] atlas not in physical map: {addr}")
            continue
        source = (repo_root / row["physicalPath"]).resolve()
        if not source.exists():
            print(f"  [warn] atlas file not found: {source}")
            continue
        env = load_source(source, xor_prefix, xor_key)
        for obj in env.objects:
            if obj.type.name == "Sprite":
                d = obj.read()
                sprite_names[int(obj.path_id)] = str(getattr(d, "m_Name", f"_Sprite_{obj.path_id}"))
    return sprite_names


def get_mb_class_name(obj: Any) -> str:
    """Resolve MonoBehaviour → C# class name via m_Script → MonoScript."""
    data = obj.read() if hasattr(obj, "read") else obj
    script = getattr(data, "m_Script", None)
    if not script:
        return "Unknown"
    try:
        script_data = script.read()
        return str(getattr(script_data, "m_ClassName", "Unknown"))
    except Exception:
        return "Unknown"


def extract_prefab_mb_fields(
    prefab_name: str,
    prefab_address: str,
    physical_map: dict[str, dict[str, str]],
    repo_root: Path,
    xor_prefix: int,
    xor_key: int,
) -> dict[str, Any]:
    """Extract Image/Text/Button serialized fields from one prefab."""
    row = physical_map.get(prefab_address.lower())
    if not row:
        print(f"  [err] prefab not in physical map: {prefab_address}")
        return {"error": "not in physical map", "prefab": prefab_name}

    source = (repo_root / row["physicalPath"]).resolve()
    if not source.exists():
        print(f"  [err] prefab file not found: {source}")
        return {"error": "file not found", "prefab": prefab_name}

    env = load_source(source, xor_prefix, xor_key)

    # Build component→GameObject map
    comp_to_go: dict[int, int] = {}
    go_names: dict[int, str] = {}
    go_active: dict[int, bool] = {}
    for obj in env.objects:
        if obj.type.name != "GameObject":
            continue
        d = obj.read()
        go_names[int(obj.path_id)] = str(getattr(d, "m_Name", f"GO_{obj.path_id}"))
        go_active[int(obj.path_id)] = bool(getattr(d, "m_IsActive", True))
        for pair in getattr(d, "m_Component", []):
            comp = getattr(pair, "component", None)
            if comp:
                cid = int(getattr(comp, "path_id", 0))
                if cid:
                    comp_to_go[cid] = int(obj.path_id)

    # Load associated SpriteAtlas name maps
    atlas_addrs = PREFAB_SPRITEATLAS_MAP.get(prefab_name, [])
    sprite_names = build_sprite_map(physical_map, repo_root, atlas_addrs, xor_prefix, xor_key)
    if sprite_names:
        print(f"  Loaded {len(sprite_names)} sprite names from {len(atlas_addrs)} atlas(es)")

    # Extract Image/Text/Button fields
    images: list[dict[str, Any]] = []
    texts: list[dict[str, Any]] = []
    buttons: list[dict[str, Any]] = []
    other_mb: dict[str, int] = defaultdict(int)  # class_name → count

    for obj in env.objects:
        if obj.type.name != "MonoBehaviour":
            continue
        class_name = get_mb_class_name(obj)
        go_id = comp_to_go.get(int(obj.path_id))
        go_name = go_names.get(go_id, f"_GO_{go_id}")
        go_is_active = go_active.get(go_id, True)

        try:
            tree = obj.read_typetree()
        except Exception:
            other_mb[f"{class_name}(read_fail)"] += 1
            continue

        if class_name == "Image":
            entry = {
                "gameObject": go_name,
                "gameObjectPathId": go_id,
                "active": go_is_active,
                "componentPathId": int(obj.path_id),
            }
            sprite_ref = tree.get("m_Sprite", {})
            pid = int(sprite_ref.get("m_PathID", 0) or 0)
            fid = int(sprite_ref.get("m_FileID", 0) or 0)
            entry["spriteFileID"] = fid
            entry["spritePathID"] = pid
            if pid and pid in sprite_names:
                entry["spriteName"] = sprite_names[pid]
            elif pid:
                entry["spriteName"] = None  # external, not in known atlas
            else:
                entry["spriteName"] = None  # no sprite assigned
            # Also extract color and material
            color = tree.get("m_Color", {})
            if color:
                entry["color"] = {
                    "r": color.get("r"),
                    "g": color.get("g"),
                    "b": color.get("b"),
                    "a": color.get("a"),
                }
            mat = tree.get("m_Material", {})
            if mat and mat.get("m_PathID", 0):
                entry["materialPathID"] = int(mat.get("m_PathID", 0))
            # RaycastTarget for interaction
            entry["raycastTarget"] = tree.get("m_RaycastTarget", True)
            # Image type
            entry["imageType"] = tree.get("m_Type", 0)  # 0=Simple, 1=Sliced, 2=Tiled, 3=Filled
            images.append(entry)

        elif class_name == "Text":
            entry = {
                "gameObject": go_name,
                "gameObjectPathId": go_id,
                "active": go_is_active,
                "componentPathId": int(obj.path_id),
                "text": str(tree.get("m_Text", "") or ""),
            }
            font_ref = tree.get("m_FontData", {})
            if font_ref:
                entry["fontSize"] = font_ref.get("m_FontSize", 0)
                entry["fontStyle"] = font_ref.get("m_FontStyle", 0)
                entry["alignment"] = font_ref.get("m_Alignment", 0)
            color = tree.get("m_Color", {})
            if color:
                entry["color"] = {
                    "r": color.get("r"),
                    "g": color.get("g"),
                    "b": color.get("b"),
                    "a": color.get("a"),
                }
            entry["raycastTarget"] = tree.get("m_RaycastTarget", True)
            texts.append(entry)

        elif class_name == "Button":
            entry = {
                "gameObject": go_name,
                "gameObjectPathId": go_id,
                "active": go_is_active,
                "componentPathId": int(obj.path_id),
            }
            onclick = tree.get("m_OnClick", {})
            targets = onclick.get("m_Targets", []) if onclick else []
            # Simplify: extract target GameObject name and method
            click_targets = []
            for t in targets:
                target_obj = t.get("m_Target", {})
                target_go_id = int(target_obj.get("m_PathID", 0) or 0)
                method = t.get("m_MethodName", "")
                target_go_name = go_names.get(target_go_id, f"_GO_{target_go_id}")
                click_targets.append({
                    "targetGameObject": target_go_name,
                    "targetGameObjectPathId": target_go_id,
                    "methodName": method,
                })
            entry["onClickTargets"] = click_targets
            entry["interactable"] = tree.get("m_Interactable", True)
            # Navigation
            nav = tree.get("m_Navigation", {})
            entry["navigationMode"] = nav.get("m_Mode", 0) if nav else 0
            buttons.append(entry)

        else:
            other_mb[class_name] += 1

    # Summary
    resolved = sum(1 for img in images if img.get("spriteName"))
    unresolved = sum(1 for img in images if img["spritePathID"] and not img.get("spriteName"))
    no_sprite = sum(1 for img in images if not img["spritePathID"])

    return {
        "prefabName": prefab_name,
        "prefabAddress": prefab_address,
        "sourceBundle": str(source),
        "atlasAddresses": atlas_addrs,
        "imageCount": len(images),
        "imagesResolved": resolved,
        "imagesUnresolvedExternal": unresolved,
        "imagesNoSprite": no_sprite,
        "textCount": len(texts),
        "buttonCount": len(buttons),
        "otherMonoBehaviours": dict(other_mb),
        "images": images,
        "texts": texts,
        "buttons": buttons,
    }


# ── Markdown output ──────────────────────────────────────────────────────
def write_markdown(results: list[dict[str, Any]], path: Path) -> None:
    lines = [
        "# Prefab MonoBehaviour 字段提取报告",
        "",
        "Image.sprite / Text.text / Button.onClick 绑定数据",
        "",
    ]

    for r in results:
        if "error" in r:
            lines.append(f"## {r['prefab']}")
            lines.append(f"**{r['error']}**")
            continue

        name = r["prefabName"]
        lines.extend([
            f"## {name}",
            "",
            f"- 预制体: `{r['prefabAddress']}`",
            f"- 源 Bundle: `{r['sourceBundle']}`",
            f"- Image: {r['imageCount']} (✅{r['imagesResolved']} 🔴{r['imagesUnresolvedExternal']} ⚪{r['imagesNoSprite']})",
            f"- Text: {r['textCount']}",
            f"- Button: {r['buttonCount']}",
            f"- 其他 MB: {json.dumps(r['otherMonoBehaviours'], ensure_ascii=False)}",
            "",
        ])

        # Image→Sprite table
        images = r.get("images", [])
        if images:
            lines.extend([
                "### Image → Sprite 绑定",
                "",
                "| GameObject | Sprite Name | FileID | PathID | Active | Type |",
                "|-----------|------------|--------|--------|--------|------|",
            ])
            for img in sorted(images, key=lambda x: (not x.get("spriteName"), x.get("spriteName") or "", x["gameObject"])):
                sname = img.get("spriteName") or "—"
                if img["spritePathID"] and not img.get("spriteName"):
                    sname = f"❓ external:{img['spritePathID']}"
                stype = ["Simple", "Sliced", "Tiled", "Filled"][img.get("imageType", 0)]
                lines.append(
                    f"| {img['gameObject']} | {sname} | {img['spriteFileID']} | {img['spritePathID']} | "
                    f"{'✅' if img['active'] else '❌'} | {stype} |"
                )
            lines.append("")

        # Text fields
        texts_list = r.get("texts", [])
        if texts_list:
            lines.extend([
                "### Text 字段",
                "",
                "| GameObject | Text Content | FontSize | Alignment |",
                "|-----------|-------------|----------|-----------|",
            ])
            for t in texts_list:
                txt = t["text"].replace("\n", "\\n")[:60]
                lines.append(
                    f"| {t['gameObject']} | {txt} | {t.get('fontSize', '—')} | {t.get('alignment', '—')} |"
                )
            lines.append("")

        # Button callbacks
        buttons_list = r.get("buttons", [])
        if buttons_list:
            lines.extend([
                "### Button.onClick 回调",
                "",
                "| GameObject | Target | Method |",
                "|-----------|--------|--------|",
            ])
            for b in buttons_list:
                for ct in b.get("onClickTargets", []):
                    lines.append(f"| {b['gameObject']} | {ct['targetGameObject']} | {ct['methodName']} |")
                if not b.get("onClickTargets"):
                    lines.append(f"| {b['gameObject']} | *(empty)* | — |")
            lines.append("")

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


# ── Main ──────────────────────────────────────────────────────────────────
def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract MonoBehaviour serialized fields from Unity prefab bundles."
    )
    parser.add_argument(
        "prefabs", nargs="*",
        help="Prefab short names (MainUIView, LoginView, etc.) or --all for all defaults."
    )
    parser.add_argument("--all", action="store_true", help="Process all default prefabs.")
    parser.add_argument("--repo-root", default=".", help="Repository root.")
    parser.add_argument(
        "--physical-map",
        default="reverse-output/assets/yoo-physical-map/physical-asset-map.csv",
    )
    parser.add_argument(
        "--out-dir",
        default="reverse-output/monobehaviour-fields",
        help="Output directory for JSON files.",
    )
    parser.add_argument("--markdown", default="", help="Optional Markdown summary path.")
    parser.add_argument("--xor-prefix", type=int, default=222)
    parser.add_argument("--xor-key", type=lambda v: int(v, 0), default=0x16)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    physical_map = read_physical_map(repo_root / args.physical_map)
    out_dir = (repo_root / args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    # Determine which prefabs to process
    all_prefabs = dict(DEFAULT_PREFABS)
    if args.all:
        targets = list(all_prefabs.items())
    elif args.prefabs:
        targets = []
        for name in args.prefabs:
            if name in all_prefabs:
                targets.append((name, all_prefabs[name]))
            else:
                print(f"[warn] unknown prefab: {name} (known: {list(all_prefabs.keys())})")
    else:
        targets = [("MainUIView", all_prefabs["MainUIView"])]

    results: list[dict[str, Any]] = []
    for prefab_name, prefab_addr in targets:
        print(f"Extracting: {prefab_name}")
        result = extract_prefab_mb_fields(
            prefab_name, prefab_addr, physical_map, repo_root, args.xor_prefix, args.xor_key
        )
        results.append(result)

        # Write per-prefab JSON
        json_path = out_dir / f"{prefab_name}.mb-fields.json"
        json_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"  → {json_path.relative_to(repo_root)}")

        if "error" not in result:
            print(f"     Image: {result['imageCount']} total, {result['imagesResolved']} resolved")
            if result["imagesUnresolvedExternal"]:
                print(f"     ⚠ {result['imagesUnresolvedExternal']} external sprites unresolved")
            if result["buttonCount"]:
                print(f"     Button: {result['buttonCount']}")
            if result["textCount"]:
                print(f"     Text: {result['textCount']}")

    # Write combined Markdown if requested
    if args.markdown and results:
        markdown = (repo_root / args.markdown).resolve()
        write_markdown(results, markdown)
        print(f"\nMarkdown: {markdown.relative_to(repo_root)}")

    failures = sum(1 for r in results if "error" in r)
    print(f"\nDone: {len(results)} prefabs, {failures} failures")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
