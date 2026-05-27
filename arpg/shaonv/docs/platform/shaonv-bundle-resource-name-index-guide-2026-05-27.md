# Bundle 资源名索引手册

生成时间：2026-05-27

这份文档解决一个很实际的问题：明明知道资源名是 `hero_053_s02`，为什么还是很难快速定位到真正的本地 bundle 文件，尤其是 `files/yoo/Default/BundleFiles/*/*/__data` 这种运行时缓存包。

## 为什么包这么难定位

同一个资源在这套 YooAsset 管线里，往往同时有 4 层名字：

| 层 | 例子 | 说明 |
|---|---|---|
| 资源名 | `hero_053_s02` | Unity 对象名，通常出现在 `Texture2D` / `TextAsset` / `Sprite` / `MonoBehaviour` 内部。 |
| asset 地址 | `Assets/Game/RawAssets/Spine/Hero/hero_053_s02/...` | manifest 里最适合人类理解的路径。 |
| bundleName / hashFileName | `assets_game_rawassets_spine_hero_hero_053_s02.bundle` / `a579edd19c0b2c1abcf2af39565ef92d.bundle` | manifest 声明的逻辑 bundle 名和 hash 名。 |
| physicalPath | `files/yoo/Default/BundleFiles/d1/d133c1e76a9e76b3b5ebbb26131bb095/__data` | 机器上真实存在的物理文件。 |

难点不是某一层本身，而是这几层不总是一一对应：

1. manifest 是“声明式映射”，记录的是逻辑 bundle；
2. `files/yoo/Default/BundleFiles` 和 `UnpackBundleFiles` 是“运行时真实落点”；
3. 本地运行过之后，某些资源会出现在运行时缓存里，但 `physical-bundle-map.csv` 不一定已经把这份真实物理包回填完整；
4. `__data` 目录名通常是另一套 hash，人眼无法从资源名直接反推出去。

所以你这次遇到的情况本质上是：

- manifest 里 `hero_053_s02` 指向的是 `a579edd19c0b2c1abcf2af39565ef92d.bundle`
- 但本地真实可解出的物理包是 `files/yoo/Default/BundleFiles/d1/d133c1e76a9e76b3b5ebbb26131bb095/__data`

这就是“按 manifest 查”和“按本地物理包查”之间出现断层的典型例子。

## 避免再人肉定位的方法

不要再走“资源名 -> 猜 bundleName -> 猜 hash -> 猜 physicalPath”的路线。

改成固定两段式：

1. 先查全量资源名索引，直接确定资源实际出现在哪个物理 bundle 里；
2. 只有需要逻辑元数据时，再回到 manifest / physical map 查 `bundleName`、`hashFileName`、依赖关系。

也就是说，以后资源定位优先级改为：

1. `bundle-resource-name-index.csv`
2. `bundle-resource-summary.csv`
3. `physical-asset-map.csv`
4. `manifest-parsed-assets.csv`

## 新增的索引文件

由脚本 `scripts/assets/export_bundle_name_index.py` 生成：

| 文件 | 用途 |
|---|---|
| `reverse-output/assets/bundle-name-index/bundle-resource-name-index.csv` | 全量对象名索引。按 `resourceName` 搜最直接。 |
| `reverse-output/assets/bundle-name-index/bundle-resource-summary.csv` | bundle 级摘要。看某个 `__data` 里大概装了什么。 |
| `reverse-output/assets/bundle-name-index/bundle-scan-errors.csv` | 扫描失败记录。当前仓库这次导出为 0。 |
| `reverse-output/assets/bundle-name-index/bundle-name-index-summary.json` | 总体统计。 |

这次实跑结果：

## 2026-05-28 实战补充：`hero_053_s02` / `hero_053_s02h`

这条路线已经在 Expedition / Spine 追源里完成了一次完整实战。

典型问题：

- `manifest-parsed-assets.csv` 中能看到：
  - `Assets/Game/RawAssets/Spine/Hero/hero_053_s02/...`
  - `Assets/Game/RawAssets/Spine/Hero/hero_053_s02h/...`
- 但 `physical-asset-map.csv` 没有可用 `physicalPath`
- 直接按 manifest 推导包名，会误以为资源“本地缺失”

