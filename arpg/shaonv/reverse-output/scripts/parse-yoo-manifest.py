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
import re
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

    def u64(self) -> int:
        self.require(8)
        value = struct.unpack_from("<Q", self.data, self.off)[0]
        self.off += 8
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


def index_physical_files(paths: list[Path]) -> dict[str, dict[str, Any]]:
    files: dict[str, dict[str, Any]] = {}
    for root in paths:
        if not root.exists():
            continue
        candidates = [root] if root.is_file() else root.rglob("*")
        for path in candidates:
            if not path.is_file():
                continue
            record = {
                "physicalPath": str(path),
                "physicalSize": path.stat().st_size,
            }
            files[path.name.lower()] = record
            # YooAsset runtime cache stores downloaded bundles as:
            #   BundleFiles/<first-two-hash-chars>/<hash>/__data
            # and the hash directory name is the manifest fileHash.
            if path.name == "__data" and path.parent.name:
                files[f"{path.parent.name.lower()}.bundle"] = record
                files[path.parent.name.lower()] = record
    return files


def parse_manifest(path: Path, physical_roots: list[Path] | None = None) -> dict[str, Any]:
    physical_files = index_physical_files(physical_roots or [])
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
    # bundle records. Align once to the first logical bundle name, then parse
    # records sequentially. Bundle fileSize is uint64 in YooAsset 2.3.1; using
    # uint32 shifts encrypted/tags/dependency fields and corrupts later rows.
    bundle_header_start = reader.off
    bundle_header_skipped = reader.align_to_prefixed_string(b"assets_", b".bundle")
    bundle_lookup_header = reader.data[bundle_header_start : bundle_header_start + bundle_header_skipped].hex()
    bundles = []
    bundle_id = 0
    while bundle_id < bundle_count:
        record_offset = reader.off
        try:
            bundle_name = reader.string()
            unity_crc = reader.u32()
            file_hash = reader.string()
            file_crc = reader.string()
            file_size = reader.u64()
            encrypted = bool(reader.u8())
            tags = reader.string_array()
            depend_bundle_ids = reader.int_array()
        except Exception as exc:
            raise ValueError(f"failed parsing bundle #{bundle_id} at offset {record_offset}") from exc
        file_name = remote_file_name(int(manifest["outputNameStyle"]), bundle_name, file_hash)
        hash_file_name = f"{file_hash}{Path(bundle_name).suffix}"
        physical = (
            physical_files.get(file_name.lower())
            or physical_files.get(hash_file_name.lower())
            or physical_files.get(bundle_name.lower())
            or {}
        )
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
                "fileName": file_name,
                "hashFileName": hash_file_name,
                "physicalPath": physical.get("physicalPath", ""),
                "physicalSize": physical.get("physicalSize", ""),
                "physicalExists": bool(physical),
                "physicalSizeMatches": bool(physical) and int(physical.get("physicalSize", -1)) == int(file_size),
                "bundleLookupHeader": bundle_lookup_header,
            }
        )
        bundle_id += 1

    bundle_id_offset = infer_bundle_id_offset(assets, bundles)
    rows = []
    for asset in assets:
        resolved_bundle_id = asset["bundleID"] + bundle_id_offset
        bundle = bundles[resolved_bundle_id] if 0 <= resolved_bundle_id < len(bundles) else {}
        rows.append(
            {
                **asset,
                "resolvedBundleID": resolved_bundle_id if bundle else "",
                "bundleIDOffset": bundle_id_offset,
                "bundleName": bundle.get("bundleName", ""),
                "fileName": bundle.get("fileName", ""),
                "hashFileName": bundle.get("hashFileName", ""),
                "fileHash": bundle.get("fileHash", ""),
                "fileCRC": bundle.get("fileCRC", ""),
                "fileSize": bundle.get("fileSize", ""),
                "encrypted": bundle.get("encrypted", ""),
                "physicalPath": bundle.get("physicalPath", ""),
                "physicalSize": bundle.get("physicalSize", ""),
                "physicalExists": bundle.get("physicalExists", ""),
                "physicalSizeMatches": bundle.get("physicalSizeMatches", ""),
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
            "physicalFilesIndexed": len(physical_files),
            "bundlesWithPhysicalFile": sum(1 for bundle in bundles if bundle.get("physicalExists")),
            "bundlesWithPhysicalSizeMatch": sum(1 for bundle in bundles if bundle.get("physicalSizeMatches")),
            "bundleIDOffset": bundle_id_offset,
            "endOffset": reader.off,
            "fileSize": len(reader.data),
        },
    }


def infer_bundle_id_offset(assets: list[dict[str, Any]], bundles: list[dict[str, Any]]) -> int:
    """Infer manifest asset bundleID base against the parsed bundle array.

    This shaonv manifest stores asset.bundleID in an external numbering space.
    Matching obvious asset path tokens against bundle names gives a stable
    offset of -133 for this package, but keep the inference generic and
    auditable instead of hardcoding it.
    """

    best_offset = 0
    best_score = -1
    for offset in range(-512, 513):
        score = 0
        for asset in assets:
            resolved = int(asset["bundleID"]) + offset
            if not 0 <= resolved < len(bundles):
                continue
            address = str(asset.get("address") or asset.get("assetPath") or "").lower()
            bundle_name = str(bundles[resolved].get("bundleName") or "").lower()
            if not address or not bundle_name:
                continue
            leaf = Path(address).stem.lower().replace("_", "")
            compact_bundle = bundle_name.replace("_", "")
            if leaf and leaf in compact_bundle:
                score += 3
            spine_match = re.search(r"spine/hero/(hero_[^/]+)/", address)
            if spine_match and spine_match.group(1).replace("_", "") in compact_bundle:
                score += 10
            if "prefabs/ui/" in address:
                parent = Path(address).parent.name.lower().replace("_", "")
                if parent and parent in compact_bundle:
                    score += 5
            if address.startswith("assets/game/static/") and "static" in bundle_name:
                score += 1
        if score > best_score:
            best_score = score
            best_offset = offset
    return best_offset


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest")
    parser.add_argument("out_dir")
    parser.add_argument(
        "--physical-root",
        action="append",
        default=[],
        help="Folder or file to index for fileName/hashFileName physical bundle lookup; may be repeated",
    )
    parser.add_argument("--json", action="store_true", help="Also write large JSON files for assets/bundles")
    args = parser.parse_args()

    parsed = parse_manifest(Path(args.manifest), [Path(item) for item in args.physical_root])
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
            "resolvedBundleID",
            "bundleIDOffset",
            "bundleName",
            "fileName",
            "hashFileName",
            "fileHash",
            "fileCRC",
            "fileSize",
            "encrypted",
            "physicalPath",
            "physicalSize",
            "physicalExists",
            "physicalSizeMatches",
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
            "hashFileName",
            "fileHash",
            "fileCRC",
            "fileSize",
            "encrypted",
            "physicalPath",
            "physicalSize",
            "physicalExists",
            "physicalSizeMatches",
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
