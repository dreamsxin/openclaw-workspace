# shaonv 单机实现方案与资源导出决策

时间：2026-05-22

## 1. 当前方案是否合理

当前方案已从 Web/Unity 两阶段切换为 Godot 主线。原因是 Unity 授权和发行成本不适合当前单机 MVP，Web 版只能验证流程，无法低成本承接后续 Spine、音频、存档、场景组织和打包发布。

| 阶段 | 目标 | 技术选择 | 结论 |
|---|---|---|---|
| 当前 MVP | 跑通主界面、抽卡、结果、图鉴、记录、存档 | `standalone/godot-mvp` | 当前主线，适合开源/低成本发行，并能逐步接入 Spine、音效和 UI 资源。 |
| 历史验证 | 快速验证离线抽卡规则和界面流程 | `standalone/web-mvp` | 已删除，仅保留文档结论。 |
| 高还原参考 | 理论上最容易复用 Unity 原 prefab/Material/Animator | `standalone/unity-mvp` | 已删除，不再作为实现方向；只保留逆向分析价值。 |

当前工程位置：

```text
standalone/godot-mvp
```

Godot 方案的取舍：

- 优点：无 Unity 授权风险，适合单机发行；Control UI、JSON 存档、资源管理足够支撑抽卡 MVP。
- 代价：不能直接复用 Unity UGUI prefab、AnimatorController、Material，需要按分析结果在 Godot 中重建 UI。
- 资源策略：先使用导出的 PNG 静态展示角色；后续接入 Spine Godot 插件或转换流程播放 `.skel.bytes + .atlas.txt + .png`。

## 2. 能否实现骨骼动画

可以实现。

已验证导出的 `hero_003Dh` 包含 Spine 运行所需核心资源，当前已复制到 Godot 工程资源目录：

```text
standalone/godot-mvp/assets/spine/hero_003Dh/
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

### Godot 实现方式

Godot 正式版建议优先验证 Spine Godot 运行方案：

1. 保持 `assets/spine/<heroKey>/<heroKey>.skel.bytes`、`.atlas.txt`、`.png` 三件套同目录。
2. 接入可用于 Godot 4 的 Spine Runtime/插件，验证二进制 `.skel`、atlas 路径和透明混合。
3. 在角色展示页、抽卡结果页使用 Spine 节点播放 idle/入场/点击动画。
4. 动画名从 `.skel.bytes` 解析或用 Spine Runtime 枚举，优先尝试 `idle`、`standby`、`animation`、`touch` 等常见名。

### Web 实现方式

Web 也能播放，但已不再作为当前 MVP 目标：

1. 引入 Spine Web Runtime。
2. 加载 `.skel.bytes`、`.atlas.txt`、`.png`。
3. 使用 WebGL/Canvas 播放 Skeleton。
4. 需要额外处理二进制加载、atlas 图片路径、动画名枚举、透明混合。

因此：当前实现选 Godot；Unity/Web 只作为历史方案和资源复用参考。

## 3. 当前已导出的可用资源

### 3.1 MVP 已复制资源

```text
standalone/godot-mvp/assets/spine/hero_001/
standalone/godot-mvp/assets/spine/hero_003Dh/
standalone/godot-mvp/assets/spine/hero_005/
standalone/godot-mvp/assets/spine/hero_016/
standalone/godot-mvp/assets/spine/hero_017/
```

`standalone/godot-mvp/scripts/main.gd` 当前按角色 `artResource` 映射本地 PNG：

```gdscript
load("res://%s.png" % resource_path.replace("Art/Spine", "assets/spine"))
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
standalone/godot-mvp/data/
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

standalone/godot-mvp/
  Godot 单机 MVP
  assets/spine/Hero/...
  assets/ui/lottery/...
  assets/audio/...
  data/...
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

- 现在的单机实现方案已切换为 Godot MVP，方向合理。
- 骨骼动画能实现，已验证 `hero_003Dh` 拥有完整 Spine 三件套。
- 下一步导出优先级是角色 Spine 三件套、角色静态图、抽卡 UI prefab 结构、抽卡 UI 图集、结果特效、音效、真实掉落表。
- 在 manifest 物理映射补齐前，不应大规模写死 bundle hash；应以 dry-run 结果和已验证导出为准。

## 8. Unity Hub 已安装后的方案再评估

时间：2026-05-23

本机已经安装 Unity Hub 后，Unity 方案的可行性提高，但不建议立刻把当前单机 MVP 主线从 Godot 切回 Unity。

### 是否会更快

短期“做出能玩闭环”不一定更快。当前 Godot MVP 已经跑通：

```text
启动/登录 -> 主界面 -> 抽卡 -> 结果 -> 图鉴/角色详情 -> 记录/商店/任务/邮件 -> 本地存档
```

并且已经接入：

- 5 个代表角色 baked Spine 动画。
- Login/MainUI/LotteryDraw 第一批原游戏 PNG。
- 本地 JSON 数据驱动的卡池、运营补给和存档。

如果切到 Unity，需要重新搭工程、搭本地数据层、重写 UI 流程、处理导入设置、处理 Spine Runtime 版本、处理 Android/PC 打包配置。即使 Unity 对原始资源格式更友好，第一轮迁移成本会抵消这部分优势。

### 是否会更好

Unity 在“高还原”方向有优势：

- 更容易复用 Unity 原资源类型：Prefab、UGUI、AnimatorController、Material、ParticleSystem。
- Spine-Unity 运行时生态成熟，理论上更适合直接播放 `.skel.bytes + .atlas.txt + .png` 并做动画混合、事件、换装。
- 如果后续目标是高度贴近原手游 UI 动效和材质表现，Unity 是更自然的还原环境。

但当前项目的实际约束仍然存在：

- YooAsset 包虽然已能解密和映射，但 Unity 工程不能直接“打开原项目”；仍要从导出的 AssetBundle/Prefab/Texture/MonoBehaviour 数据重建可编辑工程。
- 原游戏热更 C# 逻辑依赖大量线上服务、SDK、RPC、StaticCenter、ModelCenter、EventCenter，不能简单复制进 Unity 后直接运行。
- Unity 授权、版本、发布链路和项目体积仍比 Godot 重。
- 当前 Godot baked Spine 路线已经满足 MVP 展示，不支持运行时换装/混合动画的问题可以后置。

### 建议决策

当前主线建议保持：

```text
Godot = 单机 MVP 和可运行产品主线
Unity = 高还原验证/资源还原实验线
```

更具体地说：

1. 不要中断 Godot MVP。继续把真实 Login/MainUI/LotteryDraw/角色资源接进去，并拆分 scene 降低 `main.gd` 复杂度。
2. 可以新建一个小型 Unity 验证工程，只做两件事：
   - 导入一个已导出的角色 Spine 三件套，验证 Spine-Unity 直接播放 `wait/wait1`。
   - 导入 `LotteryDrawMainView` / `HeroRecruitView` 的导出 prefab 数据，评估 RectTransform/UGUI 还原成本。
3. 只有当 Unity 验证工程证明“prefab + Spine + UI 图集”能明显低成本还原，并且能稳定离线运行时，再考虑把 Unity 升为主线。

因此当前结论是：

- 想更快完成可玩的单机版：继续 Godot。
- 想更高还原原手游表现：并行做 Unity 技术验证。
- 不建议现在整体迁移到 Unity；最佳下一步是保留 Godot 主线，同时用 Unity Hub 做一个小规模验证分支。
