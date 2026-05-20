#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from build_godot_resource_demo import decompress_cocos_uuid

ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
OUT_DIR = ROOT / "data" / "prefab_layouts"
MANIFEST_PATH = ROOT / "data" / "prefab_layouts.json"
BUNDLES = ["resources", "main", "internal"]
RESOURCE_CONFIG_PATH = ROOT / "assets" / "resources" / "config.json"
RESOURCE_CONFIG = json.loads(RESOURCE_CONFIG_PATH.read_text(encoding="utf-8")) if RESOURCE_CONFIG_PATH.exists() else {}
RESOURCE_PATHS = RESOURCE_CONFIG.get("paths", {})
RESOURCE_UUIDS = RESOURCE_CONFIG.get("uuids", [])
RESOURCE_PATH_TO_UUID = {
    item[0]: RESOURCE_UUIDS[int(index)]
    for index, item in RESOURCE_PATHS.items()
    if isinstance(item, list)
    and len(item) >= 2
    and str(item[1]) == "9"
    and int(index) < len(RESOURCE_UUIDS)
}
PREFABS = [
    ("启动加载", "Prefab/loading/LoadingPre"),
    ("加载进度", "Prefab/loading/loadingProgress"),
    ("适龄提示", "Prefab/loading/shilingPre"),
    ("隐私协议", "Prefab/loading/useprivacyPre"),
    ("登录面板", "Prefab/login/LoginPre"),
    ("登录选服", "Prefab/login/pfLoginPanelPre"),
    ("主城", "Prefab/mainpanel/MainPre"),
    ("主城导航", "Prefab/mainpanel/daohangPre"),
    ("主城头像", "Prefab/mainpanel/heroHead"),
    ("主城默认角色", "Prefab/HerolhPrefab/105004"),
    ("资源条", "Prefab/comPrefab/MoneyItemPre"),
    ("商店", "Prefab/Shop/ShopPre"),
    ("商店页签", "Prefab/Shop/ShopItemPre"),
    ("商店商品", "Prefab/Shop/GoodsItemPre"),
    ("商店购买确认", "Prefab/Shop/ShopBuyEquitPre"),
    ("英雄", "Prefab/HeroPanel/HeroMainPre"),
    ("英雄详情", "Prefab/HeroPanel/HeroBookDetailPre"),
    ("英雄页签", "Prefab/HeroPanel/HeroTabPre"),
    ("英雄升级", "Prefab/HeroPanel/HeroUpLvPre"),
    ("英雄突破", "Prefab/HeroPanel/HeroBreakthroughPre"),
    ("英雄重置", "Prefab/HeroPanel/HeroResetPre"),
    ("英雄新技能", "Prefab/HeroPanel/HeroGetNewSkillsPre"),
    ("英雄装备子页", "Prefab/HeroPanel/zhuangbeiBox"),
    ("英雄装备替换", "Prefab/HeroPanel/HeroEquipChangePre"),
    ("英雄评论", "Prefab/HeroPanel/HeroCommentPre"),
    ("符文选择", "Prefab/FuWen/SelectFuwenPre"),
    ("符文刷新", "Prefab/FuWen/FuwenRefreshPre"),
    ("英雄升星子页", "Prefab/HeroPanel/shengxingBox"),
    ("英雄升星弹窗", "Prefab/HeroPanel/HeroUpgradeStarPre"),
    ("英雄战意子页", "Prefab/HeroPanel/zhanyiBox"),
    ("英雄属性详情", "Prefab/HeroPanel/HeroAttrTips"),
    ("战意领悟", "Prefab/HeroPanel/HeroWarpathGraspPre"),
    ("战意升级", "Prefab/HeroPanel/HeroWarpathUpPanel"),
    ("战意预览", "Prefab/ForgePanel/ForgeWarspiritPanel"),
    ("战意预览面板", "Prefab/HeroPanel/HeroWarpathPreviewPanel"),
    ("衣装展示", "Prefab/SkinShopPanel/SkinShowPre"),
    ("英雄列表", "Prefab/HeroListPanel/HeroListPre"),
    ("英雄列表卡片", "Prefab/comPrefab/HeroGridPre"),
    ("英雄图鉴卡片", "Prefab/HeroListPanel/HeroBookItemPre"),
    ("英雄等级共享", "Prefab/HeroListPanel/HeroLevelSharedPre"),
    ("英魂殿", "Prefab/HeroPalace/HeroPalacePre"),
    ("英雄阵容", "Prefab/HeroXZPrefab/HeroNormalarrayPre"),
    ("英雄升星", "Prefab/HeroXZPrefab/HeroStarPre"),
    ("背包", "Prefab/BagPanel/BagPre"),
    ("背包格子", "Prefab/BagPanel/GridBoxItemPre"),
    ("抽卡", "Prefab/DrawCard/drawCardPre"),
    ("抽卡英雄展示", "Prefab/DrawCard/HeroShowPre"),
    ("抽卡奖励预览", "Prefab/DrawCard/DrawRewardPreviewPre"),
    ("战斗", "Prefab/Battle/battle"),
    ("布阵", "Prefab/CombatPrefab/CombatFormPre"),
    ("挂机主线", "Prefab/guajiPanel/guajiPrefab"),
    ("挂机世界地图", "Prefab/guajiPanel/worldMapPre"),
    ("挂机世界地图关卡", "Prefab/guajiPanel/worldMapItemPre"),
    ("挂机通关地图", "Prefab/guajiPanel/WorldtgMapPre"),
    ("挂机章节", "Prefab/guajiPanel/GuajiZhangjiePre"),
    ("挂机升级", "Prefab/guajiPanel/GuajiupPre"),
    ("活动面板", "Prefab/ActivityPanel/ActivityPre"),
    ("活动抽卡", "Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre"),
    ("活动抽卡-登录领取", "Prefab/ActivityPanel/DrawCardActivity/13002"),
    ("活动抽卡-循环礼包", "Prefab/ActivityPanel/DrawCardActivity/13003"),
    ("活动抽卡-抽数任务", "Prefab/ActivityPanel/DrawCardActivity/13004"),
    ("活动抽卡-许愿礼包", "Prefab/ActivityPanel/DrawCardActivity/13005"),
    ("活动抽卡页签", "Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityToggle"),
    ("打工", "Prefab/TaskPanel/ActivityYiwuPre"),
    ("打工页签", "Prefab/TaskPanel/ActivityYiwuTapPre"),
    ("打工任务", "Prefab/ActivityPanel/hitworkactivity/HitWorkPre"),
    ("每日礼包", "Prefab/DailyGift/DailyGiftPre"),
    ("礼包", "Prefab/Gift/GiftPre"),
    ("特惠活动", "Prefab/ActivityPanel/guoqingactivity/GuoqingActivity"),
    ("限时礼包", "Prefab/ActivityPanel/jueduiactivity/ActivityXianShiLiHePre"),
    ("特惠礼盒", "Prefab/ActivityPanel/jueduiactivity/ActivityTeHuiLiHePre"),
    ("开服战神", "Prefab/ActivityPanel/kaifuactivity/zhanshencomePre"),
    ("超级钜惠", "Prefab/ActivityPanel/JuHuiActivity/JuHuiActivityPre"),
    ("召唤卡", "Prefab/ActivityPanel/ZhaoHuanActivity/ZhaoHuanActivityPre"),
    ("竟榜抽奖", "Prefab/pvpActivityPanel/pvpActivityPanel"),
    ("食铁神兽", "Prefab/stssActivityPrefab/oldgodsgraceentrancePre"),
    ("预注册", "Prefab/ActivityPanel/PreRegAvtivity/PreRegAvtivityPre"),
    ("升阶礼包", "Prefab/ElevatePanel/ElevatePre"),
    ("广告奖励", "Prefab/payPanel/AdvertisingPre"),
    ("绑定平台", "Prefab/payPanel/BindPre"),
    ("Discord活动", "Prefab/ActivityPanel/discordActivity/discordActivityPre"),
    ("次元魔战", "Prefab/MozhuPanel/moZhuPre"),
    ("好友", "Prefab/FriendPanel/FriendPanel"),
    ("邮件", "Prefab/EmailPanel/EmailPre"),
    ("排行", "Prefab/rank/RankListPanel"),
    ("战报", "Prefab/WarReport/WarReportPanel"),
    ("任务", "Prefab/TaskPanel/TaskPre"),
    ("客服", "Prefab/UserInfo/KeFuPanel"),
    ("公会", "Prefab/Guild/GuildMainPre"),
    ("公会首领", "Prefab/Guild/GuildBoss/GuildBossPre"),
    ("公会红包", "Prefab/Guild/GuildRedBag/GuildRedBagPre"),
    ("公会科技", "Prefab/Guild/GuildScience/GuildSciencePre"),
    ("公会详情", "Prefab/Guild/GuildXiangqingPre"),
    ("公会战", "Prefab/Guild/GuildWar/GuildWarHallPre"),
    ("公会任务", "Prefab/Guild/GuildTaskPre"),
    ("公会捐献", "Prefab/Guild/Guilddonation/GuilddonationPre"),
    ("竞技", "Prefab/JingjiPrefab/JingjiPre"),
    ("跨服PVP", "Prefab/KuafuPvpPane/KuafuPvpPre"),
    ("组队竞技", "Prefab/JingjiPrefab/team/teamPre"),
    ("天梯", "Prefab/JingjiPrefab/tianti/tiantiPre"),
    ("王者争霸", "Prefab/JingjiPrefab/wangzhe/wangzhePre"),
    ("宝具", "Prefab/TreasurePanel/TreasurePre"),
    ("学院", "Prefab/TeachPlace/TeachListPre"),
    ("冒险地图顶部", "Prefab/MaoxianPanel/MaoxianMapPreTop"),
    ("冒险地图底部", "Prefab/MaoxianPanel/MaoxianMapPreBotton"),
    ("冒险副本", "Prefab/MaoxianPanel/FuBenPre"),
    ("冒险副本条目", "Prefab/MaoxianPanel/fubenItemPrefab"),
    ("遗迹探险", "Prefab/yjTreasure/yjTreasurePre"),
    ("失落神庙", "Prefab/ShiLuoFanePanel/shiLuoFanePre"),
    ("冰龙巢穴", "Prefab/binglongPanel/BingLongGuidePre"),
    ("天空城", "Prefab/SkyCityPanel/SkyCityPre"),
    ("皮肤商店", "Prefab/SkinShopPanel/SkinShopPre"),
    ("通行证", "Prefab/PassPrefab/BigPassPanel"),
    ("爵位", "Prefab/PassPrefab/KnighthoodPanel"),
    ("锻造", "Prefab/ForgePanel/ForgePre"),
    ("占卜", "Prefab/zhanbu/zhanbuPre"),
    ("活动占卜", "Prefab/ActivityPanel/changzhuactivity/ActivityAuguryPre"),
    ("寻星", "Prefab/FindTreasurePanel/FindTreasurePre"),
    ("福利", "Prefab/Welfare/WelfarePre"),
    ("首充", "Prefab/FirstRechargePanel/firstRechargePre"),
    ("升星计划", "Prefab/HeroXZPrefab/StarUpPre"),
    ("活动预告", "Prefab/ActivityForecastPanel/ActivityForecastPre"),
    ("学院塔", "Prefab/MaoxianPanel/BraveManTriedPassInfoPre"),
]


