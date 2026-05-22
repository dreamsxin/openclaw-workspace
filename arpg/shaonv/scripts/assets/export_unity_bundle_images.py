import argparse
import os
from pathlib import Path

import UnityPy


def safe_name(name: str) -> str:
    return "".join(ch if ch not in '<>:"/\\|?*' else "_" for ch in name).strip()


def export_bundle(source: Path, destination: Path) -> int:
    env = UnityPy.load(str(source))
    count = 0
    for obj in env.objects:
        if obj.type.name not in {"Texture2D", "Sprite"}:
            continue
        data = obj.parse_as_object()
        name = safe_name(getattr(data, "m_Name", "") or f"{obj.type.name}_{obj.path_id}")
        if not name:
            continue
        image = getattr(data, "image", None)
        if image is None:
            continue
        out_path = destination / f"{name}.png"
        destination.mkdir(parents=True, exist_ok=True)
        image.save(out_path)
        count += 1
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description="Export Texture2D/Sprite images from Unity bundles.")
    parser.add_argument("--out", required=True, help="Destination directory.")
    parser.add_argument("sources", nargs="+", help="Unity bundle or __data files.")
    args = parser.parse_args()

    destination = Path(args.out)
    total = 0
    for raw_source in args.sources:
        source = Path(raw_source)
        if not source.exists():
            print(f"missing: {source}")
            continue
        try:
            count = export_bundle(source, destination)
        except Exception as exc:
            print(f"failed: {source}: {exc}")
            continue
        total += count
        print(f"exported {count}: {source}")
    print(f"total exported: {total} -> {destination}")


if __name__ == "__main__":
    main()
