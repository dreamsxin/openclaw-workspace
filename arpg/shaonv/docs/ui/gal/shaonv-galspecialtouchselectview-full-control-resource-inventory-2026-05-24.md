# GalSpecialTouchSelectView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalSpecialTouchSelectView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalSpecialTouchSelectView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galspecialtouchselectview.bundle` / `files\yoo\Default\BundleFiles\d6\d679363b02889b49b9c00f38e72e7cb3\__data`
- 节点数：`5`。
- Image/Text/Button：`2` / `1` / `1`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_bg_05` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/gal_bg_05.png` | `assets_game_rawassets_sprite_background_gal_bg_05.bundle` | `48353ba19fcbae5eec0b1662d91a039f.bundle`<br>`files\yoo\Default\BundleFiles\48\48353ba19fcbae5eec0b1662d91a039f\__data` | external CAB-5209e6d6d7ab9e818d471a77bcaeca61 |
| `gal_btn_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-5209e6d6d7ab9e818d471a77bcaeca61` | `assets_game_rawassets_sprite_background_gal_bg_05.bundle` | `files\yoo\Default\BundleFiles\48\48353ba19fcbae5eec0b1662d91a039f\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalSpecialTouchSelectView` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalSpecialTouchSelectView` | - |
| 2 | 1 | `GalSpecialTouchSelectView/imgBg` | Y | `pos(0.0,0.0) size(1160.0,726.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_bg_05 [Simple] -> assets_game_rawassets_sprite_background_gal_bg_05.bundle |
| 3 | 2 | `GalSpecialTouchSelectView/imgBg/btnClose` | Y | `pos(-39.0,-51.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 4 | 2 | `GalSpecialTouchSelectView/imgBg/Text` | Y | `pos(538.3,-70.0) size(906.6,36.1)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=36):"Default" |
| 5 | 2 | `GalSpecialTouchSelectView/imgBg/svSection` | Y | `pos(15.5,-17.0) size(1005.0,550.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
