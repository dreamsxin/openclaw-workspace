# shaonv 单机实现方案与资源导出决策

时间：2026-05-22

## 1. 方案是否合理

当前“两阶段”方案是合理的：

| 阶段 | 目标 | 技术选择 | 结论 |
|---|---|---|---|
| 快速验证 | 先跑通主界面、抽卡、结果、图鉴、存档 | `standalone/web-mvp` 静态 Web | 合理，开发快，适合验证离线规则和界面流程。 |
| 正式还原 | 尽量复用原资源、UI prefab、Spine、音效、特效 | Unity 单机工程 | 更合理，原游戏就是 Unity，骨骼动画和 prefab 迁移成本最低。 |

Web MVP 不应作为最终还原载体。它适合先把抽卡循环和数据结构跑通，但要高还原原游戏界面，正式版本建议新建 Unity 工程：

```text
standalone/unity-mvp
```

理由：

- 原资源是 Unity AssetBundle/YooAsset 体系，prefab、Material、Texture2D、SpriteAtlas、AudioClip 都是 Unity 原生资产。
- Spine 资源以 Unity Spine Runtime 组件使用，导出的 `.skel.bytes + .atlas.txt + .png` 可直接被 Unity Spine Runtime 接入。
- 抽卡界面的 `LotteryDrawMainView`、`HeroRecruitView`、`LotteryRewardShowView` 等 prefab 原本就是 UGUI/MonoBehaviour 结构，用 Unity 复刻最省成本。
- Web 要实现 Spine 也可行，但需要 Spine Web Runtime，并且 UI prefab、Unity 材质、特效、动画控制器都要二次翻译。

## 2. 能否实现骨骼动画

可以实现。

已验证导出的 `hero_003Dh` 包含 Spine 运行所需核心资源：

```text
standalone/web-mvp/assets/spine/hero_003Dh/
  hero_003Dh.png
  hero_003Dh.atlas.txt
  hero_003Dh.skel.bytes
```

原始导出位置：

```text
reverse-output/gacha-static/sample-export/b61d633c6f7beec5301d9f48ffb87909/by_container/Assets/Game/RawAssets/Spine/Hero/hero_003Dh/
```

这三类文件的作用：

| 文件 | 作用 | 是否必须 |
|---|---|---|
| `.skel.bytes` | Spine 二进制骨架、插槽、动画数据 | 必须 |
| `.atlas.txt` | Spine atlas，定义贴图区域和旋转/裁剪信息 | 必须 |
| `.png` | atlas 对应贴图 | 必须 |
| `_SkeletonData.asset` | Unity Spine 预制 SkeletonDataAsset | Unity 中可选，能重建则不强依赖 |
| `_Atlas.asset` | Unity Spine 预制 AtlasAsset | Unity 中可选，能重建则不强依赖 |
| `_Material.mat` | Spine 渲染材质 | Unity 中建议导出，方便还原 blend/加法材质 |

### Unity 实现方式

Unity 正式版推荐接入 Spine Unity Runtime：

1. 将 `hero_003Dh.skel.bytes`、`hero_003Dh.atlas.txt`、`hero_003Dh.png` 放入 Unity `Assets/Art/Spine/Hero/hero_003Dh/`。
2. 使用 Spine Unity Runtime 生成 `SkeletonDataAsset` 和 `AtlasAsset`。
3. 在角色展示页、抽卡结果页使用 `SkeletonGraphic` 或 `SkeletonAnimation`。
4. 动画名从 `.skel.bytes` 解析或用 Spine Runtime 枚举，优先尝试 `idle`、`standby`、`animation`、`touch` 等常见名。

### Web 实现方式

Web 也能播放，但不是当前 MVP 的首选目标：

1. 引入 Spine Web Runtime。
2. 加载 `.skel.bytes`、`.atlas.txt`、`.png`。
3. 使用 WebGL/Canvas 播放 Skeleton。
4. 需要额外处理二进制加载、atlas 图片路径、动画名枚举、透明混合。

