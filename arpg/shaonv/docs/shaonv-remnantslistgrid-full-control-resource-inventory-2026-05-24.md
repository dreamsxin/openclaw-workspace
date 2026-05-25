# RemnantsListGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsListGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsListGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantslistgrid.bundle` / `files\yoo\Default\BundleFiles\30\30fb1d616d57493e0174a8634fdb1637\__data`
- 节点数：`22`。
- Image/Text/Button：`14` / `4` / `1`。
- Image 解析：外部 Sprite `8`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `2`，未解析 `4`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_73` | 2 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_74` | 3 | `Assets/Game/RawAssets/Sprite/Common/common_img_74.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `hero_img_18` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_18.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_20` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_20.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_txt_02` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_txt_02.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 4 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |
| 5 | `CAB-34b95862cded399c7e60a6bd42fc750d` | `-` | `-` |
| 6 | `CAB-2762f2cdd10a3aeefcd20aec3066b8bf` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsListGrid` | Y | `pos(440.0,-154.0) size(172.0,296.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,RemnantsListGrid` | - |
| 2 | 1 | `RemnantsListGrid/Image` | Y | `pos(0.0,0.0) size(172.0,296.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:hero_img_18 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 3 | 2 | `RemnantsListGrid/Image/pnlHavePet` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Mask,Grey` | Image:none [Sliced], a=0.00 |
| 4 | 3 | `RemnantsListGrid/Image/pnlHavePet/imgPet` | Y | `pos(0.0,-125.0) size(160.0,250.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=5 pid=1397975093443451270 cab=CAB-34b95862cded399c7e60a6bd42fc750d [Simple] |
| 5 | 3 | `RemnantsListGrid/Image/pnlHavePet/imgFrame` | Y | `pos(0.0,46.0) size(160.0,108.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_20 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 6 | 3 | `RemnantsListGrid/Image/pnlHavePet/txtHeroName` | Y | `pos(0.0,-116.0) size(0.0,-276.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"鲨鱼辣椒" |
| 7 | 3 | `RemnantsListGrid/Image/pnlHavePet/txtLevel` | Y | `pos(52.5,-74.0) size(36.0,20.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=30):"99" |
| 8 | 3 | `RemnantsListGrid/Image/pnlHavePet/@StarBar` | Y | `pos(-23.0,-79.0) size(-60.0,-260.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter,StarBar` | - |
| 9 | 4 | `RemnantsListGrid/Image/pnlHavePet/@StarBar/@imgStar` | Y | `pos(18.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 10 | 4 | `RemnantsListGrid/Image/pnlHavePet/@StarBar/@imgStar` | Y | `pos(37.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 11 | 4 | `RemnantsListGrid/Image/pnlHavePet/@StarBar/@imgStar` | Y | `pos(56.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 12 | 4 | `RemnantsListGrid/Image/pnlHavePet/@StarBar/@imgStar` | Y | `pos(75.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 13 | 4 | `RemnantsListGrid/Image/pnlHavePet/@StarBar/@imgStar` | Y | `pos(94.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 14 | 3 | `RemnantsListGrid/Image/pnlHavePet/imgStateBg` | Y | `pos(44.0,-11.0) size(64.0,22.0)` | `0.0,1.0->0.0,1.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=4350802882673751637 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 15 | 4 | `RemnantsListGrid/Image/pnlHavePet/imgStateBg/txtState` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=16):"上阵中" |
| 16 | 2 | `RemnantsListGrid/Image/txtUse` | Y | `pos(-11.0,134.0) size(-124.0,-276.0)` | `0.0,0.0->1.0,1.0 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"0/60aaa" |
| 17 | 2 | `RemnantsListGrid/Image/imgMask` | N | `pos(0.0,7.5) size(160.0,280.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=5459479694287377341 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 18 | 2 | `RemnantsListGrid/Image/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 19 | 2 | `RemnantsListGrid/Image/imgSelect` | N | `pos(0.0,7.5) size(170.0,290.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-4174394416975242878 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 20 | 2 | `RemnantsListGrid/Image/pnlCanGet` | N | `pos(0.0,0.0) size(198.0,304.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_txt_02 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 21 | 2 | `RemnantsListGrid/Image/pnlUnSelect` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 22 | 2 | `RemnantsListGrid/Image/pnlRd` | Y | `pos(-0.3,5.8) size(154.6,276.5)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
