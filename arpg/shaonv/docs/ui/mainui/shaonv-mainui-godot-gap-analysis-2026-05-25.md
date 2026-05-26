# MainUIView Godot 还原差距分析

生成时间：2026-05-25。

本文对照 `shaonv-mainui-full-control-resource-inventory-2026-05-24.md` 中完整的 212 节点清单与 `standalone/godot-mvp/scripts/screens/home_screen.gd` 当前实现，逐层排查覆盖率、资源绑定正确性、位置偏差及缺失功能。

## 当前提交基线

| Commit | 说明 |
|---|---|
| `540348bf1` | 初始对齐 MainUIView 资源与主屏结构 |
| `399e44030` | 修正活动区位置、角色舞台、资源图标 |
| `d201d6814` | 章节信息改为标题+三格奖励 |
| `d760196ab` | 修正聊天条位置与世界频道文本 |
| `3b3f2f576` | 记录 Godot Home 对齐经验文档 |
| `968fdf4e2` | 修正底部菜单对齐 |

## 一、逐层覆盖度评估

按 `home_screen.gd` 中 `enter_normal_state()` 绘图层序对照清单节点。

### Layer 0: Wallpaper

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 3 | `@WallpaperPanel` | - | `draw_wallpaper` | ✅ |
| 5 | `imgBackGround` | `Image:none`, RuntimeBg=mainui_bg_01 | `UI_MAIN_BG` = mainui_bg_01.png | ✅ |
| 6 | `irole` | InteractiveRole | `_draw_hero_stage(hero, (390,82), (560,620))` | ✅ |
| 7 | `irole/btn` | UISprite, a=0, Button | 未显式实现（btnBodyMask 覆盖） | ⚪ |
| 8-13 | `irole/spBg/spHero/spFg` | Spine SkeletonGraphic ×3 | **未实现** — Spine baked JSON 未渲染 | 🔴 |
| 14 | `irole/imgMask` | hero_img_253 | **未实现** | 🔴 |
| 15-16 | `irole/imgSpeak` + Text | hero_img_219, N | **未实现**（prefab 中 Active=N） | ⚪ |

> **评估**: irole 下 Spine 三件套（背景/英雄/前景）是核心视觉层，当前仅用 `_draw_hero_stage` 替代原图。imgMask 为角色遮罩框。

### Layer 1: Body Mask

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 23 | `btnBodyMask` | UISprite a=0, Button | `draw_body_mask` → flat Button | ✅ |

### Layer 1b: Fullscreen Overlay

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 24 | `Image` (pnlAdapter 直子) | mainui_img_44 [Simple] | **未实现** — 全屏叠加层缺失 | 🔴🟡 |

> **关键**: 全屏 Image 使用 `mainui_img_44` 作为叠加层，资源来自 `assets_game_rawassets_sprite_mainui_mainui_img_44.bundle`。此图为独立 CAB（非 MainUI atlas），在 Godot assets 中已存在 `mainui_img_44.png`，但代码未引用。

### Layer 2: TopBar

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 25 | `@TopBar` | CanvasGroup+Animator | 部分实现（无 Animator） | 🟡 |
| 26 | `svRes` (ScrollRect) | Background [Sliced] | `draw_top_bar` 静态资源条 | 🟡 |
| 27 | `svRes/Viewport` | UIMask [Sliced] | **未实现** — 无滚动裁剪区 | 🔴 |
| 28 | `svRes/Viewport/Content` | - | **未实现** — 无内容容器 | 🔴 |
| 29 | `pnlLeftTop` | RectTransformLerp | **未实现** | ⚪ |
| 30 | `btnClose` | common_btn_04, N | **未实现**（prefab 中 Active=N） | ⚪ |
| 31 | `btnClose/Text` | "返回" | 同上 | ⚪ |
| 32 | `btnDetail` | common_btn_05, N | **未实现**（prefab 中 Active=N） | ⚪ |

> **评估**: TopBar 被简化为静态资源条。原设计为可滚动的 ScrollRect 资源列表，完整实现需要 GridScroller + Mask。btnClose/btnDetail 在 normal 状态下隐藏，MVP 可暂不实现。

