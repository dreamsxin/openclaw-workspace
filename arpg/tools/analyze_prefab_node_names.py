#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
LAYOUT_DIR = ROOT / "data" / "prefab_layouts"
OUT_PATH = ROOT / "data" / "prefab_node_name_hints.json"

TOKEN_HINTS = {
    "zjm": "主界面",
    "zh": "召唤",
    "zhaohuan": "召唤",
    "gh": "公会",
    "gonghui": "公会",
    "cm": "通用",
    "background": "背景",
    "btn": "按钮",
    "icon": "图标",
    "image": "图片",
    "img": "图片",
    "frame": "框",
    "bg": "背景",
    "bj": "背景",
    "di": "底板",
    "diban": "底板",
    "rukou": "入口",
    "guangao": "广告",
    "guanggao": "广告",
    "guang": "广告",
    "gonggao": "公告",
    "haoyou": "好友",
    "youjian": "邮件",
    "paihang": "排行",
    "xinwen": "新闻",
    "zhanbao": "战报",
    "kefu": "客服",
    "fanhui": "返回",
    "back": "返回",
    "shop": "商店",
    "shangdian": "商店",
    "shanghui": "商会",
    "baoju": "宝具",
    "cangku": "仓库",
    "jingji": "竞技",
    "xueyuan": "学院",
    "yinghun": "英魂",
    "duanzao": "锻造",
    "zhanbu": "占卜",
    "xunxing": "寻星",
    "tianti": "天梯",
    "huodong": "活动",
    "fuli": "福利",
    "libao": "礼包",
    "daily": "每日",
    "meirilibao": "每日礼包",
    "kaifu": "开服",
    "first": "首充",
    "star": "升星",
    "shengxing": "升星",
    "juhui": "钜惠",
    "skin": "衣装",
    "pass": "通行证",
    "pvp": "PVP",
    "call": "召唤",
    "dh": "兑换",
    "duihuan": "兑换",
    "tj": "推荐",
    "zhh": "转换",
    "yl": "预览",
    "help": "帮助",
    "tip": "提示",
    "tabs": "页签",
    "tab": "页签",
    "txt": "文本",
    "lbl": "文本",
    "label": "文本",
    "progress": "进度",
    "bar": "进度条",
    "box": "容器/宝箱",
    "hero": "英雄",
    "heroui": "英雄展示UI",
    "magic": "Spine/特效",
    "content": "内容容器",
    "hongdian": "红点",
    "red": "红点",
    "time": "时间",
    "free": "免费",
    "up": "UP",
    "abs": "活动",
    "xianzhi": "限定",
    "tianming": "天命",
    "putong": "普通",
    "gaoji": "高级",
    "youqing": "友情",
    "ssr": "SSR",
}


CAMEL_BOUNDARY = re.compile(r"(?<=[a-z0-9])(?=[A-Z])")
SEPARATORS = re.compile(r"[^A-Za-z0-9\u4e00-\u9fff]+")


def tokenize(name: str) -> list[str]:
    normalized = CAMEL_BOUNDARY.sub("_", name)
    tokens = []
    for part in SEPARATORS.split(normalized):
        if not part:
            continue
        tokens.append(part.lower())
    return tokens


def hints_for_name(name: str) -> list[str]:
    hints: list[str] = []
    for token in tokenize(name):
        candidates = [token]
        without_digits = token.rstrip("0123456789")
        if without_digits and without_digits != token:
            candidates.append(without_digits)
        for candidate in candidates:
            if candidate in TOKEN_HINTS and TOKEN_HINTS[candidate] not in hints:
                hints.append(TOKEN_HINTS[candidate])
        for key, hint in TOKEN_HINTS.items():
            if key in {"back"}:
                continue
            if len(key) >= 5 and key in token and hint not in hints:
                hints.append(hint)
    return hints


def summarize_node(node: dict) -> dict:
    name = str(node.get("name", ""))
    return {
        "name": name,
        "hints": hints_for_name(name),
        "global_position": node.get("global_position", []),
        "size": node.get("size", []),
        "label_text": node.get("label_text", ""),
        "texture_path": node.get("texture_path", ""),
    }


def analyze_layout(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    nodes = []
    hint_counts: Counter[str] = Counter()
    for node in data.get("nodes", []):
        if not isinstance(node, dict):
            continue
        item = summarize_node(node)
        if not item["hints"] and not item["label_text"]:
            continue
        nodes.append(item)
        hint_counts.update(item["hints"])
    return {
        "prefab": path.stem,
        "node_count": len(data.get("nodes", [])),
        "hint_counts": dict(hint_counts.most_common()),
        "nodes": nodes,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Infer Cocos prefab node usage from pinyin-like node names.")
    parser.add_argument("--layout-dir", type=Path, default=LAYOUT_DIR)
    parser.add_argument("--out", type=Path, default=OUT_PATH)
    parser.add_argument("--prefab", action="append", help="Analyze only this layout stem or json filename.")
    args = parser.parse_args()

    wanted = None
    if args.prefab:
        wanted = {Path(item).stem for item in args.prefab}

    layouts = sorted(args.layout_dir.glob("*.json"))
    result = {}
    for layout in layouts:
        if wanted is not None and layout.stem not in wanted:
            continue
        result[layout.stem] = analyze_layout(layout)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {args.out} ({len(result)} prefabs)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
