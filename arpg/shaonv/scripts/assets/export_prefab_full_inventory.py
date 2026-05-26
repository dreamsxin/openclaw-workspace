#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export a full Unity prefab control/resource inventory.

The report combines RectTransform hierarchy, Image/Text/Button bindings,
internal Sprite objects, external SerializedFile CAB dependencies, and the
YooAsset physical map. It is intentionally generic so one-off prefab analysis
can become a repeatable documentation step.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

import UnityPy


KNOWN_PREFABS = {
    "MainUIView": "Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab",
    "CityView": "Assets/Game/RawAssets/Prefabs/UI/City/CityView.prefab",
    "ActivityMainView": "Assets/Game/RawAssets/Prefabs/UI/Activity/ActivityMainView.prefab",
    "BagView": "Assets/Game/RawAssets/Prefabs/UI/Bag/BagView.prefab",
    # ── Gal ──
    # Dormitory
    "GalDormitoryView": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryView.prefab",
    "GalDormitoryMainPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryMainPanel.prefab",
    "GalCharacterView": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalCharacterView.prefab",
    "GalDormitoryDressUpPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpPanel.prefab",
    "GalDormitoryDressUpBgGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpBgGrid.prefab",
    "GalDormitoryDressUpEffectGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpEffectGrid.prefab",
    "GalDormitoryDressUpSkinGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpSkinGrid.prefab",
    "GalDormitoryDressUpUnlockGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpUnlockGrid.prefab",
    "GalDormitoryFilesPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryFilesPanel.prefab",
    "GalDormitoryGiftPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryGiftPanel.prefab",
    # "GalDormitoryGiftGrid": missing from physical map
    "GalDormitoryInteractionPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryInteractionPanel.prefab",
    "GalDormitoryPlotPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryPlotPanel.prefab",
    # "GalDormitoryScenePanel": missing from physical map
    "GalVoiceGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalVoiceGrid.prefab",
    # Dormitory Plot
    "GalPlotBlackPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/Plot/GalPlotBlackPanel.prefab",
    # "GalPlotDialoguePanel": missing from physical map
    "GalPlotDialogueSectionCenterGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/Plot/GalPlotDialogueSectionCenterGrid.prefab",
    "GalPlotDialogueSectionRightGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/Plot/GalPlotDialogueSectionRightGrid.prefab",
    "GalPlotLocationPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/Plot/GalPlotLocationPanel.prefab",
    "GalPlotTransformPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/Plot/GalPlotTransformPanel.prefab",
    # Main Gal
    "GalCollectionPageGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionPageGrid.prefab",
    "GalCollectionRecordGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionRecordGrid.prefab",
    "GalCollectionRecordPreView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionRecordPreView.prefab",
    "GalCollectionRewardGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionRewardGrid.prefab",
    "GalCollectionRewardView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionRewardView.prefab",
    "GalCollectionTokenGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionTokenGrid.prefab",
    # "GalCollectionTokenGrid": missing from physical map
    # "GalCollectionView": missing from physical map
    # "GalDateRewardView": missing from physical map
    "GalDateSelectView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalDateSelectView.prefab",
    "GalDateSelectGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalDateSelectGrid.prefab",
    "GalEffectGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalEffectGrid.prefab",
    # "GalLevelGrid": missing from physical map
    "GalLevelGroupGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelGroupGrid.prefab",
    "GalLevelUpUnlockGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelUpUnlockGrid.prefab",
    "GalLevelUpView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelUpView.prefab",
    "GalLevelView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelView.prefab",
    "GalMapEventGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalMapEventGrid.prefab",
    "GalMapLocationGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalMapLocationGrid.prefab",
    # "GalMapView": missing from physical map
    # "GalMemorySelectGrid": missing from physical map
    "GalMemorySelectView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalMemorySelectView.prefab",
    # "GalPlotRecapGrid": missing from physical map
    # "GalPlotRecapView": missing from physical map
    "GalSpecialTouchSelectGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalSpecialTouchSelectGrid.prefab",
    "GalSpecialTouchSelectView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalSpecialTouchSelectView.prefab",
    "GalSpecialTouchView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalSpecialTouchView.prefab",
    "GalTabGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalTabGrid.prefab",
    "GalToastGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalToastGrid.prefab",
    "GalToastView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalToastView.prefab",
    "GalTokenDetailView": "Assets/Game/RawAssets/Prefabs/UI/Gal/GalTokenDetailView.prefab",
    # Gal Components
    "GalDormitoryPanelTopBtns": "Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalDormitoryPanelTopBtns.prefab",
    "GalDormitoryPlotCtlBar": "Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalDormitoryPlotCtlBar.prefab",
    "GalListenTimesBar": "Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalListenTimesBar.prefab",
    "GalRole": "Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalRole.prefab",
    "GalRoleSelectGrid": "Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalRoleSelectGrid.prefab",
    "GalRoleSelector": "Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalRoleSelector.prefab",
    # Gal SpineTouch
    "SpineDragEffect01": "Assets/Game/RawAssets/Prefabs/UI/Gal/SpineTouch/SpineDragEffect01.prefab",
    "SpineTouchTeachPanel": "Assets/Game/RawAssets/Prefabs/UI/Gal/SpineTouch/Teach/SpineTouchTeachPanel.prefab",
    # ── Hero ──
    "HeroDetailInfoView": "Assets/Game/RawAssets/Prefabs/UI/Hero/HeroDetailInfoView.prefab",
    "HeroListOrdinationTabGrid": "Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListOrdinationTabGrid.prefab",
    "HeroListTabGrid": "Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListTabGrid.prefab",
    "HeroListView": "Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListView.prefab",
    "HeroMainSelectHeroGrid": "Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainSelectHeroGrid.prefab",
    "HeroMainView": "Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainView.prefab",
    "LotteryDrawMainView": "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab",
    "PrayerView": "Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerView.prefab",
    "PrayerHolyRelicPanel": "Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerHolyRelicPanel.prefab",
    "PrayerRewardView": "Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardView.prefab",
    "PrayerRewardGrid": "Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardGrid.prefab",
    # ── Remnants / 幻靈 ──
    "RemnantInfoGrid": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantInfoGrid.prefab",
    "RemnantsListGrid": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsListGrid.prefab",
    "RemnantsListView": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsListView.prefab",
    "RemnantsMainShowPanel": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsMainShowPanel.prefab",
    "RemnantsMainView": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsMainView.prefab",
    "RemnantsUpdateTabGrid": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsUpdateTabGrid.prefab",
    "RemnantsUpdateView": "Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsUpdateView.prefab",
}

