# 游戏界面分析过程记录

本文记录本次分析反编译游戏源码时使用的路径、工具、命令、观察结果和推断依据。最终界面与启动顺序整理见 `docs/game-ui-startup-analysis.md`。

## 环境

- 工作目录：`D:\work\openclaw-workspace\arpg\shaonv`
- Shell：PowerShell
- 主要输入：
  - `resources/AndroidManifest.xml`
  - `sources/`
  - `resources/assets/`
  - `../merge/reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/dump.cs`
  - `../merge/reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/*.csv`
  - `../merge/reverse-output/assets/assetstudio-cli-inventory.csv`

## 使用的工具

- PowerShell：目录浏览、文件读取、CSV 查询。
- `rg` / ripgrep：快速搜索源码、dump、Manifest。
- `Get-ChildItem`：列目录、确认资源和分析产物。
- `Get-Content -Encoding UTF8`：读取 Manifest、dump 片段、latest 指针文件。
- `Import-Csv`：读取 Il2CppDumper 分析表和 AssetStudio 资源清单。
- `Select-String`：从 Manifest 中抽取 Activity 和 `android:name`。
- `apply_patch`：创建 Markdown 文档。

没有使用联网搜索；分析完全基于本地反编译产物。

如果 PowerShell 预览中文出现乱码，先设置控制台为 UTF-8：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

## 步骤 1：确认工程结构

命令：

```powershell
Get-ChildItem -Force
```

观察：

- 当前目录只有两个主要目录：
  - `resources`
  - `sources`

命令：

```powershell
rg --files
```

观察：

- 文件量很大，包含 Android Java 反编译源码、第三方 SDK、Android 资源、Unity AssetBundle。
- 发现关键文件：
  - `resources/AndroidManifest.xml`
  - `resources/assets/yoo/Default/*.bundle`
  - `resources/assets/asd/YooAsset`
  - 大量 `sources/com/.../*.java`

命令：

```powershell
git status --short
```

观察：

- 当前仓库/上层目录有大量未跟踪文件。
- 本次分析没有回滚或修改既有源码，只新增 docs 文档。

## 步骤 2：确认 Android 启动入口

命令：

```powershell
Get-Content -Path resources\AndroidManifest.xml -Encoding UTF8 -TotalCount 220
```

观察：

- 包名：`com.and.gt.snhl`
- 版本：`versionName="1.18"`，`versionCode="19"`
- 主 Activity：
  - `com.daiei.monv.UnityPlayerActivity`
- Activity 配置：
  - `android:screenOrientation="userLandscape"`
  - `android:launchMode="singleTask"`
  - `android:theme="@style/UnityThemeSelector"`
  - `unityplayer.UnityActivity=true`
- Intent：
  - `android.intent.action.MAIN`
  - `android.intent.category.LAUNCHER`
  - `android.intent.category.LEANBACK_LAUNCHER`

命令：

```powershell
rg -n "UnityPlayerActivity|UnityPlayer|MAIN|LAUNCHER|activity" resources\AndroidManifest.xml sources\com sources\jp sources\org -g "*.java"
```

观察：

- Manifest 中 `com.daiei.monv.UnityPlayerActivity` 是唯一主启动 Activity。
- `sources\jp` 不存在，`rg` 报了路径不存在错误，不影响结论。
- 输出中大量 `activity` 来自广告、Google、Facebook、QuickGame SDK，不是游戏主 UI。

结论：

- Android 层只是启动 Unity 游戏壳。
- 游戏界面主体需要从 IL2CPP dump 和 Unity 资源中分析。

## 步骤 3：定位 IL2CPP dump

命令：

```powershell
Get-Content -Path ..\merge\reverse-output\il2cpp\latest.txt -Encoding UTF8
```

观察：

- latest 指向：
  - `D:\work\openclaw-workspace\arpg\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper`

命令：

```powershell
Get-ChildItem -Path ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper -Force
```

观察：

- 关键文件：
  - `dump.cs`
  - `il2cpp.h`
  - `script.json`
  - `stringliteral.json`
  - `analysis/class-index.csv`
  - `analysis/gameplay-class-index.csv`
  - `analysis/key-class-members.csv`

结论：

- `dump.cs` 是识别 Unity C# 类型、UI 类、管理器、状态枚举的主要依据。

## 步骤 4：搜索 UI、场景、Loading、登录相关类

命令：

