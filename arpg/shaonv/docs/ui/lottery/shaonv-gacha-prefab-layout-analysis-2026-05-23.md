# 抽卡演出 Prefab 提取、分析与对比

时间：2026-05-23  
目标：提取 HeroRecruitView（唤醒演出）和 LotteryDrawFinishView（结果展示）的 RectTransform 层级，对比 Godot MVP main.gd / gacha_result_screen.gd。

---

## 1. 提取方法

```powershell
python scripts\assets\inspect_unity_prefab_layout.py `
  "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab" `
  "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab" `
  --repo-root . `
  --markdown docs\shaonv-lottery-prefab-layout-2026-05-23.md `
  --markdown-depth 3
```

产物：
- `reverse-output/godot-layout-inspect/HeroRecruitView.layout.json`
- `reverse-output/godot-layout-inspect/LotteryDrawFinishView.layout.json`

---

## 2. 抽卡流程中两个 Prefab 的角色

从 C# IL 分析得出的调用链：

```
LotteryDrawMainView.OnDrawClick(count)
  → LotteryDrawHelper.ShowLotteryAnimation()    ← HeroRecruitView 在此被激活
    → HeroRecruitView.InitAnimationView()
    → HeroRecruitView.CreateSpine(heroKey)
    → 播放入场动画 + 光效
  → LotteryDrawHelper.CheckIsNeedSkipAnim()    ← 跳过按钮逻辑
  → LotteryDrawFinishView.Launch()              ← 结果展示
    → LotteryDrawFinishView.GetLightEffect(rarity)
    → LotteryDrawFinishView.GetMaskPic(rarity)
    → LotteryDrawFinishView.ShowReward(results)
