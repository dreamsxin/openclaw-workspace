#!/usr/bin/env python3
import csv
import json
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROJECT_ROOT = ROOT / "reverse-output/assets/assetripper-main/ExportedProject"
ASSETS_ROOT = PROJECT_ROOT / "Assets"
UI_ROOT = ASSETS_ROOT / "Resources/prefabs/ui"
SCENE_ROOT = ASSETS_ROOT / "Scenes"
OUT_DIR = ROOT / "reverse-output/assets/derived/ui_layout"
CSV_OUTPUT = OUT_DIR / "ui_prefab_layout_inventory.csv"
JSON_OUTPUT = OUT_DIR / "ui_prefab_layout_inventory.json"
STARTUP_OUTPUT = OUT_DIR / "startup_ui_candidates.json"
STARTUP_DETAIL_JSON = OUT_DIR / "startup_ui_layout_details.json"
STARTUP_DETAIL_CSV = OUT_DIR / "startup_ui_layout_details.csv"
MD_OUTPUT = ROOT / "docs/reverse-godot/ui-layout-analysis.md"


DOC_RE = re.compile(r"^--- !u!(?P<type>\d+) &(?P<id>-?\d+)\n(?P<body>.*?)(?=^--- !u!|\Z)", re.M | re.S)
NAME_RE = re.compile(r"^\s*m_Name:\s*(?P<value>.*)$", re.M)
COMPONENT_RE = re.compile(r"- component: \{fileID: (?P<id>-?\d+)\}")
GAME_OBJECT_RE = re.compile(r"m_GameObject: \{fileID: (?P<id>-?\d+)\}")
FATHER_RE = re.compile(r"m_Father: \{fileID: (?P<id>-?\d+)\}")
VEC_RE = re.compile(r"{x: (?P<x>-?[0-9.]+), y: (?P<y>-?[0-9.]+)}")

STARTUP_KEYWORDS = [
    "loading",
    "reload",
    "login",
    "lobby",
    "outgame",
    "manager",
    "scene",
    "story",
    "intro",
]

FOCUS_LAYOUT_NAMES = {
    "Reload",
    "Game",
    "UIManager",
    "UILoading",
    "UISceneLoading",
    "UIMaidLobbyLoading",
    "UIOutGame",
    "UIInGame",
}


def parse_vector(body: str, field: str) -> dict:
    match = re.search(rf"{re.escape(field)}:\s*{{x: (?P<x>-?[0-9.]+), y: (?P<y>-?[0-9.]+)}}", body)
    if not match:
        return {}
    return {"x": float(match.group("x")), "y": float(match.group("y"))}


def classify_prefab(path: Path) -> str:
    rel = path.relative_to(UI_ROOT).as_posix() if path.is_relative_to(UI_ROOT) else path.name
    parts = rel.split("/")
    name = path.stem.lower()
    if "popup" in parts or name.startswith("uipopup"):
        return "popup"
    if "listitem" in parts or "listitem" in name:
        return "listitem"
    if "button" in parts or name.startswith("btn_"):
        return "button"
    if "banner" in parts or "banner" in name:
        return "banner"
    if "tutorial" in parts or "tutorial" in name:
        return "tutorial"
    if "ingame" in parts or "ingame" in name:
        return "ingame"
    if "app" in parts or name.startswith("uiapp_"):
        return "app"
    if name.startswith("ui"):
        return "screen_or_manager"
    return "misc"


def parse_prefab(path: Path) -> dict:
    parsed = parse_layout_file(path)
    rel = path.relative_to(PROJECT_ROOT).as_posix()
    rects = parsed["rects"]
    large_rects = [
        rect
        for rect in rects
        if abs(rect.get("size_delta", {}).get("x", 0)) >= 700
        or abs(rect.get("size_delta", {}).get("y", 0)) >= 700
    ]
    root_rects = [rect for rect in rects if rect.get("parent_rect_id") in ("", "0")]
    names = [rect["name"] for rect in rects if rect.get("name")]
    lower_blob = " ".join([path.stem, *names]).lower()
    return {
        "path": rel,
        "name": path.stem,
        "category": classify_prefab(path),
        "rect_transform_count": len(rects),
        "game_object_count": len(parsed["game_objects"]),
        "root_rects": root_rects[:8],
        "large_rects": large_rects[:12],
        "sample_node_names": names[:30],
        "startup_score": sum(1 for keyword in STARTUP_KEYWORDS if keyword in lower_blob),
        "startup_keywords": [keyword for keyword in STARTUP_KEYWORDS if keyword in lower_blob],
    }


