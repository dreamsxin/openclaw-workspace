# GalToastGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalToastGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalToastGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galtoastgrid.bundle` / `files\yoo\Default\BundleFiles\5e\5e9e6fad82a19dcd5e5343cbb74b35ef\__data`
- 节点数：`15`。
- Image/Text/Button：`6` / `5` / `0`。
- Image 解析：外部 Sprite `6`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_10` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_10.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_11` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_11.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_12` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_12.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_13` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_13.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_14` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_14.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `yhero_023` | 1 | `Assets/Game/RawAssets/Sprite/Head/Round/yhero_023.png` | `assets_game_rawassets_sprite_head_round.bundle` | `ed83c7f6493927f7eb32770282eb16b5.bundle`<br>`resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` | external CAB-f8ef5bffbbc70cdd4b384bfa099efd20 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-f8ef5bffbbc70cdd4b384bfa099efd20` | `assets_game_rawassets_sprite_head_round.bundle` | `resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalToastGrid` | Y | `pos(98.0,811.0) size(486.0,0.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.0)` | `RectTransform,CanvasRenderer,GalToastGrid` | - |
| 2 | 1 | `GalToastGrid/imgBg` | Y | `pos(0.0,0.0) size(486.0,122.0)` | `1.0,0.0->1.0,0.0 p(1.0,0.0)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_11 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 2 | `GalToastGrid/imgBg/imgHeadBg` | Y | `pos(142.0,0.0) size(120.0,120.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_12 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 4 | 3 | `GalToastGrid/imgBg/imgHeadBg/imgHead` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:yhero_023 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 5 | 3 | `GalToastGrid/imgBg/imgHeadBg/imgLv` | Y | `pos(24.0,22.0) size(56.0,56.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_10 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 6 | 4 | `GalToastGrid/imgBg/imgHeadBg/imgLv/txtLv` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"9999" |
| 7 | 2 | `GalToastGrid/imgBg/txtTile` | Y | `pos(108.5,20.0) size(269.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=28):"DefaultDefaultDefaultDefault" |
| 8 | 2 | `GalToastGrid/imgBg/pnlSlider` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 9 | 3 | `GalToastGrid/imgBg/pnlSlider/txtSliderTitle` | Y | `pos(31.5,-9.0) size(-367.0,-94.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 10 | 3 | `GalToastGrid/imgBg/pnlSlider/txtSliderValue` | Y | `pos(-62.0,-8.0) size(-396.0,-92.0)` | `0.0,0.0->1.0,1.0 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=30):"+9999" |
| 11 | 3 | `GalToastGrid/imgBg/pnlSlider/sld` | Y | `pos(77.0,-34.0) size(206.0,10.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,Slider` | - |
| 12 | 4 | `GalToastGrid/imgBg/pnlSlider/sld/Background` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_13 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 13 | 4 | `GalToastGrid/imgBg/pnlSlider/sld/Fill Area` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 14 | 5 | `GalToastGrid/imgBg/pnlSlider/sld/Fill Area/Fill` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_14 [Sliced] -> assets_game_rawassets_sprite_gal.bundle |
| 15 | 2 | `GalToastGrid/imgBg/txtMessage` | Y | `pos(107.5,-20.0) size(271.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
