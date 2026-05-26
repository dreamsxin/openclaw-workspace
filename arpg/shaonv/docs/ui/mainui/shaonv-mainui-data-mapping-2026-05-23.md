# MainUIView 数据映射与缺口对照

> 2026-05-23 · 基于 layout.json + MainUIView.il.txt + spriteatlas

---

## 1. Node → Image/Sprite 映射

### 1.1 当前 home_screen.gd 使用的 sprite

| Godot const | sprite 文件 | IL FIELD 类型 | 用途 |
|-------------|------------|---------------|------|
| UI_MAIN_BG | mainui_img_01 | — (WallpaperPanel bg) | 全屏壁纸背景 |
| UI_MAIN_PLAYER_FRAME | mainui_img_02 | — (pnlPlayerInfo frame) | 玩家信息框 |
| UI_MAIN_AVATAR_RING | mainui_img_03 | imgHeadBg (Image) | 头像白色圆环 |
| UI_MAIN_EXP_RING | mainui_img_04 | imgExp (Image) | EXP 金色环 |
| UI_MAIN_BANNER | mainui_img_05 | — (@pnlAlternate) | 活动横幅 |
| UI_MAIN_TOP_ACCENT | mainui_img_10 | — (@TopBar) | 顶栏装饰条 |
| UI_MAIN_SEPARATOR | mainui_img_11 | — (Image 2×18) | 按钮分隔线 |
| UI_MAIN_ASSIST | mainui_img_19 | — (btnAssist bg) | 援助按钮 |
| UI_MAIN_STORY_BG | mainui_txt_01 | — (pnlStory bg) | 主线故事背景 |
| UI_MAIN_FUNNY_ARENA | mainui_txt_02 | — (btnArena bg) | 竞技按钮 |
| UI_MAIN_FUNNY_PRAYER | mainui_txt_03 | — (btnPrayer bg) | 祈愿按钮 |
| UI_MAIN_FUNNY_ADVENTURE | mainui_txt_05 | — (btnAdventure bg) | 冒险按钮 |
| UI_MAIN_FUNNY_DRAW | mainui_txt_06 | — (btnDraw bg) | 唤灵按钮 |
| UI_MAIN_CHAPTER_BG | mainui_img_35 | — (btnChapterInfo bg) | 章节任务 |
| UI_MAIN_CHAT_BG | mainui_btn_04 | — (pnlChat bg) | 聊天条 |
| UI_MAIN_GAL | mainui_txt_09 | — (btnGal bg) | 约会按钮 |
| UI_MAIN_BOTTOM_BTN | mainui_btn_01 | — (btnHero etc bg) | 底部通用按钮 |
| UI_MAIN_MENU | mainui_btn_06 | — (btnMenu bg) | 菜单按钮 |
| UI_MAIN_CHARGE_ICONS | btn_07~11 | — (pnlCharge bg) | 充值入口图标 |

### 1.2 可用但未分配的 sprite

| sprite | 推测用途 |
|--------|---------|
| mainui_btn_14/15/16/17/18 | 按钮备选样式 (Normal/Hover/Pressed 态?) |
| mainui_btn_20/21/23/24 | 更多功能按钮图标 |
| mainui_btn_12/13 | 不确定 |
| mainui_img_06~09,12~18,20~25,30~34,36~45 | 装饰/分割线/区域背景 |
| mainui_txt_04,07,08 | 文字标签样式 |

### 1.3 尚需确认的 Image 节点 (IL FIELD 声明但未明确 sprite)

| IL Image FIELD | 节点名 | 当前 Godot | 建议 |
|----------------|--------|-----------|------|
| imgHookTime | imgHookTime (92×20) | **缺失** | 挂机时间图标 — 需单独导出 |
| (btnGal内部 Image) | Image (0,74) 150×170 | **缺失** | 约会按钮背景 — 可能不在此 atlas |
| (btnArena 内部 Image) | (无独立 Image FIELD) | — | 需查看 Common spriteatlas |
| (irole 内的 imgMask) | imgMask (324×274) | **缺失** | 角色前景遮罩 |

