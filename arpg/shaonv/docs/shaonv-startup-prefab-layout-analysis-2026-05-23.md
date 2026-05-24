# 启动链 Prefab 提取、分析与对比

时间：2026-05-23  
目标：提取 LaunchView → PreloadingView → LoginView → LoadingView 的 RectTransform 层级并与 Godot MVP startup_screen.gd 对比。

> **2026-05-24 勘误**：本文件中的 prefab 坐标仍可作为布局事实源，但背景映射以 `docs/shaonv-startup-background-layout-reanalysis-2026-05-24.md` 为准：`LoginView = login_bg_01`，`LoadingView = loading_bg_01`，AOT 资源初始化/热更页 `UpdateView = update_bg_01`。旧文档里把 LoadingView 临时对到 `login_bg_01` 的内容已被新分析修正。

> **注意**：原游戏启动链为 LaunchView → LoginView → LoadingView；PreloadingView 仅在早期版本存在，当前 prefab 包中仅有 3 个界面。Godot MVP 中添加了简化的 PreloadingView 占位。

---

## 1. 提取方法

```powershell
python scripts\assets\inspect_unity_prefab_layout.py `
  "Assets/Game/RawAssets/Prefabs/UI/Launch/LaunchView.prefab" `
  "Assets/Game/RawAssets/Prefabs/UI/Login/LoginView.prefab" `
  "Assets/Game/RawAssets/Prefabs/UI/Login/LoadingView.prefab" `
  --repo-root . `
  --markdown docs\shaonv-prefab-layout-restart-2026-05-23.md `
  --markdown-depth 4
```

产物：
- `reverse-output/godot-layout-inspect/LaunchView.layout.json`
- `reverse-output/godot-layout-inspect/LoginView.layout.json`
- `reverse-output/godot-layout-inspect/LoadingView.layout.json`

---

## 2. LaunchView 分析

### 2.1 基本信息

| 字段 | 值 |
|------|-----|
| 节点数 | **4** |
| 组件 | VideoPlayer × 1, MonoBehaviour × 3 |
| 物理 Bundle | `files\yoo\Default\BundleFiles\02\02f333e981e168e801ed39cad54a6f17\__data` |

### 2.2 层级结构

```
LaunchView (全屏 anchor 0-0→1-1)
├── Image        (全屏, 锚 0-0→1-1, size=0)     ← 全屏黑色遮罩/背景图
├── RawImage     (1680×1680, 中锚居中)           ← 启动展示图
└── video        (100×100, 中锚居中, VideoPlayer) ← launch.mp4 视频层
```

### 2.3 精确坐标

| 节点 | 尺寸 | 位置 | active | 锚点 | 组件 |
|------|------|------|--------|------|------|
| LaunchView | 0×0 | (0,0) | true | 0-0→1-1 | RectTransform, MonoBehaviour |
| Image | 0×0 | (0,0) | true | 0-0→1-1 | RectTransform, CanvasRenderer, MonoBehaviour |
| RawImage | 1680×1680 | (0,0) | true | 0.5-0.5 | RectTransform, CanvasRenderer, MonoBehaviour |
| video | 100×100 | (0,0) | true | 0.5-0.5 | RectTransform, VideoPlayer |

### 2.4 C# 生命周期（来自 IL 分析）

```
LaunchView.Awake()
  → FileUtils.FullPathForFilename("launch.mp4")
  → videoPlayer.prepareCompleted += Play()
  → videoPlayer.loopPointReached += m_finish.Invoke(); Destroy()
```

### 2.5 Godot MVP 对比

| Prefab 节点 | Godot 实现 | 偏差 |
|-------------|-----------|------|
| Image (全屏黑底) | `_panel(Vector2(0,0), 1280×720, black)` | ✅ |
| RawImage (1680×1680) | `_panel(Vector2(-200,-120), 1680×1680, dark)` | ⚠️ 偏移 (-200,-120) 而非居中 |
| video (launch.mp4) | 未实现 — 视频资源缺失 | ❌ |
| (无按钮) | "跳过" btn at (1128,32) + "点击跳过" hint | ⚠️ prefab 本身无跳过按钮（由 C# 逻辑添加） |

**偏差总结**：LaunchView 仅 4 个节点，结构极简。Godot 实现基本正确，但 RawImage 偏移了 (-200,-120) 而非中锚居中。VideoPlayer 因缺少 `launch.mp4` 无法播放。

