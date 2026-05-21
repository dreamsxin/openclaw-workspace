from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPINE_DIR = ROOT / "godot-project" / "assets" / "spine" / "loading" / "kokomi_Loading"
ATLAS_PATH = SPINE_DIR / "kokomi_Loading.atlas.txt"
SKEL_PATH = SPINE_DIR / "kokomi_Loading.skel.bytes"
RIG_PATH = SPINE_DIR / "kokomi_Loading.rig.json"

BONES = [
    ("root", "", (0, 0)),
    ("background", "root", (0, 0)),
    ("table", "root", (0, 520)),
    ("pelvis", "root", (0, 120)),
    ("lower_body", "pelvis", (0, 45)),
    ("torso", "pelvis", (0, -195)),
    ("neck", "torso", (0, -160)),
    ("head", "neck", (0, -95)),
    ("face", "head", (0, -5)),
    ("hair_top", "head", (0, -100)),
    ("hair_left", "head", (-150, 70)),
    ("hair_right", "head", (155, 70)),
    ("back_ribbon", "torso", (0, -105)),
    ("left_arm", "torso", (-205, 60)),
    ("right_arm", "torso", (210, 70)),
    ("left_leg", "lower_body", (-145, 160)),
    ("right_leg", "lower_body", (120, 165)),
    ("left_foot", "left_leg", (-20, 125)),
    ("right_foot", "right_leg", (25, 123)),
]

DRAW_ORDER = [
    "Background/Background",
    "Back_Ribbon_2",
    "Back_Ribbon_5",
    "Twintails_L_1",
    "Twintails_R_2",
    "Twintails_L_2",
    "Skirt_Back",
    "Leg_Thigh_R",
    "Leg_Thigh_L",
    "Leg_Calf_R",
    "Leg_Calf_L",
    "Leg_Foot_R",
    "Leg_Foot_L",
    "Skrit_Frill_Back",
    "Skirt_Front",
    "Skirt_Frill_Front",
    "Chest",
    "Breast",
    "Apron_Back",
    "Apron_Front",
    "Shoulder_Frill_L_Back",
    "Shoulder_Frill_R",
    "Arm_R_Upper",
    "Arm_R_Lower",
    "Hand_R",
    "Sleeves_L_Puff",
    "Arm_L_Upper",
    "Arm_L_Lower",
    "Hand_L",
    "Neck",
    "Head",
    "Ear",
    "Hairband",
    "Hairband_Frill",
    "Hair_Bang_1",
    "Hair_Bang_2",
    "Hair_Bang_3",
    "Side_Hair_L_Upper",
    "Side_Hair_R_Upper",
    "Eye_Whites_L",
    "Eye_Whites_R",
    "Eye_Iris_L",
    "Eye_Iris_R",
    "Eye_Pupil_L",
    "Eye_Pupil_R",
    "Eye_Highlights_L_1",
    "Eye_Highlights_R_1",
    "Eyelashes_Lower_L",
    "Eyelashes_Lower_R",
    "Eyelsahes_Upper_L",
    "Eyelsahes_Upper_R",
    "Eyebrow",
    "Nose",
    "Mouth",
    "Cafe_Table",
    "Dishcloth_Front",
]

BONE_ABSOLUTE = {
    "background": (0, 0),
    "table": (0, 520),
    "pelvis": (0, 120),
    "lower_body": (0, 165),
    "torso": (0, -75),
    "neck": (0, -235),
    "head": (0, -330),
    "face": (0, -335),
    "hair_top": (0, -430),
    "hair_left": (-150, -260),
    "hair_right": (155, -260),
    "back_ribbon": (0, -180),
    "left_arm": (-205, -15),
    "right_arm": (210, -5),
    "left_leg": (-145, 320),
    "right_leg": (120, 325),
    "left_foot": (-165, 445),
    "right_foot": (145, 448),
}


def atlas_regions() -> set[str]:
    regions: set[str] = set()
    current_page = ""
    for raw_line in ATLAS_PATH.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or ":" in line:
            continue
        if line.endswith(".png"):
            current_page = line
            continue
        if current_page:
            regions.add(line)
    return regions


def skeleton_string_evidence() -> dict[str, object]:
    data = SKEL_PATH.read_bytes()
    strings = [(m.start(), m.group().decode("ascii", "replace")) for m in re.finditer(rb"[ -~]{3,}", data)]
    version = next((text for _, text in strings if re.fullmatch(r"\d+\.\d+\.\d+", text)), "")
    bone_keywords = {
        "root",
        "sub_root",
        "Pelvis",
        "Lower body_H",
        "Skirt_H",
        "body_1",
        "body_2",
        "nack",
        "Back_Ribbon_H",
        "Leg_Thigh_L_H",
        "Leg_Thigh_R_H",
    }
    bones = [{"offset": offset, "name": text} for offset, text in strings if text in bone_keywords]
    regions = [{"offset": offset, "name": text} for offset, text in strings if text in DRAW_ORDER]
    return {
        "spine_version": version,
        "string_count": len(strings),
        "bone_name_samples": bones[:32],
        "region_name_samples": regions[:64],
    }


