# shaonv 本目录分析过程记录

分析时间：2026-05-22  
工作目录：`D:\work\openclaw-workspace\arpg\shaonv`  
目标：重新分析本目录反编译后的游戏源码，整理界面、启动顺序，并记录命令和工具。

## 约束

本次分析只使用：

```text
D:\work\openclaw-workspace\arpg\shaonv
```

不使用相邻目录旧产物作为事实来源。此前文档中引用相邻目录的结果，只能作为“旧分析/参考”，不能作为本目录结论。

## 控制台编码

读取文件和输出中文时统一设置 UTF-8：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

读取文本文件时显式加：

```powershell
Get-Content -Encoding UTF8 <path>
Select-String -Encoding UTF8 -Path <path> -Pattern <pattern>
```

## 目录探查

使用命令：

```powershell
Get-ChildItem -Force
Get-ChildItem resources -Force
Get-ChildItem resources\assets\bin\Data -Force | Select-Object -First 50
Get-ChildItem resources\assets\yoo\Default -File | Measure-Object
Get-ChildItem resources\assets\yoo\Default -File | Sort-Object Length -Descending | Select-Object -First 20 Name,Length
```

确认关键输入：

| 路径 | 结论 |
| --- | --- |
| `resources\AndroidManifest.xml` | Android 入口和 SDK Activity 存在 |
| `resources\lib\arm64-v8a\libil2cpp.so` | 可用于 IL2CPP dump |
| `resources\assets\bin\Data\Managed\Metadata\global-metadata.dat` | 可用于 IL2CPP dump |
| `resources\assets\bin\Data\level0` | Unity 首场景 |
| `resources\assets\asd\YooAsset` | YooAsset 相关二进制 |
| `resources\assets\yoo\Default` | 327 个 YooAsset 包体 |

## Il2CppDumper

工具：

```text
D:\work\openclaw-workspace\arpg\tools\Il2CppDumper-net6-win-v6.7.46\Il2CppDumper.exe
```

执行命令：

```powershell
..\tools\Il2CppDumper-net6-win-v6.7.46\Il2CppDumper.exe `
  resources\lib\arm64-v8a\libil2cpp.so `
  resources\assets\bin\Data\Managed\Metadata\global-metadata.dat `
  reverse-output\il2cpp\il2cppdumper
```

输出摘要：

```text
Metadata Version: 31
WARNING: find JNI_OnLoad
ERROR: This file may be protected.
Il2Cpp Version: 31
CodeRegistration : 4c3b588
MetadataRegistration : 4e0dc18
Dumping Done
Generate struct Done
Generate dummy dll Done
```

说明：进程最后因为交互式 `Console.ReadKey` 在当前环境退出码为 1，但产物已生成。

生成产物：

| 路径 | 说明 |
| --- | --- |
| `reverse-output\il2cpp\il2cppdumper\dump.cs` | C# 类型 dump |
| `reverse-output\il2cpp\il2cppdumper\il2cpp.h` | 结构头文件 |
| `reverse-output\il2cpp\il2cppdumper\script.json` | 地址/脚本映射 |
| `reverse-output\il2cpp\il2cppdumper\stringliteral.json` | 字符串字面量 |
| `reverse-output\il2cpp\il2cppdumper\DummyDll` | Dummy DLL |

## AndroidManifest 分析

使用命令：

```powershell
Select-String -Path resources\AndroidManifest.xml `
  -Pattern 'package=|versionName|android:name=|MAIN|LAUNCHER|screenOrientation|UnityActivity' `
  -Encoding UTF8 |
  Select-Object -First 120 |
  ForEach-Object { "{0}:{1}" -f $_.LineNumber,$_.Line.Trim() }
