#!/usr/bin/env python3
import json
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROJECT_ROOT = ROOT / "reverse-output/assets/assetripper-main/ExportedProject"
ASSETS_ROOT = PROJECT_ROOT / "Assets"
GODOT_SCRIPT_ROOT = ROOT / "godot-project/scripts"
JSON_OUTPUT = ROOT / "godot-project/data/focused_ui_layout_reference.json"
MD_OUTPUT = ROOT / "docs/reverse-godot/focused-ui-prefab-audit.md"


TARGETS = [
    {
        "name": "UIInGame",
        "prefab": "Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab",
        "godot_script": "ingame_reference_shell.gd",
        "priority": "high",
    },
    {
        "name": "UIMaidLobby",
        "prefab": "Assets/Resources/prefabs/ui/UIMaidLobby.prefab",
        "godot_script": "maid_lobby_reference_screen.gd",
        "priority": "high",
    },
    {
        "name": "UIPopup_Inventory",
        "prefab": "Assets/Resources/prefabs/ui/popup/UIPopup_Inventory.prefab",
        "godot_script": "inventory_popup_reference_screen.gd",
        "priority": "high",
    },
    {
        "name": "UIPopup_Shop",
        "prefab": "Assets/Resources/prefabs/ui/popup/shop/UIPopup_Shop.prefab",
        "godot_script": "shop_popup_reference_screen.gd",
        "priority": "high",
    },
    {
        "name": "UIPopup_MaidLobbySelect",
        "prefab": "Assets/Resources/prefabs/ui/popup/outgame/UIPopup_MaidLobbySelect.prefab",
        "godot_script": "maid_lobby_select_popup_reference_screen.gd",
        "priority": "high",
    },
    {
        "name": "UIFurnitureQuest",
        "prefab": "Assets/Resources/prefabs/ui/UIFurnitureQuest.prefab",
        "godot_script": "furniture_quest_popup_reference_screen.gd",
        "priority": "medium",
    },
    {
        "name": "UIVillageReBuild",
        "prefab": "Assets/Resources/prefabs/ui/UIVillageReBuild.prefab",
        "godot_script": "out_game_reference_screen.gd",
        "priority": "medium",
    },
    {
        "name": "UIMaidLobbyLoading",
        "prefab": "Assets/Resources/prefabs/ui/UIMaidLobbyLoading.prefab",
        "godot_script": "maid_lobby_loading_reference_screen.gd",
        "priority": "medium",
    },
    {
        "name": "UILoading",
        "prefab": "Assets/Resources/prefabs/ui/UILoading.prefab",
        "godot_script": "loading_reference_screen.gd",
        "priority": "baseline",
    },
    {
        "name": "UISceneLoading",
        "prefab": "Assets/Resources/prefabs/ui/UISceneLoading.prefab",
        "godot_script": "scene_loading_reference_screen.gd",
        "priority": "baseline",
    },
    {
        "name": "UIOutGame",
        "prefab": "Assets/Resources/prefabs/ui/UIOutGame.prefab",
        "godot_script": "out_game_reference_screen.gd",
        "priority": "baseline",
    },
]


DOC_RE = re.compile(r"^--- !u!(?P<type>\d+) &(?P<id>-?\d+)\n(?P<body>.*?)(?=^--- !u!|\Z)", re.M | re.S)
NAME_RE = re.compile(r"^\s*m_Name:\s*(?P<value>.*)$", re.M)
ACTIVE_RE = re.compile(r"^\s*m_IsActive:\s*(?P<value>[01])$", re.M)
COMPONENT_RE = re.compile(r"- component: \{fileID: (?P<id>-?\d+)\}")
GAME_OBJECT_RE = re.compile(r"m_GameObject: \{fileID: (?P<id>-?\d+)\}")
FATHER_RE = re.compile(r"m_Father: \{fileID: (?P<id>-?\d+)\}")
CHILDREN_RE = re.compile(r"- \{fileID: (?P<id>-?\d+)\}")
SCRIPT_GUID_RE = re.compile(r"m_Script: \{fileID: \d+, guid: (?P<guid>[0-9a-f]+), type: \d+\}")
SPRITE_RE = re.compile(r"m_Sprite: \{fileID: (?P<file_id>-?\d+), guid: (?P<guid>[0-9a-f]+), type: (?P<type>\d+)\}")
TEXT_RE = re.compile(r"^\s*m_text:\s*(?P<value>.*)$", re.M)
FLOAT_RE = r"-?(?:\d+(?:\.\d+)?|\.\d+)(?:[eE][-+]?\d+)?"

