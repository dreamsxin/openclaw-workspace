#!/usr/bin/env python3
import json
import re
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROJECT_ROOT = ROOT / "reverse-output/assets/assetripper-main/ExportedProject"
ASSETS_ROOT = PROJECT_ROOT / "Assets"
UI_PREFABS = [
    ASSETS_ROOT / "Resources/prefabs/ui/UIOutGame.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/uiroot/UIOutGame.prefab",
]
ANIMATION_CLIPS = [
    ASSETS_ROOT / "Resources/animation/OutGameUIShow.anim",
    ASSETS_ROOT / "Resources/animation/OutGameUIHide.anim",
    ASSETS_ROOT / "Resources/animation/OutGameUIShow_Lobby.anim",
    ASSETS_ROOT / "Resources/animation/OutGameUIHide_Lobby.anim",
]
JSON_OUTPUT = ROOT / "godot-project/data/uioutgame_layout_reference.json"
MD_OUTPUT = ROOT / "docs/reverse-godot/uioutgame-layout-report.md"


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
KEYFRAME_RE = re.compile(rf"time:\s*(?P<time>{FLOAT_RE}).*?value:\s*(?P<value>{FLOAT_RE})", re.S)
FLOAT_CURVE_RE = re.compile(
    r"- serializedVersion: 2\s+curve:.*?m_Curve:\s*(?P<curve>.*?)"
    r"\n\s+attribute:\s*(?P<attribute>.*?)"
    r"\n\s+path:\s*(?P<path>.*?)"
    r"\n\s+classID:\s*(?P<class_id>\d+)",
    re.S,
)


SCRIPT_GUIDS = {
    "3cf5a44414476512e00c3e7a2569a919": "Image",
    "3f96b1d166d19b209697e35b35d65c76": "TextMeshProUGUI",
    "86fe8f3fc59dc06ea6b45a1bbee64682": "GraphicRaycaster",
    "6dfc8ec6aebac6665d9781d273993f23": "CanvasScaler",
    "cedddb77dbd60a683455a2b226c5fd56": "SafeArea",
}

KEY_NODE_TOKENS = [
    "UIOutGame",
    "FurnitureQuest",
    "UIMaidLD",
    "Dim",
    "SpinePos",
    "Npc_Dialog",
    "Icon_Dialog",
    "Tail",
    "Text_Dialog",
    "InGameBtn",
    "MaidLobbyBtn",
    "Btn_ToInteraction",
    "Btn_ToNormal",
    "UIVillageReBuild",
    "Fillbar",
]


