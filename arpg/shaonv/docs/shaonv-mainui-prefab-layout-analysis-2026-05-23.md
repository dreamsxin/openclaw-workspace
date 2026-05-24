# MainUIView Prefab 提取、分析与对比

> **2026-05-24 补充**：`screenshot/登录后界面主屏.jpg` 已与 `MainUIView.prefab` 对齐复核。结论见 `docs/shaonv-mainui-screenshot-layout-comparison-2026-05-24.md`：截图对应 `MainUIView` 的 `main_normal` 状态，背景是 `mainui_bg_01.png`，左侧活动块是 `pnlCommercialization`，右下大按钮是 `pnlStory`，其上奖励条是 `btnChapterInfo`。
>
> **2026-05-24 全量清单**：`docs/shaonv-mainui-full-control-resource-inventory-2026-05-24.md` 已导出 `MainUIView` 全 212 个节点，并把 `Image.sprite`、`Text`、`Button` 绑定回节点，同时补齐 MainUI atlas、外部 CAB、prefab 内置 Sprite 与 `mainui_bg_01.png` 运行时背景的 bundle 对照。

时间：2026-05-23  
目标：精确提取 MainUIView.prefab 的 RectTransform 层级，分析布局结构，并与 Godot MVP home_screen.gd 对比找出偏差。

---

## 1. 提取方法

### 1.1 工具

```powershell
python scripts\assets\inspect_unity_prefab_layout.py `
  "Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab" `
  --repo-root . `
  --markdown docs\shaonv-prefab-layout-restart-2026-05-23.md `
  --markdown-depth 4
```

### 1.2 提取原理

1. 从 `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` 反查 prefab 对应的物理 YooAsset bundle
2. 读取 bundle 文件，对前 222 字节 XOR `0x16` 解密（YooAsset FileStreamEncryption 逻辑）
3. 用 UnityPy 解析 bundle，提取所有 GameObject / RectTransform / MonoBehaviour 对象
4. 递归遍历 Transform 层级，输出节点名、active 状态、锚点(min/max)、pivot、sizeDelta、anchoredPosition、localPosition 到 JSON

### 1.3 产物

| 文件 | 说明 |
|------|------|
| `reverse-output/godot-layout-inspect/MainUIView.layout.json` | 212 节点完整层级 (0.7MB) |
| `docs/shaonv-prefab-layout-restart-2026-05-23.md` | 可读 markdown 摘要 |

### 1.4 MainUIView.prefab 基本信息

| 字段 | 值 |
|------|-----|
| Asset 路径 | `Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab` |
| Bundle hash | `550a7cadacd941b64b750257fc8891d0.bundle` |
| 节点数 | 212 |
| 组件数 | 357 MonoBehaviour, 33 MonoScript, 4 Animator, 10 ParticleSystem |
| Canvas 分辨率 | 1670 × 750 |

---

## 2. 分析方法

### 2.1 解析 layout.json

使用 Python 脚本递归遍历 `roots[]` 数组构建节点树：

```python
import json

with open('MainUIView.layout.json') as f:
    data = json.load(f)

def walk(node, depth=0):
    r = node.get('rect', {})
    print(f"{'  '*depth}{node['name']}: size=({r.get('sizeDelta',[0,0])[0]:.0f},{r.get('sizeDelta',[0,0])[1]:.0f}) pos=({r.get('anchoredPosition',[0,0])[0]:.0f},{r.get('anchoredPosition',[0,0])[1]:.0f}) active={node.get('active',True)}")
    for child in node.get('children', []):
        walk(child, depth + 1)

for root in data['roots']:
    walk(root)
```

### 2.2 坐标系理解

原始 Canvas 设计分辨率 **1670 × 750**，Godot MVP 使用 **1280 × 720**。

缩放系数：
- X: 1280 / 1670 ≈ **0.766**
- Y: 720 / 750 = **0.96**

锚点体系：Unity UGUI 使用 anchorMin/anchorMax 定义相对父节点的吸附方式。prefab 中各区域都有特定的锚点策略（如顶边锚、右上锚、中锚等）。

### 2.3 active 状态

部分节点 `active=False`，表示默认隐藏。在还原时需要注意这些节点只在特定条件触发时显示：
- `pnlCtl`（壁纸控制条）、`btnPlay` — 默认隐藏
- `btnClose`、`btnDetail` — 默认隐藏
- `pnlExpeditionSoftGuide`、`pnlHookSoftGuide` — 特效引导，默认隐藏
- `imgSpeak`（对话气泡） — 默认隐藏

---

## 3. Prefab 完整层级