### Layer 3: pnlPlayerInfo

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 33 | `pnlPlayerInfo` | mainui_img_02 [Simple] | `UI_MAIN_PLAYER_FRAME` ✅ | ✅ |
| 34 | `imgHeadBg` | mainui_img_03 [Filled] | `UI_MAIN_AVATAR_RING` ✅ | ✅ |
| 35 | `imgExp` | mainui_img_04 [Filled] | `UI_MAIN_EXP_RING` ✅ | ✅ |
| 36 | `txtLevel` | Text fs=34 "999" | `app._label("Lv.%d")` | 🟡 |
| 37 | `txtLevel/Text` | Text fs=8 "LEVEL" | **未实现** — "LEVEL" 子标签 | 🔴 |
| 38 | `txtName` | Text fs=20 "玩家姓名七个字" | ✅ | ✅ |
| 39 | `Image` | mainui_img_32 [Simple] | `UI_MAIN_POWER_ICON` ✅ | ✅ |
| 40 | `txtPower` | Text fs=26 "99999999" | ✅ | ✅ |
| 41 | `btnPlayerInfo` | Image:none a=0 Button | `add_hit_button` ✅ | ✅ |
| 42 | `btnEye` | mainui_btn_12 [Simple] | ✅ | ✅ |
| 43 | `btnEye/Text` | "Default" | "互动" | 🟡 |
| 44 | `btnChange` | mainui_btn_13 [Simple] | ✅ | ✅ |
| 45 | `btnChange/Text` | "Default" | "壁纸" | 🟡 |

> **评估**: pnlPlayerInfo 覆盖率 85%。缺 txtLevel 子标签，Text 内容为 placeholder，可接受。

### Layer 4: pnlFunny 及其子面板

#### 4.1 pnlStory + btnHarvest

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 47 | `pnlStory` | mainui_txt_01 | `UI_MAIN_STORY_BG` ✅ | ✅ |
| 48 | `Image` | mainui_img_34 | `UI_MAIN_STORY_PROGRESS` ✅ | ✅ |
| 49 | `txtStory` | "进度：..." | ✅ | ✅ |
| 50 | `Text` | "尘世探秘11" | "尘世探秘" | 🟡 |
| 51-54 | `pnlExpeditionSoftGuide` | ParticleSystem ×2, N | **未实现** | ⚪ |
| 55 | `@pnlRd` | red dot anchor | 通过 `_draw_red_dot` 替代 | 🟡 |
| 56 | `btnHarvest` | mainui_img_18 | `UI_MAIN_BTN_HARVEST` ✅ | ✅ |
| 57 | `imgHookTime` | mainui_img_08 | **未实现** — 挂机时间底板缺失 | 🔴 |
| 58 | `txtHookTime` | "12:08:08" | `_afk_time_display()` | ✅ |
| 59-62 | `pnlHookSoftGuide` | ParticleSystem | **未实现** | ⚪ |
| 64 | `btnStory` | Image:none a=0 Button | `add_hit_button` ✅ | ✅ |

> **🔴 imgHookTime (mainui_img_08)**: 清单中 btnHarvest 子节点有 Image=mainui_img_08 作为挂机时间标签的底板。Godot assets 中有 `mainui_img_08.png`，但代码只输出文字未铺垫底图。

#### 4.2 pnlFunnyContent

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 65 | `pnlFunnyContent` | HorizontalLayoutGroup | 手工排列 | 🟡 |
| 66 | `btnArena` | mainui_txt_03 | ✅ | ✅ |
| 68 | `Text` | "Default" | "竞技" | ✅ |
| 69 | `btnPrayer` | mainui_txt_06 | ✅ | ✅ |
| 71 | `Text` | "Default" | "祈愿" | ✅ |
| 72 | `btnAdventure` | mainui_txt_02 | ✅ | ✅ |
| 73 | `Text` | "Default" | "冒险" | ✅ |
| 75 | `btnJumpAutoFight` | mainui_img_36 | **错位使用** — 当前挂在 story_harvest 下 | 🔴 |
| 76 | `txtAssist` | "自动挑战中..." | **未实现** | 🔴 |
| 77 | `txtAssistProject` | "历战尖塔-单队" | **未实现** | 🔴 |
| 78 | `btnDraw` | mainui_txt_05 | ✅ | ✅ |
| 79 | `Text` | "Default" | "唤灵" | ✅ |

> **🔴 btnJumpAutoFight 错位**: 此节点是 `btnAdventure` 的子节点，位置 `pos(0,33) size(180,90)`。当前代码将 `mainui_img_36` 用作 story_harvest 区域的自动战斗指示器，而非放在冒险按钮上方。正确的 Unity 层级结构是 `btnAdventure > btnJumpAutoFight`，需将此按钮移到 `btnAdventure` 上方，显示"自动挑战中"和"历战尖塔-单队"文本。