def is_vec2(value: object) -> bool:
    return isinstance(value, list) and len(value) == 3 and value[0] == 5 and all(isinstance(x, (int, float)) for x in value[1:])


def is_trs(value: object) -> bool:
    return (
        isinstance(value, list)
        and len(value) == 10
        and all(isinstance(x, (int, float)) for x in value)
    )


def export_layout(prefab_path: str) -> dict:
    catalog = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))
    prefab = next(item for item in catalog["prefabs"] if item["path"] == prefab_path)
    data = json.loads((ROOT / prefab["import"]).read_text(encoding="utf-8"))
    objects = data[5] if len(data) > 5 and isinstance(data[5], list) else []
    uuid_table = data[1] if len(data) > 1 and isinstance(data[1], list) else []
    classes = data[3] if len(data) > 3 and isinstance(data[3], list) else []
    templates = data[4] if len(data) > 4 and isinstance(data[4], list) else []

    node_records = {}
    for index, item in enumerate(objects):
        if not isinstance(item, list) or len(item) < 2 or not isinstance(item[1], str):
            continue
        node_class, node_values = decode_component(item, classes, templates)
        name = str(node_values.get("_name") or item[1])
        if name.startswith("_") or name in {"data"}:
            continue
        size = vec2_from_cocos(node_values.get("_contentSize"))
        trs = node_values.get("_trs")
        if not is_trs(trs):
            trs = None
        for value in item:
            if size is None and is_vec2(value):
                size = [float(value[1]), float(value[2])]
            elif trs is None and is_trs(value):
                trs = value
        if size is None and trs is None:
            continue
        anchor = anchor_from_cocos(node_values.get("_anchorPoint"))
        parent_index = node_values.get("_parent")
        if not isinstance(parent_index, int):
            parent_index = None
        active = node_values.get("_active", True)
        sprite_uuid = ""
        sprite_info = {}
        skeleton_uuid = ""
        skeleton_info = {}
        label_info = {}
        widget_info = {}
        component_types = []
        for component in iter_components(item):
            class_name, values = decode_component(component, classes, templates)
            if class_name:
                component_types.append(class_name)
            if class_name == "cc.Label":
                label_info = resolve_label(values)
            elif class_name == "cc.Widget":
                widget_info = resolve_widget(values)
        if should_auto_texture(name):
            for component in iter_components(item):
                class_name, values = decode_component(component, classes, templates)
                if class_name in {"cc.Sprite", "cc.Button"}:
                    for ref in sprite_frame_refs(class_name, values):
                        candidate_uuid = uuid_from_ref(ref, uuid_table)
                        candidate_info = resolve_sprite_frame(candidate_uuid)
                        if candidate_info.get("texture_path"):
                            sprite_uuid = candidate_uuid
                            sprite_info = candidate_info
                            if class_name == "cc.Sprite":
                                sprite_info["sprite_type"] = int(values.get("_type", 0) or 0)
                                sprite_info["sprite_size_mode"] = int(values.get("_sizeMode", 0) or 0)
                                sprite_info["sprite_fill_type"] = int(values.get("_fillType", 0) or 0)
                                sprite_info["sprite_fill_start"] = float(values.get("_fillStart", 0.0) or 0.0)
                                sprite_info["sprite_fill_range"] = float(values.get("_fillRange", 0.0) or 0.0)
                                sprite_info["sprite_fill_center"] = vec2_from_cocos(values.get("_fillCenter")) or []
                                sprite_info["sprite_trimmed_mode"] = bool(values.get("_isTrimmedMode", True))
                            break
                    if sprite_info:
                        break
                elif class_name == "sp.Skeleton":
                    candidate_uuid = uuid_from_ref(values.get("_N$skeletonData"), uuid_table)
                    candidate_info = resolve_skeleton_data(candidate_uuid)
                    if candidate_info:
                        skeleton_uuid = candidate_uuid
                        skeleton_info = candidate_info
        if not sprite_info:
            candidate_info = resolve_sprite_frame_by_resource_path(infer_resource_paths(prefab_path, name))
            if candidate_info.get("texture_path"):
                sprite_uuid = candidate_info.get("sprite_uuid", "")
                sprite_info = candidate_info
        node_records[index] = {
            "index": index,
            "name": name,
            "active": bool(active),
            "parent_index": parent_index,
            "size": size or [80.0, 36.0],
            "anchor": anchor or [0.5, 0.5],
            "position": [float(trs[0]), float(trs[1])] if trs else [0.0, 0.0],
            "global_position": [0.0, 0.0],
            "scale": [float(trs[6]), float(trs[7])] if trs else [1.0, 1.0],
            "rotation_z": float(trs[9]) if trs else 0.0,
            "sprite_uuid": sprite_uuid,
            "sprite_resource_path": sprite_info.get("resource_path", ""),
            "texture_path": sprite_info.get("texture_path", ""),
            "sprite_name": sprite_info.get("sprite_name", ""),
            "sprite_rect": sprite_info.get("sprite_rect", []),
            "sprite_offset": sprite_info.get("sprite_offset", []),
            "sprite_original_size": sprite_info.get("sprite_original_size", []),
            "sprite_rotated": bool(sprite_info.get("sprite_rotated", False)),
            "sprite_cap_insets": sprite_info.get("sprite_cap_insets", []),
            "sprite_type": int(sprite_info.get("sprite_type", 0) or 0),
            "sprite_type_name": sprite_type_name(int(sprite_info.get("sprite_type", 0) or 0)),
            "sprite_size_mode": int(sprite_info.get("sprite_size_mode", 0) or 0),
            "sprite_size_mode_name": sprite_size_mode_name(int(sprite_info.get("sprite_size_mode", 0) or 0)),
            "sprite_fill_type": int(sprite_info.get("sprite_fill_type", 0) or 0),
            "sprite_fill_start": float(sprite_info.get("sprite_fill_start", 0.0) or 0.0),
            "sprite_fill_range": float(sprite_info.get("sprite_fill_range", 0.0) or 0.0),
            "sprite_fill_center": sprite_info.get("sprite_fill_center", []),
            "sprite_trimmed_mode": bool(sprite_info.get("sprite_trimmed_mode", True)),
            "skeleton_uuid": skeleton_uuid,
            "skeleton_name": skeleton_info.get("name", ""),
            "skeleton_textures": skeleton_info.get("textures", []),
            "skeleton_animations": skeleton_info.get("animations", []),
            "label_text": label_info.get("text", ""),
            "label_font_size": label_info.get("font_size", 0),
            "label_line_height": label_info.get("line_height", 0),
            "label_horizontal_align": label_info.get("horizontal_align", 0),
            "label_vertical_align": label_info.get("vertical_align", 0),
            "widget": widget_info,
            "component_types": component_types,
        }

    apply_widget_layout(node_records)

    global_cache = {}
    for index, node in node_records.items():
        node["global_position"] = global_position(index, node_records, global_cache)
    origin_mode = detect_origin_mode(node_records)
    for node in node_records.values():
        add_screen_rect(node, origin_mode)

    component_bindings = extract_custom_component_bindings(objects, classes, templates, node_records)

    return {
        "prefab": prefab_path,
        "import": prefab["import"],
        "origin_mode": origin_mode,
        "nodes": list(node_records.values()),
        "component_bindings": component_bindings,
    }