---

## 3. LoginView 分析

### 3.1 基本信息

| 字段 | 值 |
|------|-----|
| 节点数 | **39** (35 个唯一命名) |
| 组件 | MonoBehaviour × 67, MonoScript × 15, CanvasGroup × 2, VideoPlayer × 1 |
| 物理 Bundle | `resources\assets\yoo\Default\7996b01a22fa6b87d3cf865ec438316b.bundle` |

### 3.2 层级结构

```
LoginView (全屏)
├── @rawImgBg          (1670×1670, 中锚)                      active=FALSE
├── imgBg              (1670×750, 中锚居中, 背景图)            ← login_bg_01.png
├── pnl                (全屏锚, 主交互面板)
│   ├── btnLogin       (全屏锚 0-0→1-1, 覆盖整个底层的透明登录按钮)
│   ├── pnlFunction    (131×高, 右中锚 pos=(-66,0))             ← 4个功能按钮
│   │   ├── btnNotice      (60×60, 公告)
│   │   │   └── Text       (160×30)                   active=FALSE
│   │   ├── btnRepair      (60×60, 修复)
│   │   │   └── Text       (160×30)                   active=FALSE
│   │   ├── btnSwitchAccount (60×60, 账号)
│   │   │   └── Text       (160×30)                   active=FALSE
│   │   └── btnSelect      (60×60, 选择)
│   │       └── Text       (160×30)                   active=FALSE
│   ├── pnlVersion     (100×127, 右下锚 pos=(-13,114))
│   │   ├── txtVer     (332×30, 版本)                          pivot=(1,0.5)
│   │   ├── txtApp     (332×30, 程式)                          pivot=(1,0.5)
│   │   └── txtRes     (332×30, 资源)                          pivot=(1,0.5)
│   ├── imgLogo        (260×104, 左上锚 pos=(61,-129))         ← logo.png
│   ├── btnAge         (83×104, 左下锚 pos=(90,154))           ← 12+ 年龄确认
│   ├── @richBottom    (1670×78, 中顶锚 pos=(0,-667))          ← 底部版权
│   │   ├── txtGameTip   (800×40, pos=(0,-24))        active=FALSE
│   │   ├── txtCopyright (800×40, pos=(0,-48))        active=FALSE
│   │   └── txtCopyleft  (800×40, pos=(0,-70))        active=FALSE
│   ├── btnServerSel   (500×34, 中锚 pos=(0,-99))     active=FALSE ← 默认隐藏
│   │   ├── txtServer     (101×44, pos=(-224,0))      active=FALSE
│   │   ├── imgServer     (26×26, 右中锚 pos=(-20,0))
│   │   └── txtServerName (311×42, 中锚)
│   ├── imgTipLogin    (536×30, 中顶锚 pos=(0,-553))            ← 登录提示
│   └── @richUrl       (0×32, 中顶锚, pos=(20,-620))           ← 协议勾选
│       └── togAgree   (32×32, pos=(-10,0))                   ← Toggle
│           └── Background → Checkmark (32×32)
└── inputAccount    (543×64, 中锚 pos=(0,-115))                ← 账号输入
    ├── Placeholder  (363×64, pos=(161,0))                     ← 提示文本
    ├── Text         (363×64, pos=(161,0))                     ← 输入文本
    ├── Image        (40×40, pos=(-239,0))                    ← 输入图标
    └── txtAccount   (-469×0, pos=(-172,0))                   ← 标签

@videoPlayer (独立根节点, active=FALSE, Transform+VideoPlayer)
```

### 3.3 关键布局：中心轴排列

LoginView 的核心布局逻辑：

```
       左侧                    中心轴                   右侧
───────────────────────────────────────────────────────────────
                                                         pnlFunction
                               imgLogo                  (60×60×4)
                               (260×104)
                           
                               inputAccount
                               (543×64)
                               
                               btnLogin
                               (全屏透明覆盖)
                               
                               btnServerSel
                               (500×34, 默认隐藏)
                               
                               togAgree
左:btnAge(12+)                                            右:pnlVersion
 83×104,pos=(90,154)                                      ver/app/res 版本信息
                                                          pivot右对齐
```