#### 4.3 btnAssist

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 81 | `btnAssist` | mainui_img_19 | ✅ | ✅ |
| 82 | `Text` | "小助手" | ✅ | ✅ |

> **合规提醒**: 按前期 IL 分析结论，`btnAssist` 为 GM 专属入口，MVP 中应隐藏。当前代码将其显示在 `(317, 157)` 处。

#### 4.4 pnlCharge

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 83 | `pnlCharge` | GridLayoutGroup | 手工排列 | 🟡 |
| 84 | `btnActivity` | mainui_btn_06 | ✅ | ✅ |
| 87 | `btnWelfare` | mainui_btn_07 | ✅ | ✅ |
| 90 | `btnCard` | mainui_btn_10 | ✅ | ✅ |
| 93 | `btnCharge` | mainui_btn_08 | ✅ | ✅ |
| 96 | `btnShop` | mainui_btn_09 | ✅ | ✅ |

> **布局差异**: 原节点为 `GridLayoutGroup`，子节点 pos 均为 `(0,0)`。当前手工展开排列，底部起始位置 `(1118,142)` 与截图对齐。

#### 4.5 btnMenu

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 99 | `btnMenu` | mainui_btn_11 | ✅ | ✅ |
| 100 | `fxbtnMenu (1)` | mainui_btn_11 副本 | **未实现** — 光效覆盖层 | 🔴 |
| 101 | `@pnlRd` | red dot anchor | ✅ | ✅ |

> **btnMenu 光效**: 清单节点 100 是 `btnMenu` 子节点，重复使用 `mainui_btn_11` 且 offset 为 `(-39,-39)`，用于制作发光旋涡效果（配合 UIShiny）。当前仅有单张底图。

### Layer 5: pnlCommercialization

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 102 | `pnlCommercialization` | Background [Sliced] a=0 | **未实现** — 容器底板缺失 | 🔴 |
| 103 | `@pnlAlternate` | mainui_img_05 a=0 | `draw_commercialization` banner | ✅ |
| 104 | `pnlStandbyContainer` | N | **未实现** | ⚪ |
| 105 | `pnlShowoffContainer` | Y | **未实现** | 🔴 |
| 106 | `pnlDotsContainer` | HorizontalLayoutGroup | **未实现** — banner 指示点 | 🔴 |
| 107 | `pnlGift` | GridLayoutGroup, LimitIconPanel | 手工 4 列网格 | 🟡 |
| 108-155 | `@LimitIconView01-12` | Image:none a=0 ×12, btnIcon=mainui_btn_14 | 使用 `UI_MAIN_LIMIT_ICONS` (btn15-20) 循环 | 🟡 |
| 156-159 | `@Question` | "问卷" / "可领取" | **未实现** | 🔴 |
| 160-163 | `@BuryGift` | "埋点礼包" | **未实现** | 🔴 |
| 164-167 | `@DiscountLimitGift` | "显示折扣礼包" | **未实现** | 🔴 |

> **关键发现**:
> 1. `pnlCommercialization` 容器本身使用 prefab 内置 `Background` sliced Sprite 作为底板，当前透明（a=0），但在某些运行时状态可能有可见底图。
> 2. `@Question`（问卷）、`@BuryGift`（埋点礼包）、`@DiscountLimitGift`（折扣礼包）是三个特殊的 LimitIconView 条目，不在标准 12 个 @LimitIconView 列中。它们与标准条目共用 `mainui_btn_14` 图标，但有独立名称和可见性控制。
> 3. pnlDotsContainer 是 banner 轮播指示点，需 `HorizontalLayoutGroup`。
> 4. 清单中所有 `@LimitIconView*` 的 `btnIcon` 统一使用 `mainui_btn_14` 作为默认图，真实图标由 `LimitIconPanel` 根据运行时活动数据替换。当前代码用 6 张彩色图标（btn15-20）循环，是一种 MVP 占位策略。
> 5. pnlShowoffContainer（展示容器）Active=Y，运行时可能注入推广内容。

