# shaonv YooAsset 与 Manifest 继续分析

分析时间：2026-05-22  
范围：`D:\work\openclaw-workspace\arpg\shaonv`

## 新增结论

本轮突破点是 `resources\assets\yoo\Default\Default_1001.1774870195.cht.bytes`。它不是普通资源包，而是 YooAsset manifest，文件头为：

```text
OOY
YooAsset 2.3.1
PackageName: Default
PackageVersion: 1001.1774870195.cht
BuildPipeline: ScriptableBuildPipeline
BuildTime: 3/30/2026 7:33:10 PM
```

manifest 内部包含明文资源路径。通过字符串提取确认：

| 项 | 数量 |
| --- | ---: |
| `Assets/` 资源路径 | 18,195 |
| UI 相关候选资源 | 4,088 |
| `Prefabs/UI/**/*.prefab` 界面 prefab | 1,125 |
| 场景 `.unity` | 36 |
| `.bytes` / DLL 相关资源 | 1,146 |

## 包体加密状态

`resources\assets\yoo\Default\*.bundle` 不是明文 UnityFS。原始包头示例：

```text
43 78 7F 62 6F 50 45
```

逐字节 XOR `0x16` 后变为：

```text
55 6E 69 74 79 46 53
UnityFS
```

说明包体至少存在 XOR `0x16` 级别的加密/扰动。

已验证：

1. 整包 XOR `0x16` 后文件头恢复为 `UnityFS`。
2. 只 XOR 前缀 16 到 65,536 字节均不能让 AssetStudio 正常读取。
3. 整包 XOR 后 AssetStudio 能识别头，但在 LZ4 解块阶段失败。

当前判断：YooAsset 的 bundle 数据不是简单“整包 XOR 即可导出”。可能是块信息或块数据采用了自定义解密流程，需要继续还原运行时代码里的 `YooAsset.IDecryptionServices` / `LoadEncryptedAssetBundle`。

## 产物

| 文件 | 内容 |
| --- | --- |
| `reverse-output\assets\manifest\Default_1001.1774870195.cht.strings.txt` | 从 manifest 提取的 ASCII 字符串 |
| `reverse-output\assets\manifest\manifest-assets.csv` | 18,195 条资源路径分类 |
| `reverse-output\assets\manifest\manifest-ui-candidates.csv` | UI 候选资源 |
| `reverse-output\assets\manifest\manifest-ui-prefabs.csv` | 1,125 个 UI prefab |
| `reverse-output\assets\manifest\manifest-ui-prefab-category-stats.csv` | UI prefab 一级目录统计 |
| `reverse-output\assets\manifest\manifest-scenes.csv` | 36 个场景 |
| `reverse-output\assets\manifest\manifest-dll-bytes.csv` | 脚本 bytes / patch / spine bytes 等 |
| `reverse-output\assets\manifest\manifest-guide-assets.csv` | 新手引导相关资源 |
| `reverse-output\assets\yoo-default-xor16-decoded` | 322 个已整包 XOR 的 UnityFS 头恢复样本 |

## 脚本

| 脚本 | 作用 |
| --- | --- |
| `reverse-output\scripts\decrypt-yoo-xor16.js` | 按 `BuildinCatalog.json` 批量 XOR `0x16` 解密包体 |
| `reverse-output\scripts\decrypt-yoo-xor16-prefix.js` | 只 XOR 文件前缀，用于验证加密范围 |
| `reverse-output\scripts\extract-ascii-strings.js` | 从二进制 manifest 提取 ASCII 字符串 |
| `reverse-output\scripts\analyze-manifest-strings.js` | 按路径、扩展名和 UI 关键字生成 CSV |
| `reverse-output\scripts\parse-yoo-manifest.js` | 尝试解析 YooAsset manifest 二进制结构，当前字段顺序仍需对照源码修正 |

## 热更脚本资源定位

manifest 明确列出脚本资源：

```text
Assets/Game/RawAssets/ScriptBytes/Assembly-CSharp.bytes
Assets/Game/RawAssets/ScriptBytes/WorldMap.bytes
Assets/Game/RawAssets/ScriptBytes/patch/DOTween.bytes
Assets/Game/RawAssets/ScriptBytes/patch/LitJson.bytes
Assets/Game/RawAssets/ScriptBytes/patch/MemoryPack.bytes
Assets/Game/RawAssets/ScriptBytes/patch/mscorlib.bytes
Assets/Game/RawAssets/ScriptBytes/patch/System.bytes
Assets/Game/RawAssets/ScriptBytes/patch/System.Core.bytes
Assets/Game/RawAssets/ScriptBytes/patch/UniTask.bytes
Assets/Game/RawAssets/ScriptBytes/patch/UnityEngine.UI.bytes
Assets/Game/RawAssets/ScriptBytes/patch/UniWebView-CSharp.bytes
```

