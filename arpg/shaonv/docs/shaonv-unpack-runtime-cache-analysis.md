# shaonv 手机 files/Unpack 运行时缓存分析

分析时间：2026-05-22  
目录：`D:\work\openclaw-workspace\arpg\shaonv\Unpack`  
来源：手机 `/data/data/com.and.gt.snhl/files/` 拷贝出的 `Unpack` 目录。

## 目录结构

`Unpack` 下只有两个目录：

```text
Unpack/
  UnpackBundleFiles/
  UnpackManifestFiles/
```

统计结果：

| 项 | 数量/大小 |
| --- | ---: |
| 文件总数 | 451 |
| 总大小 | 141,972,643 bytes |
| `__data` bundle 缓存 | 225 |
| `__info` 信息文件 | 225 |
| manifest/footprint 文件 | 1 |

## 关键结论

`UnpackBundleFiles` 不是解密后的明文资源，也不是导出的 prefab/asset；它是 YooAsset 的运行时 unpack/cache 文件系统。

缓存结构：

```text
UnpackBundleFiles/<hash前2位>/<bundleHash>/__data
UnpackBundleFiles/<hash前2位>/<bundleHash>/__info
```

例如：

```text
Unpack\UnpackBundleFiles\c0\c049a0e505dd5a9644368a97ebc81245\__data
Unpack\UnpackBundleFiles\c0\c049a0e505dd5a9644368a97ebc81245\__info
```

对比 MD5 后确认：

| 结论 | 结果 |
| --- | ---: |
| `Unpack` 中 `__data` 数量 | 225 |
| APK 内源 bundle 数量 | 322 |
| `__data` 与 APK 同 hash bundle 完全一致 | 225 |
| APK 中存在但 `Unpack` 缺失 | 97 |

也就是说，手机目录中这 225 个 `__data` 仍是 APK 内的原始加密 bundle，未发生额外解密。

## 证据

`__data` 文件头：

```text
43 78 7F 62 6F 50 45 16
```

这和 APK 内 `resources\assets\yoo\Default\*.bundle` 的头部一致。上一轮已确认该头部 XOR `0x16` 后变为：

```text
55 6E 69 74 79 46 53 00
UnityFS
```

MD5 对比样例：

| 文件 | MD5 |
| --- | --- |
| `Unpack\UnpackBundleFiles\c0\c049...\__data` | `C049A0E505DD5A9644368A97EBC81245` |
| `resources\assets\yoo\Default\c049...bundle` | `C049A0E505DD5A9644368A97EBC81245` |

`ApplicationFootPrint.bytes` 内容：

```text
fd9bba35d604449abf93a42e687be137
```

它更像是 YooAsset 运行时记录的 footprint/hash，不包含资源路径或解密数据。

## 脚本包状态

上一轮 manifest 分析已经定位热更脚本包：

| 逻辑 bundle | 对应 hash 文件 |
| --- | --- |
| `assets_game_rawassets_scriptbytes.bundle` | `82d640fc6bf946d4bac8d265200fa793.bundle` |
| `assets_game_rawassets_scriptbytes_patch.bundle` | `ec57b38f548d8b2c2f6222ee738c4983.bundle` |

本次 `Unpack` 分析确认：

```text
Unpack\UnpackBundleFiles\82\82d640fc6bf946d4bac8d265200fa793\__data 不存在
Unpack\UnpackBundleFiles\ec\ec57b38f548d8b2c2f6222ee738c4983\__data 不存在
```

所以这份手机缓存不能直接提供 `Assembly-CSharp.bytes`、`WorldMap.bytes` 或 PatchAOT bytes。

`Unpack` 中也缺少两个大包：

```text
c9eea8de188f847be96d5c8687efb489.bundle
be8af1d6c0b47aada418b58c69050b52.bundle
```

## 已生成产物

| 文件 | 内容 |
| --- | --- |
| `reverse-output\assets\unpack-analysis\unpack-cache-bundles.csv` | 225 个 `__data` 缓存清单、大小、hash、是否等同源 bundle |
| `reverse-output\assets\unpack-analysis\unpack-missing-source-bundles.csv` | APK 中存在但 `Unpack` 未缓存的 97 个 bundle |
| `reverse-output\scripts\analyze-unpack-cache.js` | 分析 `UnpackBundleFiles` 的脚本 |

## 使用过的命令

统计目录：

```powershell
Get-ChildItem -LiteralPath Unpack -Recurse -File -Force |
  Measure-Object Length -Sum
```

查看大文件：

```powershell
Get-ChildItem -LiteralPath Unpack -Recurse -File -Force |
  Sort-Object Length -Descending |
  Select-Object -First 50 FullName,Length,LastWriteTime
```

检查目标脚本包是否存在：

```powershell
Test-Path Unpack\UnpackBundleFiles\82\82d640fc6bf946d4bac8d265200fa793\__data
Test-Path Unpack\UnpackBundleFiles\ec\ec57b38f548d8b2c2f6222ee738c4983\__data
```

MD5 对比：

```powershell
Get-FileHash -Algorithm MD5 `
  Unpack\UnpackBundleFiles\c0\c049a0e505dd5a9644368a97ebc81245\__data,`
  resources\assets\yoo\Default\c049a0e505dd5a9644368a97ebc81245.bundle
```

生成 CSV：

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

## 后续建议

这份 `Unpack` 没有直接解决热更程序集导出。下一步建议：

1. 从手机补拷完整 `/data/data/com.and.gt.snhl/files/`，不要只拷 `Unpack`。
2. 重点找这些目录或文件名：
   - `HotFixDll`
   - `PatchAOT`
   - `ScriptBytes`
   - `Assembly-CSharp`
   - `WorldMap`
   - `DefaultPackage`
   - `CacheFiles`
   - `BundleFiles`
3. 在手机上先进入主界面、战斗、抽卡等流程后，再重新拷贝 `files/`。当前缓存缺少脚本包，可能是还没触发相应加载，或被保存到其它目录。
4. 如果只能拿 APK 包体，仍需继续还原 YooAsset 解密服务，才能从 `82d640...bundle` 和 `ec57...bundle` 中导出热更 DLL。