```

**HeroRecruitView** = 抽卡演出页（角色登场动画 + 稀有度光效 + 剪影揭示 + 角色信息）  
**LotteryDrawFinishView** = 抽卡结果页（粒子特效光雨 + 十连结果网格 + 再抽一次）

---

## 3. HeroRecruitView

### 3.1 基本信息

| 字段 | 值 |
|------|-----|
| 节点总数 | **186** (108 唯一命名) |
| 组件 | 12 ParticleSystem, 8 CanvasGroup, 1 Animator, 1 VideoPlayer, 243 MonoBehaviour |
| 物理 Bundle | `files\yoo\Default\BundleFiles\7f\7f985e1dae908dae92d5f38cbc8a5b82\__data` |

### 3.2 层级结构

```
HeroRecruitView (全屏, Animator+CanvasGroup)
│
├── imgBg (1670×750, 中锚居中)                            ← 演出背景
│   ├── @imgBg_blue    (1670×750)  active=FALSE           ← 稀有度对应背景
│   ├── @imgBg_purple  (1670×750)  active=FALSE
│   ├── @imgBg_yellow  (1670×750)  active=FALSE
│   └── @imgBg_red     (1670×750)  active=FALSE
│
├── pnlMessage (全屏 0-0→1-1, CanvasGroup)                ← 主演出层
│   │
│   ├── ① @fx_HeroRecruitView_01 (100×100, pos=(147,0))
│   │   └── vfx (全体光效粒子容器)
│   │
│   ├── ② pnlHeroSilhouette (958×750, pos=(199,0))       ← 剪影层
│   │   └── spSilhouette (100×100, pos=(0,-334))         ← 剪影 Spine
│   │
│   ├── ③ @fx_HeroRecruitView_03 (100×100, pos=(147,0))  ← 揭示光效
│   │   └── vfx (光效粒子容器)
│   │
│   ├── ④ irole (958×750, pos=(199,0))                   ← 角色展示主层
│   │   ├── btn       (418×804, pos=(0,272))  ← 大按钮触发交互
│   │   ├── spBg      (100×100)                ← 背景骨骼
│   │   ├── spHero    (100×100)                ← 角色骨骼主体
│   │   ├── spFg      (100×100)                ← 前景骨骼
│   │   ├── imgMask   (324×274)                ← 底部遮罩
│   │   └── imgSpeak  (668×154, pos=(0,85))    active=FALSE ← 台词气泡
│   │
│   ├── ⑤ @fx_HeroRecruitView_02 (100×100, pos=(147,0))  ← 收尾光效
│   │   └── vfx2 (光效粒子容器)
│   │
│   ├── ⑥ 稀有度边框 (4套, 每套 1670×437, pos=(0,-156))
│   │   ├── @ImgFrame_blue    active=FALSE
│   │   │   ├── ImgFrame_blue      (1670×437, pos=(0,218), 底锚)
│   │   │   ├── ImgFrame_blue_l    (835×437, pos=(-418,218))  active=FALSE
│   │   │   └── ImgFrame_blue_r    (835×437, pos=(418,218))   active=FALSE
│   │   ├── @ImgFrame_purple  active=FALSE
│   │   ├── @ImgFrame_yellow  active=FALSE
│   │   └── @ImgFrame_red     active=FALSE
│   │
│   ├── spineHeroQReflection (100×100, pos=(-484,-325))       ← Q版倒影
│   ├── spineHeroQ           (100×100, pos=(-484,-330))       ← Q版角色
│   │
│   └── pnlInfo (410×70, pos=(-459,-20), CanvasGroup)         ← 角色信息条
│       ├── @imgTypeNew_33~37  (222×222, pos=(-17,164))  5个稀有度标签 active=FALSE
│       ├── imgNew        (58×48, pos=(153,35))              ← NEW 标记
│       ├── txtName       (-306×-30, pos=(60,0))             ← 角色名(负size=自适应)
│       ├── imgQuality    (132×68, pos=(-130,0))             ← 稀有度图标
│       ├── pnlHeroTag    (290×58, pos=(-17,-84))            ← 角色标签容器
│       │   ├── pnlTag1~4  (140×24, 2×2 网格)               ← 4个标签槽
│       │   └── @txtTag1~4 (全锚 0-1, 标签文字)
│       └── imgOccupation (70×70, pos=(-20,0))              ← 职业图标
│
├── pnlVideo (全屏 0-1, 视频层)
│   ├── riVideo        (1670×750)                            ← RawImage 视频输出
│   ├── pnlVideoPlayer (100×100, 中锚, VideoPlayer)         ← 视频播放器
│   └── btnSkipVideo   (138×52, pos=(-60,-24))  active=FALSE ← 跳过视频按钮
│
└── btnClose (0×0, 全屏 0-1 锚)                              ← 全屏关闭按钮
```

### 3.3 演出分层机制

HeroRecruitView 的 pnlMessage 内有 **严格的 z-order 分层**（按节点顺序从前到后）：

| 层序 | 节点 | 作用 | 动画阶段 |
|:----:|------|------|----------|
| 1 | @fx_01 + vfx | 入场粒子光效 | 阶段 1：拉开帷幕 |
| 2 | pnlHeroSilhouette | 角色剪影展示 | 阶段 2：黑色剪影悬念 |
| 3 | @fx_03 + vfx | 揭示粒子光效 | 阶段 3：剪影碎裂/光爆 |
| 4 | **irole** (spHero/spBg/spFg) | 角色登场展示 | 阶段 4：角色亮相 |
| 5 | @fx_02 + vfx2 | 收尾光效 | 阶段 5：金光收束 |
| 6 | @ImgFrame_* | 稀有度装饰边框 | 阶段 6：边框定格 |
| 7 | spineHeroQ + Reflection | Q版小角色 | 贯穿全程(左下角) |
| 8 | pnlInfo | 角色名称/稀有度/标签 | 阶段 6-7：信息浮现 |

### 3.4 稀有度切换机制

prefab 中有 **4 套按稀有度切换的资源**，全部初始 `active=FALSE`，由 C# 代码根据抽到的角色稀有度激活对应的一套：

| 稀有度 | 背景 | 边框 | 标签 |
|--------|------|------|------|
| R (2星/蓝) | @imgBg_blue | @ImgFrame_blue → ImgFrame_blue + _l + _r | @imgTypeNew_33(3元素) |
| SR (3星/紫) | @imgBg_purple | @ImgFrame_purple → _l + _r | @imgTypeNew_34(4元素) |
| SSR (4星/金) | @imgBg_yellow | @ImgFrame_yellow → _l + _r | @imgTypeNew_35(5元素) |
| UR (5星/红) | @imgBg_red | @ImgFrame_red → _l + _r | @imgTypeNew_36/37(6/7元素) |

**标签元素命名规则（lottery_img 系列）**：
- `33a/b/c` = 3 元素标签（对应 R/蓝）
- `34a/b/c/d` = 4 元素（SR/紫）
- `35a/b/c/d` = 5 元素（SSR/金）
- `36a/b/c/d` = 6 元素（UR/红）
- `37a/b/c/d` = 7 元素（更高稀有度）
- 每个主元素有 `_effect` 变体（发光特效层）

**边框**每套有 3 个组件：
- `ImgFrame_*`：中心主边框 (1670×437)
- `ImgFrame_*_l`：左侧装饰边框 (835×437)
- `ImgFrame_*_r`：右侧装饰边框 (835×437)

### 3.5 光环旋转装饰

pnlMessage 内有 **6 个光环/旋转装饰**元素（位于 @fx_03 或 irole 附近）：

| 节点 | 尺寸 | 位置 | 类型 |
|------|------|------|------|
| ring_rotation | 190×190 | (0,0) | MonoBehaviour 旋转脚本 |
| ring_rotation1 | 190×190 | (0,0) | 旋转动画 |
| ring_rotation2 | 190×190 | (0,0) | 旋转动画 |
| ring_top | 190×190 | (0,20) | 上环+按钮 |
| ring_down | 190×190 | (0,-20) | 下环+按钮 |
| ring_left | 190×190 | (-20,0) | 左环+按钮 |
| ring_right | 190×190 | (20,0) | 右环+按钮 |

### 3.6 粒子效果汇总

12 个 ParticleSystem 全部位于 HeroRecruitView 的 pnlMessage 内：

| 粒子名 | 推测效果 | 位置 |
|--------|---------|------|
| caiguang2 | 彩光 主射线 | (0,0) |
| caiguang2 (1) | 彩光 副射线 | 环绕 |
| caiguang2 (2) | 彩光 | 背景 |
| glow | 金色光晕 | 主线 |
| glow2 | 金色光晕副 | 偏位 |
| gyunlizi3 | 粒子旋转流 | (0,0) |
| gyunlizi7 | 粒子旋转流副 | 偏位 |
| vfx (fx_01内) | 入场特效 | (147,0) |
| vfx (fx_03内) | 揭示特效 | (147,0) |
| vfx2 (fx_02内) | 收尾特效 | (147,0) |

### 3.7 Godot MVP 对比

Godot 的 `gacha_result_screen.gd` 目前将 HeroRecruitView 和 LotteryDrawFinishView **合并为两个函数**：`show_draw_animation()` + `draw_and_show()`。

| Prefab 元素 | Godot 实现 | 状态 |
|-------------|-----------|:--:|
| **imgBg** (全屏背景) | `lottery_img_60.png` | ✅ |
| **@imgBg_blue/purple/yellow/red** (4色背景) | 单色半透明遮罩替代 | ❌ 缺稀有度对应背景 |
| **pnlHeroSilhouette** (剪影) | 无 | ❌ 完全缺失 |
| **irole/spHero** (角色 Spine) | baked Spine 动画 | ✅ |
| **irole/spBg/spFg** (背景/前景层) | 合并为单层 baked | ⚠️ 无分层 |
| **irole/imgMask** (遮罩) | 无 | ❌ |
| **@fx_01/02/03** (入场/揭示/收尾光效) | 无 ParticleSystem | ❌ 缺粒子特效 |
| **@ImgFrame_blue~red** (稀有度边框) | 无 | ❌ 缺 4 套边框 |
| **lottery_img_33~37** (标签元素) | "NEW"/"碎片+x" 文字 | ❌ 缺真实标签图 |
| **ring_rotation*** (光环旋转) | 无 | ❌ |
| **pnlInfo** (角色信息条) | 名称+稀有度 label | ⚠️ 缺 imgQuality/imgOccupation/pnlHeroTag |
| **spineHeroQ** (Q版小角色) | 无 | ❌ |
| **imgSpeak** (台词气泡) | 无 | ✅(prefab active=FALSE) |
| **btnClose** (全屏关闭) | "返回" 按钮 | ⚠️ prefab 是全屏覆盖，Godot 是独立按钮 |
| **pnlVideo** (视频层) | 无 | ✅(prefab 中无视频资源可跳过) |

**总体还原度：~30%**（演出分层的核心机制——剪影→揭示→角色登场→边框定格——全部缺失）

---

## 4. LotteryDrawFinishView

### 4.1 基本信息

| 字段 | 值 |
|------|-----|
| 节点总数 | **344** (36 唯一命名，大量重复粒子) |
| 组件 | 190 ParticleSystem, 40 Animator, 9 Canvas, 204 MonoBehaviour |
| 物理 Bundle | `files\yoo\Default\UnpackBundleFiles\86\86c05702d8a8a6410d5a48ddc7449de4\__data` |

### 4.2 层级结构

```
LotteryDrawFinishView (全屏)
│
├── imgBg (1670×750, 中锚, Canvas)                         ← 结果背景
│   │
│   ├── ① @pnlLight01~10 (10 个光效容器, 100×100)
│   │   ├── @pnlLight01 (-663,-375)  light01_mask(137×121) + light01_colormask(126×217 inactive)
│   │   ├── @pnlLight02 (-266,-375)  light02_colormask(305×218 inactive)
│   │   ├── @pnlLight03 (299,-375)   light03_colormask(308×233 inactive)
│   │   ├── @pnlLight04 (742,-139)   light04_mask(267×314) + light04_colormask(304×296 inactive)
│   │   ├── @pnlLight05 (-430,-103)  light05_mask(176×184)
│   │   ├── @pnlLight06 (94,-174)    light06_mask(240×102)
│   │   ├── @pnlLight07 (533,-49)    light07_mask(108×213)
│   │   ├── @pnlLight08 (-551,72)    light08_mask(198×224)
│   │   ├── @pnlLight09 (-161,72)    light09_mask(112×88)
│   │   └── @pnlLight10 (199,119)    light10_mask(124×145)
│   │
│   └── ② 粒子特效层 (大量重复, 按稀有度分组)
│
├── fx_light × 8          (Transform 无 Rect, active=TRUE)   ← 光效触发器
├── light_blue × 10       (Transform, active=FALSE)           ← 蓝色光(未激活)
├── light_orange × 8      (100×100, active=FALSE, Animator)   ← 橙色光(含粒子层)
│   └── vfx → GameObject → gzhu/gzhu2/gzhu3/gzhu4            ← 4种金色粒子
├── light_purple × 10     (Transform, active=FALSE)           ← 紫色光
├── light_red × 10        (Transform, active=FALSE)           ← 红色光
└── vfx × 40              (100×100, 粒子效果)
    └── GameObject → gzhu/gzhu2/gzhu3/gzhu4/gzhu6            ← 5种粒子组合