**关键发现**：
- `pnlFunction` 是**右侧垂直条**（131宽），4 个按钮各 60×60，内有 active=FALSE 的 Text 子节点
- 所有 pnlFunction 内按钮的 `Text` 子节点都是 **active=FALSE** — 文字不直接显示，按钮图标由 Sprite 渲染
- `btnLogin` 是**全屏透明覆盖**（锚 0-0→1-1）— 点击屏幕任意位置触发登录
- `btnServerSel` 是 **active=FALSE** — 默认不显示，仅在特定条件下激活
- `@richBottom` 三条版权文本全部 **active=FALSE**
- `@videoPlayer` 独立根节点 **active=FALSE**

### 3.4 btnServerSel 子结构（展开后）

```
btnServerSel (500×34, pos=(0,-99), active=FALSE)
├── txtServer      (101×44, pos=(-224,0), pivot(0.5,0.5))   active=FALSE
├── imgServer      (26×26, 右中锚 pos=(-20,0))               active=TRUE
└── txtServerName  (311×42, 中锚居中)                        active=TRUE
```

### 3.5 C# 生命周期（来自 IL 分析）

```
LoginView.Awake()
  → InitView()：读取隐私协议状态、初始化服务器列表
  → OnOpen()：检查首次登录、显示公告弹层、播放登录 BGM
  → ReqServerList()：从 LoginModel 获取服务器列表
  → ShowAnnounce()：调用公告弹层
  → 登录成功 → RPCSession.Connect(host, port)
```

### 3.6 Godot MVP 对比

| Prefab 节点 | Godot 实现 | 状态 |
|-------------|-----------|:--:|
| **imgBg** | `login_bg_01.png` (-195,-4) 1670×728 | ✅ |
| **imgLogo** | `logo.png` (48,90) 258×86 / 文本 fallback | ✅ |
| **btnAge** | "12+" btn (106,214) 64×70 | ⚠️ 位置偏差 |
| **pnlVersion** | 版本文本 (934,80) 230×78 | ⚠️ prefab 是右下锚 pos(-13,114)，Godot 是硬编码 |
| **inputAccount** | LineEdit (426,418) 376×62 + Icon | ⚠️ prefab 543×64 中锚居中，Godot 尺寸不匹配 |
| **inputAccount/Image** | "人" icon (378,423) 38×38 | ⚠️ prefab 中是 40×40 左对齐，Godot 偏移 |
| **btnLogin** | "开始游戏" btn (526,358) 228×54 | ❌ prefab 是全屏透明覆盖，不是单独按钮 |
| **btnNotice** | "公告" (1138,178) 60×60 | ✅ |
| **btnRepair** | "修复" (1138,250) 60×60 | ✅ |
| **btnSwitchAccount** | "账号" (1138,322) 60×60 | ✅ |
| **btnSelect** | "切换" (1138,394) 60×60 | ✅ |
| **btnServerSel** | 服务器面板 (390,486) 500×42 | ⚠️ prefab active=FALSE；Godot 始终显示 |
| **imgServer** | 状态指示灯 (888,494) 18×18 | ⚠️ prefab 中 26×26 右对齐 |
| **imgTipLogin** | "离线单机模式"提示 (390,548) 500×30 | ⚠️ prefab 中 536×30 中顶锚 |
| **togAgree** | CheckBox (426,594) 428×34 | ✅ |
| **@richBottom** | 版权文本 (340,654) 600×28 | ⚠️ prefab 3 行全 active=FALSE；Godot 显示 1 行 |

**主要偏差**：
1. **btnLogin 行为不同** — prefab 中它是全屏透明按钮（点击任意位置登录），Godot 中改成了独立按钮
2. **布局策略不同** — prefab 以中轴为中心排列组件，Godot 用绝对坐标散放
3. **pnlVersion 位置** — prefab 右下锚，Godot 右上区
4. **inputAccount 尺寸** — prefab 543×64 中锚居中，Godot 376×62

---

## 4. LoadingView 分析

### 4.1 基本信息

| 字段 | 值 |
|------|-----|
| 节点数 | **9** |
| 组件 | MonoBehaviour × 7, MonoScript × 4 |
| 物理 Bundle | `files\yoo\Default\UnpackBundleFiles\3e\3eda611616b92cfdb2af7f8c183b1e50\__data` |

