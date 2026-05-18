# 登录到主页面界面还原梳理

目标：从游戏启动初始化加载页到进入主页面，按原始 Cocos prefab 和运行时代码逐步还原界面。禁止用截图冒充界面资源；截图只作为视觉参考。

## 当前 Godot 流程

Godot 默认入口：

```text
project.godot -> run/main_scene="res://scenes/original_loading.tscn"
```

当前链路：

```text
original_loading.tscn
  -> original_login.tscn
  -> original_server_select.tscn
  -> original_home_screen.tscn
```

旧链路曾经直接从登录页开始：

```text
original_login.tscn
  -> original_server_select.tscn
  -> original_home_screen.tscn
```

对应脚本：

- `scripts/original_login.gd`
- `scripts/original_server_select.gd`
- `scripts/original_home_screen.gd`
- `scripts/original_loading.gd`

## 原始 Cocos Prefab 对应关系

### 0. 启动初始化加载页

Godot 场景：

```text
scenes/original_loading.tscn
```

原始 prefab：

```text
Prefab/loading/LoadingPre
assets/resources/import/71/71d56f9c-78d3-4b4c-99a5-7582c52b12f3.json
data/prefab_layouts/LoadingPre.json
```

相关 prefab：

```text
Prefab/loading/loadingProgress
assets/resources/import/8b/8b71b1c2-4572-4283-8bf1-32396e03cf64.json
data/prefab_layouts/loadingProgress.json
```

已确认背景资源：

```text
assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png
```

说明：

- 用户提供的 `加载页.jpg` 是该资源的 `1280x576` 显示裁切/缩放参考。
- 原始资源尺寸为 `1575x720`。
- `LoadingPre` 中包含 `bg`、`logo`、`dl_progressbar1_jiazai`、`loading_jindutiao`、进度文字和提示文字。
- `Scene/Main.fire` 摘要里存在 `loadingLayer`，说明该页属于游戏启动初始化流程。
- `Scene/updataScene.fire` 摘要里存在 `updataBtn`、`updataNode`，应属于热更新/初始化流程。

当前 Godot 实现状态：

- 已新增 `original_loading.tscn`。
- 默认启动场景已改为 `original_loading.tscn`。
- 加载页显示真实背景资源和本地进度条。
- 加载完成后自动进入 `original_login.tscn`。

下一步：

1. 将加载页也改为完全读取 `LoadingPre.json`。
2. 补 `loading_jindutiao` Spine 或进度条动画。
3. 将 `LoadingPre` 中的提示文本、进度文本、logo 坐标按 prefab 精确还原。

### 1. 登录页

Godot 场景：

```text
scenes/original_login.tscn
```

原始 prefab：

```text
Prefab/login/LoginPre
assets/resources/import/a3/a3a9989b-23b1-46a6-ad24-112682294a7c.json
data/prefab_layouts/LoginPre.json
```

当前导出结果：

```text
nodes: 39
texture_nodes: 6
```

关键贴图节点：

- `bg`：登录背景，当前导出为 `assets/resources/native/e8/e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
- `loginBtn` / `Background`：登录按钮区域
- `wenziDi`：底部文字/遮罩区域
- `logo`：原 prefab 中存在，但 `_active=false`

当前 Godot 实现状态：

- 已能显示登录背景、Logo、底部装饰、登录按钮。
- 点击登录进入选服页。
- 目前实现仍偏手工，未完全由 `LoginPre.json` 自动生成。

下一步：

1. 将 `original_login.gd` 改为读取 `data/prefab_layouts/LoginPre.json`。
2. 保留少量手工补丁只处理点击区域和离线跳转。
3. 正确处理 `_active=false` 的 logo：默认不画，除非确认运行时代码会开启。
4. 处理九宫格/拉伸节点，避免按钮或底部条失真。

### 2. 选服页

Godot 场景：

```text
scenes/original_server_select.tscn
```

原始 prefab：

```text
Prefab/login/pfLoginPanelPre
assets/resources/import/fc/fc3b94c3-c07b-4eb2-826e-2ad5d962c9e7.json
data/prefab_layouts/pfLoginPanelPre.json
```

当前导出结果：

```text
nodes: 101
texture_nodes: 10
```

关键贴图节点：

- `2`：大背景，当前导出为 `assets/resources/native/e8/e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
- `btnSwitchAcount`：切换账号按钮
- `btnGG`：公告按钮
- `wenziDi`：底部文字/装饰区域
- `button`：原始按钮节点，但 `_active=false`
- `logo`：存在但 `_active=false`

当前 Godot 实现状态：

- 选服页已经能显示背景、公告/账号按钮、本地演示服、开始按钮。
- 点击开始进入主页面。
- 目前服务器列表是本地 mock，符合“不连接服务端”的目标。
- 当前实现仍偏手工，未完全由 `pfLoginPanelPre.json` 自动生成。

下一步：

1. 将背景、公告按钮、账号按钮、底部装饰切换为 prefab 自动渲染。
2. 服务器列表继续用本地 mock 数据填充。
3. 补 `Label`、`Button`、`NinePatchRect` 映射。
4. 明确哪些节点由服务端列表数据动态生成，不从 prefab 静态找。

### 3. 主页面

Godot 场景：

```text
scenes/original_home_screen.tscn
```

原始 prefab：

```text
Prefab/mainpanel/MainPre
assets/resources/import/fd/fd77b1d2-32ad-46c4-be16-ef14bc2423d0.json
data/prefab_layouts/MainPre.json
```

当前导出结果：

```text
nodes: 227
texture_nodes: 27
```

相关子 Prefab：