IMAGE_TYPE = {0: "Simple", 1: "Sliced", 2: "Tiled", 3: "Filled"}

KNOWN_CAB_SAMPLE_ROWS = {
    "CAB-380dc4eef737e1f3e153b7a16c1efbd3": {
        "address": "Assets/Game/RawAssets/Sprite/LotteryDraw/LotteryDraw.spriteatlas",
        "bundleName": "assets_game_rawassets_sprite_lotterydraw.bundle",
        "hashFileName": "6c8ca2312693e27b46729a868236cce3.bundle",
        "physicalPath": r"files\yoo\Default\BundleFiles\ce\ce18fceb7ff2f67915e3b4177b14df94\__data",
        "physicalExists": "True",
    },
}


def safe_name(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "-", value).strip("-") or "prefab"


def load_source(path: Path, xor_prefix: int, xor_key: int):
    data = bytearray(path.read_bytes())
    for index in range(min(xor_prefix, len(data))):
        data[index] ^= xor_key
    return UnityPy.load(bytes(data))


def read_physical_map(path: Path) -> tuple[dict[str, dict[str, str]], dict[str, list[dict[str, str]]]]:
    by_address: dict[str, dict[str, str]] = {}
    by_basename: dict[str, list[dict[str, str]]] = defaultdict(list)
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            address = row.get("address", "")
            if not address:
                continue
            by_address[address.lower()] = row
            by_basename[Path(address).stem.lower()].append(row)
    return by_address, by_basename


def add_known_sample_rows(
    by_address: dict[str, dict[str, str]],
    by_basename: dict[str, list[dict[str, str]]],
) -> None:
    for row in KNOWN_CAB_SAMPLE_ROWS.values():
        address = row.get("address", "")
        if address:
            by_address.setdefault(address.lower(), row)
            by_basename[Path(address).stem.lower()].append(row)


def pptr_id(value: Any) -> int:
    return int(getattr(value, "path_id", getattr(value, "m_PathID", 0)) or 0)


def get_mb_class_name(obj: Any) -> str:
    try:
        data = obj.read()
        script = getattr(data, "m_Script", None)
        if not script:
            return "Unknown"
        return str(getattr(script.read(), "m_ClassName", "Unknown"))
    except Exception:
        return "Unknown"