def parse_vector(body: str, field: str, dimensions: str = "xy") -> dict:
    parts = []
    for dim in dimensions:
        parts.append(rf"{dim}:\s*(?P<{dim}>{FLOAT_RE})")
    pattern = rf"{re.escape(field)}:\s*{{{', '.join(parts)}}}"
    match = re.search(pattern, body)
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
    rect_by_go = {}

    docs = list(DOC_RE.finditer(text))
    for match in docs:
        type_id = match.group("type")
        file_id = match.group("id")
        body = match.group("body")
        if type_id != "1":
            continue
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
            rect = {
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
            rects.append(rect)
            rect_by_go[go_id] = rect
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
            font_size = parse_scalar(body, "m_fontSize")
            if font_size is not None:
                component["font_size"] = font_size
            components_by_go[go_id].append(component)

    rect_by_id = {rect["file_id"]: rect for rect in rects}
    for rect in rects:
        rect["node_path"] = build_rect_path(rect, rect_by_id)
        rect["components"] = components_by_go.get(rect["game_object_id"], [])
        rect["component_types"] = [component["type"] for component in rect["components"]]
        rect["layout_kind"] = classify_rect(rect)
        rect["effective_active"] = effective_active(rect, rect_by_id)

    rel = path.relative_to(PROJECT_ROOT).as_posix()
    return {
        "path": rel,
        "rect_transform_count": len(rects),
        "game_object_count": len(game_objects),
        "rects": rects,
        "key_rects": [
            rect for rect in rects if any(token in rect["node_path"] or token == rect["name"] for token in KEY_NODE_TOKENS)
        ],
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


def parse_animation_clip(path: Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="ignore")
    bindings = []
    for match in FLOAT_CURVE_RE.finditer(text):
        curve_body = match.group("curve")
        keyframes = [
            {"time": float(frame.group("time")), "value": float(frame.group("value"))}
            for frame in KEYFRAME_RE.finditer(curve_body)
        ]
        if not keyframes:
            continue
        values = [frame["value"] for frame in keyframes]
        bindings.append(
            {
                "path": match.group("path").strip(),
                "attribute": match.group("attribute").strip(),
                "class_id": int(match.group("class_id")),
                "keyframes": keyframes,
                "first_value": keyframes[0]["value"],
                "last_value": keyframes[-1]["value"],
                "min_value": min(values),
                "max_value": max(values),
            }
        )
    return {
        "path": path.relative_to(PROJECT_ROOT).as_posix(),
        "name": path.stem,
        "binding_count": len(bindings),
        "bindings": bindings,
    }


def fmt_vec(value: dict) -> str:
    if not value:
        return ""
    return ", ".join(f"{key}={val:g}" for key, val in value.items())


def write_markdown(data: dict) -> None:
    lines = [
        "# UIOutGame Layout Evidence",
        "",
        "This report is generated from the AssetRipper Unity Project export and is the current source of truth for the Godot home-screen restoration pass.",
        "",
        "## Inputs",
        "",
    ]
    for prefab in data["prefabs"]:
        lines.append(f"- `{prefab['path']}`")
    for clip in data["animations"]:
        lines.append(f"- `{clip['path']}`")
    lines.extend(
        [
            "",
            "## Generated Outputs",
            "",
            "- `godot-project/data/uioutgame_layout_reference.json`",
            "- `docs/reverse-godot/uioutgame-layout-report.md`",
            "",
            "## Summary",
            "",
        ]
    )
    for prefab in data["prefabs"]:
        lines.append(
            f"- `{prefab['path']}`: {prefab['game_object_count']} GameObjects, {prefab['rect_transform_count']} RectTransforms, {len(prefab['key_rects'])} key RectTransforms."
        )
    for clip in data["animations"]:
        lines.append(f"- `{clip['name']}`: {clip['binding_count']} float animation bindings.")
    lines.extend(
        [
            "",
            "## Key Findings",
            "",
            "- `UIOutGame.prefab` is a small controller/home-layout prefab: the serialized hierarchy contains the maid LD area, dialog controls, entry buttons, furniture quest, and rebuild progress anchors.",
            "- `uiroot/UIOutGame.prefab` is only a root-level mount wrapper, so placement work should primarily follow `Resources/prefabs/ui/UIOutGame.prefab`.",
            "- `Npc_Dialog` and `MaidLobbyBtn` are serialized inactive in the base prefab; their visible state is controlled by runtime logic and animation/state transitions.",
            "- `OutGameUIShow*` and `OutGameUIHide*` animate `InGameBtn`, `MaidLobbyBtn`, `UIMaidLD`, `UILobby`, and `UIGlobal` anchors, so Godot should model static RectTransforms and transition offsets separately.",
            "",
            "## Key RectTransforms",
            "",
            "| Source | Path | Active | AnchorMin | AnchorMax | Pos | Size | Pivot | Components |",
            "| --- | --- | --- | --- | --- | --- | --- | --- | --- |",
        ]
    )
    for prefab in data["prefabs"]:
        for rect in prefab["key_rects"]:
            components = ", ".join(component["type"] for component in rect.get("components", []))
            lines.append(
                "| "
                + " | ".join(
                    [
                        f"`{prefab['path']}`",
                        f"`{rect['node_path']}`",
                        "yes" if rect.get("effective_active") else "no",
                        fmt_vec(rect.get("anchor_min", {})),
                        fmt_vec(rect.get("anchor_max", {})),
                        fmt_vec(rect.get("anchored_position", {})),
                        fmt_vec(rect.get("size_delta", {})),
                        fmt_vec(rect.get("pivot", {})),
                        components,
                    ]
                )
                + " |"
            )

    lines.extend(
        [
            "",
            "## Animation Bindings",
            "",
            "| Clip | Path | Attribute | ClassID | Keyframes | First -> Last | Range |",
            "| --- | --- | --- | ---: | ---: | --- | --- |",
        ]
    )
    for clip in data["animations"]:
        for binding in clip["bindings"]:
            lines.append(
                "| "
                + " | ".join(
                    [
                        f"`{clip['name']}`",
                        f"`{binding['path']}`",
                        f"`{binding['attribute']}`",
                        str(binding["class_id"]),
                        str(len(binding["keyframes"])),
                        f"{binding['first_value']:g} -> {binding['last_value']:g}",
                        f"{binding['min_value']:g}..{binding['max_value']:g}",
                    ]
                )
                + " |"
            )
    lines.extend(
        [
            "",
            "## Restoration Implications",
            "",
            "1. Convert every home-screen hit region from the serialized RectTransform table instead of hand-tuned screenshot positions.",
            "2. Treat inactive serialized nodes as valid layout evidence, but gate visibility through recovered UI state.",
            "3. Apply animation clips as named transition states: normal show/hide and lobby show/hide should not overwrite base layout data.",
            "4. Resolve remaining sprite GUIDs to AssetStudio/AssetRipper sprite names before replacing any geometric fallback.",
            "",
            "## Remaining Unknowns",
            "",
            "- Exact runtime code path that toggles `Npc_Dialog`, `MaidLobbyBtn`, `Btn_ToInteraction`, and `Btn_ToNormal`.",
            "- CanvasScaler reference resolution and SafeArea updates, which are still not serialized in the AssetRipper YAML.",
            "- Sprite GUID-to-name resolution for each Image component in this focused prefab.",
        ]
    )
    MD_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    MD_OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    missing = [path for path in [*UI_PREFABS, *ANIMATION_CLIPS] if not path.exists()]
    if missing:
        for path in missing:
            print(f"Missing input: {path}")
        raise SystemExit(1)

    data = {
        "schema": "uioutgame-layout-reference-v1",
        "source_root": PROJECT_ROOT.as_posix(),
        "prefabs": [parse_prefab(path) for path in UI_PREFABS],
        "animations": [parse_animation_clip(path) for path in ANIMATION_CLIPS],
    }
    JSON_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    JSON_OUTPUT.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    write_markdown(data)
    print(f"Wrote {JSON_OUTPUT.relative_to(ROOT)}")
    print(f"Wrote {MD_OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
