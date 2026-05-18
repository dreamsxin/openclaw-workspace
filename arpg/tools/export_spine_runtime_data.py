#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

from build_godot_resource_demo import decompress_cocos_uuid
from export_cocos_prefab_layout import ROOT, find_native_path, rel


def parse_pair(value: str) -> list[int]:
    left, right = value.split(",", 1)
    return [int(left.strip()), int(right.strip())]


def parse_atlas(atlas_text: str) -> dict:
    pages: dict[str, dict] = {}
    current_page = ""
    current_region = ""
    lines = [line.rstrip() for line in atlas_text.splitlines()]
    index = 0
    while index < len(lines):
        raw = lines[index]
        line = raw.strip()
        index += 1
        if not line:
            current_page = ""
            current_region = ""
            continue
        if ":" not in line:
            if line.lower().endswith((".png", ".jpg", ".jpeg")):
                current_page = line
                pages.setdefault(current_page, {"regions": {}})
            elif current_page:
                current_region = line
                pages[current_page]["regions"].setdefault(current_region, {"page": current_page, "name": current_region})
            continue
        key, value = [part.strip() for part in line.split(":", 1)]
        if current_region:
            region = pages[current_page]["regions"][current_region]
            if key == "rotate":
                region["rotate"] = value.lower() == "true"
            elif key in {"xy", "size", "orig", "offset"}:
                region[key] = parse_pair(value)
            elif key == "index":
                region[key] = int(value)
            else:
                region[key] = value
        elif current_page:
            pages[current_page][key] = value
    regions: dict[str, dict] = {}
    for page_name, page in pages.items():
        for name, region in page.get("regions", {}).items():
            region.setdefault("rotate", False)
            region.setdefault("xy", [0, 0])
            region.setdefault("size", [0, 0])
            region.setdefault("orig", region["size"])
            region.setdefault("offset", [0, 0])
            regions[name] = region
    return {"pages": pages, "regions": regions}


def find_import_path_by_uuid(uuid: str) -> Path:
    file_name = decompress_cocos_uuid(uuid)
    for bundle in ["resources", "main", "internal"]:
        import_path = ROOT / "assets" / bundle / "import" / file_name[:2] / f"{file_name}.json"
        if import_path.exists():
            return import_path
    raise FileNotFoundError(file_name)


def load_skeleton_import(uuid: str) -> tuple[Path, list, dict]:
    import_path = find_import_path_by_uuid(uuid)
    data = json.loads(import_path.read_text(encoding="utf-8"))
    objects = data[5] if len(data) > 5 and isinstance(data[5], list) else []
    for item in objects:
        if isinstance(item, list) and len(item) >= 6 and isinstance(item[1], str) and isinstance(item[4], dict):
            return import_path, data, {
                "name": item[1],
                "atlas_text": item[2],
                "texture_names": item[3],
                "skeleton": item[4],
            }
    raise ValueError(f"No skeleton object in {import_path}")


def export(uuid: str, out_path: Path) -> None:
    import_path, import_data, item = load_skeleton_import(uuid)
    atlas = parse_atlas(item["atlas_text"])
    texture_uuids = import_data[1] if len(import_data) > 1 and isinstance(import_data[1], list) else []
    texture_paths = []
    for texture_uuid in texture_uuids:
        texture_path = find_native_path(texture_uuid)
        if texture_path:
            texture_paths.append(rel(texture_path))
    payload = {
        "uuid": uuid,
        "name": item["name"],
        "import": rel(import_path),
        "texture_names": item["texture_names"],
        "texture_paths": texture_paths,
        "atlas": atlas,
        "skeleton": item["skeleton"],
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(out_path)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--uuid", default="842mNijLZBW6uFp+/RET0n")
    parser.add_argument("--out", default="")
    args = parser.parse_args()
    out = Path(args.out) if args.out else ROOT / "data" / "spine_runtime" / f"{decompress_cocos_uuid(args.uuid)}.json"
    export(args.uuid, out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