def bone_for_region(region: str) -> str:
    if region.startswith("Background"):
        return "background"
    if region == "Cafe_Table" or region == "Dishcloth_Front":
        return "table"
    if region.startswith("Leg_Foot_L"):
        return "left_foot"
    if region.startswith("Leg_Foot_R"):
        return "right_foot"
    if region.startswith("Leg_Calf_L") or region.startswith("Leg_Thigh_L"):
        return "left_leg"
    if region.startswith("Leg_Calf_R") or region.startswith("Leg_Thigh_R"):
        return "right_leg"
    if region.startswith("Skirt") or region.startswith("Skrit"):
        return "lower_body"
    if region.startswith("Shoulder_Frill_L") or region.startswith("Sleeves_L") or region.startswith("Arm_L") or region == "Hand_L":
        return "left_arm"
    if region.startswith("Shoulder_Frill_R") or region.startswith("Arm_R") or region == "Hand_R":
        return "right_arm"
    if region == "Neck":
        return "neck"
    if region == "Head" or region == "Ear":
        return "head"
    if region.startswith("Eye_") or region.startswith("Eyel") or region.startswith("Eyels") or region in {"Eyebrow", "Mouth", "Mouth_Closed", "Nose", "Nose_Highlights"}:
        return "face"
    if region.startswith("Hair_Bang") or region.startswith("Hairband"):
        return "hair_top"
    if region.startswith("Side_Hair_L") or region.startswith("Twintails_L"):
        return "hair_left"
    if region.startswith("Side_Hair_R") or region.startswith("Twintails_R"):
        return "hair_right"
    if region.startswith("Back_Ribbon"):
        return "back_ribbon"
    return "torso"


def canonical_position(region: str) -> tuple[int, int]:
    bone = bone_for_region(region)
    if region in {"Chest", "Breast", "Apron_Back", "Apron_Front", "Shoulder_Frill_Front"}:
        return (0, -75)
    return BONE_ABSOLUTE.get(bone, (0, 0))


def main() -> None:
    regions = atlas_regions()
    attachments = []
    for region in DRAW_ORDER:
        if region not in regions:
            continue
        bone = bone_for_region(region)
        absolute = canonical_position(region)
        bone_absolute = BONE_ABSOLUTE.get(bone, (0, 0))
        attachments.append(
            {
                "region": region,
                "bone": bone,
                "position": [absolute[0] - bone_absolute[0], absolute[1] - bone_absolute[1]],
                "scale": [1.0, 1.0],
            }
        )

    rig = {
        "schema": "openclaw-spine-rig-v1",
        "source": {
            "atlas": str(ATLAS_PATH.relative_to(ROOT)).replace("\\", "/"),
            "skeleton": str(SKEL_PATH.relative_to(ROOT)).replace("\\", "/"),
            "note": "Derived bridge rig for Godot preview until exact Spine binary timeline playback is implemented.",
        },
        "evidence": skeleton_string_evidence(),
        "bones": [{"name": name, "parent": parent, "position": [pos[0], pos[1]]} for name, parent, pos in BONES],
        "draw_order": [item["region"] for item in attachments],
        "attachments": attachments,
        "animations": {
            "loading_idle": {
                "duration": 3.4,
                "bone_channels": {
                    "torso": {"translate": [0, -5], "frequency": 2.2, "phase": 0.0},
                    "neck": {"translate": [0, -3], "frequency": 2.2, "phase": 0.1},
                    "head": {"translate": [9, -8], "rotate_degrees": 1.8, "frequency": 1.35, "phase": 0.0},
                    "face": {"translate": [9, -8], "rotate_degrees": 1.8, "frequency": 1.35, "phase": 0.0},
                    "hair_top": {"translate": [8, -6], "rotate_degrees": 1.2, "frequency": 1.35, "phase": 0.2},
                    "hair_left": {"translate": [-18, -7], "rotate_degrees": -3.8, "frequency": 1.35, "phase": 0.3},
                    "hair_right": {"translate": [18, -7], "rotate_degrees": 3.8, "frequency": 1.35, "phase": 0.3},
                    "back_ribbon": {"translate": [12, -4], "rotate_degrees": 2.6, "frequency": 1.35, "phase": 0.4},
                    "left_arm": {"translate": [-8, 6], "rotate_degrees": -2.6, "frequency": 1.35, "phase": 0.25},
                    "right_arm": {"translate": [8, 6], "rotate_degrees": 2.6, "frequency": 1.35, "phase": 0.25},
                    "lower_body": {"translate": [5, 3], "frequency": 1.35, "phase": 0.15},
                    "left_leg": {"translate": [-2, 2], "frequency": 1.35, "phase": 0.15},
                    "right_leg": {"translate": [2, 2], "frequency": 1.35, "phase": 0.15},
                },
                "blink": {"period": 3.4, "start": 3.16, "duration": 0.16, "scale_y": 0.22, "offset_y": 8.0},
            }
        },
    }
    RIG_PATH.write_text(json.dumps(rig, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote {RIG_PATH}")
    print(f"Attachments: {len(attachments)} / draw candidates: {len(DRAW_ORDER)}")


if __name__ == "__main__":
    main()