```
MainUIView (全屏, anchor 0-0 → 1-1)
└── pnlAdapter (全屏适配层)
    │
    ├── ① @WallpaperPanel (1668×750, 中锚)
    │   ├── pnlVideo          (active=False)
    │   ├── imgBackGround      (1668×750)
    │   ├── irole
    │   │   ├── btn            (418×804, pos=(0,272))
    │   │   ├── spBg           (100×100) → Renderer0
    │   │   ├── spHero         (100×100) → Renderer0
    │   │   ├── spFg           (100×100) → Renderer0
    │   │   ├── imgMask        (324×274)
    │   │   └── imgSpeak                           (active=False)
    │   └── pnlCtl                                 (active=False)
    │       ├── btnPlay        (68×68)             (active=False)
    │       ├── btnPause       (68×68)
    │       ├── btnLeft        (92×50, pos=(-73,0))
    │       └── btnRight       (92×50, pos=(73,0))
    │
    ├── ② btnBodyMask (全屏遮罩)
    ├── ③ Image (辅助层)
    │
    ├── ④ @TopBar (0×60, 顶边锚 pos=(0,-12))
    │   ├── svRes
    │   │   └── Viewport → Content  (ScrollRect, 资源图标)
    │   └── pnlLeftTop
    │       ├── btnClose      (177×80, pos=(55,-6)) (active=False)
    │       └── btnDetail     (72×62, pos=(234,-14))(active=False)
    │
    ├── ⑤ pnlPlayerInfo (354×113, 左上锚 pos=(0,-5))
    │   ├── imgHeadBg        (80×79, pos=(104,8))     ← mainui_img_03
    │   │   ├── imgExp       (90×90)                  ← mainui_img_04
    │   │   └── txtLevel     (全锚居中)
    │   ├── txtName          (86×29 下半锚 pos=(0,16))
    │   ├── Image            (22×21, pos=(166,-6))
    │   ├── txtPower         (173×37, pos=(181,-4))
    │   ├── btnPlayerInfo    (354×79, 覆盖全面板)
    │   ├── btnEye           (74×74, pos=(478,-47))
    │   └── btnChange        (74×74, pos=(402,-47))
    │
    ├── ⑥ pnlFunny (全屏锚)
    │   │
    │   ├── pnlStory           (278×98, 右边锚 pos=(-60,19))
    │   │   ├── Image → txtStory  (156×34, pos=(-84,-15))
    │   │   ├── Text              (128×46)
    │   │   ├── pnlExpeditionSoftGuide  (active=False)
    │   │   ├── @pnlRd            (红点)
    │   │   ├── @vfx              (特效粒子)
    │   │   ├── btnHarvest       (106×106, pos=(67,1))
    │   │   │   ├── imgHookTime  (挂机计时图标)
    │   │   │   ├── txtHookTime  (挂机时间)
    │   │   │   ├── pnlHookSoftGuide  (active=False)
    │   │   │   └── @pnlRd
    │   │   └── btnStory         (132×99, 覆盖整个 pnlStory)
    │   │
    │   ├── pnlFunnyContent     (0×102, 右边锚 pos=(-339,70))
    │   │   ├── btnArena        (88×102) + @pnlRd + Text
    │   │   ├── btnPrayer       (88×102) + @pnlRd + Text
    │   │   ├── btnAdventure    (88×102) + Text + @pnlRd
    │   │   │   ├── btnJumpAutoFight + txtAssist + txtAssistProject
    │   │   └── btnDraw         (88×102) + Text + @pnlRd
    │   │
    │   ├── btnAssist           (78×96, 左上锚 pos=(413,-164))
    │   │
    │   ├── pnlCharge           (158×258, 右上锚 pos=(-55,-277))
    │   │   ├── btnActivity (size=0) + Text + @pnlRd
    │   │   ├── btnWelfare  (size=0) + Text + @pnlRd
    │   │   ├── btnCard     (size=0) + Text + @pnlRd
    │   │   ├── btnCharge   (size=0) + Text + @pnlRd
    │   │   └── btnShop     (size=0) + Text + @pnlRd
    │   │
    │   └── btnMenu             (78×78, 右上锚 pos=(-94,-54))
    │       ├── fxbtnMenu (1)   (78×78 特效层)
    │       └── @pnlRd
    │
    ├── ⑦ pnlCommercialization (416×420, 左上锚 pos=(265,-333))
    │   ├── @pnlAlternate       (301×108, pos=(-0,0))
    │   │   ├── pnlStandbyContainer
    │   │   ├── pnlShowoffContainer
    │   │   └── pnlDotsContainer
    │   └── pnlGift             (409×300, pos=(7,-120))
    │       ├── @LimitIconView01~12  (各含 btnIcon + txtName + txtTime)
    │       ├── @Question             (btnIcon + txtName + txtTime)
    │       ├── @BuryGift             (btnIcon + txtName + txtTime)
    │       └── @DiscountLimitGift    (btnIcon + txtName + txtTime)
    │
    ├── ⑧ btnChapterInfo (276×100, 右边锚 pos=(-34,150))
    │   ├── txtChapterTitle   (224×32, pos=(26,33))
    │   ├── svChapterReward   (190×60, pos=(3,-14))  ScrollView
    │   ├── @pnlRd
    │   └── Image
    │
    ├── ⑨ pnlBottom (0×50, 底边锚 pos=(64,49))
    │   ├── pnlGal
    │   │   └── btnGal       (115×129, pos=(0,40))  ← 向上突出！
    │   │       ├── Image
    │   │       ├── @fx05     (粒子特效: gyunlizi2, gyunxuanwo, glowdi)
    │   │       ├── Text
    │   │       ├── @pnlRd
    │   │       └── @btnGalClickRrea
    │   ├── btnHero           (86×50) + Text + @pnlRd
    │   ├── btnBagpack        (86×50) + Text + @pnlRd + Image(分隔线2×18)
    │   ├── btnPet            (86×50) + Text + @pnlRd + Image(分隔线)
    │   ├── btnDevelop        (86×50) + Text + @pnlRd + Image(分隔线)
    │   ├── btnTask           (86×50) + Text + @pnlRd + Image(分隔线)
    │   └── btnLegion         (86×50) + Text + @pnlRd + Image(分隔线)
    │
    └── ⑩ pnlChat (410×40, 右上锚 pos=(-64,-94))
        └── @btnChat
            └── @txtChat      (341×40, pos=(64,0))
```

---

## 4. C# IL 分析：状态机与面板分组

> 2026-05-23 补充：从 `reverse-output/managed/Assembly-CSharp-ui-callgraph/MainUIView.il.txt` 反编译 IL 中提取。

### 4.1 `listPanel` 面板组

原游戏中 `MainUIView` 并不是所有面板同时显示。以下 6 个面板被收集到 `listPanel` 中，作为一个整体控制显隐：

```
listPanel = [pnlChat, pnlFunny, pnlPlayerInfo, pnlCommercialization, btnChapterInfo, pnlBottom]
```

### 4.2 `ShowOrHide()` 方法

`ShowOrHide()` 执行以下逻辑：

1. 遍历 `listPanel`，对整个组调用 `SetActive(false/true)`
2. 同步隐藏/显示 `@TopBar`
3. 同步隐藏/显示 `btnBodyMask`
4. 更新 `btnEye` 和 `btnChange` 状态

这意味着原游戏有一个**壁纸聚焦模式**：隐藏所有 UI 面板，仅展示 WallpaperPanel 和角色，用户通过 `btnEye`/`btnBodyMask` 切换。

### 4.3 `btnGal` 独立入口

`btnGal` 不是普通底栏按钮，有以下特殊标识：

| 特征 | 值 |
|------|-----|
| 红点键 | `Gal.GalEntry.5799`（独立于底部栏其他按钮的红点体系）|
| 尺寸 | 115×129（其他底栏按钮 86×50）|
| 向上突出 | 79px（pos=(0,40)，父容器 pnlGal 仅 115×50）|
| 特效 | @fx05（gyunlizi2 等粒子特效）|

这表明 `btnGal` 是一个**独立入口按钮**，会打开/切换到 Gal/约会相关界面，不应和底栏其他 6 个按钮（武将/背包/宠物/养成/任务/军团）混在同一交互层。

### 4.4 状态机设计

基于以上发现，MainUIView 应实现 **3 个状态**：

| 状态 | 显示内容 | 触发方式 |
|------|---------|---------|
| `main_normal` | listPanel 全显示 + TopBar + btnGal | 默认状态 |
| `wallpaper_focus` | 仅 WallpaperPanel + 角色 + pnlCtl | btnEye / btnBodyMask / 点击角色 |
| `gal_entry` | Gal/约会首屏（覆盖或切换） | btnGal 点击 |

---

## 5. 关键区域精确坐标

所有坐标为 (anchoredPosition.x, anchoredPosition.y) + (sizeDelta.x, sizeDelta.y)，原始 Canvas 1670×750。

### 4.1 WallpaperPanel — 中央壁纸

