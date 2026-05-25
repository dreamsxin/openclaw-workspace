# RemnantsChooseView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsChooseView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsChooseView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantschooseview.bundle` / `files\yoo\Default\BundleFiles\70\709b94fc9974abf2075ee35ba15629e1\__data`
- 节点数：`5`。
- Image/Text/Button：`3` / `1` / `1`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_bg_07` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/common_bg_07.png` | `assets_game_rawassets_sprite_background_common_bg_07.bundle` | `134c6b09a037418ea9b7807ca337929e.bundle`<br>`files\yoo\Default\UnpackBundleFiles\13\134c6b09a037418ea9b7807ca337929e\__data` | external CAB-682af34e9b388bbf7528a8a5655b0963 |
| `common_btn_16` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_16.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 3 | `CAB-682af34e9b388bbf7528a8a5655b0963` | `assets_game_rawassets_sprite_background_common_bg_07.bundle` | `files\yoo\Default\UnpackBundleFiles\13\134c6b09a037418ea9b7807ca337929e\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsChooseView` | Y | `pos(0.0,0.0) size(1034.0,517.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,RemnantsChooseView` | - |
| 2 | 1 | `RemnantsChooseView/Image` | Y | `pos(0.0,0.0) size(1190.0,610.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_bg_07 [Simple] -> assets_game_rawassets_sprite_background_common_bg_07.bundle |
| 3 | 2 | `RemnantsChooseView/Image/Text` | Y | `pos(94.0,-33.5) size(120.0,25.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=30):"更换遗器" |
| 4 | 2 | `RemnantsChooseView/Image/btnClose` | Y | `pos(-39.0,-36.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_16 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 5 | 2 | `RemnantsChooseView/Image/svList` | Y | `pos(0.0,-13.0) size(1148.0,468.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,ScrollRect,GridScroller,RectMask2D` | Image:none [Sliced], a=0.00 |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
