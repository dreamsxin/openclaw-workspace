# ilprobe

用于从已导出的热更程序集里直接提取真实 IL 方法体，或查找某个方法的调用者。

## 依赖

- .NET SDK 8+
- `Mono.Cecil.dll`
  - 当前工程默认引用：
    - `D:/work/openclaw-workspace/arpg/tools/AssetStudio-net10.0-win/Mono.Cecil.dll`

## 构建

在仓库根目录执行：

```powershell
dotnet build tools\ilprobe\ilprobe.csproj -c Release
```

## 用法

### 1. 提取指定方法体

```powershell
dotnet run --project tools\ilprobe\ilprobe.csproj --configuration Release -- `
  reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  "AssetsHelper/<LoadSpriteFromExpeditionWorldMapIcon>d__111::MoveNext" `
  "ExpeditionMapGrid/<Init>d__10::MoveNext" `
  "ExpeditionMapView/<GenerateMap>d__47::MoveNext"
```

### 2. 查找某个方法的调用者

```powershell
dotnet run --project tools\ilprobe\ilprobe.csproj --configuration Release -- `
  reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
  --find-callers "LoadSpriteFromExpeditionWorldMapIcon"
```

## 当前已验证样例

已成功提取：

- `AssetsHelper/<LoadSpriteFromExpeditionWorldMapIcon>d__111::MoveNext`
- `ExpeditionMapGrid/<Init>d__10::MoveNext`
- `ExpeditionMapView/<GenerateMap>d__47::MoveNext`
- `ExpeditionMapView/<OnOpen>d__44::MoveNext`
- `ExpeditionMapView/<InitMoveTool>d__51::MoveNext`
- `ExpeditionMapView/<MoveToNewArea>d__50::MoveNext`

## 注意

- `WorldMap.dll` 当前用 Mono.Cecil 读取会触发 metadata 解析异常；优先从 `Assembly-CSharp.dll` 侧追方法调用和 async 状态机。
- async 方法本体通常只是壳，真正有效逻辑要看对应的：
  - `<MethodName>d__N::MoveNext`