def vec2_from_cocos(value: object) -> list[float] | None:
    if is_vec2(value):
        return [float(value[1]), float(value[2])]
    return None


def anchor_from_cocos(value: object) -> list[float] | None:
    if isinstance(value, list) and len(value) == 3 and all(isinstance(x, (int, float)) for x in value[1:]):
        return [float(value[1]), float(value[2])]
    return None


def sprite_type_name(value: int) -> str:
    names = {
        0: "simple",
        1: "sliced",
        2: "tiled",
        3: "filled",
        4: "mesh",
    }
    return names.get(value, f"unknown_{value}")


def sprite_size_mode_name(value: int) -> str:
    names = {
        0: "custom",
        1: "trimmed",
        2: "raw",
    }
    return names.get(value, f"unknown_{value}")


def detect_origin_mode(node_records: dict[int, dict]) -> str:
    for node in node_records.values():
        size = node.get("size", [0.0, 0.0])
        pos = node.get("global_position", [0.0, 0.0])
        if len(size) < 2 or len(pos) < 2:
            continue
        w = float(size[0])
        h = float(size[1])
        x = float(pos[0])
        y = float(pos[1])
        if w >= 1200.0 and h >= 700.0 and abs(x - 640.0) < 4.0 and abs(y - 360.0) < 4.0:
            return "bottom_left"
    return "center"


