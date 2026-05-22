# shaonv YooAsset manifest/物理包映射修复

时间：2026-05-22

## 1. 修复目标

闭合 YooAsset 热更资源映射：

```text
assetPath/address -> bundleID -> resolvedBundleID -> bundleName -> hashFileName -> physicalPath
```

这一步用于继续导出抽卡 UI prefab、Spine、SpriteAtlas、音效和 Static 数据。

## 2. 根因

旧版 `parse-yoo-manifest.py` 有两个问题：

1. bundle 记录中的 `fileSize` 实际是 `uint64`，旧脚本按 `uint32` 读取，导致 `encrypted/tags/dependBundleIDs` 后续字段错位。
2. asset 记录中的 `bundleID` 不是 bundle 表数组下标，需要整体偏移 `-133` 才能对应解析出的 bundle 数组。

修复前表现：

- `bundleCount=6647`，但只能解析 `bundlesParsed=790`。
- `hero_016` 等高位资源只能看到 asset 行，无法可靠回到正确 bundle。
- 误以为 `fileHash` 和物理文件名不对应。

修复后：

```json
{
  "assetCount": 18195,
  "bundleCount": 6647,
  "bundlesParsed": 6647,
  "physicalFilesIndexed": 327,
  "bundlesWithPhysicalFile": 276,
  "bundlesWithPhysicalSizeMatch": 276,
  "bundleIDOffset": -133
}
```

结论：manifest 已完整解析；当前磁盘只存在 276 个对应 bundle，剩余资源缺物理包，不是解析失败。

## 3. 修改内容

脚本：

```text
reverse-output/scripts/parse-yoo-manifest.py
reverse-output/scripts/export-yoo-physical-map.py
```

`parse-yoo-manifest.py` 更新：

- 新增 `Reader.u64()`。
- bundle `fileSize` 改为 `uint64`。
- 不再逐条扫描下一个 `assets_*.bundle` 字符串，而是在一次对齐后顺序解析 6647 条 bundle。
- 自动推断 `bundleIDOffset=-133`。
- 输出 `resolvedBundleID`、`bundleIDOffset`、`hashFileName`、`physicalPath`、`physicalExists`、`physicalSizeMatches`。
- 支持 `--physical-root` 扫描当前磁盘包。

`export-yoo-physical-map.py` 新增：

- 生成重点资源映射：`focused-asset-physical-map.csv`
- 生成当前可直接导出的 asset 映射：`physical-asset-map.csv`
- 生成当前可直接导出的 bundle 映射：`physical-bundle-map.csv`
- 生成统计：`physical-map-summary.json`

## 4. 生成产物

完整 manifest 解析产物：

```text
reverse-output/assets/manifest-parsed-py/manifest-parsed-assets.csv
reverse-output/assets/manifest-parsed-py/manifest-parsed-bundles.csv
reverse-output/assets/manifest-parsed-py/manifest-parsed-summary.json
```

物理映射产物：

```text
reverse-output/assets/yoo-physical-map/focused-asset-physical-map.csv
reverse-output/assets/yoo-physical-map/physical-asset-map.csv
reverse-output/assets/yoo-physical-map/physical-bundle-map.csv
reverse-output/assets/yoo-physical-map/physical-map-summary.json
```

## 5. 关键资源验证

当前已能闭合到物理文件的重点资源：

| asset | bundleName | physicalPath |
|---|---|---|
| `LotteryDrawFinishView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotterydrawfinishview.bundle` | `resources/assets/yoo/Default/86c05702d8a8a6410d5a48ddc7449de4.bundle` |
| `LotteryDrawMainView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotterydrawmainview.bundle` | `resources/assets/yoo/Default/1918525995d5a5ed05fce5506c55ca0d.bundle` |
| `LotteryDrawNewStageView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotterydrawnewstageview.bundle` | `resources/assets/yoo/Default/eb29a3f2afe63586af98537addc6cb12.bundle` |
| `hero_003Dh` Spine 文件组 | `assets_game_rawassets_spine_hero_hero_003dh.bundle` | `resources/assets/yoo/Default/b61d633c6f7beec5301d9f48ffb87909.bundle` |
| `LotteryDraw.json` | `assets_game_static_reddottree.bundle` | `resources/assets/yoo/Default/d4f0f4146eea1dcc1a3bc2c221446b91.bundle` |

当前缺物理包但 manifest 已能准确定位的重点资源：

| asset | bundleName | hashFileName |
|---|---|---|
| `HeroRecruitView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_herorecruitview.bundle` | `7f985e1dae908dae92d5f38cbc8a5b82.bundle` |
| `LotteryDrawPanel.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotterydrawpanel.bundle` | `531addbb386175036da2f491cb4d1742.bundle` |
| `LotteryRewardShowView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotteryrewardshowview.bundle` | `a9321033285bb8e6f0a638a5eb0fba98.bundle` |
| `PrayerRewardView.prefab` | `assets_game_rawassets_prefabs_ui_prayer_prayerrewardview.bundle` | `715dfdfca01468071d780e27352de68d.bundle` |
| `hero_016` Spine | `assets_game_rawassets_spine_hero_hero_016.bundle` | `f110b832f2beea558234c8a70a3b82d2.bundle` |
| `hero_017` Spine | `assets_game_rawassets_spine_hero_hero_017.bundle` | `d0feba660f4456452e29d9252b2fbd69.bundle` |

## 6. 已验证导出

使用修复后的物理映射，已成功导出两个抽卡 UI bundle：

```text
reverse-output/gacha-static/ui-prefab-export/LotteryDrawMainView/
reverse-output/gacha-static/ui-prefab-export/LotteryDrawFinishView/
```

命令：

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\1918525995d5a5ed05fce5506c55ca0d.bundle `
  reverse-output\gacha-static\ui-prefab-export\LotteryDrawMainView `
  --xor-prefix 222 --xor-key 0x16 --container-paths `
  --types GameObject,MonoBehaviour,Transform,RectTransform,Sprite,Texture2D,Material,AnimatorController,TextAsset
```

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\86c05702d8a8a6410d5a48ddc7449de4.bundle `
  reverse-output\gacha-static\ui-prefab-export\LotteryDrawFinishView `
  --xor-prefix 222 --xor-key 0x16 --container-paths `
  --types GameObject,MonoBehaviour,Transform,RectTransform,Sprite,Texture2D,Material,AnimatorController,TextAsset
```

导出结果：

| 目标 | objectsSeen | objectsExported | errors |
|---|---:|---:|---|
| `LotteryDrawMainView` | 1188 | 888 | 0 |
| `LotteryDrawFinishView` | 1551 | 892 | 0 |

## 7. 下一步

1. 从手机 `/data/data/com.and.gt.snhl/files/` 继续补齐缺失物理包，优先查找 `7f985e1d...`、`531addbb...`、`a9321033...`、`715dfdf...`、`f110b832...`、`d0feba...`。
2. 对 `ui-prefab-export` 中导出的 `GameObject/MonoBehaviour/RectTransform` 做结构分析，整理按钮、节点、动画字段。
3. 用 `physical-asset-map.csv` 批量导出当前已经存在的头像、方形头像、道具图标、`LotteryDrawMainView` 依赖资源。
4. 缺失包补齐后，直接按 `hashFileName` 用 UnityPy 导出目标 Spine/UI prefab。