SCRIPT_GUIDS = {
    "3cf5a44414476512e00c3e7a2569a919": "Image",
    "3f96b1d166d19b209697e35b35d65c76": "TextMeshProUGUI",
    "86fe8f3fc59dc06ea6b45a1bbee64682": "GraphicRaycaster",
    "6dfc8ec6aebac6665d9781d273993f23": "CanvasScaler",
    "cedddb77dbd60a683455a2b226c5fd56": "SafeArea",
}

IMPORTANT_NAME_RE = re.compile(
    r"(Btn|Button|Close|Panel|Popup|Inventory|Maid|Lobby|Shop|Request|Bottom|Top|"
    r"Fill|Gauge|Dialog|Text|Image|Icon|List|Scroll|Tab|BG|Root|UI)",
    re.I,
)


def parse_vector(body: str, field: str, dimensions: str = "xy") -> dict:
    parts = [rf"{dim}:\s*(?P<{dim}>{FLOAT_RE})" for dim in dimensions]
    match = re.search(rf"{re.escape(field)}:\s*{{{', '.join(parts)}}}", body)
    if not match:
        return {}
    return {dim: float(match.group(dim)) for dim in dimensions}


def parse_scalar(body: str, field: str) -> float | None:
    match = re.search(rf"^\s*{re.escape(field)}:\s*(?P<value>{FLOAT_RE})$", body, re.M)
    return float(match.group("value")) if match else None


