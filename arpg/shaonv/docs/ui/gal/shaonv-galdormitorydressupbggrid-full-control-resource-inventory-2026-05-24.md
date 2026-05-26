# GalDormitoryDressUpBgGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalDormitoryDressUpBgGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpBgGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_dormitory_galdormitorydressupbggrid.bundle` / `files\yoo\Default\BundleFiles\7a\7ae40c32118a5b3f143053abf8001acd\__data`
- 节点数：`9`。
- Image/Text/Button：`7` / `1` / `1`。
- Image 解析：外部 Sprite `6`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_17` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_17.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `gal_img_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_37` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_37.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_38` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_38.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_39` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_39.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_40` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_40.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalDormitoryDressUpBgGrid` | Y | `pos(0.0,0.0) size(398.0,198.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,GalDormitoryDressUpBgGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `GalDormitoryDressUpBgGrid/Image` | Y | `pos(0.0,0.0) size(398.0,198.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_38 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 2 | `GalDormitoryDressUpBgGrid/Image/imgBg` | Y | `pos(0.0,0.0) size(370.0,170.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_39 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 4 | 2 | `GalDormitoryDressUpBgGrid/Image/Image` | Y | `pos(0.0,31.0) size(370.0,34.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 5 | 3 | `GalDormitoryDressUpBgGrid/Image/Image/txtName` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 6 | 2 | `GalDormitoryDressUpBgGrid/Image/imgSelect` | Y | `pos(0.0,0.0) size(378.0,178.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_37 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 7 | 2 | `GalDormitoryDressUpBgGrid/Image/imgLock` | Y | `pos(0.0,0.0) size(378.0,178.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_40 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 8 | 2 | `GalDormitoryDressUpBgGrid/Image/@pnlRd` | Y | `pos(-9.8,-10.8) size(26.0,26.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,RedDotBadgeIcon` | - |
| 9 | 3 | `GalDormitoryDressUpBgGrid/Image/@pnlRd/imgRedDotIcon` | Y | `pos(0.0,0.0) size(26.0,26.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_17 [Simple] -> assets_game_rawassets_sprite_common.bundle |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
