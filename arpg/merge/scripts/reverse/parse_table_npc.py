#!/usr/bin/env python3
import csv
import json
import struct
from pathlib import Path
from typing import Callable


ROOT = Path(__file__).resolve().parents[2]
INPUTS = [
    ROOT / "reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_Npc.dat",
    ROOT / "reverse-output/assets/assetstudio-cli-data-monobehaviour-raw/MonoBehaviour/Table_Npc.dat",
]
OUTPUT_DIR = ROOT / "reverse-output/assets/derived/table_npc"


def align4(pos: int) -> int:
    return (pos + 3) & ~3


def read_i32(data: bytes, pos: int) -> tuple[int, int]:
    return struct.unpack_from("<i", data, pos)[0], pos + 4


def read_f32(data: bytes, pos: int) -> tuple[float, int]:
    return struct.unpack_from("<f", data, pos)[0], pos + 4


def read_string(data: bytes, pos: int) -> tuple[str, int]:
    length, pos = read_i32(data, pos)
    if length < 0 or length > 200000 or pos + length > len(data):
        raise ValueError(f"invalid string length {length} at {pos - 4:#x}")
    raw = data[pos : pos + length]
    pos = align4(pos + length)
    return raw.decode("utf-8", errors="replace"), pos


def read_fields(data: bytes, pos: int, fields: list[tuple[str, str]]) -> tuple[dict, int]:
    row = {}
    for name, field_type in fields:
        if field_type == "int":
            row[name], pos = read_i32(data, pos)
        elif field_type == "bool32":
            value, pos = read_i32(data, pos)
            row[name] = bool(value)
        elif field_type == "float":
            row[name], pos = read_f32(data, pos)
        elif field_type == "string":
            row[name], pos = read_string(data, pos)
        else:
            raise ValueError(f"unknown field type: {field_type}")
    return row, pos


NPC_FIELDS = [
    ("NpcID", "int"),
    ("Name", "string"),
    ("SkinID", "int"),
    ("ParentID", "int"),
    ("UnlockQuestID", "int"),
    ("NeedUnlockFurnitureID", "int"),
    ("UnlockType", "int"),
    ("UnlockValue_01", "int"),
    ("UnlockValue_02", "int"),
    ("isUnlockAnim", "bool32"),
    ("Icon_LD", "string"),
    ("Icon_SD", "string"),
    ("Prefab_LD", "string"),
    ("Prefab_SD", "string"),
    ("Prefab_SD_OutGame", "string"),
    ("Npc_Icon", "string"),
    ("Npc_CryIcon", "string"),
    ("Npc_Prefab", "string"),
    ("NPCType", "int"),
    ("PersonalColor", "string"),
    ("IsDormitory", "bool32"),
]

MAID_SKILL_FIELDS = [
    ("SkillID", "int"),
    ("Lv", "int"),
    ("SkillType", "int"),
    ("SkillTargetID", "string"),
    ("SkillValue", "float"),
]

MAID_LEVEL_FIELDS = [
    ("MaidId", "int"),
    ("LV", "int"),
    ("NeedExp", "int"),
    ("RewardType", "int"),
    ("RewardID", "int"),
    ("RewardCount", "int"),
]

MAID_INFO_FIELDS = [
    ("MaidID", "int"),
    ("Member", "string"),
    ("Tribe", "string"),
    ("Height", "string"),
    ("Birthday", "string"),
    ("Age", "string"),
    ("CV", "string"),
    ("Favorite", "string"),
    ("Hate", "string"),
    ("SkillID", "int"),
    ("LikeGiftID_01", "int"),
    ("LikeGiftID_02", "int"),
    ("LikeGiftID_03", "int"),
]

INGAME_DIALOG_FIELDS = [
    ("DialogID", "int"),
    ("NpcID", "int"),
    ("SkinID", "int"),
    ("AnimType", "int"),
    ("FacialType", "int"),
    ("DialogType", "int"),
    ("AudioName", "string"),
    ("KOR", "string"),
    ("KOR_LineSpace", "float"),
    ("KOR_CharSpace", "float"),
    ("ENG", "string"),
    ("ENG_LineSpace", "float"),
    ("ENG_CharSpace", "float"),
    ("JP", "string"),
    ("JP_LineSpace", "float"),
    ("JP_CharSpace", "float"),
    ("ZH_CHT", "string"),
    ("ZH_CHT_LineSpace", "float"),
    ("ZH_CHT_CharSpace", "float"),
    ("ZH_CHS", "string"),
    ("ZH_CHS_LineSpace", "float"),
    ("ZH_CHS_CharSpace", "float"),
]

CUSTOMER_FIELDS = [
    ("NpcID", "int"),
    ("GroupName", "string"),
    ("UnlockRewardType", "int"),
    ("RewardId", "int"),
    ("Value", "int"),
    ("Memo", "string"),
    ("Tribe", "string"),
    ("Birthday", "string"),
    ("Hobby", "string"),
    ("Like", "string"),
]

CUSTOMER_REWARD_FIELDS = [
    ("RewardType", "int"),
    ("RewardID", "int"),
    ("RewardAmount", "int"),
    ("Rate", "int"),
]