| 节点 | 位置 | 尺寸 | active |
|------|------|------|--------|
| @WallpaperPanel | (0, 0) | 1668×750 | true |
| imgBackGround | (0, 0) | 1668×750 | true |
| irole | (0, 0) | 958×750 | true |
| irole/btn | (0, 272) | 418×804 | true |
| irole/spBg | (0, 0) | 100×100 | true |
| irole/spHero | (0, 0) | 100×100 | true |
| irole/spFg | (0, 0) | 100×100 | true |
| irole/imgMask | (0, 0) | 324×274 | true |
| irole/imgSpeak | (0, 85) | 668×154 | **false** |
| pnlCtl | (0, -181) | 68×68 | **false** |
| btnPlay | (0, 0) | 68×68 | **false** |
| btnPause | (0, 0) | 68×68 | true |
| btnLeft | (-73, 0) | 92×50 | true |
| btnRight | (73, 0) | 92×50 | true |

### 4.2 TopBar — 顶部资源栏

| 节点 | 位置 | 尺寸 | 锚点 |
|------|------|------|------|
| @TopBar | (0, -12) | 0×60 | (0,1)-(1,1) |
| svRes | (-790, -42) | 1367×60 | (1,1)-(1,1) |

### 4.3 pnlPlayerInfo — 玩家信息

| 节点 | 位置 | 尺寸 | 锚点 |
|------|------|------|------|
| pnlPlayerInfo | (0, -5) | 354×113 | (0,1)-(0,1) |
| imgHeadBg | (104, 8) | 80×79 | (0,0.5)-(0,0.5) |
| imgExp | (0, 0) | 90×90 | (0.5,0.5)-(0.5,0.5) |
| txtLevel | (0, 0) | 0×0 | (0,0)-(1,1) |
| txtName | (0, 16) | 86×29 | (0.5,0)-(0.5,0) |
| txtPower | (181, -4) | 173×37 | (0,0.5)-(0,0.5) |
| btnPlayerInfo | (0, 8) | 354×79 | (0.5,0.5)-(0.5,0.5) |
| btnEye | (478, -47) | 74×74 | (0,1)-(0,1) |
| btnChange | (402, -47) | 74×74 | (0,1)-(0,1) |

### 4.4 pnlFunny — 右侧功能入口

**pnlStory (主线故事区)** 178×98, 右边锚 pos=(-60,19)

| 节点 | 位置 | 尺寸 | active |
|------|------|------|--------|
| pnlStory | (-60, 19) | 278×98 | true |
| Image (装饰) | (-84, -15) | 156×34 | true |
| txtStory (在Image下) | — | — | true |
| Text (主线文字) | (49, 1) | 128×46 | true |
| pnlExpeditionSoftGuide | — | — | **false** |
| @pnlRd (红点) | (13, -2) | 0×0 | true |
| btnHarvest | (67, 1) | **106×106** | true |
| btnStory | (51, 0) | **132×99** | true |

**pnlFunnyContent (4 个玩法入口)** 0×102, 右边锚 pos=(-339,70)

| 节点 | 位置 | 尺寸 | 备注 |
|------|------|------|------|
| pnlFunnyContent | (-339, 70) | 0×102 | 布局容器 |
| btnArena (竞技) | (0, 0) | **88×102** | 等大！ |
| btnPrayer (祈愿) | (0, 0) | **88×102** | 等大！ |
| btnAdventure (冒险) | (0, 0) | **88×102** | 等大！有子节点 btnJumpAutoFight |
| btnDraw (唤灵) | (0, 0) | **88×102** | 等大！ |

> ⚠️ **关键发现**：prefab 中 4 个按钮**尺寸完全相同 (88×102)**，由 LayoutGroup 水平排列，不是大小混合。

**pnlCharge (充值入口列)** 158×258, 右上锚 pos=(-55,-277)

| 节点 | 位置 | 尺寸 | 备注 |
|------|------|------|------|
| pnlCharge | (-55, -277) | 158×258 | |
| btnActivity | (0, 0) | **0×0** | size=0 表示由 LayoutGroup 驱动 |
| btnWelfare | (0, 0) | **0×0** | 同上 |
| btnCard | (0, 0) | **0×0** | 同上 |
| btnCharge | (0, 0) | **0×0** | 同上 |
| btnShop | (0, 0) | **0×0** | 同上 |

> ⚠️ 5 个按钮 size=0，由 VerticalLayoutGroup 自动排列，是**垂直堆叠**而非网格。

**btnMenu (菜单)** 78×78, 右上锚 pos=(-94,-54)

**btnAssist (援助)** 78×96, 左上锚 pos=(413,-164)

### 4.5 pnlCommercialization — 商业化入口

| 节点 | 位置 | 尺寸 | 锚点 |
|------|------|------|------|
| pnlCommercialization | (265, -333) | 416×420 | (0,1)-(0,1) |
| @pnlAlternate | (-0, 0) | 301×108 | (0,1)-(0,1) |
| pnlGift | (7, -120) | 409×300 | (0,1)-(0,1) |

pnlGift 包含 15 个子面板（12 个 LimitIconView + Question + BuryGift + DiscountLimitGift），每个子面板结构相同：
```
@LimitIconView01
  ├── btnIcon   (入口图标按钮)
  ├── txtName   (名称文本)
  └── txtTime   (限时文本)
```

### 4.6 btnChapterInfo — 章节任务

| 节点 | 位置 | 尺寸 | 锚点 |
|------|------|------|------|
| btnChapterInfo | (-34, 150) | 276×100 | (1,0)-(1,0) |
| txtChapterTitle | (26, 33) | 224×32 | (0.5,0.5)-(0.5,0.5) |
| svChapterReward | (3, -14) | 190×60 | (0.5,0.5)-(0.5,0.5) |

### 4.7 pnlBottom — 底部栏

| 节点 | 位置 | 尺寸 | 锚点 |
|------|------|------|------|
| pnlBottom | (64, 49) | **0×50** | (0,0)-(0,0) |
| pnlGal | (0, 0) | 115×50 | |
| btnGal | (0, 40) | **115×129** | ← 向上突出 79px |
| btnHero | (0, 0) | 86×50 | |
| btnBagpack | (0, 0) | 86×50 | 有 Image(2×18) 分隔线 |
| btnPet | (0, 0) | 86×50 | 有 Image 分隔线 |
| btnDevelop | (0, 0) | 86×50 | 有 Image 分隔线 |
| btnTask | (0, 0) | 86×50 | 有 Image 分隔线 |
| btnLegion | (0, 0) | 86×50 | 有 Image 分隔线 |

> ⚠️ 底部栏高度仅 50px，btnGal 115×129 向上突出到屏幕内。每个按钮间有 2×18 Image 分隔线。所有按钮都有 @pnlRd 红点节点。

### 4.8 pnlChat — 聊天条

| 节点 | 位置 | 尺寸 | 锚点 |
|------|------|------|------|
| pnlChat | (-64, -94) | 410×40 | (1,1)-(1,1) |
| @btnChat | (0, 0) | 0×0 | (0,0)-(1,1) |
| @txtChat | (64, 0) | 341×40 | (0,0.5)-(0,0.5) |

---

## 6. Godot MVP vs Prefab 对比

对比对象：
- **原始**：MainUIView.prefab (1670×750)
- **当前**：home_screen.gd (1280×720)