```

确认结果：

| 行为 | 结论 |
| --- | --- |
| package/version | `com.and.gt.snhl`，`1.18` |
| 主 Activity | `com.daiei.monv.UnityPlayerActivity` |
| 启动 Intent | `MAIN` + `LAUNCHER`/`LEANBACK_LAUNCHER` |
| 横屏 | `userLandscape` |
| Unity 标记 | `unityplayer.UnityActivity=true` |
| SDK Activity | QuickGame、Facebook、UniWebView、Vuplex、SecMTP 等 |

## dump.cs 程序集和 UI 搜索

查看 Image 列表：

```powershell
Get-Content -Encoding UTF8 reverse-output\il2cpp\il2cppdumper\dump.cs -TotalCount 140
```

关键发现：

| 存在 | 不存在 |
| --- | --- |
| `Assembly-CSharp-firstpass.dll` | `Assembly-CSharp.dll` 类型表 |
| `AOTEnter.dll` | 主业务 UI 类型 |
| `HybridCLR.Runtime.dll` | `UIManager`、`UIPopup_*`、`UILobby` 等 |
| `UniWebView-CSharp.dll` | `WorldMap.dll` 类型表 |
| `IngameDebugConsole.Runtime.dll` | 业务状态机类型 |

搜索业务 UI：

```powershell
rg -n "^public enum (GameStep|GameState|LoadingType|PopupType|TutorialType)|^public class (UIManager|UIPopupManager|UILoading|UISceneLoading|UILobby|UIOutGame|UIInGame|PlatformLoginManager|GameManager|GamePlayManager|ReloadManager)\b" reverse-output\il2cpp\il2cppdumper\dump.cs

rg -n "^public class UIPopup_[A-Za-z0-9_]+" reverse-output\il2cpp\il2cppdumper\dump.cs

rg -n "^public class UITutorial_[A-Za-z0-9_]+" reverse-output\il2cpp\il2cppdumper\dump.cs
```

结果：无业务 UI 命中。

宽泛搜索界面类：

```powershell
rg -n "^public class .*UI|^public class .*View|^public class .*Panel|^public class .*Window|^public class .*Popup|^public class .*Dialog|^public enum .*UI|^public enum .*Popup" reverse-output\il2cpp\il2cppdumper\dump.cs | Select-Object -First 300
```

有效游戏启动界面命中：

| 类 | 说明 |
| --- | --- |
| `AOT.StartView` | 启动 splash |
| `AOT.UpdateView` | 更新/修复/热更加载界面 |

其他命中多为 Unity UI、UniWebView、IngameDebugConsole、TextMeshPro 等框架类型。

## AOT 启动流程定位

搜索命令：

```powershell
rg -n "class Update|UpdateView|GameConfig|AOTConfig|GlobalConfig|LoadHotFixDlls|HotFixAssemblyList|LoadPatchedAOT|LoadMetadataForAOTAssembly|CreateResourceDownloader|YooAsset" reverse-output\il2cpp\il2cppdumper\dump.cs

rg -n "public class (UpdateView|AOTConfig|GlobalConfig|GameConfig|HotFixLoader|HotFixDllFileUtil|HotFixDllPathUtil)|public interface IUpdateViewHandler" reverse-output\il2cpp\il2cppdumper\dump.cs
```

读取关键片段：

```powershell
Get-Content -Encoding UTF8 reverse-output\il2cpp\il2cppdumper\dump.cs | Select-Object -Skip 769140 -First 130
Get-Content -Encoding UTF8 reverse-output\il2cpp\il2cppdumper\dump.cs | Select-Object -Skip 769380 -First 150
Get-Content -Encoding UTF8 reverse-output\il2cpp\il2cppdumper\dump.cs | Select-Object -Skip 769900 -First 90
Get-Content -Encoding UTF8 reverse-output\il2cpp\il2cppdumper\dump.cs | Select-Object -Skip 770560 -First 70
Get-Content -Encoding UTF8 reverse-output\il2cpp\il2cppdumper\dump.cs | Select-Object -Skip 770760 -First 130
```

确认类：

| 类/接口 | 作用 |
| --- | --- |
| `AOTConfig` | 资源系统 DLL、业务 DLL 顺序、PatchAOT、启动场景配置 |
| `GlobalConfig` | 全局版本/启动配置 |
| `GameConfig` | 服务器 URL、国家、多语言配置 |
| `HotFixDllFileUtil` | `HotFixDll`、`PatchAOT` 路径规则 |
| `HotFixDllPathUtil` | 版本文件、zip、下载/保存路径 |
| `HotFixLoader` | 加载热更 DLL |
| `IUpdateViewHandler` | 资源系统初始化、检查版本、更新文件、打开根场景 |
| `StartView` | splash |
| `UpdateView` | 启动更新 UI |

## 字符串字面量分析

命令：

```powershell
Select-String -Path reverse-output\il2cpp\il2cppdumper\stringliteral.json `
  -Pattern 'Assembly-CSharp|WorldMap|HotFixDll|PatchAOT|UIPopup|UIManager|UILobby|UITutorial|GameStep|Loading|Login|Lobby' `
  -Encoding UTF8 |
  Select-Object -First 200 |
  ForEach-Object { $_.Line.Trim() }
