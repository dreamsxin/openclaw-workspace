from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "reverse-output" / "assets" / "assetripper-main" / "ExportedProject" / "Assets"
TARGET_ROOT = ROOT / "godot-project" / "assets" / "spine" / "loading" / "kokomi_Loading"
MANIFEST_PATH = ROOT / "reverse-output" / "assets" / "derived" / "godot_spine_loading_import_manifest.json"

ASSETS = [
    ("TextAsset/kokomi_Loading.atlas.txt", "kokomi_Loading.atlas.txt"),
    ("TextAsset/kokomi_Loading.skel.bytes", "kokomi_Loading.skel.bytes"),
    ("Texture2D/kokomi_Loading.png", "kokomi_Loading.png"),
    ("Texture2D/kokomi_Loading_2.png", "kokomi_Loading_2.png"),
]


def copy_asset(source_rel: str, target_name: str) -> dict[str, object]:
    source = SOURCE_ROOT / source_rel
    target = TARGET_ROOT / target_name
    if not source.exists():
        raise FileNotFoundError(source)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    return {
        "source": str(source.relative_to(ROOT)).replace("\\", "/"),
        "target": str(target.relative_to(ROOT)).replace("\\", "/"),
        "bytes": target.stat().st_size,
    }


def main() -> None:
    copied = [copy_asset(source_rel, target_name) for source_rel, target_name in ASSETS]
    rig_builder = ROOT / "scripts" / "reverse" / "build_kokomi_loading_spine_rig.py"
    if rig_builder.exists():
        subprocess.run([sys.executable, str(rig_builder)], check=True)
        copied.append(
            {
                "source": "generated from imported kokomi_Loading Spine evidence",
                "target": "godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.rig.json",
                "bytes": (TARGET_ROOT / "kokomi_Loading.rig.json").stat().st_size,
            }
        )
    baker = ROOT / "scripts" / "reverse" / "bake_kokomi_loading_spine.mjs"
    if baker.exists():
        subprocess.run(["node", str(baker)], check=True)
        copied.append(
            {
                "source": "baked by @esotericsoftware/spine-core@4.2.43 from kokomi_Loading.skel.bytes",
                "target": "godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.baked.json",
                "bytes": (TARGET_ROOT / "kokomi_Loading.baked.json").stat().st_size,
            }
        )
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(
        json.dumps(
            {
                "source": str(SOURCE_ROOT.relative_to(ROOT)).replace("\\", "/"),
                "target": str(TARGET_ROOT.relative_to(ROOT)).replace("\\", "/"),
                "purpose": "Godot UISceneLoading Spine-region preview input assets",
                "assets": copied,
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"Copied {len(copied)} kokomi_Loading Spine files to {TARGET_ROOT}")
    print(f"Wrote {MANIFEST_PATH}")


if __name__ == "__main__":
    main()
