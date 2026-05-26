# GalSpecialTouchView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalSpecialTouchView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalSpecialTouchView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galspecialtouchview.bundle` / `files\yoo\Default\UnpackBundleFiles\c3\c3143120fcff5fee497c40fe6e98537f\__data`
- 节点数：`11`。
- Image/Text/Button：`4` / `0` / `3`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

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
| 2 | `CAB-d658a91595cb5cdab7e786ba072b54a2` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalSpecialTouchView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,GalSpecialTouchView,CanvasGroup` | - |
| 2 | 1 | `GalSpecialTouchView/imgBackGround` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 3 | 1 | `GalSpecialTouchView/@spineTouchManager` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,DynamicField,SpineTouchManager` | - |
| 4 | 2 | `GalSpecialTouchView/@spineTouchManager/BgCtl` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic,SkeletonUtility` | - |
| 5 | 2 | `GalSpecialTouchView/@spineTouchManager/CharacterCtl` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic,SkeletonUtility` | - |
| 6 | 2 | `GalSpecialTouchView/@spineTouchManager/FrontCtl` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic,SkeletonUtility` | - |
| 7 | 1 | `GalSpecialTouchView/pnlTopBtns` | Y | `pos(60.0,-18.0) size(120.0,80.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,GalDormitoryPanelTopBtns` | - |
| 8 | 2 | `GalSpecialTouchView/pnlTopBtns/btnClose` | Y | `pos(0.0,0.0) size(120.0,80.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_01 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 9 | 2 | `GalSpecialTouchView/pnlTopBtns/pnlSection` | N | `pos(66.0,0.0) size(60.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.0,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter` | - |
| 10 | 3 | `GalSpecialTouchView/pnlTopBtns/pnlSection/btnDetail` | Y | `pos(0.0,-30.0) size(60.0,60.0)` | `0.0,1.0->0.0,1.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_30 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |
| 11 | 3 | `GalSpecialTouchView/pnlTopBtns/pnlSection/btnFavorite` | N | `pos(60.0,-30.0) size(60.0,60.0)` | `0.0,1.0->0.0,1.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:gal_btn_31 [Simple] -> assets_game_rawassets_sprite_gal.bundle<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
