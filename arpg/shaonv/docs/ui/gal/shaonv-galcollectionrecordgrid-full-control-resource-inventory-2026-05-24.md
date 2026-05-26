# GalCollectionRecordGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalCollectionRecordGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionRecordGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galcollectionrecordgrid.bundle` / `files\yoo\Default\BundleFiles\c1\c1a45f41bbeeaee0f546938775191854\__data`
- 节点数：`11`。
- Image/Text/Button：`7` / `1` / `1`。
- Image 解析：外部 Sprite `5`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `2`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_16` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_16.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `gal_img_91` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_91.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_92` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_92.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_93` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_93.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_94` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_94.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 3 | `CAB-2762f2cdd10a3aeefcd20aec3066b8bf` | `-` | `-` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalCollectionRecordGrid` | Y | `pos(-236.5,238.5) size(422.0,214.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,GalCollectionRecordGrid` | Image:gal_img_91 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 2 | 1 | `GalCollectionRecordGrid/imgPic` | Y | `pos(-5.9,7.5) size(390.0,180.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_92 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 2 | `GalCollectionRecordGrid/imgPic/Image` | Y | `pos(85.0,17.0) size(170.0,34.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_93 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 4 | 3 | `GalCollectionRecordGrid/imgPic/Image/txtName` | Y | `pos(2.0,0.1) size(160.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=24):"完美的一天" |
| 5 | 1 | `GalCollectionRecordGrid/pnlLock` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 6 | 2 | `GalCollectionRecordGrid/pnlLock/Image` | Y | `pos(-6.5,6.8) size(-21.3,-24.3)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 7 | 2 | `GalCollectionRecordGrid/pnlLock/Image` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_94 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 8 | 1 | `GalCollectionRecordGrid/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 9 | 1 | `GalCollectionRecordGrid/pnlNew` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 10 | 2 | `GalCollectionRecordGrid/pnlNew/@RedDotBadgeNew` | Y | `pos(0.0,0.0) size(26.0,26.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,RedDotBadgeIcon` | - |
| 11 | 3 | `GalCollectionRecordGrid/pnlNew/@RedDotBadgeNew/imgNewIcon` | Y | `pos(0.0,0.0) size(58.0,22.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_16 [Simple] -> assets_game_rawassets_sprite_common.bundle |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
