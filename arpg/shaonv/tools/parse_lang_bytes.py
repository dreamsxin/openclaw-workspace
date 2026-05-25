#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
parse_lang_bytes.py — 解析 lang.bytes / lang_extra.bytes 语言包文件

Unity TextAsset JSON 格式:
  {"lang": ["key1=value1", "key2=value2", ...]}

输出:
  reverse-output/story-texts/lang_parsed.json
  reverse-output/story-texts/lang_extra_parsed.json

用法:
  python tools/parse_lang_bytes.py [--raw-dir <path>] [--out-dir <path>]
"""

import json, os, sys, argparse

LANG_FILES = [
    ("lang.bytes", "lang_parsed.json"),
    ("lang_extra.bytes", "lang_extra_parsed.json"),
]


def parse_lang_file(filepath: str) -> list:
    """解析单个 lang.bytes 文件，返回 [(key, value), ...]"""
    with open(filepath, "r", encoding="utf-8-sig") as f:
        data = json.load(f)

    entries = data.get("lang", [])
    parsed = []
    for e in entries:
        if "=" in e:
            key, val = e.split("=", 1)
            parsed.append((key, val))
    return parsed


def main():
    parser = argparse.ArgumentParser(description="解析 lang.bytes 语言包")
    parser.add_argument(
        "--raw-dir",
        default="reverse-output/assets/story-textassets-raw/by_container/Assets/Game/Lang",
        help="lang.bytes 所在目录",
    )
    parser.add_argument(
        "--out-dir",
        default="reverse-output/story-texts",
        help="输出目录",
    )
    args = parser.parse_args()

    os.makedirs(args.out_dir, exist_ok=True)

    for fname, outname in LANG_FILES:
        fpath = os.path.join(args.raw_dir, fname)
        if not os.path.isfile(fpath):
            print(f"ERROR: {fpath} not found", file=sys.stderr)
            continue
        parsed = parse_lang_file(fpath)
        outpath = os.path.join(args.out_dir, outname)
        with open(outpath, "w", encoding="utf-8") as f:
            json.dump(parsed, f, ensure_ascii=False, indent=2)
        print(f"  {fname}: {len(parsed)} entries → {outpath}")


if __name__ == "__main__":
    main()
