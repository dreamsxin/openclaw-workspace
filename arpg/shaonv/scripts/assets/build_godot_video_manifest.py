#!/usr/bin/env python3
"""Build the Godot runtime video manifest from exported YooAsset media."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


DEFAULT_MEDIA_MANIFEST = "reverse-output/media-export/media-export-manifest.json"
DEFAULT_VIDEO_OWNERS = "reverse-output/media-export/video-prefab-owners.json"
DEFAULT_OUT = "standalone/godot-mvp/data/video_manifest.json"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def stem_from_address(address: str) -> str:
    return Path(address.replace("\\", "/")).stem


def godot_path_for(stem: str) -> str:
    if stem == "game_start":
        return "res://assets/video/game_start.ogv"
    if stem.startswith("recruit_"):
        return f"res://assets/video/recruit/{stem}.ogv"
    return f"res://assets/video/{stem}.ogv"


def build_manifest(repo_root: Path, media_manifest: Path, owners_path: Path, out_path: Path) -> dict[str, object]:
    media_rows = [
        row for row in load_json(media_manifest)
        if str(row.get("assetExtension", "")).lower() == ".mp4" and row.get("address")
    ]
    owners_by_address = {row.get("address", ""): row for row in load_json(owners_path)}

    videos: dict[str, dict[str, object]] = {}
    hero_recruit: dict[str, str] = {}
    for row in sorted(media_rows, key=lambda item: str(item.get("address", ""))):
        address = str(row.get("address", ""))
        stem = stem_from_address(address)
        godot_path = godot_path_for(stem)
        owner_row = owners_by_address.get(address, {})
        owners = owner_row.get("owners", []) if isinstance(owner_row, dict) else []
        video_entry = {
            "address": address,
            "source": row.get("output", ""),
            "godotPath": godot_path,
            "bytes": row.get("bytes", 0),
            "owners": owners,
        }
        videos[stem] = video_entry
        if stem.startswith("recruit_"):
            hero_recruit[f"hero_{stem.split('_', 1)[1]}"] = godot_path

    manifest = {
        "generatedFrom": [
            str(media_manifest.relative_to(repo_root)).replace("\\", "/"),
            str(owners_path.relative_to(repo_root)).replace("\\", "/"),
        ],
        "videos": videos,
        "heroRecruit": hero_recruit,
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description="Build standalone/godot-mvp/data/video_manifest.json.")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--media-manifest", default=DEFAULT_MEDIA_MANIFEST)
    parser.add_argument("--video-owners", default=DEFAULT_VIDEO_OWNERS)
    parser.add_argument("--out", default=DEFAULT_OUT)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    manifest = build_manifest(
        repo_root,
        (repo_root / args.media_manifest).resolve(),
        (repo_root / args.video_owners).resolve(),
        (repo_root / args.out).resolve(),
    )
    print(f"videos: {len(manifest['videos'])}")
    print(f"hero recruit videos: {len(manifest['heroRecruit'])}")
    print(f"manifest: {(repo_root / args.out).resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
