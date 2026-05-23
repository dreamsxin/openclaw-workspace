# 7 Prefab 渲染关系与图层分析

> 2026-05-23 · 基于 UIRoot2d/ViewBehaviour/UIControl IL + 7个 layout.json 交叉分析

---

## 1. UIRoot2d 五层体系

从 `UIRoot2d.il.txt` 提取的字段声明：

```
UIRoot2d (DontDestroyOnLoad, 全局单例)
  ├─ rootLayer              ← Canvas 根层 (所有 UI 的容器)
  ├─ lowPriorityLayer       ← 低优先级层 (非交互背景?)
  ├─ midPriorityLayer       ← 中优先级层 **← 所有 7 个 View 所在层**
  ├─ highPriorityLayer      ← 高优先级层 (弹窗, ClearHighPriorityLayer 清理)
  ├─ highestPriorityLayer   ← 最高优先级层 (系统弹窗, ClearHighestPriorityLayer 清理)
  ├─ lockView               ← 加载/过渡锁屏 (ShowLockView/HideLockView)
  ├─ uiCamera               ← UI 专用 Camera (DontDestroyOnLoad)
  ├─ canvasScaler           ← 分辨率适配 (1670×750 设计分辨率)
  └─ eventSystem            ← 输入事件系统 (DontDestroyOnLoad)
```

### 层级渲染顺序 (从底到顶)

```
 ┌─────────────────────────────┐
 │  highestPriorityLayer       │  系统弹窗、错误提示、GM面板
 │  (ClearHighestPriorityLayer)│
 ├─────────────────────────────┤
 │  highPriorityLayer          │  PopUp 弹窗 (AlterView, Toast, SelectBox)
 │  (ClearHighPriorityLayer)   │
 ├─────────────────────────────┤
 │  midPriorityLayer           │  ★ 7个 View 界面 + 遮罩
 │  (DestroyAllMidPriorityView)│     LaunchView, LoginView, LoadingView,
 │                             │     MainUIView, LotteryDrawMainView,
 ├─────────────────────────────┤     HeroRecruitView, LotteryDrawFinishView
 │  lowPriorityLayer           │  备用底层
 ├─────────────────────────────┤
 │  rootLayer                  │  Canvas 根容器
 └─────────────────────────────┘
         lockView (覆盖全屏，半透明锁屏)
```

---

## 2. View 打开/关闭流程图

```
场景加载 (SceneLoadManager.LoadAsyncScene("MainScene"))
  ↓
ViewBehaviour::Open("MainUIView", param)
  ├── _allViews.Add(MainUIView)          // 压栈
  ├── Hide 下层全屏 View                  // 隐藏但不销毁
  ├── Instantiate mask (Prefab/ViewMask)  // 创建遮罩
  │     mask.SetParent(get_Root())        //   → midPriorityLayer.transform
  ├── 自身 SetParent(get_Root())
  │     SetAsLastSibling()               //   → mid 层最前端
  ├── OnOpen(param)                      //   初始化逻辑
  └── DOTween 序列动画                    //   淡入/滑入

ViewBehaviour::Close(immediate)
  ├── DOTween 序列动画 (反向)              //   淡出/滑出
  ├── OnClose()                          //   清理
  ├── Destroy mask
  ├── _allViews.Remove(this)             //   出栈
  ├── Show 下层 View (如果有)              //   恢复下层
  └── Destroy(gameObject)                //   销毁自身

场景切换 (SceneLoadManager)
  ├── DestroyAllMidPriorityView()        //   清空 mid 层
  ├── ClearHighPriorityLayer(true)       //   立即清除 high 层
  └── ClearHighestPriorityLayer(true)    //   立即清除 highest 层
```

---

## 3. 7 个 View 在 mid 层内的栈关系

以完整启动到抽卡流程为例：

```
时间线 (midPriorityLayer 内部 z-order)

① LaunchView::Open()
     [_allViews: [LaunchView]]
     → launch.mp4 播放 → 完成 → Close

② LoginView::Open()
     [_allViews: [LoginView]]
     → 点"进入游戏" → Close

③ LoadingView::Open()
     [_allViews: [LoadingView]]
     → 进度条 → GameHelper.LoadMainScene("MainScene")
     → 场景切换 → DestroyAllMidPriorityView → Show 新 View

④ MainUIView::Open()          ← 新场景
     [_allViews: [MainUIView]]
     用户操作 → 点"唤灵"按钮

⑤ LotteryDrawMainView::Open()   ← 覆盖 MainUIView
     [_allViews: [MainUIView(Hidden), LotteryDrawMainView]
     LotteryDrawMainView::SetAsLastSibling → 在 MainUIView 之上
     点"抽卡" →

⑥ HeroRecruitView::Open()      ← 抽卡演出，遮住抽卡界面
     [_allViews: [MainUIView(H), LotteryDrawMainView(H), HeroRecruitView]
     演出完成 → Close

⑦ LotteryDrawFinishView::Open()  ← 结果展示
     [_allViews: [MainUIView(H), LotteryDrawMainView(H), LotteryDrawFinishView]
```

**关键**: 下层 View 被 Hide() 而非 Destroy，保证返回时无需重建。

---

## 4. Canvas 组件分布 (视图内子层)

Unity 中每个 Canvas 组件创建独立的渲染批次。多个 Canvas 可以创建嵌套的渲染上下文。

