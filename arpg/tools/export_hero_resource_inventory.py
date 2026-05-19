#!/usr/bin/env python3
"""Build a reusable hero resource inventory for the nvshen Godot demo."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


KNOWN_HEROES = {
    "105004": {"name": "伊卡洛斯", "camp": 4, "job": "灵师", "power": "3027113", "level": "120", "stars": 5, "combat": True},
    "205008": {"name": "苏拉", "camp": 2, "job": "战士", "power": "2864100", "level": "108", "stars": 5, "assist": True},
    "305006": {"name": "尤朵拉", "camp": 1, "job": "射手", "power": "2719800", "level": "104", "stars": 5},
    "405007": {"name": "拉瑞欧", "camp": 3, "job": "守护", "power": "2339000", "level": "96", "stars": 5},
    "505004": {"name": "诺萨", "camp": 5, "job": "刺客", "power": "2188000", "level": "92", "stars": 5, "red": True},
    "204002": {"name": "艾琳", "camp": 1, "job": "辅助", "power": "2013000", "level": "88", "stars": 5},
    "104002": {"name": "莉莉", "camp": 2, "job": "法师", "power": "1884000", "level": "84", "stars": 5},
    "504002": {"name": "奥斯曼", "camp": 5, "job": "守护", "power": "1722000", "level": "80", "stars": 3, "owned": False},
    "304001": {"name": "米莉娅", "camp": 3, "job": "射手", "power": "1699000", "level": "78", "stars": 3, "owned": False},
    "204001": {"name": "阿瓦隆", "camp": 1, "job": "战士", "power": "1586000", "level": "76", "stars": 3, "owned": False},
}

QUALITY_ORDER = {"SSS": 0, "SSR": 1, "SR": 2, "R": 3, "N": 4}
QUALITY_STARS = {"SSS": 5, "SSR": 5, "SR": 4, "R": 3, "N": 2}
QUALITY_LEVEL = {"SSS": 120, "SSR": 100, "SR": 80, "R": 60, "N": 40}
QUALITY_POWER = {"SSS": 3000000, "SSR": 2200000, "SR": 1300000, "R": 650000, "N": 250000}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", default=r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
    parser.add_argument("--source", default=r"D:\work\openclaw-workspace\arpg\nvshenres")
    return parser.parse_args()


def load_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def add_numeric(store: set[str], prefix: str, value: str) -> str | None:
    if not value.startswith(prefix):
        return None
    item_id = value[len(prefix) :].split("/", 1)[0]
    if item_id.isdigit():
        store.add(item_id)
        return item_id
    return None


def is_base_hero_id(value: str) -> bool:
    return value.isdigit() and len(value) == 6


def infer_base_id(value: str, base_ids: set[str]) -> str | None:
    if is_base_hero_id(value):
        return value
    if value.isdigit() and len(value) > 6 and value[:6] in base_ids:
        return value[:6]
    return None


def infer_quality(record: dict) -> str:
    if record["has_hero_book"] and record["has_lh_prefab"] and record["cv_count"] >= 8:
        return "SSS"
    if record["has_hero_book"] and record["cv_count"] >= 8:
        return "SSR"
    if record["has_hero_book"]:
        return "SR"
    if record["has_head"]:
        return "R"
    return "N"


def fallback_camp(hero_id: str) -> int:
    if hero_id and hero_id[0].isdigit():
        return max(1, min(5, int(hero_id[0])))
    return 0


def make_catalog_entry(record: dict, index: int) -> dict:
    hero_id = record["id"]
    quality = record["quality"]
    known = dict(KNOWN_HEROES.get(hero_id, {}))
    entry = {
        "id": hero_id,
        "name": known.get("name", f"英雄{hero_id}"),
        "quality": quality,
        "grade": {"SSS": 5, "SSR": 4, "SR": 3, "R": 2, "N": 1}.get(quality, 1),
        "camp": int(known.get("camp", fallback_camp(hero_id))),
        "job": known.get("job", "未知"),
        "power": str(known.get("power", max(10000, QUALITY_POWER[quality] - index * 17321))),
        "level": str(known.get("level", QUALITY_LEVEL[quality])),
        "stars": int(known.get("stars", QUALITY_STARS[quality])),
        "owned": bool(known.get("owned", record["has_hero_book"])),
        "has_head": record["has_head"],
        "has_hero_book": record["has_hero_book"],
        "has_lh_prefab": record["has_lh_prefab"],
        "has_battle_prefab": record["has_battle_prefab"],
        "cv_count": record["cv_count"],
        "skins": record["skins"],
    }
    for key in ("combat", "assist", "red"):
        if key in known:
            entry[key] = known[key]
    return entry


def main() -> None:
    args = parse_args()
    project = Path(args.project)
    config_path = project / "assets" / "resources" / "config.json"
    named_path = project / "data" / "named_resource_index.json"
    paths = load_json(config_path)["paths"]
    named = load_json(named_path)

    heads: set[str] = set()
    hero_books: set[str] = set()
    skin_images: set[str] = set()
    lh_prefabs: set[str] = set()
    battle_prefabs: set[str] = set()
    cv: dict[str, set[str]] = {}

    for resource_name in named.keys():
        add_numeric(heads, "image/head/", resource_name)
        add_numeric(hero_books, "image/heroBook/", resource_name)
        add_numeric(skin_images, "image/skin/showImg/", resource_name)

    for item in paths.values():
        if not item:
            continue
        resource_path = str(item[0])
        add_numeric(heads, "image/head/", resource_path)
        add_numeric(hero_books, "image/heroBook/", resource_path)
        add_numeric(skin_images, "image/skin/showImg/", resource_path)
        add_numeric(lh_prefabs, "Prefab/HerolhPrefab/", resource_path)
        add_numeric(battle_prefabs, "Prefab/HeroPrefab/", resource_path)
        if resource_path.startswith("sound/cv/"):
            parts = resource_path.split("/")
            if len(parts) >= 4 and parts[2].isdigit():
                cv.setdefault(parts[2], set()).add(parts[3])

    base_ids = {x for x in heads | hero_books | lh_prefabs | battle_prefabs | set(cv.keys()) if is_base_hero_id(x)}
    skin_map = {hero_id: [] for hero_id in base_ids}
    for skin_id in sorted(skin_images | hero_books | heads):
        base_id = infer_base_id(skin_id, base_ids)
        if base_id and skin_id != base_id:
            skin_map.setdefault(base_id, []).append(skin_id)

    records = []
    for hero_id in sorted(base_ids):
        record = {
            "id": hero_id,
            "has_head": hero_id in heads,
            "has_hero_book": hero_id in hero_books,
            "has_lh_prefab": hero_id in lh_prefabs,
            "has_battle_prefab": hero_id in battle_prefabs,
            "cv_count": len(cv.get(hero_id, set())),
            "cv_ids": sorted(cv.get(hero_id, set()), key=lambda x: (len(x), x)),
            "skins": sorted(set(skin_map.get(hero_id, []))),
        }
        record["quality"] = infer_quality(record)
        records.append(record)

    records.sort(key=lambda item: (QUALITY_ORDER[item["quality"]], item["id"]))
    catalog = [make_catalog_entry(record, index) for index, record in enumerate(records)]

    summary = {
        "source": {
            "config": str(config_path),
            "named_resource_index": str(named_path),
            "original_root": str(Path(args.source)),
        },
        "counts": {
            "base_heroes": len(records),
            "heads": len([x for x in heads if is_base_hero_id(x)]),
            "hero_books": len([x for x in hero_books if is_base_hero_id(x)]),
            "lh_prefabs": len([x for x in lh_prefabs if is_base_hero_id(x)]),
            "battle_prefabs": len([x for x in battle_prefabs if is_base_hero_id(x)]),
            "cv_heroes": len([x for x in cv.keys() if is_base_hero_id(x)]),
            "skin_images": len(skin_images),
        },
        "quality_rule": {
            "SSS": "has image/heroBook, Prefab/HerolhPrefab, and at least 8 sound/cv clips",
            "SSR": "has image/heroBook and at least 8 sound/cv clips",
            "SR": "has image/heroBook",
            "R": "has image/head only",
            "N": "other base hero id resources",
        },
        "heroes": records,
    }

    data_dir = project / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    (data_dir / "hero_resource_inventory.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (data_dir / "hero_catalog.json").write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = [
        "# 女神降临英雄资源分析",
        "",
        "本文档由 `arpg/tools/export_hero_resource_inventory.py` 生成，用于记录原始 Cocos 资源到 Godot 本地 Demo 的英雄目录还原依据。",
        "",
        "## 资源入口",
        "",
        f"- Cocos 资源表：`{config_path}`，其中 `paths` 记录逻辑路径，例如 `image/head/<id>`、`image/heroBook/<id>`、`Prefab/HerolhPrefab/<id>`、`Prefab/HeroPrefab/<id>`、`sound/cv/<id>/<soundId>`。",
        f"- Godot 图片索引：`{named_path}`，由解密资源导出，记录 SpriteFrame/native PNG 对应关系。",
        "- 反编译源码里英雄格子、图鉴、详情页使用 `grade/camp/body` 字段：`HeroGridCom`、`HeroBookItemPre`、`HeroBookDetailPanel` 调用 `HeroConstant.heroBigTagArr[n.grade]`、`heroCampSmallArr[n.camp]` 和 `playHeroSound(body, soundId)`。",
        "",
        "## 离线品质推断",
        "",
        "当前导出的 JS 中没有完整静态英雄表，因此本地 Demo 先按资源完整度推断品质，后续如果找到原表可直接替换 `data/hero_catalog.json` 的 `quality/grade/name/camp/job` 字段。",
        "",
        "| 品质 | 推断规则 |",
        "| --- | --- |",
        "| SSS | 有 `image/heroBook`、`Prefab/HerolhPrefab`，并且 `sound/cv` 数量不少于 8 |",
        "| SSR | 有 `image/heroBook`，并且 `sound/cv` 数量不少于 8 |",
        "| SR | 有 `image/heroBook` |",
        "| R | 只有头像等基础资源 |",
        "| N | 其他 6 位英雄 id 资源 |",
        "",
        "## 统计",
        "",
        f"- 基础英雄 id：{summary['counts']['base_heroes']}",
        f"- 头像 `image/head`：{summary['counts']['heads']}",
        f"- 图鉴立绘 `image/heroBook`：{summary['counts']['hero_books']}",
        f"- 主立绘 Prefab `Prefab/HerolhPrefab`：{summary['counts']['lh_prefabs']}",
        f"- 战斗 Prefab `Prefab/HeroPrefab`：{summary['counts']['battle_prefabs']}",
        f"- 有语音目录 `sound/cv` 的英雄：{summary['counts']['cv_heroes']}",
        f"- 衣装/展示图 `image/skin/showImg`：{summary['counts']['skin_images']}",
        "",
        "## 英雄目录",
        "",
        "| 品质 | 英雄ID | 名称 | 头像 | 图鉴 | 立绘Prefab | 战斗Prefab | 语音数 | 皮肤/变体 |",
        "| --- | --- | --- | --- | --- | --- | --- | ---: | --- |",
    ]
    catalog_by_id = {item["id"]: item for item in catalog}
    for record in records:
        entry = catalog_by_id[record["id"]]
        lines.append(
            "| {quality} | {id} | {name} | {head} | {book} | {lh} | {battle} | {cv} | {skins} |".format(
                quality=record["quality"],
                id=record["id"],
                name=entry["name"],
                head="Y" if record["has_head"] else "-",
                book="Y" if record["has_hero_book"] else "-",
                lh="Y" if record["has_lh_prefab"] else "-",
                battle="Y" if record["has_battle_prefab"] else "-",
                cv=record["cv_count"],
                skins=", ".join(record["skins"][:6]) + (" ..." if len(record["skins"]) > 6 else ""),
            )
        )
    lines.extend(
        [
            "",
            "## Godot 使用",
            "",
            "- 英雄列表读取 `res://data/hero_catalog.json`，按 `SSS > SSR > SR > R > N` 排序。",
            "- 资源分析完整结果在 `res://data/hero_resource_inventory.json`，用于继续补角色名、阵营、职业、真实 grade。",
            "- 已人工确认的英雄名会覆盖自动名称，其余暂用 `英雄<id>`，避免阻塞完整列表展示。",
        ]
    )
    (project / "HERO_RESOURCE_INVENTORY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {len(catalog)} heroes")
    print(json.dumps(summary["counts"], ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