因此：正式高还原选 Unity；Web 只作为抽卡流程和数据结构验证。

## 3. 当前已导出的可用资源

### 3.1 MVP 已复制资源

```text
standalone/web-mvp/assets/spine/hero_003Dh/hero_003Dh.png
standalone/web-mvp/assets/spine/hero_003Dh/hero_003Dh.atlas.txt
standalone/web-mvp/assets/spine/hero_003Dh/hero_003Dh.skel.bytes
```

`standalone/web-mvp/app.js` 当前引用本地 PNG：

```js
const ART = "./assets/spine/hero_003Dh/hero_003Dh.png";
```

### 3.2 分析产物

```text
reverse-output/gacha-static/draw_pool_summary.csv
reverse-output/gacha-static/draw_pool_summary.json
reverse-output/gacha-static/hero_resource_map.csv
reverse-output/gacha-static/hero_resource_map.json
reverse-output/gacha-static/sample_character_assets.csv
reverse-output/gacha-static/sample_character_assets.json
reverse-output/gacha-static/ui_prefab_candidates.csv
reverse-output/gacha-static/ui_prefab_candidates.json
```

## 4. 单机版需要导出哪些资源

### 4.1 抽卡核心数据

| 数据 | 来源 | 用途 | 状态 |
|---|---|---|---|
| `drawconfig` / `ac_limit_draw` | Static 表 | 卡池、消耗、保底、展示角色 | 已导出 |
| `hero` | Static 表 | heroId、角色名、稀有度 | 已导出 |
| `hero_skin` | Static 表 | 皮肤、立绘、Spine key | 已导出 |
| `characters` | Static 表 | 角色资源补充字段 | 已导出 |
| reward/drop 表 | Static 表 | 真实概率、掉落组、重复转化 | 待继续追 |

建议落盘：

```text
standalone/unity-mvp/Assets/StreamingAssets/data/
  gacha_pools.json
  heroes.json
  hero_skins.json
  drop_rules.json
  save_default.json
```

### 4.2 角色骨骼动画

每个目标角色至少导出：

```text
Assets/Game/RawAssets/Spine/Hero/<heroKey>/<heroKey>.skel.bytes
Assets/Game/RawAssets/Spine/Hero/<heroKey>/<heroKey>.atlas.txt
Assets/Game/RawAssets/Spine/Hero/<heroKey>/<heroKey>.png
```

建议首批角色：

| heroId | 名称 | key | 原因 |
|---:|---|---|---|
| 240065 | 莉莉絲 | `hero_003` / `hero_003Dh` | 已有可用样本，适合作为首个可播放角色 |
| 240055 | 天狐妲己 | `hero_016` | 高稀有代表角色 |
| 240069 | 女帝 | `hero_017` | 结果展示代表角色 |
| 240045 | 蔡文姬 | `hero_005` | 图鉴/普通池代表 |
| 240068 | 哪吒 | `hero_001` | 普通池代表 |

每个角色建议同时导出变体：

- 主体：`hero_XXX`
- 半身/抽卡演出：`hero_XXXh`
- 皮肤：`hero_XXX_s01`、`hero_XXX_s01h`
- 战斗 Q 版：`HeroQ/hero_XXXq`，正式战斗系统再导出
- 背景/前景分层：`*_bg`、`*_fg`，如果 atlas 中存在
- silhouette：未获得剪影展示

### 4.3 角色静态图

用于图鉴、卡片、结果页快速展示：

| 类型 | key 示例 | 用途 |
|---|---|---|
| 头像 | `hero_head*` 或相关 Sprite | 图鉴格、结果小卡 |
| 半身像 | `bhero_003` | 主界面/图鉴 |
| 招募图 | `phero_003` | 抽卡详情/概率展示 |
| 立绘 | `zhero_003` | 角色展示 |
| 剪影 | `hero_003_silhouette` | 未获得状态 |

