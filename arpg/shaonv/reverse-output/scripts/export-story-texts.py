#!/usr/bin/env python3
"""Export story/dialogue text tables from shaonv MemoryPack static bytes.

This is a focused parser for the static table files used by the hotfix UI:
the first byte is the MemoryPack array header marker, followed by a little
endian int32 row count.  Each row starts with an object member-count byte and
then fields in the same order as the generated *StaticItem formatter.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path
from typing import Any


SCHEMAS: dict[str, list[tuple[str, str]]] = {
    "cht": [
        ("id", "i32"),
        ("title", "str"),
        ("content", "str"),
        ("switch", "i32"),
    ],
    "cn": [
        ("id", "i32"),
        ("title", "str"),
        ("content", "str"),
        ("switch", "i32"),
    ],
    "plot": [
        ("id", "i32"),
        ("type", "i32"),
        ("para1", "i32"),
        ("para2", "i32"),
        ("guide", "i32"),
        ("step", "i32"),
        ("para", "i32"),
    ],
    "role_story": [
        ("id", "i32"),
        ("chapterId", "str"),
        ("title", "str"),
        ("pic", "str"),
    ],
    "role_story_chapter": [
        ("id", "i32"),
        ("frontChapter", "str"),
        ("stepId", "i32"),
        ("title", "str"),
        ("summary", "str"),
        ("reward", "i32"),
        ("battleTag", "i32"),
        ("army", "str"),
        ("scene", "str"),
        ("unlockTime", "i32"),
    ],
    "gal_plot": [
        ("id", "i32"),
        ("sceneType", "i32"),
        ("dialogueType", "str"),
        ("name", "str"),
        ("spine", "str"),
        ("optionType", "str"),
        ("option", "str"),
        ("keyOption", "i32"),
        ("trait", "str"),
        ("traitInterval", "str"),
        ("nextId", "str"),
        ("plotText", "str"),
        ("sound", "str"),
        ("animation", "str"),
        ("pic", "str"),
        ("image", "str"),
        ("bgType", "i32"),
        ("bg", "str"),
        ("bgm", "str"),
        ("skip", "i32"),
        ("skipId", "str"),
    ],
    "gal_chat": [
        ("id", "i32"),
        ("hero", "i32"),
        ("isAgain", "i32"),
        ("plot", "i32"),
        ("num", "i32"),
        ("answer", "str"),
        ("favor", "str"),
        ("traitLimit", "str"),
        ("condition", "str"),
        ("weight", "i32"),
    ],
    "gal_memory": [
        ("id", "i32"),
        ("plot", "i32"),
        ("reward", "i32"),
        ("condition", "i32"),
        ("name", "str"),
        ("pic", "str"),
    ],
    "gal_character": [
        ("id", "i32"),
        ("default", "i32"),
        ("hero", "i32"),
        ("skin", "i32"),
        ("harmonious", "i32"),
        ("spine", "str"),
        ("showSize", "str"),
        ("posX", "str"),
        ("posY", "str"),
        ("halfIcon", "str"),
        ("dateIcon", "str"),
        ("roundIcon", "str"),
        ("touch1", "str"),
        ("touch2", "str"),
        ("touch3", "str"),
        ("touch4", "str"),
        ("touch5", "str"),
        ("touch6", "str"),
        ("touch7", "str"),
        ("touch8", "str"),
        ("giftAction1", "str"),
        ("giftAction2", "str"),
    ],
    "date": [
        ("id", "i32"),
        ("isSpecial", "str"),
        ("stepType", "i32"),
        ("name", "str"),
        ("image", "str"),
        ("position", "i32"),
        ("state", "i32"),
        ("action", "i32"),
        ("image2", "str"),
        ("position2", "i32"),
        ("state2", "i32"),
        ("action2", "i32"),
        ("textId", "str"),
        ("aside", "i32"),
        ("asideBg", "str"),
        ("num", "i32"),
        ("sound", "str"),
        ("backgroundSound", "str"),
        ("background", "str"),
        ("funName", "str"),
        ("picture", "str"),
        ("dataId", "i32"),
        ("changeType", "str"),
        ("dateName", "str"),
        ("dateMark", "i32"),
    ],
    "chapter": [
        ("id", "i32"),
        ("name", "str"),
        ("questId", "str"),
        ("reward", "str"),
        ("rewardShow", "str"),
        ("unlock", "i32"),
        ("description", "str"),
        ("description1", "str"),
        ("icon", "str"),
        ("background", "str"),
        ("tips", "str"),
        ("posX", "str"),
        ("posY", "str"),
        ("mechaShow", "i32"),
        ("picture", "str"),
        ("box", "str"),
        ("rewardDes", "str"),
    ],
}


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
        # MemoryPack string payloads in these tables are written as:
        #   negative header (~charCount), int32 utf8ByteCount, bytes
        # ASCII keys therefore look like EE FF FF FF 11 00 00 00 ...
        if header < -1:
            size = self.i32()
        else:
            size = header
        value = self.data[self.off : self.off + size].decode("utf-8", errors="replace")
        self.off += size
        return value


def parse_table(path: Path, schema: list[tuple[str, str]]) -> list[dict[str, Any]]:
    reader = Reader(path.read_bytes())
    marker = reader.u8()
    if marker != 2:
        raise ValueError(f"{path}: unsupported MemoryPack array marker {marker}")
    count = reader.i32()
    rows: list[dict[str, Any]] = []
    for index in range(count):
        member_count = reader.u8()
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
        # Forward-compatible skip is intentionally strict. If we ever hit a
        # wider generated formatter, add its schema before trusting output.
        if member_count > len(schema):
            raise ValueError(f"{path}: row {index} has {member_count} fields, schema has {len(schema)}")
        rows.append(row)
    trailing = len(reader.data) - reader.off
    if trailing:
        for row in rows:
            row["_trailingBytes"] = trailing
    return rows


def load_lang(path: Path) -> dict[str, str]:
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    result: dict[str, str] = {}
    for item in data.get("lang", []):
        if not isinstance(item, str) or "=" not in item:
            continue
        key, value = item.split("=", 1)
        result[key] = value
    return result


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


def resolve_lang(value: Any, lang: dict[str, str]) -> str:
    if value is None:
        return ""
    text = str(value)
    return lang.get(text, "")


def maybe_lang_key(value: Any) -> bool:
    if not isinstance(value, str) or not value:
        return False
    return bool(re.match(r"^(UI\d+|gal_|role_|chapter|chaDes|push_|draw_|rule_|tips_|.+_name_|.+_text_)", value))


def build_story_exports(tables: dict[str, list[dict[str, Any]]], lang: dict[str, str]) -> dict[str, list[dict[str, Any]]]:
    outputs: dict[str, list[dict[str, Any]]] = {}

    if "gal_plot" in tables:
        rows = []
        for row in tables["gal_plot"]:
            item = dict(row)
            item["nameText"] = resolve_lang(row.get("name"), lang)
            item["plotTextResolved"] = resolve_lang(row.get("plotText"), lang)
            item["optionResolved"] = resolve_lang(row.get("option"), lang)
            rows.append(item)
        outputs["gal_plot_resolved"] = rows

    if "role_story_chapter" in tables:
        rows = []
        for row in tables["role_story_chapter"]:
            item = dict(row)
            item["titleResolved"] = resolve_lang(row.get("title"), lang)
            item["summaryResolved"] = resolve_lang(row.get("summary"), lang)
            rows.append(item)
        outputs["role_story_chapter_resolved"] = rows

    if "role_story" in tables:
        rows = []
        for row in tables["role_story"]:
            item = dict(row)
            item["titleResolved"] = resolve_lang(row.get("title"), lang)
            rows.append(item)
        outputs["role_story_resolved"] = rows

    if "date" in tables:
        rows = []
        for row in tables["date"]:
            item = dict(row)
            item["nameResolved"] = resolve_lang(row.get("name"), lang)
            item["textResolved"] = resolve_lang(row.get("textId"), lang)
            item["dateNameResolved"] = resolve_lang(row.get("dateName"), lang)
            rows.append(item)
        outputs["date_resolved"] = rows

    if "chapter" in tables:
        rows = []
        for row in tables["chapter"]:
            item = dict(row)
            for field in ("name", "description", "description1", "tips", "rewardDes"):
                item[f"{field}Resolved"] = resolve_lang(row.get(field), lang)
            rows.append(item)
        outputs["chapter_resolved"] = rows

    story_lang = []
    for key, value in sorted(lang.items()):
        if any(token in key.lower() for token in ("gal", "plot", "story", "role_chapter", "chapter", "date")):
            story_lang.append({"key": key, "text": value})
    outputs["story_lang_keys"] = story_lang
    return outputs


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--static-dir", required=True)
    parser.add_argument("--lang", action="append", default=[])
    parser.add_argument("--out-dir", required=True)
    args = parser.parse_args()

    static_dir = Path(args.static_dir)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    lang: dict[str, str] = {}
    for lang_path in args.lang:
        lang.update(load_lang(Path(lang_path)))

    tables: dict[str, list[dict[str, Any]]] = {}
    for table, schema in SCHEMAS.items():
        path = static_dir / f"{table}.bytes"
        if not path.exists():
            continue
        rows = parse_table(path, schema)
        tables[table] = rows
        write_csv(out_dir / "tables" / f"{table}.csv", rows)
        (out_dir / "tables" / f"{table}.json").write_text(
            json.dumps(rows, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    resolved = build_story_exports(tables, lang)
    for name, rows in resolved.items():
        write_csv(out_dir / f"{name}.csv", rows)
        (out_dir / f"{name}.json").write_text(
            json.dumps(rows, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    summary = {
        "static_dir": str(static_dir),
        "lang_entries": len(lang),
        "tables": {name: len(rows) for name, rows in tables.items()},
        "resolved_outputs": {name: len(rows) for name, rows in resolved.items()},
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
