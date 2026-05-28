# HeroListHorListGrid 全控件与资源清单

生成时间：2026-05-28。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `HeroListHorListGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListHorListGrid.prefab`
- Prefab bundle: `herolisthorlistgrid_source_override.bundle` / `files/yoo/Default/BundleFiles/61/61200888b6f33b05423aa04e86cb11f7/__data`
- 节点数：`1`。
- Image/Text/Button：`0` / `0` / `0`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `HeroListHorListGrid` | Y | `pos(0.0,0.0) size(978.0,296.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HeroListHorListGrid` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
