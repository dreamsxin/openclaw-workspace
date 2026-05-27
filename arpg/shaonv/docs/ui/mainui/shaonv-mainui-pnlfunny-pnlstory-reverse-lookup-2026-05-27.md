# MainUI `pnlFunny` / `pnlStory` 反查记录

生成时间：2026-05-27。

本文聚焦 `MainUIView.prefab` 中 `pnlFunny`、`pnlStory`、`btnHarvest`、`btnStory`、`btnChapterInfo` 三条主界面右下功能链，目标是把：

1. prefab 节点结构  
2. 原始 sprite / red dot 资源  
3. `MainUIView` 热更 IL 初始化逻辑  

串成一条可复用的恢复路线，避免后续继续把 `塵世探秘`、挂机收益和章节奖励条混在一起。

## 结论摘要

- `pnlFunny` 是主界面右侧玩法入口总容器，不等于左侧活动区，也不等于单独的 `塵世探秘` 按钮。
- `pnlStory` 才是右下大号 `塵世探秘` 入口，底图为 `mainui_txt_01`，其上叠加进度条 `mainui_img_34`、主标题文本、挂机宝箱 `btnHarvest`、透明点击层 `btnStory`。
- `btnHarvest` 对应挂机收益入口，资源键和红点 key 都走 `Expedition.Hook.84317` 这条线。
- `btnChapterInfo` 是 `pnlStory` 上方的章节奖励预览条，不是右下大按钮本体；它对应章节任务入口 `ChapterTask.ChapterTaskEnter.32541`。
- `btnStory` 与 `btnChapterInfo` 都会导向塵世探秘相关系统，但职责不同：前者是主入口，后者是奖励预览条。

## 1. Prefab 结构

依据：

- [MainUIView.layout.json](D:/work/openclaw-workspace/arpg/shaonv/reverse-output/godot-layout-inspect-self/MainUIView.layout.json)
- [shaonv-mainui-full-control-resource-inventory-2026-05-24.md](D:/work/openclaw-workspace/arpg/shaonv/docs/ui/mainui/shaonv-mainui-full-control-resource-inventory-2026-05-24.md)

关键节点：

- `MainUIView/pnlAdapter/pnlFunny`
  - 全屏锚点容器，承载右侧玩法、右上商店列、菜单按钮、右下 `塵世探秘` 区。
- `MainUIView/pnlAdapter/pnlFunny/pnlStory`
  - `pos(-60,19) size(278,98)`
  - `Image: mainui_txt_01`
  - `UIShiny`
- `MainUIView/pnlAdapter/pnlFunny/pnlStory/Image`
  - `pos(-84,-15) size(156,34)`
  - `Image: mainui_img_34`
  - 子文本 `txtStory`
- `MainUIView/pnlAdapter/pnlFunny/pnlStory/Text`
  - `pos(49,1) size(128,46)`
  - `Text(fs=32): "尘世探秘11"`
  - 即右下主标题文本，运行时本地化为 `塵世探秘`
- `MainUIView/pnlAdapter/pnlFunny/pnlStory/btnHarvest`
  - `pos(67,1) size(106,106)`
  - `Image: mainui_img_18`
  - 子节点 `imgHookTime -> mainui_img_08`
  - 子文本 `txtHookTime`
- `MainUIView/pnlAdapter/pnlFunny/pnlStory/btnStory`
  - `pos(51,0) size(132,98.7)`
  - `Image:none alpha=0`
  - 透明 Button，覆盖主故事区点击热区
- `MainUIView/pnlAdapter/btnChapterInfo`
  - `pos(-34,150) size(276,100)`
  - `Image: mainui_img_35`
  - 子节点 `txtChapterTitle`、`svChapterReward`、`@pnlRd`

## 2. 原始资源映射

### `pnlStory`

- `mainui_txt_01`
  - `Assets/Game/RawAssets/Sprite/MainUI/mainui_txt_01.png`
  - `pnlStory` 主底图
- `mainui_img_34`
  - `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_34.png`
  - `pnlStory/Image` 进度条底
- `mainui_img_18`
  - `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_18.png`
  - `btnHarvest` 宝箱/挂机按钮
- `mainui_img_08`
  - `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_08.png`
  - `btnHarvest/imgHookTime` 挂机时间底板

### `pnlFunnyContent`

- `mainui_txt_03`
  - `btnArena`
- `mainui_txt_06`
  - `btnPrayer`
- `mainui_txt_02`
  - `btnAdventure`
- `mainui_txt_05`
  - `btnDraw`
- `mainui_img_36`
  - `btnAdventure/btnJumpAutoFight`

### `btnChapterInfo`

- `mainui_img_35`
  - `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_35.png`
  - 奖励预览条底图
- `svChapterReward`
  - 运行时实例化 `RewardGrid`
  - 不是静态三格图，而是 `GridScroller`

## 3. IL 初始化逻辑

依据：

