# GalToastView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalToastView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalToastView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galtoastview.bundle` / `files\yoo\Default\BundleFiles\9a\9ad540a9894ff20ae5be482d5bccb4d6\__data`
- 节点数：`3`。
- Image/Text/Button：`1` / `0` / `0`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-4c77286d6fa600df61302b570f6c0e9a` | `assets_game_rawassets_prefabs_ui_gal_galtoastgrid.bundle` | `files\yoo\Default\BundleFiles\5e\5e9e6fad82a19dcd5e5343cbb74b35ef\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalToastView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,GalToastView` | Image:none [Simple], a=0.00 |
| 2 | 1 | `GalToastView/pnlShowArea` | Y | `pos(0.0,-275.0) size(486.0,0.0)` | `1.0,1.0->1.0,1.0 p(1.0,0.0)` | `RectTransform,VerticalLayoutGroup,ContentSizeFitter` | - |
| 3 | 1 | `GalToastView/pnlCycle` | N | `pos(0.0,-1226.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
