# GalLevelGroupGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalLevelGroupGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelGroupGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_gallevelgroupgrid.bundle` / `files\yoo\Default\BundleFiles\06\06693d77a9db7c6512b2465274dae57c\__data`
- 节点数：`6`。
- Image/Text/Button：`3` / `2` / `1`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_btn_34` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_34.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_35` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_35.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalLevelGroupGrid` | Y | `pos(0.0,0.0) size(228.0,76.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalLevelGroupGrid,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `GalLevelGroupGrid/imgNormal` | Y | `pos(0.0,0.0) size(228.0,76.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_btn_35 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 2 | `GalLevelGroupGrid/imgNormal/txtNormal` | Y | `pos(-5.0,1.0) size(-10.0,-2.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Default" |
| 4 | 1 | `GalLevelGroupGrid/imgSelect` | Y | `pos(0.0,0.0) size(228.0,76.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_btn_34 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 5 | 2 | `GalLevelGroupGrid/imgSelect/txtSelect` | Y | `pos(-5.0,1.0) size(-10.0,-2.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Default" |
| 6 | 1 | `GalLevelGroupGrid/@pnlRd` | Y | `pos(85.2,28.1) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
