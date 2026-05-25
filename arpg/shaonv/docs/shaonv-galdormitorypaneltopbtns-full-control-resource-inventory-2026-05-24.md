# GalDormitoryPanelTopBtns 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalDormitoryPanelTopBtns`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalDormitoryPanelTopBtns.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_components_galdormitorypaneltopbtns.bundle` / `files\yoo\Default\UnpackBundleFiles\2a\2a874ed00da216228fb290ae4fd0fa41\__data`
- 节点数：`5`。
- Image/Text/Button：`3` / `0` / `3`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_btn_01` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_01.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_30` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_30.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_31` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_31.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalDormitoryPanelTopBtns` | Y | `pos(60.0,-18.0) size(120.0,80.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,GalDormitoryPanelTopBtns` | - |
| 2 | 1 | `GalDormitoryPanelTopBtns/btnClose` | Y | `pos(0.0,0.0) size(120.0,80.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_01 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 3 | 1 | `GalDormitoryPanelTopBtns/pnlSection` | Y | `pos(66.0,0.0) size(0.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.0,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter` | - |
| 4 | 2 | `GalDormitoryPanelTopBtns/pnlSection/btnDetail` | N | `pos(0.0,-30.0) size(60.0,60.0)` | `0.0,1.0->0.0,1.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_30 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 5 | 2 | `GalDormitoryPanelTopBtns/pnlSection/btnFavorite` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_31 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
