#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
from collections import Counter
from pathlib import Path
from typing import Iterable


DEFAULT_SIGN = b"sign_123"
DEFAULT_KEY = b"key_456"


def parse_bytes(value: str) -> bytes:
    if value.startswith("hex:"):
        return bytes.fromhex(value[4:].replace(" ", ""))
    return value.encode("utf-8")


def read_head(path: Path, size: int = 64) -> bytes:
    with path.open("rb") as handle:
        return handle.read(size)


def iter_files(root: Path) -> Iterable[Path]:
    for path in root.rglob("*"):
        if path.is_file():
            yield path


def decrypt_payload(data: bytes, sign: bytes, key: bytes) -> tuple[bytes, bool]:
    if not sign:
        raise ValueError("sign must not be empty")
    if not key:
        raise ValueError("key must not be empty")
    if not data.startswith(sign):
        return data, False

    body = data[len(sign):]
    key_len = len(key)
    output = bytes(byte ^ key[index % key_len] for index, byte in enumerate(body))
    return output, True


def detect_kind(data: bytes) -> str:
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if data.startswith(b"\xff\xd8\xff"):
        return "jpg"
    if data.startswith(b"GIF87a") or data.startswith(b"GIF89a"):
        return "gif"
    if data.startswith(b"RIFF") and data[8:12] == b"WEBP":
        return "webp"
    if data.startswith(b"PK\x03\x04"):
        return "zip"
    if data.startswith(b"OggS"):
        return "ogg"
    if data.startswith(b"fLaC"):
        return "flac"
    if data.startswith(b"ID3") or data.startswith((b"\xff\xfb", b"\xff\xf3", b"\xff\xf2")):
        return "mp3"
    if data.startswith(b"\x00\x01\x00\x00") or data.startswith(b"OTTO"):
        return "font"

    stripped = data.lstrip()
    if stripped.startswith((b"{", b"[")):
        return "json"
    if stripped.startswith((b"#!", b"var ", b"let ", b"const ", b"window.", b"(function", b"System.")):
        return "js"
    if data and b"\x00" not in data[:512]:
        return "text"
    return "binary"


def expected_ext(kind: str) -> str | None:
    mapping = {
        "png": ".png",
        "jpg": ".jpg",
        "gif": ".gif",
        "webp": ".webp",
        "json": ".json",
        "js": ".js",
        "mp3": ".mp3",
        "ogg": ".ogg",
        "flac": ".flac",
        "zip": ".zip",
    }
    return mapping.get(kind)


def make_record(root: Path, path: Path, data: bytes, encrypted: bool, decrypted: bool) -> dict[str, object]:
    kind = detect_kind(data)
    ext = path.suffix.lower()
    wanted_ext = expected_ext(kind)
    return {
        "path": str(path.relative_to(root)),
        "size": path.stat().st_size,
        "ext": ext,
        "kind": kind,
        "encrypted": encrypted,
        "decrypted": decrypted,
        "extension_mismatch": bool(wanted_ext and ext and ext != wanted_ext),
        "expected_ext": wanted_ext or "",
        "head_hex": data[:16].hex(" "),
    }


