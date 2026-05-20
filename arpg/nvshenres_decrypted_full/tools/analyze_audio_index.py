#!/usr/bin/env python3
"""Summarize Cocos cc.AudioClip paths exported from config.json."""

from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path


def classify(path: str) -> str:
    parts = path.split("/")
    if len(parts) >= 2:
        return "/".join(parts[:2])
    return path or "<empty>"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default="data/config_index/by_type/cc.AudioClip.json")
    parser.add_argument("--output", default="data/audio_index_summary.json")
    args = parser.parse_args()

    entries = json.loads(Path(args.input).read_text(encoding="utf-8"))
    by_prefix: Counter[str] = Counter()
    cv_by_hero: dict[str, list[dict]] = defaultdict(list)
    samples: dict[str, list[str]] = defaultdict(list)

    for entry in entries:
        path = str(entry.get("path", ""))
        prefix = classify(path)
        by_prefix[prefix] += 1
        if len(samples[prefix]) < 12:
            samples[prefix].append(path)
        parts = path.split("/")
        if len(parts) >= 4 and parts[0] == "sound" and parts[1] == "cv":
            cv_by_hero[parts[2]].append(entry)

    hero_counts = {
        hero_id: len(items)
        for hero_id, items in sorted(cv_by_hero.items(), key=lambda kv: (-len(kv[1]), kv[0]))
    }
    output = {
        "source": args.input,
        "total_audio_clips": len(entries),
        "prefix_counts": dict(sorted(by_prefix.items())),
        "cv_hero_count": len(cv_by_hero),
        "cv_by_hero_counts": hero_counts,
        "samples": dict(sorted(samples.items())),
        "notes": [
            "sound/cv/<hero_id>/<sound_id> are hero or guide voices.",
            "sound/skill/<skill_id> and *_hit are combat skill sounds.",
            "sound/UI/<name> are interface effects.",
            "sound/bgm/<name> are looping background music candidates.",
        ],
    }
    Path(args.output).write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
