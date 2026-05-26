# MainUIView 到 Godot Home 修复经验

生成时间：2026-05-25。

本文记录按 `shaonv-mainui-full-control-resource-inventory-2026-05-24.md` 修复 `standalone/godot-mvp/scripts/screens/home_screen.gd` 时遇到的问题，重点解释：为什么已经有 212 节点全量清单，落到 Godot 后仍然会出现位置不对。

## 本轮提交

| Commit | 说明 |
|---|---|
| `540348bf1` | 对齐 MainUIView 资源和主屏结构：背景、底栏、现世入口、右侧商业入口、左侧限时入口、剧情入口等。 |
| `399e44030` | 修正活动区位置、角色舞台大小、顶部资源图标和左侧活动图标。 |
| `d201d6814` | 把右下章节信息从纯文字改成标题加三格奖励。 |
| `d760196ab` | 修正右上聊天条位置和世界频道文本。 |

## 为什么全量清单后仍会位置不对

### 1. 清单是 Raw RectTransform，不是最终屏幕坐标

`MainUIView` 清单中的 `Rect` 是 Unity prefab 的 `anchoredPosition/sizeDelta/anchorMin/anchorMax/pivot` 原始值。它不是运行时最终像素坐标。

例如：

- `pnlChat` 是右上锚点、pivot 也是右上：`anchor=1,1`、`pivot=1,1`、`pos(-64,-94)`、`size(410,40)`。
- 如果只把 `pos.x=-64` 转成 Godot 的 x 偏移，会得到错误的右侧位置。
- 正确思路是先按父容器、锚点、pivot 算出左上角：`left = parentRight - marginRight - width`，再映射到 Godot。

这就是聊天条第一次几乎挤出屏幕的原因。

### 2. Unity 与 Godot 目标画布比例不同

MainUIView 的关键画布宽高是 `1668x750`，当前 Godot MVP 是 `1280x720`。二者不是等比例缩放：

| 轴 | 比例 |
|---|---:|
| X | `1280 / 1668 ≈ 0.767` |
| Y | `720 / 750 = 0.96` |

如果简单用同一个缩放值，横向会偏；如果分别缩放 X/Y，元素形状和间距又会和 Unity CanvasScaler / 设备适配策略不同。截图本身也是宽屏手机画幅，不等同于 Godot 的 16:9 视口。

因此位置需要结合截图做二次校准，不能只做一次线性换算。

### 3. 锚点、pivot、Y 轴方向必须一起算

Unity UGUI 是以父 RectTransform、锚点和 pivot 共同决定位置；Godot Control 默认是左上角定位。常见坑：

- `anchor=(0,1)` 表示左上锚点，但 Unity `anchoredPosition.y` 正负方向与 Godot 屏幕 y 方向相反。
- `pivot=(1,0)` 或 `pivot=(1,1)` 的节点，`anchoredPosition` 往往不是左上角。
- `sizeDelta=(0,0)` 不代表没有尺寸；拉伸锚点节点尺寸来自父容器。

所以全量清单里的单行 Rect 不能直接写成 `position = Vector2(pos.x, pos.y)`。

### 4. LayoutGroup / ContentSizeFitter 会运行时排布

`pnlBottom`、`pnlFunnyContent`、`pnlGift` 等节点由 Unity 的 `HorizontalLayoutGroup`、`GridLayoutGroup`、`ContentSizeFitter` 管理。清单里子节点常显示 `pos(0,0)`，因为它们的最终排列由布局组件在运行时计算。

Godot 复刻时如果没有实现对应布局组件，就要按父节点布局参数手工展开：

- `pnlBottom` 要按 `pnlGal + btnHero + btnBagpack + ...` 的顺序铺开。
- `pnlGift` 要按 4 列网格排布，而不是照每个 `@LimitIconView` 的 `pos(0,0)`。
- `pnlFunnyContent` 要按横向布局排 4 个玩法入口。

这也是“清单全量，但子项仍会堆在一起或错位”的核心原因。

### 5. 部分视觉来自运行时数据，不在 prefab 静态资源里

全量清单可以解析 `Image.sprite`，但 MainUIView 有不少运行时填充：

- `imgBackGround` prefab 内 sprite 为空，实际由 `WallpaperPanel` 注入 `mainui_bg_01`。
- `@LimitIconView*` 的活动入口真实图标和标题来自运行时活动数据；prefab 只给了模板结构和默认图。
- `svChapterReward` 的奖励格由数据驱动；清单只有滚动容器和标题节点。
- `spHero/spBg/spFg` 是 Spine 运行时显示，Godot 使用 baked JSON 后还会有自身缩放规则。

