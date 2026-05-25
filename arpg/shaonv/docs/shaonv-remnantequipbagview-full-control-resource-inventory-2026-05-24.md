# RemnantEquipBagView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantEquipBagView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantEquipBagView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantequipbagview.bundle` / `files\yoo\Default\BundleFiles\f9\f93592d994ed88f42daeceb79980c06f\__data`
- 节点数：`47`。
- Image/Text/Button：`26` / `17` / `9`。
- Image 解析：外部 Sprite `10`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `11`，未解析 `5`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Remnants_bg_02` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/Remnants_bg_02.png` | `assets_game_rawassets_sprite_background_remnants_bg_02.bundle` | `4b188373c3ab3d6ca5c6f9ccda420646.bundle`<br>`files\yoo\Default\BundleFiles\4b\4b188373c3ab3d6ca5c6f9ccda420646\__data` | external CAB-7789a59fc2aa80086d4185032e7cbbff |
| `common_img_59` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_59.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_69` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_69.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_84` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_84.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `hero_img_05` | 3 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_05.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_65` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_65.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_82` | 1 | `Assets/Game/RawAssets/Sprite/Hero/Cultivate/hero_img_82.png` | `assets_game_rawassets_sprite_hero_cultivate.bundle` | `1b1c1c8ae975905d020572b444a62209.bundle`<br>`files\yoo\Default\UnpackBundleFiles\1b\1b1c1c8ae975905d020572b444a62209\__data` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `remnants_img_50` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_50.png` | `assets_game_rawassets_sprite_remnants_remnants_img_50.bundle` | `ff088a08b04821370155c7eb5d5a2250.bundle`<br>`files\yoo\Default\BundleFiles\ff\ff088a08b04821370155c7eb5d5a2250\__data` | external CAB-557311de6f2baf48678783b93d792818 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |
| 2 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 5 | `CAB-7789a59fc2aa80086d4185032e7cbbff` | `assets_game_rawassets_sprite_background_remnants_bg_02.bundle` | `files\yoo\Default\BundleFiles\4b\4b188373c3ab3d6ca5c6f9ccda420646\__data` |
| 6 | `CAB-557311de6f2baf48678783b93d792818` | `assets_game_rawassets_sprite_remnants_remnants_img_50.bundle` | `files\yoo\Default\BundleFiles\ff\ff088a08b04821370155c7eb5d5a2250\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantEquipBagView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RemnantEquipBagView` | Image:none [Sliced], a=0.00 |
| 2 | 1 | `RemnantEquipBagView/Image` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Remnants_bg_02 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_02.bundle |
| 3 | 1 | `RemnantEquipBagView/btnGetway` | N | `pos(618.0,65.0) size(161.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=2 pid=-5349136626577647624 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 4 | 2 | `RemnantEquipBagView/btnGetway/Text` | Y | `pos(19.0,0.0) size(-80.0,-22.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"获取途径" |
| 5 | 1 | `RemnantEquipBagView/tabList` | Y | `pos(478.0,8.0) size(830.0,542.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,CanvasRenderer,Image,RectMask2D,TabScrollView` | Image:none [Sliced], a=0.00 |
| 6 | 1 | `RemnantEquipBagView/pnlNoEquip` | N | `pos(0.0,0.0) size(830.0,542.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Sliced], a=0.00 |
| 7 | 2 | `RemnantEquipBagView/pnlNoEquip/Image` | Y | `pos(0.0,0.0) size(250.0,250.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_59 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 8 | 2 | `RemnantEquipBagView/pnlNoEquip/Text` | Y | `pos(0.0,0.0) size(287.4,56.1)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"暂无装备" |
| 9 | 1 | `RemnantEquipBagView/Image` | Y | `pos(291.0,65.0) size(454.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_img_50 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_50.bundle |
| 10 | 2 | `RemnantEquipBagView/Image/@pnlLines` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 11 | 3 | `RemnantEquipBagView/Image/@pnlLines/Image` | Y | `pos(-108.0,0.0) size(2.0,18.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_05 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 12 | 3 | `RemnantEquipBagView/Image/@pnlLines/Image` | Y | `pos(0.0,0.0) size(2.0,18.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_05 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 13 | 3 | `RemnantEquipBagView/Image/@pnlLines/Image` | Y | `pos(108.0,0.0) size(2.0,18.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_05 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 14 | 2 | `RemnantEquipBagView/Image/pnlBtnParts` | Y | `pos(0.0,0.0) size(426.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup` | - |
| 15 | 3 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart0` | Y | `pos(-159.8,0.0) size(106.5,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 16 | 4 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart0/Text (Legacy)` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"Default" |
| 17 | 3 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart1` | Y | `pos(-53.2,0.0) size(106.5,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 18 | 4 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart1/Text (Legacy)` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"Default" |
| 19 | 3 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart2` | Y | `pos(53.2,0.0) size(106.5,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 20 | 4 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart2/Text (Legacy)` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"Default" |
| 21 | 3 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart3` | Y | `pos(159.8,0.0) size(106.5,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 22 | 4 | `RemnantEquipBagView/Image/pnlBtnParts/@btnPart3/Text (Legacy)` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"Default" |
| 23 | 3 | `RemnantEquipBagView/Image/pnlBtnParts/pnlBtnPos` | Y | `pos(-159.8,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 24 | 4 | `RemnantEquipBagView/Image/pnlBtnParts/pnlBtnPos/Image` | Y | `pos(0.0,87.0) size(164.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_84 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 25 | 5 | `RemnantEquipBagView/Image/pnlBtnParts/pnlBtnPos/Image/@btnPos0` | Y | `pos(0.0,-25.0) size(144.0,40.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=2 pid=6125944892010050420 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 26 | 6 | `RemnantEquipBagView/Image/pnlBtnParts/pnlBtnPos/Image/@btnPos0/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 27 | 5 | `RemnantEquipBagView/Image/pnlBtnParts/pnlBtnPos/Image/@btnPos1` | Y | `pos(0.0,25.0) size(144.0,-70.0)` | `0.5,0.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=2 pid=6125944892010050420 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 28 | 6 | `RemnantEquipBagView/Image/pnlBtnParts/pnlBtnPos/Image/@btnPos1/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 29 | 1 | `RemnantEquipBagView/pnlInfo` | Y | `pos(-835.0,0.0) size(1670.0,750.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Sliced], a=0.00 |
| 30 | 2 | `RemnantEquipBagView/pnlInfo/pnlName` | Y | `pos(-259.0,309.0) size(390.0,54.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 31 | 3 | `RemnantEquipBagView/pnlInfo/pnlName/txtCurName` | Y | `pos(89.5,11.0) size(179.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"道具名称" |
| 32 | 3 | `RemnantEquipBagView/pnlInfo/pnlName/txtCurLv` | Y | `pos(-122.5,-14.0) size(145.0,26.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"LV.10" |
| 33 | 3 | `RemnantEquipBagView/pnlInfo/pnlName/Image` | Y | `pos(-1.0,9.0) size(30.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_82 [Simple] -> assets_game_rawassets_sprite_hero_cultivate.bundle |
| 34 | 3 | `RemnantEquipBagView/pnlInfo/pnlName/txtTargetName` | Y | `pos(118.0,11.0) size(154.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"道具名称" |
| 35 | 3 | `RemnantEquipBagView/pnlInfo/pnlName/txtTargetLv` | Y | `pos(96.7,-14.0) size(111.4,26.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"LV.10" |
| 36 | 2 | `RemnantEquipBagView/pnlInfo/Image` | Y | `pos(576.0,275.0) size(390.0,10.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_65 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 37 | 2 | `RemnantEquipBagView/pnlInfo/@CommonAttrGrid` | Y | `pos(576.0,244.0) size(390.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid,CommonAttrGrid` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 38 | 3 | `RemnantEquipBagView/pnlInfo/@CommonAttrGrid/imgIcon` | N | `pos(18.0,0.0) size(20.0,20.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 39 | 3 | `RemnantEquipBagView/pnlInfo/@CommonAttrGrid/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"遗器能量值" |
| 40 | 3 | `RemnantEquipBagView/pnlInfo/@CommonAttrGrid/txtAddValue` | Y | `pos(-9.0,0.0) size(0.0,32.0)` | `1.0,0.5->1.0,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Text,ContentSizeFitter` | Text(fs=22):"" |
| 41 | 4 | `RemnantEquipBagView/pnlInfo/@CommonAttrGrid/txtAddValue/txtValue` | Y | `pos(0.0,0.0) size(52.0,33.0)` | `0.0,0.5->0.0,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"123456789" |
| 42 | 2 | `RemnantEquipBagView/pnlInfo/svAttr` | Y | `pos(576.0,68.6) size(390.0,300.9)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,CanvasRenderer,Image,GridScroller,RectMask2D` | Image:none [Simple], a=0.00 |
| 43 | 2 | `RemnantEquipBagView/pnlInfo/pnlBtn` | Y | `pos(576.0,-300.0) size(390.0,64.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Sliced], a=0.00 |
| 44 | 3 | `RemnantEquipBagView/pnlInfo/pnlBtn/btnEquip` | Y | `pos(0.0,-7.0) size(316.0,86.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=2 pid=6771108641299508787 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 45 | 4 | `RemnantEquipBagView/pnlInfo/pnlBtn/btnEquip/Text` | Y | `pos(0.0,6.5) size(96.0,25.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"装备" |
| 46 | 3 | `RemnantEquipBagView/pnlInfo/pnlBtn/btnDown` | N | `pos(0.0,-7.0) size(316.0,86.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=2 pid=-6996327897631528263 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 47 | 4 | `RemnantEquipBagView/pnlInfo/pnlBtn/btnDown/Text` | Y | `pos(0.0,6.5) size(96.0,25.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"卸除" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
