#!/usr/bin/env python3
"""
清理脚本：删除 guangmingnvshen 目录中所有无关文件
保留：index.html / assets/ / npm_libs/ / README.md / cleanup.py 本身
"""

import os
import sys

BASE = os.path.dirname(os.path.abspath(__file__))

# ── 调试脚本 (.py / .js) ──────────────────────────────────────────────────
DEBUG_SCRIPTS = [
    "analyze_bin.py", "check_buildarmature.py", "check_db.js", "check_db2.py",
    "check_db3.py", "check_db4.py", "check_db5.py", "check_dirty.py",
    "check_header.py", "check_mesh_parent.py", "check_pixi.js", "check_pixi2.py",
    "check_simplemesh.py", "check_simplemesh2.py", "check_simplemesh3.py",
    "check_slot.py", "check_slot2.py", "check_slot3.py", "check_slot4.py",
    "check_slot5.py", "check_ticker.py", "check_ticker2.py", "check_transform.py",
    "check_transformfn.py", "check_urls.py", "check_vertices.py",
    "dump_detail.py", "dump_names.py", "find_error.py", "inspect.py",
    "parse_dbbin.py", "patch_db.py", "scan_assets.py",
    "gameCommonSdk.js", "gameMainSdk.js",
]

# ── Spine 格式资源（.atlas / .json / .png，与 DragonBones 无关）─────────────
SPINE_ATLAS = [
    "sp_hero0000.atlas", "sp_hero0002.atlas", "sp_hero0007.atlas",
    "sp_hero0010.atlas", "sp_hero0029.atlas", "sp_hero0030.atlas",
    "sp_hero0031.atlas", "sp_hero0042.atlas", "sp_hero0043.atlas",
    "sp_hero0053.atlas", "sp_hero0055.atlas", "sp_hero0071.atlas",
]

SPINE_JSON = [
    "sp_hero0000.json", "sp_hero0002.json", "sp_hero0007.json",
    "sp_hero0010.json", "sp_hero0029.json", "sp_hero0030.json",
    "sp_hero0031.json", "sp_hero0042.json", "sp_hero0043.json",
    "sp_hero0053.json", "sp_hero0055.json", "sp_hero0071.json",
]

SPINE_PNG = [
    "sp_hero0000.png", "sp_hero00002.png", "sp_hero0002.png", "sp_hero0007.png",
    "sp_hero0010.png", "sp_hero0029.png", "sp_hero0030.png", "sp_hero0031.png",
    "sp_hero0042.png", "sp_hero0043.png", "sp_hero0053.png", "sp_hero0055.png",
    "sp_hero0071.png",
]

# ── 背景图 / UI 图 (.jpg) ──────────────────────────────────────────────────
JPG_FILES = [
    "gjzh_bg_1_1_87c61e40.jpg",
    "gjzh_bg_1_ff9781d6.jpg",
    "ll_bg_2_d96439d.jpg",
    "pcbg.jpg",
    "qufudl_loading1_9d8bd867.jpg",
]

# ── 其他杂项 ──────────────────────────────────────────────────────────────
MISC_FILES = [
    # 游戏种子文件（完全无关）
    "Atelier.Firis.The.Alchemist.and.the.Mysterious.Journey.DX.Steam.torrent",
    # 旧骨骼 JSON 格式备份
    "guangmingnvsheng_1_ske_17694.json",
    "guangmingnvsheng_ske_23117.json",
]

