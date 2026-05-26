# GalDateSelectGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalDateSelectGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalDateSelectGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galdateselectgrid.bundle` / `files\yoo\Default\BundleFiles\45\450ec7c8b5476eb5a426c980fe817a97\__data`
- 节点数：`7`。
- Image/Text/Button：`4` / `2` / `1`。
- Image 解析：外部 Sprite `4`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_77` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_77.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_78` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_78.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_79` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_79.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_80` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_80.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalDateSelectGrid` | Y | `pos(0.0,0.0) size(242.0,304.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalDateSelectGrid` | - |
| 2 | 1 | `GalDateSelectGrid/btnClick` | Y | `pos(0.0,0.0) size(242.0,304.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_img_79 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 3 | 1 | `GalDateSelectGrid/imgPic` | Y | `pos(-2.0,-15.0) size(222.0,238.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_80 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 4 | 1 | `GalDateSelectGrid/txtName` | Y | `pos(0.0,128.0) size(221.7,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Default" |
| 5 | 1 | `GalDateSelectGrid/imgSelect` | Y | `pos(-2.0,7.0) size(230.0,290.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_77 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 6 | 1 | `GalDateSelectGrid/pnlLock` | Y | `pos(-2.0,7.0) size(230.0,290.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_78 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 7 | 2 | `GalDateSelectGrid/pnlLock/txtCondition` | Y | `pos(0.0,-36.0) size(207.9,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
