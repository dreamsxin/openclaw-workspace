# GalCollectionRewardGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalCollectionRewardGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalCollectionRewardGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galcollectionrewardgrid.bundle` / `files\yoo\Default\BundleFiles\6a\6a73ebb1c3f9c11b991c26e41e30ab95\__data`
- 节点数：`11`。
- Image/Text/Button：`3` / `4` / `1`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_88` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_88.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `gal_btn_26` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_26.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_98` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_98.png` | `assets_game_rawassets_sprite_gal_gal_img_98.bundle` | `c7bdaf8e3c549f3710540276753d8b8b.bundle`<br>`files\yoo\Default\BundleFiles\c7\c7bdaf8e3c549f3710540276753d8b8b\__data` | external CAB-a3b55a90b6541c1a3e811b9fceb037a5 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-a3b55a90b6541c1a3e811b9fceb037a5` | `assets_game_rawassets_sprite_gal_gal_img_98.bundle` | `files\yoo\Default\BundleFiles\c7\c7bdaf8e3c549f3710540276753d8b8b\__data` |
| 4 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalCollectionRewardGrid` | Y | `pos(0.0,0.0) size(952.0,128.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,GalCollectionRewardGrid` | Image:gal_img_98 [Simple] -> assets_game_rawassets_sprite_gal_gal_img_98.bundle |
| 2 | 1 | `GalCollectionRewardGrid/txtTitle` | Y | `pos(114.0,22.0) size(207.7,30.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 3 | 1 | `GalCollectionRewardGrid/txtNum` | Y | `pos(114.0,-14.0) size(144.7,51.2)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=36):"Default" |
| 4 | 1 | `GalCollectionRewardGrid/svRewards` | Y | `pos(71.0,0.0) size(282.0,90.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |
| 5 | 1 | `GalCollectionRewardGrid/pnlReward` | N | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 6 | 2 | `GalCollectionRewardGrid/pnlReward/Image` | Y | `pos(-128.0,0.0) size(70.0,70.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_88 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 7 | 1 | `GalCollectionRewardGrid/pnlComplete` | N | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 8 | 2 | `GalCollectionRewardGrid/pnlComplete/btnComplete` | Y | `pos(-128.0,0.0) size(208.0,74.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_26 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 9 | 3 | `GalCollectionRewardGrid/pnlComplete/btnComplete/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=26):"Default" |
| 10 | 1 | `GalCollectionRewardGrid/pnlAccept` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 11 | 2 | `GalCollectionRewardGrid/pnlAccept/Text` | Y | `pos(-128.0,0.0) size(201.8,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=26):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
