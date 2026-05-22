# shaonv P0 单机版补齐记录

时间：2026-05-22

## 1. 本轮目标

依据 `docs/shaonv-single-player-knowledge-summary.md` 继续推进 P0 任务，已完成的 P0-2、P0-3、P0-6 不重复导出，只补齐资源验证、UI prefab 定位、单机最小闭环实现和剩余风险。

## 2. 当前结论

| 编号 | 任务 | 状态 | 结论 |
|---|---|---|---|
| P0-1 | 反编译 LotteryDraw/Prayer/HeroRecruit 调用链 | 已有基础结论 | 调用链已收敛到 `LotteryDrawMainView -> LotteryDrawPanel -> LotteryDrawModel -> LotteryDrawFinishView/HeroRecruitView` 与 `PrayerView -> PrayerBasePanel -> PrayerModel -> PrayerRewardView`。 |
| P0-2 | 导出抽卡、角色、皮肤 Static 表 | 已完成 | 已生成 `reverse-output/gacha-static/*.csv/json`。 |
| P0-3 | heroId 到角色/资源映射 | 已完成 | 已生成 `hero_resource_map.csv/json` 和 `sample_character_assets.csv/json`。 |
| P0-4 | 导出并验证 3-5 个代表角色资源 | 部分完成 | 已实际导出并验证 `hero_003Dh`；`hero_016` 逻辑 bundle 已定位，但当前磁盘物理文件名未闭合。 |
| P0-5 | 整理抽卡 UI prefab 和结果展示 prefab | 部分完成 | 6 个目标 prefab asset 行已定位，只有 `HeroRecruitView` 能从当前 parsed bundle 表拿到 hash。 |
| P0-6 | 离线抽卡规则和本地存档 | 已完成设计 | 已在 P0 文档中定义本地规则、保底和 JSON 存档结构。 |
| P0-7 | 实现单机版最小闭环 | 已迁移到 Godot MVP | 当前实现目录为 `standalone/godot-mvp`，已实现主界面、抽卡、结果、图鉴、记录、本地存档。此前 `standalone/web-mvp` 已删除，仅保留历史分析价值。 |

## 3. P0-4 资源验证进展

已验证样本：

```text
reverse-output/gacha-static/sample-export/b61d633c6f7beec5301d9f48ffb87909/by_container/Assets/Game/RawAssets/Spine/Hero/hero_003Dh
```

包含：

- `hero_003Dh.png`
- `hero_003Dh.atlas.bytes`
- `hero_003Dh.skel.bytes`
- `hero_003Dh_SkeletonData.bin`
- `hero_003Dh_Atlas.bin`
- `hero_003Dh_Material.bin`
- `hero_003Dh_Material-Additive.bin`

`hero_016` 当前定位：

| 字段 | 值 |
|---|---|
| 角色 | `240055 天狐妲己` |
| 逻辑 bundle | `assets_game_rawassets_spine_hero_hero_016.bundle` |
| parsed fileHash | `f110b832f2beea558234c8a70a3b82d2` |
| parsed fileSize | `8472711` |
| 当前问题 | `resources/assets/yoo/Default/f110b832f2beea558234c8a70a3b82d2.bundle` 不存在 |

这说明 `manifest-parsed-bundles.csv` 的 `fileHash` 字段还不能直接当作当前磁盘物理包名使用，或者手机热更目录缺少该包。后续必须补 `bundleName -> 当前物理文件` 映射。

## 4. P0-5 UI prefab 定位

目标 UI prefab：

| View | prefab asset id | bundleName / hash 现状 | 生命周期重点 |
|---|---:|---|---|
| `HeroRecruitView` | 2442 | `assets_game_rawassets_prefabs_ui_lotterydraw_herorecruitview.bundle`，hash `7f985e1dae908dae92d5f38cbc8a5b82` | `Awake`, `InitView`, `InitAnimationView`, `CreateSpine`, `GetAnimationKey` |
| `LotteryDrawFinishView` | 2444 | 逻辑名已知，hash 未闭合 | `Awake`, `OnOpen`, `Launch`, `ShowReward` |
| `LotteryDrawMainView` | 2449 | 逻辑名已知，hash 未闭合 | `OnOpen`, `OnDrawClick`, `CheckCondition`, `OnRecvLotteryDrawOnce`, `ShowHeroReward` |
| `LotteryDrawPanel` | 2451 | 逻辑名已知，hash 未闭合 | `UpdatePanel`, `UpdateCostShow`, `OnBtnOneClick`, `OnBtnTenClick` |
| `LotteryRewardShowView` | 2459 | 逻辑名已知，hash 未闭合 | `OnOpen`, `InitView`, `GridAtAsync`, `PlayGridSpineAndShow`, `OnBtnAgainClick` |
| `PrayerRewardView` | 2523 | 逻辑名已知，hash 未闭合 | `OnOpen`, `OnOpenAsync`, `ShowRecruitView`, `OnBtnAgainClick` |

本轮额外发现 `resources/assets/yoo/Default/8532f257e2c3fee0602027efb486883a.bundle` 可由 UnityPy 读取，且 dry-run manifest 中包含大量抽卡结果特效材质：

- `fx_lottery_reward_*`
- `fx_HeroRecruitView_linght_*`

该文件更像抽卡结果/招募特效依赖包，不是 `HeroRecruitView.prefab` 主包。已生成 dry-run 记录：

