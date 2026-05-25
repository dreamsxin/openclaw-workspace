# RemnantsTypeGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsTypeGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsTypeGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantstypegrid.bundle` / `files\yoo\Default\BundleFiles\c0\c08f83f57f1aa4f4d29153bd1356b3f2\__data`
- 节点数：`5`。
- Image/Text/Button：`3` / `2` / `1`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `2`，未解析 `1`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsTypeGrid` | Y | `pos(0.0,0.0) size(172.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,RemnantsTypeGrid,Button,CanvasRenderer,Image` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `RemnantsTypeGrid/imgUnSelect` | Y | `pos(0.0,0.0) size(172.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.00 |
| 3 | 2 | `RemnantsTypeGrid/imgUnSelect/txtUnSelect` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"主战（1/3)" |
| 4 | 1 | `RemnantsTypeGrid/imgSelect` | Y | `pos(0.0,0.0) size(172.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=1933107396982301870 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 5 | 2 | `RemnantsTypeGrid/imgSelect/txtSelect` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"主战（1/3)" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
