from __future__ import annotations

import json
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPRITE_SOURCE = ROOT / "reverse-output/assets/assetstudio-cli-data-sprite/Sprite"
TEXTURE_SOURCE = ROOT / "reverse-output/assets/assetstudio-cli-data-texture2d/Texture2D"
TARGET_DIR = ROOT / "godot-project/assets/loading"
MANIFEST_PATH = ROOT / "reverse-output/assets/derived/godot_loading_asset_import_manifest.json"

ASSET_NAMES = [
    "Image_Loading.png",
    "LoadingIcon64.png",
    "Loading_maid_2.png",
    "kokomi_Loading.png",
    "kokomi_Loading_2.png",
    "LogoChar.png",
    "MaidCafe_Logo_Kr.png",
    "MaidCafe_Logo_Broken.png",
    "MugeMaidcafe Logo.png",
    "MaidCafe_Logo_Eg.png",
    "MaidCafe_Logo_Jp.png",
    "MergeMaid LOGO_Ch.png",
    "MergeMaid LOGO_Ch2.png",
]


def _source_for(asset_name: str) -> Path | None:
    for base in (SPRITE_SOURCE, TEXTURE_SOURCE):
        candidate = base / asset_name
        if candidate.exists():
            return candidate
    return None


def main() -> None:
    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)

    copied = []
    missing = []
    for asset_name in ASSET_NAMES:
        source = _source_for(asset_name)
        if source is None:
            missing.append(asset_name)
            continue
        target = TARGET_DIR / asset_name
        shutil.copy2(source, target)
        copied.append(
            {
                "name": asset_name,
                "source": str(source.relative_to(ROOT)).replace("\\", "/"),
                "target": str(target.relative_to(ROOT)).replace("\\", "/"),
                "bytes": target.stat().st_size,
            }
        )

    manifest = {
        "copied_count": len(copied),
        "missing_count": len(missing),
        "copied": copied,
        "missing": missing,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Copied {len(copied)} loading assets; missing {len(missing)}")


if __name__ == "__main__":
    main()