---

## 2. Text → 内容映射

### 2.1 已知 Text 节点和 IL 绑定

| IL Text FIELD | 节点名 | 运行时赋值来源 | 内容示例 |
|---------------|--------|---------------|---------|
| txtLevel | Text (50×12) | `UserModel.UserLv` → "{0}" 格式 | "Lv.42" |
| txtName | (200×28) | `UserModel.UserName` | "玩家名字" |
| txtPower | (173×37) | `UserHelper.GetPower()` → ToString | "123456" |
| txtStory | txtStory (-6×-7) | `Scx.Lang::Get("UI1000015")` + `ExpeditionStatic.name` | "主线 命運渦流" |
| txtChapterTitle | (224×32) | `Scx.Lang::Get("UI1000026")` 推测 | ❓ |
| txtHookTime | txtHookTime (0×0) | `RefreshHookTime()` IL 显示 | ❓ 挂机计时 |
| txtAssist | (162×30) | IL 中 SetText | ❓ "辅助战斗" |
| txtAssistProject | (170×28) | IL 中 SetText | ❓ |
| (btnHarvest Text) | (无独立 FIELD) | ✅ 当前已有 "收获" | — |
| (btnGal Text) | Text (70×30) | ❓ | "约会" |

### 2.2 待解析的 UI 本地化 Key (需 MemoryPack 解析 lang.bytes)

```
UI1000015 → txtStory 格式化: "主线 {0}"
UI1000026 → txtChapterTitle / svChapterReward? 
UI1000034 → 未知用途
UI1000035 → 未知用途
```

---

## 3. Button → 跳转目标映射

### 3.1 IL 中已知的 Prefab 引用

从 `MainUIView.il.txt` Ldstr 提取的完整 Prefab 路径:

| Prefab 路径 | 用途 | 有物理 Bundle? |
|------------|------|:--:|
| `Prefabs/UI/Common/TopResGrid` | svRes 资源栏单元格 | ✅ |
| `Prefabs/UI/Common/RewardGrid` | svChapterReward 奖励网格 | ❓ |
| `Prefabs/UI/MainUI/MainUIAlternateDot` | pnlAlternate 轮播指示点 | ❓ |
| `Prefabs/UI/MainUI/MainUIAlternateGrid` | pnlAlternate 轮播网格 | ❓ |
| `Prefabs/UI/Wallpaper/WallpaperPreView` | btnChange → 壁纸预览 | ❓ |

### 3.2 按钮 → 系统映射 (通过红点键推断)

| 按钮 | IL Field | 红点键 | 跳转目标 (推断) |
|------|----------|--------|---------------|
| btnDraw | Button | LotteryDraw.LotteryDrawHero.7805 | LotteryDrawMainView |
| btnPrayer | Button | LotteryDraw.Prayer.4036 | PrayerView |
| btnArena | Button | Arena.ArenaRedDot.89949 | ArenaMainView |
| btnAdventure | Button | Adventure.AdventureMainView.43704 | AdventureView |
| btnHero | Button | Hero.HeroEnter.30218 | HeroMainView / HeroListView |
| btnBagpack | Button | Bag.BagRedDot.73517 | BagView / Inventory |
| btnPet | Button | Remnants.RemnantsEnter.1728 | RemnantsView |
| btnDevelop | Button | Develop.DevelopEnter.78015 | DevelopView |
| btnTask | Button | Quest.QuestEnter.42775 | QuestView |
| btnLegion | Button | Alliance.AllianceEnter.6965 | AllianceView |
| btnGal | Button | Gal.GalEntry.5799 | GalView / MaidLobby |
| btnMenu | Button | MainUIView.BtnMenu.84538 | 设置/系统菜单 |
| btnChapterInfo | Button | ChapterTask.ChapterTaskEnter.32541 | ChapterTaskView |
| btnShop | Button | GameShopCollection.Page.1748 | GameShopView |
| btnActivity | Button | Activities.Activity.34064 | ActivityMainView |
| btnWelfare | Button | Activities.Welfare.83923 | WelfareView |
| btnCharge | Button | Activities.ReCharge.99752 | RechargeView |
| btnCard | Button | Activities.Card.5353 | CardView |
| btnHarvest | Button | Expedition.Hook.84317 | (无跳转, 直接领收益) |
| btnPlayerInfo | Button | (无红点) | PlayerInfoView |
| btnChange | Button | (无红点) | WallpaperPreView (图鉴) |
| btnEye | Button | (无红点) | ShowOrHide toggle |