def add_screen_rect(node: dict, origin_mode: str) -> None:
    pos = node.get("global_position", node.get("position", [0.0, 0.0]))
    size = node.get("size", [0.0, 0.0])
    anchor = node.get("anchor", [0.5, 0.5])
    x = float(pos[0])
    y = float(pos[1])
    w = float(size[0])
    h = float(size[1])
    ax = float(anchor[0])
    ay = float(anchor[1])
    if origin_mode == "bottom_left":
        screen_x = x - w * ax
        screen_y = 720.0 - y - h * (1.0 - ay)
    else:
        screen_x = 640.0 + x - w * ax
        screen_y = 360.0 - y - h * (1.0 - ay)
    node["screen_position"] = [screen_x, screen_y]
    node["screen_rect"] = [screen_x, screen_y, w, h]


def apply_widget_layout(node_records: dict[int, dict]) -> None:
    for _ in range(3):
        for node in node_records.values():
            widget = node.get("widget") or {}
            if not widget:
                continue
            parent_index = node.get("parent_index")
            if not isinstance(parent_index, int) or parent_index not in node_records:
                continue
            parent = node_records[parent_index]
            apply_widget_to_node(node, parent, widget)


def apply_widget_to_node(node: dict, parent: dict, widget: dict) -> None:
    flags = int(widget.get("align_flags", 0) or 0)
    if flags <= 0:
        return
    parent_size = parent.get("size", [0.0, 0.0])
    size = [float(node.get("size", [0.0, 0.0])[0]), float(node.get("size", [0.0, 0.0])[1])]
    pos = [float(node.get("position", [0.0, 0.0])[0]), float(node.get("position", [0.0, 0.0])[1])]
    anchor = node.get("anchor", [0.5, 0.5])
    parent_w = float(parent_size[0])
    parent_h = float(parent_size[1])
    anchor_x = float(anchor[0])
    anchor_y = float(anchor[1])

    top = float(widget.get("top", 0.0) or 0.0)
    bottom = float(widget.get("bottom", 0.0) or 0.0)
    left = float(widget.get("left", 0.0) or 0.0)
    right = float(widget.get("right", 0.0) or 0.0)
    hcenter = float(widget.get("horizontal_center", 0.0) or 0.0)
    vcenter = float(widget.get("vertical_center", 0.0) or 0.0)

    # Cocos Creator widget flags: TOP=1, MID=2, BOT=4, LEFT=8, CENTER=16, RIGHT=32.
    if flags & 8 and flags & 32:
        size[0] = max(0.0, parent_w - left - right)
        pos[0] = -parent_w * 0.5 + left + size[0] * anchor_x
    elif flags & 8:
        pos[0] = -parent_w * 0.5 + left + size[0] * anchor_x
    elif flags & 32:
        pos[0] = parent_w * 0.5 - right - size[0] * (1.0 - anchor_x)
    elif flags & 16:
        pos[0] = hcenter

    if flags & 1 and flags & 4:
        size[1] = max(0.0, parent_h - top - bottom)
        pos[1] = parent_h * 0.5 - top - size[1] * (1.0 - anchor_y)
    elif flags & 1:
        pos[1] = parent_h * 0.5 - top - size[1] * (1.0 - anchor_y)
    elif flags & 4:
        pos[1] = -parent_h * 0.5 + bottom + size[1] * anchor_y
    elif flags & 2:
        pos[1] = vcenter

    node["size"] = size
    node["position"] = pos
    node["widget_applied"] = True


