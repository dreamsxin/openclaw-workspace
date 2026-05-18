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

注意：部分 SpriteFrame 有 `rotated: 1`、`offset`、`originalSize`，直接裁剪 rect 会有黑块/偏移。当前导出器已写出 `sprite_offset`、`sprite_original_size`、`sprite_rotated`，通用 prefab layer、prefab 预览器和主城页已按 Cocos trim 规则复原到透明原始尺寸画布。

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
- 已将左侧竖排快捷按钮和左侧四列活动入口拆开坐标，避免图标重叠。
- 已确认主城活动广告入口资源为 `assets/resources/native/00/002545b0-69b1-4515-ac70-e545a4c8b5d2.png`，对应 `MainPre.json` 的 `zjm_image_GuanGao1`，尺寸约 `320x150`，全局中心约 `(-464.409, -115.622)`。
- 已按 `MainPre.json` 将右侧入口条收缩到 `260x34` 的父节点尺寸，并把底部导航替换为 `cm_icon_ChengZhen/YingXiong/CangKu/FuBen/GongHui` 等真实 SpriteFrame。
- 已用 `zjm_btn_rukou0..4` 的 `offset/originalSize/rotated` 元数据复原右侧入口条，`zjm_btn_rukou4` 不再依赖手工规避 rotated 裁剪。
- 已接入主城动态 Spine 角色轮换：`105004`、`SuLa_LH`、`YouDuoLa_LH`。
- 主城默认角色已改为原始逻辑对应的 `105004` Spine；静态 `Illustration` 仍保留在 Hero 轮换中，但不再作为默认主屏角色。
- `YouDuoLa_LH` 来源为 `assets/resources/native/1b/1baef3d2-6771-487a-84f3-f3222ae92456.png`，反查到 SkeletonData `2bb12a28-eeb0-4dbc-b5f3-c90d869cbc14`。
- 主城截图回归可用 `--home-hero <name>` 和 `--home-bg <name-or-index>` 指定角色/背景，例如 `--home-hero YouDuoLa_LH`。
- 主城角色展示区域可点击切换动作。`105004` 已验证可从 `idle` 切到 `show`，也可用 `--home-click-hero-once` 模拟点击。
- 主城动作可用 `--home-animation <name>` 指定，便于截图回归。
- 主城主要入口已接到对应 prefab 预览：
  - 底部 `英雄` -> `Prefab/HeroPanel/HeroMainPre`
  - 底部 `仓库` -> `Prefab/BagPanel/BagPre`
  - 底部 `冒险` -> `Prefab/Battle/battle`
  - 底部 `副本` -> `Prefab/SkyCityPanel/SkyCityPre`
  - 底部 `公会` -> `Prefab/Guild/GuildMainPre`
  - 左侧/右侧 `竞技` -> `Prefab/JingjiPrefab/JingjiPre`
  - `召唤` -> `Prefab/DrawCard/drawCardPre`
  - 活动广告/广告入口 -> `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre`
- `cocos_prefab_preview.gd` 支持从 `Navigation.go_with_args(..., {"layout": "英雄"})` 或命令行 `--prefab-layout 英雄` 打开指定界面。
- Prefab 预览器已改为优先使用导出的 `global_position`，并跳过无贴图根节点，核心界面骨架比局部坐标版更接近原布局。
- Prefab 导出器已补 `cc.Label` 文本字段；预览器可以显示真实 Label 文本并应用节点 scale。英雄、背包、抽卡等主要界面现在不再只显示节点名。
- Prefab 导出器已补 `cc.Sprite._type/_sizeMode` 和 SpriteFrame `capInsets`；预览器对 sliced Sprite 使用 `NinePatchRect` 渲染。
- `HeroMainPre` 预览已叠加本地 mock 的 `105004` Spine 角色展示，便于从主城进入英雄面板后检查角色展示效果。
- Prefab 导出器已补 `_anchorPoint`；预览器已按 Cocos anchor 计算节点左上角，减少 Label 和按钮相对面板的错位。
- Prefab 导出器已补 `cc.Widget` 的 `_alignFlags` 与 left/right/top/bottom，并在导出阶段做基础贴边/拉伸计算。登录面板等使用 Widget 的 prefab 更接近 Cocos 运行时布局。
- `BagPre` 预览已叠加本地背包条目 mock。条目结构来自 `Prefab/BagPanel/GridBoxItemPre`，真实图标来自 `assets/resources/config.json` 中的 `image/equipment/<icon>` 索引。
- 当前结论：prefab 可还原静态节点坐标、尺寸、锚点、Widget；背包列表等动态内容需要继续追源码中的 `cc.instantiate` / `setImgUrl` 规则，并用子 Prefab 加本地数据补齐。

当前不足：

