# 分析目录纠偏说明

用户指出：单机版规划应基于 `D:\work\openclaw-workspace\arpg\shaonv`，而不是相邻的 `../merge/reverse-output`。

结论：这个指出是正确的。此前若干文档中的 `../merge/reverse-output/...` 是相邻目录里的已导出分析产物，可作为参考，但不能视为 `shaonv` 目录自身已经完成的分析结果。后续实现单机版时，应先从 `shaonv` 本目录重新导出 IL2CPP dump、资源清单和表数据。

## shaonv 目录当前实际内容

工作目录：

```text
D:\work\openclaw-workspace\arpg\shaonv
```

顶层目录：

- `resources/`
- `sources/`
- `docs/`

关键原始文件：

- `resources/AndroidManifest.xml`
- `resources/lib/arm64-v8a/libil2cpp.so`
- `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`
- `resources/assets/bin/Data/level0`
- `resources/assets/bin/Data/sharedassets0.assets`
- `resources/assets/asd/YooAsset`
- `resources/assets/yoo/Default/*.bundle`

确认命令：

```powershell
Get-ChildItem -Force
```

```powershell
rg --files resources | rg "(global-metadata|libil2cpp|\.bundle$|YooAsset|level0|sharedassets0\.assets)"
```

```powershell
Get-ChildItem -Path resources -Recurse -File -Filter libil2cpp.so | Select-Object FullName,Length
```

```powershell
Get-ChildItem -Path resources -Recurse -File -Filter global-metadata.dat | Select-Object FullName,Length
```

## 之前文档中需要重新校验的部分

以下文档中引用了相邻目录 `../merge/reverse-output`：

- `docs/game-ui-startup-analysis.md`
- `docs/game-ui-analysis-process.md`
- `docs/resource-mapping-analysis.md`
- `docs/table-data-analysis.md`
- `docs/core-gameplay-loop-analysis.md`
- `docs/single-player-port-task-plan.md`

这些引用目前应理解为：

- `../merge/reverse-output`：参考样本或外部已导出结果。
- `shaonv/resources/...`：本项目当前可确认的真实输入。

后续必须用 `shaonv/resources/lib/arm64-v8a/libil2cpp.so` 和 `shaonv/resources/assets/bin/Data/Managed/Metadata/global-metadata.dat` 重新跑 Il2CppDumper / Cpp2IL，生成属于 `shaonv` 的 dump。

## 修正后的单机版分析入口

后续任务应从这些输入开始：

### 1. Android 壳

```text
resources/AndroidManifest.xml
sources/
```

用途：

- 确认启动 Activity。
- 确认 SDK 登录、广告、支付、WebView 外壳。

### 2. IL2CPP

```text
resources/lib/arm64-v8a/libil2cpp.so
resources/assets/bin/Data/Managed/Metadata/global-metadata.dat
```

用途：

- 重新导出 `dump.cs`。
- 重新生成类索引、表结构、UI 类列表。

### 3. Unity 内置资源

```text
resources/assets/bin/Data/level0
resources/assets/bin/Data/sharedassets0.assets
resources/assets/bin/Data/*
```

用途：

- 分析初始场景。
- 分析内置 prefab、ScriptableObject、TextAsset。

### 4. YooAsset / AssetBundle

```text
resources/assets/asd/YooAsset
resources/assets/yoo/Default/*.bundle
```

用途：

- 解析资源包、资源地址、资源清单。
- 建立 sprite、prefab、spine、audio、textasset 映射。

## 修正后的 P0 任务

1. 在 `shaonv` 目录下创建本项目专用导出目录，例如：

```text
reverse-output/il2cpp/
reverse-output/assets/
reverse-output/derived/
```

2. 使用 `resources/lib/arm64-v8a/libil2cpp.so` 和 `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat` 重新跑 Il2CppDumper。

3. 使用 AssetStudio / AssetRipper 对 `resources/assets/bin/Data` 和 `resources/assets/yoo/Default` 重新导出资源清单。

4. 重新生成：

- `reverse-output/il2cpp/dump.cs`
- `reverse-output/il2cpp/analysis/class-index.csv`
- `reverse-output/il2cpp/analysis/table-data-fields.csv`
- `reverse-output/assets/assetstudio-cli-inventory.csv`
- `reverse-output/assets/assetstudio-cli-data-sprite/`
- `reverse-output/assets/assetstudio-cli-data-textasset/`

5. 再用这些 `shaonv/reverse-output` 结果更新所有单机版规划文档。

## 当前文档的状态

当前 docs 中关于 UI、表、玩法的结论仍可能有参考价值，因为它们来自同一工作区相邻导出的 Unity/IL2CPP 结果；但在未用 `shaonv` 本目录重新导出验证前，不能作为最终实现依据。

后续实现应以 `shaonv/reverse-output` 重新生成的数据为准。