def global_position(index: int, node_records: dict[int, dict], cache: dict[int, list[float]]) -> list[float]:
    if index in cache:
        return cache[index]
    node = node_records[index]
    local = node.get("position", [0.0, 0.0])
    x = float(local[0])
    y = float(local[1])
    parent_index = node.get("parent_index")
    if isinstance(parent_index, int) and parent_index in node_records and parent_index != index:
        parent = global_position(parent_index, node_records, cache)
        x += float(parent[0])
        y += float(parent[1])
    cache[index] = [x, y]
    return cache[index]


def extract_custom_component_bindings(objects: list, classes: list, templates: list, node_records: dict[int, dict]) -> list[dict]:
    bindings = []
    for owner_index, item in enumerate(objects):
        if owner_index not in node_records or not isinstance(item, list):
            continue
        for component in iter_components(item):
            class_name, values = decode_component(component, classes, templates)
            if not is_custom_runtime_component(class_name):
                continue
            fields = {}
            raw_refs = {}
            unresolved = {}
            for field, value in values.items():
                if isinstance(value, int):
                    raw_refs[field] = value
                target_index = infer_component_field_target(field, owner_index, node_records)
                if target_index is not None and target_index in node_records:
                    fields[field] = {
                        "index": target_index,
                        "name": node_records[target_index].get("name", ""),
                    }
                elif field != "node":
                    unresolved[field] = value
            entry = {
                "owner_index": owner_index,
                "owner_name": node_records[owner_index].get("name", ""),
                "component": class_name,
                "fields": fields,
            }
            if raw_refs:
                entry["raw_refs"] = raw_refs
            if unresolved:
                entry["unresolved_fields"] = unresolved
            bindings.append(entry)
    return bindings