def parse_prefab(path: Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="ignore")
    game_objects = {}
    component_to_go = {}
    components_by_go = defaultdict(list)
    rects = []
    docs = list(DOC_RE.finditer(text))

    for match in docs:
        if match.group("type") != "1":
            continue
        file_id = match.group("id")
        body = match.group("body")
        name_match = NAME_RE.search(body)
        active_match = ACTIVE_RE.search(body)
        component_ids = COMPONENT_RE.findall(body)
        game_objects[file_id] = {
            "file_id": file_id,
            "name": name_match.group("value").strip() if name_match else "",
            "active": active_match.group("value") == "1" if active_match else True,
            "component_ids": component_ids,
        }
        for component_id in component_ids:
            component_to_go[component_id] = file_id

    for match in docs:
        type_id = match.group("type")
        file_id = match.group("id")
        body = match.group("body")
        go_match = GAME_OBJECT_RE.search(body)
        go_id = go_match.group("id") if go_match else component_to_go.get(file_id, "")
        if not go_id:
            continue
        if type_id == "224":
            father_match = FATHER_RE.search(body)
            rects.append(
                {
                    "file_id": file_id,
                    "game_object_id": go_id,
                    "name": game_objects.get(go_id, {}).get("name", ""),
                    "active": game_objects.get(go_id, {}).get("active", True),
                    "parent_rect_id": father_match.group("id") if father_match else "",
                    "children_ids": CHILDREN_RE.findall(body),
                    "anchor_min": parse_vector(body, "m_AnchorMin"),
                    "anchor_max": parse_vector(body, "m_AnchorMax"),
                    "anchored_position": parse_vector(body, "m_AnchoredPosition"),
                    "size_delta": parse_vector(body, "m_SizeDelta"),
                    "pivot": parse_vector(body, "m_Pivot"),
                    "local_position": parse_vector(body, "m_LocalPosition", "xyz"),
                    "local_scale": parse_vector(body, "m_LocalScale", "xyz"),
                }
            )
            components_by_go[go_id].append({"file_id": file_id, "type": "RectTransform"})
        elif type_id == "222":
            components_by_go[go_id].append({"file_id": file_id, "type": "CanvasRenderer"})
        elif type_id == "114":
            guid_match = SCRIPT_GUID_RE.search(body)
            guid = guid_match.group("guid") if guid_match else ""
            component = {
                "file_id": file_id,
                "type": SCRIPT_GUIDS.get(guid, f"MonoBehaviour:{guid[:8]}" if guid else "MonoBehaviour"),
                "script_guid": guid,
                "enabled": parse_scalar(body, "m_Enabled"),
            }
            sprite_match = SPRITE_RE.search(body)
            if sprite_match:
                component["sprite"] = {
                    "file_id": int(sprite_match.group("file_id")),
                    "guid": sprite_match.group("guid"),
                    "type": int(sprite_match.group("type")),
                }
            text_match = TEXT_RE.search(body)
            if text_match:
                component["text"] = text_match.group("value").strip()
            components_by_go[go_id].append(component)

    rect_by_id = {rect["file_id"]: rect for rect in rects}
    for rect in rects:
        rect["node_path"] = build_rect_path(rect, rect_by_id)
        rect["components"] = components_by_go.get(rect["game_object_id"], [])
        rect["component_types"] = [component["type"] for component in rect["components"]]
        rect["layout_kind"] = classify_rect(rect)
        rect["effective_active"] = effective_active(rect, rect_by_id)

    return {
        "path": path.relative_to(PROJECT_ROOT).as_posix(),
        "game_object_count": len(game_objects),
        "rect_transform_count": len(rects),
        "layout_kind_counts": dict(Counter(rect["layout_kind"] for rect in rects)),
        "component_counts": dict(Counter(component["type"] for items in components_by_go.values() for component in items)),
        "rects": rects,
        "key_rects": select_key_rects(rects),
    }


def build_rect_path(rect: dict, rect_by_id: dict) -> str:
    parts = []
    seen = set()
    current = rect
    while current and current.get("file_id") not in seen:
        seen.add(current.get("file_id"))
        parts.append(current.get("name") or current.get("file_id", ""))
        current = rect_by_id.get(current.get("parent_rect_id", ""))
    return "/".join(reversed([part for part in parts if part]))


def effective_active(rect: dict, rect_by_id: dict) -> bool:
    seen = set()
    current = rect
    while current and current.get("file_id") not in seen:
        seen.add(current.get("file_id"))
        if not current.get("active", True):
            return False
        current = rect_by_id.get(current.get("parent_rect_id", ""))
    return True


def classify_rect(rect: dict) -> str:
    anchor_min = rect.get("anchor_min", {})
    anchor_max = rect.get("anchor_max", {})
    size = rect.get("size_delta", {})
    if anchor_min == {"x": 0.0, "y": 0.0} and anchor_max == {"x": 1.0, "y": 1.0}:
        return "full_stretch"
    if anchor_min == anchor_max:
        return "fixed_anchor"
    if abs(size.get("x", 0.0)) >= 700 or abs(size.get("y", 0.0)) >= 700:
        return "large_panel"
    return "mixed"


def select_key_rects(rects: list[dict]) -> list[dict]:
    selected = []
    for rect in rects:
        name = rect.get("name", "")
        path = rect.get("node_path", "")
        components = set(rect.get("component_types", []))
        size = rect.get("size_delta", {})
        if (
            IMPORTANT_NAME_RE.search(name)
            or "Image" in components
            or "TextMeshProUGUI" in components
            or abs(size.get("x", 0.0)) >= 500
            or abs(size.get("y", 0.0)) >= 500
            or path.count("/") <= 2
        ):
            selected.append(rect)
    return selected[:220]