bundle 名称和 hash 线索：

| 逻辑 bundle | 文件 hash / bundle 文件 |
| --- | --- |
| `assets_game_rawassets_scriptbytes.bundle` | `82d640fc6bf946d4bac8d265200fa793.bundle` |
| `assets_game_rawassets_scriptbytes_patch.bundle` | `ec57b38f548d8b2c2f6222ee738c4983.bundle` |

这两个 bundle 是后续获取 `Assembly-CSharp.bytes`、`WorldMap.bytes`、PatchAOT bytes 的优先目标。

## 场景清单

manifest 中确认的场景：

```text
Assets/Scene/StreamedScenes/Root.unity
Assets/Scene/StreamedScenes/MainScene.unity
Assets/Scene/StreamedScenes/Choujiang.unity
Assets/Scene/StreamedScenes/BNS.unity
Assets/Scene/StreamedScenes/AFKMap/WorldMap01.unity
Assets/Scene/StreamedScenes/AFKMap/AFKMapScene01.unity ... AFKMapScene10.unity
Assets/Scene/StreamedScenes/BattleScene_01_GCSB.unity ... BattleScene_21_BYC.unity
```

启动链路上，`AOT.UpdateView -> IUpdateViewHandler.OpenRootScene()` 很可能进入 `Root.unity`，然后再进入 `MainScene.unity` 或业务场景；但实际入口仍要从热更代码或 `AOTConfig.gameStartScene` 实例值确认。

## UI prefab 目录统计

`Prefabs/UI/**/*.prefab` 共 1,125 个。一级目录统计前列：

| 目录 | 数量 |
| --- | ---: |
| Activity | 285 |
| Common | 64 |
| Hero | 64 |
| Roguelike | 59 |
| Gal | 59 |
| Arena | 39 |
| Alliance | 39 |
| Remnants | 35 |
| Chat | 27 |
| HolyRelic | 24 |
| Slug | 24 |
| UserInfo | 21 |
| LotteryDraw | 19 |
| AllianceGvG | 18 |
| Smelt | 18 |
| WorldBoss | 17 |
| Ruins | 16 |
| Expedition | 15 |
| Terminal | 15 |
| GameShop | 15 |
| DevilHunter | 14 |
| Battle | 11 |
| Pet | 11 |
| Stronger | 11 |
| Prayer | 10 |
| Login | 6 |
| Launch | 2 |
| Update | 1 |

完整列表见：

```text
reverse-output\assets\manifest\manifest-ui-prefabs.csv
reverse-output\assets\manifest\manifest-ui-prefab-category-stats.csv
```

## 引导界面资源

manifest 中确认的引导相关 prefab：

```text
Assets/Game/RawAssets/GuideAsset/GuideComponent/AudioComponent.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/ComicGifComponent.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/ComicTipsComponent.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/DialogueComicPanel.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/DialoguePanel.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/DialogueSpineComponent.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/DialogueVideoComponent.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/GraphComponent.prefab
Assets/Game/RawAssets/GuideAsset/GuideComponent/NoviceGuidePanel.prefab
```

同时存在：

```text
Assets/Game/RawAssets/GuideAsset/Graph/Guide1.asset
Assets/Game/RawAssets/GuideAsset/Graph/GuideConfig.asset
Assets/Game/RawAssets/GuideAsset/Graph/GuideGraph.asset
Assets/Game/RawAssets/GuideAsset/Graph/GuideTest.asset
```

## 对单机版实现的影响

这轮分析把“有哪些资源和 UI”从未知推进到可枚举：

1. 可以先用 `manifest-ui-prefabs.csv` 规划单机版 UI 模块优先级。
2. 可以按 `manifest-scenes.csv` 建立场景加载替代流程。
3. 热更程序集导出已经完成，可以直接分析 `Assembly-CSharp.dll` 和 `WorldMap.dll`。
4. 可以按 `manifest-assets.csv` 建立资源路径索引，即使暂时不能导出 prefab，也能先设计资源管理表。

后续最关键任务已经从“还原解密”切换为：

1. 反编译热更业务 UI 代码。
2. 建立 `View/Panel/Grid` 类型到 `Prefabs/UI/**/*.prefab` 的映射。
3. 从热更代码还原登录、加载、主界面、引导和场景切换顺序。

热更导出专项记录见：

```text
docs\shaonv-yooasset-decryption-hotfix-export.md
```
