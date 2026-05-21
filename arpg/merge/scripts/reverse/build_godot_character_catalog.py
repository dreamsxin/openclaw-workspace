#!/usr/bin/env python3
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "reverse-output/assets/derived/table_npc/table_npc_decoded.json"
OUTPUT_DIR = ROOT / "godot-project/data/characters"
CHARACTER_ASSET_DIR = ROOT / "godot-project/assets/characters"


def build_asset_index() -> dict[str, str]:
    index = {}
    if not CHARACTER_ASSET_DIR.exists():
        return index
    for path in CHARACTER_ASSET_DIR.rglob("*"):
        if path.is_file():
            rel = path.relative_to(ROOT / "godot-project").as_posix()
            index[path.stem.lower()] = f"res://{rel}"
    return index


def asset_path(asset_index: dict[str, str], key: str) -> str:
    if not key:
        return ""
    return asset_index.get(key.lower(), "")


def slim_npc(row: dict, asset_index: dict[str, str]) -> dict:
    return {
        "npc_id": int(row["NpcID"]),
        "name": row["Name"],
        "skin_id": int(row["SkinID"]),
        "parent_id": int(row["ParentID"]),
        "npc_type": int(row["NPCType"]),
        "personal_color": row["PersonalColor"],
        "is_dormitory": bool(row["IsDormitory"]),
        "unlock": {
            "quest_id": int(row["UnlockQuestID"]),
            "furniture_id": int(row["NeedUnlockFurnitureID"]),
            "type": int(row["UnlockType"]),
            "value_01": int(row["UnlockValue_01"]),
            "value_02": int(row["UnlockValue_02"]),
            "anim": bool(row["isUnlockAnim"]),
        },
        "asset_keys": {
            "icon_ld": row["Icon_LD"],
            "icon_sd": row["Icon_SD"],
            "prefab_ld": row["Prefab_LD"],
            "prefab_sd": row["Prefab_SD"],
            "prefab_sd_out_game": row["Prefab_SD_OutGame"],
            "npc_icon": row["Npc_Icon"],
            "npc_cry_icon": row["Npc_CryIcon"],
            "npc_prefab": row["Npc_Prefab"],
        },
        "assets": {
            "icon_ld": asset_path(asset_index, row["Icon_LD"]),
            "icon_sd": asset_path(asset_index, row["Icon_SD"]),
            "prefab_ld": asset_path(asset_index, row["Prefab_LD"]),
            "prefab_sd": asset_path(asset_index, row["Prefab_SD"]),
            "prefab_sd_out_game": asset_path(asset_index, row["Prefab_SD_OutGame"]),
            "npc_icon": asset_path(asset_index, row["Npc_Icon"]),
            "npc_cry_icon": asset_path(asset_index, row["Npc_CryIcon"]),
            "npc_prefab": asset_path(asset_index, row["Npc_Prefab"]),
        },
    }


def main() -> None:
    decoded = json.loads(SOURCE.read_text(encoding="utf-8"))
    asset_index = build_asset_index()

    npcs = [slim_npc(row, asset_index) for row in decoded["NpcTableData"]]
    npc_by_id = {row["npc_id"]: row for row in npcs}

    skills_by_id: dict[int, list[dict]] = {}
    for row in decoded["MaidSkillTableData"]:
        skills_by_id.setdefault(int(row["SkillID"]), []).append(
            {
                "level": int(row["Lv"]),
                "skill_type": int(row["SkillType"]),
                "target_id": row["SkillTargetID"],
                "value": float(row["SkillValue"]),
            }
        )

    levels_by_maid: dict[int, list[dict]] = {}
    for row in decoded["MaidLevelTableData"]:
        levels_by_maid.setdefault(int(row["MaidId"]), []).append(
            {
                "level": int(row["LV"]),
                "need_exp": int(row["NeedExp"]),
                "reward_type": int(row["RewardType"]),
                "reward_id": int(row["RewardID"]),
                "reward_count": int(row["RewardCount"]),
            }
        )

    maids = []
    for row in decoded["MaidInfoTableData"]:
        maid_id = int(row["MaidID"])
        skill_id = int(row["SkillID"])
        npcs_for_maid = [
            npc
            for npc in npcs
            if npc["npc_id"] == maid_id or npc["parent_id"] == maid_id
        ]
        if not npcs_for_maid and maid_id in npc_by_id:
            npcs_for_maid = [npc_by_id[maid_id]]
        maids.append(
            {
                "maid_id": maid_id,
                "profile": {
                    "member": row["Member"],
                    "tribe": row["Tribe"],
                    "height": row["Height"],
                    "birthday": row["Birthday"],
                    "age": row["Age"],
                    "cv": row["CV"],
                    "favorite": row["Favorite"],
                    "hate": row["Hate"],
                },
                "skill_id": skill_id,
                "skills": skills_by_id.get(skill_id, []),
                "liked_gift_ids": [
                    int(row["LikeGiftID_01"]),
                    int(row["LikeGiftID_02"]),
                    int(row["LikeGiftID_03"]),
                ],
                "levels": levels_by_maid.get(maid_id, []),
                "npc_records": npcs_for_maid,
            }
        )

    customer_npcs = [npc for npc in npcs if npc["npc_type"] == 2]
    dialogs = []
    for row in decoded["InGameNpcDialog"]:
        dialogs.append(
            {
                "dialog_id": int(row["DialogID"]),
                "npc_id": int(row["NpcID"]),
                "skin_id": int(row["SkinID"]),
                "anim_type": int(row["AnimType"]),
                "facial_type": int(row["FacialType"]),
                "dialog_type": int(row["DialogType"]),
                "audio_name": row["AudioName"],
                "text": {
                    "kor": row["KOR"],
                    "eng": row["ENG"],
                    "jp": row["JP"],
                    "zh_cht": row["ZH_CHT"],
                    "zh_chs": row["ZH_CHS"],
                },
            }
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    payloads = {
        "npcs.json": {
            "source": decoded["source"],
            "note": "Generated from decoded Table_Npc.NpcTableData.",
            "npcs": npcs,
        },
        "maids.json": {
            "source": decoded["source"],
            "note": "Generated from MaidInfo, MaidLevel, MaidSkill, and matching NPC rows.",
            "maids": maids,
        },
        "customers.json": {
            "source": decoded["source"],
            "note": "First-pass customer catalog from NpcTableData NPCType=2. CustomerTableData remains a second-pass decode target.",
            "customers": customer_npcs,
        },
        "dialogs.json": {
            "source": decoded["source"],
            "note": decoded["decode_notes"]["dialog"],
            "decode_meta": decoded["decode_notes"]["dialog_meta"],
            "dialogs": dialogs,
        },
    }
    for filename, payload in payloads.items():
        (OUTPUT_DIR / filename).write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    print(f"npcs={len(npcs)}")
    print(f"maids={len(maids)}")
    print(f"customers={len(customer_npcs)}")
    print(f"dialogs={len(dialogs)}")
    print(OUTPUT_DIR)


if __name__ == "__main__":
    main()
