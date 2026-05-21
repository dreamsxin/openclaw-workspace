#!/usr/bin/env python3
import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DUMP = ROOT / "reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/dump.cs"
ANALYSIS_DIR = DUMP.parent / "analysis"
CSV_OUTPUT = ANALYSIS_DIR / "producer-runtime-methods.csv"
MD_OUTPUT = ROOT / "docs/reverse-godot/producer-runtime-notes.md"

TARGET_METHODS = {
    "InGame_ItemBlock": [
        "OnProduce",
        "SetProduceEnergyData",
        "OnStartCoolTime",
        "CheckCoolTime",
        "CheckOpenCoolTime",
        "OnStartOpenCoolTime",
    ],
    "InGame_BlockManager": [
        "OnNewProduceBlock",
        "OnNewProduceRandBox",
        "OnNewProduceDesignedBox",
        "GetDropPossibleProduceBlock",
        "GetProducelockCount",
    ],
    "InGame_MapManager": [
        "NewProduceBlock",
        "SetRestoreBlock",
        "SetPullOutInventoryBlock",
    ],
    "MapDataManager": [
        "MoveProduceBlockData",
        "SetProduceActive",
        "SetProduceEnergy",
        "GetProduceBlockData",
        "SetNewProduceBlock",
        "SetNewProduceBlockData",
        "SetProduceBlockData",
        "SetProduceBlockData_CoolTimeInfo",
        "SetProduceBlockData_OpenInfo",
        "SetDesignedProduceBlockData",
        "GetProduceBlockDropWeight",
        "AddProduceBlockDropWeight",
        "SetProduceBlockDropWeight",
        "SaveProduceBlockData",
    ],
}

TARGET_FIELDS = {
    "InGame_ItemBlock": [
        "ProduceEnergy",
        "isCoolTime",
        "isOpenCoolTime",
        "coolTimeMax",
        "coolTime",
        "openCoolTimeMax",
        "openCoolTime",
        "RemainCoolTime",
        "RemainOpenCoolTime",
        "isEnergyGenTime",
    ],
    "ProduceBlockData": [
        "produceEnergy",
        "dailyCoolTimeCount",
        "startCoolTime",
        "coolTimeMax",
        "subCoolTime",
        "startOpenCoolTime",
        "isProduce",
        "open",
        "opening",
        "dorpBlockIds",
        "dropBlockWeightDic",
        "dropBlockSubWeightDic",
    ],
    "BlockTableData": [
        "ProduceEnergy",
        "CoolTime",
        "MaxSubtractCoolTimePer",
        "OnGoingAddedCoolTimeper",
        "OpenCoolTime",
        "ProduceRewardType",
        "ProduceRewardID",
        "ProduceRewardValue",
    ],
}

CLASS_RE = re.compile(r"^public class (?P<name>[A-Za-z0-9_]+)\b")
FIELD_RE = re.compile(r"^\s*(?:public|private|protected|internal).+?\s+(?P<name>[A-Za-z0-9_<>]+); // (?P<offset>0x[0-9A-Fa-f]+)")
RVA_RE = re.compile(r"^\s*// RVA: (?P<rva>0x[0-9A-Fa-f]+) Offset: (?P<offset>0x[0-9A-Fa-f]+) VA: (?P<va>0x[0-9A-Fa-f]+)")
METHOD_RE = re.compile(r"^\s*(?:public|private|protected|internal).+?\s(?P<name>[A-Za-z0-9_<>]+)\(")


def collect() -> tuple[list[dict], list[dict]]:
    methods: list[dict] = []
    fields: list[dict] = []
    current_class = ""
    pending_addr: dict | None = None

    for line_no, line in enumerate(DUMP.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        class_match = CLASS_RE.match(line)
        if class_match:
            current_class = class_match.group("name")
            pending_addr = None
            continue

        rva_match = RVA_RE.match(line)
        if rva_match:
            pending_addr = rva_match.groupdict() | {"line": line_no}
            continue

        if current_class in TARGET_FIELDS:
            field_match = FIELD_RE.match(line)
            if field_match:
                raw_name = field_match.group("name")
                field_name = raw_name
                if raw_name.startswith("<") and ">k__BackingField" in raw_name:
                    field_name = raw_name[1:].split(">")[0]
                if field_name in TARGET_FIELDS[current_class]:
                    fields.append(
                        {
                            "class": current_class,
                            "field": field_name,
                            "raw_field": raw_name,
                            "offset": field_match.group("offset"),
                            "dump_line": line_no,
                        }
                    )

        if current_class in TARGET_METHODS and pending_addr:
            method_match = METHOD_RE.match(line)
            if method_match:
                method_name = method_match.group("name")
                if method_name in TARGET_METHODS[current_class]:
                    methods.append(
                        {
                            "class": current_class,
                            "method": method_name,
                            "signature": line.strip(),
                            "rva": pending_addr["rva"],
                            "offset": pending_addr["offset"],
                            "va": pending_addr["va"],
                            "dump_line": line_no,
                        }
                    )
                pending_addr = None

    return methods, fields


def write_outputs(methods: list[dict], fields: list[dict]) -> None:
    ANALYSIS_DIR.mkdir(parents=True, exist_ok=True)
    with CSV_OUTPUT.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=["class", "method", "signature", "rva", "offset", "va", "dump_line"])
        writer.writeheader()
        writer.writerows(methods)

    lines = [
        "# Producer Runtime Notes",
        "",
        "This note tracks the native methods and fields needed to finish producer refill, open, and cooldown semantics.",
        "",
        "## Method Targets",
        "",
        "| Class | Method | RVA | Signature |",
        "| --- | --- | --- | --- |",
    ]
    for row in methods:
        lines.append(f"| `{row['class']}` | `{row['method']}` | `{row['rva']}` | `{row['signature']}` |")

    lines.extend(
        [
            "",
            "## Field Targets",
            "",
            "| Class | Field | Offset | Dump line |",
            "| --- | --- | --- | ---: |",
        ]
    )
    for row in fields:
        lines.append(f"| `{row['class']}` | `{row['field']}` | `{row['offset']}` | {row['dump_line']} |")

    lines.extend(
        [
            "",
            "## Current Inference",
            "",
            "- `BlockTableData.ProduceEnergy` is the producer's maximum/internal energy source, not player AP.",
            "- Runtime save data stores mutable `ProduceBlockData.produceEnergy` per producer instance.",
            "- `InGame_ItemBlock.OnProduce(... _isUseProduceEnergy = True, ...)` is the next Ghidra target for decrement/refill behavior.",
            "- `SetProduceEnergyData` is the next target for UI/state synchronization after production.",
            "- `NewProduceBlock` and `SetNewProduceBlockData` are the next targets for initial producer instance values and designed-drop list setup.",
            "",
            "## Ghidra Follow-up",
            "",
            "Open `libil2cpp.so` and jump to the RVAs above. Prioritize:",
            "",
            "1. `InGame_ItemBlock.OnProduce`",
            "2. `InGame_ItemBlock.SetProduceEnergyData`",
            "3. `InGame_MapManager.NewProduceBlock`",
            "4. `MapDataManager.SetNewProduceBlockData`",
            "",
        ]
    )
    MD_OUTPUT.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    methods, fields = collect()
    write_outputs(methods, fields)
    print(f"methods={len(methods)}")
    print(f"fields={len(fields)}")
    print(CSV_OUTPUT)
    print(MD_OUTPUT)


if __name__ == "__main__":
    main()