```

### 4.3 光效系统详解

**10 个 pnlLight 容器**覆盖全屏不同坐标位置，构成"光雨绽放"效果：

```
        @pnlLight08(-551,72)    @pnlLight09(-161,72)    @pnlLight10(199,119)
        
@pnlLight05(-430,-103)            @pnlLight07(533,-49)   @pnlLight04(742,-139)
        
            @pnlLight01(-663,-375)  @pnlLight02(-266,-375)  @pnlLight03(299,-375)
                                        @pnlLight06(94,-174)
```

每个 pnlLight 包含 2 层：
- **mask 层**（active=TRUE）：带 Canvas 组件的遮罩图像（控制光效范围和形状）
- **colormask 层**（active=FALSE）：带颜色的遮罩变体（可能在特定稀有度时激活）

**4 种稀有度光效**（light_blue/purple/orange/red）：
- 每种有 8-10 个实例，全部 **active=FALSE**
- 由 C# 代码根据结果稀有度 `GetLightEffect(rarity)` 激活对应颜色
- `light_orange` 内部有 Animator + vfx 粒子层（4-5 种 gzhu 粒子）

**vfx 粒子实例**（约 40 个）每个包含 GameObject 容器组：
```
vfx
└── GameObject (100×100)
    ├── gzhu   (100×100, pos=(0,-1.5))  ← 主粒子柱
    ├── gzhu4  (100×100, pos=(0,0))     ← 粒子柱 4
    ├── gzhu2  (100×100, pos=(0,-1.5))  ← 粒子柱 2
    ├── gzhu3  (100×100, pos=(0,-1.5))  ← 粒子柱 3 (部分有)
    └── gzhu6  (100×100, pos=(0,-1.5))  ← 粒子柱 6 (部分有)
