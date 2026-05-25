# GalLevelView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalLevelView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_gallevelview.bundle` / `files\yoo\Default\BundleFiles\61\611624cb7868a2d0d927630c22cc46f4\__data`
- 节点数：`7`。
- Image/Text/Button：`3` / `1` / `2`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_bg_03` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/gal_bg_03.png` | `assets_game_rawassets_sprite_background_gal_bg_03.bundle` | `44ab770f0d7327968fff1ed15db66a53.bundle`<br>`files\yoo\Default\BundleFiles\44\44ab770f0d7327968fff1ed15db66a53\__data` | external CAB-5934842977f6eaf978518592a03e9d34 |
| `gal_btn_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_44` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_44.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-5934842977f6eaf978518592a03e9d34` | `assets_game_rawassets_sprite_background_gal_bg_03.bundle` | `files\yoo\Default\BundleFiles\44\44ab770f0d7327968fff1ed15db66a53\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalLevelView` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalLevelView` | - |
| 2 | 1 | `GalLevelView/Image` | Y | `pos(0.0,0.0) size(1090.0,680.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_bg_03 [Simple] -> assets_game_rawassets_sprite_background_gal_bg_03.bundle |
| 3 | 2 | `GalLevelView/Image/Text` | Y | `pos(356.0,-95.0) size(538.0,38.4)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=36):"Default" |
| 4 | 2 | `GalLevelView/Image/btnClose` | Y | `pos(-67.0,-65.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 5 | 2 | `GalLevelView/Image/tabGourp` | Y | `pos(-380.0,-25.9) size(228.0,459.8)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |
| 6 | 2 | `GalLevelView/Image/svLevel` | Y | `pos(100.0,-31.5) size(752.0,469.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScrollerEx` | - |
| 7 | 2 | `GalLevelView/Image/btnDetail` | Y | `pos(-275.0,242.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_44 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
