#!/usr/bin/env python3
"""Export gacha, hero, skin, and character resource tables.

The input static files are MemoryPack arrays exported from Unity TextAsset
objects.  Field order is taken from the decompiled *StaticItem formatters.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path
from typing import Any


SCHEMAS: dict[str, list[tuple[str, str]]] = {
    "drawconfig": [
        ("id", "i32"), ("cycleTime", "i32"), ("rewardShow", "str"), ("showId", "i32"),
        ("type", "i32"), ("drawType", "str"), ("name", "str"), ("titlePic", "str"),
        ("dayLimit", "i32"), ("oncecond", "str"), ("continuouscond", "str"),
        ("generalItem", "str"), ("gold", "i32"), ("tendrawCost", "i32"),
        ("goldtype", "i32"), ("continuousrewardtimes", "i32"), ("free", "i32"),
        ("cdtime", "i32"), ("integral", "i32"), ("integralDraw", "str"),
        ("reward2", "str"), ("reward3", "str"), ("reward1", "str"), ("cnt4", "i32"),
        ("reward4", "str"), ("cntF", "i32"), ("rewardF2", "str"), ("cntF2", "i32"),
        ("noCnt2", "i32"), ("cnt2", "i32"), ("cnt3", "i32"), ("wishListHero", "str"),
        ("showHero", "str"), ("wishListNum", "i32"), ("rateUp", "str"),
        ("wishListOpen", "str"), ("wishListStage", "str"), ("sort", "i32"),
        ("buttonUnlock", "i32"), ("isShow", "str"), ("decide", "i32"),
        ("stageReward", "str"), ("condition", "str"), ("skipAnimeType", "i32"),
        ("skipAnimeLevel", "i32"), ("describe", "str"), ("pic", "str"),
        ("levelLimit", "i32"), ("openServerDay", "i32"), ("vipUnlock", "i32"),
        ("coin", "i32"), ("exchange", "str"), ("cntUp", "i32"),
        ("probabilityUp", "i32"), ("reward", "str"),
    ],
    "ac_limit_draw": [
        ("id", "i32"), ("urDraw", "str"), ("isUr", "i32"), ("name", "str"),
        ("heroShow", "i32"), ("probabilityShow", "i32"), ("levelLimit", "i32"),
        ("dayLimit", "i32"), ("oncecond", "str"), ("continuouscond", "str"),
        ("generalItem", "str"), ("gold", "i32"), ("goldtype", "i32"),
        ("goldTime", "i32"), ("continuousrewardtimes", "i32"), ("tendrawCost", "i32"),
        ("continuousgoldTime", "i32"), ("free", "i32"), ("cdTime", "i32"),
        ("rewardShow", "i32"), ("reward2", "str"), ("reward3", "str"),
        ("reward1", "str"), ("reward4", "str"), ("cntF", "i32"), ("rewardF2", "str"),
        ("cntF2", "i32"), ("cnt2", "i32"), ("cnt3", "i32"), ("cnt4", "i32"),
        ("wishListStage", "str"), ("wishListHero", "str"), ("wishListNum", "i32"),
        ("rateUp", "str"), ("wishListOpen", "str"), ("wishLimit", "i32"),
    ],
    "ac_limit_drawconfig": [
        ("id", "i32"), ("cycle", "i32"), ("param", "str"), ("growupHero", "str"),
        ("growupGift", "str"), ("showGrowupGift", "str"), ("order", "i32"),
        ("quest", "str"), ("gameShop", "i32"), ("icon", "str"), ("titlePic", "str"),
        ("bgPic", "str"), ("growupBgPic", "str"), ("condition", "str"),
        ("des", "str"), ("pageShow", "str"),
    ],
    "ac_draw_gift": [
        ("id", "i32"), ("cycleTime", "i32"), ("quest", "str"), ("spine", "str"),
        ("size", "str"), ("posX", "str"), ("posY", "str"),
    ],
    "crazy_draw": [
        ("id", "i32"), ("condition", "str"), ("reward1", "i32"), ("reward2", "i32"),
        ("reward3", "i32"), ("reward4", "i32"), ("hero1", "i32"), ("hero2", "i32"),
        ("hero3", "i32"), ("hero4", "i32"),
    ],
    "draw_integral_reward": [("id", "i32"), ("type", "i32"), ("para", "i32"), ("reward", "str")],
    "draw_sound": [("id", "str"), ("delay", "str"), ("bgm", "str")],
    "integral_draw": [
        ("id", "i32"), ("pic", "str"), ("des", "str"), ("name", "str"),
        ("cost", "i32"), ("rewardShow", "i32"), ("reward", "i32"),
    ],
    "hero": [
        ("id", "i32"), ("occupation", "i32"), ("heroType", "i32"), ("rare", "i32"),
        ("rare2", "i32"), ("rare3", "i32"), ("isShow", "i32"), ("isAdvanced", "i32"),
        ("advanced", "i32"), ("advancedGoods", "str"), ("advancedSkin", "i32"),
        ("mimicry", "i32"), ("evolution", "i32"), ("exclusiveGift", "str"),
        ("recruitItem", "str"), ("goodExp", "str"), ("extraCost", "str"),
        ("goodLimit", "i32"), ("max", "str"), ("maxSkill", "str"),
        ("development", "str"), ("skillLimit", "i32"), ("normalAttack", "i32"),
        ("skill1", "i32"), ("skill2", "i32"), ("skill3", "i32"), ("skill4", "i32"),
        ("changeLimit", "i32"), ("skin", "str"), ("slugRecommend", "str"),
        ("recruitVideo", "str"), ("attackAuto", "str"), ("flyObj", "str"),
        ("hitEff", "str"), ("powerStar", "i32"), ("powerIcon", "str"),
        ("npcPic", "i32"), ("favorLimit", "i32"), ("favorGoods", "str"),
        ("name", "str"), ("jName", "str"), ("tName", "str"), ("label", "str"),
        ("recruit", "str"), ("number", "str"), ("myth", "str"), ("poewr", "str"),
        ("career", "str"), ("personality", "str"), ("hobby", "str"),
        ("birthday", "str"), ("description", "str"), ("story1", "str"),
        ("story2", "str"), ("story3", "str"), ("height", "str"), ("birth", "str"),
        ("age", "str"), ("birthplace", "str"), ("hate", "str"), ("sex", "str"),
        ("coreAttribute", "i32"), ("fightStyle", "i32"),
    ],
    "hero_skin": [
        ("id", "i32"), ("_default", "i32"), ("order", "i32"), ("hero", "str"),
        ("cost", "str"), ("effect", "str"), ("specialShow", "str"), ("showItem", "str"),
        ("unlockSkin", "str"), ("skinName", "str"), ("skinDes", "str"),
        ("skinIcon", "str"), ("skinSize", "str"), ("careType", "i32"),
        ("block", "str"), ("shop", "i32"), ("price", "i32"), ("shopSkin", "str"),
        ("x1", "i32"), ("y1", "i32"), ("x2", "i32"), ("y2", "i32"),
        ("x3", "i32"), ("y3", "i32"), ("x4", "i32"), ("y4", "i32"),
    ],
    "skin": [
        ("id", "i32"), ("name", "str"), ("type", "i32"), ("color", "i32"),
        ("harmonious", "i32"), ("pic", "str"), ("icon", "str"), ("goodsId", "str"),
        ("describe", "str"), ("effect", "str"), ("value", "str"), ("armsId", "str"),
        ("retainEffect", "str"), ("retainValue", "str"), ("retainArms", "str"),
        ("order", "i32"), ("isshow", "str"), ("des", "str"), ("specialShow", "str"),
        ("showItem", "str"),
    ],
    "characters": [
        ("id", "i32"), ("name", "str"), ("_default", "i32"), ("hero", "i32"),
        ("skin", "i32"), ("heroSounds", "str"), ("harmonious", "i32"),
        ("spine", "str"), ("spineFg", "i32"), ("spineBg", "i32"), ("showSize", "str"),
        ("spineDf", "str"), ("fgDf", "str"), ("bgDf", "str"), ("showName", "str"),
        ("posX", "str"), ("posY", "str"), ("careType", "i32"), ("block", "str"),
        ("popSize", "str"), ("popX", "str"), ("popY", "str"), ("model", "str"),
        ("size", "str"), ("recruitImg", "str"), ("modelIcon", "str"),
        ("halfIcon", "str"), ("half2Icon", "str"), ("dateIcon", "str"),
        ("roundIcon", "str"), ("ovalIcon", "str"), ("half3Icon", "str"),
    ],
    "gal_character": [
        ("id", "i32"), ("_default", "i32"), ("hero", "i32"), ("skin", "i32"),
        ("harmonious", "i32"), ("spine", "str"), ("showSize", "str"), ("posX", "str"),
        ("posY", "str"), ("halfIcon", "str"), ("dateIcon", "str"), ("roundIcon", "str"),
        ("touch1", "str"), ("touch2", "str"), ("touch3", "str"), ("touch4", "str"),
        ("touch5", "str"), ("touch6", "str"), ("touch7", "str"), ("touch8", "str"),
        ("giftAction1", "str"), ("giftAction2", "str"),
    ],
    "gal_hero": [
        ("id", "i32"), ("traitType", "str"), ("traitValue", "str"), ("memory", "str"),
        ("favorGoods", "str"), ("location", "str"), ("special", "str"), ("skin", "i32"),
        ("order", "i32"), ("height", "str"), ("bwh", "str"), ("career", "str"),
        ("hobby", "str"), ("introduction", "str"),
    ],
    "gal_hero_skin": [
        ("id", "i32"), ("_default", "i32"), ("hero", "i32"), ("cost", "str"),
        ("effect", "str"), ("order", "i32"), ("specialShow", "str"),
        ("showItem", "str"), ("name", "str"), ("des", "str"), ("icon", "str"),
    ],
    "illustrate_hero": [
        ("id", "i32"), ("heroId", "str"), ("type", "i32"), ("image", "str"),
        ("birthday", "str"), ("like", "str"), ("institution", "str"),
        ("combat", "str"), ("meetingDay", "str"), ("resume", "str"),
        ("report", "str"), ("voiceActorJp", "str"), ("files1", "str"),
        ("files2", "str"), ("soundRecruit", "str"), ("soundTalk", "str"),
        ("soundTouch", "str"), ("soundBattle", "str"), ("soundSkill", "str"),
        ("soundFail", "str"),
    ],
}

UI_PREFAB_KEYWORDS = (
    "/LotteryDraw/",
    "/Prayer/",
    "/Hero/HeroMainView.prefab",
    "/Hero/HeroListView.prefab",
    "/Hero/HeroSkinView.prefab",
)


class Reader:
    def __init__(self, data: bytes):
        self.data = data
        self.off = 0

    def u8(self) -> int:
        value = self.data[self.off]
        self.off += 1
        return value

    def i32(self) -> int:
        value = int.from_bytes(self.data[self.off : self.off + 4], "little", signed=True)
        self.off += 4
        return value

    def string(self) -> str | None:
        header = self.i32()
        if header == -1:
            return None
        size = self.i32() if header < -1 else header
        value = self.data[self.off : self.off + size].decode("utf-8", errors="replace")
        self.off += size
        return value


def parse_table(path: Path, schema: list[tuple[str, str]]) -> list[dict[str, Any]]:
    reader = Reader(path.read_bytes())
    marker = reader.u8()
    if marker != 2:
        raise ValueError(f"{path}: unsupported array marker {marker}")
    count = reader.i32()
    rows: list[dict[str, Any]] = []
    for index in range(count):
        member_count = reader.u8()
        if member_count > len(schema):
            raise ValueError(f"{path}: row {index} has {member_count} fields, schema has {len(schema)}")
        row: dict[str, Any] = {"_index": index}
        for field_index, (name, kind) in enumerate(schema):
            if field_index >= member_count:
                row[name] = None
            elif kind == "i32":
                row[name] = reader.i32()
            elif kind == "str":
                row[name] = reader.string()
            else:
                raise ValueError(f"unknown field kind {kind}")
        rows.append(row)
    return rows


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        path.write_text("", encoding="utf-8")
        return
    headers: list[str] = []
    for row in rows:
        for key in row:
            if key not in headers:
                headers.append(key)
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)


def load_lang(paths: list[str]) -> dict[str, str]:
    lang: dict[str, str] = {}
    for item in paths:
        path = Path(item)
        if not path.exists():
            continue
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        if isinstance(data, list):
            for row in data:
                if isinstance(row, dict) and "id" in row and "content" in row:
                    lang[str(row["id"])] = str(row.get("content") or "")
        elif isinstance(data, dict):
            for row in data.get("lang", []):
                if isinstance(row, str) and "=" in row:
                    key, value = row.split("=", 1)
                    lang[key] = value
    return lang


def resolve(value: Any, lang: dict[str, str]) -> str:
    if value is None:
        return ""
    return lang.get(str(value), "")


def int_list(value: Any) -> list[int]:
    if value is None:
        return []
    return [int(x) for x in re.findall(r"-?\d+", str(value))]


def read_manifest_paths(path: Path | None) -> list[str]:
    if path is None or not path.exists():
        return []
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        first = reader.fieldnames[0] if reader.fieldnames else "path"
        return [row.get("path") or row.get("assetPath") or row.get(first) or "" for row in reader]


def asset_matches(paths: list[str], *needles: Any) -> str:
    tokens = [str(n).lower() for n in needles if n not in (None, "", 0)]
    hits: list[str] = []
    for path in paths:
        low = path.lower()
        if any(token in low for token in tokens):
            hits.append(path)
    priority = (
        "/spine/hero/",
        "/rawassets/hero/",
        "/ui/atlas/hero/",
        "/ui/texture/hero/",
        "/sound/action/",
        "/sound/battle/",
        "/prefabs/3d/",
    )
    hits = sorted(
        dict.fromkeys(hits),
        key=lambda p: next((i for i, token in enumerate(priority) if token in p.lower()), len(priority)),
    )
    return "|".join(hits[:40])


def build_outputs(
    tables: dict[str, list[dict[str, Any]]],
    lang: dict[str, str],
    asset_paths: list[str],
    ui_paths: list[str],
) -> dict[str, list[dict[str, Any]]]:
    heroes = {int(row["id"]): row for row in tables.get("hero", []) if row.get("id") is not None}
    char_by_hero: dict[int, list[dict[str, Any]]] = {}
    for row in tables.get("characters", []):
        char_by_hero.setdefault(int(row.get("hero") or 0), []).append(row)
    gal_by_hero: dict[int, list[dict[str, Any]]] = {}
    for row in tables.get("gal_character", []):
        gal_by_hero.setdefault(int(row.get("hero") or 0), []).append(row)
    skins_by_hero: dict[int, list[dict[str, Any]]] = {}
    for row in tables.get("hero_skin", []):
        for hero_id in int_list(row.get("hero")):
            skins_by_hero.setdefault(hero_id, []).append(row)
    illustrate_by_hero: dict[int, list[dict[str, Any]]] = {}
    for row in tables.get("illustrate_hero", []):
        for hero_id in int_list(row.get("heroId")):
            illustrate_by_hero.setdefault(hero_id, []).append(row)

    hero_map = []
    for hero_id, hero in sorted(heroes.items()):
        chars = char_by_hero.get(hero_id, [])
        gal_chars = gal_by_hero.get(hero_id, [])
        skin_rows = skins_by_hero.get(hero_id, [])
        illus_rows = illustrate_by_hero.get(hero_id, [])
        resource_keys = []
        for source_rows in (chars, gal_chars, illus_rows):
            for row in source_rows:
                for key in ("spine", "model", "recruitImg", "modelIcon", "halfIcon", "half2Icon", "dateIcon", "roundIcon", "ovalIcon", "half3Icon", "image"):
                    value = row.get(key)
                    if value and value not in resource_keys:
                        resource_keys.append(str(value))
        hero_map.append({
            "heroId": hero_id,
            "rare": hero.get("rare"),
            "rare2": hero.get("rare2"),
            "rare3": hero.get("rare3"),
            "nameKey": hero.get("name"),
            "nameText": resolve(hero.get("name"), lang),
            "jNameText": resolve(hero.get("jName"), lang),
            "labelText": resolve(hero.get("label"), lang),
            "skinIds": "|".join(str(row.get("id")) for row in skin_rows),
            "characterIds": "|".join(str(row.get("id")) for row in chars),
            "galCharacterIds": "|".join(str(row.get("id")) for row in gal_chars),
            "spine": "|".join(str(row.get("spine")) for row in chars if row.get("spine")),
            "galSpine": "|".join(str(row.get("spine")) for row in gal_chars if row.get("spine")),
            "recruitImg": "|".join(str(row.get("recruitImg")) for row in chars if row.get("recruitImg")),
            "halfIcon": "|".join(str(row.get("halfIcon")) for row in chars if row.get("halfIcon")),
            "galHalfIcon": "|".join(str(row.get("halfIcon")) for row in gal_chars if row.get("halfIcon")),
            "illustrateImage": "|".join(str(row.get("image")) for row in illus_rows if row.get("image")),
            "assetPathCandidates": asset_matches(asset_paths, *resource_keys, f"hero_{hero_id:03d}"),
        })

    draw_pool = []
    for table_name in ("drawconfig", "ac_limit_draw"):
        for row in tables.get(table_name, []):
            show_heroes = int_list(row.get("showHero")) or int_list(row.get("heroShow"))
            wish_heroes = int_list(row.get("wishListHero"))
            rewards = "|".join(str(row.get(k) or "") for k in ("reward1", "reward2", "reward3", "reward4", "rewardF2", "reward"))
            draw_pool.append({
                "table": table_name,
                "id": row.get("id"),
                "type": row.get("type") or row.get("isUr"),
                "drawType": row.get("drawType") or row.get("urDraw"),
                "nameKey": row.get("name"),
                "nameText": resolve(row.get("name"), lang),
                "titlePic": row.get("titlePic"),
                "pic": row.get("pic"),
                "showHeroIds": "|".join(str(x) for x in show_heroes),
                "showHeroNames": "|".join(resolve(heroes.get(x, {}).get("name"), lang) or str(x) for x in show_heroes),
                "wishHeroIds": "|".join(str(x) for x in wish_heroes),
                "onceCost": row.get("oncecond"),
                "tenCost": row.get("continuouscond"),
                "pityCounters": f"cnt2={row.get('cnt2')};cnt3={row.get('cnt3')};cnt4={row.get('cnt4')};cntF={row.get('cntF')};cntF2={row.get('cntF2')}",
                "rewardRaw": rewards,
            })

    ui_candidates = [
        {"path": path, "role": "gacha_or_hero_ui"}
        for path in ui_paths
        if any(token.lower() in path.lower() for token in UI_PREFAB_KEYWORDS)
    ]

    sample_ids = [1, 3, 5, 16, 17]
    sample_assets = []
    for hero_id in sample_ids:
        sample_assets.append({
            "heroId": hero_id,
            "heroKey": f"hero_{hero_id:03d}",
            "assetPaths": asset_matches(asset_paths, f"hero_{hero_id:03d}"),
        })

    return {
        "hero_resource_map": hero_map,
        "draw_pool_summary": draw_pool,
        "ui_prefab_candidates": ui_candidates,
        "sample_character_assets": sample_assets,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--static-dir", required=True)
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--lang", action="append", default=[])
    parser.add_argument("--manifest-assets")
    parser.add_argument("--manifest-ui-prefabs")
    args = parser.parse_args()

    static_dir = Path(args.static_dir)
    out_dir = Path(args.out_dir)
    tables_dir = out_dir / "tables"
    out_dir.mkdir(parents=True, exist_ok=True)

    tables: dict[str, list[dict[str, Any]]] = {}
    errors = {}
    for name, schema in SCHEMAS.items():
        path = static_dir / f"{name}.bytes"
        if not path.exists():
            continue
        try:
            rows = parse_table(path, schema)
        except Exception as exc:  # keep batch export useful while documenting gaps
            errors[name] = str(exc)
            continue
        tables[name] = rows
        write_csv(tables_dir / f"{name}.csv", rows)
        (tables_dir / f"{name}.json").write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8")

    lang = load_lang(args.lang)
    asset_paths = read_manifest_paths(Path(args.manifest_assets) if args.manifest_assets else None)
    ui_paths = read_manifest_paths(Path(args.manifest_ui_prefabs) if args.manifest_ui_prefabs else None)
    outputs = build_outputs(tables, lang, asset_paths, ui_paths)
    for name, rows in outputs.items():
        write_csv(out_dir / f"{name}.csv", rows)
        (out_dir / f"{name}.json").write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8")

    summary = {
        "static_dir": str(static_dir),
        "tables": {name: len(rows) for name, rows in tables.items()},
        "errors": errors,
        "lang_entries": len(lang),
        "manifest_asset_paths": len(asset_paths),
        "manifest_ui_prefabs": len(ui_paths),
        "outputs": {name: len(rows) for name, rows in outputs.items()},
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