```

### 4.4 信息面板（推断）

`LotteryDrawFinishView.prefab` 中**没有**结果网格/卡片节点。这些在 `LotteryRewardShowView.prefab`（未定位物理文件）和 `LotteryRewardShowGrid.prefab` 中。FinishView 只负责光效演出，结果卡片由 RewardShowView 叠加显示。

### 4.5 Godot MVP 对比

Godot 的 `_draw_result_stage()` + `_draw_result_grid()` 实现：

| Prefab 元素 | Godot 实现 | 状态 |
|-------------|-----------|:--:|
| **imgBg** | `lottery_img_60.png` | ✅ |
| **@pnlLight01~10** (10 光效容器) | 无 mask/光效图 | ❌ 完全缺失 |
| **light_mask × 10** | 无 | ❌ |
| **light_colormask × 10** | 无 | ❌ |
| **fx_light × 8** (光触发器) | 无 | ❌ |
| **light_blue/purple/orange/red** (稀有度光) | 半透明色块模拟 | ❌ 缺真实动画 |
| **vfx × 40** (190 ParticleSystem) | 无粒子系统 | ❌ 缺所有粒子特效 |
| **gzhu 粒子柱** | 无 | ❌ |
| **结果网格** | `_draw_result_grid()` 的卡片排列 | ⚠️ 网格在 LotteryRewardShowView 中，未定位物理文件 |
| **再抽按钮** | "继续抽卡" 按钮 | ⚠️ 按钮在 LotteryDrawFinishView 自身或子 prefab 中 |
| **稀有度色框** | Godot ColorRect 模拟 | ⚠️ 缺真实边框图 |

**总体还原度：~20%**（190 个 ParticleSystem 全部缺失，光效系统完全用色块模拟）

---

## 5. 完整演出流程 vs Godot 实现对比

### 5.1 原游戏演出序列（从时序推测）

```
[抽卡按钮点击]
  ↓
