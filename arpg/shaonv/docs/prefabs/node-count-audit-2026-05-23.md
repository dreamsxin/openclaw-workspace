# Prefab 节点审计：Login + MainUI 节点数 vs Godot 代码

> 2026-05-23 · 对照 layout.json 检查每个节点的存在性、多余、缺失

---

## LoginView

| | Prefab | Godot |
|------|:--:|:--:|
| 总节点 | 39 | ~22 |
| 活跃节点 | 28 | ~22 |
| 隐藏节点 | 11 | 0 (全部跳过) |

### 逐节点对比

| Prefab 节点 | 状态 | Godot 状态 | 判定 |
|------------|:--:|------|:--:|
| @videoPlayer | ✗ | 无 | ⬜ 跳过（MVP 不播视频） |
| LoginView | ✓ | _clear("登入")→view container | ✅ |
| @rawImgBg | ✗ | 无 | ⬜ 跳过 |
| **imgBg** | ✓ | `_draw_image(UI_LOGIN_BG)` | ✅ |
| pnl | ✓ | (view container 本身) | ✅ 隐式 |
| btnLogin | ✓ | `_add_action_button("开始游戏")` | ✅ 语义等价 |
| pnlFunction | ✓ | 4 个 `_add_action_button` | ✅ |
| btnNotice | ✓ | "公告" 按钮 | ✅ |
| btnRepair | ✓ | "修复" 按钮 | ✅ |
| btnSwitchAccount | ✓ | "账号" 按钮 | ✅ |
| btnSelect | ✓ | "切换" 按钮 | ✅ |
| btnXxx/Text | ✗ | 无 | ⬜ prefab 中已隐藏 |
| **pnlVersion** | ✓ | `_label("版本...")` ×1 | ⚠️ prefab 有 3 个 Text(txtVer/txtApp/txtRes)，Godot 合并为 1 |
| **imgLogo** | ✓ | `_draw_image(UI_LOGIN_LOGO)` | ✅ |
| **btnAge** | ✓ | `Button.new()` "12+" | ✅ |
| @richBottom | ✓ | `_label("Copyright...")` | ✅ 简化版 |
| txtGameTip/txtCopyright/txtCopyleft | ✗ | 无 | ⬜ prefab 中已隐藏 |
| **btnServerSel** | ✗ | **服务器栏 + 状态灯** | 🔴 prefab 中隐藏！Godot 错误地显示了 |
| txtServer | ✗ | 无 | ⬜ 隐藏 |
| imgServer | ✓ | (无) | ⚠️ 缺失 server 图标 |
| txtServerName | ✓ | 服务器标签 | ✅ |
| **imgTipLogin** | ✓ | tip label | ✅ |
| @richUrl | ✓ | agree CheckBox | ✅ |
| togAgree | ✓ | ✅ | ✅ |
| **inputAccount** | ✓ | `LineEdit.new()` | ✅ |
| Placeholder | ✓ | LineEdit.placeholder_text | ✅ 隐式 |
| Text | ✓ | LineEdit.text | ✅ 隐式 |
| **Image (inputAccount 内图标)** | ✓ | 独立 ColorRect + "人" label | ⚠️ prefab 是用 prefab 内嵌 Image，不是独立面板 |

### LoginView 判定

| 判定 | 数量 | 说明 |
|------|:--:|------|
| ✅ 正确 | 15 | 核心节点都覆盖 |
| ⚠️ 简化/偏差 | 3 | pnlVersion 合并、input icon 方式不同、server img 缺失 |
| 🔴 错误 | 1 | **btnServerSel 本应隐藏，Godot 却显示了** |
| ⬜ 合理跳过 | 9 | 全为 prefab 中 active=false 的节点 |

> **结论**: LoginView 节点覆盖率良好。唯一结构性错误是显示了本该隐藏的服务器选择条。

---

## MainUIView

| | Prefab | Godot |
|------|:--:|:--:|
| 总节点 | 212 | ~77 |
| 活跃节点 | 203 | ~77 |
| 隐藏节点 | 9 | 0 |
| CanvasGroup | 34 | 0 (未实现面板显隐) |

### 关键面板逐项对比

