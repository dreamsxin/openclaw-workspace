# MainUI Manifest 反查与还原复查记录

生成时间：2026-05-27。

本文按 `docs/ui/shaonv-yooasset-manifest-reverse-dependency-guide-2026-05-27.md` 复查主界面，并对照旧文档 `docs/ui/mainui/shaonv-mainui-godot-gap-analysis-2026-05-25.md` 与当前 `standalone/godot-mvp/scripts/screens/home_screen.gd`。结论只记录可由 prefab 清单、manifest physical 和 Godot 落地资源共同证实的状态；缺运行时数据、粒子或 Spine 的项目继续标为简化/未完整还原。

## 反查结论

| 资源 | asset 地址 | physical | Godot 落地 | 当前状态 |
|---|---|---|---|---|
| `MainUIView.prefab` | `Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab` | 是 | - | 原始 prefab 可导出，清单 212 节点。 |
| `mainui_img_02` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_02.png` | 是 | 是 | `pnlPlayerInfo` 玩家信息框，已使用。 |
| `mainui_img_03` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_03.png` | 是 | 是 | `imgHeadBg` 头像环，已使用。 |
| `mainui_img_04` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_04.png` | 是 | 是 | `imgExp` 经验环，已使用。 |
| `mainui_img_06` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_06.png` | 是 | 是 | `pnlDotsContainer` 当前选中轮播点，已用于商业 banner dots。 |
| `mainui_img_07` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_07.png` | 是 | 是 | `pnlDotsContainer` 未选中轮播点，已用于商业 banner dots。 |
| `mainui_img_08` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_08.png` | 是 | 是 | `btnHarvest/imgHookTime` 挂机时间底板，已补入。 |
| `mainui_img_09` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_09.png` | 是 | 是 | `TopResGrid/imgBg` 200x40 资源项背板，已用于 Godot 顶部资源项。 |
| `mainui_img_32` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_32.png` | 是 | 是 | `txtPower` 前战力图标，已使用。 |
| `mainui_img_35` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_35.png` | 是 | 是 | `btnChapterInfo` 章节/奖励底板，已使用。 |
| `mainui_img_36` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_36.png` | 是 | 是 | `btnAdventure/btnJumpAutoFight` 自动挑战条，已移到冒险入口上方。 |
| `mainui_img_44` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_44.png` | 是 | 是 | `pnlAdapter/Image` 全屏叠加层，已弱透明叠加。 |
| `mainui_img_45` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_45.png` | 是 | 是 | MainUI 奖励框资源，已用于章节奖励静态三格。 |
| `mainui_btn_14` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_btn_14.png` | 是 | 是 | `LimitIconView.btnIcon` 默认图标，商业活动网格已用作默认入口图标。 |
| `hero_img_253` | `Assets/Game/RawAssets/Sprite/Hero/hero_img_253.png` | 是 | 是 | `irole/imgMask` 角色遮罩，已弱透明叠加。 |
| `hero_img_219` | `Assets/Game/RawAssets/Sprite/Hero/hero_img_219.png` | 是 | 是 | `irole/imgSpeak` 原 prefab 中 Active=N，当前不强行显示。 |
| `TopResGrid.prefab` | `Assets/Game/RawAssets/Prefabs/UI/Common/TopResGrid.prefab` | 是 | 简化 | 顶部资源栏单元格原始 200x40；当前为静态 `icon + number + plus`，未还原 ScrollRect/Mask。 |
| `ChapterTaskView.prefab` | `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterTaskView.prefab` | 是 | 简化 | 已按 layout 结构补出塵世探秘独立界面；背景、提示条、分割线、按钮已使用原始资源，角色奖励预览/特效层未完整还原。 |
| `ChapterTaskCell.prefab` | `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterTaskCell.prefab` | 是 | 简化 | 已导出 `task_img_18/03/02`、`common_btn_02`、`common_img_88` 并用于任务 cell；GridScroller/奖励滚动仍为静态。 |
| `ChapterRewardDetailView.prefab` | `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterRewardDetailView.prefab` | 是 | 简化 | 已导出 `common_bg_09/common_btn_16` 并补出奖励详情弹窗；列表滚动和真实奖励表仍为静态。 |

## 旧 Gap 复查

| 旧 gap 项 | prefab 节点 | 当前 Godot 复查 | 判定 |
|---|---|---|---|
| `irole/imgMask` 缺失 | `@WallpaperPanel/irole/imgMask` | `UI_HERO_MASK` 引用 `hero_img_253`，在 `draw_wallpaper()` 内绘制。 | 已修复，透明度按当前角色舞台适配。 |
| 全屏叠加层缺失 | `pnlAdapter/Image` | `UI_MAIN_FULLSCREEN_OVERLAY` 引用 `mainui_img_44`，在 `draw_fullscreen_overlay()` 内绘制。 | 已修复，作为弱透明全屏层。 |
| `imgHookTime` 缺失 | `btnHarvest/imgHookTime` | `UI_MAIN_HOOK_TIME_BG` 引用 `mainui_img_08`，在 `draw_story_harvest()` 内位于挂机时间文字下方。 | 已修复。 |
| `btnJumpAutoFight` 错位 | `btnAdventure/btnJumpAutoFight` | `UI_MAIN_AUTO_FIGHT` 已在 `draw_funny_content()` 中绘制到冒险按钮上方，并绑定自动战斗入口。 | 已修复。 |
| `@Question` 缺失 | `pnlGift/@Question` | 商业活动网格新增 `問卷 / 可領取` 项，使用 `mainui_btn_14` 默认图标。 | 已补默认入口；真实活动图标仍依赖运行时数据。 |
| `@BuryGift` 缺失 | `pnlGift/@BuryGift` | 商业活动网格新增 `埋點禮包` 项，使用 `mainui_btn_14` 默认图标。 | 已补默认入口；真实显隐仍依赖运行时数据。 |
| `@DiscountLimitGift` 缺失 | `pnlGift/@DiscountLimitGift` | 商业活动网格新增 `折扣禮包` 项，使用 `mainui_btn_14` 默认图标。 | 已补默认入口；折扣内容仍依赖运行时数据。 |
| `pnlDotsContainer` 缺失 | banner 指示点 | `draw_commercialization()` 绘制 3 个轮播点。 | 已简化补入，未实现轮播状态机。 |
| 顶部 `svRes` 不完整 | `@TopBar/svRes/Viewport/Content` | 当前资源项已使用 `TopResGrid/imgBg` 对应的 `mainui_img_09` 背板、真实物品图标、数量和加号，但不是完整 `TopResGrid` prefab 实例，也没有 ScrollRect/Mask。 | 仍为简化还原。 |

## 重点区域状态

### 顶部资源栏

`TopResGrid` 原始结构：

```text
TopResGrid 200x40
  imgBg 200x40
  imgIcon -5,1 50x50
  txtNum 27,0 130x40
  btnClick 200x40 inactive
  txtTitle 160x30 inactive
