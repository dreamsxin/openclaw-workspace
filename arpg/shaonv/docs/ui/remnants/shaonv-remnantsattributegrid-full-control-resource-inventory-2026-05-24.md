# RemnantsAttributeGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsAttributeGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsAttributeGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsattributegrid.bundle` / `files\yoo\Default\BundleFiles\e2\e221961764afc20c769e0902a8a0f2db\__data`
- 节点数：`3`。
- Image/Text/Button：`1` / `2` / `0`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_35` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_35.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsAttributeGrid` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RemnantsAttributeGrid` | Image:common_img_35 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 2 | 1 | `RemnantsAttributeGrid/txtTitle` | Y | `pos(13.0,0.0) size(160.0,30.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"阵营攻击" |
| 3 | 1 | `RemnantsAttributeGrid/txtValue` | Y | `pos(-13.0,0.0) size(160.0,30.0)` | `1.0,0.5->1.0,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"9999" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
