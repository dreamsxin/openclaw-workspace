# GalDateSelectView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalDateSelectView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalDateSelectView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galdateselectview.bundle` / `files\yoo\Default\BundleFiles\5e\5e61987c6c373fef049be54caacf7543\__data`
- 节点数：`10`。
- Image/Text/Button：`4` / `4` / `3`。
- Image 解析：外部 Sprite `4`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_bg_06` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/gal_bg_06.png` | `assets_game_rawassets_sprite_background_gal_bg_06.bundle` | `dc5e6eeb65b1cbf9756e9c453c80464c.bundle`<br>`files\yoo\Default\BundleFiles\dc\dc5e6eeb65b1cbf9756e9c453c80464c\__data` | external CAB-8e538fcd7f5456077da30437fae623ef |
| `gal_btn_25` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_25.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_36` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_36.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-8e538fcd7f5456077da30437fae623ef` | `assets_game_rawassets_sprite_background_gal_bg_06.bundle` | `files\yoo\Default\BundleFiles\dc\dc5e6eeb65b1cbf9756e9c453c80464c\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalDateSelectView` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalDateSelectView` | - |
| 2 | 1 | `GalDateSelectView/imgBg` | Y | `pos(0.0,0.0) size(1346.0,652.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_bg_06 [Simple] -> assets_game_rawassets_sprite_background_gal_bg_06.bundle |
| 3 | 2 | `GalDateSelectView/imgBg/btnClose` | Y | `pos(-95.0,-81.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 4 | 2 | `GalDateSelectView/imgBg/Text` | Y | `pos(-43.7,256.0) size(-257.5,-622.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=36):"Default" |
| 5 | 2 | `GalDateSelectView/imgBg/txtDateNum` | Y | `pos(-253.5,187.0) size(-679.0,-622.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 6 | 2 | `GalDateSelectView/imgBg/btnDateRecord` | Y | `pos(144.0,119.0) size(88.0,88.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_36 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 7 | 3 | `GalDateSelectView/imgBg/btnDateRecord/Text` | Y | `pos(0.0,-33.0) size(88.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=18):"Default" |
| 8 | 2 | `GalDateSelectView/imgBg/btnConfirm` | Y | `pos(0.0,-209.0) size(338.0,74.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_25 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 9 | 3 | `GalDateSelectView/imgBg/btnConfirm/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=26):"Default" |
| 10 | 2 | `GalDateSelectView/imgBg/tabSections` | Y | `pos(1.5,-1.0) size(1157.0,304.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
