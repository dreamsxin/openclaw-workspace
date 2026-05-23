# MainUIView Prefab 提取、分析与对比

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

## 4. 关键区域精确坐标

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

## 5. Godot MVP vs Prefab 对比

对比对象：
- **原始**：MainUIView.prefab (1670×750)
- **当前**：home_screen.gd (1280×720)

### 5.1 十大偏差

| # | 问题 | 原 prefab | Godot 当前 | 影响 |
|---|------|-----------|-----------|------|
| 1 | **pnlFunnyContent 按钮** | 4 个 88×102 等大水平排列 | 拱门 120×136 + 小按钮 96×96 混合 | 右侧入口区域外观完全错误 |
| 2 | **pnlCharge 布局** | 垂直堆叠 5 个按钮(size=0) | 2×3 网格手动放置 | 商业入口结构错误 |
| 3 | **btnHarvest 尺寸** | 106×106 大按钮(带时间显示) | 104×42 小文本按钮 | 收获入口缺失真实布局 |
| 4 | **svRes 资源栏** | ScrollRect + 图标(ItemResources) | 纯文本 "邮件%d 喚靈券%s" | 顶部资源区缺失真实图标 |
| 5 | **pnlCommercialization** | 独立区域 416×420, 12 LimitIconView | 混入 pnlFunny, 文本替代 | 商业化区域缺失 |
| 6 | **btnChapterInfo 挂机** | 挂机收益在 btnHarvest 内 | 额外添加独立区域 | 结构冗余 |
| 7 | **btnGal 尺寸** | 115×129 向上突出到画面内 | 100×52 等大 | 约会入口尺寸/位置错误 |
| 8 | **pnlBottom 高度** | **50px** | **102px**(高一倍) | 底部栏过高 |
| 9 | **红点覆盖** | 所有按钮都有 @pnlRd | 仅部分有 | 系统反馈缺失 |
| 10 | **按钮分隔线** | 底部栏按钮间 2×18 Image | 全缺 | 视觉不精确 |

### 5.2 按区域详细对比

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

## 6. 缺失资源清单（需从 bundle 补充导出）

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

## 7. 下一步建议

1. **修正 home_screen.gd 坐标** — 按 prefab 精确 RectTransform 逐区域调整
2. **补充缺失资源** — 导出 ItemResources、Common 图集、活动图标
3. **pnlFunnyContent 重排** — 4 个 88×102 等大按钮水平布局
4. **pnlCharge 改垂直** — 5 个按钮 VLG 垂直堆叠
5. **pnlBottom 精简** — 高度从 102 缩到 50，btnGal 向上突出
6. **红点全覆盖** — 每个功能按钮旁添加 @pnlRd