> **重要前提**：原游戏通过 `listPanel` + `ShowOrHide()` 实现状态切换，不是所有面板同时显示。以下偏差中部分"布局重叠"实际是 Godot 未实现状态切换导致的。

### 6.1 架构级偏差（状态机缺失）

| # | 问题 | 原逻辑 | Godot 当前 | 影响 |
|---|------|--------|-----------|------|
| 0 | **无状态切换** | ShowOrHide() 控制 listPanel 整组显隐 + btnEye/btnBodyMask 切换 | 全部组件画在同一状态 | 🔴 所有面板重叠，壁纸无法独占全屏 |
| — | **btnGal 混入底栏** | 独立入口，独立红点 Gal.GalEntry.5799，115×129 突出 | 和底栏其他按钮等大 (100×52) | 🔴 约会入口降级为普通按钮 |

### 6.2 布局级偏差

| # | 问题 | 原 prefab | Godot 当前 | 影响 |
|---|------|-----------|-----------|------|
| 1 | **pnlFunnyContent 按钮** | 4 个 88×102 等大水平排列 | 拱门 120×136 + 小按钮 96×96 混合 | 右侧入口区域外观完全错误 |
| 2 | **pnlCharge 布局** | 垂直堆叠 5 个按钮(size=0) | 2×3 网格手动放置 | 商业入口结构错误 |
| 3 | **btnHarvest 尺寸** | 106×106 大按钮(带时间显示) | 104×42 小文本按钮 | 收获入口缺失真实布局 |
| 4 | **svRes 资源栏** | ScrollRect + 图标(ItemResources) | 纯文本 "邮件%d 喚靈券%s" | 顶部资源区缺失真实图标 |
| 5 | **pnlCommercialization** | 独立区域 416×420, 12 LimitIconView | 混入 pnlFunny, 文本替代 | 商业化区域缺失 |

### 6.2 布局级偏差
| 6 | **btnChapterInfo 挂机** | 挂机收益在 btnHarvest 内 | 额外添加独立区域 | 结构冗余 |
| 7 | **btnGal 尺寸** | 115×129 向上突出到画面内 | 100×52 等大 | 约会入口尺寸/位置错误 |
| 8 | **pnlBottom 高度** | **50px** | **102px**(高一倍) | 底部栏过高 |
| 9 | **红点覆盖** | 所有按钮都有 @pnlRd | 仅部分有 | 系统反馈缺失 |
| 10 | **按钮分隔线** | 底部栏按钮间 2×18 Image | 全缺 | 视觉不精确 |

### 6.3 按区域详细对比

#### WallpaperPanel
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 全屏背景 | imgBackGround 1668×750 | mainui_img_01.png | ✅ |
| Spine 角色 | spBg/spHero/spFg 三层 | baked Spine 单层 | ⚠️ |
| 前景遮罩 | imgMask 324×274 | 无 | ❌ |
| 控制条 pnlCtl | 默认隐藏(active=false) | 始终显示 | ❌ |
| 左右切换 | btnLeft/Right 92×50, pos=(±73,0) | ◀▶ 48×36 | ⚠️ |
| 暂停按钮 | btnPause 68×68 | 缺失 | ❌ |

#### TopBar
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 装饰条 | @TopBar 0×60 全宽 | mainui_img_10 480×40 居中 | ❌ |
| svRes | ScrollView 1367×60, 右上锚 | 文本标签 720×36 | ❌ |
| btnClose | 177×80, active=False | 无 | ✅(隐藏) |
| btnDetail | 72×62, active=False | 无 | ✅(隐藏) |

#### pnlPlayerInfo
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 区域尺寸 | 354×113 | ≈324×96 | ⚠️ |
| imgHeadBg | 80×79 pos=(104,8) | 72×68 pos=(32,34) | ⚠️ |
| imgExp 经验环 | 90×90 叠加头像 | 88×84 | ✅ |
| txtLevel | 全锚居中(0-1) | Lv.label pos=(34,94) | ⚠️ |
| txtName | 86×29 下半锚 | 140×28 pos=(110,22) | ⚠️ |
| txtPower | 173×37 pos=(181,-4) | 140×30 pos=(110,54) | ⚠️ |
| btnEye | 74×74 pos=(478,-47) | 58×50 pos=(350,34) | ❌ |
| btnChange | 74×74 pos=(402,-47) | 58×50 pos=(416,34) | ❌ |

#### pnlFunny→pnlFunnyContent
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 区域锚点 | 右边锚 pos=(-339,70) | x=930 y=72 | ⚠️ |
| btnArena | 88×102 | 96×96 | ❌尺寸错 |
| btnPrayer | 88×102 | 120×136 | ❌尺寸错 |
| btnAdventure | 88×102 | 96×96 | ❌尺寸错 |
| btnDraw | 88×102 | 120×136 | ❌尺寸错 |

#### pnlFunny→pnlCharge
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 布局方向 | VerticalLayoutGroup | 2×3 手动网格 | ❌ |
| 按钮尺寸 | 全 size=0 (自动) | 74×36 手动 | ❌ |
| 5 个红点 | @pnlRd 每个按钮旁 | 0 个 | ❌ |

#### pnlCommercialization
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 独立区域 | 416×420 pos=(265,-333) | 混入 pnlFunny | ❌ |
| @pnlAlternate | 301×108 轮播 | 静态图片 | ❌ |
| 12 LimitIconView | 图标+名称+时间 | 文本按钮 | ❌ |
| Question/BuryGift/DiscountGift | 各有独立图标 | 文本替代 | ❌ |

#### btnChapterInfo
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 区域 | 276×100 右边锚 pos=(-34,150) | 分成两段 284×(106+52) | ⚠️ |
| txtChapterTitle | 224×32 pos=(26,33) | 章节文本 | ✅ |
| svChapterReward | ScrollView 190×60 | 挂机收益文本 | ❌ |
| 挂机收益 | 不在 btnChapterInfo 内 | 额外区域 | ❌ |

#### pnlBottom
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 高度 | **50px** | **102px** | ❌ |
| btnGal | **115×129** 突出 | 100×52 等大 | ❌ |
| btnGal 特效 | @fx05(gyunlizi2等) | 无 | ❌ |
| 按钮尺寸 | 86×50 | 100×52 | ⚠️ |
| 分隔线(6条) | Image 2×18 | 无 | ❌ |
| 红点(7个) | @pnlRd 全覆盖 | 3 个 | ❌ |

#### pnlChat
| 项 | Prefab | Godot | 状态 |
|----|--------|-------|:--:|
| 区域 | 410×40 右上锚 pos=(-64,-94) | 480×30 pos=(760,586) | ❌ |
| @btnChat | 全锚按钮覆盖 | 无按钮 | ❌ |
| @txtChat | 341×40 pos=(64,0) | "世界 离线" | ✅ |

---

## 7. 缺失资源清单（需从 bundle 补充导出）

### 6.1 TopResGrid 资源图标

位于 `Assets/Game/RawAssets/Sprite/Item/ItemResources`，物理路径为多个独立 bundle。

