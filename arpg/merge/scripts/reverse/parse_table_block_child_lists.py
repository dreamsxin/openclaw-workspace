#!/usr/bin/env python3
import csv
import struct
from pathlib import Path

from parse_table_block_raw import INPUTS, ROOT, align4, parse, read_i32, read_string


OUT_DIR = ROOT / "reverse-output/assets/derived/table_block_children"


def write_csv(name: str, rows: list[dict]) -> None:
    if not rows:
        return
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / f"{name}.csv"
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"{name}: rows={len(rows)} path={path}")


def read_string_i32x4(data: bytes, pos: int, fields: list[str]) -> tuple[dict, int]:
    row = {}
    row[fields[0]], pos = read_string(data, pos)
    for field in fields[1:]:
        row[field], pos = read_i32(data, pos)
    return row, pos


def parse_fixed_ints(data: bytes, pos: int, fields: list[str]) -> tuple[dict, int]:
    row = {}
    for field in fields:
        row[field], pos = read_i32(data, pos)
    return row, pos


def parse_grow_produce(data: bytes, pos: int) -> tuple[dict, int]:
    row = {}
    row["produce_block_id"], pos = read_i32(data, pos)
    row["target_block_id"], pos = read_i32(data, pos)
    row["step"], pos = read_i32(data, pos)
    row["block_image_name"], pos = read_string(data, pos)
    row["spine_type"], pos = read_i32(data, pos)
    row["is_produce_active"], pos = read_i32(data, pos)
    return row, pos


def parse_spine(data: bytes, pos: int) -> tuple[dict, int]:
    row = {}
    row["block_id"], pos = read_i32(data, pos)
    row["spine_type"], pos = read_i32(data, pos)
    row["spine_object_name"], pos = read_string(data, pos)
    row["anim_name"], pos = read_string(data, pos)
    row["skin_name"], pos = read_string(data, pos)
    row["is_loop"], pos = read_i32(data, pos)
    return row, pos


def parse_msg(data: bytes, pos: int) -> tuple[dict, int]:
    row = {}
    row["level_up_step"], pos = read_i32(data, pos)
    row["message"], pos = read_string(data, pos)
    return row, pos


def parse_list(data: bytes, pos: int, name: str, parser) -> tuple[list[dict], int]:
    count, pos = read_i32(data, pos)
    rows = []
    for index in range(count):
        row, pos = parser(data, pos)
        row["row_index"] = index
        rows.append(row)
    write_csv(name, rows)
    return rows, pos


def main() -> None:
    input_path = next((path for path in INPUTS if path.exists()), None)
    if input_path is None:
        raise FileNotFoundError("Table_Block.dat not found")

    # Reuse the validated main parser to compute the exact end of BlockTableData.
    main_rows = parse()
    data = input_path.read_bytes()
    pos = int(main_rows[-1]["record_offset"]) + 0
    pos = int(main_rows[-1]["record_offset"]) + (len(bytes.fromhex(main_rows[-1]["tail_raw_hex"])))
    # Add the parsed prefix length by scanning from the last record start to the preserved tail.
    # The next four bytes at this point must be the first child-list count.
    last_start = int(main_rows[-1]["record_offset"])
    tail = bytes.fromhex(main_rows[-1]["tail_raw_hex"])
    tail_start = data.find(tail, last_start)
    pos = tail_start + len(tail)

    print(f"source={input_path.relative_to(ROOT)}")
    print(f"child_lists_start=0x{pos:x}")

    _, pos = parse_list(data, pos, "BlockCoolTimeTableData", lambda d, p: read_string_i32x4(d, p, ["group_name", "currency_type", "min_value", "cool_time_during", "cool_time_during_value"]))
    _, pos = parse_list(data, pos, "BlockDropTableData", lambda d, p: parse_fixed_ints(d, p, ["id", "block_id", "ratio", "weight", "final_ratio_raw"]))
    _, pos = parse_list(data, pos, "BlockBubbleDropTableData", lambda d, p: read_string_i32x4(d, p, ["group_name", "level_min", "ratio1", "ratio2", "ratio3"]))
    _, pos = parse_list(data, pos, "BlockDesignedDropTableData", lambda d, p: parse_fixed_ints(d, p, ["id", "block_id", "count_min", "count_max"]))
    _, pos = parse_list(data, pos, "BlockProduceTableData", lambda d, p: parse_fixed_ints(d, p, ["id", "drop_id", "designed_drop_id"]))
    _, pos = parse_list(data, pos, "BlockProduceMsgTableData", parse_msg)
    _, pos = parse_list(data, pos, "BlockGrowProduceTableData", parse_grow_produce)
    _, pos = parse_list(data, pos, "BlockSpineTableData", parse_spine)
    _, pos = parse_list(data, pos, "BlockMergeDropRateTableData", lambda d, p: parse_fixed_ints(d, p, ["block_id", "pool_group_id", "rate"]))
    _, pos = parse_list(data, pos, "BlockMergeDropPoolTableData", lambda d, p: parse_fixed_ints(d, p, ["pool_group_id", "drop_block_id", "map_cell_type"]))
    _, pos = parse_list(data, pos, "BubbleRewardTableData", lambda d, p: parse_fixed_ints(d, p, ["pop_type", "min_production_diff", "max_production_diff", "reward_block_id", "reward_rate"]))
    _, pos = parse_list(data, pos, "BlockCollectionTableData", lambda d, p: parse_fixed_ints(d, p, ["block_id", "reward_type", "reward_id", "reward_amount"]))
    print(f"end=0x{pos:x} size=0x{len(data):x}")


if __name__ == "__main__":
    main()
