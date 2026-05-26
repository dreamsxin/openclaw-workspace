# GalRole 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalRole`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/Components/GalRole.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_components_galrole.bundle` / `files\yoo\Default\BundleFiles\a4\a43483a4b1ecb519dcd62f2dfe6b19d3\__data`
- 节点数：`4`。
- Image/Text/Button：`0` / `0` / `0`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-58197a437c9490430c75204b0fb01052` | `-` | `-` |
| 2 | `CAB-d658a91595cb5cdab7e786ba072b54a2` | `-` | `-` |
| 3 | `CAB-f8b6bba23d3ec910d9bd7ab2ce63051c` | `assets_game_rawassets_spine_hero_hero_022h.bundle` | `files\yoo\Default\BundleFiles\9a\9ad9407b5dd391fc88f81e2999e7494f\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalRole` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,GalRole` | - |
| 2 | 1 | `GalRole/pnlAnchor` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 3 | 2 | `GalRole/pnlAnchor/spine` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.0)` | `RectTransform,CanvasRenderer,SkeletonGraphic,SkeletonUtility,SkeletonGraphicRenderTexture` | - |
| 4 | 3 | `GalRole/pnlAnchor/spine/@customRenderRect` | Y | `pos(0.0,0.0) size(4096.0,4096.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
