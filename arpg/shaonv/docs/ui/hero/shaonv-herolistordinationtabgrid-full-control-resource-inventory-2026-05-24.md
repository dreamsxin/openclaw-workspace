# HeroListOrdinationTabGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `HeroListOrdinationTabGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListOrdinationTabGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_hero_herolistordinationtabgrid.bundle` / `files\yoo\Default\BundleFiles\74\74e0767f134b569c4935811d865b0e97\__data`
- 节点数：`3`。
- Image/Text/Button：`1` / `2` / `1`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `HeroListOrdinationTabGrid` | Y | `pos(0.0,0.0) size(111.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,HeroListOrdinationTabGrid` | Image:none [Sliced], a=0.00<br>Button |
| 2 | 1 | `HeroListOrdinationTabGrid/txtNormal` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"战力" |
| 3 | 1 | `HeroListOrdinationTabGrid/txtHighLight` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"战力" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
