# HeroDetailInfoView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `HeroDetailInfoView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroDetailInfoView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_hero_herodetailinfoview.bundle` / `files\yoo\Default\BundleFiles\5d\5db1c90a6748f03bb9be791dffba7dee\__data`
- 节点数：`73`。
- Image/Text/Button：`25` / `36` / `4`。
- Image 解析：外部 Sprite `18`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `4`，无 sprite `3`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 4 | `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroDetailInfoView.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_hero_herodetailinfoview.bundle` | `5db1c90a6748f03bb9be791dffba7dee.bundle`<br>`files\yoo\Default\BundleFiles\5d\5db1c90a6748f03bb9be791dffba7dee\__data` | internal Sprite in prefab bundle |
| `guessing_bg_03` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/guessing_bg_03.png` | `assets_game_rawassets_sprite_background_guessing_bg_03.bundle` | `c3b20a4965666c4773523549f3ccf908.bundle`<br>`files\yoo\Default\BundleFiles\c3\c3b20a4965666c4773523549f3ccf908\__data` | external CAB-bccc3c825a01ccee528f57d3e840d8dc |
| `common_img_07` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_07.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_163` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_163.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_199` | 5 | `Assets/Game/RawAssets/Sprite/Common/common_img_199.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_208` | 4 | `Assets/Game/RawAssets/Sprite/Common/common_img_208.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_73` | 5 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `thero_052` | 1 | `Assets/Game/RawAssets/Sprite/Head/Square/thero_052.png` | `assets_game_rawassets_sprite_head_square.bundle` | `c891ba87e85bf4a5fb50f9a6b4a17ec4.bundle`<br>`resources\assets\yoo\Default\c891ba87e85bf4a5fb50f9a6b4a17ec4.bundle` | external CAB-affdf3ff19638c78732cb086997a78d2 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 3 | `CAB-bccc3c825a01ccee528f57d3e840d8dc` | `assets_game_rawassets_sprite_background_guessing_bg_03.bundle` | `files\yoo\Default\BundleFiles\c3\c3b20a4965666c4773523549f3ccf908\__data` |
| 4 | `CAB-affdf3ff19638c78732cb086997a78d2` | `assets_game_rawassets_sprite_head_square.bundle` | `resources\assets\yoo\Default\c891ba87e85bf4a5fb50f9a6b4a17ec4.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `HeroDetailInfoView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,HeroDetailInfoView` | - |
| 2 | 1 | `HeroDetailInfoView/imgBg` | Y | `pos(0.0,0.0) size(1080.0,610.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,FullMoonCelebrationGuessFormationDetailView` | Image:guessing_bg_03 [Simple] -> assets_game_rawassets_sprite_background_guessing_bg_03.bundle |
| 3 | 2 | `HeroDetailInfoView/imgBg/imgHeadFrame` | Y | `pos(12.0,-10.0) size(140.0,140.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_07 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 4 | 3 | `HeroDetailInfoView/imgBg/imgHeadFrame/imgHead` | Y | `pos(0.0,0.0) size(126.0,126.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:thero_052 [Simple] -> assets_game_rawassets_sprite_head_square.bundle |
| 5 | 2 | `HeroDetailInfoView/imgBg/pnlName` | Y | `pos(166.0,-9.0) size(110.0,80.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform` | - |
| 6 | 3 | `HeroDetailInfoView/imgBg/pnlName/txtGod` | Y | `pos(0.0,24.0) size(110.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"维露卡妮丝" |
| 7 | 3 | `HeroDetailInfoView/imgBg/pnlName/txtName` | Y | `pos(0.0,-8.0) size(110.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=40):"朱雀" |
| 8 | 2 | `HeroDetailInfoView/imgBg/Image` | Y | `pos(-194.0,213.5) size(360.0,1.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 9 | 2 | `HeroDetailInfoView/imgBg/txtLevel` | Y | `pos(83.5,-164.0) size(77.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=24):"等级15" |
| 10 | 2 | `HeroDetailInfoView/imgBg/imgRare` | Y | `pos(-554.0,-15.0) size(120.0,54.0)` | `1.0,1.0->1.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_163 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 11 | 2 | `HeroDetailInfoView/imgBg/pnlStar` | Y | `pos(158.0,-98.0) size(164.0,44.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,HorizontalLayoutGroup` | - |
| 12 | 3 | `HeroDetailInfoView/imgBg/pnlStar/imgStar0` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 13 | 3 | `HeroDetailInfoView/imgBg/pnlStar/imgStar1` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 14 | 3 | `HeroDetailInfoView/imgBg/pnlStar/imgStar2` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 15 | 3 | `HeroDetailInfoView/imgBg/pnlStar/imgStar3` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 16 | 3 | `HeroDetailInfoView/imgBg/pnlStar/imgStar4` | Y | `pos(0.0,0.0) size(44.0,44.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 17 | 2 | `HeroDetailInfoView/imgBg/imgOccupation` | Y | `pos(337.0,-98.0) size(44.0,44.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 18 | 3 | `HeroDetailInfoView/imgBg/imgOccupation/txtOccupation` | Y | `pos(1.0,0.0) size(59.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=18):"女武神" |
| 19 | 2 | `HeroDetailInfoView/imgBg/imgCamp` | Y | `pos(432.0,-98.0) size(44.0,44.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 20 | 3 | `HeroDetailInfoView/imgBg/imgCamp/txtCamp` | Y | `pos(0.0,0.0) size(40.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=18):"辅助" |
| 21 | 2 | `HeroDetailInfoView/imgBg/pnlAttr` | Y | `pos(16.0,-187.0) size(510.0,218.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform` | - |
| 22 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Image` | Y | `pos(0.0,0.0) size(510.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_199 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 23 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Image/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"属性详情" |
| 24 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(23.0,-48.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"攻击" |
| 25 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtAtk` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 26 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(23.0,-78.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"防御" |
| 27 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtDef` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 28 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(23.0,-108.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"伤害加成" |
| 29 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtHurtAdd` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 30 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(23.0,-138.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"命中" |
| 31 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtHit` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 32 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(23.0,-168.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"暴击" |
| 33 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtCrt` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 34 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(23.0,-198.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"暴击伤害" |
| 35 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtCrd` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 36 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(273.0,-48.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"生命" |
| 37 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtHp` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 38 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(273.0,-78.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"速度" |
| 39 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtSpd` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 40 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(273.0,-108.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"伤害减免" |
| 41 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtHurtRdc` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 42 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(273.0,-138.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"抗暴" |
| 43 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtAvd` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 44 | 3 | `HeroDetailInfoView/imgBg/pnlAttr/Text` | Y | `pos(273.0,-168.0) size(40.0,20.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=20):"攻击" |
| 45 | 4 | `HeroDetailInfoView/imgBg/pnlAttr/Text/txtTgh` | Y | `pos(214.0,0.0) size(52.0,20.0)` | `0.0,1.0->0.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"1660" |
| 46 | 2 | `HeroDetailInfoView/imgBg/pnlSkill` | Y | `pos(16.0,-426.0) size(510.0,135.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform` | - |
| 47 | 3 | `HeroDetailInfoView/imgBg/pnlSkill/Image` | Y | `pos(0.0,0.0) size(0.0,30.0)` | `0.0,1.0->1.0,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_199 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 48 | 4 | `HeroDetailInfoView/imgBg/pnlSkill/Image/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"技能列表" |
| 49 | 3 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent` | Y | `pos(0.0,-25.5) size(414.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter` | - |
| 50 | 4 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image` | Y | `pos(-165.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_208 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 51 | 5 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill1` | Y | `pos(0.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_hero_herodetailinfoview.bundle<br>Button |
| 52 | 6 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill1/txtSkill1` | Y | `pos(0.0,0.0) size(84.0,32.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 53 | 4 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image` | Y | `pos(-55.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_208 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 54 | 5 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill2` | Y | `pos(0.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_hero_herodetailinfoview.bundle<br>Button |
| 55 | 6 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill2/txtSkill2` | Y | `pos(0.0,0.0) size(84.0,32.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 56 | 4 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image` | Y | `pos(55.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_208 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 57 | 5 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill3` | Y | `pos(0.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_hero_herodetailinfoview.bundle<br>Button |
| 58 | 6 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill3/txtSkill3` | Y | `pos(0.0,0.0) size(84.0,32.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 59 | 4 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image` | Y | `pos(165.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_208 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 60 | 5 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill4` | Y | `pos(0.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_hero_herodetailinfoview.bundle<br>Button |
| 61 | 6 | `HeroDetailInfoView/imgBg/pnlSkill/pnlSkillContent/Image/btnSkill4/txtSkill4` | Y | `pos(0.0,0.0) size(84.0,32.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 62 | 2 | `HeroDetailInfoView/imgBg/pnlEquip` | Y | `pos(271.0,-10.0) size(510.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform` | - |
| 63 | 3 | `HeroDetailInfoView/imgBg/pnlEquip/Image` | Y | `pos(0.0,0.0) size(510.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_199 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 64 | 4 | `HeroDetailInfoView/imgBg/pnlEquip/Image/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"灵装" |
| 65 | 3 | `HeroDetailInfoView/imgBg/pnlEquip/svEquip` | Y | `pos(0.5,-33.0) size(509.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,1.0)` | `RectTransform,ScrollRect,GridScroller` | - |
| 66 | 2 | `HeroDetailInfoView/imgBg/pnlSlug` | Y | `pos(271.0,-187.0) size(510.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform` | - |
| 67 | 3 | `HeroDetailInfoView/imgBg/pnlSlug/Image` | Y | `pos(0.0,0.0) size(510.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_199 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 68 | 4 | `HeroDetailInfoView/imgBg/pnlSlug/Image/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"源神" |
| 69 | 3 | `HeroDetailInfoView/imgBg/pnlSlug/svSlug` | Y | `pos(0.5,-48.0) size(509.0,110.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform,ScrollRect,GridScroller` | - |
| 70 | 2 | `HeroDetailInfoView/imgBg/pnlWeapon` | Y | `pos(271.0,-363.0) size(510.0,30.0)` | `0.5,1.0->0.5,1.0 p(0.5,1.0)` | `RectTransform` | - |
| 71 | 3 | `HeroDetailInfoView/imgBg/pnlWeapon/Image` | Y | `pos(0.0,0.0) size(0.0,30.0)` | `0.0,1.0->1.0,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_199 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 72 | 4 | `HeroDetailInfoView/imgBg/pnlWeapon/Image/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"神具" |
| 73 | 3 | `HeroDetailInfoView/imgBg/pnlWeapon/svWeapon` | Y | `pos(0.5,-33.0) size(509.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,1.0)` | `RectTransform,ScrollRect,GridScroller` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
