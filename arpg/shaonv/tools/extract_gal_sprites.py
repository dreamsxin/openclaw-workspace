#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract_gal_sprites.py — 从 gal sprite atlas bundle 提取 PNG 资源到 Godot MVP

YooAsset XOR 解码参数: prefix=222, key=0x16

用法:
  python tools/extract_gal_sprites.py [--out-dir <path>]

来源:
  - resources/assets/yoo/Default/9b3005c642f23a035f900e91974d2f1f.bundle  (gal atlas)
  - resources/assets/yoo/Default/a96bd085ecfdfad6c0db3054c1036062.bundle  (gal_img_03)
  - resources/assets/yoo/Default/efb0c915b94a7323d062291be01f89c6.bundle  (gal_img_122)
"""

import os, sys, argparse, UnityPy

XOR_PREFIX = 222
XOR_KEY = 0x16

GAL_BUNDLES = [
    {
        "name": "gal atlas",
        "path": "resources/assets/yoo/Default/9b3005c642f23a035f900e91974d2f1f.bundle",
        "sprites": [
            "gal_btn_01", "gal_btn_02", "gal_btn_03", "gal_btn_04",
            "gal_btn_05", "gal_btn_06", "gal_btn_11", "gal_btn_12",
            "gal_btn_13", "gal_btn_14", "gal_btn_15", "gal_btn_16",
            "gal_btn_30", "gal_btn_31", "gal_btn_45", "gal_btn_46",
            "gal_img_04", "gal_img_05", "gal_img_06", "gal_img_07",
            "gal_img_08", "gal_img_09", "gal_img_125", "gal_img_126",
        ],
    },
    {
        "name": "gal_img_03",
        "path": "resources/assets/yoo/Default/a96bd085ecfdfad6c0db3054c1036062.bundle",
        "sprites": ["gal_img_03"],
    },
    {
        "name": "gal_img_122",
        "path": "resources/assets/yoo/Default/efb0c915b94a7323d062291be01f89c6.bundle",
        "sprites": ["gal_img_122"],
    },
]


def load_xor_bundle(path: str) -> UnityPy.Environment:
    """XOR decode and load Unity bundle."""
    data = bytearray(open(path, "rb").read())
    for i in range(min(XOR_PREFIX, len(data))):
        data[i] ^= XOR_KEY
    return UnityPy.load(bytes(data))


def extract_sprites(env: UnityPy.Environment, wanted: set, out_dir: str) -> int:
    """Extract named sprites from loaded bundle environment."""
    count = 0
    for obj in env.objects:
        if obj.type.name == "Sprite":
            data = obj.read()
            name = getattr(data, "m_Name", "")
            if name in wanted:
                out_path = os.path.join(out_dir, f"{name}.png")
                data.image.save(out_path)
                print(f"  {name}.png")
                count += 1
    return count


def main():
    parser = argparse.ArgumentParser(description="提取 Gal sprite 资源到 Godot MVP")
    parser.add_argument(
        "--out-dir",
        default="standalone/godot-mvp/assets/ui/gal",
        help="输出目录",
    )
    args = parser.parse_args()

    os.makedirs(args.out_dir, exist_ok=True)

    total = 0
    for bundle_info in GAL_BUNDLES:
        if not os.path.isfile(bundle_info["path"]):
            print(f"  SKIP: {bundle_info['name']} — bundle not found at {bundle_info['path']}")
            continue
        env = load_xor_bundle(bundle_info["path"])
        wanted = set(bundle_info["sprites"])
        extracted = extract_sprites(env, wanted, args.out_dir)
        print(f"  {bundle_info['name']}: {extracted}/{len(bundle_info['sprites'])}")
        total += extracted

    print(f"\nTotal: {total} sprites → {args.out_dir}")


if __name__ == "__main__":
    main()