def infer_ui_class_name(class_name: str, tree: dict[str, Any]) -> str:
    """Recover stripped Unity UI class names from stable serialized fields."""
    if class_name != "Unknown":
        return class_name
    keys = set(tree)
    if {"m_Sprite", "m_RaycastTarget", "m_Type"}.issubset(keys):
        return "Image"
    if {"m_Text", "m_FontData", "m_RaycastTarget"}.issubset(keys):
        return "Text"
    if {"m_Interactable", "m_TargetGraphic", "m_OnClick"}.issubset(keys):
        return "Button"
    return class_name


def get_inferred_mb_class_name(obj: Any) -> str:
    class_name = get_mb_class_name(obj)
    if class_name != "Unknown":
        return class_name
    try:
        return infer_ui_class_name(class_name, obj.read_typetree())
    except Exception:
        return class_name


def object_name(obj: Any, data: Any) -> str:
    return str(getattr(data, "m_Name", "") or getattr(data, "name", "") or f"{obj.type.name}_{obj.path_id}")


def vec2(value: Any) -> list[float]:
    if value is None:
        return [0.0, 0.0]
    return [float(getattr(value, "x", 0.0)), float(getattr(value, "y", 0.0))]


def vec3(value: Any) -> list[float]:
    if value is None:
        return [0.0, 0.0, 0.0]
    return [float(getattr(value, "x", 0.0)), float(getattr(value, "y", 0.0)), float(getattr(value, "z", 0.0))]


def esc(value: Any) -> str:
    text = "" if value is None else str(value)
    return text.replace("`", "\\`").replace("|", "\\|").replace("\r", " ").replace("\n", " ")


def fmt_num(value: Any) -> str:
    try:
        number = float(value)
    except Exception:
        return str(value)
    if abs(number) < 0.0005:
        number = 0.0
    return f"{number:.1f}"


def fmt_vec2(value: Any) -> str:
    if not value:
        return "0.0,0.0"
    return f"{fmt_num(value[0])},{fmt_num(value[1])}"


def rect_text(rect: dict[str, Any] | None) -> str:
    if not rect:
        return "-"
    return f"pos({fmt_vec2(rect.get('anchoredPosition'))}) size({fmt_vec2(rect.get('sizeDelta'))})"


def anchor_text(rect: dict[str, Any] | None) -> str:
    if not rect:
        return "-"
    return f"{fmt_vec2(rect.get('anchorMin'))}->{fmt_vec2(rect.get('anchorMax'))} p({fmt_vec2(rect.get('pivot'))})"


def bundle_short(row: dict[str, str] | None) -> str:
    if not row:
        return "bundle ?"
    return row.get("bundleName") or row.get("hashFileName") or "bundle ?"


def canonical_cab(value: str) -> str:
    match = re.search(r"cab-([0-9a-fA-F]{32})", value or "", re.IGNORECASE)
    if match:
        return f"CAB-{match.group(1).lower()}"
    return value


def resolve_prefab_address(target: str) -> tuple[str, str]:
    if target in KNOWN_PREFABS:
        return target, KNOWN_PREFABS[target]
    if target.endswith(".prefab"):
        return Path(target).stem, target.replace("\\", "/")
    raise ValueError(f"Unknown prefab target: {target}")


