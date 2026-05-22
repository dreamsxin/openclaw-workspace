# shaonv YooAsset 解密与热更程序集导出

## 结论

已还原当前 APK 内 YooAsset bundle 的自定义加密逻辑，并成功导出热更程序集：

```text
reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll
reverse-output\managed\hotfix-dlls\WorldMap.dll
```

关键结论：

1. `resources\assets\asd\YooAsset` 本身是标准 .NET DLL，只是没有 `.dll` 扩展。
2. `YooAsset.FileStreamEncryption.Encrypt()` 的真实逻辑不是整包 XOR，也不是块级 XOR，而是只对文件前 222 字节逐字节 XOR `0x16`。
3. 对 `*.bundle` 前 222 字节 XOR `0x16` 后，AssetStudio 可以识别 UnityFS 并导出 TextAsset。
4. `Assembly-CSharp.bytes` 和 `WorldMap.bytes` 是 Unity `TextAsset`，导出为 `.dat` 后需要再剥离 TextAsset 头部，得到真正的 PE/DLL。

## 解密逻辑

从 `resources\assets\asd\YooAsset` 复制得到：

```text
reverse-output\managed\YooAsset.dll
```

用 Mono.Cecil 转储 `YooAsset.FileStreamEncryption` 后确认核心 IL：

```text
Math.Min(222, fileLength)
for i in range(prefixLength):
    bytes[i] ^= 0x16
```

对应转储文件：

```text
reverse-output\managed\il\YooAsset.decrypt-path.il.txt
```

## 解密并导出热更包

脚本：

```text
reverse-output\scripts\decrypt-yoo-xor16-prefix.js
reverse-output\scripts\extract-textasset-dll.js
```

执行过的核心命令：

```powershell
$node = "C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"

& $node reverse-output\scripts\decrypt-yoo-xor16-prefix.js `
  resources\assets\yoo\Default\82d640fc6bf946d4bac8d265200fa793.bundle `
  reverse-output\assets\yoo-default-xor16-prefix222\scriptbytes\82d640fc6bf946d4bac8d265200fa793.bundle `
  222 16

& $node reverse-output\scripts\decrypt-yoo-xor16-prefix.js `
  resources\assets\yoo\Default\ec57b38f548d8b2c2f6222ee738c4983.bundle `
  reverse-output\assets\yoo-default-xor16-prefix222\scriptbytes\ec57b38f548d8b2c2f6222ee738c4983.bundle `
  222 16

D:\work\openclaw-workspace\arpg\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe `
  reverse-output\assets\yoo-default-xor16-prefix222\scriptbytes `
  reverse-output\assets\assetstudio-assembly-Raw `
  --game Normal --types TextAsset --names '^Assembly-CSharp$' --export_type Raw --silent

& $node reverse-output\scripts\extract-textasset-dll.js `
  reverse-output\assets\assetstudio-assembly-Raw\TextAsset `
  reverse-output\managed\hotfix-dlls
