#!/usr/bin/env python3
import csv
import json
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
INPUTS = [
    ROOT / "reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_Block.dat",
    ROOT / "reverse-output/assets/assetstudio-cli-data-monobehaviour-raw/MonoBehaviour/Table_Block.dat",
]
CSV_OUTPUT = ROOT / "reverse-output/assets/derived/table_block_catalog.csv"
JSON_OUTPUT = ROOT / "reverse-output/assets/derived/table_block_catalog.json"

TAIL_FIELDS = [
    ("is_spine_block", "bool"),
    ("parent_block_id", "int"),
    ("is_all_parent_block", "bool"),
    ("produce_energy", "int"),
    ("cool_time", "int"),
    ("max_subtract_cool_time_per", "int"),
    ("ongoing_added_cool_time_per", "int"),
    ("produce_reward_type", "int"),
    ("produce_reward_id", "int"),
    ("produce_reward_value", "int"),
    ("expendability", "bool"),
    ("expend_alter_block_id", "int"),
    ("open_cool_time", "int"),
    ("open_type", "int"),
    ("added_drop_rate", "int"),
    ("added_drop_block_id", "int"),
    ("bubble_block_rate", "int"),
    ("bubble_pop_currency_type", "int"),
    ("jewel_bubble_pop_coef", "float"),
    ("obtain_reward_type", "int"),
    ("obtain_reward_id", "int"),
    ("obtain_reward_value", "int"),
    ("sell_available", "bool"),
    ("sell_gold_coef", "float"),
    ("gold_shop_coef", "float"),
    ("jewel_shop_coef", "float"),
    ("shop_block_currency_type", "int"),
    ("shop_block_currency_value", "int"),
    ("display_in_collection", "bool"),
    ("is_active_merge", "bool"),
]


def align4(pos: int) -> int:
    return (pos + 3) & ~3


def read_i32(data: bytes, pos: int) -> tuple[int, int]:
    return struct.unpack_from("<i", data, pos)[0], pos + 4


def read_f32(data: bytes, pos: int) -> tuple[float, int]:
    return struct.unpack_from("<f", data, pos)[0], pos + 4


def read_bool32(data: bytes, pos: int) -> tuple[bool, int]:
    value, pos = read_i32(data, pos)
    return value != 0, pos


def read_string(data: bytes, pos: int) -> tuple[str, int]:
    length, pos = read_i32(data, pos)
    if length < 0 or length > 4096 or pos + length > len(data):
        raise ValueError(f"invalid string length {length} at {pos - 4:#x}")
    raw = data[pos : pos + length]
    pos = align4(pos + length)
    return raw.decode("utf-8", errors="replace"), pos


def looks_like_record(data: bytes, pos: int) -> bool:
    if pos + 12 >= len(data):
        return False
    value = struct.unpack_from("<i", data, pos)[0]
    if value <= 0:
        return False
    length = struct.unpack_from("<i", data, pos + 4)[0]
    if length <= 0 or length > 80 or pos + 8 + length > len(data):
        return False
    sample = data[pos + 8 : pos + 8 + length]
    if not all((32 <= b <= 126) for b in sample):
        return False
    try:
        probe = pos
        _, probe = read_i32(data, probe)
        category, probe = read_string(data, probe)
        sub_category, probe = read_string(data, probe)
        group, probe = read_string(data, probe)
        _, probe = read_i32(data, probe)
        level, probe = read_i32(data, probe)
        _, probe = read_i32(data, probe)
        _, probe = read_i32(data, probe)
        block_name, probe = read_string(data, probe)
        block_image, probe = read_string(data, probe)
    except (ValueError, struct.error):
        return False
    return (
        category != ""
        and sub_category != ""
        and group != ""
        and block_name.lower().startswith("blockname_")
        and block_image != ""
        and 0 <= level <= 100
    )


def find_next_record(data: bytes, pos: int) -> int | None:
    for candidate in range(pos, min(pos + 4096, len(data) - 12)):
        if looks_like_record(data, candidate):
            return candidate
    return None


def parse_block_record(data: bytes, pos: int, has_next: bool) -> tuple[dict, int]:
    start = pos
    row = {}
    row["id"], pos = read_i32(data, pos)
    row["category_name"], pos = read_string(data, pos)
    row["sub_category_name"], pos = read_string(data, pos)
    row["group_name"], pos = read_string(data, pos)
    row["block_type"], pos = read_i32(data, pos)
    row["level"], pos = read_i32(data, pos)
    row["block_tier"], pos = read_i32(data, pos)
    row["production_diff"], pos = read_i32(data, pos)
    row["block_name"], pos = read_string(data, pos)
    row["block_image"], pos = read_string(data, pos)

    if not has_next:
        next_pos = pos + 120
    else:
        next_pos = find_next_record(data, pos)
        if next_pos is None:
            next_pos = pos + 120
    if next_pos - pos != 120:
        # BlockTableData has a fixed primitive tail. Preserve the scanned value for auditing,
        # but keep table boundaries stable so following lists can be decoded.
        row["scanned_tail_size"] = next_pos - pos
        next_pos = pos + 120

    tail = data[pos:next_pos]
    tail_pos = 0
    for field_name, field_type in TAIL_FIELDS:
        if field_type == "float":
            row[field_name] = struct.unpack_from("<f", tail, tail_pos)[0]
        else:
            value = struct.unpack_from("<i", tail, tail_pos)[0]
            row[field_name] = bool(value) if field_type == "bool" else value
        tail_pos += 4

    row["tail_raw_hex"] = tail.hex()
    row["tail_size"] = next_pos - pos
    row["record_offset"] = start
    return row, next_pos


def parse() -> list[dict]:
    input_path = next((path for path in INPUTS if path.exists()), None)
    if input_path is None:
        searched = "\n".join(str(path) for path in INPUTS)
        raise FileNotFoundError(f"Table_Block.dat not found. Searched:\n{searched}")
    data = input_path.read_bytes()
    pos = 12
    _, pos = read_i32(data, pos)
    _, pos = read_i32(data, pos)
    _, pos = read_i32(data, pos)
    _, pos = read_i32(data, pos)
    table_name, pos = read_string(data, pos)
    if table_name != "Table_Block":
        raise ValueError(f"unexpected table name: {table_name!r}")
    row_count, pos = read_i32(data, pos)

    rows = []
    for index in range(row_count):
        if not looks_like_record(data, pos):
            break
        row, pos = parse_block_record(data, pos, True)
        row["source_file"] = str(input_path.relative_to(ROOT))
        rows.append(row)
    return rows


def main() -> None:
    rows = parse()
    CSV_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with CSV_OUTPUT.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    JSON_OUTPUT.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"rows={len(rows)}")
    print(CSV_OUTPUT)
    print(JSON_OUTPUT)


if __name__ == "__main__":
    main()