```powershell
rg -n "class .*?(UI|View|Panel|Window|Page|Dialog|Popup|Form|Screen|Scene|Loading|Login|Lobby|Home|Main|Battle)" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

观察：

- 命中大量 UI 类型。
- 早期命中中有第三方示例/SDK，例如 Facebook、Apple、Google Play LoadingScreen。
- 游戏自身关键类型集中在以下区域：
  - `UIManager`
  - `UIPopupManager`
  - `UILobby`
  - `UILoading`
  - `UISceneLoading`
  - `UIInGame`
  - 大量 `UIPopup_*`
  - 大量 `UITutorial_*`

命令：

```powershell
rg -n "(LoadScene|SceneManager|YooAssets|Addressables|UIManager|UIPanel|OpenUI|ShowUI|Login|Lobby|Loading)" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

观察：

- 发现 `GameStep`、`LoadingPopupType`、`PlatformLoginManager`、`ReloadManager`、`UIManager`、`UILoading`、`UISceneLoading` 等。
- Unity Addressables 类型也存在，但那是 Unity/Addressables 框架层。

结论：

- 游戏内部 UI 并不是 Android XML UI，而是 Unity UGUI/Prefab 体系。
- 类名前缀可以作为第一轮界面枚举依据。

## 步骤 5：查看 IL2CPP 分析目录

命令：

```powershell
Get-ChildItem -Path ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis -Force
```

观察：

- 已有分析 CSV：
  - `class-index.csv`
  - `gameplay-class-index.csv`
  - `key-class-members.csv`
  - `producer-runtime-methods.csv`

命令：

```powershell
Import-Csv ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis\class-index.csv | Select-Object -First 20 | Format-Table -AutoSize
```

观察：

- `class-index.csv` 的列包含：
  - `LineNumber`
  - `Kind`
  - `Name`
  - `TypeDefIndex`
  - `Declaration`
- 可用于把类名映射回 `dump.cs` 行号。

命令：

```powershell
Import-Csv ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis\gameplay-class-index.csv | Select-Object -First 5 | Format-List
```

观察：

- `gameplay-class-index.csv` 也是相似结构。
- 初次按 `Class`、`Base` 列筛选没有结果，因为列名并非预想格式。

结论：

- 后续主要直接对 `dump.cs` 使用 `rg` 提取类名，再用 CSV 辅助。

## 步骤 6：提取核心状态枚举

命令：

```powershell
rg -n "^public enum (GameState|GameStep|SceneType|LoadingType|Popup|UI|Tutorial|GameMode|Flow|Contents|Lobby)" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

观察：

- 关键枚举：
  - `GameStep`
  - `LoadingType`
  - `GameState`
  - `TutorialType`
  - `UIPopupManager.Order`

命令：

```powershell
Get-Content ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs -Encoding UTF8 | Select-Object -Skip 4038 -First 65
```

观察：

`GameStep`：

- `Loading = 0`
- `InGame = 1`
- `OutGame = 2`
- `Story = 3`

命令：

```powershell
Get-Content ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs -Encoding UTF8 | Select-Object -Skip 29472 -First 35
```

观察：

`GameState`：

- `None = 0`
- `Lobby = 1`
- `Playing = 2`
- `End = 3`

结论：

- UI 顶层按 `GameStep` 切换。
- 小玩法内部可能再用 `GameState` 描述 Lobby/Playing/End。

## 步骤 7：分析 UIManager

命令：

```powershell
Get-Content ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs -Encoding UTF8 | Select-Object -Skip 34645 -First 190
```

观察到 `UIManager` 字段：

- `SafeArea safeArea`
- `Camera uiBGCamera`
- `UIOutGame uiOutGame`
- `UILobby uiLobby`
- `UIInGame uiInGame`
- `UIGlobal uiGlobal`
- `UIPopupManager uiPopupManager`
- `UILoading uiLoading`
- `UISceneLoading uiSceneLoading`
- `UIUseItemBlock uiUseItemBlock`
- `UIInGameBG uiInGameBG`
- `Canvas uiCanvas`
- `Canvas uiBGCanvas`
- `GraphicRaycaster[] raycasters`
- `EventSystem eventSystem`
- `Animation uiShowHideAnim`
- `Animation uiMaidLobbyLoading`
- `Animation uiBlackFadeLoading`

观察到 `UIManager` 方法：

- `Initialize()`
- `LoadInit()`
- `SetUI(GameStep _gameStep)`
- `StartSceneMoveLoading(Action _finish)`
- `ShowUI(...)`
- `ShowTouchCover(...)`
- `PlayBuildAnimFade(...)`
- `Fade(...)`
- `PlayBlackFadeLoading(...)`
- `PlayMaidLobbyLoading(...)`

结论：

- `UIManager` 是 Unity 内 UI 总控。
- 根 UI 至少分为 `OutGame`、`Lobby`、`InGame`、`Global`、`Popup`、`Loading`、`SceneLoading`。

## 步骤 8：分析游戏流程管理器

命令：

```powershell
Get-Content ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs -Encoding UTF8 | Select-Object -Skip 8710 -First 210
```

观察：

- 该片段包含游戏内管理器字段与流程方法：
  - `OnGameStart(bool isLoading = True)`
  - `OnInGame()`
  - `SceneLoadingPrev()`
  - `SceneLoadingFinish(bool isInGame = True)`
  - `OnOutGame(bool isSceneLoading = False, bool changeBGM = True)`
  - `OnOutGameSetting()`
  - `SetInGameData()`

结论：

- 游戏大流程从 Loading 进入 InGame 或 OutGame。
- 场景切换前后分别由 `SceneLoadingPrev` / `SceneLoadingFinish` 处理。

## 步骤 9：提取管理器类

命令：

```powershell
rg -n "^public class .*Manager : MonoBehaviourSingleton|^public class .*Manager : Singleton|^public class .*Manager : MonoBehaviour" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs | Select-Object -First 160
```

观察：

关键游戏管理器包括：

- `GameManager`
- `GamePlayManager`
- `OutGameManager`
- `PlatformLoginManager`
- `ResourceManager`
- `TableDataManager`
- `UserDataManager`
- `UIManager`
- `UIPopupManager`
- `TutorialManager`
- `InGame_BlockManager`
- `InGame_MapManager`
- `InGame_RequestManager`
- `EventManager`
- `MaidChatManager`
- `MaidAIChatManager`
- `NoticeManager`
- `PackageManager`
- `ShopDataManager`
- `RewardManager`
- `SoundManager`
- `BGMManager`

结论：

- 启动流程不只是 UI 初始化，还涉及配置、表数据、用户存档、平台登录、资源加载。

## 步骤 10：提取主界面类

命令：

```powershell
$dump='..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs'
rg "^public class UI(InGame|OutGame|Lobby|Maid|Memory|Inventory|Request|Block|Fabricate|User|Village|Global|Loading|SceneLoading|Story|Cutscene|Npc|Costume|Photo|Echo|Use|Skill|Surprise|Cell|Balloons|Tap)[A-Za-z0-9_]*" $dump |
  ForEach-Object {
    if ($_ -match 'public class (UI[A-Za-z0-9_]+)') { $matches[1] }
  } |
  Sort-Object -Unique