| View | Canvas 数 | Canvas 节点 | 用途 |
|------|:--:|------|------|
| **LotteryDrawFinishView** | **9** | light01_mask, light04_mask~light10_mask, imgBg | 光效遮罩层 (每层独立 srcFactor/dstFactor) |
| **LotteryDrawMainView** | **6** | @InteractiveRole ×5, 主画布 | 5 个 Hero 展示区各自独立 Canvas |
| **MainUIView** | **1** | irole | Spine 角色渲染 (独立 Camera?) |
| **HeroRecruitView** | **1** | irole | Spine 角色 + 剪影渲染 |
| LoginView | 0 | (共享根Canvas) | 无独立 Canvas |
| LoadingView | 0 | - | 简单 UI 无分层 |
| LaunchView | 0 | - | VideoPlayer 不依赖 Canvas |
| TopResGrid | 0 | - | 嵌入 MainUIView 的 svRes |

> 🔑 **LotteryDrawFinishView 的 9 Canvas 是光效 VFX 系统的核心**: 每个 mask 层有独立的 blending mode (通过 Canvas 的 `renderMode`/`sortingOrder` 控制), 实现诸如 additive blending 的粒子光效。

---

## 5. CanvasGroup 显隐控制 (视图内面板)

CanvasGroup 不改变渲染顺序，仅控制 alpha + interactable:

| View | CG数 | 主要 CG 节点 |
|------|:--:|------|
| MainUIView | **34** | irole, @TopBar, pnlPlayerInfo, pnlFunnyContent, pnlStory, pnlCharge, btnMenu, btnAssist, pnlCommercialization, @pnlAlternate, pnlGift, btnChapterInfo, pnlBottom, pnlChat, btnGal, btnEye, btnChange, btnHarvest, 12×LimitIconView, @Question, @BuryGift, @DiscountLimitGift |
| LotteryDrawMainView | **32** | (面板组管理, 类似 MainUI) |
| HeroRecruitView | **8** | pnlMessage 下各演出层 |
| LoginView | **2** | pnlFunction, imgBg |
| LaunchView | 0 | - |
| LoadingView | 0 | - |

MainUIView 的 34 个 CanvasGroup 即 `ShowOrHide()` 中 `listPanel` 的物理实现 — 每个 CG 对应一个可独立显隐的面板/面板组。`SetActive(false)` 关闭的是整个 GameObject (含子节点), CanvasGroup 提供的是不销毁节点的 alpha 控制。

---

## 6. VideoPlayer 层

| View | VideoPlayer | 位置 |
|------|:--:|------|
| LaunchView | 1 | 全屏 video → RenderTexture → RawImage 显示 |
| MainUIView | 1 | pnlVideo (隐藏) |
| HeroRecruitView | 1 | pnlVideo (隐藏) |
| LoginView | 1 | @videoPlayer (独立根节点, OFF) |

VideoPlayer 渲染到 RenderTexture, 然后 RawImage 在 Canvas 中显示。VideoPlayer 本身不受 Canvas 渲染顺序影响。

---

## 7. ParticleSystem 渲染 (不受 Canvas z-order 限制)

| View | PS数 | 位置 |
|------|:--:|------|
| LotteryDrawFinishView | **190** | gzhu/gzhu2~gzhu6 光柱, light_orange 内 Animator |
| HeroRecruitView | **12** | caiguang2×3, glow×2, gyunlizi3/7, vfx×3 |
| MainUIView | **10** | btnGal/@fx05(5层), pnlExpeditionSoftGuide/@vfx(2层), pnlHookSoftGuide/@vfx(2层) |

ParticleSystem 在世界空间或 Screen Space - Overlay 下渲染，不受 Canvas 排序影响。在 Screen Space - Overlay 模式下，PS 始终渲染在所有 Canvas 元素之上。

---

## 8. 场景切换与层清理

```
SceneLoadManager.LoadAsyncScene("MainScene")
  ├── 旧场景所有 GameObject 销毁 (DontDestroyOnLoad 除外)
  │     UIRoot2d (含 root/low/mid/high/highest/lockView) → 保留
  │     旧 MainUIView 实例 → 销毁
  ├── 新场景加载
  ├── GameHelper LoadMainScene 回调:
  │     DestroyAllMidPriorityView()   → 清空 mid 层旧 View
  │     ClearHighPriorityLayer(true)  → 立即清空 high 层弹窗
  │     ClearHighestPriorityLayer(true) → 立即清空 highest 层
  └── 打开新 MainUIView
```

---

## 9. 对 Godot MVP 的启示

| 原始机制 | Godot 对应 |
|----------|-----------|
| UIRoot2d 5 层 | Godot 无内置分层 → 需要手动 `z_index` 或 `CanvasLayer` |
| ViewBehaviour 栈管理 | `_allViews` 列表 → 当前 MVP 无栈，每次 `_clear()` 全清除 |
| SetAsLastSibling() | `move_child(node, get_child_count()-1)` |
| CanvasGroup alpha 控制 | `modulate.a` 或 `visible` |
| DontDestroyOnLoad 持久化 | `Autoload` 单例 |
| Hide/Show 下层 View | 当前 MVP 未实现 (每次 _clear 全销毁) |
| SceneLoadManager | `get_tree().change_scene_to_file()` |

### Godot 层建议

```
CanvasLayer (Layer 5) ← 系统弹窗
CanvasLayer (Layer 4) ← PopUp 工具箱
CanvasLayer (Layer 3) ← 主界面 View (7个View)
CanvasLayer (Layer 2) ← 背景层
CanvasLayer (Layer 1) ← 锁屏/加载
```

### 当前 MVP 的视图栈缺陷

- 每次切换 View 调用 `_clear()` 完全清空 content → 无法回到下层 View
- 应该实现 `_push_view()` / `_pop_view()` 栈机制
- `home_screen.gd` 的三态切换 (normal/focus/gal) 是一个好的局部状态机，但缺少全局栈