所以 Godot 不能只照 `Image.sprite` 列表，还要结合截图和数据含义补“运行时填充层”。

### 6. Godot TextureRect 的拉伸规则和 Unity Image 不一样

Unity `Image` 的 `Simple/Sliced/Filled` 和 Godot `TextureRect` 的 `stretch_mode` 不是一一对应。本轮出现过顶部资源小图标被画成原图大尺寸的问题，原因是普通 `_draw_image()` 使用 `KEEP_ASPECT_CENTERED`，没有把源图缩成目标像素。

修正经验：

- 大背景、按钮底图可以继续用 `_draw_image()`。
- 资源小图标、奖励小格图标这类必须固定尺寸的图，使用 `add_scaled_image()` 先 resize 再创建纹理。
- 透明点击区应该用 `Button.flat = true`，不要画一个可见色块。

## 当前修复后的 Godot Home 对齐点

- 背景使用 `mainui_bg_01`。
- 左侧活动区使用 `mainui_img_05` banner 和 `mainui_btn_15~20` 彩色入口图标。
- 顶部资源条使用现有 `draw_07` / `draw_05` 作为券和晶石图标。
- 底栏使用 `mainui_img_10` 与 `mainui_img_11`，文字对齐 `现世 / 幻灵 / 背包 / 遗器 / 养成 / 任务 / 公会`。
- 右侧商业入口使用 `mainui_btn_06/07/08/09/10/11`。
- 右下章节入口使用 `mainui_img_35`，并补成标题 + 三格奖励。
- 聊天条按右上锚点重算，落到截图对应区域。

## 后续规则

1. 先把 Unity RectTransform 转成“屏幕左上角坐标”，再写 Godot 坐标。
2. 遇到 LayoutGroup，不读子节点 `pos(0,0)`，而是按布局组件语义排布。
3. 遇到 `Image:none`，先判断是不是透明点击区或运行时注入，不要直接认为资源缺失。
4. 小图标统一使用固定像素缩放 helper，避免 Godot 保持原图尺寸。
5. 每轮修改都用 `SHAONV_MVP_START_VIEW=main` 截图验证；截图比清单更能发现运行时错位。

## 2026-05-26 Home 按钮功能闭环

本轮重点不是重新排主屏，而是把截图中可见的按钮从“占位跳转”改成可用功能页：

- 顶部资源条的 `+` 点击区进入商店。
- `壁紙` 进入 `wallpaper_select`，可选择主屏看板角色；`互動` 仍进入纯看板模式。
- 底栏 `背包 / 遺器 / 養成 / 公會` 分别接到 `_show_bag()`、`_show_relics()`、`_show_develop()`、`_show_guild()`，不再复用商店/图库/主页占位。
- 右下 `競技` 接 `_show_competition()`；`祈願 / 冒險 / 喚靈` 继续接已有祈愿、战役、喚靈链路。
- 右侧 `活動 / 福利 / 月卡` 分别接活动中心、福利中心、月卡页；`商店 / 儲值` 仍进商店。
- `小助手` 进入 `_show_assist()`；聊天条进入 `_show_chat()`。
- 左侧限时入口统一收束到活动、福利、商店、聊天、Gal、任务、喚靈等已有链路，避免按钮点击无反馈。

新增调试启动入口用于后续快速回归：

- `SHAONV_MVP_START_VIEW=bag`
- `SHAONV_MVP_START_VIEW=relics`
- `SHAONV_MVP_START_VIEW=develop`
- `SHAONV_MVP_START_VIEW=guild`
- `SHAONV_MVP_START_VIEW=activity`
- `SHAONV_MVP_START_VIEW=welfare`
- `SHAONV_MVP_START_VIEW=month_card`
- `SHAONV_MVP_START_VIEW=competition`
- `SHAONV_MVP_START_VIEW=assist`
- `SHAONV_MVP_START_VIEW=chat`
- `SHAONV_MVP_START_VIEW=wallpaper_select`

验证截图：

- `tmp/screenshots/home-buttons-main.png`
- `tmp/screenshots/home-bag-view.png`
- `tmp/screenshots/home-develop-view.png`
- `tmp/screenshots/home-activity-view.png`
- `tmp/screenshots/home-wallpaper-select-v2.png`
- `tmp/screenshots/home-relics-view.png`
- `tmp/screenshots/home-guild-view.png`
- `tmp/screenshots/home-welfare-view.png`
- `tmp/screenshots/home-competition-view.png`
- `tmp/screenshots/home-month-card-view.png`
- `tmp/screenshots/home-assist-view.png`
- `tmp/screenshots/home-chat-view.png`

