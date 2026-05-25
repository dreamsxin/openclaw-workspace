# GalTokenDetailView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalTokenDetailView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalTokenDetailView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galtokendetailview.bundle` / `files\yoo\Default\BundleFiles\88\8868b6fe4455b7d33b3d13141431ca99\__data`
- 节点数：`8`。
- Image/Text/Button：`4` / `3` / `1`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_bg_10` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/gal_bg_10.png` | `assets_game_rawassets_sprite_background_gal_bg_10.bundle` | `a5856ea87eb8e939de68c218378dbdcb.bundle`<br>`files\yoo\Default\BundleFiles\a5\a5856ea87eb8e939de68c218378dbdcb\__data` | external CAB-9031d7720d313039c60789c176cb0cb9 |
| `gal_btn_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_99` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_99.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-9031d7720d313039c60789c176cb0cb9` | `assets_game_rawassets_sprite_background_gal_bg_10.bundle` | `files\yoo\Default\BundleFiles\a5\a5856ea87eb8e939de68c218378dbdcb\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalTokenDetailView` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalTokenDetailView` | - |
| 2 | 1 | `GalTokenDetailView/imgBg` | Y | `pos(0.0,0.0) size(946.0,516.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_bg_10 [Simple] -> assets_game_rawassets_sprite_background_gal_bg_10.bundle |
| 3 | 2 | `GalTokenDetailView/imgBg/txtName` | Y | `pos(351.2,-99.0) size(536.4,30.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Default" |
| 4 | 2 | `GalTokenDetailView/imgBg/btnClose` | Y | `pos(-95.0,-93.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 5 | 2 | `GalTokenDetailView/imgBg/Image` | Y | `pos(-239.0,39.0) size(142.0,142.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_99 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 6 | 3 | `GalTokenDetailView/imgBg/Image/imgIcon` | Y | `pos(-3.0,3.0) size(110.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 7 | 2 | `GalTokenDetailView/imgBg/txtCondition` | Y | `pos(-240.0,-89.0) size(282.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=24):"Default" |
| 8 | 2 | `GalTokenDetailView/imgBg/txtDetail` | Y | `pos(175.0,-35.5) size(418.0,286.9)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