#### @WallpaperPanel

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| imgBackGround | `_draw_image(UI_MAIN_BG)` | ✅ |
| pnlVideo (✗) | 无 | ⬜ 跳过（隐藏） |
| irole | `_draw_hero_stage()` | ✅ |
| irole/btn | body_mask 按钮 | ✅ 等价 |
| irole/spBg/spHero/spFg | baked Spine canvas | ✅ |
| **irole/imgMask** | **无** | 🔴 **缺失** — 角色前景遮罩 |
| irole/imgSpeak (✗) | 无 | ⬜ 跳过（隐藏） |
| pnlCtl (✗) | wallpaper_focus 状态手动按钮 | ✅ |

#### @TopBar

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| svRes | 3 个资源图标 | ⚠️ 简化（prefab 是 ScrollRect 动态列表） |
| pnlLeftTop/btnClose (✗) | 无 | ⬜ |
| pnlLeftTop/btnDetail (✗) | 无 | ⬜ |

#### pnlPlayerInfo

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| imgHeadBg | `UI_MAIN_AVATAR_RING` + portrait | ✅ |
| imgExp | `UI_MAIN_EXP_RING` | ✅ |
| **txtLevel** | level label | ✅ |
| txtName | name label | ✅ |
| Image (小图标) | 无 | ⚠️ prefab 有 21×21 装饰图标 |
| txtPower | power label | ✅ |
| btnPlayerInfo | 覆盖按钮 | ✅ |
| btnEye | "眼" 按钮 | ✅ |
| btnChange | "换" 按钮 | ✅ |

#### pnlFunny

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| pnlStory | story bg + text | ✅ |
| pnlStory/Image (156×34) | 无 — story bg 已包含 | ⚠️ prefab 内层有独立装饰 Image |
| pnlStory/Text (128×46) | story label | ✅ |
| **pnlExpeditionSoftGuide (✗)** | 无 | ⬜ 隐藏 |
| @pnlRd | _draw_red_dot | ✅ |
| btnHarvest | "收获" 按钮 | ✅ |
| **btnHarvest/imgHookTime** | **无** | 🔴 **缺失** — 挂机时间图标 |
| **btnHarvest/txtHookTime** | **无** | 🔴 **缺失** — 挂机倒计时文本 |
| **btnStory** | **无** | 🔴 **缺失** — 覆盖故事区的透明按钮 |
| pnlFunnyContent | 4 个水平按钮 | ✅ |
| btnArena/Prayer/Adventure/Draw | 均已创建 | ✅ |
| **btnAdventure/btnJumpAutoFight** | **无** | 🔴 **缺失** — 冒险按钮右下角的自动战斗子面板 |
| **btnJumpAutoFight/txtAssist** | **无** | 🔴 — 自动战斗状态文本 |
| **btnJumpAutoFight/txtAssistProject** | **无** | 🔴 — 自动战斗项目名文本 |
| btnAssist | "援助" 按钮 | ✅ |
| pnlCharge | 5 垂直按钮 | ✅ |
| btnActivity/Welfare/Card/Charge/Shop | 均已创建 | ✅ |
| btnMenu | 菜单按钮 | ✅ |
| fxbtnMenu (1) | 无 | ⬜ 粒子特效（MVP 跳过） |

#### pnlCommercialization

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| @pnlAlternate | banner image | ✅ |
| pnlStandbyContainer | 无 | ⬜ 待机轮播暂存（不需要） |
| pnlShowoffContainer | 无 | ⬜ |
| pnlDotsContainer | 无 | ⚠️ 轮播指示点缺失 |
| pnlGift | 9 个礼包槽位 | ⚠️ 简化（prefab 有 15 个 LimitIconView） |

#### btnChapterInfo

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| txtChapterTitle | 在 info label 中 | ✅ 合并 |
| svChapterReward | 无 | ⚠️ 章节奖励 ScrollView 缺失 |
| @pnlRd | _draw_red_dot | ✅ |
| Image | 无 | ⚠️ 装饰 Image 缺失 |