```

观察：

- 提取出主界面、根 UI、功能页、常驻控件。
- 其中 `UIListItem_*` 被刻意排除，避免把列表项误判为独立界面。

结论：

- 主界面类用于整理 `主要 UI 根界面` 章节。

## 步骤 11：提取弹窗界面

命令：

```powershell
$dump='..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs'
rg "^public class UIPopup_[A-Za-z0-9_]+" $dump |
  ForEach-Object {
    if ($_ -match 'public class (UIPopup_[A-Za-z0-9_]+)') { $matches[1] }
  } |
  Sort-Object -Unique
```

观察：

- 提取出约 140 个 `UIPopup_*` 类型。
- 包含：
  - 通用系统弹窗
  - 账号/平台弹窗
  - 大厅/角色弹窗
  - 背包/道具/合成弹窗
  - 任务/奖励弹窗
  - 商店/礼包弹窗
  - 活动/赛季/小游戏弹窗
  - 卡牌/记忆/抽奖弹窗
  - 剧情/图鉴/相册弹窗
  - AI/聊天弹窗

结论：

- `UIPopup_*` 是最可靠的独立界面线索。
- 少数 `UIPopup_* : MonoBehaviour` 不是泛型 `UIPopup<T>`，但从命名和位置看仍属于 UI 功能页或子弹窗。

## 步骤 12：提取教程界面

命令：

```powershell
$dump='..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs'
rg "^public class UITutorial_[A-Za-z0-9_]+" $dump |
  ForEach-Object {
    if ($_ -match 'public class (UITutorial_[A-Za-z0-9_]+)') { $matches[1] }
  } |
  Sort-Object -Unique
```

观察：

- 提取出 50 多个 `UITutorial_*` 类型。
- 覆盖合成、生产、背包、商店、宿舍、女仆、聊天、AI、活动、剧情回放等功能。

结论：

- 游戏新手引导系统比较完整，教程类可按功能直接映射到玩法模块。

## 步骤 13：查看 Android SDK Activity

命令：

```powershell
Select-String -Path resources\AndroidManifest.xml -Pattern '<activity|android:name=' |
  Select-Object -First 120 |
  ForEach-Object { $_.Line.Trim() }
