# ActivityMainView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `ActivityMainView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Activity/ActivityMainView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_activity_activitymainview.bundle` / `files\yoo\Default\BundleFiles\57\57d25035fbd2fefeff6e4c6cad80e2ae\__data`
- 节点数：`6`。
- Image/Text/Button：`2` / `1` / `0`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `bag_bg_01` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/bag_bg_01.png` | `assets_game_rawassets_sprite_background_bag_bg_01.bundle` | `ecd06c7cd242d7c4f23efe8e53893b99.bundle`<br>`files\yoo\Default\BundleFiles\ec\ecd06c7cd242d7c4f23efe8e53893b99\__data` | external CAB-2a1dfe71948b80ff24cb58a23df40566 |
| `common_img_59` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_59.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-2a1dfe71948b80ff24cb58a23df40566` | `assets_game_rawassets_sprite_background_bag_bg_01.bundle` | `files\yoo\Default\BundleFiles\ec\ecd06c7cd242d7c4f23efe8e53893b99\__data` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-0d5731a6a534bfedecdb443e393185d2` | `-` | `-` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `ActivityMainView` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ActivityMainView,Animator` | - |
| 2 | 1 | `ActivityMainView/imgBg` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:bag_bg_01 [Simple] -> assets_game_rawassets_sprite_background_bag_bg_01.bundle |
| 3 | 2 | `ActivityMainView/imgBg/imgNo` | Y | `pos(0.0,0.0) size(250.0,250.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_59 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 4 | 2 | `ActivityMainView/imgBg/Text` | Y | `pos(0.0,0.0) size(287.4,56.1)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"暂无活动" |
| 5 | 1 | `ActivityMainView/pnlActivity` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 6 | 1 | `ActivityMainView/tabActivity` | Y | `pos(140.0,-430.5) size(230.0,639.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView,CanvasGroup` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
