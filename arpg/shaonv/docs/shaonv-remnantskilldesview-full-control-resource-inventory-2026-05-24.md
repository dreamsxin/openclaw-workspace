# RemnantSkillDesView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantSkillDesView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantSkillDesView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantskilldesview.bundle` / `files\yoo\Default\BundleFiles\a6\a6df4b63c7c457bb1b29896c43f4d2f2\__data`
- 节点数：`25`。
- Image/Text/Button：`13` / `10` / `0`。
- Image 解析：外部 Sprite `5`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `6`，未解析 `1`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Background` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantSkillDesView.prefab#Sprite/Background` | `assets_game_rawassets_prefabs_ui_remnants_remnantskilldesview.bundle` | `a6df4b63c7c457bb1b29896c43f4d2f2.bundle`<br>`files\yoo\Default\BundleFiles\a6\a6df4b63c7c457bb1b29896c43f4d2f2\__data` | internal Sprite in prefab bundle |
| `hero_bg_07` | 3 | `Assets/Game/RawAssets/Sprite/BackGround/hero_bg_07.png` | `assets_game_rawassets_sprite_background.bundle` | `6b5c8d7d52da8cdafb815e8ecdb1bc5d.bundle`<br>`files\yoo\Default\BundleFiles\6b\6b5c8d7d52da8cdafb815e8ecdb1bc5d\__data` | external CAB-139c59964eae683fe7049a952b30a996 |
| `hero_bg_05` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/hero_bg_05.png` | `assets_game_rawassets_sprite_background_hero_bg_05.bundle` | `bbbf3b6cad76046bf95071e08712ea9c.bundle`<br>`files\yoo\Default\BundleFiles\bb\bbbf3b6cad76046bf95071e08712ea9c\__data` | external CAB-3a58eddfdd6efab27f995eee646f4844 |
| `hero_img_76` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_76.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |
| 2 | `CAB-139c59964eae683fe7049a952b30a996` | `assets_game_rawassets_sprite_background.bundle` | `files\yoo\Default\BundleFiles\6b\6b5c8d7d52da8cdafb815e8ecdb1bc5d\__data` |
| 3 | `CAB-3a58eddfdd6efab27f995eee646f4844` | `assets_game_rawassets_sprite_background_hero_bg_05.bundle` | `files\yoo\Default\BundleFiles\bb\bbbf3b6cad76046bf95071e08712ea9c\__data` |
| 4 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 5 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantSkillDesView` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RemnantSkillDesView` | Image:none [Simple], a=0.00 |
| 2 | 1 | `RemnantSkillDesView/Image` | Y | `pos(164.0,309.0) size(400.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,VerticalLayoutGroup,ContentSizeFitter` | Image:hero_bg_05 [Sliced] -> assets_game_rawassets_sprite_background_hero_bg_05.bundle |
| 3 | 2 | `RemnantSkillDesView/Image/imgSkillBg` | Y | `pos(57.0,-59.0) size(108.0,108.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,LayoutElement` | Image:external fid=5 pid=8376328699360261513 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 4 | 3 | `RemnantSkillDesView/Image/imgSkillBg/imgSkill` | Y | `pos(0.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_76 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 5 | 2 | `RemnantSkillDesView/Image/txtSkillName` | Y | `pos(236.0,-41.5) size(236.0,25.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LayoutElement` | Text(fs=28):"阿威十八式" |
| 6 | 2 | `RemnantSkillDesView/Image/txtSkillLv` | Y | `pos(236.0,-75.5) size(236.0,25.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LayoutElement` | Text(fs=22):"等级3" |
| 7 | 2 | `RemnantSkillDesView/Image/@imgUpLine` | Y | `pos(0.0,-119.0) size(370.0,2.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,LayoutElement` | Image:none [Simple], a=0.10 |
| 8 | 2 | `RemnantSkillDesView/Image/txtDes` | Y | `pos(200.0,0.0) size(354.0,0.0)` | `0.0,0.0->0.0,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text,ContentSizeFitter` | Text(fs=20):"宠物星级提升后，技能等级提升 预留" |
| 9 | 3 | `RemnantSkillDesView/Image/txtDes/@imgBottomLine` | Y | `pos(0.0,-12.0) size(370.0,2.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 10 | 2 | `RemnantSkillDesView/Image/pnlText` | Y | `pos(0.0,0.0) size(0.0,324.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,ScrollRect,RectMask2D` | Image:Background [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantskilldesview.bundle, a=0.00 |
| 11 | 3 | `RemnantSkillDesView/Image/pnlText/txtSkillDes` | N | `pos(0.0,0.0) size(0.0,18.0)` | `0.0,1.0->1.0,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text,ContentSizeFitter` | Text(fs=18):"" |
| 12 | 3 | `RemnantSkillDesView/Image/pnlText/pnlDesContent` | Y | `pos(0.0,-0.0) size(0.0,0.0)` | `0.0,1.0->1.0,1.0 p(0.5,1.0)` | `RectTransform,VerticalLayoutGroup,ContentSizeFitter` | - |
| 13 | 1 | `RemnantSkillDesView/pnlLeft` | Y | `pos(-214.0,-65.0) size(300.0,160.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,VerticalLayoutGroup` | - |
| 14 | 2 | `RemnantSkillDesView/pnlLeft/imgEntry1` | N | `pos(150.0,-80.0) size(300.0,160.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_bg_07 [Sliced] -> assets_game_rawassets_sprite_background.bundle |
| 15 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry1/txtEntryName1` | Y | `pos(82.0,-28.5) size(126.0,25.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"燃烧" |
| 16 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry1/Image` | Y | `pos(0.0,28.0) size(280.0,2.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 17 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry1/txtEntry1` | Y | `pos(2.0,-15.5) size(266.0,75.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"降低3%护甲，行动结束时造成30%施加者攻击的伤害，持续..." |
| 18 | 2 | `RemnantSkillDesView/pnlLeft/imgEntry2` | N | `pos(150.0,-250.0) size(300.0,160.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_bg_07 [Sliced] -> assets_game_rawassets_sprite_background.bundle |
| 19 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry2/txtEntryName2` | Y | `pos(82.0,-28.5) size(126.0,25.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"毒雾" |
| 20 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry2/Image` | Y | `pos(0.0,28.0) size(280.0,2.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 21 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry2/txtEntry2` | Y | `pos(2.0,-15.5) size(266.0,75.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"降低2%命中，行动结束时造成30%施加者攻击的伤害，持续..." |
| 22 | 2 | `RemnantSkillDesView/pnlLeft/imgEntry3` | N | `pos(150.0,-420.0) size(300.0,160.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_bg_07 [Sliced] -> assets_game_rawassets_sprite_background.bundle |
| 23 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry3/txtEntryName3` | Y | `pos(82.0,-28.5) size(126.0,25.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"流血" |
| 24 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry3/Image` | Y | `pos(0.0,28.0) size(280.0,2.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 25 | 3 | `RemnantSkillDesView/pnlLeft/imgEntry3/txtEntry3` | Y | `pos(2.0,-15.5) size(266.0,75.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"降低5%受到治疗效果，行动结束时造成15%施加者攻击的伤..." |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