def inspect_layout(env: Any, address: str, source: Path) -> dict[str, Any]:
    type_counts = Counter(obj.type.name for obj in env.objects)
    component_type_by_path = {int(obj.path_id): obj.type.name for obj in env.objects}
    mb_class_by_path = {
        int(obj.path_id): get_inferred_mb_class_name(obj)
        for obj in env.objects
        if obj.type.name == "MonoBehaviour"
    }

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
            if not comp_id:
                continue
            ctype = component_type_by_path.get(comp_id, "Unknown")
            class_name = mb_class_by_path.get(comp_id) if ctype == "MonoBehaviour" else ""
            components.append({"pathId": comp_id, "type": ctype, "className": class_name})
        gameobjects[int(obj.path_id)] = {
            "pathId": int(obj.path_id),
            "name": object_name(obj, data),
            "active": bool(getattr(data, "m_IsActive", True)),
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
        component_names = [
            component["className"] if component["type"] == "MonoBehaviour" and component["className"] else component["type"]
            for component in go["components"]
        ]
        nodes.append({
            **go,
            "parentPathId": parent_go_id,
            "parentName": gameobjects.get(parent_go_id, {}).get("name", ""),
            "componentTypes": component_names,
            "rect": rect,
        })

    children_by_parent: dict[int, list[dict[str, Any]]] = defaultdict(list)
    for node in nodes:
        children_by_parent[int(node.get("parentPathId", 0))].append(node)

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

    def build_tree(node: dict[str, Any]) -> dict[str, Any]:
        return {
            "name": node["name"],
            "pathId": node["pathId"],
            "active": node["active"],
            "components": node["componentTypes"],
            "rect": node.get("rect"),
            "children": [build_tree(child) for child in children_by_parent.get(node["pathId"], [])],
        }

    roots = [node for node in nodes if int(node.get("parentPathId", 0)) not in gameobjects]
    roots.sort(key=sort_key)
    return {
        "address": address,
        "source": str(source),
        "typeCounts": dict(sorted(type_counts.items())),
        "nodeCount": len(nodes),
        "roots": [build_tree(root) for root in roots],
    }


def flatten_nodes(layout: dict[str, Any]) -> list[dict[str, Any]]:
    rows = []

    def walk(node: dict[str, Any], parent: str = "", depth: int = 0) -> None:
        path = f"{parent}/{node['name']}" if parent else node["name"]
        copied = dict(node)
        copied["path"] = path
        copied["depth"] = depth
        rows.append(copied)
        for child in node.get("children", []) or []:
            walk(child, path, depth + 1)

    for root in layout.get("roots", []):
        walk(root)
    return rows


def extract_asset_bundle_metadata(env: Any) -> tuple[list[str], dict[int, str], list[tuple[int, int]]]:
    dependencies: list[str] = []
    fileid_to_cab: dict[int, str] = {}
    preload: list[tuple[int, int]] = []
    for asset in getattr(env, "assets", []):
        for index, ext in enumerate(getattr(asset, "externals", []), 1):
            raw = str(getattr(ext, "name", "") or getattr(ext, "path", "") or "")
            fileid_to_cab[index] = canonical_cab(raw)
    for obj in env.objects:
        if obj.type.name != "AssetBundle":
            continue
        data = obj.read()
        dependencies.extend(str(dep) for dep in getattr(data, "m_Dependencies", []) or [])
        for ref in getattr(data, "m_PreloadTable", []) or []:
            preload.append((int(getattr(ref, "file_id", getattr(ref, "m_FileID", 0)) or 0), pptr_id(ref)))
    return dependencies, fileid_to_cab, preload


def build_component_context(env: Any) -> tuple[dict[int, int], dict[int, str], dict[int, bool], dict[int, str]]:
    component_to_go: dict[int, int] = {}
    go_names: dict[int, str] = {}
    go_active: dict[int, bool] = {}
    mb_class_by_path: dict[int, str] = {}
    for obj in env.objects:
        if obj.type.name == "MonoBehaviour":
            mb_class_by_path[int(obj.path_id)] = get_mb_class_name(obj)
    for obj in env.objects:
        if obj.type.name != "GameObject":
            continue
        data = obj.read()
        go_id = int(obj.path_id)
        go_names[go_id] = object_name(obj, data)
        go_active[go_id] = bool(getattr(data, "m_IsActive", True))
        for pair in getattr(data, "m_Component", []):
            comp = getattr(pair, "component", None)
            cid = pptr_id(comp)
            if cid:
                component_to_go[cid] = go_id
    return component_to_go, go_names, go_active, mb_class_by_path


def extract_bindings(env: Any) -> dict[str, Any]:
    component_to_go, go_names, go_active, mb_class_by_path = build_component_context(env)
    images: list[dict[str, Any]] = []
    texts: list[dict[str, Any]] = []
    buttons: list[dict[str, Any]] = []
    other = Counter()
    internal_sprites: dict[int, str] = {}
    for obj in env.objects:
        if obj.type.name == "Sprite":
            try:
                data = obj.read()
                internal_sprites[int(obj.path_id)] = str(getattr(data, "m_Name", "") or f"Sprite_{obj.path_id}")
            except Exception:
                pass

    for obj in env.objects:
        if obj.type.name != "MonoBehaviour":
            continue
        class_name = mb_class_by_path.get(int(obj.path_id), "Unknown")
        go_id = component_to_go.get(int(obj.path_id), 0)
        entry_base = {
            "gameObject": go_names.get(go_id, f"_GO_{go_id}"),
            "gameObjectPathId": go_id,
            "active": go_active.get(go_id, True),
            "componentPathId": int(obj.path_id),
        }
        try:
            tree = obj.read_typetree()
        except Exception:
            other[f"{class_name}(read_fail)"] += 1
            continue
        class_name = infer_ui_class_name(class_name, tree)

        if class_name == "Image":
            sprite_ref = tree.get("m_Sprite", {}) or {}
            color = tree.get("m_Color", {}) or {}
            entry = {
                **entry_base,
                "spriteFileID": int(sprite_ref.get("m_FileID", 0) or 0),
                "spritePathID": int(sprite_ref.get("m_PathID", 0) or 0),
                "color": {key: color.get(key) for key in ("r", "g", "b", "a")} if color else {},
                "raycastTarget": tree.get("m_RaycastTarget", True),
                "imageType": tree.get("m_Type", 0),
            }
            images.append(entry)
        elif class_name == "Text":
            font_data = tree.get("m_FontData", {}) or {}
            color = tree.get("m_Color", {}) or {}
            entry = {
                **entry_base,
                "text": str(tree.get("m_Text", "") or ""),
                "fontSize": font_data.get("m_FontSize", 0),
                "fontStyle": font_data.get("m_FontStyle", 0),
                "alignment": font_data.get("m_Alignment", 0),
                "color": {key: color.get(key) for key in ("r", "g", "b", "a")} if color else {},
                "raycastTarget": tree.get("m_RaycastTarget", True),
            }
            texts.append(entry)
        elif class_name == "Button":
            nav = tree.get("m_Navigation", {}) or {}
            entry = {
                **entry_base,
                "interactable": tree.get("m_Interactable", True),
                "navigationMode": nav.get("m_Mode", 0),
            }
            buttons.append(entry)
        else:
            other[class_name] += 1

    return {
        "images": images,
        "texts": texts,
        "buttons": buttons,
        "otherMonoBehaviours": dict(sorted(other.items())),
        "internalSprites": internal_sprites,
    }


def collect_unique_physical_rows(by_address: dict[str, dict[str, str]]) -> list[dict[str, str]]:
    seen = set()
    rows = []
    for row in by_address.values():
        physical = row.get("physicalPath", "")
        if not physical or physical in seen or row.get("physicalExists") != "True":
            continue
        seen.add(physical)
        rows.append(row)

    def priority(row: dict[str, str]) -> tuple[int, str]:
        text = f"{row.get('address', '')} {row.get('bundleName', '')}".lower()
        keys = [
            "sprite/",
            "font",
            "material",
            "shader",
            "prefabs/ui",
            "spine",
            "anim",
        ]
        for index, key in enumerate(keys):
            if key in text:
                return (index, text)
        return (len(keys), text)

    return sorted(rows, key=priority)


def locate_cab_rows(
    repo_root: Path,
    candidates: list[dict[str, str]],
    target_cabs: set[str],
    xor_prefix: int,
    xor_key: int,
) -> dict[str, dict[str, str]]:
    found: dict[str, dict[str, str]] = {}
    lower_targets = {cab.lower(): cab for cab in target_cabs if cab}
    for row in candidates:
        if len(found) == len(lower_targets):
            break
        source = repo_root / row.get("physicalPath", "")
        if not source.exists():
            continue
        try:
            env = load_source(source, xor_prefix, xor_key)
        except Exception:
            continue
        for asset in getattr(env, "assets", []):
            name = str(getattr(asset, "name", "") or "")
            key = lower_targets.get(name.lower())
            if key and key not in found:
                found[key] = row
        for obj in env.objects:
            if obj.type.name != "AssetBundle":
                continue
            try:
                bundle_name = str(getattr(obj.read(), "m_Name", "") or "")
            except Exception:
                bundle_name = ""
            key = lower_targets.get(bundle_name.lower())
            if key and key not in found:
                found[key] = row
    return found


def load_sprite_names_from_row(
    repo_root: Path,
    row: dict[str, str],
    xor_prefix: int,
    xor_key: int,
) -> dict[int, str]:
    source = repo_root / row.get("physicalPath", "")
    if not source.exists():
        return {}
    try:
        env = load_source(source, xor_prefix, xor_key)
    except Exception:
        return {}
    names = {}
    for obj in env.objects:
        if obj.type.name != "Sprite":
            continue
        try:
            data = obj.read()
            names[int(obj.path_id)] = str(getattr(data, "m_Name", "") or f"Sprite_{obj.path_id}")
        except Exception:
            continue
    return names


def image_asset_for_name(
    name: str,
    by_basename: dict[str, list[dict[str, str]]],
    preferred_row: dict[str, str] | None = None,
) -> tuple[str, dict[str, str]] | None:
    rows = by_basename.get(name.lower(), [])
    sprite_rows = [row for row in rows if "/Sprite/" in row.get("address", "").replace("\\", "/")]
    if preferred_row:
        for row in sprite_rows:
            if (
                row.get("bundleName") == preferred_row.get("bundleName")
                or row.get("hashFileName") == preferred_row.get("hashFileName")
                or row.get("physicalPath") == preferred_row.get("physicalPath")
            ):
                return row.get("address", ""), row
    if sprite_rows:
        return sprite_rows[0].get("address", ""), sprite_rows[0]
    if rows:
        return rows[0].get("address", ""), rows[0]
    return None


def add_spriteatlas_rows(
    by_basename: dict[str, list[dict[str, str]]],
    names_by_fileid: dict[int, dict[int, str]],
    fileid_to_cab: dict[int, str],
    cab_rows: dict[str, dict[str, str]],
) -> None:
    for fid, names in names_by_fileid.items():
        cab = fileid_to_cab.get(fid, "")
        row = cab_rows.get(cab)
        if not row:
            continue
        base_address = str(row.get("address", ""))
        if base_address.endswith(".spriteatlas"):
            folder = str(Path(base_address).parent).replace("\\", "/")
        else:
            folder = str(Path(base_address).parent).replace("\\", "/")
        for name in names.values():
            image_row = dict(row)
            image_row["address"] = f"{folder}/{name}.png"
            image_row["assetPath"] = image_row["address"]
            by_basename[name.lower()].append(image_row)


def generate_report(
    prefab_name: str,
    prefab_address: str,
    prefab_row: dict[str, str],
    layout: dict[str, Any],
    bindings: dict[str, Any],
    fileid_to_cab: dict[int, str],
    cab_rows: dict[str, dict[str, str]],
    sprite_names_by_fileid: dict[int, dict[int, str]],
    by_basename: dict[str, list[dict[str, str]]],
    out_path: Path,
) -> tuple[int, int]:
    nodes = flatten_nodes(layout)
    images_by_go: dict[int, list[dict[str, Any]]] = defaultdict(list)
    texts_by_go: dict[int, list[dict[str, Any]]] = defaultdict(list)
    buttons_by_go: dict[int, list[dict[str, Any]]] = defaultdict(list)
    for image in bindings["images"]:
        images_by_go[int(image.get("gameObjectPathId") or 0)].append(image)
    for text in bindings["texts"]:
        texts_by_go[int(text.get("gameObjectPathId") or 0)].append(text)
    for button in bindings["buttons"]:
        buttons_by_go[int(button.get("gameObjectPathId") or 0)].append(button)

    resource_refs: list[tuple[str, str, dict[str, str] | None, str]] = []
    resolved_counts = Counter()
    internal_sprites = {int(key): value for key, value in bindings["internalSprites"].items()}

    def resolve_image(image: dict[str, Any]) -> str:
        fid = int(image.get("spriteFileID") or 0)
        pid = int(image.get("spritePathID") or 0)
        typ = IMAGE_TYPE.get(int(image.get("imageType") or 0), str(image.get("imageType")))
        alpha = image.get("color", {}).get("a")
        suffix = f", a={float(alpha):.2f}" if isinstance(alpha, (int, float)) and abs(float(alpha) - 1.0) > 0.001 else ""
        if not pid:
            resolved_counts["no_sprite"] += 1
            return f"Image:none [{typ}]{suffix}"
        name = ""
        source_note = ""
        row = None
        if fid == 0 and pid in internal_sprites:
            name = internal_sprites[pid]
            source_note = "internal Sprite in prefab bundle"
            row = prefab_row
            resolved_counts["internal_sprite"] += 1
            asset = f"{prefab_address}#Sprite/{name}"
        else:
            name = sprite_names_by_fileid.get(fid, {}).get(pid, "")
            cab = fileid_to_cab.get(fid, f"fileID:{fid}")
            source_note = f"external {cab}"
            if name:
                found = image_asset_for_name(name, by_basename, cab_rows.get(cab))
                if found:
                    asset, row = found
                    resolved_counts["external_sprite"] += 1
                else:
                    asset = f"{cab}#{name}"
                    row = cab_rows.get(cab)
                    resolved_counts["external_sprite_name_only"] += 1
            else:
                resolved_counts["unresolved_sprite"] += 1
                return f"Image:external fid={fid} pid={pid} cab={cab} [{typ}]{suffix}"
        resource_refs.append((name, asset, row, source_note))
        return f"Image:{name} [{typ}] -> {bundle_short(row)}{suffix}"

    def node_bindings(node: dict[str, Any]) -> str:
        go_id = int(node.get("pathId") or 0)
        parts = [resolve_image(image) for image in images_by_go.get(go_id, [])]
        for text in texts_by_go.get(go_id, []):
            content = esc(text.get("text", ""))
            if len(content) > 28:
                content = content[:28] + "..."
            parts.append(f"Text(fs={text.get('fontSize', '')}):\"{content}\"")
        for button in buttons_by_go.get(go_id, []):
            parts.append("Button" if int(button.get("interactable", 1)) else "Button(disabled)")
        return "<br>".join(parts) if parts else "-"

    node_rows = []
    for index, node in enumerate(nodes, 1):
        node_rows.append({
            "index": index,
            "depth": node["depth"],
            "path": node["path"],
            "active": "Y" if node.get("active", True) else "N",
            "rect": rect_text(node.get("rect")),
            "anchor": anchor_text(node.get("rect")),
            "components": ",".join(node.get("components", [])),
            "bindings": node_bindings(node),
        })

    unique_refs = {}
    for name, asset, row, source in resource_refs:
        key = (name, asset, row.get("bundleName") if row else "", row.get("hashFileName") if row else "")
        unique_refs.setdefault(key, {"name": name, "asset": asset, "row": row, "sources": set(), "count": 0})
        unique_refs[key]["sources"].add(source)
        unique_refs[key]["count"] += 1

    lines = [
        f"# {prefab_name} 全控件与资源清单",
        "",
        "生成时间：2026-05-24。",
        "",
        f"本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `{prefab_name}`。",
        "",
        "## 输入与结论",
        "",
        f"- Prefab: `{prefab_address}`",
        f"- Prefab bundle: `{bundle_short(prefab_row)}` / `{prefab_row.get('physicalPath', '')}`",
        f"- 节点数：`{len(nodes)}`。",
        f"- Image/Text/Button：`{len(bindings['images'])}` / `{len(bindings['texts'])}` / `{len(bindings['buttons'])}`。",
        f"- Image 解析：外部 Sprite `{resolved_counts['external_sprite']}`，外部具名但未落到物理表 `{resolved_counts['external_sprite_name_only']}`，prefab 内置 Sprite `{resolved_counts['internal_sprite']}`，无 sprite `{resolved_counts['no_sprite']}`，未解析 `{resolved_counts['unresolved_sprite']}`。",
        "",
        "## 资源 Bundle 表",
        "",
        "| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |",
        "|---|---:|---|---|---|---|",
    ]
    for item in sorted(unique_refs.values(), key=lambda value: (bundle_short(value["row"]), value["name"], value["asset"])):
        row = item["row"] or {}
        lines.append("| `{}` | {} | `{}` | `{}` | `{}`<br>`{}` | {} |".format(
            esc(item["name"]),
            item["count"],
            esc(item["asset"]),
            esc(row.get("bundleName", "?")),
            esc(row.get("hashFileName", "?")),
            esc(row.get("physicalPath", "?")),
            esc(", ".join(sorted(item["sources"]))),
        ))

    lines.extend([
        "",
        "## 外部 CAB 对照",
        "",
        "| FileID | CAB | Located bundle | Physical |",
        "|---:|---|---|---|",
    ])
    for fid in sorted(fileid_to_cab):
        cab = fileid_to_cab[fid]
        row = cab_rows.get(cab)
        lines.append(f"| {fid} | `{esc(cab)}` | `{esc(row.get('bundleName', '-') if row else '-')}` | `{esc(row.get('physicalPath', '-') if row else '-')}` |")

    lines.extend([
        "",
        "## 节点层级清单",
        "",
        "| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |",
        "|---:|---:|---|:---:|---|---|---|---|",
    ])
    for row in node_rows:
        lines.append("| {index} | {depth} | `{path}` | {active} | `{rect}` | `{anchor}` | `{components}` | {bindings} |".format(
            index=row["index"],
            depth=row["depth"],
            path=esc(row["path"]),
            active=row["active"],
            rect=esc(row["rect"]),
            anchor=esc(row["anchor"]),
            components=esc(row["components"]),
            bindings=row["bindings"],
        ))

    lines.extend([
        "",
        "## 复用路线验证",
        "",
        "- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。",
        "- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。",
        "- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。",
        "",
    ])

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines), encoding="utf-8")
    return len(nodes), len(unique_refs)


