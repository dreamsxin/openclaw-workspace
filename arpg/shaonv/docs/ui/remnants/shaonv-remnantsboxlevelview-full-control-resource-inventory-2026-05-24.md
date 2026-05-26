# RemnantsBoxLevelView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsBoxLevelView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsBoxLevelView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsboxlevelview.bundle` / `files\yoo\Default\BundleFiles\23\231485bdb7c5d253d8098f9fbe2d51f5\__data`
- 节点数：`67`。
- Image/Text/Button：`35` / `27` / `9`。
- Image 解析：外部 Sprite `9`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `4`，无 sprite `10`，未解析 `12`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Background` | 4 | `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsBoxLevelView.prefab#Sprite/Background` | `assets_game_rawassets_prefabs_ui_remnants_remnantsboxlevelview.bundle` | `231485bdb7c5d253d8098f9fbe2d51f5.bundle`<br>`files\yoo\Default\BundleFiles\23\231485bdb7c5d253d8098f9fbe2d51f5\__data` | internal Sprite in prefab bundle |
| `common_img_69` | 3 | `Assets/Game/RawAssets/Sprite/Common/common_img_69.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_84` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_84.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `hero_img_65` | 2 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_65.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_68` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_68.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `remnants_img_05` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_05.png` | `assets_game_rawassets_sprite_remnants_remnants_img_05.bundle` | `c878b2502a32d11257c38b413e28f7cb.bundle`<br>`files\yoo\Default\BundleFiles\c8\c878b2502a32d11257c38b413e28f7cb\__data` | external CAB-af4de5b794a9a7be928dd0bb95dc8edc |
| `remnants_img_06` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_06.png` | `assets_game_rawassets_sprite_remnants_remnants_img_06.bundle` | `aa00ec5613b074e8e1e89d9f87d0977c.bundle`<br>`files\yoo\Default\BundleFiles\aa\aa00ec5613b074e8e1e89d9f87d0977c\__data` | external CAB-c1b44e78df6c1d6271547441a7571ed4 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |
| 4 | `CAB-af4de5b794a9a7be928dd0bb95dc8edc` | `assets_game_rawassets_sprite_remnants_remnants_img_05.bundle` | `files\yoo\Default\BundleFiles\c8\c878b2502a32d11257c38b413e28f7cb\__data` |
| 5 | `CAB-e42836c6a0e8585c7210e8e4a8691cb4` | `-` | `-` |
| 6 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 7 | `CAB-0d5731a6a534bfedecdb443e393185d2` | `-` | `-` |
| 8 | `CAB-c1b44e78df6c1d6271547441a7571ed4` | `assets_game_rawassets_sprite_remnants_remnants_img_06.bundle` | `files\yoo\Default\BundleFiles\aa\aa00ec5613b074e8e1e89d9f87d0977c\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsBoxLevelView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Animator,RemnantsBoxLevelView` | - |
| 2 | 1 | `RemnantsBoxLevelView/Image` | Y | `pos(-259.0,282.0) size(390.0,50.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:external fid=1 pid=5716415776903518313 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 3 | 2 | `RemnantsBoxLevelView/Image/Text` | Y | `pos(0.0,0.0) size(160.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"基座升级" |
| 4 | 1 | `RemnantsBoxLevelView/pnlLv` | Y | `pos(-258.0,228.0) size(330.0,45.0)` | `1.0,0.5->1.0,0.5 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:none [Simple], a=0.00 |
| 5 | 2 | `RemnantsBoxLevelView/pnlLv/txtOldLv` | Y | `pos(-118.0,0.0) size(94.0,43.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=30):"LV.100" |
| 6 | 2 | `RemnantsBoxLevelView/pnlLv/@imgLvArrow` | Y | `pos(-7.0,1.0) size(118.0,52.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=5 pid=-7402652912950301548 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 7 | 2 | `RemnantsBoxLevelView/pnlLv/txtNewLv` | Y | `pos(-47.0,0.0) size(94.0,43.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=30):"LV.100" |
| 8 | 1 | `RemnantsBoxLevelView/@imgLine` | Y | `pos(-259.0,159.0) size(390.0,10.0)` | `1.0,0.5->1.0,0.5 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:hero_img_65 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 9 | 1 | `RemnantsBoxLevelView/@CommonAttrUpGrid1` | Y | `pos(-259.0,131.0) size(390.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid,CanvasGroup` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 10 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid1/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"遗器能量值" |
| 11 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid1/txtOldValue` | Y | `pos(-14.0,0.0) size(-338.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |
| 12 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid1/Image` | Y | `pos(74.0,0.0) size(-360.0,-3.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=5 pid=3885715908292743732 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 13 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid1/txtNewValue` | Y | `pos(-39.0,0.0) size(52.0,32.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"9999" |
| 14 | 1 | `RemnantsBoxLevelView/@CommonAttrUpGrid2` | Y | `pos(-259.0,91.0) size(390.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid,CanvasGroup` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 15 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid2/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"阵容攻击" |
| 16 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid2/txtOldValue` | Y | `pos(-14.0,0.0) size(-338.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |
| 17 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid2/Image` | Y | `pos(74.0,0.0) size(-360.0,-3.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=5 pid=3885715908292743732 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 18 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid2/txtNewValue` | Y | `pos(-39.0,0.0) size(52.0,32.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"9999" |
| 19 | 1 | `RemnantsBoxLevelView/@CommonAttrUpGrid3` | Y | `pos(-259.0,51.0) size(390.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid,CanvasGroup` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 20 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid3/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"阵容生命" |
| 21 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid3/txtOldValue` | Y | `pos(-14.0,0.0) size(-338.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |
| 22 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid3/Image` | Y | `pos(74.0,0.0) size(-360.0,-3.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=5 pid=3885715908292743732 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 23 | 2 | `RemnantsBoxLevelView/@CommonAttrUpGrid3/txtNewValue` | Y | `pos(-39.0,0.0) size(52.0,32.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"9999" |
| 24 | 1 | `RemnantsBoxLevelView/pnlBottom` | Y | `pos(-258.0,-173.5) size(388.0,403.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:Background [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantsboxlevelview.bundle, a=0.00 |
| 25 | 2 | `RemnantsBoxLevelView/pnlBottom/pnlUp` | Y | `pos(0.0,-84.7) size(388.0,234.6)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Background [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantsboxlevelview.bundle, a=0.00 |
| 26 | 3 | `RemnantsBoxLevelView/pnlBottom/pnlUp/@imgLine` | Y | `pos(-1.0,144.2) size(390.0,11.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_65 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 27 | 3 | `RemnantsBoxLevelView/pnlBottom/pnlUp/@txtCostTitle` | Y | `pos(-1.0,269.0) size(80.0,29.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"消耗材料" |
| 28 | 3 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp` | Y | `pos(0.0,18.9) size(388.0,272.4)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Background [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantsboxlevelview.bundle, a=0.00 |
| 29 | 4 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/@LvUpCostGrid` | Y | `pos(49.0,10.3) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.0)` | `RectTransform,CommonCostGrid` | - |
| 30 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/@LvUpCostGrid/imgCostBg` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 31 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/@LvUpCostGrid/imgCost` | Y | `pos(0.0,0.0) size(-21.4,-21.4)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 32 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/@LvUpCostGrid/btnAdd` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 33 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/@LvUpCostGrid/txtCost` | Y | `pos(0.0,-10.5) size(137.9,28.9)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"<Color=#FF5F59>245</Color>/1..." |
| 34 | 4 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnLvUp` | Y | `pos(-150.0,68.3) size(316.0,85.6)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=6771108641299508787 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 35 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnLvUp/Text` | Y | `pos(0.0,6.5) size(316.0,25.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"升级" |
| 36 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnLvUp/Text` | N | `pos(0.0,-68.0) size(160.0,25.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"长按可快速升级" |
| 37 | 4 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnQuickLvUp` | Y | `pos(-164.0,-62.7) size(86.0,86.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=6125781591778408501 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 38 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnQuickLvUp/pnlQuickLvUp` | Y | `pos(0.0,56.0) size(164.0,110.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_84 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 39 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnQuickLvUp/pnlQuickLvUp/btnLvUpFive` | Y | `pos(0.0,-25.0) size(144.0,40.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=6125944892010050420 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 40 | 7 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnQuickLvUp/pnlQuickLvUp/btnLvUpFive/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"升5级" |
| 41 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnQuickLvUp/pnlQuickLvUp/btnLvUpMax` | Y | `pos(0.0,25.0) size(144.0,-70.0)` | `0.5,0.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=6125944892010050420 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 42 | 7 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvUp/btnQuickLvUp/pnlQuickLvUp/btnLvUpMax/txtLvUpMax` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"升至10级" |
| 43 | 3 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak` | N | `pos(0.0,18.9) size(388.0,272.4)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Background [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantsboxlevelview.bundle, a=0.00 |
| 44 | 4 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent` | Y | `pos(-1.0,64.3) size(230.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter` | - |
| 45 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid0` | Y | `pos(100.0,-100.0) size(100.0,100.0)` | `0.0,1.0->0.0,1.0 p(1.0,0.0)` | `RectTransform,CommonCostGrid` | - |
| 46 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid0/imgCostBg` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 47 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid0/imgCost` | Y | `pos(0.0,0.0) size(-21.4,-21.4)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 48 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid0/btnAdd` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 49 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid0/txtCost` | Y | `pos(0.0,-10.5) size(137.9,28.9)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"<Color=#FF5F59>245</Color>/1..." |
| 50 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid1` | Y | `pos(230.0,-100.0) size(100.0,100.0)` | `0.0,1.0->0.0,1.0 p(1.0,0.0)` | `RectTransform,CommonCostGrid` | - |
| 51 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid1/imgCostBg` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 52 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid1/imgCost` | Y | `pos(0.0,0.0) size(-21.4,-21.4)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 53 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid1/btnAdd` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 54 | 6 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/pnlContent/@LvBreakCostGrid1/txtCost` | Y | `pos(0.0,-10.5) size(137.9,28.9)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"<Color=#FF5F59>245</Color>/1..." |
| 55 | 4 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/btnBreak` | Y | `pos(0.0,-60.7) size(316.0,85.6)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=6771108641299508787 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 56 | 5 | `RemnantsBoxLevelView/pnlBottom/pnlUp/pnlLvBreak/btnBreak/Text` | Y | `pos(0.0,6.5) size(316.0,25.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"突破" |
| 57 | 2 | `RemnantsBoxLevelView/pnlBottom/pnlMax` | Y | `pos(0.0,0.0) size(390.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_68 [Sliced] -> assets_game_rawassets_sprite_hero.bundle |
| 58 | 3 | `RemnantsBoxLevelView/pnlBottom/pnlMax/Text` | Y | `pos(0.0,0.0) size(160.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"已达到最大等级" |
| 59 | 1 | `RemnantsBoxLevelView/imgTip` | Y | `pos(-143.0,0.0) size(1042.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:remnants_img_05 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_05.bundle |
| 60 | 2 | `RemnantsBoxLevelView/imgTip/txtTitle` | Y | `pos(0.0,-97.5) size(112.0,41.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=28):"基座共鸣" |
| 61 | 2 | `RemnantsBoxLevelView/imgTip/Image` | Y | `pos(0.0,-214.0) size(580.0,174.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_img_06 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_06.bundle |
| 62 | 3 | `RemnantsBoxLevelView/imgTip/Image/txtLv` | Y | `pos(0.0,73.0) size(187.0,38.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Lv.99" |
| 63 | 3 | `RemnantsBoxLevelView/imgTip/Image/Text` | Y | `pos(0.0,30.5) size(580.0,35.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"基座等级=遗器等级" |
| 64 | 3 | `RemnantsBoxLevelView/imgTip/Image/Text` | Y | `pos(0.0,-35.0) size(580.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"基座升级后，所有遗器将自动同步提升至相同等级" |
| 65 | 2 | `RemnantsBoxLevelView/imgTip/imgIcon` | Y | `pos(0.0,132.0) size(403.0,325.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=21721582758192110 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 66 | 1 | `RemnantsBoxLevelView/btnBuff` | Y | `pos(97.0,103.0) size(80.0,80.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,CanvasGroup` | Image:external fid=1 pid=-3416197695145359509 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 67 | 2 | `RemnantsBoxLevelView/btnBuff/Text` | Y | `pos(0.0,-51.5) size(80.0,25.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=18):"属性总览" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