def is_custom_runtime_component(class_name: str) -> bool:
    if not class_name:
        return False
    if class_name.startswith("cc."):
        return False
    if class_name.startswith("sp."):
        return False
    return True


def infer_component_field_target(field: str, owner_index: int, node_records: dict[int, dict]) -> int | None:
    candidates = descendant_indices(owner_index, node_records)
    candidates.append(owner_index)
    alias_names = component_field_aliases(field)
    for alias in alias_names:
        alias_norm = normalize_name(alias)
        for index in candidates:
            if normalize_name(str(node_records[index].get("name", ""))) == alias_norm:
                return index
    field_norm = normalize_name(field)
    for index in candidates:
        if normalize_name(str(node_records[index].get("name", ""))) == field_norm:
            return index
    return None


def descendant_indices(owner_index: int, node_records: dict[int, dict]) -> list[int]:
    result = []
    pending = [owner_index]
    while pending:
        current = pending.pop(0)
        for index, node in node_records.items():
            if node.get("parent_index") == current:
                result.append(index)
                pending.append(index)
    return result


def normalize_name(value: str) -> str:
    return "".join(ch for ch in value.lower() if ch.isalnum())


def component_field_aliases(field: str) -> list[str]:
    aliases = {
        "girdLayout": ["gridLayout", "girdLayout"],
        "JDT_label": ["yet_label", "JDT_label", "taskProgressLab", "count"],
        "JDT_progress": ["progressBar", "JDT_progress"],
        "title": ["title", "label_name"],
        "txt_xiangou": ["label_xiangou", "txt_xiangou"],
        "img_receive": ["gzzz_img_yishouqin", "img_receive", "isOver"],
        "submitBtn": ["submitBtn", "getBtn", "btn_buy"],
        "btnLabel": ["btnLabel", "Label"],
        "imgComplete": ["imgComplete", "isOver"],
        "descText": ["descText", "title"],
        "taskProgress": ["taskProgress", "progressBar"],
        "taskProgressLab": ["taskProgressLab", "count", "JDT_label"],
        "vir_list": ["vir_list", "logScrollView", "scrollview"],
    }
    return aliases.get(field, [field])


