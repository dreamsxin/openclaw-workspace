# 单机版还原操作界面所需数据清单

日期：2026-05-22  
目标：尽可能还原原游戏操作界面，实现抽卡卖点优先的单机版。

## 1. 当前已具备的数据

已具备：

- UI prefab 路径清单：`reverse-output\assets\manifest\manifest-ui-prefabs.csv`
- YooAsset assetPath 清单：`reverse-output\assets\manifest\manifest-assets.csv`
- Python 解析的 manifest 部分映射：`reverse-output\assets\manifest-parsed-py`
- 抽卡/角色/皮肤 Static 表：`reverse-output\gacha-static\tables`
- 抽卡池摘要：`reverse-output\gacha-static\draw_pool_summary.csv`
- `heroId -> 名字 -> 稀有度 -> Spine/立绘`：`reverse-output\gacha-static\hero_resource_map.csv`
- 故事文本：`reverse-output\story-texts`
- 热更业务程序集索引：`reverse-output\managed\Assembly-CSharp-index`

## 2. 新增 manifest 解析进展

新增 Python 脚本：

```text
reverse-output\scripts\parse-yoo-manifest.py
```

可解析：

- `fileVersion=2.3.1`
- `packageName=Default`
- `packageVersion=1001.1774870195.cht`
- `buildPipeline=ScriptableBuildPipeline`
- 18,195 条 asset 记录
- 前 790 条逻辑 bundle 记录

输出：

```text
reverse-output\assets\manifest-parsed-py\manifest-parsed-assets.csv
reverse-output\assets\manifest-parsed-py\manifest-parsed-bundles.csv
reverse-output\assets\manifest-parsed-py\manifest-parsed-summary.json
```

限制：

- `bundleCount=6647`，当前只稳定解析 `bundlesParsed=790`。
- 后段 bundle 记录不再全部以 `assets_*.bundle` 命名，或中间还有未解的 section，需要继续对齐。
- 当前映射足够覆盖部分 UI、LotteryDraw 图集、Prayer 面板、`hero_016` Spine 等，但还不能全量自动导出所有依赖。

## 3. 还原操作界面还需要补齐的数据

### 3.1 prefab 结构数据

需要导出并解析以下 prefab 的 GameObject 层级和 MonoBehaviour 字段：

```text
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawPanel.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryRewardShowView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListView.prefab
```

目的：

- 还原按钮位置、滚动列表、Tab、结果卡格。
- 确认 `Button -> 方法` 绑定。
- 确认 prefab 内引用的 Sprite、Spine、特效和字体。
- 复刻界面布局，而不是只复刻功能。

### 3.2 UI 图集和字体

必须补齐：

- `Assets/Game/RawAssets/Sprite/LotteryDraw/**`
- `Assets/Game/RawAssets/Sprite/Common/**`
- `Assets/Game/RawAssets/Sprite/Hero/**`
- `Assets/Game/RawAssets/Sprite/Head/**`
- 字体、通用按钮、货币图标、稀有度框、结果背景。

用途：

- 主界面入口按钮。
- 抽卡池背景。
- 单抽/十连按钮。
- 结果页稀有度边框。
- 图鉴头像和未获得遮罩。

### 3.3 View 生命周期和交互状态

还需反编译核心 UI 类的方法体：

```text
LotteryDrawMainView
LotteryDrawPanel
LotteryDrawHelper
LotteryDrawFinishView
LotteryRewardShowView
HeroRecruitView
PrayerView
PrayerBasePanel
HeroMainView
HeroListView
HeroSkinView
```

需要记录：

- `Awake / OnOpen / OnShow / Destroy` 做了什么。
- 哪些事件刷新 UI。
- 哪些按钮触发抽卡、心愿、概率、返回。
- 结果展示动画顺序。
- 是否有跳过动画 Toggle。

### 3.4 奖励与概率表

当前 `drawconfig` 只拿到卡池和保底字段，还需要把 reward id 展开：

```text
reward1/reward2/reward3/reward4/rewardF2/reward
```

需要追：

- `380011/380012/380013` 等 reward id 对应什么掉落组。
- 每个掉落组的 hero、道具、权重、数量。
- 高级召唤、普通召唤、进阶召唤、限定召唤的真实概率。
- 重复角色转化规则。

### 3.5 角色展示资源

每个 MVP 角色至少需要：

- `characters.spine`
- `characters.recruitImg`
- `characters.halfIcon`
- `characters.modelIcon`
- `hero_skin.skinIcon`
- Spine 文件组：`.png`, `.atlas.txt`, `.skel.bytes`, `SkeletonData.asset`

优先验证角色：

```text
240065 莉莉絲 -> hero_003
240055 天狐妲己 -> hero_016
240069 女帝 -> hero_017
240045 蔡文姬 -> hero_005
240068 哪吒 -> hero_001
```

### 3.6 新手与主界面入口

如果要“像原游戏一样操作”，还要补：

- `MainUIView` 上抽卡入口按钮位置与显隐条件。
- `GuideAsset` 新手引导图、对话框、遮罩组件。
- `TopBar` 货币显示。
- `RedDot` 红点逻辑，可在单机版简化为本地可抽提示。

### 3.7 本地存档与资源索引

需要形成单机运行时数据：

```text
data/pools.json
data/heroes.json
data/resources.json
data/ui-prefabs.json
save/save.json
```

其中：

- `pools.json` 来自 `draw_pool_summary.csv`
- `heroes.json` 来自 `hero_resource_map.csv`
- `resources.json` 来自 manifest + 实际导出资源
- `ui-prefabs.json` 来自 prefab 层级解析
- `save.json` 保存货币、抽卡历史、保底计数、已拥有角色和看板娘

## 4. 下一步优先级

1. 继续完善 `parse-yoo-manifest.py`，把 `bundlesParsed` 从 790 提到 6647。
2. 用解析出的 bundle 映射批量导出 LotteryDraw、Prayer、Hero UI prefab 及依赖图集。
3. 反编译 `LotteryDrawHelper` 和结果页，确认抽卡动画与结果展示参数。
4. 追 `reward` 系列表，展开真实掉落池和概率。
5. 为 5 个代表角色导出完整立绘/Spine，并验证在单机 runtime 中可加载。
6. 基于导出 UI 图集搭建单机版界面，而不是先做纯功能页面。