MAID_GIFT_FIELDS = [
    ("GiftID", "int"),
    ("GiftName", "string"),
    ("GiftImage", "string"),
    ("AddExp", "int"),
    ("AddBoostExp", "int"),
]

MAID_LOADING_FIELDS = [
    ("NpcID", "int"),
    ("SkinID", "int"),
    ("BGName", "string"),
    ("SoundName", "string"),
    ("InteractingDelay", "float"),
    ("Rate", "float"),
    ("spinePosX", "int"),
    ("spinePosY", "int"),
    ("IsActive", "bool32"),
]


def parse_list(
    data: bytes,
    pos: int,
    fields: list[tuple[str, str]],
    list_name: str,
    row_parser: Callable[[bytes, int, list[tuple[str, str]]], tuple[dict, int]] = read_fields,
) -> tuple[list[dict], int]:
    count, pos = read_i32(data, pos)
    rows = []
    for index in range(count):
        row_offset = pos
        try:
            row, pos = row_parser(data, pos, fields)
            row["row_index"] = index
            row["record_offset"] = row_offset
            rows.append(row)
        except ValueError as exc:
            raise ValueError(f"{list_name}[{index}] failed at {row_offset:#x}: {exc}") from exc
    return rows, pos


def parse_dialog_prefix(data: bytes, pos: int, _fields: list[tuple[str, str]]) -> tuple[dict, int]:
    row, next_pos = read_fields(data, pos, INGAME_DIALOG_FIELDS)
    return row, next_pos


def parse_known_dialog_prefix(data: bytes, pos: int) -> tuple[list[dict], int, dict]:
    count, pos = read_i32(data, pos)
    rows = []
    failed = None
    for index in range(count):
        row_offset = pos
        try:
            row, pos = parse_dialog_prefix(data, pos, INGAME_DIALOG_FIELDS)
        except ValueError as exc:
            failed = {"row_index": index, "record_offset": row_offset, "error": str(exc)}
            pos = row_offset
            break
        row["row_index"] = index
        row["record_offset"] = row_offset
        rows.append(row)
    if failed is None:
        failed = {"row_index": count, "record_offset": pos, "error": ""}
    return rows, pos, {"declared_count": count, "parsed_count": len(rows), "stopped": failed}


def parse() -> dict:
    input_path = next((path for path in INPUTS if path.exists()), None)
    if input_path is None:
        searched = "\n".join(str(path) for path in INPUTS)
        raise FileNotFoundError(f"Table_Npc.dat not found. Searched:\n{searched}")

    data = input_path.read_bytes()
    pos = 12
    for _ in range(4):
        _, pos = read_i32(data, pos)
    table_name, pos = read_string(data, pos)
    if table_name != "Table_Npc":
        raise ValueError(f"unexpected table name: {table_name!r}")

    npc_rows, pos = parse_list(data, pos, NPC_FIELDS, "NpcTableData")
    skill_rows, pos = parse_list(data, pos, MAID_SKILL_FIELDS, "MaidSkillTableData")
    level_rows, pos = parse_list(data, pos, MAID_LEVEL_FIELDS, "MaidLevelTableData")
    info_rows, pos = parse_list(data, pos, MAID_INFO_FIELDS, "MaidInfoTableData")
    dialog_rows, pos, dialog_meta = parse_known_dialog_prefix(data, pos)

    return {
        "source": str(input_path.relative_to(ROOT)),
        "table_name": table_name,
        "NpcTableData": npc_rows,
        "MaidSkillTableData": skill_rows,
        "MaidLevelTableData": level_rows,
        "MaidInfoTableData": info_rows,
        "InGameNpcDialog": dialog_rows,
        "decode_notes": {
            "dialog": (
                "Rows before the first mixed-format dialog payload are decoded using the dump.cs "
                "InGameNpcDialog field order. Later rows contain non-text presentation/effect "
                "payloads and need a dedicated second-pass parser."
            ),
            "dialog_meta": dialog_meta,
            "unparsed_tail_offset": pos,
            "unparsed_tail_bytes": len(data) - pos,
            "pending_lists": [
                "CustomerTableData",
                "CustomerRewardData",
                "MaidGiftTableData",
                "MaidSceneLoadingTableData",
            ],
        },
    }


def write_csv(path: Path, rows: list[dict]) -> None:
    if not rows:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0].keys())
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    decoded = parse()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for key in [
        "NpcTableData",
        "MaidSkillTableData",
        "MaidLevelTableData",
        "MaidInfoTableData",
        "InGameNpcDialog",
    ]:
        write_csv(OUTPUT_DIR / f"{key}.csv", decoded[key])
    json_path = OUTPUT_DIR / "table_npc_decoded.json"
    json_path.write_text(json.dumps(decoded, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    summary = {
        "source": decoded["source"],
        "counts": {
            key: len(decoded[key])
            for key in [
                "NpcTableData",
                "MaidSkillTableData",
                "MaidLevelTableData",
                "MaidInfoTableData",
                "InGameNpcDialog",
            ]
        },
        "decode_notes": decoded["decode_notes"],
    }
    summary_path = OUTPUT_DIR / "table_npc_summary.json"
    summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