## 2026-05-26 Home 二级页真实资源接入

本轮开始修复“按钮能点但进入后仍像占位界面”的问题，优先处理 Home 链路下的背包、遗器、养成、公会、活动、福利、月卡、竞技、小助手、聊天、壁纸选择，以及商店、每日、邮件、任务这些二级跳转页。

资源使用经验：

- 二级页背景仍使用 `mainui_bg_01` 加深色遮罩，避免离开 Home 后视觉断层。
- 标题区可复用 `mainui_img_44` 的弱覆盖感和 `mainui_img_40` 的横向分割线，但不要把带大字/角色图的 `mainui_img_37` 直接拉伸成通用大面板；它会把“NEWBIE”这类活动大字压到内容上。
- 小卡片可以少量复用 `mainui_img_38/mainui_img_39`，但宽列表更适合用暗色面板 + `mainui_img_40` 上下边线，避免源图被过度放大后露出不相关角色图案。
- 奖励和道具格使用 `mainui_img_45` + `item/draw_*.png`，比纯色方块更接近原 UI 的奖励格语义。
- 主屏活动/福利入口继续复用 `mainui_btn_14~20` 与 `mainui_btn_06/07/10`，这些资源比任意 Common 图标更符合 MainUI 链路。
- 壁纸选择页头像使用 `Head/Round/yhero_*`，外框使用 `common_img_64`，星条使用 `common_img_62`，与 Gal/幻灵左侧头像条保持一致。
- Godot `TextureRect` 默认会参与鼠标命中，统一给 `_draw_image()` 生成的 TextureRect 设置 `mouse_filter = IGNORE`，否则后画的高亮/底图可能挡住透明按钮。

新增快速回归入口：

- `SHAONV_MVP_START_VIEW=shop`
- `SHAONV_MVP_START_VIEW=daily`
- `SHAONV_MVP_START_VIEW=mail`
- `SHAONV_MVP_START_VIEW=tasks`

验证截图：

- `tmp/screenshots/home-resource-bag-v2.png`
- `tmp/screenshots/home-resource-activity-v3.png`
- `tmp/screenshots/home-resource-welfare-v2.png`
- `tmp/screenshots/home-resource-shop-v2.png`
- `tmp/screenshots/home-resource-daily-v2.png`
- `tmp/screenshots/home-resource-mail-v2.png`
- `tmp/screenshots/home-resource-tasks-v4.png`
- `tmp/screenshots/home-resource-wallpaper_select-v2.png`

## 2026-05-26 Home 主屏剩余按钮独立化

本轮继续处理“能点但语义不准”的入口，避免主屏按钮过度复用商店或设置页：

- `儲值` 和左侧 `首储` 不再进入商店，改为 `_show_charge()`，支持首储一次领取、普通补给反复购买，并复用 `mainui_btn_08`、`mainui_btn_10`、`mainui_btn_19` 与 `item/draw_05/draw_07`。
- 右上角罗盘 `mainui_btn_11` 不再直接打开设置，改为 `_show_home_menu()`，收束玩家资料、系统设置、邮件、资源修复、公告和小助手。
- 主屏 `btnJumpAutoFight` 使用 `mainui_img_36` 的横幅现在有透明点击区，进入 `_show_auto_fight()`，可切换自动状态、挑战一次、收取挂机。
- 右下章节卡与 Story 区域不再直接跳任务，改为 `_show_chapter_progress()`，集中展示已通关、下一关、章节奖励和任务进度，再分流到挑战/任务/战役详情。
- 透明点击区不要用 `_add_action_button("", ...)`，Godot 默认 Button 皮肤会画出灰块；需要使用 `_add_hit_button()` 或 HomeScreen 的 `add_hit_button()`，并保持 `flat=true`、`focus_mode=NONE`。

新增快速回归入口：

- `SHAONV_MVP_START_VIEW=home_menu`
- `SHAONV_MVP_START_VIEW=charge`
- `SHAONV_MVP_START_VIEW=auto_fight`
- `SHAONV_MVP_START_VIEW=chapter`

验证截图：

- `tmp/screenshots/home-main-buttons-v2.png`
- `tmp/screenshots/home-charge-view.png`
- `tmp/screenshots/home-menu-view-v2.png`
- `tmp/screenshots/home-auto-fight-view.png`
- `tmp/screenshots/home-chapter-progress-view.png`