### Layer 6: btnChapterInfo

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 168 | `btnChapterInfo` | mainui_img_35 | ✅ | ✅ |
| 169 | `txtChapterTitle` | "第1章砸瓦鲁多 1/30" | "第1章尘世裂痕 0/1" | ✅ |
| 170 | `svChapterReward` | ScrollRect, GridScroller | 手工三格 | 🟡 |
| 171 | `@pnlRd` | red dot | ✅ | ✅ |
| 172 | `Image` | Image:none a=0 | **未实现** | ⚪ |

### Layer 7: pnlBottom

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 173 | `pnlBottom` | mainui_img_10 [Sliced] | `UI_MAIN_BOTTOM_BG` ✅ | ✅ |
| 174 | `pnlGal` | container | ✅ | ✅ |
| 175 | `btnGal` | Image:none a=0 Button | `add_hit_button` ✅ | ✅ |
| 176 | `btnGal/Image` | mainui_btn_25 | `UI_MAIN_GAL` ✅ | ✅ |
| 177-183 | `btnGal/@fx05` | ParticleSystem ×6 | **未实现** — 现世按钮粒子光效 | 🔴 |
| 184 | `btnGal/Text` | "现世" | ✅ | ✅ |
| 186 | `@btnGalClickRrea` | Image:none a=0 | **未实现** — 点击响应区 | ⚪ |
| 187 | `btnHero` | Image:none a=0 | ✅ "幻灵" | ✅ |
| 190 | `btnBagpack` | Image:none a=0 | ✅ "背包" | ✅ |
| 193 | `Image` | mainui_img_11 | ✅ 分隔线 | ✅ |
| 194 | `btnPet` | Image:none a=0 | ✅ "宠物" | 🟡 |
| 198 | `btnDevelop` | UISprite a=0 | ✅ "养成" | 🟡 |
| 202 | `btnTask` | UISprite a=0 | ✅ "任务" | 🟡 |
| 206 | `btnLegion` | Image:none a=0 | ✅ "公会" | ✅ |

> **🟡 命名对照**:
> - Godot 将 `btnPet` 显示为"遗器"而非"宠物"
> - Godot 将 `btnDevelop` 显示为"养成"（一致）
> - Prefab 中 `btnTask/Text` 值也为"养成"（疑似开发期复制粘贴），Godot 译为"任务"
> - 底部导航统一使用 `mainui_img_11` 作为按钮分隔竖线（7 个实例中 5 个引用），当前用 `_draw_image` 硬画

### Layer 8-9: btnGal + pnlChat

| # | Prefab 节点 | 清单 Sprite | Godot 实现 | 状态 |
|---:|---|:---|:---|:---|
| 210 | `pnlChat` | ChatEntryPanel | ✅ | ✅ |
| 211 | `@btnChat` | mainui_btn_04 | ✅ | ✅ |
| 212 | `@txtChat` | TextMeshProUGUI | ✅ | ✅ |

## 二、资源绑定交叉验证

### 2.1 清单中已用 ↔ Godot 代码已声明

| 清单 Sprite | Godot 常量 | 状态 |
|---|---|---|
| mainui_img_02 | UI_MAIN_PLAYER_FRAME | ✅ |
| mainui_img_03 | UI_MAIN_AVATAR_RING | ✅ |
| mainui_img_04 | UI_MAIN_EXP_RING | ✅ |
| mainui_img_05 | UI_MAIN_BANNER | ✅ |
| mainui_img_10 | UI_MAIN_BOTTOM_BG | ✅ |
| mainui_img_11 | UI_MAIN_SEPARATOR | ✅ |
| mainui_img_18 | UI_MAIN_BTN_HARVEST | ✅ |
| mainui_img_19 | UI_MAIN_ASSIST | ✅ |
| mainui_img_32 | UI_MAIN_POWER_ICON | ✅ |
| mainui_img_34 | UI_MAIN_STORY_PROGRESS | ✅ |
| mainui_img_35 | UI_MAIN_CHAPTER_BG | ✅ |
| mainui_img_36 | UI_MAIN_AUTO_FIGHT | ✅ |
| mainui_txt_01 | UI_MAIN_STORY_BG | ✅ |
| mainui_txt_02 | UI_MAIN_FUNNY_ADVENTURE | ✅ |
| mainui_txt_03 | UI_MAIN_FUNNY_ARENA | ✅ |
| mainui_txt_05 | UI_MAIN_FUNNY_DRAW | ✅ |
| mainui_txt_06 | UI_MAIN_FUNNY_PRAYER | ✅ |
| mainui_btn_04 | UI_MAIN_CHAT_BG | ✅ |
| mainui_btn_06-11 | UI_MAIN_CHARGE_ICONS[0-4] | ✅ |
| mainui_btn_12 | UI_MAIN_BTN_EYE | ✅ |
| mainui_btn_13 | UI_MAIN_BTN_CHANGE | ✅ |
| mainui_btn_25 | UI_MAIN_GAL | ✅ |