```

关键命中：

| 字符串 | 解释 |
| --- | --- |
| `Assembly-CSharp.dll` | 热更业务 DLL 候选 |
| `WorldMap.dll` | 热更业务/地图 DLL 候选 |
| `HotFixDll` | 热更 DLL 目录 |
| `PatchAOT` | 补充元数据目录 |
| `LoginRequest Error` | SDK/登录相关字符串 |
| `NetworkLobbyManager` | 框架/网络大厅相关字符串 |

未命中主游戏 UI 名称，进一步支持“业务类型在热更 DLL 中”。

## 二进制资源搜索

命令：

```powershell
rg -a -n "Assembly-CSharp|WorldMap|HotFix|PatchAOT|rawAssembly|___AssemblyString___|UIPopup|UIManager|UILobby|UITutorial|Loading|Lobby|Tutorial|Login" resources\assets\yoo\Default resources\assets\asd\YooAsset resources\assets\bin\Data
```

结果：`resources\assets\asd\YooAsset` 中包含大量 YooAsset、下载、文件系统、加密服务、`LoadPatchedAOT`、`AOTConfig`、`GameConfig`、`GlobalConfig` 等字符串；`Default` 包体中未直接获得可读业务 UI 名称。

## AssetStudio 尝试

工具：

```text
D:\work\openclaw-workspace\arpg\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe
```

查看帮助：

```powershell
..\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe --help
```

导出/建图尝试：

```powershell
New-Item -ItemType Directory -Force reverse-output\assets\assetstudio-json | Out-Null

..\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe `
  resources\assets\yoo\Default `
  reverse-output\assets\assetstudio-json `
  --game Normal `
  --export_type JSON `
  --types TextAsset,GameObject,MonoBehaviour `
  --map_op Both `
  --map_type JSON `
  --dummy_dlls reverse-output\il2cpp\il2cppdumper\DummyDll
```

输出摘要：

```text
Found 327 files
Removed Default.version, no assets found
Removed BuildinCatalog.bytes, no assets found
Removed Default_1001.1774870195.cht.bytes, no assets found
...
Map build successfully !! 0 collisions found
Finished buidling AssetMap with 0 assets.
```

产物：

| 文件 | 结果 |
| --- | --- |
| `reverse-output\assets\assetstudio-json\assets_map.json` | 长度为 2，空映射 |

结论：当前 YooAsset 包不能用普通 AssetStudio 参数直接解出资源。下一步需要先解析 YooAsset manifest/catalog 和解密/文件系统逻辑。

## 生成文档

本次新增：

| 文档 | 内容 |
| --- | --- |
| `docs\shaonv-ui-startup-analysis.md` | 本目录界面与启动顺序分析 |
| `docs\shaonv-analysis-process.md` | 本目录分析过程、命令、工具、产物 |

## 后续任务建议

1. 解析 `resources\assets\yoo\Default\Default_1001.1774870195.cht.bytes` 和 `BuildinCatalog.bytes`。
2. 从 `AOTConfig` 实际资源配置中取出 `assetSystemDll`、`updateHandlerTypeName`、`loadGameDlls`、`pathAOTDlls`、`gameStartScene`。
3. 还原 YooAsset 解密/读取服务，至少能把 `HotFixDll` 和 `PatchAOT` 目录中的 DLL 解出来。
4. 反编译解出的 `Assembly-CSharp.dll`、`WorldMap.dll` 后，再重新生成完整 UI 清单。
5. 再次运行类名搜索：`UIManager`、`UIPopup_*`、`UITutorial_*`、`UILobby`、`GameStep`、`GameManager`。
6. 结合 prefab/scene 依赖重新整理“所有界面”和“启动到大厅/战斗”的准确流程。

## 继续分析：YooAsset manifest 与资源索引

追加分析发现 `resources\assets\yoo\Default\BuildinCatalog.json` 是明文 wrapper 列表，`Default_1001.1774870195.cht.bytes` 是 YooAsset manifest。先提取 manifest 字符串：

```powershell
$node='C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
New-Item -ItemType Directory -Force reverse-output\assets\manifest | Out-Null
& $node reverse-output\scripts\extract-ascii-strings.js `
  resources\assets\yoo\Default\Default_1001.1774870195.cht.bytes `
  reverse-output\assets\manifest\Default_1001.1774870195.cht.strings.txt `
  4
```