- [MainUIView.il.txt](D:/work/openclaw-workspace/arpg/shaonv/reverse-output/managed/Assembly-CSharp-ui-callgraph/MainUIView.il.txt)
- [target-strings.csv](D:/work/openclaw-workspace/arpg/shaonv/reverse-output/managed/Assembly-CSharp-ui-callgraph/target-strings.csv)

### `InitPnlFunny()`

`MainUIView::InitPnlFunny()` 为右侧玩法区注册点击和订阅：

- `btnStory`
  - 绑定 `MainUIView/<>c::<InitPnlFunny>b__79_0()`
  - 点击延时参数是 `1`
- `btnHarvest`
  - 绑定 `MainUIView/<>c::<InitPnlFunny>b__79_1()`
  - 点击延时参数是 `0.3`
- `btnAdventure`
  - 绑定 `MainUIView/<>c::<InitPnlFunny>b__79_2()`
- `btnArena`
  - 绑定 `MainUIView/<>c::<InitPnlFunny>b__79_3()`
- `btnJumpAutoFight`
  - 绑定 `MainUIView/<>c::<InitPnlFunny>b__79_13()`

同一方法还订阅了两条和挂机直接相关的事件：

- `ReceiveHookReward`
  - 回调 `MainUIView/<>c__DisplayClass79_0::<InitPnlFunny>b__14(EventParam)`
- `RefreshHookTime`
  - 回调 `MainUIView/<>c__DisplayClass79_0::<InitPnlFunny>b__15(EventParam)`

以及：

- `PauseAutoFight`
  - 回调 `MainUIView::RefreshAutoFight(EventParam)`

### `InitPnlTask()`

`MainUIView::InitPnlTask()` 专门负责 `btnChapterInfo`：

- `btnChapterInfo`
  - 绑定 `MainUIView/<>c::<InitPnlTask>b__70_0()`
- 订阅事件：
  - `RefreshChapterTask`
  - `GetChapterTaskReward`
  - `ChapterComplete`
  - 三者都回调 `MainUIView::UpdateChapterTask(EventParam)`

### `UpdateChapterTask()`

`UpdateChapterTask` 做了三件直接相关的事：

1. 从 `ChapterTaskModel` 取 `GetChapterRSInfo()`，写入 `_chapterRewards`
2. 配置 `svChapterReward` 为 `GridScroller`
3. 更新 `txtChapterTitle`

IL 里确认章节标题格式使用本地化 key：

- `UI1000026`

它会拼入：

- 章节 id
- 章节名
- 章节进度

同时当章节不可显示时，会对 `btnChapterInfo` 调 `SetActive(false)`。

### `SetUIInfo()`

`SetUIInfo()` 更新 `pnlStory` 当前关卡文案：

- 先从 `ExpeditionModel.GetCurStageId()` 取得当前 stage
- 经 `ExpeditionStaticItem.name -> Scx.Lang.Get(...)` 得到当前关卡名
- 再使用本地化 key `UI1000015`
- 最终写入 `txtStory`

所以：

- `pnlStory/Image/txtStory` 是“当前推进/关卡进度”文案
- `pnlStory/Text` 是大标题 `塵世探秘`

## 4. Red Dot / 功能键

`InitRedDot()` 里这两条是最关键的：

- `btnHarvest`
  - `Expedition.Hook.84317`
- `btnChapterInfo`
  - `ChapterTask.ChapterTaskEnter.32541`

说明两者在原游戏模型里是两套独立入口：

- `btnHarvest`：挂机收益/远征收获
- `btnChapterInfo`：章节任务入口

这也解释了为什么不能把 `btnChapterInfo` 当作右下大故事按钮。

## 5. 恢复界面时应遵守的边界

- `pnlStory` 与 `btnChapterInfo` 必须分开恢复。
- `btnStory` 是透明点击层，不能用它的“无图”误判为缺资源。
- `btnHarvest` 的 `imgHookTime` 必须保留，因为它是 prefab 明确存在的视觉层。
- `btnChapterInfo` 的奖励区应优先朝 `GridScroller` 结构恢复，而不是长期停留在静态三格。
- 如果恢复真实打开链路，应优先改为：
  - `btnStory` / `btnChapterInfo`
  - `ChangeToOther` 过渡
  - `ExpeditionMainView`
  - `ExpeditionMapView` / `ChapterTaskView`
  其中 `ChapterTaskView` 更适合作为章节任务 / 奖励子面板，而不是过渡页后的首屏。

## 6. 对当前 Godot MVP 的直接启示

- `home_screen.gd` 中右下 `塵世探秘` 主入口应继续以 `pnlStory` 为准。
- `btnChapterInfo` 应只承担“章节奖励预览条 + 进入章节界面”的职责，不应和挂机收益合并。
- `btnHarvest` 应单独维持“收取挂机收益”的逻辑和红点提示。
- `ChangeToOther.prefab` 更像 `btnStory/btnChapterInfo` 到 `ExpeditionMainView` 之间的真实过渡壳，不应再误认成 `ChapterTaskView` 本体。
