from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
INPUT_PATH = ROOT / "reverse-output/assets/derived/ui_layout/startup_ui_layout_details.json"
OUTPUT_PATH = ROOT / "godot-project/data/ui_layout_reference.json"

FOCUS_SOURCES = [
    "UILoading",
    "UISceneLoading",
    "UIMaidLobbyLoading",
    "UIOutGame",
    "UIInGame",
]

MAX_RECTS_PER_SOURCE = 32

PINNED_NODE_SUFFIXES = {
    "UILoading": [
        "UILoading",
        "Loading_Type/BG_Base",
        "Loading_Type/BG_Base/BG",
        "LogoArea/LogoImage",
        "LoadingBar",
        "LoadingBar/Fill Area",
        "LoadingBar/Fill Area/Image",
        "LoadingBar/Handle Slide Area",
        "LoadingBar/Handle Slide Area/Handle",
        "LoadingBar/Text",
        "Ver",
        "Ver (1)",
    ],
    "UISceneLoading": [
        "UISceneLoading",
        "SceneObjects",
        "SceneObjects/TypeA",
        "SceneObjects/TypeA/SkeletonGraphic (kokomi_Loading)",
        "SceneObjects/TypeNormal",
        "SceneObjects/TypeNormal/BG",
        "SceneObjects/TypeNormal/SpinePos",
    ],
}


def _round_value(value):
    if isinstance(value, float):
        return round(value, 3)
    if isinstance(value, list):
        return [_round_value(item) for item in value]
    if isinstance(value, dict):
        return {key: _round_value(item) for key, item in value.items()}
    return value


def _vec2(value) -> tuple[float, float]:
    if isinstance(value, dict):
        return (float(value.get("x", 0.0) or 0.0), float(value.get("y", 0.0) or 0.0))
    if isinstance(value, list):
        x = float(value[0]) if len(value) > 0 else 0.0
        y = float(value[1]) if len(value) > 1 else 0.0
        return (x, y)
    return (0.0, 0.0)


def _rect_score(rect: dict) -> tuple:
    size = _vec2(rect.get("size_delta", {}))
    width = abs(size[0])
    height = abs(size[1])
    children = int(rect.get("children_count", 0) or 0)
    layout_kind = str(rect.get("layout_kind", ""))
    full_stretch = 1 if layout_kind == "full_stretch" else 0
    return (full_stretch, width * height, children)


def _compact_rect(rect: dict) -> dict:
    return _round_value(
        {
            "node_path": rect.get("node_path", ""),
            "layout_kind": rect.get("layout_kind", ""),
            "anchor_min": rect.get("anchor_min", []),
            "anchor_max": rect.get("anchor_max", []),
            "anchored_position": rect.get("anchored_position", []),
            "size_delta": rect.get("size_delta", []),
            "pivot": rect.get("pivot", []),
            "children_count": rect.get("children_count", 0),
        }
    )


def _infer_reference_resolution(source: dict) -> dict:
    for rect in source.get("key_rects", []):
        if rect.get("node_path") in {"UILoading", "Canvas/UILoading"}:
            size = _vec2(rect.get("size_delta", {}))
            if abs(size[0] - 1080.0) < 0.1 and abs(size[1] - 1920.0) < 0.1:
                return {
                    "width": 1080,
                    "height": 1920,
                    "basis": "UILoading root RectTransform",
                }
    return {
        "width": 1080,
        "height": 1920,
        "basis": "inferred from recovered UILoading root; CanvasScaler still unconfirmed",
    }


def _build_reference(source: dict) -> dict:
    rects = sorted(source.get("key_rects", []), key=_rect_score, reverse=True)
    pinned_suffixes = PINNED_NODE_SUFFIXES.get(str(source.get("name", "")), [])
    pinned_rects = []
    seen_paths = set()
    for suffix in pinned_suffixes:
        for rect in source.get("key_rects", []):
            node_path = str(rect.get("node_path", ""))
            if node_path.endswith(suffix) and node_path not in seen_paths:
                pinned_rects.append(rect)
                seen_paths.add(node_path)
    compact_rects = [_compact_rect(rect) for rect in pinned_rects]
    for rect in rects:
        node_path = str(rect.get("node_path", ""))
        if node_path in seen_paths:
            continue
        compact_rects.append(_compact_rect(rect))
        seen_paths.add(node_path)
        if len(compact_rects) >= MAX_RECTS_PER_SOURCE:
            break
    layout_kinds: dict[str, int] = {}
    for rect in source.get("key_rects", []):
        kind = str(rect.get("layout_kind", "unknown"))
        layout_kinds[kind] = layout_kinds.get(kind, 0) + 1
    return {
        "name": source.get("name", ""),
        "source_type": source.get("type", ""),
        "source_path": source.get("path", ""),
        "rect_transform_count": source.get("rect_transform_count", 0),
        "reference_resolution": _infer_reference_resolution(source),
        "layout_kind_counts": dict(sorted(layout_kinds.items())),
        "key_rects": compact_rects,
    }


def main() -> None:
    payload = json.loads(INPUT_PATH.read_text(encoding="utf-8"))
    sources = payload.get("focus_sources", []) if isinstance(payload, dict) else payload
    selected = [source for source in sources if source.get("name") in FOCUS_SOURCES]
    selected.sort(key=lambda source: FOCUS_SOURCES.index(source.get("name")))

    output = {
        "source": str(INPUT_PATH.relative_to(ROOT)).replace("\\", "/"),
        "generated_for": "godot-project",
        "notes": [
            "Coordinates are Unity RectTransform values, not final Godot Control offsets.",
            "Use reference_resolution as the base portrait-space design reference when rebuilding screens.",
            "CanvasScaler and SafeArea runtime behavior still need IL2CPP confirmation before exact responsive layout.",
        ],
        "sources": [_build_reference(source) for source in selected],
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH.relative_to(ROOT)} ({len(output['sources'])} sources)")


if __name__ == "__main__":
    main()
