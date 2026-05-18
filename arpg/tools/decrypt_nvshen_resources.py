#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path


SIGN = b"sign_123"
KEY = b"key_456"


def decrypt_payload(data: bytes) -> tuple[bytes, bool]:
    if not data.startswith(SIGN):
        return data, False

    body = data[len(SIGN):]
    key_len = len(KEY)
    decrypted = bytes(byte ^ KEY[index % key_len] for index, byte in enumerate(body))
    return decrypted, True


def detect_kind(data: bytes) -> str:
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if data.startswith(b"\xff\xd8\xff"):
        return "jpg"
    if data.startswith(b"ID3") or data.startswith(b"\xff\xfb") or data.startswith(b"\xff\xf3") or data.startswith(b"\xff\xf2"):
        return "mp3"
    stripped = data.lstrip()
    if stripped.startswith((b"{", b"[")):
        return "json"
    if stripped.startswith((b"#!", b"var ", b"let ", b"const ", b"window.", b"(function", b"System.")):
        return "js"
    if b"\x00" not in data[:512]:
        return "text"
    return "binary"


def decrypt_tree(src: Path, dst: Path, overwrite: bool) -> dict[str, object]:
    stats: Counter[str] = Counter()
    samples: list[dict[str, str]] = []

    for path in src.rglob("*"):
        if not path.is_file():
            continue

        rel = path.relative_to(src)
        out_path = dst / rel
        if out_path.exists() and not overwrite:
            stats["skipped_existing"] += 1
            continue

        data = path.read_bytes()
        output, decrypted = decrypt_payload(data)

        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(output)

        kind = detect_kind(output)
        stats["total"] += 1
        stats["decrypted" if decrypted else "copied_plain"] += 1
        stats[f"kind_{kind}"] += 1
        stats[f"ext_{path.suffix.lower() or '<none>'}"] += 1

        if decrypted and len(samples) < 20:
            samples.append({
                "path": str(rel),
                "ext": path.suffix.lower(),
                "kind": kind,
                "head": output[:16].hex(" "),
            })

    return {"stats": dict(stats), "samples": samples}


def main() -> int:
    parser = argparse.ArgumentParser(description="Decrypt nvshen Cocos resources protected by sign_123/key_456.")
    parser.add_argument(
        "--src",
        type=Path,
        default=Path(r"D:\work\openclaw-workspace\arpg\nvshenres\assets\resources"),
        help="source resources directory",
    )
    parser.add_argument(
        "--dst",
        type=Path,
        default=Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted\assets\resources"),
        help="output directory",
    )
    parser.add_argument("--overwrite", action="store_true", help="overwrite existing output files")
    parser.add_argument("--report", type=Path, help="optional JSON report path")
    args = parser.parse_args()

    src = args.src.resolve()
    dst = args.dst.resolve()
    if not src.is_dir():
        raise SystemExit(f"source directory does not exist: {src}")
    if src == dst or src in dst.parents:
        raise SystemExit("destination must not be the source directory or a child of the source directory")

    result = decrypt_tree(src, dst, args.overwrite)
    report = args.report or dst.parent.parent / "decrypt_report.json"
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"source: {src}")
    print(f"output: {dst}")
    print(f"report: {report}")
    for key, value in sorted(result["stats"].items()):
        print(f"{key}: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