#### pnlBottom

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| pnlGal/btnGal | "约会" 按钮 | ✅ |
| btnHero/Bagpack/Pet/Develop/Task/Legion | 6 个按钮 | ✅ |
| 各 btn 下的 Text | _add_action_button 自带文本 | ✅ |
| 各 btn 下的 @pnlRd | _draw_red_dot | ✅ |
| **各 btn 间的 Image(分隔线)** | **UI_MAIN_SEPARATOR** | ✅ |

#### pnlChat

| Prefab 节点 | Godot | 判定 |
|------------|------|:--:|
| @btnChat/@txtChat | chat label | ✅ |

---

## 总判定矩阵

### 🔴 缺失（影响功能/视觉）

| # | 缺失节点 | 所在区域 | 影响 |
|:--:|------|------|------|
| 1 | **irole/imgMask** | WallpaperPanel | 角色前景遮罩层缺失 |
| 2 | **btnHarvest/imgHookTime** | pnlStory | 挂机时间图标缺失 |
| 3 | **btnHarvest/txtHookTime** | pnlStory | 挂机倒计时文本缺失 |
| 4 | **btnStory** | pnlStory | 故事入口缺少可点击覆盖层 |
| 5 | **btnAdventure/btnJumpAutoFight** | pnlFunnyContent | 自动战斗入口缺失 |
| 6 | **txtAssist** | btnJumpAutoFight | 自动战斗状态文本 |
| 7 | **txtAssistProject** | btnJumpAutoFight | 自动战斗项目名 |
| 8 | **btnServerSel (Login)** | LoginView/pnl | 显示不该显示的隐藏元素 |

### 🟡 简化/偏差

| # | 节点 | 说明 |
|:--:|------|------|
| 1 | pnlVersion ×3 Text | prefab 有 3 个独立 Text(txtVer/txtApp/txtRes)，Godot 合并为 1 |
| 2 | svRes (TopBar) | prefab 是 ScrollRect 动态列表，Godot 手动放了 3 个静态图标 |
| 3 | inputAccount/Image | prefab 用内嵌 Image 组件，Godot 用独立 ColorRect+"人" |
| 4 | svChapterReward | 章节奖励滚动列表缺失 |
| 5 | pnlDotsContainer | 轮播指示点缺失 |
| 6 | pnlGift ×15 → ×9 | 15 个 LimitIconView 简化为 9 个通用礼包槽 |
| 7 | pnlPlayerInfo/Image | 玩家信息面板小装饰图标缺失 |
| 8 | pnlStory/Image | 故事区独立装饰 Image 缺失 |
| 9 | btnChapterInfo/Image | 章节信息装饰图片缺失 |

### ✅ 正确覆盖

- 全部 10 个顶级面板（@WallpaperPanel ~ pnlChat）
- 全部可交互按钮（19 个主按钮 + 4 个 Login 功能键）
- Spine 角色渲染（irole 3 层骨架）
- 红点系统（@pnlRd → _draw_red_dot）
- 面板背景图片（mainui_img_01~45 全部启用）

### ⬜ 合理跳过（prefab 中 active=false）

- pnlVideo（WallpaperPanel 视频层）
- imgSpeak（对话气泡）
- pnlCtl（壁纸控制条 — 在 wallpaper_focus 状态手动重建）
- pnlLeftTop/btnClose/btnDetail（TopBar 左侧隐藏按钮）
- pnlExpeditionSoftGuide/pnlHookSoftGuide（引导特效）
- @richBottom 的 3 个子 Text（隐藏文本）
- 4 个 pnlFunction 按钮的子 Text（隐藏标签）

---

## 优先级修复建议

| 优先级 | 修复项 | 工时 |
|:--:|------|:--:|
| P0 | **btnServerSel 移除**（Login 显示了不该显示的服务器选择条） | 5min |
| P1 | **txtHookTime + imgHookTime**（挂机信息显示） | 15min |
| P1 | **btnJumpAutoFight + txtAssist**（自动战斗入口） | 15min |
| P1 | **btnStory 覆盖按钮**（故事区可点击） | 5min |
| P2 | **irole/imgMask**（角色遮罩 — 需要导出资源） | 20min |
| P2 | pnlVersion 拆分为 3 个 Text | 10min |
| P3 | pnlDotsContainer 轮播指示点 | 15min |
| P3 | svChapterReward 章节奖励列表 | 30min |
