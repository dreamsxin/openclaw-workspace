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

初次仅索引 `resources/assets/yoo/Default` 时只能匹配 276 个 bundle。把手机目录
`D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default` 纳入索引后，统计更新为：

```json
{
  "assetCount": 18195,
  "bundleCount": 6647,
  "bundlesParsed": 6647,
  "physicalFilesIndexed": 14028,
  "bundlesWithPhysicalFile": 6185,
  "bundlesWithPhysicalSizeMatch": 6185,
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
- 支持 YooAsset 手机缓存结构：`BundleFiles/<hash前两位>/<hash>/__data`。

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
| `HeroRecruitView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_herorecruitview.bundle` | `files/yoo/Default/BundleFiles/7f/7f985e1dae908dae92d5f38cbc8a5b82/__data` |
| `hero_001` Spine 文件组 | `assets_game_rawassets_spine_hero_hero_001.bundle` | `files/yoo/Default/BundleFiles/0e/0e5210f0383683827d134d7c0bdb10d7/__data` |
| `hero_003Dh` Spine 文件组 | `assets_game_rawassets_spine_hero_hero_003dh.bundle` | `resources/assets/yoo/Default/b61d633c6f7beec5301d9f48ffb87909.bundle` |
| `hero_005` Spine 文件组 | `assets_game_rawassets_spine_hero_hero_005.bundle` | `files/yoo/Default/BundleFiles/e1/e142aefe30d7727b58a79e487c52e19b/__data` |
| `hero_016` Spine 文件组 | `assets_game_rawassets_spine_hero_hero_016.bundle` | `files/yoo/Default/BundleFiles/f1/f110b832f2beea558234c8a70a3b82d2/__data` |
| `hero_017` Spine 文件组 | `assets_game_rawassets_spine_hero_hero_017.bundle` | `files/yoo/Default/BundleFiles/d0/d0feba660f4456452e29d9252b2fbd69/__data` |
| `LotteryDraw.json` | `assets_game_static_reddottree.bundle` | `resources/assets/yoo/Default/d4f0f4146eea1dcc1a3bc2c221446b91.bundle` |

当前仍缺物理包但 manifest 已能准确定位的重点资源：

| asset | bundleName | hashFileName |
|---|---|---|
| `LotteryDrawPanel.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotterydrawpanel.bundle` | `531addbb386175036da2f491cb4d1742.bundle` |
| `LotteryRewardShowView.prefab` | `assets_game_rawassets_prefabs_ui_lotterydraw_lotteryrewardshowview.bundle` | `a9321033285bb8e6f0a638a5eb0fba98.bundle` |
| `PrayerRewardView.prefab` | `assets_game_rawassets_prefabs_ui_prayer_prayerrewardview.bundle` | `715dfdfca01468071d780e27352de68d.bundle` |

## 6. 已验证导出

使用修复后的物理映射，已成功导出抽卡 UI bundle：

```text
reverse-output/gacha-static/ui-prefab-export/HeroRecruitView/
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
| `HeroRecruitView` | 846 | 617 | 0 |
| `LotteryDrawMainView` | 1188 | 888 | 0 |
| `LotteryDrawFinishView` | 1551 | 892 | 0 |

已成功导出代表角色 Spine 主包：

| 目标 | hash | objectsSeen | objectsExported | errors |
|---|---|---:|---:|---|
| `hero_001` | `0e5210f0383683827d134d7c0bdb10d7` | 16 | 13 | 0 |
| `hero_005` | `e142aefe30d7727b58a79e487c52e19b` | 28 | 25 | 0 |
| `hero_016` | `f110b832f2beea558234c8a70a3b82d2` | 31 | 27 | 0 |
| `hero_017` | `d0feba660f4456452e29d9252b2fbd69` | 27 | 23 | 0 |

## 7. 下一步

1. 继续查找缺失 UI 包：`531addbb...`、`a9321033...`、`715dfdf...`。
2. 对 `ui-prefab-export` 中导出的 `GameObject/MonoBehaviour/RectTransform` 做结构分析，整理按钮、节点、动画字段。
3. 用 `physical-asset-map.csv` 批量导出当前已经存在的头像、方形头像、道具图标、`LotteryDrawMainView` 依赖资源。
4. 将已导出的 `hero_001/005/016/017` Spine 三件套纳入单机版资源清单。

