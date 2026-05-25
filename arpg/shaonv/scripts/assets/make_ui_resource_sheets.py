#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build contact sheets for already-exported UI PNG resources."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image, ImageDraw


def natural_key(path: Path) -> list[object]:
    parts = re.split(r"(\d+)", path.stem.lower())
    return [int(part) if part.isdigit() else part for part in parts]


def collect(root: Path, patterns: list[str]) -> list[Path]:
    files: list[Path] = []
    for pattern in patterns:
        files.extend(root.glob(pattern))
    return sorted({path for path in files if path.is_file()}, key=natural_key)


def make_sheet(files: list[Path], out: Path, title: str, columns: int, cell: tuple[int, int]) -> None:
    if not files:
        return
    cell_w, cell_h = cell
    title_h = 32
    rows = (len(files) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * cell_w, title_h + rows * cell_h), (17, 21, 31, 255))
    draw = ImageDraw.Draw(sheet)
    draw.text((10, 8), f"{title} ({len(files)})", fill=(238, 242, 250, 255))
    for index, path in enumerate(files):
        x = (index % columns) * cell_w
        y = title_h + (index // columns) * cell_h
        try:
            image = Image.open(path).convert("RGBA")
        except Exception:
            continue
        max_w = cell_w - 12
        max_h = cell_h - 28
        image.thumbnail((max_w, max_h), Image.LANCZOS)
        sheet.alpha_composite(image, (x + (cell_w - image.width) // 2, y + 6))
        draw.text((x + 4, y + cell_h - 20), path.stem, fill=(220, 226, 238, 255))
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)


def main() -> int:
    parser = argparse.ArgumentParser(description="Create UI resource contact sheets.")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--out", default="tmp/screenshots/resource-sheets")
    args = parser.parse_args()

    root = Path(args.repo_root)
    out = root / args.out
    unity = root / "standalone/unity-mvp/Assets/Resources/UI"
    godot = root / "standalone/godot-mvp/assets/ui"

    sheets = [
        ("hero-buttons", unity / "Hero", ["hero_btn_*.png"], 8, (128, 112)),
        ("hero-icons-1-120", unity / "Hero", ["hero_img_*.png", "hero_zhiye_*.png"], 10, (110, 100)),
        ("common-buttons", unity / "Common", ["common_btn_*.png", "tongyong_btn_*.png", "*_btn_*.png"], 8, (142, 112)),
        ("common-icons", unity / "Common", ["common_img_*.png", "chat_headk_*.png"], 10, (110, 100)),
        ("skill-icons", godot / "skill", ["*.png"], 8, (120, 112)),
        ("hero-round-heads", godot / "hero/round", ["yhero_*.png"], 8, (112, 112)),
        ("hero-square-heads", unity / "Item", ["thero_*.png"], 8, (120, 112)),
        ("gal-godot", godot / "gal", ["*.png"], 8, (136, 112)),
    ]

    for name, directory, patterns, columns, cell in sheets:
        files = collect(directory, patterns)
        make_sheet(files, out / f"{name}.png", name, columns, cell)
        print(f"{name}: {len(files)} -> {out / f'{name}.png'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