```

当前 `draw_top_bar()` 使用 manifest 已确认的 `mainui_img_09` 作为资源项背板，并使用 `draw_07.png`、`draw_05.png` 和本地数量绘制右上资源条。它比纯色条更接近 `TopResGrid` 的 200x40 单元格，但仍未完整复刻 `svRes` 的 1367x60 ScrollRect、Viewport/Mask、Content 和动态子实例。该项不能标为完整还原。

### 商业活动入口

当前 `draw_commercialization()` 保留 banner、轮播点、12 个常规活动入口以及 `@Question`、`@BuryGift`、`@DiscountLimitGift` 三个特殊入口。轮播点已使用 manifest 确认存在的 `mainui_img_06/07`。所有入口使用 prefab 清单中的 `mainui_btn_14` 默认图标，这符合 `LimitIconPanel` 运行时替换图标之前的默认状态。

仍简化项：`pnlShowoffContainer` 推广内容、真实活动显隐、活动剩余时间、折扣内容和运行时替换图标未还原。

### 底部导航

`pnlBottom` 已使用 `mainui_img_10`，分隔线使用 `mainui_img_11`，`btnGal` 使用 `mainui_btn_25` 并独立突出到底栏上方。底部 `btnPet/btnDevelop/btnTask` 的透明 `UISprite` 背板没有单独绘制，因为原清单中 alpha 为 0；文字按当前 MVP 功能入口显示。

仍简化项：`btnGal/@fx05` 粒子光效和额外点击响应区没有还原。

### 章节/聊天区

`btnChapterInfo` 使用 `mainui_img_35` 绘制章节奖励条，奖励格已改用 manifest 确认存在的 `mainui_img_45` MainUI 奖励框，但仍是本地三格静态预览，不是完整 `GridScroller`。`pnlChat/@btnChat` 使用 `mainui_btn_04`，聊天文本为 MVP 本地占位。

`pnlStory/btnStory` 与 `btnChapterInfo` 现均接入 `_show_dust_exploration()`，旧 `_show_chapter_progress()` 保留为兼容别名。塵世探秘界面按 `ChapterTaskView.layout.json` 的宏观结构拆成左侧 `pnlReward` 奖励预览/跳转提示与右侧 `pnlTask/svTaskList` 任务列表，并使用已导出的 `hero_bg_01`、`task_bg_01`、`task_btn_01`、`task_img_39/37/13/18/03/02`、`common_btn_02/16/17`、`common_img_44/46/88` 和本地 MVP 数据绘制可交互入口。

仍简化项：章节奖励滚动、真实章节进度文本、聊天运行时消息流未还原。

### 塵世探秘界面

Manifest 反查确认 `ChapterTaskView.prefab` physical 存在，layout 节点包含全屏 `Image/@fx_imgBg_star`、`pnlContent/pnlReward`、`pnlReward/pnlChapterIfno`、`pnlContent/pnlTask` 与 `svTaskList`。`ChapterTaskView` 资源清单进一步确认本体使用 `hero_bg_01`、`task_bg_01`、`task_btn_01`、`task_img_39/37/13`、`common_btn_17`；`ChapterTaskCell` 使用 `task_img_18/03/02`、`common_btn_02`、`common_img_88`；`ChapterRewardDetailView/Grid` 使用 `common_bg_09`、`common_btn_16`、`common_img_44/46/88`。数据表 `chapter_resolved.csv` 仍记录了 `chapter_chufa_00..05` 背景 key，但这些 key 对应的章节切换背景没有作为 Godot 可直接引用贴图落地；`@fx_imgBg_star`、`@RoleRewardPre`、Spine/CanvasGroup 动画层也没有本地运行时。

本轮只修复可证实的小缺口：

- `main.gd` 新增 `_show_dust_exploration()`，以 `ChapterTaskView` 原始资源重建塵世探秘背景、奖励预览按钮、跳转提示条、章节奖励条、任务列表和底部操作按钮。
- `main.gd` 新增 `_draw_chapter_task_cell()` 与 `_show_chapter_reward_detail()`，对齐 `ChapterTaskCell`、`ChapterRewardDetailView/Grid` 的行底、进度条、领取/已领取状态与详情弹窗。
- `home_screen.gd` 中 `pnlStory/btnStory` 与 `btnChapterInfo` 的透明点击区均指向 `_show_dust_exploration()`，右下主入口不再停留在旧的简化章节面板。
- 挑战、收取挂机、章节任务、战役详情沿用现有 MVP 数据与行为，不伪造未接入的 `ChapterTaskView` 运行时奖励滚动、章节背景换图、角色奖励预览或粒子/Spine 层。

### 右下功能与挂机区

`pnlFunnyContent` 的竞技、祈愿、冒险、唤灵四个入口已恢复到 prefab 资源原始 88x102 比例；`btnAdventure/btnJumpAutoFight` 使用 `mainui_img_36` 的 180x90 原始比例并保持透明点击入口。`pnlStory` 已恢复 `mainui_txt_01` 的 278x98 原始比例，`btnHarvest` 使用 `mainui_img_18` 的 89x100 比例，`imgHookTime` 使用 `mainui_img_08` 的 92x20 原始比例。

仍简化项：`pnlExpeditionSoftGuide`、`pnlHookSoftGuide` 粒子节点保持未还原；自动挑战条上的状态文本仍是本地静态文本。

## 仍需注意

- `hero_img_219` 对应 `irole/imgSpeak`，原始 Active=N，不应为了资源存在而强行显示。
- Spine 三层 `spBg/spHero/spFg` 与各类粒子节点没有在本轮伪装成完整还原；它们需要独立运行时或烘焙流程。
- `TopResGrid` physical 存在，后续若要完整复原顶部 `svRes`，应先以 `TopResGrid.layout.json` 和 `MainUIView.layout.json` 补齐容器裁剪、布局和滚动行为。
