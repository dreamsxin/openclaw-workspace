# GalRoleSelectGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalRoleSelectGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalRoleSelectGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_components_galroleselectgrid.bundle` / `files\yoo\Default\BundleFiles\88\88e0293b6331aefd95458eee49b4f7df\__data`
- 节点数：`11`。
- Image/Text/Button：`9` / `1` / `2`。
- Image 解析：外部 Sprite `6`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `3`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_btn_17` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_17.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_btn_18` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_18.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_06` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_06.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_10` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_10.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_51` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_51.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_52` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_52.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-755b7f86b89daf8a2a077009b3ad4910` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalRoleSelectGrid` | Y | `pos(0.0,0.0) size(110.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,GalRoleSelectGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `GalRoleSelectGrid/imgBackGround` | Y | `pos(0.0,0.0) size(110.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_06 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 1 | `GalRoleSelectGrid/imgHead` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:none [Simple] |
| 4 | 1 | `GalRoleSelectGrid/imgSelect` | Y | `pos(0.0,0.0) size(110.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_btn_17 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 5 | 2 | `GalRoleSelectGrid/imgSelect/Image` | Y | `pos(-17.0,17.0) size(50.0,50.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_btn_18 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 6 | 1 | `GalRoleSelectGrid/Image` | Y | `pos(-36.0,-38.0) size(56.0,56.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_10 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 7 | 2 | `GalRoleSelectGrid/Image/txtLv` | Y | `pos(0.0,3.0) size(0.0,-26.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"99" |
| 8 | 1 | `GalRoleSelectGrid/imgFavorite` | Y | `pos(17.0,-17.0) size(34.0,34.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_52 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 9 | 1 | `GalRoleSelectGrid/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 10 | 1 | `GalRoleSelectGrid/imgLock` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_51 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 11 | 1 | `GalRoleSelectGrid/@pnlRd` | Y | `pos(35.3,35.0) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
