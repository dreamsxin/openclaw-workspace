#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
categorize_lang_keys.py — 将 lang_extra.bytes UI 键按数字范围分类

分类规则:
  1-19999   通用对话框/提示
  20000-29999 设置/通知
  30000-39999 个人信息/英雄
  40000-49999 商店/增益
  50000-59999 详情/升级
  60000-69999 建筑解锁
  70000-79999 公会
  80000-89999 聊天/邮件
  90000-99999 特殊/格式化
  100000-109999 活动/作战
  110000-119999 订阅/奖励
  120000-129999 章节进度
  200000-209999 活动弹窗
  300000-399999 道具/品质
  400000-499999 购买确认
  900000-999999 系统提示
  1000000+    主页/子系统

用法:
  python tools/categorize_lang_keys.py [--parsed <path>] [--out <path>]
"""

import json, os, sys, argparse, re
from collections import defaultdict

CATEGORY_RULES = [
    (0,      13,      "底部导航栏"),    # exact keys: UI1000001-UI1000013
    (1,      19999,   "通用对话框/提示"),
    (20000,  29999,   "设置/通知"),
    (30000,  39999,   "个人信息/英雄"),
    (40000,  49999,   "商店/增益"),
    (50000,  59999,   "详情/升级"),
    (60000,  69999,   "建筑解锁"),
    (70000,  79999,   "公会"),
    (80000,  89999,   "聊天/邮件"),
    (90000,  99999,   "特殊/格式化"),
    (100000, 109999,  "活动/作战"),
    (110000, 119999,  "订阅/奖励"),
    (120000, 129999,  "章节进度"),
    (200000, 209999,  "活动弹窗"),
    (300000, 399999,  "道具/品质"),
    (400000, 499999,  "购买确认"),
    (900000, 999999,  "系统提示"),
    (1000000, 99999999, "主页/子系统"),
]

# 底部导航硬编码键
BOTTOM_NAV_KEYS = {
    "UI1000001", "UI1000002", "UI1000003", "UI1000005",
    "UI1000007", "UI1000009", "UI1000013",
}


def categorize(entries: list) -> dict:
    """按数字范围分类"""
    cats = defaultdict(list)
    for k, v in entries:
        if k in BOTTOM_NAV_KEYS:
            cats["底部导航栏"].append((k, v))
            continue
        if not k.startswith("UI"):
            continue
        num_str = k[2:]
        if not num_str.isdigit():
            continue
        num = int(num_str)
        for lo, hi, name in CATEGORY_RULES:
            if name == "底部导航栏":
                continue
            if lo <= num <= hi:
                cats[name].append((k, v))
                break
    return dict(cats)


def main():
    parser = argparse.ArgumentParser(description="按功能分类 lang_extra 键")
    parser.add_argument(
        "--parsed",
        default="reverse-output/story-texts/lang_extra_parsed.json",
        help="已解析的 lang_extra JSON",
    )
    parser.add_argument(
        "--out",
        default="reverse-output/story-texts/lang_extra_categorized.json",
        help="输出分类 JSON",
    )
    args = parser.parse_args()

    if not os.path.isfile(args.parsed):
        print(f"ERROR: {args.parsed} not found. Run parse_lang_bytes.py first.", file=sys.stderr)
        sys.exit(1)

    with open(args.parsed, "r", encoding="utf-8") as f:
        entries = json.load(f)

    cats = categorize(entries)

    total = sum(len(v) for v in cats.values())
    print(f"  Total entries: {len(entries)}")
    print(f"  Categorized: {total}")
    for name in sorted(cats, key=lambda x: -len(cats[x])):
        print(f"    {name}: {len(cats[name])}")

    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(cats, f, ensure_ascii=False, indent=2)
    print(f"  → {args.out}")


if __name__ == "__main__":
    main()