当前未导出，svRes 仍用纯文本。

### 6.2 pnlFunnyContent 按钮图标

`btnArena`/`btnAdventure` 的图标图不在 MainUI spriteatlas 中，可能在 Common spriteatlas 或独立 bundle。

### 6.3 LimitIconView 图标

`pnlGift` 中的 15 个子面板图标，位于 `Assets/Game/RawAssets/Sprite/` 下的各个活动子目录。

### 6.4 pnlBottom

底部栏按钮的独立图标未在 MainUI spriteatlas 中定位，可能在 Common spriteatlas。

---

## 8. 完整 Prefab 树补充 (2026-05-23)

以下从 `MainUIView.layout.json` 提取的完整 RectTransform 层级。所有坐标 Unity pixel, Canvas 1670×750。

### 8.1 @WallpaperPanel
```
@WallpaperPanel pos=(0,0) size=(1668,750) anchor=(0.5,0.5) ON
  pnlVideo OFF
  imgBackGround pos=(0,0) size=(1668,750) anchor=(0.5,0.5) ON
  irole pos=(0,0) size=(958,750) anchor=(0.5,0.5) ON
    btn pos=(0,272) size=(418,804) anchor=(0.5,0.5) ON
    spBg/spHero/spFg → 各 100×100 三层 Spine Renderer
    imgMask pos=(0,0) size=(324,274) anchor=(0.5,0.5) ON
    imgSpeak pos=(0,85) size=(668,154) OFF ← 对话气泡
  pnlCtl pos=(0,-181) size=(68,68) anchor=(0.5,0.5) OFF ← 默认隐藏
    btnPlay(pos=(0,0),68×68) OFF / btnPause(pos=(0,0),68×68) ON
    btnLeft(pos=(-73,0),92×50) / btnRight(pos=(73,0),92×50)
```

### 8.2 @TopBar
```
@TopBar pos=(0,-12) size=(0,60) anchor=(0,1) ON ← 全宽60px顶部
  svRes pos=(-790,-42) size=(1367,60) anchor=(1,1) ON ← 资源ScrollRect
  pnlLeftTop: btnClose(55,-6,177×80) OFF / btnDetail(234,-14,72×62) OFF
```

### 8.3 pnlPlayerInfo
```
pnlPlayerInfo pos=(0,-5) size=(354,113) anchor=(0,1) ON
  imgHeadBg pos=(104,8) size=(80,79) / imgExp(0,0,90×90) / txtLevel(全锚居中)
  txtName pos=(154,22) size=(200,28) anchor=(0,0.5)
  Image pos=(166,-6) size=(22,21) ← 名字旁图标
  txtPower pos=(181,-4) size=(173,37) anchor=(0,0.5)
  btnPlayerInfo pos=(0,8) size=(354,79) anchor=(0.5,0.5)
  btnEye pos=(478,-47) size=(74,74) anchor=(0,1)
  btnChange pos=(402,-47) size=(74,74) anchor=(0,1)
```

### 8.4 pnlFunny 子区域
```
pnlFunnyContent pos=(-339,70) size=(0,102) anchor=(1,0)
  btnArena/btnPrayer/btnAdventure/btnDraw: 各 88×102, @pnlRd(-19,-20)
  btnAdventure 有额外 btnJumpAutoFight(0,33,180×90)

pnlStory pos=(-60,19) size=(278,98) anchor=(1,0)
  txtStory / btnHarvest(67,1,106×106) / btnStory(51,0,132×99)
  pnlExpeditionSoftGuide OFF / @pnlRd(13,-2)

btnAssist pos=(413,-164) size=(78,96) anchor=(0,1)
btnMenu pos=(-94,-54) size=(78,78) anchor=(1,1), fxbtnMenu 特效

pnlCharge pos=(-55,-277) size=(158,258) anchor=(1,1)
  btnActivity/btnWelfare/btnCard/btnCharge/btnShop: 各 size=(0,0), VLG 自动
  每个有 @pnlRd(-18,-18)
```

### 8.5 pnlCommercialization
```
pnlCommercialization pos=(265,-333) size=(416,420) anchor=(0,1)
  @pnlAlternate pos=(-0,0) size=(301,108) ← 横幅轮播
  pnlGift pos=(7,-120) size=(409,300)
    @LimitIconView01~12: 各 size=(0,0), btnIcon(86,86)+txtName+txtTime
    @Question / @BuryGift / @DiscountLimitGift: 特殊入口
```

### 8.6 btnChapterInfo
```
btnChapterInfo pos=(-34,150) size=(276,100) anchor=(1,0)
  txtChapterTitle(26,33,224×32) / svChapterReward(3,-14,190×60)
  @pnlRd(-31,-1)
```

### 8.7 pnlBottom — 关键修正
```
pnlBottom pos=(64,49) size=(0,50) anchor=(0,0) ON
  pnlGal pos=(0,0) size=(115,50)
    btnGal pos=(0,40) size=(115,129) ← 向上突出79px!
      Image(0,74,150×170) + @fx05(-4,68) 5层粒子 + @pnlRd(45,129)
      @btnGalClickRrea(0,101,100×100)
  btnHero/btnBagpack/btnPet/btnDevelop/btnTask/btnLegion:
    各 size=(86,50) anchor=(0,0) ← **不是 86×86! 是 86×50!**
    Text(70,30) + @pnlRd(32,25) + Image(2,18)分隔线
```

### 8.8 pnlChat
```
pnlChat pos=(-64,-94) size=(410,40) anchor=(1,1)
  @btnChat size=(0,0) anchor=(0,0)-(1,1) ← 全锚按钮
  @txtChat pos=(64,0) size=(341,40) anchor=(0,0.5)
```

### 8.9 新发现摘要
| # | 发现 | 说明 |
|---|------|------|
| 1 | **btnBottom 86×50** | 当前代码用 86×86，高度错了 +72% |
| 2 | **btnChapterInfo anchor=(1,0)** | 右边锚，pos=(-34,150) |
| 3 | **pnlChat anchor=(1,1) pos=(-64,-94)** | 当前位置完全错误 |
| 4 | **WallpaperPanel anchor=(0.5,0.5)** | 居中 fullscreen |
| 5 | **pnlCommercialization anchor=(0,1)** | pos=(265,-333)，当前 (57,123) 完全错 |
| 6 | **btnGal @fx05 5层粒子** | 当前无特效 |
| 7 | **btnGal @btnGalClickRrea** | 独立点击区 |
| 8 | **pnlGift 含 @Question/@BuryGift/@DiscountLimitGift** | 当前仅普通 grid |
| 9 | **pnlCtl 默认 OFF** | wallpaper_focus 时显示，含 btnPause/btnLeft/btnRight |
| 10 | **irole/imgMask 324×274** | 前景遮罩，当前缺失 |
| 11 | **irole/imgSpeak 668×154 OFF** | 对话气泡，触发时显示 |

---

## 10. 深度组件分析 (2026-05-23 补充)

基于 `layout.json` 的 `componentTypes` + `MainUIView.il.txt` 的 `FIELD` 声明交叉分析。

