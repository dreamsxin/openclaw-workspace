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