```

导出结果：

| 文件 | 大小 | 说明 |
| --- | ---: | --- |
| `reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll` | 7,357,440 | 主业务热更程序集 |
| `reverse-output\managed\hotfix-dlls\WorldMap.dll` | 236,032 | 世界地图相关热更程序集 |

`Assembly-CSharp.dll` SHA256：

```text
E8551F8BC2B1E867B774A68DCEECAD5E777B4C68138901945C262365CF9ED097
```

## 业务 UI 代码索引

已用 Mono.Cecil 索引 `Assembly-CSharp.dll`：

```text
reverse-output\managed\Assembly-CSharp-index\types.csv
reverse-output\managed\Assembly-CSharp-index\methods.csv
reverse-output\managed\Assembly-CSharp-index\ui-types.csv
reverse-output\managed\Assembly-CSharp-index\ui-methods.csv
reverse-output\managed\Assembly-CSharp-index\view-panel-types.csv
reverse-output\managed\Assembly-CSharp-index\core-ui-types.csv
reverse-output\managed\Assembly-CSharp-index\startup-ui-methods.csv
```

统计：

| 项 | 数量 |
| --- | ---: |
| 类型总数 | 8,928 |
| 方法总数 | 37,802 |
| UI 候选类型 | 1,407 |

核心 UI/启动候选类型已确认存在：

```text
LoginView : ViewBehaviour
LoadingView : ViewBehaviour
PreloadingView : ViewBehaviour
MainUIView : ViewBehaviour
NoviceGuidePanel : ViewBehaviour
Guide : UnityEngine.MonoBehaviour
GuideModel : System.Object
UIControl : UnityEngine.MonoBehaviour
UIRoot2d : UnityEngine.MonoBehaviour
ViewBehaviour
ActivityMainView : ViewBehaviour
HeroMainView : ViewBehaviour
LotteryDrawMainView : ViewBehaviour
AllianceMainView : ViewBehaviour
ArenaMainView : ViewBehaviour
WorldBossMainView : ViewBehaviour
```

界面类型基类分布前列：

| 基类 | 数量 |
| --- | ---: |
| `ViewBehaviour` | 385 |
| `Scx.GridCell` | 311 |
| `UnityEngine.MonoBehaviour` | 239 |
| `TabGridCell` | 107 |
| `UIControl` | 100 |
| `ActivityBasePanel` | 58 |

## 对后续界面/启动顺序分析的影响

之前只能从 AOT 壳推断启动顺序，现在可以直接进入热更业务代码分析：

1. 从 `LoginView`、`LoadingView`、`PreloadingView`、`MainUIView` 还原登录到主界面的 UI 流程。
2. 从 `ViewBehaviour`、`UIControl`、`UIRoot2d`、`Scx.UIHelper` 还原通用界面生命周期和打开/关闭规则。
3. 从 `view-panel-types.csv` 按 `ViewBehaviour`、`ActivityBasePanel`、`GridCell` 分类整理所有界面。
4. 从 `AssetsHelper` 的 `LoadSpriteFrom*`、`LoadSpineFrom*` 方法还原资源路径约定。
5. 对 `WorldMap.dll` 单独索引，补齐世界地图/场景切换逻辑。

## 下一步

需要继续完成：

1. 反编译 `ViewBehaviour`、`UIControl`、`UIRoot2d`、`LoginView`、`LoadingView`、`PreloadingView`、`MainUIView` 的方法体。
2. 建立 `View/Panel` 类型到 `Prefabs/UI/**/*.prefab` 的映射。
3. 从热更代码中找场景加载、资源加载和启动入口调用链。
4. 对 `WorldMap.dll` 生成同样的类型/方法索引。

## UnityPy 全资源导出测试

新增 Python 脚本：

```text
reverse-output\scripts\export-unitypy-all-assets.py
```

脚本能力：

1. 可直接读取原始加密 bundle，并在内存中执行 `--xor-prefix 222 --xor-key 0x16`。
2. 可导出 `Texture2D`、`Sprite` 为 PNG。
3. 可导出 `TextAsset` 为 `.dll`、`.bytes` 等原始数据。
4. 会生成导出清单 `unitypy-export-manifest.csv` 和错误日志 `unitypy-export-errors.log`。

安装依赖：

```powershell
C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe -m pip install UnityPy
```

热更脚本包导出测试：

```powershell
$py = "C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"

& $py reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\82d640fc6bf946d4bac8d265200fa793.bundle `
  reverse-output\assets\unitypy-scriptbytes-test `
  --types TextAsset `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --limit-objects 5
```

输出：

```text
files_seen=1
objects_seen=3
objects_matched=2
objects_exported=2
```

导出：

```text
reverse-output\assets\unitypy-scriptbytes-test\by_type\TextAsset\Assembly-CSharp.dll
reverse-output\assets\unitypy-scriptbytes-test\by_type\TextAsset\WorldMap.dll
```

图片资源包限量导出测试：

```powershell
& $py reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\c049a0e505dd5a9644368a97ebc81245.bundle `
  reverse-output\assets\unitypy-c049-image-test `
  --types Texture2D,Sprite,TextAsset `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --limit-objects 20
```

输出：

```text
files_seen=1
objects_seen=20
objects_matched=20
objects_exported=20
```

导出了若干 PNG，例如：

```text
reverse-output\assets\unitypy-c049-image-test\by_type\Texture2D\fx_052q_fz_z.png
reverse-output\assets\unitypy-c049-image-test\by_type\Sprite\fxpt_UI_xskh.png
```

这说明现在不仅可以导出热更 DLL，也可以直接基于原始 YooAsset bundle 批量导出图片/TextAsset 资源。
