# 资源目录与源码作用索引

本文档记录当前已经梳理出的目录、关键文件和用途，后续做 Godot 界面还原时优先查这里，避免重复定位。

## 总体目录

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres` | APK 解包、dex 反编译、原始资源和参考截图目录。用于追溯 Android 壳、原始包结构、截图参考。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full` | 已解密资源 + Godot 4 本地 Demo 工程。当前主要实现和验证都在这里。 |
| `D:\work\openclaw-workspace\arpg\tools` | 本项目分析/转换脚本和 Godot 可执行文件所在目录。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources` | JADX 反编译后的 Java 源码。主要用于理解 Android 启动、SDK、Cocos JSB 桥接，不是主 UI 布局来源。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\lib` | APK 解出的 native so。此前用于定位资源解密逻辑，后续如需继续分析 native 行为再查。 |

## 原始解包目录

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres\assets` | 原始 APK assets。包含 Cocos bundle、project.json、资源包等。若需要对比解密前后结构，从这里开始。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\res` | Android 原生 res 目录。主要是启动图标、原生配置等，游戏 UI 不是这里定义。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes.dex` 到 `classes4.dex` | 原始 dex。已导出到 `classes-source\sources` 方便阅读。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\主屏.jpg` | 用户提供/保留的原主城截图，只作为视觉参考，不能当作实际界面资源。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\加载页.jpg` | 原启动加载页截图。已匹配到真实资源 `assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png`。 |

## 解密后 Godot 工程

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\project.godot` | Godot 工程配置。当前默认入口是 `res://scenes/original_loading.tscn`。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets` | 解密后的 Cocos 资源根目录。Godot 脚本直接从这里读取图片、json、音频等。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data` | 由脚本生成的索引和中间数据，如资源总目录、prefab 布局、Spine 索引。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\scenes` | Godot 场景文件。包含启动页、登录页、选服页、主城页、资源浏览器、prefab 预览器。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\scripts` | Godot GDScript 实现。负责界面搭建、资源加载、导航和预览逻辑。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\converted` | 转换/缓存输出目录。后续如做格式转换或导出可继续复用。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\decrypt_report.*` | 解密报告和 Godot import 生成的 translation 文件。用于核对哪些资源解密成功。 |

## Cocos Bundle

### `assets/main`

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\main\index.js` | 最重要的运行时代码。包含登录、加载、主城、英雄立绘、面板打开逻辑等。界面还原时优先搜索这个文件。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\main\config.json` | main bundle 配置。确认了场景 `db://assets/Scene/Main.fire` 和 `db://assets/Scene/updataScene.fire`，依赖 `resources`、`internal`，`encrypted=false`。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\main\import` | main bundle 的 import JSON。场景和部分资源元数据在这里。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\main\native` | main bundle 的 native 文件。当前包含 manifest 和少量 native 资源。 |

`assets/main/index.js` 已确认的关键线索：

| 位置 | 结论 |
| --- | --- |
| `index.js:54517` | 登录后平台登录面板加载 `Prefab/login/pfLoginPanelPre`。 |
| `index.js:80002` | `HeroLhPanel` 模块定义，处理英雄立绘展示页。 |
| `index.js:99534` | 默认主城角色 `_roleLhbody = "105004"`。 |
| `index.js:99542` | 默认主城背景 `_bgbody = 0`。 |
| `index.js:100399` | `MainUIPanel.showBg` 动态加载 `Prefab/bigImage/<id>`。 |
| `index.js:54193` | `RoleLh` 根据类型拼出 `Prefab/HerolhPrefab/<bodyID>` 等资源路径。 |

结论：`MainPre.json` 不是完整主城截图。真实主城至少由三层组成：

1. `Prefab/mainpanel/MainPre`：主城 UI 层。
2. `Prefab/bigImage/<id>`：运行时加载的背景层。
3. `Prefab/HerolhPrefab/<bodyID>`：运行时加载的角色 Spine 立绘层。