```text
reverse-output/gacha-static/sample-export/8532f257e2c3fee0602027efb486883a/unitypy-export-manifest.csv
```

## 5. P0-7 Godot MVP

当前实现目录：

```text
standalone/godot-mvp/
  project.godot
  scenes/main.tscn
  scripts/main.gd
  data/
  assets/spine/
```

已实现：

- 主界面：显示本地货币、看板娘、入口、保底状态。
- 抽卡：普通/高级/进阶/源神祈愿池切换，单抽和十连。
- 结果：结果卡片、新角色标记、重复转化提示，点击结果可设为看板。
- 图鉴：已获得角色高亮，未获得灰显，显示持有数量和碎片。
- 角色详情：展示获得状态、碎片、资源路径和 Spine key，可设为看板。
- 记录：最近抽卡记录。
- 商店：源石兑换喚靈券，并进入每日补给、邮件、任务。
- 章节任务：抽卡次数、收集数量达成后发放喚靈券和源石。
- 每日补给：按本地日期每日领取一次资源。
- 邮件：启动补给、回归补给，模拟原游戏邮件奖励。
- 数据驱动：`standalone/godot-mvp/data/live_ops_mvp.json` 驱动每日补给、商店兑换、任务和邮件奖励。
- 本地存档：`user://shaonv_godot_mvp_save.json`。

资源接入：

- 当前使用已导出的 `hero_001/003Dh/005/016/017` 的 PNG 静态展示。
- 每个角色目录保留 `.skel.bytes + .atlas.txt + .png`，等待接入 Spine Godot 运行方案。

运行方式：

```powershell
cd D:\work\openclaw-workspace\arpg\shaonv
.\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
```

启动编辑器或直接运行：

```powershell
.\Godot\Godot.exe --path standalone\godot-mvp
.\Godot\Godot.exe --path standalone\godot-mvp --scene res://scenes/main.tscn
```

此前 `standalone/web-mvp` 和 `standalone/unity-mvp` 已删除，不再作为当前实现目录。

## 6. 本轮使用命令和工具

使用工具：

- PowerShell
- `rg`
- Python
- UnityPy 导出脚本：`reverse-output/scripts/export-unitypy-all-assets.py`
- git
- Codex 并行子任务

关键命令：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding=[System.Text.Encoding]::UTF8
chcp 65001 > $null
```

```powershell
rg -n "hero_016|hero_003|draw_pool|LotteryDraw|PrayerReward|HeroRecruit|LotteryReward" `
  docs reverse-output\gacha-static reverse-output\assets\manifest-parsed-py `
  -g "*.md" -g "*.json" -g "*.csv"
```

```powershell
Import-Csv reverse-output\assets\manifest-parsed-py\manifest-parsed-bundles.csv |
  Where-Object {
    $_.bundleName -match 'hero_016|herorecruitview|lotterydrawmainview|lotterydrawpanel|lotteryrewardshowview|prayerrewardview' `
    -or $_.fileName -match 'f110b832|7f985e1d' `
    -or $_.fileHash -match 'f110b832|7f985e1d'
  } |
  ConvertTo-Json -Depth 4
```

```powershell
Get-ChildItem resources\assets\yoo -Recurse -File |
  Where-Object { $_.Name -like 'f110b832*' -or $_.Name -like '7f985e1d*' } |
  Select-Object FullName,Length
```

```powershell
rg -a -l "hero_016\.skel|hero_016\.atlas|HeroRecruitView" `
  resources\assets\yoo Unpack reverse-output\assets 2>$null
```

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\8532f257e2c3fee0602027efb486883a.bundle `
  reverse-output\gacha-static\sample-export\8532f257e2c3fee0602027efb486883a `
  --xor-prefix 222 --xor-key 0x16 --container-paths `
  --types Texture2D,Sprite,TextAsset,MonoBehaviour,Material `
  --dry-run
```

## 7. 还需要继续分析的数据

为了尽可能还原游戏操作界面并继续 Godot 单机实现，下一步优先级如下：

1. 修正 YooAsset manifest 解析，得到完整 `assetPath -> bundleID -> bundleName -> 当前磁盘物理文件` 映射。
2. 批量导出 `hero_001/003/005/016/017` 的 Spine、立绘、头像、半身像和皮肤资源。
3. 导出 `HeroRecruitView/LotteryDrawMainView/LotteryDrawPanel/LotteryDrawFinishView/LotteryRewardShowView/PrayerRewardView` 主 prefab 和依赖 prefab。
4. 对上述 View 的 MonoBehaviour 字段做定向 IL/反编译，补齐按钮、动画、结果格、特效节点绑定。
5. 追 `rewardRaw` 对应的掉落/概率表，确认真实概率、保底、UP、自选祈愿和重复转化规则。
6. 整理 `LotteryDraw.spriteatlas`、抽卡背景图、按钮图、结果光效和音效，形成 `single-player asset manifest`。
7. 将 `HeroRecruitView/LotteryDrawMainView/LotteryRewardShowView` 的结构映射成 Godot Control scene，并用真实 Spine/图集/音效替换当前静态 PNG 和基础按钮。
8. 继续补原 `QuestView/GameShopView/Welfare/Mail` 对应资源和文本，把当前 `live_ops_mvp.json` 替换为从原游戏表导出的数据。
