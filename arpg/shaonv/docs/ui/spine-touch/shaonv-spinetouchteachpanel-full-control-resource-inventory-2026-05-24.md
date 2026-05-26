# SpineTouchTeachPanel 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `SpineTouchTeachPanel`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/SpineTouch/Teach/SpineTouchTeachPanel.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_spinetouch_teach_spinetouchteachpanel.bundle` / `resources\assets\yoo\Default\3d3dd9c2b5fbc97840d5b40b410d2834.bundle`
- 节点数：`3`。
- Image/Text/Button：`2` / `0` / `0`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `2`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-eafcdf54b9fbfba5b913c8c8609f4d69` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `SpineTouchTeachPanel` | Y | `pos(0.0,0.0) size(500.0,150.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,SpineTouchTeachInfoPanel` | Image:external fid=2 pid=-8985724238309873835 cab=CAB-eafcdf54b9fbfba5b913c8c8609f4d69 [Simple] |
| 2 | 1 | `SpineTouchTeachPanel/Image` | Y | `pos(-176.7,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=1618372601403119750 cab=CAB-eafcdf54b9fbfba5b913c8c8609f4d69 [Simple] |
| 3 | 1 | `SpineTouchTeachPanel/txtInfo` | Y | `pos(49.7,0.0) size(316.8,64.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,TextMeshProUGUI` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