① LotteryDrawMainView 隐藏
② HeroRecruitView 打开（全屏黑→淡入）
   → @fx_01 粒子光效爆发（入场开幕）
   → pnlHeroSilhouette 显示黑色剪影（3秒悬念）
   → @fx_03 粒子光效 + 剪影碎裂动画
   → irole spHero 从剪影中显现（骨骼动画 wait/idle）
   → @ImgFrame_* 稀有度边框从两侧滑入
   → ring_rotation* 光环旋转装饰展开放大
   → @fx_02 收尾粒子
   → pnlInfo 角色名称/稀有度/标签淡入
   → (用户点击或自动超时)
  ↓
③ LotteryDrawFinishView 打开
   → imgBg 全屏背景
   → 稀有度对应 light_* 激活（blue/purple/orange/red）
   → 190 个 ParticleSystem 粒子爆发（gzhu 光柱雨）
   → 10 个 pnlLight mask 光效绽放
   → (可能叠加 LotteryRewardShowView 结果网格)
   → 十连结果卡片逐个飞入
   → 再抽一次 / 确认按钮显示
```

### 5.2 Godot 实现序列

```
[抽卡按钮点击]
  ↓
① main.gd _show_draw_animation(count)
   → gacha_result_screen.show_draw_animation()
   → 黑色半透明遮罩 + 文字 "喚靈中..."
   → (2秒等待)
  ↓