这些资源的精确 assetPath 已部分出现在 `hero_resource_map.csv` 和 manifest assets 中，但仍依赖完整 `assetPath -> 物理 bundle` 映射。

### 4.4 抽卡 UI prefab

正式 Unity 复刻需要导出这些 prefab：

```text
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawPanel.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryRewardShowView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryRewardShowGrid.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawRateView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawWishView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardGrid.prefab
```

这些 prefab 用于还原：

- 卡池入口
- 卡池 tab
- 单抽/十连按钮
- 消耗显示
- 概率/积分/心愿入口
- 抽卡演出结果页
- 十连结果格
- 再抽一次按钮

### 4.5 UI 图片、图集、特效和音效

抽卡界面还需要导出：

| 资源 | 例子 | 用途 |
|---|---|---|
| 抽卡图集 | `Assets/Game/RawAssets/Sprite/LotteryDraw/*` | 背景、按钮、mask、卡池 banner |
| UI 通用图集 | Common、Hero、Item、Prayer 相关 SpriteAtlas | 按钮、货币、道具框 |
| 结果特效材质 | `fx_lottery_reward_*`, `fx_HeroRecruitView_linght_*` | 抽卡结果光效 |
| AnimatorController | `MainUIMenuView01.controller` 等 | UI 动画 |
| 音效 | `Cominc_xzyy_24.wav`、抽卡/点击/结果音效 | 反馈和演出 |

本轮已 dry-run 一个疑似抽卡特效包：

```text
reverse-output/gacha-static/sample-export/8532f257e2c3fee0602027efb486883a/unitypy-export-manifest.csv
```

其中包含大量：

```text
fx_lottery_reward_*
fx_HeroRecruitView_linght_*
```

## 5. 推荐导出目录规范

为了避免逆向产物和单机工程混在一起，建议：

```text
reverse-output/
  继续保存原始分析、dry-run、批量导出记录

standalone/web-mvp/
  只放 Web MVP 真正使用的轻量资源

standalone/unity-mvp/
  未来正式 Unity 工程
  Assets/Art/Spine/Hero/...
  Assets/Art/UI/LotteryDraw/...
  Assets/Audio/...
  Assets/StreamingAssets/data/...
```

## 6. 当前最大阻塞

最大阻塞不是骨骼动画本身，而是 YooAsset manifest 的物理包映射：

```text
assetPath -> bundleID -> bundleName -> 当前磁盘物理文件
```

当前情况：

- `manifest-parsed-assets.csv` 能列出很多 assetPath。
- `manifest-parsed-bundles.csv` 只稳定解析了前 790 个 bundle。
- `hero_016` 能得到逻辑 bundle 和 parsed hash，但 `resources/assets/yoo/Default/f110b832f2beea558234c8a70a3b82d2.bundle` 不存在。
- 说明 parsed `fileHash` 与当前磁盘文件名之间仍缺一层映射，或者当前 `Unpack`/`resources` 缺少对应热更文件。

下一步应优先完成：

1. 修 `parse-yoo-manifest.py`，完整解析 6647 个 bundle。
2. 对 `resources/assets/yoo/Default` 和 `Unpack` 建立物理文件索引。
3. 用 UnityPy dry-run 扫描可读 bundle，反向建立 `containerPath -> physicalBundle`。
4. 先批量导出 5 个代表角色的 Spine 三件套。
5. 再导出抽卡 UI prefab 和依赖图集。

## 7. 实施结论

- 现在的单机实现方案合理，但 Web MVP 只作为流程验证。
- 骨骼动画能实现，已验证 `hero_003Dh` 拥有完整 Spine 三件套。
- 正式高还原应使用 Unity + Spine Unity Runtime。
- 下一步导出优先级是角色 Spine 三件套、角色静态图、抽卡 UI prefab、抽卡 UI 图集、结果特效、音效、真实掉落表。
- 在 manifest 物理映射补齐前，不应大规模写死 bundle hash；应以 dry-run 结果和已验证导出为准。