### 4.2 层级结构

```
LoadingView (全屏)
├── imgBg        (1670×750, 中锚居中)                          ← 背景图
├── txtPercent   (123×37, 右中锚 pos=(-11,-355))               ← 百分比文字
└── sldSpeed     (-181×34, 下中锚 pos=(4,-357))               ← 进度条 Slider
    ├── Background          (0×34, 中锚 0-0.5→1-0.5)         ← 进度条背景
    ├── Fill Area           (0×0, 全锚 0-0→1-1)
    │   └── Fill            (0×0, 左下锚 0-0)                ← 进度填充
    └── Handle Slide Area   (0×0, 全锚 0-0→1-1)
        └── Handle          (82×82, 左下锚 pos=(-41,4))     ← 滑块把手
```

### 4.3 精确坐标

| 节点 | 尺寸 | 位置 | active | 锚点 |
|------|------|------|--------|------|
| LoadingView | 0×0 | (0,0) | true | 0-0→1-1 |
| imgBg | 1670×750 | (0,0) | true | 0.5-0.5 |
| txtPercent | 123×37 | (-11,-355) | true | 1-0.5 |
| sldSpeed | -181×34 | (4,-357) | true | 0-0.5→1-0.5 |
| sldSpeed/Background | 0×34 | (0,0) | true | 0-0.5→1-0.5 |
| sldSpeed/Fill Area | 0×0 | (0,0) | true | 0-0→1-1 |
| sldSpeed/Fill | 0×0 | (0,0) | true | 0-0 |
| sldSpeed/Handle Slide Area | 0×0 | (0,0) | true | 0-0→1-1 |
| sldSpeed/Handle | 82×82 | (-41,4) | true | 0-0 |

**关键发现**：
- `sldSpeed` 是 Unity 原生 **Slider** 组件，含标准子结构 Background/Fill Area/Handle Slide Area
- txtPercent 是**右中锚**（1-0.5），位于进度条**左侧**
- sldSpeed 锚点是 **0-0.5→1-0.5**（水平全宽，垂直居中于底部偏上）
- Handle 把手是 **82×82** 大圆形滑块

### 4.4 C# 生命周期（来自 IL 分析）

```
LoadingView.Awake()
  → OnOpen()：开始进度更新
  → UpdateProcess()：逐帧更新进度条 → 到达 100%
  → GameHelper.LoadMainScene("MainScene")
  → SceneLoadManagerExtension.LoadAsyncScene(..., "MainScene", ...)
```

### 4.5 Godot MVP 对比

| Prefab 节点 | Godot 实现 | 状态 |
|-------------|-----------|:--:|
| **imgBg** | `login_bg_01.png` (-195,-4) 1670×728 | ✅ |
| **txtPercent** | "88%" label (1190,604) 60×28 | ⚠️ prefab 中 123×37 右中锚 pos=(-11,-355)；Godot 位置完全不同 |
| **sldSpeed** | `_draw_progress_bar` (90,624) 1100×22 | ❌ prefab 中是完整 Slider(含 Handle)，Godot 简化成纯进度条 |
| **Background** | 进度条背景色块 | ⚠️ prefab 中是 34px 高的完整背景 |
| **Fill** | 进度填充 | ✅ |
| **Handle** | **缺失** | ❌ prefab 中有 82×82 圆形滑块 |
| (无文本) | "正在进入主城" (340,550) | ⚠️ prefab 无此元素（C# 逻辑通过其他方式展示）|
| (无文本) | 提示文字 (290,596) | ⚠️ prefab 无此元素 |
| (无按钮) | "进入" btn (574,664) | ⚠️ prefab 无按钮（自动过渡到 MainScene） |

**主要偏差**：
1. **sldSpeed 是 Unity Slider 而非简单进度条** — 含 Handle(82×82)、Fill Area、Handle Slide Area 三件套
2. **txtPercent 位置** — prefab 中是右中锚紧贴进度条左侧，Godot 中放在右下角
3. **添加了不存在的元素** — "正在进入主城" 提示文字和 "进入" 按钮在 prefab 中均不存在
4. **自动过渡 vs 手动确认** — 原游戏进度到 100% 自动调 `GameHelper.LoadMainScene`，Godot 需要手动点 "进入"

---

## 5. 对比总结

### 5.1 节点数偏差