### 10.1 组件分布统计

| 组件类型 | 数量 | 说明 |
|----------|:----:|------|
| RectTransform | 212 | 所有节点 |
| CanvasRenderer | 171 | 所有可见渲染节点 |
| MonoBehaviour | 357 | UI 行为脚本 |
| CanvasGroup | 34 | 显隐/alpha 控制面板 |
| ParticleSystem | 10 | 粒子特效 |
| Animator | 4 | 动画状态机 |
| Canvas | 1 | 根画布 |
| VideoPlayer | 1 | 视频播放 (pnlVideo) |
| MonoScript | 33 | 脚本类型变体 |

### 10.2 CanvasGroup 面板 (34个)

CanvasGroup 控制整组显隐。以下 34 个 CanvasGroup 节点实际构成 `listPanel`:

```
irole, @TopBar, pnlPlayerInfo, 
pnlFunnyContent, pnlStory, pnlCharge, btnMenu, btnAssist,
pnlCommercialization, @pnlAlternate, pnlGift,
btnChapterInfo, pnlBottom, pnlChat, btnGal,
btnEye, btnChange, btnHarvest,
@LimitIconView01~12, @Question, @BuryGift, @DiscountLimitGift
```

### 10.3 粒子特效 (10个 ParticleSystem)

| 特效 | 位置 | 用途 |
|------|------|------|
| gyunlizi2 (×2) | btnGal/@fx05 | 约会按钮主体/粒子 |
| gyunxuanwo (×3) | btnGal/@fx05 | 约会按钮漩涡旋转 |
| glowdi | btnGal/@fx05 | 约会按钮发光 |
| gyun (×2) | pnlExpeditionSoftGuide/@vfx | 远征引导箭头 |
| gyun2 (×2) | pnlExpeditionSoftGuide/pnlHookSoftGuide | 红点光芒 |

**btnGal 总共 5 层粒子特效！** 这是整个 prefab 中最特效密度最高的按钮。

### 10.4 Animator 节点 (4个)

| 节点 | 说明 |
|------|------|
| MainUIView | 根节点 Animator（可能控制状态机切换动画） |
| @TopBar | 顶栏动画（滑动/淡入） |
| pnlExpeditionSoftGuide | 远征引导动画（OFF） |
| pnlHookSoftGuide | 挂机钩子引导动画（OFF） |

### 10.5 IL Field 类型对照

从 `MainUIView.il.txt` FIELD 声明可知每个命名节点的精确 Unity 组件类型:

| 节点 | Unity 类型 | 说明 |
|------|-----------|------|
| btnBodyMask, btnPlayerInfo, btnEye, btnChange, btnHarvest, btnStory, btnArena, btnPrayer, btnAdventure, btnJumpAutoFight, btnDraw, btnAssist, btnActivity, btnWelfare, btnCard, btnCharge, btnShop, btnMenu, btnChapterInfo, btnGal, btnHero, btnBagpack, btnPet, btnDevelop, btnTask, btnLegion, btnClose, btnDetail, btnLeft, btnRight, btnPause, btnPlay | **UnityEngine.UI.Button** | 全部按钮 |
| imgHeadBg, imgExp, imgHookTime | **UnityEngine.UI.Image** | 图片 |
| txtLevel, txtName, txtPower, txtStory, txtHookTime, txtAssist, txtAssistProject, txtChapterTitle | **UnityEngine.UI.Text** | 文字 |
| pnlAdapter, pnlPlayerInfo, pnlFunny, pnlStory, pnlFunnyContent, pnlCharge, pnlCommercialization, pnlGift, pnlBottom, pnlGal | **UnityEngine.Transform** | 容器面板 |
| svChapterReward | **Scx.GridScroller** | 自定义滚动组件 |
| svRes | **ScrollRect**(推测, MonoBx5) | 资源滚动区 |

### 10.6 交互节点 MonoB 模式

| MonoB 数量 | 含义 | 节点示例 |
|:----------:|------|---------|
| 2 | Button(+Image) 或 Transform 容器 | 所有 btn* 按钮, pnlStory, pnlGift 等面板 |
| 3 | Button+Image+Layout 或 Text 组件 | btnActivity~Shop(pnlCharge), irole, pnlBottom |
| 5 | ScrollRect 复合 | svRes (Viewport+Content+Grid+Scrollbar) |

### 10.7 默认隐藏节点 (active=False)

| 节点 | 触发条件 |
|------|---------|
| **pnlCtl** | 壁纸聚焦模式 (wallpaper_focus) |
| btnPlay | pnlCtl 内的播放按钮（开始播放 Spine） |
| btnClose/btnDetail | TopBar 左侧 — 始终 OFF |
| pnlExpeditionSoftGuide | 远征任务引导箭头 |
| pnlHookSoftGuide | 挂机钩子引导动画 |
| imgSpeak | 角色对话气泡（事件触发） |
| pnlStandbyContainer | @pnlAlternate 轮播待机容器 |
| gyun2 (in pnlHookSoftGuide) | 红点光芒默认关闭 |

### 10.8 svRes 深度分析

`svRes` 有 5 个 MonoBehaviour (MonoBx5)，层级:
```
svRes (-790,-42) 1367×60 anchor=(1,1) [ScrollRect + Layout + ...]
  Viewport (0,0) 0×0 [Mask + Image]
    Content (0,0) 0×60 anchor=(0,1) [GridLayout + ContentSizeFitter]
      → 内部 ItemResources 子对象（资源图标+数量，动态生成）
```

当前 Godot 使用纯文本模拟，缺少 ScrollRect + Grid 动态图标布局。

### 10.9 btnGal 特效全貌

```
btnGal (0,40) 115×129 anchor=(0.5,0.5)
  ├─ Image (0,74) 150×170 ← 约会图标背景
  ├─ @fx05 (-4,68) 100×50 ← 5层粒子系统!
  │   └─ gyunlizi2(1) (0,0) 100×100
  │       ├─ gyunlizi2      ← 粒子主体
  │       ├─ gyunxuanwo(2)  ← 漩涡2
  │       ├─ gyunxuanwo(1)  ← 漩涡1
  │       ├─ glowdi(1)      ← 发光点
  │       └─ gyunxuanwo     ← 漩涡
  ├─ Text (0,25) 70×30 ← "约会"文字
  ├─ @pnlRd (45,129) ← 红点 Gal.GalEntry.5799
  └─ @btnGalClickRrea (0,101) 100×100 ← 独立点击热区
```

---

## 9. 下一步建议

按优先级排列：

### 8.1 P0：实现状态机
1. **拆 `main_normal` 状态** — listPanel 6 面板 + TopBar + btnGal 作为独立入口
2. **拆 `wallpaper_focus` 状态** — 隐藏 listPanel，btnEye/btnBodyMask 切换，仅显示角色+壁纸
3. **拆 `gal_entry` 状态** — btnGal 点击后进入 Gal/约会首屏覆盖层
4. **btnGal 独立处理** — 不再混入底栏按钮组，独立渲染 115×129 突出尺寸