```

观察：

- Manifest 中有大量第三方 SDK Activity：
  - Facebook 登录/CustomTab
  - QuickGame 登录、用户中心、支付、公告、Web
  - Google Billing
  - ByteDance/Pangle 广告
  - Mintegral 广告
  - IronSource / Google Ads 等广告组件
  - Vuplex WebView

结论：

- 这些是 Android 外壳界面，会覆盖 Unity 画面，但不属于 Unity 内部 UI 树。
- 文档中单独放到 `Android SDK 界面` 章节。

## 步骤 14：查看资源索引

命令：

```powershell
Get-ChildItem -Path ..\merge\reverse-output\assets -Force | Select-Object Name,Mode,Length,LastWriteTime
```

观察：

- 资源导出目录包括：
  - `assetripper-main`
  - `assetripper-primary`
  - `assetstudio-cli-data-json`
  - `assetstudio-cli-data-sprite`
  - `assetstudio-cli-data-textasset`
  - `assetstudio-cli-data-texture2d`
  - `assetstudio-cli-inventory.csv`

命令：

```powershell
Import-Csv ..\merge\reverse-output\assets\assetstudio-cli-inventory.csv | Select-Object -First 10 | Format-List
```

观察：

- CSV 列包含：
  - `Type`
  - `Name`
  - `Extension`
  - `Bytes`
  - `RelativePath`

命令：

```powershell
Import-Csv ..\merge\reverse-output\assets\assetstudio-cli-inventory.csv |
  Where-Object { $_.Type -match 'Scene|MonoBehaviour|GameObject|Prefab|TextAsset' -or $_.Name -match 'UI|Popup|Lobby|Loading|InGame|OutGame|Scene' } |
  Select-Object Type,Name,RelativePath |
  Sort-Object Type,Name |
  Select-Object -First 200 |
  Format-Table -AutoSize
```

观察：

- 命中大量 UI、Popup、Lobby、Loading、InGame 相关素材。
- 资源线索包括：
  - `Image_Loading`
  - `Loading_maid_2`
  - `InLobby`
  - `OutLobby`
  - `BG_Ingame_*`
  - `Popup_Window*`
  - `2025SummerPopup_*`
  - `2025XmasPopup_*`
  - `Tutorial_Suitcase_01`

结论：

- 资源命名支持 UI 分类结论。
- 当前没有继续反查每个 UI prefab 的资源地址。

## 步骤 15：写入分析文档

创建最终分析文档使用了 `apply_patch`：

```text
*** Begin Patch
*** Add File: docs/game-ui-startup-analysis.md
...
*** End Patch
```

验证命令：

```powershell
Get-ChildItem docs -Force
Get-Content docs\game-ui-startup-analysis.md -Encoding UTF8 -TotalCount 30
```

观察：

- 文件已创建：
  - `docs/game-ui-startup-analysis.md`
- PowerShell 控制台显示中文为乱码，这是控制台编码显示问题；文件内容按补丁写入为中文 Markdown。

## 关键推断依据

- `AndroidManifest.xml` 证明启动入口是 Unity Activity。
- `GameStep` 明确 UI 顶层状态：`Loading / InGame / OutGame / Story`。
- `UIManager` 字段明确 UI 根节点：`uiOutGame / uiLobby / uiInGame / uiGlobal / uiPopupManager / uiLoading / uiSceneLoading`。
- `UIManager.SetUI(GameStep)` 表明 UI 按 `GameStep` 切换。
- `PlatformLoginManager` 表明启动阶段涉及平台登录检查。
- `UILoading`、`UISceneLoading`、`SceneLoadingPrev()`、`SceneLoadingFinish()` 表明存在启动加载和场景切换加载。
- `UIPopup_*` 类名是独立弹窗/页面的主要枚举来源。
- `UITutorial_*` 类名是教程界面的主要枚举来源。
- AssetStudio 资源名中的 `Popup`、`Loading`、`Lobby`、`InGame` 与代码分类互相印证。

## 局限

- IL2CPP dump 中方法体为空，不能直接看到真实调用细节。
- 当前文档未做 native 地址级反汇编，所以启动顺序是结构化推断，不是完整调用栈。
- 当前未解析所有 AssetBundle / YooAsset 清单，未建立 `UIPopup_*` 到具体 prefab 文件的完整映射。
- 第三方 SDK Activity 只按 Manifest 归类，没有逐个阅读 SDK 源码。
- `UIListItem_*`、`UITab_*`、`UIEventQuest_*` 等被视为组件或按钮，没有全部列入“独立界面”。

## 后续建议

- 从 `script.json` 或 AssetRipper 输出中反查 MonoBehaviour 组件和 prefab 绑定关系。
- 对 `UIManager.Initialize`、`GameManager.OnGameStart`、`GamePlayManager.Initialize` 等 RVA 做反汇编，恢复真实调用链。
- 解析 YooAsset 清单，建立资源路径、bundle、prefab、脚本类之间的映射。
- 结合运行截图，把类名映射成玩家可见的中文界面名称。
