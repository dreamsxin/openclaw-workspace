#!/usr/bin/env python3
import csv
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROJECT_ROOT = ROOT / "reverse-output/assets/assetripper-main/ExportedProject"
ASSETS_ROOT = PROJECT_ROOT / "Assets"
OUT_DIR = ROOT / "reverse-output/assets/derived/ui_layout"
JSON_OUTPUT = OUT_DIR / "canvas_layout_inventory.json"
CSV_OUTPUT = OUT_DIR / "canvas_layout_inventory.csv"

DOC_RE = re.compile(r"^--- !u!(?P<type>\d+) &(?P<id>-?\d+)\n(?P<body>.*?)(?=^--- !u!|\Z)", re.M | re.S)
NAME_RE = re.compile(r"^\s*m_Name:\s*(?P<value>.*)$", re.M)
COMPONENT_RE = re.compile(r"- component: \{fileID: (?P<id>-?\d+)\}")
GAME_OBJECT_RE = re.compile(r"m_GameObject: \{fileID: (?P<id>-?\d+)\}")
FATHER_RE = re.compile(r"m_Father: \{fileID: (?P<id>-?\d+)\}")
SCRIPT_RE = re.compile(r"m_Script: \{fileID: \d+, guid: (?P<guid>[0-9a-f]+), type: \d+\}")

SCRIPT_GUIDS = {
    "6dfc8ec6aebac6665d9781d273993f23": "CanvasScaler",
    "86fe8f3fc59dc06ea6b45a1bbee64682": "GraphicRaycaster",
    "cedddb77dbd60a683455a2b226c5fd56": "SafeArea",
    "3cf5a44414476512e00c3e7a2569a919": "Image",
    "3f96b1d166d19b209697e35b35d65c76": "TextMeshProUGUI",
    "ab0e0bb351e7be9b1ef3f8a3fe9811f4": "UIInGameBG",
}

TARGETS = [
    ASSETS_ROOT / "Resources/prefabs/ui/BGCanvas.prefab",
    ASSETS_ROOT / "Scenes/Reload.unity",
    ASSETS_ROOT / "Scenes/Game.unity",
    ASSETS_ROOT / "Resources/prefabs/ui/UIManager.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/UILoading.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/UISceneLoading.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/UIMaidLobbyLoading.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/UIOutGame.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/uiroot/UIOutGame.prefab",
    ASSETS_ROOT / "Resources/prefabs/ui/uiroot/UIInGame.prefab",
]

CANVAS_FIELDS = [
    "m_RenderMode",
    "m_PlaneDistance",
    "m_PixelPerfect",
    "m_ReceivesEvents",
    "m_OverrideSorting",
    "m_OverridePixelPerfect",
    "m_AdditionalShaderChannelsFlag",
    "m_UpdateRectTransformForStandalone",
    "m_SortingLayerID",
    "m_SortingOrder",
    "m_TargetDisplay",
]

CANVAS_SCALER_FIELDS = [
    "m_UiScaleMode",
    "m_ReferencePixelsPerUnit",
    "m_ScaleFactor",
    "m_ReferenceResolution",
    "m_ScreenMatchMode",
    "m_MatchWidthOrHeight",
    "m_PhysicalUnit",
    "m_FallbackScreenDPI",
    "m_DefaultSpriteDPI",
    "m_DynamicPixelsPerUnit",
]


def scalar(body: str, field: str) -> str:
    match = re.search(rf"^\s*{re.escape(field)}:\s*(?P<value>.*)$", body, re.M)
    return match.group("value").strip() if match else ""


def vector(body: str, field: str) -> dict:
    value = scalar(body, field)
    match = re.match(r"\{x: (?P<x>-?[0-9.]+), y: (?P<y>-?[0-9.]+)\}", value)
    if not match:
        return {}
    return {"x": float(match.group("x")), "y": float(match.group("y"))}


def compact_fields(body: str, fields: list[str]) -> dict:
    values = {}
    for field in fields:
        value = scalar(body, field)
        if value:
            values[field] = value
    return values


