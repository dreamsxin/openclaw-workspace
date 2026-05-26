# LotteryDrawStageView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `LotteryDrawStageView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawStageView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_lotterydraw_lotterydrawstageview.bundle` / `files\yoo\Default\BundleFiles\b8\b86a0d80160c66da3399ffacdd1e6441\__data`
- 节点数：`38`。
- Image/Text/Button：`30` / `1` / `1`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `29`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_115` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_115.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-4978250f06ec6dea5048e4431e7a4eee` | `-` | `-` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `LotteryDrawStageView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,LotteryDrawStageView` | - |
| 2 | 1 | `LotteryDrawStageView/pnlAnim` | N | `pos(0.0,0.0) size(1334.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Sliced], a=0.00 |
| 3 | 2 | `LotteryDrawStageView/pnlAnim/anim` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Animator` | - |
| 4 | 3 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel` | Y | `pos(0.0,-26.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 5 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/menbgImg` | Y | `pos(0.0,26.0) size(1680.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 6 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/bgImg` | Y | `pos(0.0,0.0) size(1670.0,816.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 7 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/lizi` | N | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,ParticleSystem,ParticleSystemRenderer` | - |
| 8 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/bgLeftImg` | Y | `pos(-621.5,0.0) size(357.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 9 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/bgRightImg` | Y | `pos(673.0,1.0) size(254.0,748.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 10 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/bgMidImg` | Y | `pos(40.0,1.0) size(1100.0,748.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 11 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing01` | Y | `pos(0.0,0.0) size(77.0,77.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 12 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing02` | Y | `pos(0.0,0.0) size(130.0,125.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 13 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing03` | Y | `pos(0.0,0.0) size(155.0,175.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 14 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing04` | Y | `pos(0.0,0.0) size(213.0,212.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 15 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing05` | Y | `pos(0.0,0.0) size(275.0,273.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 16 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing06` | Y | `pos(0.0,0.0) size(447.0,453.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 17 | 4 | `LotteryDrawStageView/pnlAnim/anim/LotteryDrawAnim_Panel/InnerRing07` | Y | `pos(0.0,0.0) size(499.0,501.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 18 | 2 | `LotteryDrawStageView/pnlAnim/img1` | Y | `pos(347.0,196.0) size(144.0,136.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 19 | 2 | `LotteryDrawStageView/pnlAnim/img2` | Y | `pos(431.0,-15.0) size(128.0,130.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 20 | 2 | `LotteryDrawStageView/pnlAnim/img3` | Y | `pos(319.0,-189.5) size(122.0,136.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 21 | 2 | `LotteryDrawStageView/pnlAnim/img4` | Y | `pos(-363.0,-202.0) size(160.0,131.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 22 | 2 | `LotteryDrawStageView/pnlAnim/img5` | Y | `pos(-460.0,-5.5) size(136.0,136.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 23 | 2 | `LotteryDrawStageView/pnlAnim/img6` | Y | `pos(-332.0,198.0) size(136.0,140.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 24 | 2 | `LotteryDrawStageView/pnlAnim/dragMoving` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Drag` | Image:none [Sliced], a=0.00 |
| 25 | 1 | `LotteryDrawStageView/pnlGuide` | N | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,Animator` | - |
| 26 | 2 | `LotteryDrawStageView/pnlGuide/jixieshouImg` | Y | `pos(0.0,0.0) size(136.0,107.0)` | `0.5,0.5->0.5,0.5 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 27 | 3 | `LotteryDrawStageView/pnlGuide/jixieshouImg/jiantouImg` | Y | `pos(-68.0,50.0) size(136.0,107.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 28 | 3 | `LotteryDrawStageView/pnlGuide/jixieshouImg/jiantouImg01` | Y | `pos(-24.6,74.7) size(136.0,107.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 29 | 3 | `LotteryDrawStageView/pnlGuide/jixieshouImg/jiantouImg02` | Y | `pos(18.9,99.5) size(136.0,107.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 30 | 3 | `LotteryDrawStageView/pnlGuide/jixieshouImg/jiantouImg03` | Y | `pos(62.3,124.2) size(136.0,107.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 31 | 3 | `LotteryDrawStageView/pnlGuide/jixieshouImg/jiantouImg04` | Y | `pos(105.8,149.0) size(136.0,107.0)` | `0.5,0.5->0.5,0.5 p(1.0,0.5)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 32 | 2 | `LotteryDrawStageView/pnlGuide/InnerRing03` | Y | `pos(337.7,198.8) size(155.0,175.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,UIAdditiveEffect` | Image:none [Simple] |
| 33 | 1 | `LotteryDrawStageView/pnlVideo` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Sliced], a=0.00 |
| 34 | 2 | `LotteryDrawStageView/pnlVideo/rawImg` | Y | `pos(0.0,0.0) size(1670.0,1670.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,RawImage` | - |
| 35 | 2 | `LotteryDrawStageView/pnlVideo/video` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,VideoPlayer` | - |
| 36 | 2 | `LotteryDrawStageView/pnlVideo/pressLong` | Y | `pos(0.0,0.0) size(-336.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,LongPressOrClickEventTrigger` | Image:none [Sliced], a=0.00 |
| 37 | 2 | `LotteryDrawStageView/pnlVideo/btnSkip` | Y | `pos(-97.1,-43.0) size(138.0,52.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_img_115 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 38 | 3 | `LotteryDrawStageView/pnlVideo/btnSkip/txtSkip` | Y | `pos(25.0,0.0) size(40.0,20.0)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"跳过" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