再生成资源分类 CSV：

```powershell
& $node reverse-output\scripts\analyze-manifest-strings.js `
  reverse-output\assets\manifest\Default_1001.1774870195.cht.strings.txt `
  reverse-output\assets\manifest
```

输出摘要：

```text
assets=18195
ui_candidates=4088
scenes=36
dll_or_bytes=1146
```

新增产物：

| 文件 | 内容 |
| --- | --- |
| `reverse-output\assets\manifest\manifest-assets.csv` | manifest 中 18,195 条资源路径 |
| `reverse-output\assets\manifest\manifest-ui-prefabs.csv` | 1,125 个 `Prefabs/UI/**/*.prefab` |
| `reverse-output\assets\manifest\manifest-ui-prefab-category-stats.csv` | UI prefab 目录统计 |
| `reverse-output\assets\manifest\manifest-scenes.csv` | 36 个场景 |
| `reverse-output\assets\manifest\manifest-dll-bytes.csv` | 脚本 bytes 和 patch bytes |
| `docs\shaonv-yooasset-manifest-analysis.md` | YooAsset 与 manifest 专项分析 |

### Bundle XOR 验证

原始 bundle 头部：

```text
43 78 7F 62 6F 50 45
```

XOR `0x16` 后：

```text
55 6E 69 74 79 46 53
UnityFS
```

批量解密命令：

```powershell
& $node reverse-output\scripts\decrypt-yoo-xor16.js `
  resources\assets\yoo\Default\BuildinCatalog.json `
  resources\assets\yoo\Default `
  reverse-output\assets\yoo-default-xor16-decoded `
  16
```

输出：

```text
done decoded=322 skipped=0 output=...\reverse-output\assets\yoo-default-xor16-decoded key=0x16
```

但是 AssetStudio 对整包 XOR 后的文件仍在 LZ4 解块阶段失败：

```text
Error while reading bundle file
System.ArgumentOutOfRangeException
AssetStudio.LZ4.Decompress
```

前缀 XOR 16、32、64、128、256、512、1024、2048、4096、8192、16384、32768、65536 字节也均失败。

后续从 `resources\assets\asd\YooAsset` 还原运行时逻辑后，修正结论：真实加密不是整包 XOR，也不是 2 的幂长度前缀 XOR，而是只对文件前 222 字节 XOR `0x16`。

### 热更脚本包定位

manifest 中确认：

```text
Assets/Game/RawAssets/ScriptBytes/Assembly-CSharp.bytes
Assets/Game/RawAssets/ScriptBytes/WorldMap.bytes
Assets/Game/RawAssets/ScriptBytes/patch/*.bytes
```

字符串邻近关系确认：

| 逻辑 bundle | 对应文件 |
| --- | --- |
| `assets_game_rawassets_scriptbytes.bundle` | `82d640fc6bf946d4bac8d265200fa793.bundle` |
| `assets_game_rawassets_scriptbytes_patch.bundle` | `ec57b38f548d8b2c2f6222ee738c4983.bundle` |

这两个 bundle 是导出热更业务代码和 PatchAOT 补充元数据的优先目标。

## 继续分析：YooAsset 解密与热更程序集导出

发现 `resources\assets\asd\YooAsset` 是标准 .NET DLL，复制为：

```text
reverse-output\managed\YooAsset.dll
```

使用 Mono.Cecil 转储 `YooAsset.FileStreamEncryption`：

```powershell
powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\YooAsset.dll `
  -CecilPath D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll `
  -Patterns '*FileStreamEncryption*'
```

确认逻辑：

```text
prefixLength = Math.Min(222, fileLength)
bytes[i] ^= 0x16
```

按 222 字节前缀解密热更脚本包：

```powershell
$node = "C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"

& $node reverse-output\scripts\decrypt-yoo-xor16-prefix.js `
  resources\assets\yoo\Default\82d640fc6bf946d4bac8d265200fa793.bundle `
  reverse-output\assets\yoo-default-xor16-prefix222\scriptbytes\82d640fc6bf946d4bac8d265200fa793.bundle `
  222 16
