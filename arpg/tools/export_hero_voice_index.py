import argparse
import json
import shutil
import sys
from pathlib import Path

from build_godot_resource_demo import decompress_cocos_uuid


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "nvshenres_decrypted_full"
DEFAULT_SOURCE = ROOT / "nvshenres" / "assets" / "resources" / "native"
DEFAULT_CONFIG = PROJECT / "assets" / "resources" / "config.json"
DEFAULT_OUT = PROJECT / "data" / "hero_voice_index.json"
DEFAULT_COPY_DIR = PROJECT / "assets" / "hero_voice"


HERO_IDS = [
    "105004",
    "205008",
    "305006",
    "405007",
    "505004",
    "204002",
    "104002",
    "504002",
    "304001",
    "204001",
]


def native_path_for_uuid(native_root: Path, uuid: str) -> Path | None:
    full_uuid = decompress_cocos_uuid(uuid)
    prefix = full_uuid[:2]
    for ext in (".mp3", ".ogg", ".wav"):
        candidate = native_root / prefix / f"{full_uuid}{ext}"
        if candidate.exists():
            return candidate
    return None


def export(config_path: Path, native_root: Path, out_path: Path, copy_dir: Path, hero_ids: list[str]) -> None:
    config = json.loads(config_path.read_text(encoding="utf-8"))
    paths = config.get("paths", {})
    uuids = config.get("uuids", [])
    index: dict[str, dict[str, dict[str, str]]] = {}
    copy_dir.mkdir(parents=True, exist_ok=True)

    for item in paths.values():
        if not isinstance(item, list) or not item:
            continue
        asset_path = str(item[0])
        if not asset_path.startswith("sound/cv/"):
            continue
        parts = asset_path.split("/")
        if len(parts) != 4:
            continue
        _, _, hero_id, sound_id = parts
        if hero_id not in hero_ids:
            continue
        path_index = int(next(k for k, v in paths.items() if v is item))
        if path_index < 0 or path_index >= len(uuids):
            continue
        uuid = str(uuids[path_index])
        native = native_path_for_uuid(native_root, uuid)
        if native is None:
            continue
        target_dir = copy_dir / hero_id
        target_dir.mkdir(parents=True, exist_ok=True)
        target = target_dir / f"{sound_id}{native.suffix.lower()}"
        shutil.copy2(native, target)
        rel_target = target.relative_to(PROJECT).as_posix()
        index.setdefault(hero_id, {})[sound_id] = {
            "asset_path": asset_path,
            "uuid": uuid,
            "native": str(native),
            "path": f"res://{rel_target}",
        }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Export Cocos hero cv MP3 files for the Godot demo.")
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--native-root", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--copy-dir", type=Path, default=DEFAULT_COPY_DIR)
    parser.add_argument("--heroes", nargs="*", default=HERO_IDS)
    args = parser.parse_args()
    export(args.config, args.native_root, args.out, args.copy_dir, args.heroes)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
