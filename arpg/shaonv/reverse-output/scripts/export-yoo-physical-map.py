#!/usr/bin/env python3
"""Export focused YooAsset asset-to-physical-bundle lookup tables."""

from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path
from typing import Any


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def write_csv(path: Path, rows: list[dict[str, Any]], headers: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("parsed_dir", help="Folder containing manifest-parsed-assets.csv and manifest-parsed-bundles.csv")
    parser.add_argument("out_dir")
    parser.add_argument(
        "--focus",
        default=(
            "LotteryDraw|Prayer|HeroRecruit|Spine/Hero/hero_00[135]|"
            "Spine/Hero/hero_016|Spine/Hero/hero_017|Sprite/LotteryDraw"
        ),
        help="Regex for focused assetPath rows",
    )
    args = parser.parse_args()

    parsed_dir = Path(args.parsed_dir)
    out_dir = Path(args.out_dir)
    assets = read_csv(parsed_dir / "manifest-parsed-assets.csv")
    bundles = read_csv(parsed_dir / "manifest-parsed-bundles.csv")
    focus = re.compile(args.focus, re.IGNORECASE)

    headers = [
        "id",
        "address",
        "assetPath",
        "bundleID",
        "bundleName",
        "hashFileName",
        "fileSize",
        "physicalPath",
        "physicalExists",
        "physicalSizeMatches",
        "dependBundleIDs",
    ]
    focused_assets = [
        {key: row.get(key, "") for key in headers}
        for row in assets
        if focus.search(row.get("assetPath", "") or row.get("address", ""))
    ]
    physical_assets = [
        {key: row.get(key, "") for key in headers}
        for row in assets
        if row.get("physicalExists") == "True"
    ]
    physical_bundles = [row for row in bundles if row.get("physicalExists") == "True"]

    write_csv(out_dir / "focused-asset-physical-map.csv", focused_assets, headers)
    write_csv(out_dir / "physical-asset-map.csv", physical_assets, headers)
    write_csv(
        out_dir / "physical-bundle-map.csv",
        physical_bundles,
        [
            "id",
            "bundleName",
            "fileName",
            "hashFileName",
            "fileHash",
            "fileCRC",
            "fileSize",
            "physicalPath",
            "physicalSize",
            "physicalExists",
            "physicalSizeMatches",
            "dependBundleIDs",
        ],
    )

    summary = {
        "totalAssets": len(assets),
        "totalBundles": len(bundles),
        "physicalBundles": len(physical_bundles),
        "physicalAssets": len(physical_assets),
        "focusedAssets": len(focused_assets),
        "focusedPhysicalAssets": sum(1 for row in focused_assets if row.get("physicalExists") == "True"),
        "missingFocusedAssets": sum(1 for row in focused_assets if row.get("physicalExists") != "True"),
    }
    (out_dir / "physical-map-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