def main() -> int:
    parser = argparse.ArgumentParser(description="Export full prefab control/resource inventory.")
    parser.add_argument("target", help="Known prefab short name or full prefab address.")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--physical-map", default="reverse-output/assets/yoo-physical-map/physical-asset-map.csv")
    parser.add_argument("--out", default="", help="Output Markdown path.")
    parser.add_argument("--layout-out-dir", default="reverse-output/godot-layout-inspect")
    parser.add_argument("--mb-out-dir", default="reverse-output/monobehaviour-fields")
    parser.add_argument("--xor-prefix", type=int, default=222)
    parser.add_argument("--xor-key", type=lambda value: int(value, 0), default=0x16)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    by_address, by_basename = read_physical_map(repo_root / args.physical_map)
    add_known_sample_rows(by_address, by_basename)
    prefab_name, prefab_address = resolve_prefab_address(args.target)
    prefab_row = by_address.get(prefab_address.lower())
    if not prefab_row:
        raise SystemExit(f"Prefab not found in physical map: {prefab_address}")
    source = repo_root / prefab_row.get("physicalPath", "")
    if not source.exists():
        raise SystemExit(f"Prefab bundle not found: {source}")

    env = load_source(source, args.xor_prefix, args.xor_key)
    layout = inspect_layout(env, prefab_address, source)
    bindings = extract_bindings(env)
    dependencies, fileid_to_cab, _preload = extract_asset_bundle_metadata(env)

    target_cabs = {canonical_cab(cab) for cab in fileid_to_cab.values()} | {canonical_cab(dep) for dep in dependencies}
    cab_rows = locate_cab_rows(
        repo_root,
        collect_unique_physical_rows(by_address),
        target_cabs,
        args.xor_prefix,
        args.xor_key,
    )
    for cab in target_cabs:
        known_row = KNOWN_CAB_SAMPLE_ROWS.get(cab)
        if known_row and (repo_root / known_row.get("physicalPath", "")).exists():
            cab_rows.setdefault(cab, known_row)
    sprite_names_by_fileid: dict[int, dict[int, str]] = {}
    for fid, cab in fileid_to_cab.items():
        row = cab_rows.get(cab)
        if row:
            sprite_names_by_fileid[fid] = load_sprite_names_from_row(repo_root, row, args.xor_prefix, args.xor_key)
    add_spriteatlas_rows(by_basename, sprite_names_by_fileid, fileid_to_cab, cab_rows)

    layout_dir = repo_root / args.layout_out_dir
    mb_dir = repo_root / args.mb_out_dir
    layout_dir.mkdir(parents=True, exist_ok=True)
    mb_dir.mkdir(parents=True, exist_ok=True)
    (layout_dir / f"{prefab_name}.layout.json").write_text(json.dumps(layout, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (mb_dir / f"{prefab_name}.mb-fields.json").write_text(json.dumps({
        "prefabName": prefab_name,
        "prefabAddress": prefab_address,
        "sourceBundle": str(source),
        "imageCount": len(bindings["images"]),
        "textCount": len(bindings["texts"]),
        "buttonCount": len(bindings["buttons"]),
        **bindings,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if args.out:
        out_path = repo_root / args.out
    else:
        out_path = repo_root / "docs" / f"shaonv-{safe_name(prefab_name).lower()}-full-control-resource-inventory-2026-05-24.md"
    node_count, resource_count = generate_report(
        prefab_name,
        prefab_address,
        prefab_row,
        layout,
        bindings,
        fileid_to_cab,
        cab_rows,
        sprite_names_by_fileid,
        by_basename,
        out_path,
    )
    print(f"Markdown: {out_path.relative_to(repo_root)}")
    print(f"Layout: {layout_dir / f'{prefab_name}.layout.json'}")
    print(f"MB fields: {mb_dir / f'{prefab_name}.mb-fields.json'}")
    print(f"Nodes: {node_count}; Images: {len(bindings['images'])}; Texts: {len(bindings['texts'])}; Buttons: {len(bindings['buttons'])}; Resources: {resource_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