def parse_layout_file(path: Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="ignore")
    game_objects = {}
    component_to_go = {}
    rects = []
    for match in DOC_RE.finditer(text):
        type_id = match.group("type")
        file_id = match.group("id")
        body = match.group("body")
        if type_id == "1":
            name_match = NAME_RE.search(body)
            name = name_match.group("value").strip() if name_match else ""
            component_ids = COMPONENT_RE.findall(body)
            game_objects[file_id] = {"name": name, "components": component_ids}
            for component_id in component_ids:
                component_to_go[component_id] = file_id
        elif type_id == "224":
            go_match = GAME_OBJECT_RE.search(body)
            father_match = FATHER_RE.search(body)
            go_id = go_match.group("id") if go_match else component_to_go.get(file_id, "")
            rects.append(
                {
                    "file_id": file_id,
                    "game_object_id": go_id,
                    "name": "",
                    "parent_rect_id": father_match.group("id") if father_match else "",
                    "anchor_min": parse_vector(body, "m_AnchorMin"),
                    "anchor_max": parse_vector(body, "m_AnchorMax"),
                    "anchored_position": parse_vector(body, "m_AnchoredPosition"),
                    "size_delta": parse_vector(body, "m_SizeDelta"),
                    "pivot": parse_vector(body, "m_Pivot"),
                }
            )
    for rect in rects:
        rect["name"] = game_objects.get(rect["game_object_id"], {}).get("name", "")
    rect_by_id = {rect["file_id"]: rect for rect in rects}
    children_by_parent = defaultdict(list)
    for rect in rects:
        children_by_parent[rect.get("parent_rect_id", "")].append(rect["file_id"])
    for rect in rects:
        rect["children_count"] = len(children_by_parent.get(rect["file_id"], []))
        rect["node_path"] = rect_path(rect, rect_by_id)
        rect["layout_kind"] = rect_layout_kind(rect)
    return {
        "game_objects": game_objects,
        "rects": rects,
    }


def rect_path(rect: dict, rect_by_id: dict[str, dict]) -> str:
    names = []
    seen = set()
    current = rect
    while current and current.get("file_id") not in seen:
        seen.add(current.get("file_id"))
        names.append(current.get("name") or current.get("file_id", ""))
        parent_id = current.get("parent_rect_id", "")
        current = rect_by_id.get(parent_id)
    return "/".join(reversed([name for name in names if name]))


def rect_layout_kind(rect: dict) -> str:
    anchor_min = rect.get("anchor_min", {})
    anchor_max = rect.get("anchor_max", {})
    size = rect.get("size_delta", {})
    if anchor_min == {"x": 0.0, "y": 0.0} and anchor_max == {"x": 1.0, "y": 1.0}:
        return "full_stretch"
    if anchor_min == anchor_max:
        return "fixed_anchor"
    if abs(size.get("x", 0)) >= 700 or abs(size.get("y", 0)) >= 700:
        return "large_panel"
    return "mixed"


def scene_summary(path: Path) -> dict:
    parsed = parse_layout_file(path)
    names = [rect["name"] for rect in parsed["rects"] if rect.get("name")]
    rel = path.relative_to(PROJECT_ROOT).as_posix()
    lower_blob = " ".join([path.stem, *names[:200]]).lower()
    return {
        "path": rel,
        "name": path.stem,
        "rect_transform_count": len(parsed["rects"]),
        "sample_node_names": [name.strip() for name in names[:40]],
        "startup_score": sum(1 for keyword in STARTUP_KEYWORDS if keyword in lower_blob),
        "startup_keywords": [keyword for keyword in STARTUP_KEYWORDS if keyword in lower_blob],
    }


def write_csv(rows: list[dict]) -> None:
    with CSV_OUTPUT.open("w", encoding="utf-8", newline="") as fh:
        fieldnames = [
            "path",
            "name",
            "category",
            "rect_transform_count",
            "game_object_count",
            "startup_score",
            "startup_keywords",
            "sample_node_names",
            "large_rect_count",
        ]
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "path": row["path"],
                    "name": row["name"],
                    "category": row["category"],
                    "rect_transform_count": row["rect_transform_count"],
                    "game_object_count": row["game_object_count"],
                    "startup_score": row["startup_score"],
                    "startup_keywords": "|".join(row["startup_keywords"]),
                    "sample_node_names": "|".join(row["sample_node_names"][:12]),
                    "large_rect_count": len(row["large_rects"]),
                }
            )


