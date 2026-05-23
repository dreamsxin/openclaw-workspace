#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Batch export Unity UI resources from YooAsset bundles to Unity project.
Filters physical-asset-map.csv for Sprite assets in priority UI directories,
decrypts bundles, extracts PNG images, and places them in the Unity Resources folder.

Priority order: Login → MainUI → LotteryDraw → Gallery → Hero → Common → Item → Battle

Usage:
    python scripts/unity/export_unity_ui_resources.py [--dry-run]
"""

from __future__ import annotations

import argparse
import csv
import os
import re
import sys
from collections import defaultdict
from pathlib import Path

import UnityPy

# Project paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
PHYSICAL_MAP = PROJECT_ROOT / "reverse-output" / "assets" / "yoo-physical-map" / "physical-asset-map.csv"
UNITY_UI_ROOT = PROJECT_ROOT / "standalone" / "unity-mvp" / "Assets" / "Resources" / "UI"

# Priority directories for Sprite assets (in export order)
PRIORITY_SPRITE_DIRS = [
    "Assets/Game/RawAssets/Sprite/Login",
    "Assets/Game/RawAssets/Sprite/Loading",
    "Assets/Game/RawAssets/Sprite/MainUI",
    "Assets/Game/RawAssets/Sprite/BackGround",
    "Assets/Game/RawAssets/Sprite/LotteryDraw",
    "Assets/Game/RawAssets/Sprite/Gallery",
    "Assets/Game/RawAssets/Sprite/Hero",
    "Assets/Game/RawAssets/Sprite/Prayer",
    "Assets/Game/RawAssets/Sprite/Common",
    "Assets/Game/RawAssets/Sprite/Item",
    "Assets/Game/RawAssets/Sprite/Battle",
    "Assets/Game/RawAssets/Sprite/PlayerInfo",
    "Assets/Game/RawAssets/Sprite/Task",
    "Assets/Game/RawAssets/Sprite/Shop",
    "Assets/Game/RawAssets/Sprite/Mail",
    "Assets/Game/RawAssets/Sprite/Welfare",
    "Assets/Game/RawAssets/Sprite/Quest",
]

# Subdirectories to include under Hero/
HERO_SUBDIRS = [
    "Assets/Game/RawAssets/Sprite/Hero/Recruit",
    "Assets/Game/RawAssets/Sprite/Hero/HalfBody",
    "Assets/Game/RawAssets/Sprite/Hero/Card",
    "Assets/Game/RawAssets/Sprite/Hero/Head",
    "Assets/Game/RawAssets/Sprite/Hero/Skill",
    "Assets/Game/RawAssets/Sprite/Hero/Silhouette",
]

XOR_PREFIX = 222
XOR_KEY = 0x16


def safe_name(name: str) -> str:
    return re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", name).strip(" .")


def load_bundle(path: Path) -> UnityPy.Environment | None:
    """Load and decrypt a YooAsset bundle."""
    try:
        data = bytearray(path.read_bytes())
        for i in range(min(XOR_PREFIX, len(data))):
            data[i] ^= XOR_KEY
        return UnityPy.load(bytes(data))
    except Exception as e:
        print(f"  ERROR loading {path.name}: {e}")
        return None


def export_textures(env: UnityPy.Environment, out_dir: Path, prefix: str = "") -> int:
    """Export all Texture2D and Sprite images from a bundle environment."""
    count = 0
    for obj in env.objects:
        if obj.type.name not in ("Texture2D", "Sprite"):
            continue
        try:
            data = obj.read()
            name = safe_name(getattr(data, "m_Name", "") or f"{obj.type.name}_{obj.path_id}")
            image = getattr(data, "image", None)
            if image is None:
                continue

            filename = f"{prefix}{name}.png" if prefix else f"{name}.png"
            out_path = out_dir / filename
            out_path.parent.mkdir(parents=True, exist_ok=True)
            image.save(out_path)
            count += 1
        except Exception as e:
            print(f"  ERROR extracting {obj.path_id}: {e}")
    return count


def read_physical_map() -> list[dict]:
    """Read the physical asset map and filter for Sprite assets in priority directories."""
    assets = []
    with open(PHYSICAL_MAP, "r", encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            # The 'address' field contains the asset path for Sprite assets
            asset_path = row.get("address", "") or row.get("assetPath", "")
            physical_path = row.get("physicalPath", "")
            physical_exists = row.get("physicalExists", "False")

            if not asset_path or not physical_path or physical_exists != "True":
                continue
            
            # Filter: only Sprite assets in priority directories
            if not asset_path.startswith("Assets/Game/RawAssets/Sprite/"):
                continue

            is_priority = False
            for pdir in PRIORITY_SPRITE_DIRS:
                if asset_path.startswith(pdir + "/") or asset_path == pdir:
                    is_priority = True
                    break
            for hdir in HERO_SUBDIRS:
                if asset_path.startswith(hdir + "/"):
                    is_priority = True
                    break

            if not is_priority:
                continue

            assets.append({
                "assetPath": asset_path,
                "physicalPath": physical_path,
                "bundleName": row.get("bundleName", ""),
            })

    return assets


def group_by_bundle(assets: list[dict]) -> dict[str, list[dict]]:
    """Group assets by their physical bundle path."""
    groups = defaultdict(list)
    for a in assets:
        groups[a["physicalPath"]].append(a)
    return groups


def asset_to_unity_dir(asset_path: str) -> str:
    """Convert asset path to Unity Resources subdirectory.
    Assets/Game/RawAssets/Sprite/Login/logo.png -> Login
    Assets/Game/RawAssets/Sprite/MainUI/mainui_img_01.png -> MainUI
    """
    prefix = "Assets/Game/RawAssets/Sprite/"
    if asset_path.startswith(prefix):
        rel = asset_path[len(prefix):]
        parts = rel.replace("\\", "/").split("/")
        if len(parts) >= 1:
            return parts[0]
    return "Other"


def main():
    parser = argparse.ArgumentParser(description="Export Unity UI resources from YooAsset bundles.")
    parser.add_argument("--dry-run", action="store_true", help="Only list what would be exported")
    args = parser.parse_args()

    print("Reading physical asset map...")
    assets = read_physical_map()
    print(f"Found {len(assets)} Sprite assets in priority directories")

    bundles = group_by_bundle(assets)
    print(f"Across {len(bundles)} unique bundles")

    if args.dry_run:
        print("\n[Dry run] Would export:")
        dir_counts = defaultdict(int)
        for a in assets:
            dir_counts[asset_to_unity_dir(a["assetPath"])] += 1
        for d, c in sorted(dir_counts.items(), key=lambda x: -x[1]):
            print(f"  {d}: {c} assets")
        print(f"\nTotal: {len(assets)} assets across {len(bundles)} bundles")
        return 0

    total_exported = 0
    total_failed = 0
    processed_bundles = 0

    for bundle_path_str, bundle_assets in bundles.items():
        bundle_path = (PROJECT_ROOT / bundle_path_str).resolve()
        if not bundle_path.exists():
            print(f"SKIP (not found): {bundle_path_str}")
            total_failed += len(bundle_assets)
            continue

        processed_bundles += 1
        if processed_bundles % 50 == 0:
            print(f"  Progress: {processed_bundles}/{len(bundles)} bundles...")

        env = load_bundle(bundle_path)
        if env is None:
            total_failed += len(bundle_assets)
            continue

        # Determine output directory from first asset
        unity_dir = asset_to_unity_dir(bundle_assets[0]["assetPath"])
        out_dir = UNITY_UI_ROOT / unity_dir

        count = export_textures(env, out_dir)
        total_exported += count

    print(f"\nDone: {total_exported} images exported from {processed_bundles} bundles")
    print(f"Failed: {total_failed} assets (bundle not found or extraction error)")
    print(f"Output: {UNITY_UI_ROOT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