### 2.2 清单中已用但 Godot 代码未引用

| 清单 Sprite | 使用节点 | 严重度 |
|---|---|---|
| **mainui_img_08** | `btnHarvest/imgHookTime` 挂机时间底板 | 🔴 影响视觉 |
| **mainui_img_44** | `pnlAdapter/Image` 全屏叠加层 | 🟡 需确认可见性 |
| **hero_img_253** | `irole/imgMask` 角色遮罩 | 🔴 Spine 依赖 |
| **hero_img_219** | `irole/imgSpeak`（隐藏） | ⚪ 暂不需要 |
| **Background** (prefab) | `svRes`, `pnlCommercialization` 底板 | 🟡 当前透明 |
| **UIMask** (prefab) | `svRes/Viewport` 滚动裁剪 | 🔴 需配合 ScrollRect |
| **UISprite** (prefab) | `btnDevelop`, `btnTask` 底板 | 🟡 当前透明 |
| **common_btn_04/05** | `btnClose`, `btnDetail`（均隐藏） | ⚪ 暂不需要 |
| **wallpaper_btn_01/02/16** | `pnlCtl` 壁纸控制栏 | ⚪ wallpaper_focus 中使用文字按钮替代 |

### 2.3 Godot 使用了清单外资源

| Godot 常量 | 路径 | 用途 |
|---|---|---|
| UI_ITEM_TICKET | draw_07.png | 顶部资源图标 |
| UI_ITEM_GEM | draw_05.png | 顶部资源图标 |
| draw_06.png | draw_06.png | 章节奖励中间格 |
| `UI_MAIN_LIMIT_ICONS` | mainui_btn_15-20 | 活动入口占位图 |

> **清单对照**: `mainui_btn_14` 是清单中 `@LimitIconView*` 的统一默认图标，而 `mainui_btn_15-20` 不在 MainUIView.prefab 的 Image.sprite 清单中（可能为外部 CAB 资源或由 LimitIconPanel 运行时加载）。当前使用 6 张彩色图标循环为合理的 MVP 策略。

## 三、位置核对重点

### 3.1 已验证对齐点

| 区域 | Godot 位置 | 清单推导 | 截图对照 | 评级 |
|---|---|---|---|---|
| Background | (0,0) 1280×720 | 拉伸 | ✅ | 🟢 |
| pnlPlayerInfo | (0,5) | anchor(0,1) pos(0,-5) | top-left | 🟢 |
| TopBar 资源条 | (842,20) | anchor(1,1) | top-right | 🟢 |
| pnlChat | (916,90) | anchor(1,1) pos(-64,-94) | right-upper | 🟢 |
| pnlBottom | (49,657) | anchor(0,0) pos(64,49) | bottom-left | 🟢 |
| btnGal | (38,562) | 独立绘制 | protrudes above bar | 🟢 |
| btnChapterInfo | (1042,480) | anchor(1,0) pos(-34,150) | right-mid | 🟢 |
| pnlCommercialization | (50,120) | anchor(0,1) pos(265,-333) | left-mid | 🟢 |
| pnlCharge | (1118,142-318) | anchor(1,1) pos(-55,-277) | right-mid | 🟢 |
| pnlFunnyContent | (745,604) | anchor(1,0) pos(-339,70) | bottom-right | 🟢 |
| pnlStory | (1021,608) | anchor(1,0) pos(-60,19) | right of content | 🟢 |
| btnMenu | (1178,14) | anchor(1,1) pos(-94,-54) | top-right corner | 🟢 |

### 3.2 需要复查的位置

| 节点 | 当前 Godot 位置 | 清单 Rect | 疑问 |
|---|---|---|---|
| btnAssist | (317,157) | pos(413,-164) anchor(0,1) | MVP 宜隐藏（GM 专属） |
| btnJumpAutoFight | 误挂在 story_harvest 内 | pos(0,33) size(180,90) | 应属于 btnAdventure 子节点 |
| pnlCommercialization pnlGift | (55,233) 开始 | pos(7,-120) | 4列网格间距需截图验证 |
| @pnlAlternate | (50,120) | pos(0,0) | banner 左上角与 pnlCommercialization 锚点一致 |