```

使用 AssetStudio 导出 `TextAsset: Assembly-CSharp` 后，再剥离 TextAsset 头：

```powershell
D:\work\openclaw-workspace\arpg\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe `
  reverse-output\assets\yoo-default-xor16-prefix222\scriptbytes `
  reverse-output\assets\assetstudio-assembly-Raw `
  --game Normal --types TextAsset --names '^Assembly-CSharp$' --export_type Raw --silent

& $node reverse-output\scripts\extract-textasset-dll.js `
  reverse-output\assets\assetstudio-assembly-Raw\TextAsset `
  reverse-output\managed\hotfix-dlls
```

已导出：

```text
reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll
reverse-output\managed\hotfix-dlls\WorldMap.dll
```

`Assembly-CSharp.dll`：

```text
size=7357440
sha256=E8551F8BC2B1E867B774A68DCEECAD5E777B4C68138901945C262365CF9ED097
```

已生成热更业务索引：

```text
reverse-output\managed\Assembly-CSharp-index\types.csv
reverse-output\managed\Assembly-CSharp-index\methods.csv
reverse-output\managed\Assembly-CSharp-index\ui-types.csv
reverse-output\managed\Assembly-CSharp-index\ui-methods.csv
reverse-output\managed\Assembly-CSharp-index\view-panel-types.csv
reverse-output\managed\Assembly-CSharp-index\core-ui-types.csv
```

统计：

```text
types=8928
methods=37802
uiTypes=1407
```

专项文档：

```text
docs\shaonv-yooasset-decryption-hotfix-export.md
```

## 继续分析：手机 files/Unpack 缓存

用户提供了从手机 `/data/data/com.and.gt.snhl/files/` 拷贝出的：

```text
D:\work\openclaw-workspace\arpg\shaonv\Unpack
```

分析脚本：

```powershell
$node='C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
& $node reverse-output\scripts\analyze-unpack-cache.js `
  Unpack\UnpackBundleFiles `
  resources\assets\yoo\Default `
  reverse-output\assets\unpack-analysis
```

输出：

```text
unpackData=225
sourceBundles=322
missingInUnpack=97
sameAsSource=225
```

结论：

1. `Unpack\UnpackBundleFiles` 里的 `__data` 与 APK 内同 hash bundle 完全一致，不是解密后的资源。
2. `Unpack` 只缓存了 225 个 bundle，APK 内共有 322 个 bundle，缺 97 个。
3. 热更脚本包缺失：
   - `82d640fc6bf946d4bac8d265200fa793.bundle`
   - `ec57b38f548d8b2c2f6222ee738c4983.bundle`
4. 这份 `Unpack` 不能直接导出 `Assembly-CSharp.bytes` 或 `WorldMap.bytes`。

新增文档：

```text
docs\shaonv-unpack-runtime-cache-analysis.md
```

## 继续分析：热更业务 UI 调用链和生命周期

目标：反编译热更业务 UI 代码，重点还原：

```text
ViewBehaviour
UIControl
UIRoot2d
LoginView
LoadingView
PreloadingView
MainUIView
```

补充分析类：

```text
GameHelper
LaunchView
SilentUpdateView
AssetsService
YooAssetsService
LoginModel
```

### 生成目标类调用图

命令：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding=[System.Text.Encoding]::UTF8
chcp 65001 > $null

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\analyze-managed-callgraph.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Types 'ViewBehaviour,UIControl,UIRoot2d,LoginView,LoadingView,PreloadingView,MainUIView' `
  -OutputDir reverse-output\managed\Assembly-CSharp-ui-callgraph
```

输出：

```text
types=7
fields=123
methods=137
calls=1026
strings=85
fieldRefs=571
```

产物：

```text
reverse-output\managed\Assembly-CSharp-ui-callgraph\target-types.csv
reverse-output\managed\Assembly-CSharp-ui-callgraph\target-fields.csv
reverse-output\managed\Assembly-CSharp-ui-callgraph\target-methods.csv
reverse-output\managed\Assembly-CSharp-ui-callgraph\target-calls.csv
reverse-output\managed\Assembly-CSharp-ui-callgraph\target-strings.csv
reverse-output\managed\Assembly-CSharp-ui-callgraph\target-fieldrefs.csv
```

### 导出目标类 IL

单类导出，避免一次性输出过大：

```powershell
powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*UIControl' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\UIControl.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*ViewBehaviour' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\ViewBehaviour.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*UIRoot2d' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\UIRoot2d.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*LoginView' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\LoginView.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*LoadingView' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\LoadingView.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*PreloadingView' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\PreloadingView.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*MainUIView' |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\MainUIView.il.txt
```

生成文件大小：

```text
UIControl.il.txt       23386
ViewBehaviour.il.txt   40195
UIRoot2d.il.txt        14435
LoginView.il.txt       37881
LoadingView.il.txt      5804
PreloadingView.il.txt   1921
MainUIView.il.txt     112962
```

### 提取关键方法调用表

命令：

```powershell
$calls=Import-Csv reverse-output\managed\Assembly-CSharp-ui-callgraph\target-calls.csv
$keys='Open','Close','Destroy','Awake','OnOpen','Start','OnDestroy','InitView','InitSubscribe','OnEnable','OnDisable','Create','SetProcess','UpdateProcess'
$calls |
  Where-Object { $keys -contains $_.Caller -or $_.Caller -like '<Awake>*' -or $_.Caller -like '<Init*' } |
  Select-Object CallerType,Caller,CalleeType,Callee,CalleeFullName |
  Sort-Object CallerType,Caller |
  ConvertTo-Csv -NoTypeInformation |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\key-method-calls.csv
