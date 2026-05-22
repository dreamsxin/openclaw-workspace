# 少女回战抽卡 P0 分析过程

日期：2026-05-22  
工作目录：`D:\work\openclaw-workspace\arpg\shaonv`

## 1. 并行任务

按用户要求启动多任务并行：

- P0-1：反编译 `LotteryDraw/Prayer/HeroRecruit` 调用链。
- P0-2/P0-3：导出抽卡、角色、皮肤 Static 表，并建立 `heroId -> 角色名 -> 稀有度 -> 立绘/Spine` 映射。
- P0-4/P0-5：定位并验证代表角色资源，整理抽卡 UI prefab 和结果 prefab。

子任务结论已合并到：

- `docs\shaonv-gacha-single-player-p0-analysis.md`

## 2. 工具

本轮使用：

- PowerShell
- `rg`
- Mono.Cecil 脚本：`reverse-output\scripts\dump-managed-il.ps1`
- UnityPy 导出脚本：`reverse-output\scripts\export-unitypy-all-assets.py`
- 新增 Static 导出脚本：`reverse-output\scripts\export-gacha-static.py`
- 既有 YooAsset manifest 脚本：`reverse-output\scripts\parse-yoo-manifest.js`

统一读取/命令前置 UTF-8：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null
```

## 3. 索引搜索

搜索抽卡、Prayer、角色、皮肤相关类型和方法：

```powershell
rg -n "LotteryDraw|Prayer|HeroRecruit|Recruit|Gacha|Draw|Drawconfig|Wish|Pool|Hero.*Static|Skin.*Static|CharactersStatic|EntityDraw|Entity.*Draw|EntityHero|HeroModel" `
  reverse-output\managed\Assembly-CSharp-index\types.csv `
  reverse-output\managed\Assembly-CSharp-index\methods.csv `
  reverse-output\managed\Assembly-CSharp-index\ui-types.csv `
  reverse-output\managed\Assembly-CSharp-index\ui-methods.csv
```

搜索资源 manifest：

```powershell
rg -n "LotteryDraw|Prayer|HeroRecruit|Draw|Recruit|Gacha|Hero|Skin|Spine|Skeleton|Half|Head|Wallpaper" `
  reverse-output\assets\manifest
```

确认 Static 候选文件：

```powershell
Get-ChildItem reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Static |
  Where-Object Name -match 'draw|hero|skin|character|prayer|lottery|wish|recruit' |
  Select-Object Name,Length
```

关键发现：

- 抽卡 UI 类型包括 `LotteryDrawMainView`, `LotteryDrawPanel`, `HeroRecruitView`, `LotteryDrawFinishView`, `LotteryRewardShowView`。
- Prayer 类型包括 `PrayerView`, `PrayerBasePanel`, `PrayerRewardView`。
- Static 表已由 `324fcda729f678d13d6dea7bf868e1bc.bundle` 导出到 `story-textassets-raw`。

## 4. IL 字段导出

使用 Mono.Cecil dump `*StaticItem` 字段顺序：

```powershell
$out='reverse-output\gacha-analysis\static-and-gacha-types-il.txt'
$patterns=@(
  '*DrawconfigStaticItem*',
  '*DrawIntegralRewardStaticItem*',
  '*DrawSoundStaticItem*',
  '*AcDrawGiftStaticItem*',
  '*AcLimitDrawStaticItem*',
  '*AcLimitDrawconfigStaticItem*',
  '*CrazyDrawStaticItem*',
  '*IntegralDrawStaticItem*',
  '*HeroStaticItem*',
  '*HeroSkinStaticItem*',
  '*SkinStaticItem*',
  '*CharactersStaticItem*',
  '*GalCharacterStaticItem*',
  '*LotteryDrawEntity*'
)
foreach ($p in $patterns) {
  "### PATTERN $p" | Add-Content -Encoding UTF8 $out
  powershell -ExecutionPolicy Bypass -File reverse-output\scripts\dump-managed-il.ps1 `
    -AssemblyPath reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll `
    -CecilPath 'D:\work\openclaw-workspace\arpg\tools\AssetStudio.net472.v0.16.47\Mono.Cecil.dll' `
    -Patterns $p |
    Add-Content -Encoding UTF8 $out
}
```

输出：

```text
reverse-output\gacha-analysis\static-and-gacha-types-il.txt
```

注意：`dump-managed-il.ps1` 的 `Patterns` 数组参数在单次传多个 pattern 时会被 PowerShell 当成位置参数，因此本轮改为逐个 pattern 导出并合并。

## 5. Static 表导出

新增脚本：

```text
reverse-output\scripts\export-gacha-static.py
```

执行命令：

```powershell
python reverse-output\scripts\export-gacha-static.py `
  --static-dir reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Static `
  --lang reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Lang\lang.bytes `
  --lang reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Lang\lang_extra.bytes `
  --manifest-assets reverse-output\assets\manifest\manifest-assets.csv `
  --manifest-ui-prefabs reverse-output\assets\manifest\manifest-ui-prefabs.csv `
  --out-dir reverse-output\gacha-static
```

输出摘要：

```json
{
  "drawconfig": 11,
  "ac_limit_draw": 23,
  "hero": 69,
  "hero_skin": 108,
  "characters": 108,
  "gal_character": 16,
  "illustrate_hero": 69,
  "errors": {}
}
```

主要输出：

```text
reverse-output\gacha-static\tables\drawconfig.csv
reverse-output\gacha-static\tables\ac_limit_draw.csv
reverse-output\gacha-static\tables\hero.csv
reverse-output\gacha-static\tables\hero_skin.csv
reverse-output\gacha-static\tables\characters.csv
reverse-output\gacha-static\draw_pool_summary.csv
reverse-output\gacha-static\hero_resource_map.csv
reverse-output\gacha-static\sample_character_assets.csv
reverse-output\gacha-static\ui_prefab_candidates.csv
```

## 6. 角色映射检查

检查代表角色：

```powershell
Import-Csv reverse-output\gacha-static\hero_resource_map.csv |
  Where-Object { $_.heroId -in @('240045','240055','240065','240069','240068') } |
  Select-Object heroId,rare,nameText,spine,recruitImg,halfIcon,assetPathCandidates |
  ConvertTo-Json -Depth 4