```text
Prefab/mainpanel/daohangPre
data/prefab_layouts/daohangPre.json

Prefab/mainpanel/heroHead
data/prefab_layouts/heroHead.json
```

辅助追踪文件：

```text
data/mainpre_asset_trace.json
```

该文件记录了主城相关 `image/com/mainpanel/*` 路径到真实 SpriteFrame/native atlas/rect 的映射，后续替换占位按钮优先查它。

关键结论：

`MainPre` 不是完整静态主城图。它主要是 UI 层，背景和角色由 JS 运行时选择。

运行时资源链：

```text
MainUIPanel.showBg -> Prefab/bigImage/<bgbody>
RoleLh -> Prefab/HerolhPrefab/<bodyID>
```

已确认默认值：

```text
_roleLhbody = "105004"
_bgbody = 0
```

左上头像：

```text
image/head/105004
assets/resources/native/d7/d7bf0f4d-1dc9-4fda-80c0-65dfeee3316a.png
```

右侧入口条：

```text
image/com/mainpanel/zjm_btn_rukou0 -> assets/resources/native/1f/1f6b547b4.png rect [639,292,364,50]
image/com/mainpanel/zjm_btn_rukou1 -> assets/resources/native/1f/1f6b547b4.png rect [675,65,341,56]
image/com/mainpanel/zjm_btn_rukou2 -> assets/resources/native/1f/1f6b547b4.png rect [675,230,336,56]
image/com/mainpanel/zjm_btn_rukou3 -> assets/resources/native/1f/1f6b547b4.png rect [675,3,342,56]
image/com/mainpanel/zjm_btn_rukou4 -> assets/resources/native/1f/1f6b547b4.png rect [684,591,387,58] rotated=1
```

常用主城图标 atlas：

```text
assets/resources/native/1a/1a7921f32.png
assets/resources/native/1f/1f6b547b4.png
assets/resources/native/14/140096250.png
assets/resources/native/18/18b29ae48.png
```

注意：部分 SpriteFrame 有 `rotated: 1`、`offset`、`originalSize`，直接裁剪 rect 会有黑块/偏移。当前 Godot 脚本只实现了基础 rotated 处理，还没有完整复原 Cocos trim/offset。

主城应分层：

```text
背景层：Prefab/bigImage/*
角色层：Prefab/HerolhPrefab/* Spine
UI 层：Prefab/mainpanel/MainPre
```

当前 Godot 实现状态：

- `original_home_screen.gd` 已读取 `MainPre.json` 渲染部分 UI。
- 已加入可切换背景按钮 `BG`。
- 已加入可切换角色按钮 `Hero`。
- 不再使用上传的 `主屏.jpg` 作为实际资源。
- 已使用 `global_position`，避免子节点局部坐标直接当根坐标。
- 已跳过 `_active=false` 隐藏节点。
- 已过滤一部分九宫格/动态面板误拉伸节点。

当前不足：

- 角色 Spine 还没有真正播放，只能显示贴图或替代立绘。
- `MainPre` 的 Label、Layout、ScrollView、Widget、九宫格仍未完整映射。
- 顶部资源栏、底部入口、右侧入口还有大量运行时动态内容未补齐。

下一步：

1. 从 `Prefab/bigImage/*` 自动生成背景候选。
2. 从 `Prefab/HerolhPrefab/*` 自动生成角色候选。
3. 在资源浏览器中先完善 Spine atlas/动画索引查看。
4. 调研或接入 Godot Spine runtime。
5. 逐步把 `MainPre` 的按钮/入口区域补成可点击导航。

## 实施顺序

### 第一步：统一 prefab 渲染器

目标：登录页、选服页、主页面都使用同一套 Cocos prefab 渲染逻辑。

需要补齐：

- `cc.Node` -> `Control`
- `cc.Sprite` -> `TextureRect`
- `cc.Button` -> 可点击 `Button` + 状态贴图
- `cc.Label` -> `Label`
- `cc.Widget` -> anchor/offset
- `cc.Layout` -> 容器布局
- 九宫格 Sprite -> `NinePatchRect`

### 第二步：登录页从手工切到 prefab

目标：`original_login.gd` 只负责加载 `LoginPre.json` 和绑定登录按钮。

保留本地逻辑：

```text
点击登录 -> Navigation.go("res://scenes/original_server_select.tscn")
```

### 第三步：选服页从手工切到 prefab

目标：`original_server_select.gd` 使用 `pfLoginPanelPre.json` 渲染静态视觉，服务器列表用本地 mock 填充。

保留本地逻辑：

```text
点击开始 -> Navigation.go("res://scenes/original_home_screen.tscn")
```

### 第四步：主页面三层还原

目标：主页面不再靠固定图片，而是由三类资源组合：

```text
bigImage 背景 + HerolhPrefab 角色 + MainPre UI
```

短期可接受：

- 背景可选，不要求和账号数据完全一致。
- 角色可选，不要求和服务端阵容一致。
- 角色先显示 Spine atlas/替代立绘，但必须标注未接入真实 Spine runtime。

长期目标：

- 真正播放 `idle` / `show` 动画。
- 主城入口按钮能跳转到对应 prefab 预览页。

## 验证方式

启动工程：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

无窗口基础校验：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --headless --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full" --quit
```

截图检查：

- 登录页：`--capture-login`
- 选服页：`--capture-server-select`
- 主页面：`--capture-home-screen`

## 当前判断

登录到主页面可以还原，但应避免继续扩大手工拼图。后续应先完善统一 prefab 渲染器，再把登录、选服、主城逐步切回原始 prefab 驱动；运行时动态部分用本地 mock 数据补齐。
