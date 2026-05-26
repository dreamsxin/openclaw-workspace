#!/usr/bin/env python3
"""Export VideoClip payloads from a YooAsset Unity bundle.

The game's recruit videos are Unity VideoClip assets whose actual mp4 bytes are
stored in sibling `.resource` streams inside the same UnityFS bundle.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import UnityPy


def xor_prefix(data: bytearray, prefix: int, key: int) -> None:
    for index in range(min(prefix, len(data))):
        data[index] ^= key


def safe_name(value: str) -> str:
    return "".join(ch if ch.isalnum() or ch in ("-", "_", ".") else "_" for ch in value)


def resource_key(source: str) -> str:
    # Unity stores this as archive:/CAB-.../CAB-....resource.
    return source.rsplit("/", 1)[-1]


def export_videos(bundle_path: Path, out_dir: Path, xor_prefix_len: int, xor_key: int) -> int:
    data = bytearray(bundle_path.read_bytes())
    if xor_prefix_len > 0:
        xor_prefix(data, xor_prefix_len, xor_key)

    env = UnityPy.load(bytes(data))
    out_dir.mkdir(parents=True, exist_ok=True)
    count = 0

    for obj in env.objects:
        if obj.type.name != "VideoClip":
            continue
        clip = obj.read()
        resource = getattr(clip, "m_ExternalResources", None)
        if resource is None:
            continue
        source = getattr(resource, "m_Source", "")
        size = int(getattr(resource, "m_Size", 0))
        offset = int(getattr(resource, "m_Offset", 0))
        if not source or size <= 0:
            continue

        resource_name = resource_key(source)
        stream = None
        for unity_file in env.files.values():
            files = getattr(unity_file, "files", {})
            if resource_name in files:
                stream = files[resource_name]
                break
        if stream is None:
            raise RuntimeError(f"Resource stream not found for {clip.m_Name}: {source}")

        payload = bytes(stream.bytes[offset : offset + size])
        ext = ".mp4" if payload[4:8] == b"ftyp" else ".bin"
        out_path = out_dir / f"{safe_name(clip.m_Name)}{ext}"
        out_path.write_bytes(payload)
        print(f"exported {clip.m_Name} -> {out_path} ({len(payload)} bytes)")
        count += 1

    return count


def main() -> None:
    parser = argparse.ArgumentParser(description="Export Unity VideoClip payloads from a YooAsset bundle.")
    parser.add_argument("bundle", type=Path, help="Path to YooAsset bundle __data file.")
    parser.add_argument("--out", type=Path, required=True, help="Output directory for extracted videos.")
    parser.add_argument("--xor-prefix", type=int, default=222, help="Number of leading bytes to XOR before parsing.")
    parser.add_argument("--xor-key", type=lambda value: int(value, 0), default=0x16, help="XOR key.")
    args = parser.parse_args()

    count = export_videos(args.bundle, args.out, args.xor_prefix, args.xor_key)
    print(f"done: {count} video(s)")


if __name__ == "__main__":
    main()
