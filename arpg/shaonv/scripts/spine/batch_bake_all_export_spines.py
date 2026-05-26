#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Bake all imported Spine preview sets for the Godot browser."""

from __future__ import annotations

import csv
import json
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
GODOT_ROOT = REPO_ROOT / "standalone/godot-mvp"
INDEX_PATH = GODOT_ROOT / "assets/spine/all_spines_list.json"
BAKE_SCRIPT = REPO_ROOT / "scripts/spine/bake_hero_spine_preview.mjs"
FAILURES_CSV = REPO_ROOT / "tmp/all-spine-bake-failures.csv"


def node_exe() -> str:
    bundled = Path(r"C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe")
    return str(bundled if bundled.exists() else "node")


def main() -> int:
    items = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
    failures: list[dict[str, str]] = []
    ok = 0
    skipped = 0

    for index, item in enumerate(items, start=1):
        key = item["key"]
        baked = GODOT_ROOT / item["baked"].replace("res://", "")
        if baked.exists() and baked.stat().st_size > 0:
            skipped += 1
            continue

        directory = item["dir"].replace("res://", "")
        command = [
            node_exe(),
            str(BAKE_SCRIPT),
            f"--dir={directory}",
            f"--key={key}",
            "--fps=8",
            "--max-duration=1.2",
            "--max-clips=4",
        ]
        result = subprocess.run(command, cwd=REPO_ROOT, capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            ok += 1
        else:
            failures.append(
                {
                    "key": key,
                    "sourceDir": str(item.get("sourceDir", "")),
                    "stderr": result.stderr.strip()[:1000],
                    "stdout": result.stdout.strip()[:1000],
                }
            )

        if index % 50 == 0:
            print(f"[{index}/{len(items)}] ok={ok} skipped={skipped} failures={len(failures)}")

    FAILURES_CSV.parent.mkdir(parents=True, exist_ok=True)
    with FAILURES_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["key", "sourceDir", "stderr", "stdout"])
        writer.writeheader()
        writer.writerows(failures)

    print(f"total={len(items)} ok={ok} skipped={skipped} failures={len(failures)}")
    print(f"failures: {FAILURES_CSV}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