def parse_yaml_file(path: Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="ignore")
    game_objects = {}
    component_to_go = {}
    rects = {}
    components = []

    for match in DOC_RE.finditer(text):
        type_id = match.group("type")
        file_id = match.group("id")
        body = match.group("body")
        if type_id == "1":
            name_match = NAME_RE.search(body)
            component_ids = COMPONENT_RE.findall(body)
            game_objects[file_id] = {
                "file_id": file_id,
                "name": name_match.group("value").strip() if name_match else "",
                "components": component_ids,
            }
            for component_id in component_ids:
                component_to_go[component_id] = file_id
        elif type_id == "224":
            go_id = scalar_file_id(body, "m_GameObject")
            rects[file_id] = {
                "file_id": file_id,
                "game_object_id": go_id,
                "name": "",
                "parent_rect_id": scalar_file_id(body, "m_Father"),
                "anchor_min": vector(body, "m_AnchorMin"),
                "anchor_max": vector(body, "m_AnchorMax"),
                "anchored_position": vector(body, "m_AnchoredPosition"),
                "size_delta": vector(body, "m_SizeDelta"),
                "pivot": vector(body, "m_Pivot"),
            }
        elif type_id in {"223", "114"}:
            go_match = GAME_OBJECT_RE.search(body)
            script_match = SCRIPT_RE.search(body)
            guid = script_match.group("guid") if script_match else ""
            components.append(
                {
                    "file_id": file_id,
                    "type_id": type_id,
                    "unity_type": "Canvas" if type_id == "223" else "MonoBehaviour",
                    "game_object_id": go_match.group("id") if go_match else component_to_go.get(file_id, ""),
                    "script_guid": guid,
                    "script_name": SCRIPT_GUIDS.get(guid, ""),
                    "body": body,
                }
            )

    for rect in rects.values():
        rect["name"] = game_objects.get(rect["game_object_id"], {}).get("name", "")
    rect_by_go = {rect["game_object_id"]: rect for rect in rects.values()}
    for rect in rects.values():
        rect["node_path"] = rect_path(rect, rects)

    return {
        "game_objects": game_objects,
        "rects": rects,
        "rect_by_go": rect_by_go,
        "components": components,
    }


def scalar_file_id(body: str, field: str) -> str:
    if field == "m_Father":
        match = FATHER_RE.search(body)
    else:
        match = re.search(rf"{re.escape(field)}: \{{fileID: (?P<id>-?\d+)\}}", body)
    return match.group("id") if match else ""


def rect_path(rect: dict, rects: dict[str, dict]) -> str:
    names = []
    seen = set()
    current = rect
    while current and current.get("file_id") not in seen:
        seen.add(current.get("file_id"))
        names.append(current.get("name") or current.get("file_id", ""))
        current = rects.get(current.get("parent_rect_id", ""))
    return "/".join(reversed([name for name in names if name]))


def component_node(component: dict, parsed: dict) -> dict:
    rect = parsed["rect_by_go"].get(component.get("game_object_id", ""), {})
    go = parsed["game_objects"].get(component.get("game_object_id", ""), {})
    return {
        "game_object_id": component.get("game_object_id", ""),
        "game_object_name": go.get("name", ""),
        "node_path": rect.get("node_path") or go.get("name", ""),
        "rect": {
            "anchor_min": rect.get("anchor_min", {}),
            "anchor_max": rect.get("anchor_max", {}),
            "anchored_position": rect.get("anchored_position", {}),
            "size_delta": rect.get("size_delta", {}),
            "pivot": rect.get("pivot", {}),
        },
    }