### `assets/resources`

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\resources\config.json` | resources bundle 的总索引，记录 path -> uuid/type。查 prefab、图片、Spine、音频路径先看这里。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\resources\import` | Cocos 序列化资源 JSON。Prefab、SpriteFrame、SkeletonData 等主要在这里。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\resources\native` | 图片、音频、二进制等 native 文件。Godot 预览加载图片主要来自这里。 |

已确认的核心路径：

| Cocos 资源路径 | import / native 路径 | 作用 |
| --- | --- | --- |
| `Prefab/loading/LoadingPre` | `assets/resources/import/71/71d56f9c-78d3-4b4c-99a5-7582c52b12f3.json` | 启动初始化加载页 prefab。 |
| `Prefab/loading/loadingProgress` | `assets/resources/import/8b/8b71b1c2-4572-4283-8bf1-32396e03cf64.json` | 加载进度条相关 prefab。 |
| `image/com/login/dl_bg` | `assets/resources/native/e8/...` | 登录页背景资源路径。 |
| `Prefab/login/LoginPre` | `assets/resources/import/a3/a3a9989b-23b1-46a6-ad24-112682294a7c.json` | 登录底层 prefab，含背景和登录按钮等。 |
| `Prefab/login/pfLoginPanelPre` | `assets/resources/import/fc/fc3b94c3-c07b-4eb2-826e-2ad5d962c9e7.json` | 平台登录/开始游戏面板 prefab。 |
| `Prefab/mainpanel/MainPre` | `assets/resources/import/fd/fd77b1d2-32ad-46c4-be16-ef14bc2423d0.json` | 主城 UI 层 prefab。 |
| `Prefab/mainpanel/daohangPre` | `data/prefab_layouts/daohangPre.json` | 主城底部导航子 Prefab。包含部分 UISpine/Spine 导航资源，不能完全按静态 SpriteFrame 使用。 |
| `Prefab/mainpanel/heroHead` | `data/prefab_layouts/heroHead.json` | 主城左上玩家头像/等级/战力区域子 Prefab。用于校正玩家信息坐标。 |
| `image/head/105004` | `assets/resources/native/d7/d7bf0f4d-1dc9-4fda-80c0-65dfeee3316a.png` | 默认主城角色 `105004` 的头像 SpriteFrame。 |
| `image/com/mainpanel/zjm_btn_rukou0..4` | `assets/resources/native/1f/1f6b547b4.png` | 主城右侧入口条 SpriteFrame。`zjm_btn_rukou4` 带 rotated 标记。 |
| `Prefab/HerolhPrefab/105004` | `assets/resources/import/00/00482677-9b33-43a2-91b3-fd0d9c1259a6.json` | 默认主城角色立绘 prefab，指向 Spine 数据。 |
| `assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png` | native PNG | 与原始 `加载页.jpg` 匹配的启动加载背景图。 |

## 生成数据

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\catalog.json` | 资源总索引。资源浏览器主要读取它。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\prefabs.csv` | 原始 prefab 清单。用于统计和筛选还原目标。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\prefab_layouts.json` | 已导出的核心 prefab 布局汇总。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\prefab_layouts\*.json` | 单个 prefab 的简化布局 JSON。Godot 当前用它还原 UI 层。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\mainpre_asset_trace.json` | 主城 `image/com/mainpanel/*` SpriteFrame 追踪结果，记录 path、uuid、import、native atlas、rect、rotated/originalSize 等信息。替换主城占位按钮时优先查。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\prefab_restore_inventory.csv` | Prefab 还原清单 CSV。适合排序、过滤和批处理。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\prefab_restore_inventory.md` | Prefab 还原清单 Markdown。适合人工阅读。 |
| `D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\spine_preview_index.json` | Spine 索引，当前用于资源浏览器查看 skeleton 名、动画名、atlas/png。 |

`data/prefab_layouts/*.json` 的字段含义：

| 字段 | 作用 |
| --- | --- |
| `prefab` | Cocos 资源路径，例如 `Prefab/mainpanel/MainPre`。 |
| `import` | 对应的 import JSON 路径。 |
| `nodes` | 解析出的节点列表。 |
| `parent_index` | 父节点索引。还原 Cocos 局部坐标时必须使用。 |
| `active` | Cocos `_active`。当前 Godot 预览会跳过隐藏节点。 |
| `position` | 节点本地坐标。 |
| `global_position` | 已按父节点累加后的简化全局坐标。当前预览主要用它。 |
| `texture_path` | SpriteFrame 对应的 native 图片路径。 |
| `skeleton_*` | Spine SkeletonData 解析结果。 |

