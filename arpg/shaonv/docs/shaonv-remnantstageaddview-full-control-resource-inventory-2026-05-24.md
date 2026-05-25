# RemnantStageAddView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantStageAddView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantStageAddView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantstageaddview.bundle` / `files\yoo\Default\BundleFiles\27\274f8a76edbe461a932f4846f2a3b4e1\__data`
- 节点数：`5`。
- Image/Text/Button：`2` / `1` / `1`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_bg_03` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/common_bg_03.png` | `assets_game_rawassets_sprite_background_common_bg_03.bundle` | `bb11902dbcc9ffec46423a368d36a6f5.bundle`<br>`resources\assets\yoo\Default\bb11902dbcc9ffec46423a368d36a6f5.bundle` | external CAB-16bc41bb8126b782e8e1227175bfb3fc |
| `common_btn_16` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_16.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-16bc41bb8126b782e8e1227175bfb3fc` | `assets_game_rawassets_sprite_background_common_bg_03.bundle` | `resources\assets\yoo\Default\bb11902dbcc9ffec46423a368d36a6f5.bundle` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantStageAddView` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,RemnantStageAddView` | - |
| 2 | 1 | `RemnantStageAddView/Image` | Y | `pos(0.0,0.0) size(788.0,408.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_bg_03 [Simple] -> assets_game_rawassets_sprite_background_common_bg_03.bundle |
| 3 | 2 | `RemnantStageAddView/Image/Text` | Y | `pos(-301.0,171.5) size(-668.0,-383.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=30):"阶段加成" |
| 4 | 2 | `RemnantStageAddView/Image/btnClose` | Y | `pos(356.0,169.0) size(60.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_16 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 5 | 2 | `RemnantStageAddView/Image/svList` | Y | `pos(0.0,-27.5) size(744.0,309.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