### 3.3 btnJumpAutoFight 位置纠正方案

当前代码将 `mainui_img_36` 放在 `pnlStory` 内部：

```
# 错位: draw_story_harvest() 中
app._draw_image(UI_MAIN_AUTO_FIGHT, Vector2(sx+5, sy+67), ...)  # story 内部
```

正确做法：`btnJumpAutoFight` 是 `btnAdventure` 子节点（清单 #75），应移到 `draw_funny_content` 中冒险按钮上方：

```
# Prefab 清单:
# 72 btnAdventure: mainui_txt_02, pos(0,0) size(88,102)
#   └ 75 btnJumpAutoFight: mainui_img_36, pos(0,33) size(180,90)
#        └ 76 txtAssist: "自动挑战中..."
#        └ 77 txtAssistProject: "历战尖塔-单队"
```

`pos(0,33)` 表示相对父节点 `btnAdventure` 顶部上方偏移 33px。`size(180,90)` 是 180×90 的横幅，远大于父节点的 88×102 宽度。在 Godot 中应在冒险按钮上方绘制：

```
auto_fight_y = by - 90 - 4   # btnAdventure 上方
add_scaled_image(UI_MAIN_AUTO_FIGHT, (start_x - 46, auto_fight_y), (180, 90))
add_ui_text("自动挑战中", (start_x - 40, auto_fight_y + 14), ...)
add_ui_text("历战尖塔-单队", (start_x - 40, auto_fight_y + 44), ...)
```

## 四、缺失功能优先级

| 优先级 | 缺失项 | 节点数 | 理由 |
|:---:|---|---|---|
| **P0** | `irole` Spine 渲染 (spBg/spHero/spFg) | 3 | 核心视觉——角色三件套 |
| **P0** | `irole/imgMask` hero_img_253 | 1 | 角色遮罩框 |
| **P1** | `imgHookTime` mainui_img_08 底板 | 1 | 挂机时间视觉完整性 |
| **P1** | `btnJumpAutoFight` 位置纠正 | 3 | 错位导致自动战斗UI不可见 |
| **P1** | 全屏 `mainui_img_44` 叠加层 | 1 | 全屏效果层 |
| **P2** | `@Question`/`@BuryGift`/`@DiscountLimitGift` | 3 | 特殊活动入口 |
| **P2** | `pnlShowoffContainer` | 1 | 推广内容展示 |
| **P2** | `pnlDotsContainer` banner 指示点 | 1 | Banner 轮播 |
| **P3** | btnGal 粒子光效 (`@fx05`) | 6 | 现世按钮旋涡光效 |
| **P3** | btnMenu 光效覆盖层 | 1 | UIShiny 旋转效果 |
| **P3** | pnlExpeditionSoftGuide 粒子 | 2 | 探秘引导特效 |
| **P3** | pnlHookSoftGuide 粒子 | 2 | 挂机引导特效 |

## 五、总评

### 覆盖率

| 维度 | 数值 | 评级 |
|---|---|---|
| 节点覆盖 | ~170 / 212 有对应实现或合理跳过 | 80% |
| Image Sprite 绑定 | 21 / 90 直接引用（其余为 none/运行时/SkeletonGraphic） | 🟢 关键图片已全绑定 |
| Text 节点 | 24 / 61 有文本渲染（其余隐藏/空白/运行时填充） | 🟡 |
| Button 交互 | 18 / 49 有回调（其余隐藏/模板） | 🟢 |
| Layout 模拟 | 3 个 LayoutGroup 用手工排列 | 🟡 |

### 下一轮建议

1. **立即**: 修正 `btnJumpAutoFight` 位置（从 story_harvest 移到 btnAdventure 上方）
2. **立即**: 补充 `imgHookTime` (mainui_img_08) 底板
3. **立即**: 补充全屏 `mainui_img_44` 叠加层
4. **后续**: Spine 角色三件套渲染
5. **后续**: @Question/@BuryGift/@DiscountLimitGift 三个特殊活动入口
6. **后续**: 粒子特效层（btnGal/@fx05, btnMenu/fx, pnlExpeditionSoftGuide）

---

*本文基于 `shaonv-mainui-full-control-resource-inventory-2026-05-24.md` 和 `shaonv-mainui-godot-home-fix-experience-2026-05-25.md` 交叉分析生成。*