def resolve_sprite_frame(sprite_uuid: str) -> dict:
    if not sprite_uuid:
        return {}
    import_path = find_import_path(sprite_uuid)
    if not import_path:
        return {}
    try:
        data = json.loads(import_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return {}
    if not isinstance(data, list) or len(data) < 6:
        return {}
    texture_uuid = data[1][0] if isinstance(data[1], list) and data[1] else ""
    frame = data[5][0] if isinstance(data[5], list) and data[5] and isinstance(data[5][0], dict) else {}
    texture_path = find_native_path(texture_uuid)
    return {
        "texture_uuid": texture_uuid,
        "texture_path": rel(texture_path) if texture_path else "",
        "sprite_name": frame.get("name", ""),
        "sprite_rect": frame.get("rect", []),
        "sprite_offset": frame.get("offset", []),
        "sprite_original_size": frame.get("originalSize", []),
        "sprite_rotated": bool(frame.get("rotated", False)),
        "sprite_cap_insets": frame.get("capInsets", []),
    }


def resolve_sprite_frame_by_resource_path(paths: list[str]) -> dict:
    for resource_path in paths:
        sprite_uuid = RESOURCE_PATH_TO_UUID.get(resource_path)
        if not sprite_uuid:
            continue
        info = resolve_sprite_frame(sprite_uuid)
        if info.get("texture_path"):
            info["sprite_uuid"] = sprite_uuid
            info["resource_path"] = resource_path
            return info
    return {}


def infer_resource_paths(prefab_path: str, node_name: str) -> list[str]:
    paths: list[str] = []
    if not node_name:
        return paths
    base = Path(prefab_path).name
    if "mainpanel" in prefab_path.lower() or base in {"MainPre", "daohangPre", "heroHead"}:
        paths.append(f"image/com/mainpanel/{node_name}")
        if node_name.startswith("cm_tab_"):
            paths.append(f"image/com/mainpanel/cm_icon_{node_name.removeprefix('cm_tab_').removesuffix('1')}")
        if node_name == "cm_tab_ChuJi1":
            paths.append("image/com/mainpanel/cm_icon_ChuJi")
        if node_name == "cm_tab_ZhaoHuan":
            paths.append("image/com/mainpanel/cm_icon_ZhaoHuan")
            paths.append("image/com/mainpanel/zjm_icon_zhaohuan")
        if node_name == "zjm_btn_rukou5":
            paths.append("image/com/mainpanel/zjm_btn_rukou3")
        if node_name.startswith("zjm_btn_"):
            paths.append(f"image/com/mainpanel/{node_name}")
        if node_name.startswith("zjm_icon_"):
            paths.append(f"image/com/mainpanel/{node_name}")
    if "login" in prefab_path.lower():
        paths.append(f"image/com/login/{node_name}")
    if "maoxianpanel" in prefab_path.lower():
        paths.append(f"image/com/MaoxianPanel/{node_name}")
        if node_name == "hongdian":
            paths.append("image/common/cm_icon_HongDian")
            paths.append("image/com/mainpanel/cm_icon_HongDian")
            paths.append("image/com/MaoxianPanel/hongdian")
        if node_name == "suo":
            paths.append("image/common/cm_icon_SuoDing")
            paths.append("image/com/MaoxianPanel/suo")
        if node_name == "tip":
            paths.append("image/common/cm_icon_HongDian")
            paths.append("image/com/mainpanel/cm_icon_HongDian")
        if node_name == "xsyd_frame9_lihuiming":
            paths.append("image/com/guide/xsyd_frame9_lihuiming")
    paths.append(node_name)
    deduped = []
    for path in paths:
        if path not in deduped:
            deduped.append(path)
    return deduped


def resolve_skeleton_data(skeleton_uuid: str) -> dict:
    if not skeleton_uuid:
        return {}
    import_path = find_import_path(skeleton_uuid)
    if not import_path:
        return {}
    try:
        data = json.loads(import_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return {}
    if not isinstance(data, list) or len(data) < 6:
        return {}
    objects = data[5] if isinstance(data[5], list) else []
    for item in objects:
        if not isinstance(item, list) or len(item) < 2:
            continue
        if isinstance(item[1], str) and len(item) >= 6:
            skeleton_json = item[4] if isinstance(item[4], dict) else {}
            texture_names = item[3] if isinstance(item[3], list) else []
            textures = []
            for texture_uuid in data[1] if isinstance(data[1], list) else []:
                texture_path = find_native_path(texture_uuid)
                if texture_path:
                    textures.append(rel(texture_path))
            animations = []
            if isinstance(skeleton_json, dict) and isinstance(skeleton_json.get("animations"), dict):
                animations = sorted(skeleton_json["animations"].keys())
            return {
                "name": item[1],
                "texture_names": texture_names,
                "textures": textures,
                "animations": animations,
            }
    return {}


def resolve_label(values: dict) -> dict:
    text = values.get("_string", "")
    if text is None:
        text = ""
    return {
        "text": str(text),
        "font_size": int(values.get("_fontSize", 18) or 18),
        "line_height": int(values.get("_lineHeight", values.get("_fontSize", 18)) or 18),
        "horizontal_align": int(values.get("_N$horizontalAlign", 0) or 0),
        "vertical_align": int(values.get("_N$verticalAlign", 0) or 0),
    }


def resolve_widget(values: dict) -> dict:
    return {
        "align_flags": int(values.get("_alignFlags", 0) or 0),
        "left": float(values.get("_left", 0.0) or 0.0),
        "right": float(values.get("_right", 0.0) or 0.0),
        "top": float(values.get("_top", 0.0) or 0.0),
        "bottom": float(values.get("_bottom", 0.0) or 0.0),
        "horizontal_center": float(values.get("_horizontalCenter", 0.0) or 0.0),
        "vertical_center": float(values.get("_verticalCenter", 0.0) or 0.0),
        "original_width": float(values.get("_originalWidth", 0.0) or 0.0),
        "original_height": float(values.get("_originalHeight", 0.0) or 0.0),
    }


def find_import_path(uuid: str) -> Path | None:
    file_name = decompress_cocos_uuid(uuid)
    for bundle in BUNDLES:
        path = ROOT / "assets" / bundle / "import" / file_name[:2] / f"{file_name}.json"
        if path.exists():
            return path
    return None


def find_native_path(uuid: str) -> Path | None:
    if not uuid:
        return None
    file_name = decompress_cocos_uuid(uuid)
    for bundle in BUNDLES:
        native_dir = ROOT / "assets" / bundle / "native" / file_name[:2]
        if not native_dir.exists():
            continue
        for ext in [".png", ".jpg", ".jpeg"]:
            path = native_dir / f"{file_name}{ext}"
            if path.exists():
                return path
        candidates = sorted(path for path in native_dir.glob(f"{file_name}*") if path.suffix.lower() in {".png", ".jpg", ".jpeg"})
        if candidates:
            return candidates[0]
    return None


def rel(path: Path | None) -> str:
    if not path:
        return ""
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def iter_components(item: list) -> list:
    for value in item:
        if not isinstance(value, list):
            continue
        if value and all(isinstance(part, list) for part in value):
            return value
    return []


def decode_component(component: list, classes: list, templates: list) -> tuple[str, dict]:
    if not component or not isinstance(component[0], int):
        return "", {}
    template_index = component[0]
    if template_index < 0 or template_index >= len(templates):
        return "", {}
    template = templates[template_index]
    if not isinstance(template, list) or not template or not isinstance(template[0], int):
        return "", {}
    class_index = template[0]
    if class_index < 0 or class_index >= len(classes):
        return "", {}
    class_info = classes[class_index]
    if not isinstance(class_info, list) or len(class_info) < 2:
        return "", {}
    fields = class_info[1] if isinstance(class_info[1], list) else []
    values = {}
    for value_offset, field_index in enumerate(template[1:], start=1):
        if value_offset >= len(component):
            break
        if isinstance(field_index, int) and 0 <= field_index < len(fields):
            values[fields[field_index]] = component[value_offset]
    return str(class_info[0]), values


def sprite_frame_refs(class_name: str, values: dict) -> list[int]:
    if class_name == "cc.Sprite":
        return [extract_ref(values.get("_spriteFrame"))]
    if class_name == "cc.Button":
        return [
            extract_ref(values.get("_N$normalSprite")),
            extract_ref(values.get("_N$pressedSprite")),
            extract_ref(values.get("_N$hoverSprite")),
            extract_ref(values.get("_N$disabledSprite")),
        ]
    return []


def extract_ref(value: object) -> int:
    if isinstance(value, int):
        return value
    if isinstance(value, list) and len(value) == 1 and isinstance(value[0], int):
        return value[0]
    if isinstance(value, list) and len(value) >= 2 and isinstance(value[0], int) and isinstance(value[1], int):
        return value[0]
    return -1


def uuid_from_ref(ref: int, uuid_table: list) -> str:
    if not isinstance(ref, int):
        return ""
    if ref < 0 or ref >= len(uuid_table):
        return ""
    return str(uuid_table[ref])


def should_auto_texture(name: str) -> bool:
    lowered = name.lower()
    if lowered in {"new label", "label", "text_label", "placeholder_label", "richtext", "color", "tmptxt"}:
        return False
    if lowered.startswith(("txt", "lbl")):
        return False
    return True


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = []
    for label, prefab in PREFABS:
        layout = export_layout(prefab)
        name = prefab.split("/")[-1]
        output = OUT_DIR / f"{name}.json"
        output.write_text(json.dumps(layout, ensure_ascii=False, indent=2), encoding="utf-8")
        texture_count = sum(1 for node in layout["nodes"] if node.get("texture_path"))
        manifest.append({
            "label": label,
            "prefab": prefab,
            "layout": rel(output),
            "nodes": len(layout["nodes"]),
            "texture_nodes": texture_count,
        })
        print(prefab, len(layout["nodes"]), "textures", texture_count)
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