def summarize_file(path: Path) -> dict:
    parsed = parse_yaml_file(path)
    rel_path = path.relative_to(PROJECT_ROOT).as_posix()
    canvases = []
    canvas_scalers = []
    safe_areas = []
    script_components = []

    for component in parsed["components"]:
        node = component_node(component, parsed)
        if component["type_id"] == "223":
            canvases.append(
                {
                    **node,
                    "component_id": component["file_id"],
                    "fields": compact_fields(component["body"], CANVAS_FIELDS),
                }
            )
        elif component["script_name"] == "CanvasScaler":
            fields = compact_fields(component["body"], CANVAS_SCALER_FIELDS)
            canvas_scalers.append(
                {
                    **node,
                    "component_id": component["file_id"],
                    "script_guid": component["script_guid"],
                    "serialized_fields_present": bool(fields),
                    "fields": fields,
                }
            )
        elif component["script_name"] == "SafeArea":
            safe_areas.append(
                {
                    **node,
                    "component_id": component["file_id"],
                    "script_guid": component["script_guid"],
                }
            )
        if component["script_guid"]:
            script_components.append(
                {
                    "component_id": component["file_id"],
                    "node_path": node["node_path"],
                    "game_object_name": node["game_object_name"],
                    "script_guid": component["script_guid"],
                    "script_name": component["script_name"] or "unknown",
                }
            )

    named_safe_rects = [
        {
            "node_path": rect["node_path"],
            "game_object_id": rect["game_object_id"],
            "rect": {
                "anchor_min": rect["anchor_min"],
                "anchor_max": rect["anchor_max"],
                "anchored_position": rect["anchored_position"],
                "size_delta": rect["size_delta"],
                "pivot": rect["pivot"],
            },
        }
        for rect in parsed["rects"].values()
        if "safearea" in rect.get("name", "").lower()
    ]

    return {
        "path": rel_path,
        "exists": True,
        "canvas_count": len(canvases),
        "canvas_scaler_count": len(canvas_scalers),
        "safe_area_component_count": len(safe_areas),
        "safe_area_named_rect_count": len(named_safe_rects),
        "canvases": canvases,
        "canvas_scalers": canvas_scalers,
        "safe_area_components": safe_areas,
        "safe_area_named_rects": named_safe_rects,
        "script_component_sample": script_components[:80],
    }


def write_csv(rows: list[dict]) -> None:
    with CSV_OUTPUT.open("w", encoding="utf-8", newline="") as fh:
        fieldnames = [
            "path",
            "kind",
            "node_path",
            "component_id",
            "game_object_name",
            "script_guid",
            "serialized_fields_present",
            "fields",
            "rect",
        ]
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            for canvas in row.get("canvases", []):
                writer.writerow(flat_row(row["path"], "Canvas", canvas))
            for scaler in row.get("canvas_scalers", []):
                writer.writerow(flat_row(row["path"], "CanvasScaler", scaler))
            for safe_area in row.get("safe_area_components", []):
                writer.writerow(flat_row(row["path"], "SafeAreaComponent", safe_area))
            for safe_rect in row.get("safe_area_named_rects", []):
                writer.writerow(flat_row(row["path"], "SafeAreaRect", safe_rect))


def flat_row(path: str, kind: str, item: dict) -> dict:
    return {
        "path": path,
        "kind": kind,
        "node_path": item.get("node_path", ""),
        "component_id": item.get("component_id", ""),
        "game_object_name": item.get("game_object_name", ""),
        "script_guid": item.get("script_guid", ""),
        "serialized_fields_present": item.get("serialized_fields_present", ""),
        "fields": json.dumps(item.get("fields", {}), ensure_ascii=False, sort_keys=True),
        "rect": json.dumps(item.get("rect", {}), ensure_ascii=False, sort_keys=True),
    }


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = []
    missing = []
    for path in TARGETS:
        if path.exists():
            rows.append(summarize_file(path))
        else:
            missing.append(path.relative_to(PROJECT_ROOT).as_posix())

    summary = {
        "source_root": PROJECT_ROOT.as_posix(),
        "targets": [path.relative_to(PROJECT_ROOT).as_posix() for path in TARGETS],
        "missing_targets": missing,
        "file_count": len(rows),
        "canvas_count": sum(row["canvas_count"] for row in rows),
        "canvas_scaler_count": sum(row["canvas_scaler_count"] for row in rows),
        "canvas_scalers_with_serialized_fields": sum(
            1
            for row in rows
            for scaler in row["canvas_scalers"]
            if scaler["serialized_fields_present"]
        ),
        "safe_area_component_count": sum(row["safe_area_component_count"] for row in rows),
        "safe_area_named_rect_count": sum(row["safe_area_named_rect_count"] for row in rows),
        "known_script_guids": SCRIPT_GUIDS,
        "files": rows,
    }

    JSON_OUTPUT.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    write_csv(rows)

    print(f"Wrote {JSON_OUTPUT.relative_to(ROOT)}")
    print(f"Wrote {CSV_OUTPUT.relative_to(ROOT)}")
    print(
        "Summary: "
        f"{summary['canvas_count']} Canvas, "
        f"{summary['canvas_scaler_count']} CanvasScaler, "
        f"{summary['canvas_scalers_with_serialized_fields']} CanvasScaler with serialized fields, "
        f"{summary['safe_area_component_count']} SafeArea components, "
        f"{summary['safe_area_named_rect_count']} SafeArea rects"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
