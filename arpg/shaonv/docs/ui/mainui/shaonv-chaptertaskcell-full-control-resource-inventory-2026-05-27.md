# ChapterTaskCell 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `ChapterTaskCell`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterTaskCell.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_chapter_chaptertaskcell.bundle` / `files\yoo\Default\BundleFiles\c5\c5ec5ead35fde57f644ebdf1b99e1442\__data`
- 节点数：`12`。
- Image/Text/Button：`6` / `3` / `1`。
- Image 解析：外部 Sprite `5`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_btn_02` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_02.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_88` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_88.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `task_img_02` | 1 | `Assets/Game/RawAssets/Sprite/Task/task_img_02.png` | `assets_game_rawassets_sprite_task.bundle` | `16317ad091fe49057dc1e5ab10203a9c.bundle`<br>`files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` | external CAB-6f622e0fc6cdf1596810cdfd307887d2 |
| `task_img_03` | 1 | `Assets/Game/RawAssets/Sprite/Task/task_img_03.png` | `assets_game_rawassets_sprite_task.bundle` | `16317ad091fe49057dc1e5ab10203a9c.bundle`<br>`files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` | external CAB-6f622e0fc6cdf1596810cdfd307887d2 |
| `task_img_18` | 1 | `Assets/Game/RawAssets/Sprite/Task/task_img_18.png` | `assets_game_rawassets_sprite_task_task_img_18.bundle` | `51d765b0fc5fc5404f915a4968c8d92e.bundle`<br>`files\yoo\Default\BundleFiles\51\51d765b0fc5fc5404f915a4968c8d92e\__data` | external CAB-9f50589f4d780eeeacf6a082c7c78ae4 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-9f50589f4d780eeeacf6a082c7c78ae4` | `assets_game_rawassets_sprite_task_task_img_18.bundle` | `files\yoo\Default\BundleFiles\51\51d765b0fc5fc5404f915a4968c8d92e\__data` |
| 2 | `CAB-6f622e0fc6cdf1596810cdfd307887d2` | `assets_game_rawassets_sprite_task.bundle` | `files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `ChapterTaskCell` | Y | `pos(0.0,0.0) size(786.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ChapterTaskCell` | - |
| 2 | 1 | `ChapterTaskCell/Image` | Y | `pos(0.0,0.0) size(786.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:task_img_18 [Simple] -> assets_game_rawassets_sprite_task_task_img_18.bundle |
| 3 | 1 | `ChapterTaskCell/txtRes` | Y | `pos(-139.5,21.0) size(-425.5,-102.0)` | `0.0,0.0->1.0,1.0 p(0.4,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"2名星灵达到40级" |
| 4 | 1 | `ChapterTaskCell/sldProgress` | Y | `pos(-214.0,-26.0) size(-482.0,-104.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,Slider` | - |
| 5 | 2 | `ChapterTaskCell/sldProgress/Image` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:task_img_03 [Simple] -> assets_game_rawassets_sprite_task.bundle |
| 6 | 2 | `ChapterTaskCell/sldProgress/Fill Area` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 7 | 3 | `ChapterTaskCell/sldProgress/Fill Area/Fill` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:task_img_02 [Sliced] -> assets_game_rawassets_sprite_task.bundle |
| 8 | 1 | `ChapterTaskCell/txtNum` | Y | `pos(-21.5,-24.0) size(34.0,16.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"<color=#594AE4>2</color>/2" |
| 9 | 1 | `ChapterTaskCell/svReward` | Y | `pos(69.0,0.0) size(84.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RectMask2D,ScrollRectEx,GridScroller` | Image:none [Sliced], a=0.00 |
| 10 | 1 | `ChapterTaskCell/btnLing` | N | `pos(259.0,0.2) size(216.0,57.6)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_02 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 11 | 2 | `ChapterTaskCell/btnLing/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=24):"领取" |
| 12 | 1 | `ChapterTaskCell/imgReceive` | Y | `pos(257.0,0.6) size(70.0,70.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_88 [Simple] -> assets_game_rawassets_sprite_common.bundle |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
