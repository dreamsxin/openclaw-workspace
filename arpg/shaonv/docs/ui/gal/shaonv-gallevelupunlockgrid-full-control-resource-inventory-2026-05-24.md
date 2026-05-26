# GalLevelUpUnlockGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalLevelUpUnlockGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelUpUnlockGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_gallevelupunlockgrid.bundle` / `files\yoo\Default\BundleFiles\b7\b74fd58a818855498e8519f82942d3ba\__data`
- 节点数：`3`。
- Image/Text/Button：`1` / `1` / `0`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_63` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_63.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalLevelUpUnlockGrid` | Y | `pos(373.5,-30.0) size(449.0,34.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalLevelUpUnlockGrid` | - |
| 2 | 1 | `GalLevelUpUnlockGrid/imgUnlock` | Y | `pos(-207.5,0.0) size(34.0,34.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_63 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 1 | `GalLevelUpUnlockGrid/txtUnlock` | Y | `pos(16.0,0.0) size(-32.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