def write_markdown(rows: list[dict], scenes: list[dict], startup: list[dict]) -> None:
    category_counts = Counter(row["category"] for row in rows)
    rect_total = sum(row["rect_transform_count"] for row in rows)
    top_rects = sorted(rows, key=lambda item: item["rect_transform_count"], reverse=True)[:20]
    lines = [
        "# UI Layout Analysis",
        "",
        "This document records the first-pass static UI layout inventory extracted from the AssetRipper Unity Project export.",
        "",
        "## Inputs",
        "",
        "- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/**/*.prefab`",
        "- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Scenes/*.unity`",
        "",
        "## Generated Outputs",
        "",
        "- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.csv`",
        "- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.json`",
        "- `reverse-output/assets/derived/ui_layout/startup_ui_candidates.json`",
        "- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.csv`",
        "- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.json`",
        "",
        "## Summary",
        "",
        f"- UI prefab files scanned: {len(rows)}",
        f"- Scene files scanned: {len(scenes)}",
        f"- RectTransform records in UI prefabs: {rect_total}",
        f"- Categories: {', '.join(f'{key}={value}' for key, value in sorted(category_counts.items()))}",
        "",
        "## Startup Candidates",
        "",
        "| Name | Type | Path | RectTransforms | Keywords |",
        "| --- | --- | --- | ---: | --- |",
    ]
    for item in startup[:25]:
        lines.append(
            f"| `{item['name']}` | {item.get('type', 'prefab')} | `{item['path']}` | "
            f"{item.get('rect_transform_count', 0)} | {', '.join(item.get('startup_keywords', []))} |"
        )
    focus_names = ["Reload", "Game", "UIManager", "UILoading", "UISceneLoading", "UIMaidLobbyLoading", "UIOutGame", "UIInGame"]
    focus_rows = [item for item in startup if item["name"] in focus_names]
    lines.extend(
        [
            "",
            "## Focus Startup Layout Sources",
            "",
            "| Name | Type | RectTransforms | Path |",
            "| --- | --- | ---: | --- |",
        ]
    )
    seen_focus = set()
    for item in focus_rows:
        key = (item["type"], item["path"])
        if key in seen_focus:
            continue
        seen_focus.add(key)
        lines.append(
            f"| `{item['name']}` | {item.get('type', 'prefab')} | {item.get('rect_transform_count', 0)} | `{item['path']}` |"
        )
    lines.extend(
        [
            "",
            "Key recovered layout facts from `startup_ui_layout_details.*`:",
            "",
            "- `UILoading` root is a fixed 1080 x 1920 RectTransform.",
            "- `Reload.unity` contains `Canvas/UILoading` with the same large loading background structure.",
            "- `UISceneLoading` uses full-stretch root layout plus 2000 x 2000 centered Spine loading character nodes.",
            "- `UIOutGame` and `UIInGame` use full-stretch roots; their child controls are primarily fixed-anchor panels/buttons.",
            "- `UIManager.prefab` and `Game.unity` embed the large startup/UI root tree rather than only referencing external prefabs.",
        ]
    )
    lines.extend(
        [
            "",
            "## Largest UI Prefabs",
            "",
            "| Name | Category | RectTransforms | Large Rects | Path |",
            "| --- | --- | ---: | ---: | --- |",
        ]
    )
    for row in top_rects:
        lines.append(
            f"| `{row['name']}` | {row['category']} | {row['rect_transform_count']} | "
            f"{len(row['large_rects'])} | `{row['path']}` |"
        )
    lines.extend(
        [
            "",
            "## Current Limits",
            "",
            "- This pass reads static serialized prefab and scene YAML only.",
            "- Runtime-instantiated UI, localization-driven text sizing, safe-area adjustment, and code-driven show/hide states still require IL2CPP/native flow analysis.",
            "- CanvasScaler reference resolution was not confirmed in this pass; the next step is to inspect `UIRoot`, `UICanvasManager`, and any serialized Canvas scaler components or runtime setup code.",
            "",
            "## Next Steps",
            "",
            "1. Map startup flow through `ReloadManager`, `LoginMenuHandler`, `UIRoot`, `UIManager`, `UIPopupManager`, and `UISceneLoading`.",
            "2. Expand the extractor to reconstruct parent/child paths for selected high-value screens.",
            "3. Build Godot reference layouts for `UILoading`, `UISceneLoading`, `UILobbyUIOn`, `UIOutGame`, and the first in-game HUD.",
        ]
    )
    MD_OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def focus_layout_sources(rows: list[dict], scenes: list[dict]) -> list[dict]:
    sources = []
    for row in rows:
        if row["name"] in FOCUS_LAYOUT_NAMES:
            sources.append({"type": "prefab", **row})
    for scene in scenes:
        if scene["name"] in FOCUS_LAYOUT_NAMES:
            sources.append({"type": "scene", **scene})
    return sorted(sources, key=lambda item: (item["type"], item["name"], item["path"]))