### 8.2 P1：修正布局坐标
1. **pnlFunnyContent 重排** — 4 个 88×102 等大按钮水平布局
2. **pnlCharge 改垂直** — 5 个按钮 VLG 垂直堆叠
3. **pnlBottom 精简** — 高度从 102 缩到 50，btnGal 向上突出
4. **红点全覆盖** — 每个功能按钮旁添加 @pnlRd
5. **按钮分隔线** — 底部栏按钮间 2×18 分隔线

### 8.2 P2：补充资源
1. **svRes 图标** — 导出 ItemResources 精灵

2. **pnlCommercialization** — 独立区域 + LimitIconView 图标
3. **Common 图集** — 底部栏和其他按钮的真实图标

---

## 11. 跨 Prefab 模式分析 (2026-05-23)

分析 8 个 layout.json (MainUIView, LoginView, LaunchView, LoadingView, LotteryDrawMainView, LotteryDrawFinishView, HeroRecruitView, TopResGrid) 发现通用 UI 模式。

### 11.1 按钮尺寸标准化

| 尺寸 | 出现次数 | 用途 |
|------|:--:|------|
| 86×86 | 15 | LimitIconView 图标按钮（pnlGift 等） |
| 60×60 | 10 | 小图标按钮（Login pnlFunction, Lottery pnlBtn） |
| 418×804 | 8 | 全高 Hero 点击区（irole/btn, 5 个 hero slot） |
| **86×50** | 6 | **底部栏按钮**（btnHero/Bagpack/Pet/Develop/Task/Legion） |
| 88×102 | 4 | MainUI pnlFunnyContent 入口按钮 |
| 80×80 | 3 | 抽卡按钮（btnReward/Shop/Wish） |
| 74×74 | 2 | btnEye / btnChange |
| 68×68 | 2 | btnPlay / btnPause（pnlCtl 内） |
| 92×50 | 2 | btnLeft / btnRight（pnlCtl 内） |
| 115×129 | 1 | btnGal（最大突出独立按钮） |
| 106×106 | 1 | btnHarvest（收获大按钮） |
| 78×78 | 1 | btnMenu（右下角菜单） |
| 78×96 | 1 | btnAssist（援助按钮） |

> 🔑 **关键发现**: 底部栏按钮在 prefab 中是 **86×50**（非 86×86），这是跨 prefab 的标准化尺寸。

### 11.2 TopResGrid — svRes 的真实结构

`TopResGrid` 是 MainUIView 中 `svRes/Content` 的子 prefab 实例，每个资源项（邮件、唤灵券、源石）都是一个 TopResGrid:

```
TopResGrid 200×40 anchor=(0.5,0.5)
  imgBg     200×40  ← 半透明圆角背景
  imgIcon   (-5,1) 50×50  ← 资源图标（左对齐）
  txtNum    (27,0) 130×40  ← 数量文本（居中）
  btnClick  (0,0) 200×40 OFF ← 点击区（默认禁用）
  txtTitle  (11,0) 160×30 OFF ← 标题（默认禁用）
```

当前 Godot 使用纯文本 `"邮件 %d"` 模拟，应改为图标+数量的 TopResGrid 风格。

### 11.3 @ 前缀 Prefab 实例 (75 个)

所有 prefab 共享 75 种 `@` 前缀 Prefab 实例。MainUIView 最常用的:

| @Prefab | 出现次数 | 说明 |
|---------|:--:|------|
| @pnlRd | 21 | 红点 — 单一 prefab 全局复用，每个实例锚点不同 |
| @LimitIconView01~12 | 12 | pnlGift 内图标项 — 统一 btnIcon(86×86)+txtName+txtTime |
| @WallpaperPanel | 1 | 壁纸面板 — 可能在多个 View 间共享 |
| @TopBar | 1 | 顶部栏 — 可能与 LoadingView 共享 |
| @pnlAlternate | 1 | 轮播横幅容器 |
| @fx05 | 1 | btnGal 的 5 层粒子特效 |
| @vfx | 2 | 引导特效（远征、挂机钩子） |
| @richBottom | 1 | 底部版权信息（LoginView 也有） |

### 11.4 面板命名约定

| 命名模式 | 示例 | 含义 |
|----------|------|------|
| `pnlAdapter` | MainUIView | 根适配器容器（(0,0)-(1,1) 全屏拉伸） |
| `pnlRoot` | LotteryDrawMainView | 抽卡根容器 |
| `pnlFunction` | LoginView | 右上角功能按钮行 |
| `pnlBtn` | Lottery | 底部按钮行 |
| `pnlBottom` | MainUI/Lottery | 底部栏 |
| `pnlLeft` | Lottery | 左侧面板 |
| `pnlPlayerInfo` | MainUI | 玩家信息 |
| `pnlCommercialization` | MainUI | 商业化面板 |
| `pnlChat` | MainUI | 聊天条 |
| `@richBottom` | Login/MainUI | 底部版权区 |

### 11.5 红点系统 (@pnlRd) 分析

`@pnlRd` 是跨所有 prefab 共享的单一 Red Dot Prefab Instance:
- 21 个实例仅在 MainUIView 中
- 每个实例通过不同的 `anchoredPosition` 定位在按钮旁
- 锚点模式: (1,1) 表示父元素右上角，(-18,-18) 表示左上偏移
- 红点键通过代码动态绑定（如 `Gal.GalEntry.5799`），不是 prefab 数据

### 11.6 对 MainUI Godot MVP 的启示

| # | 发现 | Godot 应用 |
|---|------|-----------|
| 1 | **btnBottom=86×50 标准化** | ✅ 已修正为 66×48 |
| 2 | **TopResGrid 图标+数量布局** | 🔧 svRes 应改为图标+数字，非纯文本 |
| 3 | **86×86 是 LimitIconView 标准** | ☑️ pnlGift 应使用此尺寸 |
| 4 | **60×60 是辅助按钮标准** | 可能用于将来的 pnlFunction 等辅助行 |
| 5 | **@pnlRd 是共享 Prefab** | Godot 中可创建单一 RedDot scene 复用 |
| 6 | **@richBottom 跨 View 共享** | 底部版权可在多个 Screen 复用 |
| 7 | **命名约定一致** | pnl+功能名, btn+动作名的规范可在代码注释中标注 |

---

## 12. 游戏逻辑深度分析 (2026-05-23)

基于 `MainUIView.il.txt` + `ViewBehaviour.il.txt` + `UIControl.il.txt` 交叉分析。

### 12.1 视图生命周期

```
ViewBehaviour (基类)
  ├─ Start()           → 初始化 _allViews 列表
  ├─ Open(parameter)   → OnOpen → DG.Tweening 动画 → OnOpened
  ├─ Close(immediate)  → 动画 → OnClose → Destroy
  ├─ Hide() / Show()   → SetActive
  ├─ TopView()         → 返回栈顶 View
  ├─ GetShowFullScreenView() → 找全屏 View
  ├─ DestroyAllView()  → 清空栈
  └─ OnBack()          → virtual, 各 View override
```