```

产物：

```text
reverse-output\managed\Assembly-CSharp-ui-callgraph\key-method-calls.csv
```

### 补充启动链相关类

`GameHelper.LoadMainScene` 分析：

```powershell
powershell -ExecutionPolicy Bypass -File reverse-output\scripts\analyze-managed-callgraph.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Types 'GameHelper,AssetsService,YooAssetsService,LoginModel' `
  -OutputDir reverse-output\managed\Assembly-CSharp-startup-callgraph
```

输出：

```text
types=4
fields=25
methods=76
calls=319
strings=67
fieldRefs=212
```

`dump-managed-il.ps1` 原先只遍历顶层类型，不能导出 `GameHelper/<LoadMainScene>d__24` 这类嵌套 async 状态机。本轮已修改为递归遍历 `NestedTypes`。

修改点：

```powershell
function Get-AllTypes {
    param([Mono.Cecil.TypeDefinition]$Type)
    $Type
    foreach ($nested in $Type.NestedTypes) {
        Get-AllTypes $nested
    }
}
```

导出 `GameHelper.LoadMainScene` 状态机：

```powershell
$out = powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns 'GameHelper/<LoadMainScene>d__24'

$out | Set-Content -Encoding UTF8 `
  reverse-output\managed\Assembly-CSharp-ui-callgraph\GameHelper.LoadMainScene.il.txt
```

确认 `GameHelper/<LoadMainScene>d__24.MoveNext()`：

```text
SceneLoadManager.GetInstance()
Ldstr "MainScene"
SceneLoadManagerExtension.LoadAsyncScene(..., "MainScene", progressCallback, completedCallback, null, LoadSceneMode.Single)
```

补充导出：

```powershell
powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*LaunchView' 2>$null |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\LaunchView.il.txt

powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
  -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
  -Patterns '*SilentUpdateView' 2>$null |
  Set-Content -Encoding UTF8 reverse-output\managed\Assembly-CSharp-ui-callgraph\SilentUpdateView.il.txt
```

`LaunchView` 确认：

```text
Awake()
  -> FileUtils.FullPathForFilename("launch.mp4")
  -> videoPlayer.prepareCompleted += Play()
  -> videoPlayer.loopPointReached += m_finish.Invoke(); Destroy()
```

`SilentUpdateView` 确认：

```text
OnOpen()
  -> SilentUpdateMgr.Instance.OnProgress = OnProgress

OnClose()
  -> SilentUpdateMgr.Instance.OnProgress = null
```

### 本轮文档

新增：

```text
docs\shaonv-hotfix-ui-lifecycle-analysis.md
```

核心结论：

```text
UIRoot2d.Awake 建立 2D UI 根和层级单例。
UIControl 管理事件、RPC、Timer、DOTween 和销毁清理。
ViewBehaviour 是所有业务 View 的 Open/Close/Destroy/遮罩/栈顶框架。
LoginView 负责隐私协议、服务器列表、SDK/编辑器登录、公告与连接 RPCSession。
LoadingView 负责登录后的进度条，并在进度完成后调用 GameHelper.LoadMainScene。
GameHelper.LoadMainScene 通过 SceneLoadManagerExtension.LoadAsyncScene 加载 "MainScene"。
MainUIView 在 MainScene 进入后初始化玩家信息、玩法入口、底部栏、商业化入口、章节任务、红点和壁纸面板。
```
