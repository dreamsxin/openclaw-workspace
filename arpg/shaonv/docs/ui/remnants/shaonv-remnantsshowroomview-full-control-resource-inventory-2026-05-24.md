# RemnantsShowRoomView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsShowRoomView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsShowRoomView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsshowroomview.bundle` / `files\yoo\Default\BundleFiles\1f\1fe2116ba740ae061a3767eb4dfb4bf3\__data`
- 节点数：`6`。
- Image/Text/Button：`4` / `0` / `2`。
- Image 解析：外部 Sprite `4`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Remnants_bg_01` | 2 | `Assets/Game/RawAssets/Sprite/BackGround/Remnants_bg_01.png` | `assets_game_rawassets_sprite_background_remnants_bg_01.bundle` | `78bfef76a153b86673775025d5919d84.bundle`<br>`files\yoo\Default\BundleFiles\78\78bfef76a153b86673775025d5919d84\__data` | external CAB-4a87eaee50d71cf83fefcc89956df6e8 |
| `common_img_126` | 2 | `Assets/Game/RawAssets/Sprite/Common/common_img_126.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-0d5731a6a534bfedecdb443e393185d2` | `-` | `-` |
| 2 | `CAB-0c2ea3c22537e010c1266669a597166b` | `assets_game_rawassets_prefabs_ui_remnants_remnantsshowroomgrid.bundle` | `files\yoo\Default\BundleFiles\a8\a8317523e4797dc91eda1970ab21c07b\__data` |
| 3 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 4 | `CAB-4a87eaee50d71cf83fefcc89956df6e8` | `assets_game_rawassets_sprite_background_remnants_bg_01.bundle` | `files\yoo\Default\BundleFiles\78\78bfef76a153b86673775025d5919d84\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsShowRoomView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,RemnantsShowRoomView,Animator` | - |
| 2 | 1 | `RemnantsShowRoomView/Image` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Remnants_bg_01 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_01.bundle |
| 3 | 1 | `RemnantsShowRoomView/evRoom` | Y | `pos(0.0,0.0) size(1373.0,580.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,EnhancedScroller,RectMask2D,CanvasGroup` | - |
| 4 | 1 | `RemnantsShowRoomView/Image_mask` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:Remnants_bg_01 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_01.bundle |
| 5 | 1 | `RemnantsShowRoomView/btnLeft` | Y | `pos(52.0,0.0) size(94.0,66.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,Button,CanvasGroup` | Image:common_img_126 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 6 | 1 | `RemnantsShowRoomView/btnRight` | Y | `pos(-52.0,0.0) size(94.0,66.0)` | `1.0,0.5->1.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,Button,CanvasGroup` | Image:common_img_126 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
