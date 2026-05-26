# PrayerView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `PrayerView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_prayer_prayerview.bundle` / `files\yoo\Default\BundleFiles\93\933564e0036934b0e071db546bebb5be\__data`
- 节点数：`4`。
- Image/Text/Button：`1` / `0` / `0`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `PrayerView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,PrayerView` | - |
| 2 | 1 | `PrayerView/imgBg` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 3 | 1 | `PrayerView/pnlContent` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 4 | 1 | `PrayerView/tabPrayer` | Y | `pos(164.0,14.0) size(230.0,510.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
