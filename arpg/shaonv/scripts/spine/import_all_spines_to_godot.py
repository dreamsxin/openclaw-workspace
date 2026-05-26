#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Copy exported Spine preview files into the Godot MVP asset tree.

This reads ``tmp/all-spine-export/spine-preview-files.csv`` and creates one
Godot-friendly folder per skeleton under ``assets/spine/all_export``.
"""

from __future__ import annotations

import csv
import json
import re
import shutil
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
EXPORT_ROOT = REPO_ROOT / "tmp/all-spine-export"
PREVIEW_CSV = EXPORT_ROOT / "spine-preview-files.csv"
GODOT_ROOT = REPO_ROOT / "standalone/godot-mvp"
TARGET_ROOT = GODOT_ROOT / "assets/spine/all_export"
INDEX_PATH = GODOT_ROOT / "assets/spine/all_spines_list.json"


def safe_key(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_.-]+", "_", value).strip("._-")
    return cleaned or "spine"


def rel_after_spine(source_dir: str) -> str:
    marker = "Assets/Game/RawAssets/Spine/"
    if source_dir.startswith(marker):
        return source_dir[len(marker) :]
    return source_dir


def skeleton_base(path: str) -> str:
    name = Path(path).name
    suffix = ".skel.bytes"
    return name[: -len(suffix)] if name.endswith(suffix) else Path(name).stem


def unique_key(row: dict[str, str], used: set[str]) -> str:
    relative_dir = rel_after_spine(row["sourceDir"]).replace("\\", "/")
    parts = [safe_key(part) for part in relative_dir.split("/") if part]
    base = safe_key(skeleton_base(row["skeleton"]))
    if not parts or parts[-1].lower() != base.lower():
        parts.append(base)
    candidate = "__".join(parts)
    key = candidate
    index = 2
    while key.lower() in used:
        key = f"{candidate}__{index}"
        index += 1
    used.add(key.lower())
    return key


def copy_file(export_rel: str, destination: Path) -> None:
    source = EXPORT_ROOT / export_rel
    if not source.exists():
        raise FileNotFoundError(source)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def main() -> int:
    if not PREVIEW_CSV.exists():
        raise FileNotFoundError(PREVIEW_CSV)

    rows = list(csv.DictReader(PREVIEW_CSV.open("r", encoding="utf-8-sig", newline="")))
    used: set[str] = set()
    index_rows: list[dict[str, object]] = []
    copied = 0

    TARGET_ROOT.mkdir(parents=True, exist_ok=True)

    for row in rows:
        if str(row.get("previewReady", "")).lower() != "true":
            continue

        key = unique_key(row, used)
        base = skeleton_base(row["skeleton"])
        target_dir = TARGET_ROOT / key
        target_skeleton = target_dir / f"{key}.skel.bytes"
        target_atlas = target_dir / f"{key}.atlas.txt"

        copy_file(row["skeleton"], target_skeleton)
        copy_file(row["atlas"], target_atlas)
        copied += 2

        page_names: list[str] = []
        for png_rel in filter(None, row.get("pngs", "").split("|")):
            source_name = Path(png_rel).name
            target_png = target_dir / source_name
            copy_file(png_rel, target_png)
            page_names.append(source_name)
            copied += 1

        category_parts = rel_after_spine(row["sourceDir"]).split("/")
        category = category_parts[0] if category_parts else "Spine"
        index_rows.append(
            {
                "key": key,
                "name": key,
                "id": len(index_rows) + 1,
                "category": category,
                "sourceDir": row["sourceDir"],
                "sourceSkeleton": row["skeleton"],
                "base": base,
                "dir": f"res://assets/spine/all_export/{key}",
                "skeleton": f"res://assets/spine/all_export/{key}/{key}.skel.bytes",
                "atlas": f"res://assets/spine/all_export/{key}/{key}.atlas.txt",
                "baked": f"res://assets/spine/all_export/{key}/{key}.baked.json",
                "pages": page_names,
            }
        )

    INDEX_PATH.write_text(json.dumps(index_rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"imported sets: {len(index_rows)}")
    print(f"copied files: {copied}")
    print(f"index: {INDEX_PATH}")
    print(f"target: {TARGET_ROOT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
