# GalRoleSelector 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalRoleSelector`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalRoleSelector.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_components_galroleselector.bundle` / `files\yoo\Default\BundleFiles\1e\1e29e6ba63bd88d32ca0d355919a4007\__data`
- 节点数：`9`。
- Image/Text/Button：`4` / `1` / `1`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_btn_11` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_11.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_06` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_06.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_09` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_09.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-0e7bffabda55b8581d84f7e776e668e5` | `assets_game_rawassets_prefabs_ui_gal_components_galroleselectgrid.bundle` | `files\yoo\Default\BundleFiles\88\88e0293b6331aefd95458eee49b4f7df\__data` |
| 2 | `CAB-755b7f86b89daf8a2a077009b3ad4910` | `-` | `-` |
| 3 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 4 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalRoleSelector` | Y | `pos(0.0,0.0) size(110.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalRoleSelector` | - |
| 2 | 1 | `GalRoleSelector/btnChange` | Y | `pos(0.0,0.0) size(110.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_img_06 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 3 | 2 | `GalRoleSelector/btnChange/imgHead` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Unknown` | Image:none [Simple], a=0.00 |
| 4 | 2 | `GalRoleSelector/btnChange/Image` | Y | `pos(-17.0,-17.0) size(50.0,50.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_btn_11 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 5 | 2 | `GalRoleSelector/btnChange/@pnlRd` | Y | `pos(49.9,49.6) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 6 | 1 | `GalRoleSelector/pnlSelect` | N | `pos(-1.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 7 | 2 | `GalRoleSelector/pnlSelect/Image` | Y | `pos(75.0,84.0) size(200.0,44.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_09 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 8 | 3 | `GalRoleSelector/pnlSelect/Image/Text` | Y | `pos(0.0,0.0) size(-40.0,30.0)` | `0.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"Default" |
| 9 | 2 | `GalRoleSelector/pnlSelect/pnlSelectList` | Y | `pos(314.0,0.0) size(656.0,128.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,EnhancedScroller` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