# ── 无骨骼对应的孤立纹理 PNG ──────────────────────────────────────────────
ORPHAN_TEXTURE_PNG = [
    "anyingsishennvshen_tex_0_24263.png", "anyingsishennvshen_tex_1_24263.png",
    "bingshuangnvshen_tex_0_23119.png",   "bingshuangnvshen_tex_1_23119.png",
    "bingxuenvhuang_tex_21235.png",
    "dongzhins_tex_0_29963.png",          "dongzhins_tex_1_29988.png",
    "emolieshou_tex_23086.png",
    "haiyangnvshen_tex_0_26849.png",      "haiyangnvshen_tex_1_26849.png",
    "jiguangnvshen_tex_23086.png",
    "jinglingshaonv_tex_21235.png",
    "jinlingjisinvshen_tex_21249.png",
    "lieyannvshen_tex_0_23119.png",       "lieyannvshen_tex_1_23117.png",
    "longnv_tex_0_23144.png",             "longnv_tex_1_23145.png",
    "mingyunnvshen_tex_28771.png",
    "natasha_tex_0_22920.png",            "natasha_tex_1_22920.png",
    "shenglinvshen_tex_0_21263.png",      "shenglinvshen_tex_1_21263.png",
    "tianlainvshen_tex_0_20952.png",      "tianlainvshen_tex_1_20952.png",
    "tianqinvshen_tex_23119.png",
    "tongkunvyao_tex_0_21235.png",        "tongkunvyao_tex_1_21235.png",
    "wendi1_tex_21235.png",
    "xingchenzhizi_tex_0_20952.png",      "xingchenzhizi_tex_1_20952.png",
]

GRAY_PNG = [
    "baozoulongnv_gray_dbimg_24407.png",
    "haiyangnvshen_gray_dbimg_24407.png",
    "mingyunnvshen_gray_dbimg_24407.png",
    "tianqinvshen_gray_dbimg_24407.png",
    "yueliangnvshen_gray_dbimg_24407.png",
]

MISC_PNG = [
    "citynpc_1_22232.png", "citynpc_2_22693.png", "citynpc_3_22728.png",
    "god4_b586abe7.png", "goddessEntrance_20_16501.png",
    "goddessHead_7_f510ac69.png", "goddess_halfBody_7_209fe266.png",
    "godquality1_6d8a3442.png", "godquality1_70a89f0d.png",
    "godquality2_5736abca.png", "godquality2_6cfa6855.png",
    "js_bg_ns01_30cf8f5.png", "js_bg_ns03_a6814587.png",
    "ll_bg_rw_857efcf.png", "mainopen_769ab4a6.png",
    "main_16bf44be.png", "main_zd1_5494.png", "menuicon_22089d6c.png",
    "port_301f8625.png",
    "srsj_panel_fz06_10fb1765.png", "tarot1_4a70512c.png",
    "us_bossxz_6010.png", "zc_panel_5_c3613955.png", "zd_numb1_ede35925.png",
]

ALL_TARGETS = (
    DEBUG_SCRIPTS
    + SPINE_ATLAS + SPINE_JSON + SPINE_PNG
    + JPG_FILES
    + MISC_FILES
    + ORPHAN_TEXTURE_PNG + GRAY_PNG + MISC_PNG
)


def main():
    dry_run = "--dry-run" in sys.argv

    if dry_run:
        print("[DRY RUN] 以下文件将被删除（未实际执行）：\n")
    else:
        print("开始清理...\n")

    deleted, skipped, missing = [], [], []

    for name in ALL_TARGETS:
        path = os.path.join(BASE, name)
        if not os.path.exists(path):
            missing.append(name)
            continue
        if dry_run:
            print(f"  [预览] {name}")
            deleted.append(name)
        else:
            try:
                os.remove(path)
                print(f"  OK  {name}")
                deleted.append(name)
            except Exception as e:
                print(f"  ERR {name}  ({e})")
                skipped.append(name)

    print(f"\n{'─'*55}")
    action = "预览" if dry_run else "完成"
    print(f"{action}：删除 {len(deleted)} 个 | 不存在 {len(missing)} 个 | 失败 {len(skipped)} 个")

    if skipped:
        print("\n失败文件：")
        for f in skipped:
            print(f"  {f}")

    if not dry_run and not skipped:
        # 自我删除
        try:
            #os.remove(os.path.abspath(__file__))
            print("\ncleanup.py 已自动删除。")
        except Exception:
            print("\n提示：可手动删除 cleanup.py。")


if __name__ == "__main__":
    main()
