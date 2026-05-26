# GalDormitoryDressUpEffectGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalDormitoryDressUpEffectGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Dormitory/GalDormitoryDressUpEffectGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_dormitory_galdormitorydressupeffectgrid.bundle` / `files\yoo\Default\BundleFiles\5b\5b64d0238279c12d85f3b2e2c1ca7bb7\__data`
- 节点数：`3`。
- Image/Text/Button：`1` / `2` / `0`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_48` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_48.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalDormitoryDressUpEffectGrid` | Y | `pos(0.0,0.0) size(390.0,36.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,GalDormitoryDressUpEffectGrid` | Image:gal_img_48 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 2 | 1 | `GalDormitoryDressUpEffectGrid/txtName` | Y | `pos(14.0,0.0) size(186.5,36.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |
| 3 | 1 | `GalDormitoryDressUpEffectGrid/txtVal` | Y | `pos(-14.0,0.0) size(186.5,36.0)` | `1.0,0.5->1.0,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
