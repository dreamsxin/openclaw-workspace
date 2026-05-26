# RemnantsStarUpView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsStarUpView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsStarUpView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsstarupview.bundle` / `files\yoo\Default\BundleFiles\e7\e769e554952c0970c8a7b1ddbf0a2adb\__data`
- 节点数：`54`。
- Image/Text/Button：`32` / `14` / `3`。
- Image 解析：外部 Sprite `20`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `4`，未解析 `7`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsStarUpView.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_remnants_remnantsstarupview.bundle` | `e769e554952c0970c8a7b1ddbf0a2adb.bundle`<br>`files\yoo\Default\BundleFiles\e7\e769e554952c0970c8a7b1ddbf0a2adb\__data` | internal Sprite in prefab bundle |
| `common_img_69` | 4 | `Assets/Game/RawAssets/Sprite/Common/common_img_69.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_73` | 4 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_74` | 6 | `Assets/Game/RawAssets/Sprite/Common/common_img_74.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_84` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_84.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `hero_img_65` | 2 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_65.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_76` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_76.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_85` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_85.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_84` | 1 | `Assets/Game/RawAssets/Sprite/Hero/Cultivate/hero_img_84.png` | `assets_game_rawassets_sprite_hero_cultivate.bundle` | `1b1c1c8ae975905d020572b444a62209.bundle`<br>`files\yoo\Default\UnpackBundleFiles\1b\1b1c1c8ae975905d020572b444a62209\__data` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-e42836c6a0e8585c7210e8e4a8691cb4` | `-` | `-` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 4 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 5 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsStarUpView` | Y | `pos(-259.0,0.0) size(454.0,750.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RemnantsStarUpView` | Image:none [Simple], a=0.00 |
| 2 | 1 | `RemnantsStarUpView/pnlStar` | Y | `pos(0.0,-139.0) size(406.0,44.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform` | - |
| 3 | 2 | `RemnantsStarUpView/pnlStar/@StarBarOld` | Y | `pos(-121.0,0.0) size(164.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter,StarBar` | - |
| 4 | 3 | `RemnantsStarUpView/pnlStar/@StarBarOld/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 5 | 3 | `RemnantsStarUpView/pnlStar/@StarBarOld/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 6 | 3 | `RemnantsStarUpView/pnlStar/@StarBarOld/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 7 | 3 | `RemnantsStarUpView/pnlStar/@StarBarOld/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 8 | 3 | `RemnantsStarUpView/pnlStar/@StarBarOld/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 9 | 2 | `RemnantsStarUpView/pnlStar/@imgStarArrow` | Y | `pos(-14.4,0.0) size(-346.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=3458736361515503420 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 10 | 2 | `RemnantsStarUpView/pnlStar/@StarBarNew` | Y | `pos(121.0,0.0) size(164.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter,StarBar` | - |
| 11 | 3 | `RemnantsStarUpView/pnlStar/@StarBarNew/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 12 | 3 | `RemnantsStarUpView/pnlStar/@StarBarNew/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 13 | 3 | `RemnantsStarUpView/pnlStar/@StarBarNew/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 14 | 3 | `RemnantsStarUpView/pnlStar/@StarBarNew/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 15 | 3 | `RemnantsStarUpView/pnlStar/@StarBarNew/@imgStar` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 16 | 1 | `RemnantsStarUpView/@imgLine` | Y | `pos(0.0,-197.0) size(390.0,10.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_65 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 17 | 1 | `RemnantsStarUpView/pnlAttrUp` | Y | `pos(0.0,-216.0) size(390.0,125.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform` | - |
| 18 | 2 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid` | Y | `pos(0.0,-15.0) size(390.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 19 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"遗器能量值" |
| 20 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtOldValue` | Y | `pos(-14.0,0.0) size(-338.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |
| 21 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/Image` | Y | `pos(74.0,0.0) size(-360.0,-3.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=3885715908292743732 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 22 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtNewValue` | Y | `pos(-39.0,0.0) size(52.0,32.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"9999" |
| 23 | 2 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid` | Y | `pos(0.0,-55.0) size(390.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 24 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"阵容攻击" |
| 25 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtOldValue` | Y | `pos(-14.0,0.0) size(-338.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |
| 26 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/Image` | Y | `pos(74.0,0.0) size(-360.0,-3.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=3885715908292743732 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 27 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtNewValue` | Y | `pos(-39.0,0.0) size(52.0,32.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"9999" |
| 28 | 2 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid` | Y | `pos(0.0,-95.0) size(390.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CommonAttrUpGrid` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 29 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtName` | Y | `pos(10.0,0.0) size(72.0,32.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"阵容生命" |
| 30 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtOldValue` | Y | `pos(-14.0,0.0) size(-338.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |
| 31 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/Image` | Y | `pos(74.0,0.0) size(-360.0,-3.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=3885715908292743732 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 32 | 3 | `RemnantsStarUpView/pnlAttrUp/@CommonAttrUpGrid/txtNewValue` | Y | `pos(-39.0,0.0) size(52.0,32.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"9999" |
| 33 | 1 | `RemnantsStarUpView/pnlSkillUp` | Y | `pos(0.0,307.0) size(390.0,70.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_84 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 34 | 2 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg` | Y | `pos(0.0,19.0) size(108.0,106.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=4 pid=8376328699360261513 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 35 | 3 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg/imgSkill` | Y | `pos(0.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_76 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 36 | 4 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg/imgSkill/imgSkillUp` | Y | `pos(14.0,-14.0) size(28.0,28.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,UIImageMover` | Image:hero_img_84 [Simple] -> assets_game_rawassets_sprite_hero_cultivate.bundle |
| 37 | 5 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg/imgSkill/imgSkillUp/fx_imgSkillUp` | Y | `pos(14.0,-28.7) size(28.0,58.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=759479295342198049 cab=CAB-e42836c6a0e8585c7210e8e4a8691cb4 [Simple] |
| 38 | 3 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg/Image` | Y | `pos(0.0,-40.0) size(58.0,14.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_85 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 39 | 4 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg/Image/txtSkillLv` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"9999" |
| 40 | 3 | `RemnantsStarUpView/pnlSkillUp/imgSkillBg/btnSkill` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantsstarupview.bundle, a=0.00<br>Button |
| 41 | 1 | `RemnantsStarUpView/pnlBottom` | Y | `pos(0.0,0.0) size(406.1,750.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer` | - |
| 42 | 2 | `RemnantsStarUpView/pnlBottom/pnlUpdate` | Y | `pos(0.0,375.1) size(406.1,750.2)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer` | - |
| 43 | 3 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@txtCostTitle` | Y | `pos(-0.0,268.1) size(80.0,29.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"消耗材料" |
| 44 | 3 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@imgLine` | Y | `pos(-0.0,256.1) size(390.0,10.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_65 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 45 | 3 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@CommonCostGrid` | Y | `pos(-0.0,146.0) size(100.0,100.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CommonCostGrid` | - |
| 46 | 4 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@CommonCostGrid/imgCostBg` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 47 | 4 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@CommonCostGrid/imgCost` | Y | `pos(0.0,0.0) size(-21.4,-21.4)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 48 | 4 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@CommonCostGrid/btnAdd` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 49 | 4 | `RemnantsStarUpView/pnlBottom/pnlUpdate/@CommonCostGrid/txtCost` | Y | `pos(0.0,-10.5) size(137.9,28.9)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"<Color=#FF5F59>245</Color>/1..." |
| 50 | 3 | `RemnantsStarUpView/pnlBottom/pnlUpdate/btnBreak` | Y | `pos(-0.0,25.0) size(316.0,86.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=4 pid=6771108641299508787 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 51 | 4 | `RemnantsStarUpView/pnlBottom/pnlUpdate/btnBreak/Text` | Y | `pos(0.0,6.5) size(0.0,-61.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"星级突破" |
| 52 | 4 | `RemnantsStarUpView/pnlBottom/pnlUpdate/btnBreak/@pnlRd` | Y | `pos(132.8,38.8) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 53 | 2 | `RemnantsStarUpView/pnlBottom/pnlMax` | N | `pos(-0.0,161.0) size(390.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_69 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 54 | 3 | `RemnantsStarUpView/pnlBottom/pnlMax/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"已达到最高等级" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
