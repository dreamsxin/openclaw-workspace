#!/usr/bin/env python3
"""Parse shaonv YooAsset 2.3.1 binary package manifest.

This manifest uses 16-bit string and array counts.  It is not compatible with
the older parse-yoo-manifest.js assumptions that used int32 string lengths.
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import struct
from typing import Any


class Reader:
    def __init__(self, data: bytes):
        self.data = data
        self.off = 0

    def require(self, size: int) -> None:
        if self.off + size > len(self.data):
            raise EOFError(f"need {size} bytes at {self.off}, file size {len(self.data)}")

    def u8(self) -> int:
        self.require(1)
        value = self.data[self.off]
        self.off += 1
        return value

    def i32(self) -> int:
        self.require(4)
        value = struct.unpack_from("<i", self.data, self.off)[0]
        self.off += 4
        return value

    def u32(self) -> int:
        self.require(4)
        value = struct.unpack_from("<I", self.data, self.off)[0]
        self.off += 4
        return value

    def u16(self) -> int:
        self.require(2)
        value = struct.unpack_from("<H", self.data, self.off)[0]
        self.off += 2
        return value

    def string(self) -> str:
        size = self.u16()
        self.require(size)
        value = self.data[self.off : self.off + size].decode("utf-8")
        self.off += size
        return value

    def string_array(self) -> list[str]:
        count = self.u16()
        return [self.string() for _ in range(count)]

    def int_array(self) -> list[int]:
        count = self.u16()
        return [self.i32() for _ in range(count)]

    def align_to_prefixed_string(self, prefix: bytes, suffix: bytes | None = None) -> int:
        start = self.off
        for pos in range(start, len(self.data) - 2):
            size = struct.unpack_from("<H", self.data, pos)[0]
            text_start = pos + 2
            if len(prefix) <= size <= 512 and text_start + size <= len(self.data):
                blob = self.data[text_start : text_start + size]
                if blob.startswith(prefix) and (suffix is None or blob.endswith(suffix)):
                    self.off = pos
                    return pos - start
        raise ValueError(f"could not align to prefixed string {prefix!r} from {start}")


def csv_escape(value: Any) -> str:
    text = "" if value is None else str(value)
    if any(c in text for c in '",\r\n'):
        return '"' + text.replace('"', '""') + '"'
    return text


def write_csv(path: Path, rows: list[dict[str, Any]], headers: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)


def remote_file_name(output_name_style: int, bundle_name: str, file_hash: str) -> str:
    suffix = Path(bundle_name).suffix
    if output_name_style == 1:
        return f"{file_hash}{suffix}"
    if output_name_style == 2:
        return bundle_name
    if output_name_style == 3:
        stem = bundle_name[: -len(suffix)] if suffix else bundle_name
        return f"{stem}_{file_hash}{suffix}"
    return f"{file_hash}{suffix}"


def parse_manifest(path: Path) -> dict[str, Any]:
    reader = Reader(path.read_bytes())
    signature = reader.data[:4]
    reader.off = 4
    if signature != b"OOY\x00":
        raise ValueError(f"unexpected signature {signature!r}")

    manifest = {
        "signature": signature.decode("latin1"),
        "fileVersion": reader.string(),
        "flags": [reader.u8() for _ in range(7)],
        "outputNameStyle": reader.i32(),
        "buildPipeline": reader.string(),
        "packageName": reader.string(),
        "packageVersion": reader.string(),
        "buildTime": reader.string(),
    }

    asset_count = reader.i32()
    # The first asset section is preceded by an empty reserved string in this
    # 2.3.1 manifest variant.
    manifest["assetSectionReserved"] = reader.string()
    assets = []
    for asset_id in range(asset_count):
        record_offset = reader.off
        try:
            address = reader.string()
            assets.append(
                {
                    "id": asset_id,
                    "address": address,
                    "assetPath": reader.string(),
                    "assetTags": "|".join(reader.string_array()),
                    "bundleID": reader.i32(),
                    "dependAssetIDs": "|".join(str(v) for v in reader.int_array()),
                    "dependBundleIDs": "|".join(str(v) for v in reader.int_array()),
                }
            )
        except Exception as exc:
            raise ValueError(f"failed parsing asset #{asset_id} at offset {record_offset}") from exc

    bundle_count = reader.i32()
    # This manifest variant writes a compact lookup/header section before
    # bundle records.  Align to the first logical bundle name.  The skipped
    # bytes are preserved in summary so this remains auditable.
    bundle_header_start = reader.off
    bundle_header_skipped = reader.align_to_prefixed_string(b"assets_", b".bundle")
    bundle_lookup_header = reader.data[bundle_header_start : bundle_header_start + bundle_header_skipped].hex()
    bundles = []
    bundle_id = 0
    while bundle_id < bundle_count:
        if bundle_id:
            try:
                reader.align_to_prefixed_string(b"assets_", b".bundle")
            except ValueError:
                break
        record_offset = reader.off
        try:
            bundle_name = reader.string()
            unity_crc = reader.u32()
            file_hash = reader.string()
            file_crc = reader.string()
            file_size = reader.u32()
            encrypted = bool(reader.u8())
            tags = reader.string_array()
            depend_bundle_ids = reader.int_array()
        except Exception as exc:
            raise ValueError(f"failed parsing bundle #{bundle_id} at offset {record_offset}") from exc
        bundles.append(
            {
                "id": bundle_id,
                "bundleName": bundle_name,
                "unityCRC": unity_crc,
                "fileHash": file_hash,
                "fileCRC": file_crc,
                "fileSize": file_size,
                "encrypted": encrypted,
                "tags": "|".join(tags),
                "dependBundleIDs": "|".join(str(v) for v in depend_bundle_ids),
                "fileName": remote_file_name(int(manifest["outputNameStyle"]), bundle_name, file_hash),
                "bundleLookupHeader": bundle_lookup_header,
            }
        )
        bundle_id += 1

    rows = []
    for asset in assets:
        bundle = bundles[asset["bundleID"]] if 0 <= asset["bundleID"] < len(bundles) else {}
        rows.append(
            {
                **asset,
                "bundleName": bundle.get("bundleName", ""),
                "fileName": bundle.get("fileName", ""),
                "fileHash": bundle.get("fileHash", ""),
                "fileCRC": bundle.get("fileCRC", ""),
                "fileSize": bundle.get("fileSize", ""),
                "encrypted": bundle.get("encrypted", ""),
            }
        )

    return {
        "manifest": manifest,
        "assets": assets,
        "bundles": bundles,
        "assetBundleRows": rows,
        "summary": {
            **manifest,
            "assetCount": asset_count,
            "bundleCount": bundle_count,
            "bundlesParsed": len(bundles),
            "endOffset": reader.off,
            "fileSize": len(reader.data),
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest")
    parser.add_argument("out_dir")
    parser.add_argument("--json", action="store_true", help="Also write large JSON files for assets/bundles")
    args = parser.parse_args()

    parsed = parse_manifest(Path(args.manifest))
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    write_csv(
        out_dir / "manifest-parsed-assets.csv",
        parsed["assetBundleRows"],
        [
            "id",
            "address",
            "assetPath",
            "assetTags",
            "bundleID",
            "bundleName",
            "fileName",
            "fileHash",
            "fileCRC",
            "fileSize",
            "encrypted",
            "dependAssetIDs",
            "dependBundleIDs",
        ],
    )
    write_csv(
        out_dir / "manifest-parsed-bundles.csv",
        parsed["bundles"],
        [
            "id",
            "bundleName",
            "fileName",
            "fileHash",
            "fileCRC",
            "fileSize",
            "encrypted",
            "tags",
            "dependBundleIDs",
            "unityCRC",
            "bundleLookupHeader",
        ],
    )
    (out_dir / "manifest-parsed-summary.json").write_text(
        json.dumps(parsed["summary"], ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    if args.json:
        (out_dir / "manifest-parsed-assets.json").write_text(
            json.dumps(parsed["assetBundleRows"], ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        (out_dir / "manifest-parsed-bundles.json").write_text(
            json.dumps(parsed["bundles"], ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
    print(json.dumps(parsed["summary"], ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