改走资源名直查后，实际命中物理 bundle：

- `hero_053_s02`
  - `files/yoo/Default/BundleFiles/d1/d133c1e76a9e76b3b5ebbb26131bb095/__data`
- `hero_053_s02h`
  - `files/yoo/Default/BundleFiles/2e/2ebf56a5c569284708925de1bc096436/__data`

然后继续走：

1. 单独补导出到 `tmp/all-spine-export`
2. 重跑 `scripts/spine/import_all_spines_to_godot.py`
3. 针对新增条目运行 `scripts/spine/bake_hero_spine_preview.mjs`

最终成功补回：

- `Hero__hero_053_s02`
- `Hero__hero_053_s02h`

经验结论：

1. `physical-asset-map.csv` 没命中，不等于本地没有资源。
2. 当你已经知道明确资源名时，直接扫所有本地 bundle 的 container path，比继续猜 bundleName / hash 更快。
3. 这条方法特别适合：
   - Spine 三件套
   - 运行时缓存 bundle
   - manifest 有记录但 physical map 未闭合的资源

- 扫描物理 bundle：`7281`
- 扫描失败：`0`
- 建立对象索引：`194117`

## 脚本用法

```powershell
python scripts\assets\export_bundle_name_index.py --repo-root .
```

默认会扫描：

- `files/yoo/Default/BundleFiles/*/*/__data`
- `files/yoo/Default/UnpackBundleFiles/*/*/__data`
- `resources/assets/yoo/Default/*.bundle`

并自动做：

1. XOR 解密前 222 字节，密钥 `0x16`
2. 用 UnityPy 读取 bundle
3. 导出内部对象名
4. 尝试与 `reverse-output/assets/yoo-physical-map/physical-bundle-map.csv` 回连
5. 即使回连失败，也保留 `physical-only` 索引记录，避免漏掉运行时缓存包

## hero_053_s02 的直接查法

```powershell
Import-Csv reverse-output\assets\bundle-name-index\bundle-resource-name-index.csv |
  Where-Object { $_.resourceNameLower -match 'hero_053_s02' } |
  Select-Object resourceName,objectType,bundleName,hashFileName,physicalPath
```

这次已经验证能直接命中：

- `hero_053_s02`
- `hero_053_s02.atlas`
- `hero_053_s02.skel`
- `hero_053_s02_bg`

对应真实物理包：

- `files/yoo/Default/BundleFiles/d1/d133c1e76a9e76b3b5ebbb26131bb095/__data`

也就是说，今后你只要知道对象名，不需要先知道 manifest 里的逻辑 bundle。

## 什么时候查 summary 表

如果你已经拿到一个物理包路径，只想先判断“这包大概是不是我要的”，先查：

```powershell
Import-Csv reverse-output\assets\bundle-name-index\bundle-resource-summary.csv |
  Where-Object { $_.physicalPath -match 'd133c1e76a9e76b3b5ebbb26131bb095' }
```

这次返回的摘要是：

- `objectCount = 14`
- `uniqueNameCount = 14`
- `types = {"Material": 4, "MonoBehaviour": 4, "TextAsset": 4, "Texture2D": 2}`

这对 Spine 包非常好用，因为一眼就能看出它大概率是：

- 2 张贴图
- 2 套 atlas/skel 文本
- 2 套 SkeletonData / Atlas / Material

## 推荐的固定排障顺序

1. 只知道资源名：先查 `bundle-resource-name-index.csv`
2. 已知道物理包路径：查 `bundle-resource-summary.csv`
3. 需要逻辑 bundle / hash / 依赖：查 `physical-bundle-map.csv`
4. 需要 asset 地址 / 资源声明：查 `manifest-parsed-assets.csv`
5. 只有在以上都没有答案时，才手工解某个 bundle 看内容

## 结论

可以，而且已经做了：

- 所有本地可见 bundle 的资源名已经导出到 `reverse-output/assets/bundle-name-index/`
- 以后定位资源，应优先查“资源名索引”，不要先猜 manifest 映射
- 这能显著减少 `bundleName / hashFileName / __data physicalPath` 三层名字来回跳转的成本