## Godot 场景与脚本

| 路径 | 作用 |
| --- | --- |
| `scenes/original_loading.tscn` / `scripts/original_loading.gd` | 当前默认启动页。使用真实加载背景，模拟本地加载进度后跳登录页。 |
| `scenes/original_login.tscn` / `scripts/original_login.gd` | 登录页还原入口。加载 `LoginPre`、`pfLoginPanelPre` 相关资源。 |
| `scenes/original_server_select.tscn` / `scripts/original_server_select.gd` | 本地选服页。当前不连服务端，点击进入主城页。 |
| `scenes/original_home_screen.tscn` / `scripts/original_home_screen.gd` | 当前主城页。使用 `MainPre.json` 做 UI 层，背景和角色层独立选择。 |
| `scenes/original_main_city.tscn` / `scripts/original_main_city.gd` | 之前保留的独立主城/预览场景。 |
| `scenes/resource_browser.tscn` / `scripts/resource_browser.gd` | 资源浏览器。支持图片、文本、音频、Prefab、Scene、Spine 索引查看。 |
| `scenes/cocos_prefab_preview.tscn` / `scripts/cocos_prefab_preview.gd` | Prefab 布局预览器。用于检查导出的 `data/prefab_layouts`。 |

当前本地运行命令：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

## 分析/转换工具

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\tools\decrypt_nvshen_resources.py` | 批量解密资源脚本。用于从原始资源生成可读/可加载资源。 |
| `D:\work\openclaw-workspace\arpg\tools\cocos_xor_resource_tool.py` | Cocos 资源 XOR/格式辅助工具。 |
| `D:\work\openclaw-workspace\arpg\tools\build_godot_resource_demo.py` | 构建 Godot 资源 Demo 和资源索引的脚本。 |
| `D:\work\openclaw-workspace\arpg\tools\export_cocos_prefab_layout.py` | 把 Cocos prefab import JSON 导出为简化布局 JSON。 |
| `D:\work\openclaw-workspace\arpg\tools\export_spine_preview_index.py` | 导出 Spine 预览索引。 |
| `D:\work\openclaw-workspace\arpg\tools\README_nvshen_decrypt.md` | 资源解密定位过程和脚本说明。 |
| `D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe` | 当前用于运行/测试 Godot 工程的控制台版 Godot。 |

## 反编译源码目录

| 路径 | 作用 |
| --- | --- |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\org\cocos2dx\javascript` | 游戏 Android 壳和 SDK 桥接代码。优先阅读这里。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\org\cocos2dx\lib` | Cocos Android runtime、GLSurfaceView、JSB、Downloader、WebView、Video 等。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\org\cocos2dx\okhttp3` | Cocos 打包的 OkHttp。主要是下载/网络库，不是 UI。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\org\cocos2dx\okio` | OkHttp 依赖库，不是 UI。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\com` | 第三方 SDK 为主，例如广告、Firebase、Google、Facebook、Unity、Applovin 等。通常可先忽略。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\androidx` | AndroidX 支持库。忽略。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\kotlin` | Kotlin runtime。忽略。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\okhttp3` / `okio` | 另一份网络库包名。忽略，除非分析请求行为。 |
| `D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\A*` 到 `Z*` 等短名目录 | 混淆后的第三方/依赖代码较多。先不要作为 UI 还原入口。 |

关键 Java 文件：

| 文件 | 作用 |
| --- | --- |
| `org\cocos2dx\javascript\AppActivity.java` | Android Activity 入口，继承 `Cocos2dxActivity`。包含 Facebook/Google/Firebase 登录、Applovin 激励视频、JSB 回调，例如 `Cocos2dxJavascriptJavaBridge.evalString(...)`。 |
| `org\cocos2dx\javascript\SdkApplication.java` | Application 入口/SDK 初始化。 |
| `org\cocos2dx\javascript\SDKWrapper.java` | 从 assets `project.json` 读取 `serviceClassPath`，初始化并分发生命周期给 SDKClass。 |
| `org\cocos2dx\javascript\GPSdk.java` | Google/Firebase 登录相关桥接。 |
| `org\cocos2dx\javascript\EMSdk.java`、`ApplovinSdk.java`、`AdjustSdk.java`、`UtilSdk.java`、`NetworkUtils.java` | 广告、统计、工具、网络辅助桥接。 |
| `org\cocos2dx\javascript\service\SDKClass.java` / `SDKInterface.java` | SDK 生命周期抽象。 |
| `org\cocos2dx\lib\Cocos2dxActivity.java` | 创建 Cocos GL 视图、调试信息、生命周期处理。 |
| `org\cocos2dx\lib\Cocos2dxJavascriptJavaBridge.java` | Java 调 JS 的桥接入口。分析原生回调到 JS 时看它。 |
| `org\cocos2dx\lib\Cocos2dxHelper.java`、`Cocos2dxRenderer.java`、`Cocos2dxDownloader.java` | Cocos runtime 辅助、渲染和下载。 |

结论：反编译 Java 能帮助理解“程序如何启动 Cocos、如何登录/广告/SDK 回调 JS”，但游戏 UI 的具体 prefab、坐标、图片、动态加载链路主要在 `assets/main/index.js` 和 `assets/resources`。

## UI 还原入口链

| 阶段 | 原始线索 | Godot 当前实现 |
| --- | --- | --- |
| 启动/更新页 | `assets/main/config.json` 的 `Scene/updataScene.fire`，`Prefab/loading/LoadingPre`，`Prefab/loading/loadingProgress` | `scenes/original_loading.tscn` |
| 登录页 | `Prefab/login/LoginPre`，`Prefab/login/pfLoginPanelPre`，`index.js:54517` | `scenes/original_login.tscn` |
| 选服页 | `index.js` 中 `ServerSelectPanel` / `ServerMainPanel` / `ServerData` 相关模块 | `scenes/original_server_select.tscn` |
| 主城页 | `Prefab/mainpanel/MainPre` + `Prefab/bigImage/<id>` + `Prefab/HerolhPrefab/<bodyID>` | `scenes/original_home_screen.tscn` |
| 英雄立绘/动画 | `RoleLh`、`HeroLhPanel`、`Prefab/HerolhPrefab/*`、`data/spine_preview_index.json` | 资源浏览器可查看 Spine 索引，尚未真实播放骨骼动画 |

## 常用定位命令

读取文件时明确 UTF-8：

```powershell
Get-Content -LiteralPath "D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\org\cocos2dx\javascript\AppActivity.java" -Encoding UTF8 -TotalCount 260
```

定位运行时 UI 逻辑：

```powershell
rg -n "MainUIPanel|showBg|HeroLhPanel|RoleLh|_roleLhbody|_bgbody|PFLoginPanel|ServerSelectPanel" "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\main\index.js"
```

定位资源路径：

```powershell
rg -n "Prefab/login/LoginPre|Prefab/login/pfLoginPanelPre|Prefab/mainpanel/MainPre|Prefab/HerolhPrefab/105004|image/com/login/dl_bg" "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\resources\config.json"
```

查询主城已解析 SpriteFrame 映射：

```powershell
Get-Content -Encoding UTF8 "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\mainpre_asset_trace.json"
```

查看 Cocos/SDK Java 入口：

```powershell
rg -n "Cocos2dxJavascriptJavaBridge|evalString|project.json|serviceClassPath|onCreate|onActivityResult" "D:\work\openclaw-workspace\arpg\nvshenres\classes-source\sources\org\cocos2dx"
```

## 后续优先级

1. 继续从 `assets/main/index.js` 梳理 `LoginPanel`、`PFLoginPanel`、`ServerSelectPanel`、`MainUIPanel` 的真实打开顺序。
2. 扩展 `export_cocos_prefab_layout.py`，补齐 anchor、opacity/color、Label、Widget、Layout、ScrollView、九宫格 Sprite。
3. 自动生成 `Prefab/bigImage/*` 背景候选和 `Prefab/HerolhPrefab/*` 角色候选。
4. 接入或实现 Spine 播放能力，把主城角色从 atlas 预览升级为真正的 `idle/show` 动画。
5. 用 `data/prefab_restore_inventory.md` 逐个推进高优先级界面：登录、选服、主城、英雄、背包、抽卡、战斗。