② main.gd _draw_and_show(count)
   → gacha_result_screen.draw_and_show()
   → _draw_result_stage()：lottery_img_60 背景
     + baked Spine 角色 + 稀有度色块 + 名称/碎片标签
   → _draw_result_grid()：十连结果卡片网格
   → "继续抽卡" 按钮
```

### 5.3 差距总结

| 演出阶段 | 原游戏 | Godot | 偏差 |
|---------|--------|-------|:--:|
| 入场开幕 | @fx_01 粒子爆发 | 无 | ❌ |
| 剪影悬念 | pnlHeroSilhouette + spSilhouette | 无 | ❌ |
| 揭示光效 | @fx_03 粒子 + 剪影碎裂 | 无 | ❌ |
| 角色登场 | spHero/spBg/spFg 三层骨骼 | baked 单层 | ❌ |
| 稀有度边框 | @ImgFrame_* 4 套边框滑入 | 无 | ❌ |
| 光环装饰 | ring_rotation* 6 个光环 | 无 | ❌ |
| 收尾光效 | @fx_02 粒子收束 | 无 | ❌ |
| 角色信息 | pnlInfo(稀有度图标+职业+标签×4) | 名称+碎片文字 | ❌ |
| 稀有度光雨 | light_* 10 个 mask + 190 PS | 色块模拟 | ❌ |
| Q版小角 | spineHeroQ + Reflection | 无 | ❌ |

**综合评分：~25%**（核心演出机制——两层粒子爆发+剪影揭示+边框动画——全部缺失）

---

## 6. 缺失资源清单

### 6.1 HeroRecruitView 缺失资源

| 类别 | 资源 | 数量 |
|------|------|:--:|
| 稀有度背景 | @imgBg_blue/purple/yellow/red | 4 |
| 稀有度边框 | ImgFrame_* + _l + _r (4套×3) | 12 |
| 稀有度标签 | lottery_img_33~37 系列 (a/b/c/d + _effect) | ~25 |
| 光环装饰 | ring_rotation/ring_top/down/left/right 贴图 | ~6 |
| 粒子贴图 | caiguang2/glow/gyunlizi 等粒子纹理 | ~8 |
| 剪影 Spine | spSilhouette 骨骼资源 | 每角色1 |

### 6.2 LotteryDrawFinishView 缺失资源

| 类别 | 资源 | 数量 |
|------|------|:--:|
| 光效 mask | light01~10_mask + colormask | 20 |
| 粒子贴图 | gzhu/gzhu2/gzhu3/gzhu4/gzhu6 | 5 |
| 稀有度光 | light_blue/purple/orange/red 完整资源包 | 4 |

### 6.3 未定位的 Prefab

| Prefab | Bundle Hash | 影响 |
|--------|-------------|------|
| LotteryRewardShowView | a9321033... | 结果卡片网格布局缺失 |
| LotteryRewardShowGrid | 未知 | 单个结果卡片结构缺失 |
| LotteryDrawPanel | 531addbb... | 抽卡主面板布局缺失 |

---

## 7. 下一步建议

1. **优先实现 HeroRecruitView 演出分层** — 至少补上剪影→角色→边框的基础序列
2. **导出稀有度边框和标签图** — 4 套 ImgFrame + lottery_img_33~37 系列
3. **用简单动画替代粒子** — Godot Tween 模拟光效淡入/缩放，暂不依赖 ParticleSystem
4. **分离 Godot 结果页** — 将 `_draw_result_stage()` 和 `_draw_result_grid()` 拆为独立 scene
5. **添加关闭交互** — HeroRecruitView 的 btnClose(全屏) 映射为点击任意位置关闭
