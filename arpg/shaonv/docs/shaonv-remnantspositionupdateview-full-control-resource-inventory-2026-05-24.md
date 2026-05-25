# RemnantsPositionUpdateView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsPositionUpdateView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsPositionUpdateView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantspositionupdateview.bundle` / `files\yoo\Default\BundleFiles\8a\8a20728b993151ee6d504d369ed130bf\__data`
- 节点数：`4`。
- Image/Text/Button：`1` / `0` / `0`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Remnants_bg_02` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/Remnants_bg_02.png` | `assets_game_rawassets_sprite_background_remnants_bg_02.bundle` | `4b188373c3ab3d6ca5c6f9ccda420646.bundle`<br>`files\yoo\Default\BundleFiles\4b\4b188373c3ab3d6ca5c6f9ccda420646\__data` | external CAB-7789a59fc2aa80086d4185032e7cbbff |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-0d5731a6a534bfedecdb443e393185d2` | `-` | `-` |
| 2 | `CAB-7789a59fc2aa80086d4185032e7cbbff` | `assets_game_rawassets_sprite_background_remnants_bg_02.bundle` | `files\yoo\Default\BundleFiles\4b\4b188373c3ab3d6ca5c6f9ccda420646\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsPositionUpdateView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,RemnantsPositionUpdateView,Animator` | - |
| 2 | 1 | `RemnantsPositionUpdateView/imgBg` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Remnants_bg_02 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_02.bundle |
| 3 | 1 | `RemnantsPositionUpdateView/pnlContent` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 4 | 1 | `RemnantsPositionUpdateView/tabPage` | Y | `pos(103.0,187.5) size(145.0,135.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView,CanvasGroup` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
