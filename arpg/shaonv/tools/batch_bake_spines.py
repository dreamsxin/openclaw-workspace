#!/usr/bin/env python3
"""Batch bake Spine JSON for all exported heroes."""
import subprocess, os, sys
from pathlib import Path

GD_SPINE = Path(r"D:\work\openclaw-workspace\arpg\shaonv\standalone\godot-mvp\assets\spine")
BAKE_SCRIPT = Path(r"D:\work\openclaw-workspace\arpg\shaonv\scripts\spine\bake_hero_spine_preview.mjs")
NODE = r"C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"

print(f"Baking spines from: {GD_SPINE}")
heroes = sorted([d.name for d in GD_SPINE.iterdir() if d.is_dir() 
                 and (d / f"{d.name}.skel.bytes").exists()
                 and (d / f"{d.name}.atlas.txt").exists()
                 and (d / f"{d.name}.png").exists()
                 and not (d / f"{d.name}.baked.json").exists()])

print(f"Heroes to bake: {len(heroes)}")

ok, skip, fail = 0, 0, 0
for i, hero in enumerate(heroes):
    baked = GD_SPINE / hero / f"{hero}.baked.json"
    if baked.exists():
        skip += 1
        continue
    
    result = subprocess.run(
        [NODE, str(BAKE_SCRIPT), f"--hero={hero}"],
        capture_output=True, text=True, timeout=30
    )
    if result.returncode == 0:
        ok += 1
        if (i + 1) % 20 == 0:
            print(f"  [{i+1}/{len(heroes)}] baked {hero}: ok")
    else:
        fail += 1
        err = result.stderr.strip()[:120]
        print(f"  FAIL {hero}: {err}")

print(f"\nTotal: {len(heroes)}, OK: {ok}, Skip: {skip}, Fail: {fail}")
