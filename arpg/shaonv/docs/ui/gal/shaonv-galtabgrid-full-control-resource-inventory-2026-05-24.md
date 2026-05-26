# GalTabGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalTabGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalTabGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galtabgrid.bundle` / `files\yoo\Default\BundleFiles\22\22bb6fd9748c979153e51f351bd36306\__data`
- 节点数：`8`。
- Image/Text/Button：`5` / `2` / `1`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `4`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_btn_20` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_20.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalTabGrid` | Y | `pos(0.0,0.0) size(266.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,GalTabGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `GalTabGrid/imgNormal` | Y | `pos(0.0,0.0) size(266.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.00 |
| 3 | 2 | `GalTabGrid/imgNormal/imgNormalIcon` | Y | `pos(83.0,0.0) size(70.0,70.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 4 | 2 | `GalTabGrid/imgNormal/txtNormal` | Y | `pos(70.0,0.0) size(-140.0,-70.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,Gradient` | Text(fs=22):"Default" |
| 5 | 1 | `GalTabGrid/imgSelect` | Y | `pos(0.0,0.0) size(266.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_btn_20 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 6 | 2 | `GalTabGrid/imgSelect/imgSelectIcon` | Y | `pos(83.0,0.0) size(70.0,70.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 7 | 2 | `GalTabGrid/imgSelect/txtSelect` | Y | `pos(70.0,0.0) size(-140.0,-70.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,Gradient` | Text(fs=22):"Default" |
| 8 | 1 | `GalTabGrid/@pnlRd` | Y | `pos(87.7,27.4) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