def summarize_focus_rects(path: Path, limit: int = 120) -> list[dict]:
    parsed = parse_layout_file(path)
    rects = parsed["rects"]

    def rank(rect: dict) -> tuple:
        size = rect.get("size_delta", {})
        area = abs(size.get("x", 0) * size.get("y", 0))
        important_name = any(
            token in rect.get("name", "").lower()
            for token in ["loading", "lobby", "outgame", "ingame", "canvas", "bg", "dim", "button", "title"]
        )
        return (1 if rect.get("parent_rect_id") in ("", "0") else 0, 1 if important_name else 0, area, rect["children_count"])

    selected = sorted(rects, key=rank, reverse=True)[:limit]
    return [
        {
            "node_path": rect["node_path"],
            "name": rect["name"],
            "layout_kind": rect["layout_kind"],
            "anchor_min": rect["anchor_min"],
            "anchor_max": rect["anchor_max"],
            "anchored_position": rect["anchored_position"],
            "size_delta": rect["size_delta"],
            "pivot": rect["pivot"],
            "children_count": rect["children_count"],
        }
        for rect in selected
    ]


def write_startup_details(rows: list[dict], scenes: list[dict]) -> None:
    sources = focus_layout_sources(rows, scenes)
    details = []
    for source in sources:
        source_path = PROJECT_ROOT / source["path"]
        if not source_path.exists():
            continue
        details.append(
            {
                "type": source["type"],
                "name": source["name"],
                "path": source["path"],
                "rect_transform_count": source["rect_transform_count"],
                "sample_node_names": source.get("sample_node_names", [])[:30],
                "key_rects": summarize_focus_rects(source_path),
            }
        )
    STARTUP_DETAIL_JSON.write_text(json.dumps(details, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with STARTUP_DETAIL_CSV.open("w", encoding="utf-8", newline="") as fh:
        fieldnames = [
            "source_type",
            "source_name",
            "source_path",
            "node_path",
            "layout_kind",
            "anchor_min",
            "anchor_max",
            "anchored_position",
            "size_delta",
            "children_count",
        ]
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for detail in details:
            for rect in detail["key_rects"]:
                writer.writerow(
                    {
                        "source_type": detail["type"],
                        "source_name": detail["name"],
                        "source_path": detail["path"],
                        "node_path": rect["node_path"],
                        "layout_kind": rect["layout_kind"],
                        "anchor_min": json.dumps(rect["anchor_min"], ensure_ascii=False),
                        "anchor_max": json.dumps(rect["anchor_max"], ensure_ascii=False),
                        "anchored_position": json.dumps(rect["anchored_position"], ensure_ascii=False),
                        "size_delta": json.dumps(rect["size_delta"], ensure_ascii=False),
                        "children_count": rect["children_count"],
                    }
                )
    return details


def main() -> None:
    if not UI_ROOT.exists():
        raise FileNotFoundError(UI_ROOT)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = [parse_prefab(path) for path in sorted(UI_ROOT.rglob("*.prefab"))]
    scenes = [scene_summary(path) for path in sorted(SCENE_ROOT.glob("*.unity"))] if SCENE_ROOT.exists() else []
    startup_prefabs = [
        {"type": "prefab", **row}
        for row in rows
        if row["startup_score"] > 0 or row["name"] in {"UILoading", "UISceneLoading", "UIManager", "UIOutGame"}
    ]
    startup_scenes = [{"type": "scene", **scene} for scene in scenes if scene["startup_score"] > 0]
    startup = sorted(
        [*startup_prefabs, *startup_scenes],
        key=lambda item: (item.get("startup_score", 0), item.get("rect_transform_count", 0)),
        reverse=True,
    )
    JSON_OUTPUT.write_text(
        json.dumps({"prefabs": rows, "scenes": scenes}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    STARTUP_OUTPUT.write_text(json.dumps(startup, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_csv(rows)
    startup_details = write_startup_details(rows, scenes)
    write_markdown(rows, scenes, startup)
    print(f"ui_prefabs={len(rows)}")
    print(f"scenes={len(scenes)}")
    print(f"rect_transforms={sum(row['rect_transform_count'] for row in rows)}")
    print(f"startup_detail_sources={len(startup_details)}")
    print(CSV_OUTPUT)
    print(MD_OUTPUT)


if __name__ == "__main__":
    main()