def analyze_godot_script(script_name: str) -> dict:
    path = GODOT_SCRIPT_ROOT / script_name
    if not path.exists():
        return {"path": script_name, "exists": False}
    text = path.read_text(encoding="utf-8", errors="ignore")
    source_paths = sorted(set(re.findall(r'_source_rect\("([^"]+)"', text)))
    source_paths.extend(re.findall(r'_source_or_fallback\("([^"]+)"', text))
    source_paths = sorted(set(source_paths))
    exact_paths = sorted(set(re.findall(r'_rect_by_path\("([^"]+)"', text)))
    suffix_paths = sorted(set(re.findall(r'_rect_by_suffix\("([^"]+)"', text)))
    return {
        "path": f"godot-project/scripts/{script_name}",
        "exists": True,
        "has_set_source": "func set_source" in text,
        "has_rect_transform_helpers": any(token in text for token in ["_rect_by_path", "_source_rect", "_to_preview_rect_world"]),
        "rect2_calls": len(re.findall(r"\bRect2\s*\(", text)),
        "source_rect_paths": source_paths,
        "exact_rect_paths": exact_paths,
        "suffix_rect_paths": suffix_paths,
    }


def score_target(prefab: dict, script: dict) -> dict:
    rect_count = prefab.get("rect_transform_count", 0)
    referenced = len(set(script.get("source_rect_paths", []) + script.get("exact_rect_paths", []) + script.get("suffix_rect_paths", [])))
    uses_source = script.get("has_set_source", False)
    has_helpers = script.get("has_rect_transform_helpers", False)
    if not script.get("exists", False):
        status = "missing_godot_screen"
        score = 0
    elif uses_source and has_helpers and referenced >= 6:
        status = "prefab_first_partial"
        score = min(85, 40 + referenced * 4)
    elif uses_source and has_helpers:
        status = "prefab_reference_shell"
        score = 45
    elif referenced > 0:
        status = "mixed_unwired"
        score = 30
    else:
        status = "manual_shell"
        score = 10
    if rect_count > 200 and status != "prefab_first_partial":
        score = min(score, 25)
    return {
        "status": status,
        "score": score,
        "referenced_rect_paths": referenced,
        "rect_coverage_ratio": round(referenced / rect_count, 4) if rect_count else 0.0,
    }


def compact_prefab(prefab: dict) -> dict:
    return {
        "path": prefab["path"],
        "game_object_count": prefab["game_object_count"],
        "rect_transform_count": prefab["rect_transform_count"],
        "layout_kind_counts": prefab["layout_kind_counts"],
        "component_counts": prefab["component_counts"],
        "rects": [],
        "key_rects": [compact_rect(rect) for rect in prefab["key_rects"]],
    }


def compact_rect(rect: dict) -> dict:
    return {
        "file_id": rect.get("file_id", ""),
        "name": rect.get("name", ""),
        "active": rect.get("active", True),
        "effective_active": rect.get("effective_active", True),
        "parent_rect_id": rect.get("parent_rect_id", ""),
        "node_path": rect.get("node_path", ""),
        "anchor_min": rect.get("anchor_min", {}),
        "anchor_max": rect.get("anchor_max", {}),
        "anchored_position": rect.get("anchored_position", {}),
        "size_delta": rect.get("size_delta", {}),
        "pivot": rect.get("pivot", {}),
        "component_types": rect.get("component_types", []),
        "layout_kind": rect.get("layout_kind", ""),
    }


def fmt_counts(counts: dict) -> str:
    return ", ".join(f"{key}={value}" for key, value in sorted(counts.items())) if counts else "-"