---

## 4. 事件订阅映射

从 IL `InitSubscribe()` 方法:

| 事件 Key | 触发时机 | 回调 |
|----------|---------|------|
| `GetFormation` | 阵容变化 | `CommonFormationView::GetFormation` |
| `UserSkinChange` | 皮肤切换 | 未知 (在 Awake() 中注册) |
| `UserSkinInteractiveRoleChange` | 角色交互皮肤变化 | 未知 |
| `RefreshQuestionInfo` | 问答刷新 | `UpdateQuestionInfo()` |
| `RefreshChapterTask` | 章节任务刷新 | `UpdateChapterTask()` |
| `GetChapterTaskReward` | 章节奖励领取 | 未知 |
| `ChapterComplete` | 章节完成 | 未知 |
| `WallpaperAutoPlay` | 壁纸自动播放 | 状态设置 |
| `WallpaperLastPlayed` | 上次播放壁纸 | 恢复状态 |
| `PauseAutoFight` | 暂停自动战斗 | `RefreshAutoFight` |
| `ReceiveHookReward` | 领取挂机奖励 | 未知 |
| `RefreshHookTime` | 挂机时间刷新 | `UpdateHookTime()` |

---

## 5. 嵌套 Prefab 物理可用性

| Prefab | 物理 bundle | 状态 |
|--------|-----------|:--:|
| TopResGrid | `b2/b23b6d9847109cf0f7aa85ad748645e6/__data` | ✅ 已有 layout |
| RewardGrid | `70a7db643fc8859f5f35754b2718513b.bundle` (49KB) | ✅ 待提取 |
| MainUIAlternateDot | `22/227dbb9cd22f97cd93c37fe4537f46f8/__data` (4KB) | ✅ 待提取 |
| MainUIAlternateGrid | `a2/a20c9fd9e58b913ff8b0ab37e9207a88/__data` (6KB) | ✅ 待提取 |
| WallpaperPreView | `75/75c01994bdb3a8d8f2d64981c11628e6/__data` (25KB) | ✅ 待提取 |

> 全部 5 个嵌套 Prefab 物理 bundle 均已确认存在，可用 `inspect_unity_prefab_layout.py` 批量提取。

---

## 6. 缺口汇总

| 缺口 | 严重度 | 补齐方式 |
|------|:--:|------|
| UI1000015~35 本地化文本 | 🟡 | 解析 lang.bytes MemoryPack → UI text 分支 |
| imgHookTime 挂机图标 | 🟡 | 导出对应 bundle 的 Sprite |
| btnGal 内部 Image (150×170) | 🟡 | 可能不在 MainUI atlas, 需单独导出 |
| imgMask (324×274) 遮罩 | 🟡 | 导出 |
| 4 个嵌套 Prefab 物理文件确认 | 🟡 | 查询 physical-asset-map.csv |
| 所有 Lang key → Text 精确对应 | 🟠 | MemoryPack 解析 |
| Share 属性值 (颜色/材质) | 🟠 | AssetRipper |
| ParticleSystem 参数 | 🟠 | AssetRipper |
| Animator 状态机 | 🟠 | AssetRipper |
| AudioClip 音频 | 🟠 | bundle 提取 |
