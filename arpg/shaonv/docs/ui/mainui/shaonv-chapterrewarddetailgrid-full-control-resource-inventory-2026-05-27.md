# ChapterRewardDetailGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `ChapterRewardDetailGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterRewardDetailGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_chapter_chapterrewarddetailgrid.bundle` / `files\yoo\Default\BundleFiles\7e\7e9bd0269b4061b6c4e5becb05fc5cfb\__data`
- 节点数：`7`。
- Image/Text/Button：`4` / `2` / `0`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_44` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_44.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_46` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_46.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_88` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_88.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `ChapterRewardDetailGrid` | Y | `pos(0.0,0.0) size(980.0,110.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ChapterRewardDetailGrid` | - |
| 2 | 1 | `ChapterRewardDetailGrid/Image` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_44 [Sliced] -> assets_game_rawassets_sprite_common.bundle |
| 3 | 1 | `ChapterRewardDetailGrid/txtChapter` | Y | `pos(-272.5,0.0) size(-857.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"通关第1章节" |
| 4 | 1 | `ChapterRewardDetailGrid/txtTip` | N | `pos(-225.0,-28.0) size(406.7,33.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=24):"通关第1章节" |
| 5 | 1 | `ChapterRewardDetailGrid/svReward` | Y | `pos(32.0,0.0) size(400.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RectMask2D,ScrollRectEx,GridScroller` | Image:none [Sliced], a=0.00 |
| 6 | 1 | `ChapterRewardDetailGrid/imgMask` | Y | `pos(356.0,0.0) size(70.0,70.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_88 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 7 | 1 | `ChapterRewardDetailGrid/Image` | Y | `pos(-432.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_46 [Simple] -> assets_game_rawassets_sprite_common.bundle |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