def write_markdown(data: dict) -> None:
    lines = [
        "# Focused UI Prefab Audit",
        "",
        "This audit checks the currently implemented Godot screens against focused AssetRipper prefab evidence.",
        "",
        "## Summary",
        "",
        "| UI | Priority | Status | Score | Prefab Rects | Godot Script | Referenced Rect Paths | Notes |",
        "| --- | --- | --- | ---: | ---: | --- | ---: | --- |",
    ]
    for target in data["targets"]:
        notes = []
        if target["score"]["status"] == "manual_shell":
            notes.append("manual Rect2 shell")
        if target["score"]["rect_coverage_ratio"] < 0.05:
            notes.append("low path coverage")
        if not target["godot_script"].get("has_set_source", False):
            notes.append("no set_source")
        lines.append(
            "| "
            + " | ".join(
                [
                    f"`{target['name']}`",
                    target["priority"],
                    target["score"]["status"],
                    str(target["score"]["score"]),
                    str(target["prefab"].get("rect_transform_count", 0)),
                    f"`{target['godot_script'].get('path', '-')}`",
                    str(target["score"]["referenced_rect_paths"]),
                    ", ".join(notes) if notes else "source driven",
                ]
            )
            + " |"
        )

    lines.extend(
        [
            "",
            "## Target Details",
            "",
        ]
    )
    for target in data["targets"]:
        prefab = target["prefab"]
        script = target["godot_script"]
        lines.extend(
            [
                f"### {target['name']}",
                "",
                f"- Prefab: `{prefab['path']}`",
                f"- Godot: `{script.get('path', '-')}`",
                f"- Status: `{target['score']['status']}`",
                f"- RectTransforms: {prefab.get('rect_transform_count', 0)}",
                f"- Layout kinds: {fmt_counts(prefab.get('layout_kind_counts', {}))}",
                f"- Components: {fmt_counts(prefab.get('component_counts', {}))}",
                f"- Godot has `set_source`: {script.get('has_set_source', False)}",
                f"- Godot has RectTransform helpers: {script.get('has_rect_transform_helpers', False)}",
                f"- Godot hard-coded `Rect2(...)` calls: {script.get('rect2_calls', 0)}",
                "",
                "Key serialized rect paths:",
                "",
            ]
        )
        for rect in prefab.get("key_rects", [])[:25]:
            lines.append(
                f"- `{rect['node_path']}` active={rect.get('effective_active')} size={fmt_vec(rect.get('size_delta', {}))} components={','.join(rect.get('component_types', []))}"
            )
        lines.append("")

    lines.extend(
        [
            "## Required Next Work",
            "",
            "1. Promote every `manual_shell` high-priority screen to `prefab_reference_shell` by loading this focused JSON and using RectTransform conversion helpers.",
            "2. Raise high-priority screens to at least six source-referenced rect paths before marking them as prefab-first partial.",
            "3. Resolve Image sprite GUIDs to concrete asset names for each focused prefab before replacing geometric fallbacks.",
            "4. Keep screenshot captures as regression checks only; they do not count as source placement evidence.",
        ]
    )
    MD_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    MD_OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def fmt_vec(value: dict) -> str:
    if not value:
        return "-"
    return ",".join(f"{key}={val:g}" for key, val in value.items())


def main() -> None:
    targets = []
    missing = []
    for spec in TARGETS:
        prefab_path = PROJECT_ROOT / spec["prefab"]
        if not prefab_path.exists():
            missing.append(str(prefab_path))
            continue
        prefab = parse_prefab(prefab_path)
        script = analyze_godot_script(spec["godot_script"])
        score = score_target(prefab, script)
        targets.append(
            {
                "name": spec["name"],
                "priority": spec["priority"],
                "prefab": compact_prefab(prefab),
                "godot_script": script,
                "score": score,
            }
        )
    if missing:
        for path in missing:
            print(f"Missing input: {path}")
        raise SystemExit(1)

    data = {
        "schema": "focused-ui-layout-reference-v1",
        "source_root": PROJECT_ROOT.as_posix(),
        "targets": targets,
    }
    JSON_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    JSON_OUTPUT.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    write_markdown(data)
    print(f"Wrote {JSON_OUTPUT.relative_to(ROOT)}")
    print(f"Wrote {MD_OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