- 角色 Spine 已能播放，但仍是项目内轻量 runtime，和官方 Spine runtime 可能有细节差异。
- `SuLa_LH` 的 `idle` 姿态偏横向，主城展示后续需要结合原角色面板确认是否应使用 `show` 或额外偏移。
- `MainPre` 和主要功能 prefab 的 Layout、ScrollView 仍未完整映射；当前主要界面是可进入且带文本/anchor/基础 Widget/基础九宫格的 prefab 骨架预览，还不是最终可交互面板。
- 顶部资源栏、底部入口、右侧入口还有大量运行时动态内容未补齐。

下一步：

1. 从 `Prefab/bigImage/*` 自动生成背景候选。
2. 从 `Prefab/HerolhPrefab/*` 自动生成角色候选，并接入主城和 Spine 列表。
3. 在资源浏览器中继续完善 Spine atlas/动画索引查看。
4. 继续补轻量 Spine runtime 的约束、clipping、path 等高级能力。
5. 逐步把 `MainPre` 的按钮/入口区域补成可点击导航。
6. 优先完善 `HeroMainPre`、`BagPre`、`drawCardPre` 的 Label、九宫格和滚动列表 mock 数据。

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
- 角色使用项目内 `SimpleSpinePlayer` 播放 Spine，允许和官方 runtime 有小差异。

长期目标：

- 继续提高 `idle` / `show` 动画精度。
- 主城入口按钮能跳转到对应 prefab 预览页。

## 验证方式

## Godot 使用说明

本工程固定使用 Godot 4.6.2 控制台版：

```powershell
$godot = "D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe"
$proj = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

常用运行方式：

```powershell
& $godot --path $proj
& $godot --path $proj --scene "res://scenes/original_home_screen.tscn"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" -- --prefab-layout "公会"
```

命令行参数规则：

- `--path <dir>` 指向 Godot 工程目录，目录内必须有 `project.godot`。
- `--scene <res://...>` 可直接启动指定场景，用于跳过前置流程调试某个页面。
- `--quit-after <frames>` 适合截图回归，等待若干帧后自动退出。
- `--log-file <file>` 写 Godot 引擎日志；PowerShell 的 `*> file.log` 同时收集 stdout/stderr。
- `--` 后面的参数不再由 Godot 引擎解析，而是由脚本通过 `OS.get_cmdline_user_args()` 读取。
- `--headless` 只能做语法/启动校验，不适合用 `get_viewport().get_texture()` 截图。
- Windows 下常见 `WASAPI: init_output_device error` 是音频设备初始化警告，界面截图和脚本校验时可忽略；真正需要优先处理的是 `SCRIPT ERROR`、`Parse Error`。

截图回归参数：

```powershell
& $godot --path $proj --scene "res://scenes/original_loading.tscn" --quit-after 100 -- --capture-loading "$proj\loading_check.png" *> "$proj\loading_check.log"
& $godot --path $proj --scene "res://scenes/original_login.tscn" --quit-after 100 -- --capture-login "$proj\login_check.png" *> "$proj\login_check.log"
& $godot --path $proj --scene "res://scenes/original_server_select.tscn" --quit-after 100 -- --capture-server-select "$proj\server_check.png" *> "$proj\server_check.log"
& $godot --path $proj --scene "res://scenes/original_home_screen.tscn" --quit-after 100 -- --capture-home-screen "$proj\home_check.png" *> "$proj\home_check.log"
```

功能界面 prefab 预览：

```powershell
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "英雄" --capture-prefab-preview "$proj\prefab_hero.png" *> "$proj\prefab_hero.log"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "背包" --capture-prefab-preview "$proj\prefab_bag.png" *> "$proj\prefab_bag.log"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "抽卡" --capture-prefab-preview "$proj\prefab_draw.png" *> "$proj\prefab_draw.log"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "公会" --capture-prefab-preview "$proj\prefab_guild.png" *> "$proj\prefab_guild.log"
```

