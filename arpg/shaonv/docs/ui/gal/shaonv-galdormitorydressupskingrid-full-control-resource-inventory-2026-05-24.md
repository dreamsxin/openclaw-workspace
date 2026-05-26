# GalDormitoryDressUpSkinGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalDormitoryDressUpSkinGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpSkinGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_dormitory_galdormitorydressupskingrid.bundle` / `files\yoo\Default\BundleFiles\e7\e7402ead75460534747a152f6d67403b\__data`
- 节点数：`10`。
- Image/Text/Button：`7` / `1` / `1`。
- Image 解析：外部 Sprite `6`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_17` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_17.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `gal_img_32` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_32.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_34` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_34.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_36` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_36.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `phero_037r` | 1 | `Assets/Game/RawAssets/Sprite/Head/Half2/phero_037r.png` | `assets_game_rawassets_sprite_head_half2.bundle` | `26c9a3831f0632b544d7ede4f6affd5b.bundle`<br>`files\yoo\Default\BundleFiles\26\26c9a3831f0632b544d7ede4f6affd5b\__data` | external CAB-41a1c39e9137b1a1dddfb56cd0232890 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-41a1c39e9137b1a1dddfb56cd0232890` | `assets_game_rawassets_sprite_head_half2.bundle` | `files\yoo\Default\BundleFiles\26\26c9a3831f0632b544d7ede4f6affd5b\__data` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalDormitoryDressUpSkinGrid` | Y | `pos(0.0,0.0) size(198.0,288.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,GalDormitoryDressUpSkinGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `GalDormitoryDressUpSkinGrid/imgBg` | Y | `pos(0.0,0.0) size(198.0,288.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_34 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 2 | `GalDormitoryDressUpSkinGrid/imgBg/imgSkin` | Y | `pos(0.0,0.0) size(-28.0,-28.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:phero_037r [Simple] -> assets_game_rawassets_sprite_head_half2.bundle |
| 4 | 2 | `GalDormitoryDressUpSkinGrid/imgBg/Image` | Y | `pos(0.0,31.0) size(170.0,34.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 5 | 3 | `GalDormitoryDressUpSkinGrid/imgBg/Image/txtName` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 6 | 2 | `GalDormitoryDressUpSkinGrid/imgBg/imgSelect` | N | `pos(0.0,0.0) size(178.0,268.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_32 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 7 | 2 | `GalDormitoryDressUpSkinGrid/imgBg/imgLock` | Y | `pos(0.0,0.0) size(178.0,268.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_36 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 8 | 2 | `GalDormitoryDressUpSkinGrid/imgBg/pnlRd` | Y | `pos(85.1,130.1) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 9 | 3 | `GalDormitoryDressUpSkinGrid/imgBg/pnlRd/@RedDotBadgeIcon` | Y | `pos(0.0,0.0) size(26.0,26.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,RedDotBadgeIcon` | - |
| 10 | 4 | `GalDormitoryDressUpSkinGrid/imgBg/pnlRd/@RedDotBadgeIcon/imgRedDotIcon` | Y | `pos(0.0,0.0) size(26.0,26.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_17 [Simple] -> assets_game_rawassets_sprite_common.bundle |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
