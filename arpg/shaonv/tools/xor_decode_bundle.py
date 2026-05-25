#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
xor_decode_bundle.py — 通用 YooAsset XOR 解码并列出 bundle 内容

YooAsset 加密 bundle 的前 N 字节与密钥异或。解码后可用 UnityPy 读取。

默认参数 (shaonv 项目): prefix=222, key=0x16

用法:
  python tools/xor_decode_bundle.py <bundle_path> [--prefix 222] [--key 0x16]
  python tools/xor_decode_bundle.py <bundle_path> --list   (仅列出内容)
  python tools/xor_decode_bundle.py <bundle_path> --extract --out <dir>
"""

import os, sys, argparse, UnityPy


def xor_decode(path: str, prefix: int, key: int) -> bytes:
    data = bytearray(open(path, "rb").read())
    for i in range(min(prefix, len(data))):
        data[i] ^= key
    return bytes(data)


def list_contents(env: UnityPy.Environment):
    """打印 bundle 中所有资源的类型和名称"""
    count = 0
    for obj in env.objects:
        t = obj.type.name
        if t in ("Sprite", "Texture2D", "TextAsset", "GameObject", "MonoBehaviour", "Transform", "RectTransform"):
            count += 1
            data = obj.read()
            name = getattr(data, "m_Name", "") or getattr(data, "name", "")
            print(f"  [{t:16s}] {name}")
    print(f"\n  Total objects shown: {count}")


def extract_all(env: UnityPy.Environment, out_dir: str):
    """导出所有 Sprite/Texture2D 为 PNG"""
    os.makedirs(out_dir, exist_ok=True)
    count = 0
    for obj in env.objects:
        if obj.type.name == "Sprite":
            data = obj.read()
            name = getattr(data, "m_Name", "unnamed")
            out = os.path.join(out_dir, f"{name}.png")
            data.image.save(out)
            count += 1
        elif obj.type.name == "Texture2D" and hasattr(obj.read(), "image"):
            data = obj.read()
            name = getattr(data, "m_Name", "unnamed")
            out = os.path.join(out_dir, f"{name}.png")
            data.image.save(out)
            count += 1
    print(f"Extracted {count} images → {out_dir}")


def main():
    parser = argparse.ArgumentParser(description="YooAsset bundle XOR 解码工具")
    parser.add_argument("bundle", help="bundle 文件路径")
    parser.add_argument("--prefix", type=int, default=222, help="XOR 前缀字节数")
    parser.add_argument("--key", type=lambda v: int(v, 0), default=0x16, help="XOR 密钥 (支持 0x 前缀)")
    parser.add_argument("--list", action="store_true", help="仅列出 bundle 内容")
    parser.add_argument("--extract", action="store_true", help="导出所有图片")
    parser.add_argument("--out", default="tmp/bundle_export", help="导出目录")
    args = parser.parse_args()

    if not os.path.isfile(args.bundle):
        print(f"ERROR: {args.bundle} not found", file=sys.stderr)
        sys.exit(1)

    decoded = xor_decode(args.bundle, args.prefix, args.key)
    env = UnityPy.load(decoded)

    if args.list:
        list_contents(env)
    elif args.extract:
        extract_all(env, args.out)
    else:
        list_contents(env)


if __name__ == "__main__":
    main()
