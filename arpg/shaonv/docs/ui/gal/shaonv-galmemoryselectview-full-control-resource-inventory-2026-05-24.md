# GalMemorySelectView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalMemorySelectView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalMemorySelectView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galmemoryselectview.bundle` / `files\yoo\Default\BundleFiles\f4\f4c3ddad9de84e7e939a72608e654866\__data`
- 节点数：`5`。
- Image/Text/Button：`2` / `1` / `1`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_bg_04` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/gal_bg_04.png` | `assets_game_rawassets_sprite_background_gal_bg_04.bundle` | `d263682ef741f046f2b4b11b1a3c4946.bundle`<br>`files\yoo\Default\BundleFiles\d2\d263682ef741f046f2b4b11b1a3c4946\__data` | external CAB-5a65684d4acae9ecc9ab9f18ddf795d0 |
| `gal_btn_33` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_33.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-5a65684d4acae9ecc9ab9f18ddf795d0` | `assets_game_rawassets_sprite_background_gal_bg_04.bundle` | `files\yoo\Default\BundleFiles\d2\d263682ef741f046f2b4b11b1a3c4946\__data` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalMemorySelectView` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalMemorySelectView` | - |
| 2 | 1 | `GalMemorySelectView/Image` | Y | `pos(0.0,0.0) size(1346.0,652.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_bg_04 [Simple] -> assets_game_rawassets_sprite_background_gal_bg_04.bundle |
| 3 | 2 | `GalMemorySelectView/Image/Text` | Y | `pos(-124.1,255.0) size(925.8,37.1)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=36):"Default" |
| 4 | 2 | `GalMemorySelectView/Image/btnClose` | Y | `pos(-95.0,-81.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_33 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 5 | 2 | `GalMemorySelectView/Image/svMemory` | Y | `pos(0.0,-24.0) size(1190.0,440.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