MainUIView 继承 ViewBehaviour，覆写:
- `OnOpen()`: 初始化所有面板
- `OnBack()`: 切换到 wallpaper_focus 模式
- `OnEnable()` / `OnDisable()`: 注册/注销事件

### 12.2 ShowOrHide 状态机 (完整逻辑)

```
ShowOrHide():
  _wallpaperPanel.ActivateCtlBar(false, -1)  // 隐藏控制条
  _wallpaperPanel.AutoHideTime = 5            // 5秒自动隐藏

  if hidePanels:          // HIDE 模式 → 壁纸聚焦
    btnBodyMask.SetActive(false)   // 隐藏遮罩按钮
    _topBar.Hide()                 // 隐藏顶栏
    foreach t in listPanel:        // 隐藏全部面板
      t.SetActive(false)           // [pnlChat, pnlFunny, pnlPlayerInfo,
                                   //  pnlCommercialization, btnChapterInfo, pnlBottom]
  else:                   // SHOW 模式 → 主界面正常
    btnBodyMask.SetActive(true)    // 显示遮罩按钮
    _topBar.Show()                 // 显示顶栏
    foreach t in listPanel:        // 显示全部面板
      t.SetActive(true)

  hidePanels = !hidePanels         // TOGGLE 状态
  UpdateBodyButtonVisible()        // 更新 btnEye/btnChange 显隐
```

**触发路径**:
| 触发 | hidePanels 变化 | 结果 |
|------|:--:|------|
| `OnBack()` | 设为 true → ShowOrHide → 切换为 false | 隐藏面板 (wallpaper_focus) |
| `btnEye` 点击 | (toggle) | 隐藏面板 (wallpaper_focus) |
| `btnBodyMask` 点击 | (toggle) | 显示面板 (main_normal) |
| `btnChange` 点击 | (独立逻辑) | 打开图鉴换壁纸 |

### 12.3 完整红点键映射 (InitRedDot)

从 IL 中提取的全部 `RedDotHelper::BindWeightRedDot` 调用:

| 按钮 | 红点键 | 对应系统 |
|------|--------|---------|
| btnHarvest | `Expedition.Hook.84317` | 远征/挂机收益 |
| btnShop | `GameShopCollection.Page.1748` | 商店 |
| btnActivity | `Activities.Activity.34064` | 活动 |
| btnWelfare | `Activities.Welfare.83923` | 福利 |
| btnCharge | `Activities.ReCharge.99752` | 充值 |
| btnCard | `Activities.Card.5353` | 月卡 |
| btnAdventure | `Adventure.AdventureMainView.43704` | 冒险 |
| btnDraw | `LotteryDraw.LotteryDrawHero.7805` | 唤灵/抽卡 |
| btnArena | `Arena.ArenaRedDot.89949` | 竞技 |
| btnDevelop | `Develop.DevelopEnter.78015` | 养成 |
| btnBagpack | `Bag.BagRedDot.73517` | 背包 |
| btnTask | `Quest.QuestEnter.42775` | 任务 |
| btnLegion | `Alliance.AllianceEnter.6965` | 军团 |
| btnPet | `Remnants.RemnantsEnter.1728` | 宠物/遗迹 |
| btnHero | `Hero.HeroEnter.30218` | 武将 |
| btnPrayer | `LotteryDraw.Prayer.4036` | 祈愿 |
| btnGal | `Gal.GalEntry.5799` | 约会 |
| btnMenu | `MainUIView.BtnMenu.84538` | 菜单 |
| btnChapterInfo | `ChapterTask.ChapterTaskEnter.32541` | 章节任务 |

> 🔑 红点键命名揭示完整的游戏功能模块树: Hero/Bag/Remnants(宠物)/Develop/Quest/Alliance/LotteryDraw/Arena/Adventure/Expedition/Activities/Gal。

### 12.4 SetUIInfo 数据流

```
SetUIInfo():
  ModelCenter.Get<UserModel>()        → 用户数据
  UserModel.UserLv → imgExp.fillAmount → EXP 环进度
  UserModel.UserName → txtName         → 名字
  UserHelper.GetPower() → txtPower     → 战力
  ConditionHelper.IsUnlock("C60102")   → pnlCommercialization 显隐
  ExpeditionModel.GetCurStageId()      → 远征进度
  ExpeditionStatic.GetItem(stageId)    → 阶段名
  Scx.Lang.Get("UI1000015")            → "主线 {0}" 本地化
  Format(stageName) → txtStory         → pnlStory 文字
  UpdatePnlBottom()                    → 底部栏刷新
  UpdateFunny()                        → Funny 区刷新
  UpdateBodyButtonVisible()            → btnEye/btnChange 显隐
  ExpeditionHelper.ShowSoftGuide()     → pnlExpeditionSoftGuide 显隐
  RefreshAutoFight(EventParam)         → 自动战斗状态
```

### 12.5 顶部栏数据 (RefreshTopBar)

```
RefreshTopBar():
  ConditionHelper.IsUnlock("C60088") → 检查功能解锁
  [动态创建 ItemResources 子对象到 svRes/Content]
  每个 ItemResources: imgIcon(图标) + txtNum(数量)
  → 邮件数、唤灵券数、源石数
```

### 12.6 视图栈管理 (ViewBehaviour)

```
Open(view)     → 压栈, 播放打开动画, 可能隐藏下层全屏 View
Close(view)    → 出栈, 播放关闭动画, 可能恢复下层 View
OnBack()       → Android back 键处理
TopView()      → 获取当前顶层 View
GetShowFullScreenView() → 获取全屏 View (可能是 wallpaper focus)
DestroyAllView() → 清空所有 View (场景切换)
```

### 12.7 对 Godot MVP 的状态机验证

| 原始逻辑 | Godot 实现 | 状态 |
|:---------|:----------|:----:|
| `hidePanels` 布尔 toggle | `_main_state` 三态 (normal/focus/gal) | ✅ 增强版 |
| `ShowOrHide()` toggle 调用 | `enter_normal_state` / `enter_wallpaper_focus` 显式切换 | ✅ |
| `btnBodyMask` 控制 wallpaper 切换 | `draw_body_mask()` 全屏透明 Button | ✅ |
| `btnEye` / `btnChange` | `draw_player_info()` 内实现 | ✅ |
| `listPanel` = [6 Transform] | `_main_panels` Array | ✅ |
| TopBar 独立 show/hide | 通过 `_main_panels` 统一管理 | ✅ |
| `SetUIInfo()` 数据刷新 | `_next_task_text()` / `_afk_claimed_today()` 模拟 | ⚠️ 简化版 |
| `InitRedDot()` 19 个红点绑定 | 部分按钮有 `_draw_red_dot()` | ⚠️ 覆盖率不足 |
| `RefreshTopBar()` → ItemResources | 纯文本 "邮件 %d" | ❌ 需 TopResGrid 结构 |