```

检查业务 id 和 Spine 资源编号的关系：

```powershell
Import-Csv reverse-output\gacha-static\tables\characters.csv |
  Where-Object {
    $_.spine -match 'hero_00[135]|hero_016|hero_017' -or
    $_.recruitImg -match 'hero_00[135]|hero_016|hero_017' -or
    $_.halfIcon -match 'hero_00[135]|hero_016|hero_017'
  } |
  Select-Object id,hero,skin,name,spine,recruitImg,halfIcon,modelIcon
```

结论：

- `240065 -> 莉莉絲 -> hero_003`
- `240055 -> 天狐妲己 -> hero_016`
- `240069 -> 女帝 -> hero_017`
- `240045 -> 蔡文姬 -> hero_005`
- `240068 -> 哪吒 -> hero_001`

## 7. 样本资源定位与导出

用二进制文本搜索定位包含代表资源名的 bundle：

```powershell
rg -a -l "hero_003\.skel|hero_003\.atlas|hero_003" resources\assets\yoo\Default reverse-output\assets\yoo-default-xor16-decoded
rg -a -l "hero_005\.skel|hero_005\.atlas|hero_005" resources\assets\yoo\Default reverse-output\assets\yoo-default-xor16-decoded
rg -a -l "hero_016\.skel|hero_016\.atlas|hero_016" resources\assets\yoo\Default reverse-output\assets\yoo-default-xor16-decoded
rg -a -l "hero_017\.skel|hero_017\.atlas|hero_017" resources\assets\yoo\Default reverse-output\assets\yoo-default-xor16-decoded
```

明确命中：

```text
resources\assets\yoo\Default\b61d633c6f7beec5301d9f48ffb87909.bundle
```

导出命令：

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\b61d633c6f7beec5301d9f48ffb87909.bundle `
  reverse-output\gacha-static\sample-export\b61d633c6f7beec5301d9f48ffb87909 `
  --types Texture2D,Sprite,TextAsset,Material,MonoBehaviour,GameObject `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --container-paths
```

导出成功对象：

```text
hero_003Dh.png
hero_003Dh.atlas.bytes
hero_003Dh.skel.bytes
hero_003Dh_SkeletonData.bin
hero_003Dh_Atlas.bin
hero_003Dh_Material.bin
hero_003Dh_Material-Additive.bin
```

清单：

```text
reverse-output\gacha-static\sample-export\b61d633c6f7beec5301d9f48ffb87909\unitypy-export-manifest.csv
```

## 8. UI prefab 清单

生成自：

```text
reverse-output\assets\manifest\manifest-ui-prefabs.csv
```

筛选输出：

```text
reverse-output\gacha-static\ui_prefab_candidates.csv
```

关键 prefab：

```text
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawPanel.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryRewardShowView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroSkinView.prefab
```

## 9. Manifest 解析阻塞

尝试解析 YooAsset manifest：

```powershell
node reverse-output\scripts\parse-yoo-manifest.js `
  resources\assets\yoo\Default\Default_1001.1774870195.cht.bytes `
  reverse-output\assets\manifest-parsed
```

旧 JS 脚本失败：

```text
RangeError [ERR_OUT_OF_RANGE]: The value of "offset" is out of range.
```

原因：

- 当前 manifest 的字符串长度是 `uint16` 小端，不是旧脚本假设的 `int32`。
- asset 记录结构是 `address, assetPath, tags[], bundleId, dependAssetIds[], dependBundleIds[]`。
- bundle 记录前还有一个 lookup/header section。

新增 Python 脚本：

```text
reverse-output\scripts\parse-yoo-manifest.py
```

执行命令：

```powershell
python reverse-output\scripts\parse-yoo-manifest.py `
  resources\assets\yoo\Default\Default_1001.1774870195.cht.bytes `
  reverse-output\assets\manifest-parsed-py
```

当前输出：

```json
{
  "fileVersion": "2.3.1",
  "assetCount": 18195,
  "bundleCount": 6647,
  "bundlesParsed": 790
}
```

当前判断：

- `BuildinCatalog.json` 只有 `BundleGUID -> FileName`，不含 assetPath。
- `manifest-parsed-py\manifest-parsed-assets.csv` 已可导出 18,195 条 asset 记录。
- `manifest-parsed-py\manifest-parsed-bundles.csv` 已可导出前 790 条逻辑 bundle 记录。
- 后段 bundle 记录仍需继续还原，才能完整覆盖 6,647 个 bundle。

影响：

- 可以做 Static 表和资源路径级映射。
- 可以解析出部分关键 UI / Sprite / Spine bundle，例如 `HeroRecruitView`、`LotteryDraw` 图集、`hero_016` Spine。
- 暂不能全量稳定导出所有 `assetPath -> bundle -> files`。

后续优先级：

1. 修正 `parse-yoo-manifest.js` 对 `Default_1001.1774870195.cht.bytes` 的字段顺序。
2. 生成 `assetPath -> bundleName -> fileName -> dependencies`。
3. 用该映射批量导出 `hero_001/003/005/016/017` 和 `LotteryDraw*` prefab 依赖。