## 8. Godot UI 资源导出更新

时间：2026-05-23

本轮已用修复后的物理映射继续导出一批可直接接入 Godot 的 UI 图片。导出命令模式：

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  <physicalPath> `
  reverse-output\godot-resource-export\<asset-key> `
  --xor-prefix 222 --xor-key 0x16 --container-paths `
  --types Texture2D,Sprite,TextAsset,AudioClip
```

已验证导出的关键资源：

| asset | physicalPath | Godot 落盘 |
|---|---|---|
| `Assets/Game/RawAssets/Sprite/BackGround/login_bg_01.png` | `files/yoo/Default/UnpackBundleFiles/64/647bb3f8d07da0f5cd3a427cfe667d46/__data` | `standalone/godot-mvp/assets/ui/background/login_bg_01.png` |
| `Assets/Game/RawAssets/Sprite/BackGround/mainui_bg_01.png` | `files/yoo/Default/UnpackBundleFiles/49/49b67212a5ba7c5e4687eac6a8a4be81/__data` | `standalone/godot-mvp/assets/ui/background/mainui_bg_01.png` |
| `Assets/Game/RawAssets/Sprite/BackGround/mainui_bg_02.png` | `files/yoo/Default/BundleFiles/a2/a274e17038bc58235f710bf98e4df2af/__data` | `standalone/godot-mvp/assets/ui/background/mainui_bg_02.png` |
| `Assets/Game/RawAssets/Sprite/Login/logo.png` | `files/yoo/Default/BundleFiles/9a/9a3ce25ebc12cd55eb20007f97759139/__data` | `standalone/godot-mvp/assets/ui/login/logo.png` |
| `Assets/Game/RawAssets/Sprite/Login/server_bg_011.png` | `files/yoo/Default/BundleFiles/ec/ec1e093af2768ed42aa90abb8eb8ab17/__data` | `standalone/godot-mvp/assets/ui/login/server_bg_011.png` |
| `Assets/Game/RawAssets/Sprite/Login/server_bg_03.png` | `resources/assets/yoo/Default/8cfe4e0148670640e919adc92c841d6c.bundle` | `standalone/godot-mvp/assets/ui/login/server_bg_03.png` |
| `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_01.png` | `files/yoo/Default/BundleFiles/cb/cb842e65b448fd2ec0239d59ac06ec4e/__data` | `standalone/godot-mvp/assets/ui/lottery/lottery_img_01.png` |
| `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_60.png` | `files/yoo/Default/BundleFiles/6f/6f3e9fad14c7d3f7a80030bce905ca31/__data` | `standalone/godot-mvp/assets/ui/lottery/lottery_img_60.png` |
| `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_60_l.png` | `files/yoo/Default/BundleFiles/34/347e79afc81c357688dd4e227245cf40/__data` | `standalone/godot-mvp/assets/ui/lottery/lottery_img_60_l.png` |
| `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_60_r.png` | `files/yoo/Default/BundleFiles/fd/fd3599bc4553b4b7038540e13ef1b276/__data` | `standalone/godot-mvp/assets/ui/lottery/lottery_img_60_r.png` |
| `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_alpha_l.png` | `files/yoo/Default/BundleFiles/e6/e6883b47610377ea2569656d24e93dd3/__data` | `standalone/godot-mvp/assets/ui/lottery/lottery_img_alpha_l.png` |
| `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_alpha_r.png` | `files/yoo/Default/BundleFiles/8d/8dc442e5b977e42220a8af07e1940cfc/__data` | `standalone/godot-mvp/assets/ui/lottery/lottery_img_alpha_r.png` |
| `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_10.png` | `files/yoo/Default/UnpackBundleFiles/81/81efe3519683f820516e21458a06ca24/__data` | `standalone/godot-mvp/assets/ui/mainui/mainui_img_10.png` |

结论更新：

- `physical-asset-map.csv` 已足够支撑一批 Login/MainUI/LotteryDraw 图片导出。
- 这些资源已经接入 Godot MVP，登录页、主界面、抽卡页和抽卡演出/结果页不再只依赖几何色块。
- 中间导出目录 `reverse-output/godot-resource-export/` 仅作为可复现导出记录；Godot 实际运行依赖 `standalone/godot-mvp/assets/ui/`。
