# GalLevelUpView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalLevelUpView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalLevelUpView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_gallevelupview.bundle` / `files\yoo\Default\BundleFiles\2d\2da8a97e1bb3bbad64a6bbb436cb85bb\__data`
- 节点数：`17`。
- Image/Text/Button：`9` / `3` / `0`。
- Image 解析：外部 Sprite `9`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_57` | 2 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_57.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_61` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_61.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_62` | 2 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_62.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `gal_img_58` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_58.png` | `assets_game_rawassets_sprite_gal_gal_img_58.bundle` | `71af6ff3587ad7d842ccbe491622efb3.bundle`<br>`files\yoo\Default\BundleFiles\71\71af6ff3587ad7d842ccbe491622efb3\__data` | external CAB-5adca8426b7de476e43feec79b730dc3 |
| `gal_img_59` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_59.png` | `assets_game_rawassets_sprite_gal_gal_img_59.bundle` | `02c2255735c8caa9c4d7c77ff804559a.bundle`<br>`files\yoo\Default\BundleFiles\02\02c2255735c8caa9c4d7c77ff804559a\__data` | external CAB-bd9bc2bfa896f9527b347c927c7f0917 |
| `gal_img_60` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_60.png` | `assets_game_rawassets_sprite_gal_gal_img_60.bundle` | `e5245f51f484c9d7f85c25574279d2a3.bundle`<br>`files\yoo\Default\BundleFiles\e5\e5245f51f484c9d7f85c25574279d2a3\__data` | external CAB-51f6cfbebf3e4e4e0c3131669a11a50e |
| `gal_txt_01` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_txt_01.png` | `assets_game_rawassets_sprite_gal_gal_txt_01.bundle` | `4053c3177bf313cb05a62a560f5174b3.bundle`<br>`files\yoo\Default\BundleFiles\40\4053c3177bf313cb05a62a560f5174b3\__data` | external CAB-636d04f9e75e167437268bf064034135 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 3 | `CAB-51f6cfbebf3e4e4e0c3131669a11a50e` | `assets_game_rawassets_sprite_gal_gal_img_60.bundle` | `files\yoo\Default\BundleFiles\e5\e5245f51f484c9d7f85c25574279d2a3\__data` |
| 4 | `CAB-5adca8426b7de476e43feec79b730dc3` | `assets_game_rawassets_sprite_gal_gal_img_58.bundle` | `files\yoo\Default\BundleFiles\71\71af6ff3587ad7d842ccbe491622efb3\__data` |
| 5 | `CAB-636d04f9e75e167437268bf064034135` | `assets_game_rawassets_sprite_gal_gal_txt_01.bundle` | `files\yoo\Default\BundleFiles\40\4053c3177bf313cb05a62a560f5174b3\__data` |
| 6 | `CAB-bd9bc2bfa896f9527b347c927c7f0917` | `assets_game_rawassets_sprite_gal_gal_img_59.bundle` | `files\yoo\Default\BundleFiles\02\02c2255735c8caa9c4d7c77ff804559a\__data` |
| 7 | `CAB-d658a91595cb5cdab7e786ba072b54a2` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalLevelUpView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,GalLevelUpView` | - |
| 2 | 1 | `GalLevelUpView/imgFrame` | Y | `pos(0.0,0.0) size(6680.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_58 [Tiled] -> assets_game_rawassets_sprite_gal_gal_img_58.bundle |
| 3 | 1 | `GalLevelUpView/imgBg` | Y | `pos(0.0,0.0) size(1670.0,580.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_60 [Simple] -> assets_game_rawassets_sprite_gal_gal_img_60.bundle |
| 4 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(356.0,189.0) size(540.0,120.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_txt_01 [Simple] -> assets_game_rawassets_sprite_gal_gal_txt_01.bundle |
| 5 | 2 | `GalLevelUpView/imgBg/pnlSpineHandler` | Y | `pos(-328.5,-927.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 6 | 3 | `GalLevelUpView/imgBg/pnlSpineHandler/spineHero` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 7 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(-328.5,-312.5) size(605.0,55.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_59 [Simple] -> assets_game_rawassets_sprite_gal_gal_img_59.bundle |
| 8 | 3 | `GalLevelUpView/imgBg/Image/txtWords` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=24):"Default" |
| 9 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(246.0,83.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_57 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 10 | 3 | `GalLevelUpView/imgBg/Image/txtOldLv` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=40):"" |
| 11 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(358.0,83.0) size(100.0,76.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_61 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 12 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(466.0,83.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_57 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 13 | 3 | `GalLevelUpView/imgBg/Image/txtNewLv` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=40):"" |
| 14 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(356.0,28.0) size(484.0,2.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_62 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 15 | 2 | `GalLevelUpView/imgBg/Image` | Y | `pos(356.0,-122.0) size(484.0,2.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:gal_img_62 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 16 | 2 | `GalLevelUpView/imgBg/svUnlock` | Y | `pos(373.5,-45.0) size(449.0,130.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |
| 17 | 2 | `GalLevelUpView/imgBg/svReward` | Y | `pos(356.0,-180.0) size(350.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