Spine 查看器：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn"
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 100 -- --spine-path "res://data/spine_runtime/105004.json" --spine-animation show --capture-spine-viewer "$proj\spine_105004_show.png" *> "$proj\spine_105004_show.log"
```

## 界面还原实现说明

当前还原不是用截图贴图，而是按以下链路把 Cocos Creator 资源转为 Godot 可渲染结构：

```text
assets/resources/config.json
  -> import/*.json / native/*.png / spine json+atlas
  -> tools/*.py 导出索引与 prefab layout
  -> data/*.json
  -> scripts/*.gd 在 Godot 中渲染和补运行时 mock 数据
```

核心导出脚本：

- `tools/export_cocos_prefab_layout.py`：把 Cocos prefab 导出为 `data/prefab_layouts/*.json`，包含节点树、全局坐标、尺寸、锚点、SpriteFrame、Label、Widget、NinePatch 信息。
- `tools/export_named_resource_index.py`：把源码/运行时常见的字符串资源路径导出为 `data/named_resource_index.json`，用于 `setImgUrl("image/...")` 这类动态加载。
- `tools/export_equipment_icon_index.py`：导出 `image/equipment/*`，用于背包等动态列表 mock。
- `tools/export_spine_runtime_data.py`：把 Cocos `sp.SkeletonData` 转为项目内轻量 Spine runtime 可读的 `data/spine_runtime/*.json`。
- `tools/cocos_spine_trace_tool.py`：用于 native PNG、SkeletonData、压缩 UUID 之间反查。

Godot 渲染脚本分工：

- `scripts/original_loading.gd`：启动初始化加载页，当前保留手工流程控制。
- `scripts/original_login.gd`：登录页，本地点击进入选服页。
- `scripts/original_server_select.gd`：选服页，本地 mock 服务器列表。
- `scripts/original_home_screen.gd`：主城页，组合 `bigImage` 背景、`HerolhPrefab` Spine 角色、`MainPre` UI。
- `scripts/cocos_prefab_preview.gd`：通用功能界面 prefab 预览器，负责英雄、背包、抽卡、公会等页面骨架和动态 mock 数据。
- `scripts/simple_spine_player.gd`：项目内轻量 Spine 3.8 播放器，用于主城角色和 Spine 查看器。

Prefab 静态节点按 Cocos 规则处理：

- 坐标优先使用导出的 `global_position`，避免把子节点局部坐标误当根坐标。
- `_active=false` 的节点默认不绘制。
- SpriteFrame 使用 `rect`、`offset`、`originalSize`、`rotated` 复原到透明原始尺寸画布。
- `cc.Sprite` 的 sliced 类型使用 `NinePatchRect`，读取 `capInsets`。
- `cc.Label` 读取 `_string`、字号、行高和对齐。
- `cc.Widget` 当前支持基础贴边、居中和四边拉伸。

运行时动态内容的处理原则：

- prefab 中没有实例化出来的列表项，不手工猜整张截图，而是查源码里的 `cc.instantiate`、`setImgUrl`、`loadRes` 规则。
- 动态列表使用对应子 prefab 加本地 mock 数据补齐，例如 `BagPre` 使用 `GridBoxItemPre`，图标来自 `image/equipment/*`。
- 按字符串路径加载的图片先扩展 `export_named_resource_index.py` 的前缀，再在 Godot 中通过 `_add_named_image()` 使用真实资源。
- 角色展示优先使用 `Prefab/HerolhPrefab/*` 对应 Spine；只有未导出 runtime 时才临时使用静态贴图。

当前已验证的功能界面补丁：

- `HeroMainPre`：叠加 `105004` Spine 展示区。
- `BagPre`：叠加本地背包条目，结构来自 `GridBoxItemPre`。
- `drawCardPre`：叠加抽卡卡池、卡牌、宝箱进度和召唤按钮。
- `GuildMainPre`：叠加公会大厅背景、旗帜、信息和入口。
- `SkyCityPre`：叠加天空城空岛、建筑、矿物、副本入口和底部操作按钮；资源来自 `image/com/skyCity/*`。
- `JingjiPre`：叠加 PVP 背景、五个竞技玩法入口、膜拜信息和赛季奖励；资源来自 `image/com/Jingji/*` 与 `image/com/pvpActivity/*`。
- `battle`：叠加地图背景、左右 5 个战斗站位、头像、血条、伤害/治疗反馈和胜利奖励面板；资源来自 `image/com/map/*`、`image/head/*`、`image/com/Battle*`。
- `DrawCardActivityPre`：叠加活动标题、倒计时、限定英雄概率提升、抽数奖励进度、活动兑换和操作按钮；资源来自 `image/com/ActivityPanel/ZhaoHuan/*`、`image/com/ActivityPanel/NewHeroComing/*`、`image/com/ActivityPanel/thousandDrawCardActivity/*`。
- `HeroMainPre`：叠加英雄列表、属性面板、技能格、装备格和 `105004` Spine 展示；资源来自 `image/en/HeroPanel/*`、`image/comHeroGrid/*`、`image/skill/*`、`image/head/*`。
- `BagPre`：叠加背包分类、道具列表、详情区和使用/出售/一键出售操作；装备/道具图标来自 `data/equipment_icon_index.json`，通用按钮来自 `image/common/cm_btn*`。

启动工程：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

当前默认入口是 `res://scenes/original_loading.tscn`，启动后按“加载页 -> 登录页 -> 选服页 -> 主城页”流程进入。登录页可显式运行：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full" --scene "res://scenes/original_login.tscn"
```

无窗口基础校验：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --headless --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full" --quit
```

截图检查：

- 登录页：`--capture-login`
- 选服页：`--capture-server-select`
- 主页面：`--capture-home-screen`

Godot 4.6.2 命令注意：

```powershell
$godot = "D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe"
$proj = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
$out = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\home_check.png"
$log = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\godot_check.log"
$godotLog = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\godot_engine.log"
& $godot --path $proj --scene "res://scenes/original_home_screen.tscn" --quit-after 80 --log-file $godotLog -- --capture-home-screen $out *> $log
```

- 指定场景使用 `--scene <path>`。
- `--` 后面的参数由 `OS.get_cmdline_user_args()` 读取。
- `--headless` 使用 dummy 渲染，不能用 `get_viewport().get_texture()` 截图。
- PowerShell 中使用 `*> file.log` 可同时重定向 stdout/stderr，方便查看 Godot 脚本错误。

Spine 查看器：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 80 --log-file $godotLog -- --spine-animation attack --capture-spine-viewer "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\spine_attack.png" *> $log
```

也可以直接指定 runtime JSON：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 80 -- --spine-path "res://data/spine_runtime/YiKaLuoSi.json" --spine-animation attack --capture-spine-viewer "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\spine_attack.png" *> $log
```

资源浏览器：

- 进入 `Spine` 分类。
- 如果该 skeleton 已存在 `data/spine_runtime/<name>.json`，会出现 `Open Spine Viewer`。
- 点击后会带着 runtime 路径和默认动画进入 `spine_character_viewer.tscn`。

主要 prefab 预览：

```powershell
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "公会" --capture-prefab-preview "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\prefab_guild.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "英雄" --capture-prefab-preview "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\prefab_hero.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "天空城" --capture-prefab-preview "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\prefab_skycity.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "竞技" --capture-prefab-preview "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\prefab_jingji.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "战斗" --capture-prefab-preview "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\prefab_battle.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "活动抽卡" --capture-prefab-preview "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\prefab_draw_activity.png" *> $log
```

- `背包`：使用 `GridBoxItemPre` + `image/equipment` mock 数据。
- `背包` 当前还额外补了分类按钮、详情面板和操作按钮；详情区仍受原 prefab 暗层影响，后续需统一处理 Mask/ScrollView 层级。
- 带运行时 mock 的 prefab 预览页会跳过无贴图、无文本的 Cocos 容器占位节点，避免 `content`、`mask`、`box` 这类半透明灰块遮住动态内容。
- `抽卡`：使用 `image/com/DrawCard` mock 数据。
- `抽卡` 当前还额外补了右侧卡池页签、召唤积分/消耗、十连结果预览和积分兑换信息；仍需继续处理原 prefab 静态贴图/文本与 mock 内容重叠。
- `公会`：使用 `image/com/Guild`、`image/guildFlag` mock 数据。
- `天空城`：使用 `image/com/skyCity` mock 建筑、矿物、空岛和副本入口。
- `竞技`：使用 `image/com/Jingji`、`image/com/pvpActivity` mock 玩法入口、排名、奖励和膜拜信息。
- `战斗`：使用 `image/com/map`、`image/head`、`image/com/Battle*` mock 战场、站位、血条和胜利面板。
- `活动抽卡`：使用 `image/com/ActivityPanel/ZhaoHuan`、`image/com/ActivityPanel/NewHeroComing`、`image/com/ActivityPanel/thousandDrawCardActivity` mock 活动奖池、抽数奖励和兑换区。
- `英雄`：使用 `image/en/HeroPanel`、`image/comHeroGrid`、`image/skill`、`image/head` mock 英雄列表、属性、技能、装备和角色展示。

局部 slot 调试：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 80 -- --spine-path "res://data/spine_runtime/YiKaLuoSi.json" --spine-animation idle --debug-slots "YiKaLuoSi_zuodatui,YiKaLuoSi_zuojiao,YiKaLuoSi_youdatui,YiKaLuoSi_youjiao" --capture-spine-viewer "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\spine_legs.png" *> $log
```

YiKaLuoSi 当前还原记录：

- 头饰：`YiKaLuoSi_toushi03` 绑定独立 `bone21`，和头部 `bone5` 不同；当前在 runtime 内保留最小角色级补偿，避免头冠悬浮。
- 腿部：`yik` / `zik` 是 setup-only 二骨 IK，runtime 已补 IK 求解和 IK 后子骨骼重算。
- 左侧脚部：问题主要来自 `rotate: true` mesh atlas UV 方向，已修正 rotated mesh UV 映射。
- `YiKaLuoSi_zuojiao` 是 weighted mesh，使用 `bone9`、`bone10`、`bone11` 权重；未发现 idle/run/attack/skill 的 deform timeline。

## 当前判断

登录到主页面可以还原，但应避免继续扩大手工拼图。后续应先完善统一 prefab 渲染器，再把登录、选服、主城逐步切回原始 prefab 驱动；运行时动态部分用本地 mock 数据补齐。