def write_reports(records: list[dict[str, object]], report_json: Path, report_csv: Path | None) -> None:
    stats: Counter[str] = Counter()
    for record in records:
        stats["total"] += 1
        stats["encrypted" if record["encrypted"] else "plain"] += 1
        stats["decrypted" if record["decrypted"] else "not_decrypted"] += 1
        stats[f"kind_{record['kind']}"] += 1
        stats[f"ext_{record['ext'] or '<none>'}"] += 1
        if record["extension_mismatch"]:
            stats["extension_mismatch"] += 1

    report_json.parent.mkdir(parents=True, exist_ok=True)
    report_json.write_text(
        json.dumps({"stats": dict(stats), "files": records}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    if report_csv:
        report_csv.parent.mkdir(parents=True, exist_ok=True)
        with report_csv.open("w", newline="", encoding="utf-8-sig") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(records[0].keys()) if records else [])
            if records:
                writer.writeheader()
                writer.writerows(records)

    for key, value in sorted(stats.items()):
        print(f"{key}: {value}")
    print(f"report_json: {report_json}")
    if report_csv:
        print(f"report_csv: {report_csv}")


def analyze(args: argparse.Namespace) -> int:
    root = args.src.resolve()
    sign = parse_bytes(args.sign)
    key = parse_bytes(args.key)
    records: list[dict[str, object]] = []
    heads: Counter[str] = Counter()

    for path in iter_files(root):
        raw = path.read_bytes()
        heads[raw[: min(len(raw), args.head_size)].hex(" ")] += 1
        output, decrypted = decrypt_payload(raw, sign, key) if raw.startswith(sign) else (raw, False)
        records.append(make_record(root, path, output, raw.startswith(sign), decrypted))

    print("top_heads:")
    for head, count in heads.most_common(args.top_heads):
        print(f"{count}: {head}")
    write_reports(records, args.report_json.resolve(), args.report_csv.resolve() if args.report_csv else None)
    return 0


def decrypt(args: argparse.Namespace) -> int:
    src = args.src.resolve()
    dst = args.dst.resolve()
    sign = parse_bytes(args.sign)
    key = parse_bytes(args.key)
    if not src.is_dir():
        raise SystemExit(f"source directory does not exist: {src}")
    if src == dst or src in dst.parents:
        raise SystemExit("destination must not be the source directory or a child of the source directory")

    records: list[dict[str, object]] = []
    for path in iter_files(src):
        rel = path.relative_to(src)
        out_path = dst / rel
        if out_path.exists() and not args.overwrite:
            continue

        raw = path.read_bytes()
        output, decrypted = decrypt_payload(raw, sign, key)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(output)
        records.append(make_record(src, path, output, raw.startswith(sign), decrypted))

    write_reports(records, args.report_json.resolve(), args.report_csv.resolve() if args.report_csv else None)
    print(f"output: {dst}")
    return 0


def verify(args: argparse.Namespace) -> int:
    root = args.src.resolve()
    sign = parse_bytes(args.sign)
    records: list[dict[str, object]] = []
    remaining = 0
    json_fail = 0

    for path in iter_files(root):
        raw = path.read_bytes()
        if raw.startswith(sign):
            remaining += 1
        records.append(make_record(root, path, raw, raw.startswith(sign), False))
        if path.suffix.lower() == ".json":
            try:
                json.loads(raw.decode("utf-8"))
            except Exception:
                json_fail += 1

    write_reports(records, args.report_json.resolve(), args.report_csv.resolve() if args.report_csv else None)
    print(f"remaining_sign: {remaining}")
    print(f"json_fail: {json_fail}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Analyze and decrypt Cocos resource files protected by sign + XOR key.")
    parser.add_argument("--sign", default=DEFAULT_SIGN.decode("ascii"), help="plain text or hex: encoded signature")
    parser.add_argument("--key", default=DEFAULT_KEY.decode("ascii"), help="plain text or hex: encoded XOR key")
    subparsers = parser.add_subparsers(dest="command", required=True)

    analyze_parser = subparsers.add_parser("analyze", help="analyze encryption state and true file formats")
    analyze_parser.add_argument("src", type=Path)
    analyze_parser.add_argument("--head-size", type=int, default=8)
    analyze_parser.add_argument("--top-heads", type=int, default=10)
    analyze_parser.add_argument("--report-json", type=Path, default=Path("cocos_resource_analysis.json"))
    analyze_parser.add_argument("--report-csv", type=Path)
    analyze_parser.set_defaults(func=analyze)

    decrypt_parser = subparsers.add_parser("decrypt", help="decrypt a resource tree into a separate output directory")
    decrypt_parser.add_argument("src", type=Path)
    decrypt_parser.add_argument("dst", type=Path)
    decrypt_parser.add_argument("--overwrite", action="store_true")
    decrypt_parser.add_argument("--report-json", type=Path, default=Path("cocos_resource_decrypt_report.json"))
    decrypt_parser.add_argument("--report-csv", type=Path)
    decrypt_parser.set_defaults(func=decrypt)

    verify_parser = subparsers.add_parser("verify", help="verify decrypted output")
    verify_parser.add_argument("src", type=Path)
    verify_parser.add_argument("--report-json", type=Path, default=Path("cocos_resource_verify_report.json"))
    verify_parser.add_argument("--report-csv", type=Path)
    verify_parser.set_defaults(func=verify)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