| View | Prefab 节点 | Godot 等效控件 | 复杂度差距 |
|------|:----------:|:------------:|:--------:|
| LaunchView | 4 | ~5 | 相当 |
| LoginView | 39 | ~20 | Godot 省略了约一半（主要是 active=FALSE 的子节点和 Toggle 内部结构）|
| LoadingView | 9 | ~6 | Godot 省略了 Handle/Handle Slide Area，添加了额外文字和按钮 |

### 5.2 十大偏差（启动链）

| # | 问题 | Prefab | Godot | 影响 |
|---|------|--------|-------|------|
| 1 | **btnLogin 行为** | 全屏透明按钮(0-0→1-1) | "开始游戏"独立按钮 | 登录触发区域缩小 |
| 2 | **sldSpeed Handle** | 82×82 圆形滑块 | 缺失 | 视觉不精确 |
| 3 | **txtPercent 位置** | 右中锚, 进度条左侧 | 右下角硬编码 | 位置错误 |
| 4 | **inputAccount 尺寸** | 543×64 中锚居中 | 376×62 手动偏移 | 尺寸位置不匹配 |
| 5 | **pnlVersion 位置** | 右下锚 | 右上区域 | 位置错误 |
| 6 | **btnServerSel** | active=FALSE(隐藏) | 始终显示 | 多余元素 |
| 7 | **imgTipLogin** | 536×30 中顶锚 | 500×30 就近摆放 | 尺寸和锚点不精确 |
| 8 | **LaunchView RawImage** | 1680×1680 中锚居中 | (-200,-120) 偏移 +α | 偏移而非居中 |
| 9 | **@richBottom 版权** | 3行全 active=FALSE | 1行始终显示 | 多余元素 |
| 10 | **Loading 额外文本/按钮** | 无 | "进入主城"+"进入"按钮 | 多余元素 |

### 5.3 active=FALSE 处理

多处节点在 prefab 中默认隐藏，在特定条件下由 C# 逻辑激活：

| 节点 | active | 触发条件（推断）|
|------|--------|----------------|
| @rawImgBg | FALSE | 可能是横屏/竖屏适配备用背景 |
| @videoPlayer | FALSE | 启动视频播放完毕后的动画层 |
| btnServerSel | FALSE | 多服务器可用时激活 |
| txtServer | FALSE | 服务器标签文字 |
| btnNotice/Repair/Switch/Select→Text | FALSE | 按钮文字（可能由图片替代）|
| @richBottom→txtGameTip/Copyright/Copyleft | FALSE | 仅在首次启动或特定地区显示 |

---

## 6. 缺失资源清单

| View | 缺失资源 | 用途 |
|------|---------|------|
| LaunchView | `launch.mp4` | 启动视频 |
| LoginView | pnlFunction 按钮图标 (60×60 ×4) | 公告/修复/账号/切换图标 |
| LoginView | btnLogin 按钮图 | 登录按钮样式 |
| LoginView | btnAge 图标 | 12+ 年龄标记 |
| LoginView | inputAccount 输入框背景 | 输入框装饰 |
| LoadingView | sldSpeed Backgroud/Fill/Handle 样式 | 进度条滑块视觉 |
| LoadingView | _loading_tip 系列图片 | 加载提示（manifest 中有 `loading_tip.bytes` 含 `loading_1_1~loading_6_9` key）|

---

## 7. 下一步建议

1. **LoginView 布局重排** — 改为中轴对齐，imgLogo → inputAccount → btnServerSel → togAgree 沿垂直中轴排列
2. **pnlFunction 采用真实图标** — 导出 60×60 按钮图替换纯文本
3. **btnLogin 改为全屏覆盖** — 或保持独立按钮但标注差异
4. **LoadingView sldSpeed 还原** — 加入 Handle(82×82) 滑块，调整 txtPercent 到进度条左侧
5. **移除 Godot 额外元素** — LoadingView 中 "进入主城" 提示和 "进入" 按钮（或标注为 MVP 便利功能）
6. **active=FALSE 元素按需显示** — btnServerSel 默认隐藏，仅在有服务器数据时展示
7. **导出 loading_tip 图片** — 从 `loading_tip.bytes` 的 key 反查 manifest，定位并导出 `loading_1_1~loading_6_9` 等图片作为加载背景
