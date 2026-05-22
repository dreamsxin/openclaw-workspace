# 少女回战单机版知识汇总与开工前缺口

更新日期：2026-05-22

目标：基于 `D:\work\openclaw-workspace\arpg\shaonv` 当前已还原的热更程序集、YooAsset 资源和 UI 调用链，整理可用于单机版实现的知识，并明确还需要补齐哪些信息。

## 当前已掌握

### 资源与热更程序集

已确认 YooAsset 自定义解密逻辑：

```text
读取 bundle 前 222 字节
每字节 XOR 0x16
其余内容保持不变
```

已导出热更业务程序集：

```text
reverse-output\managed\hotfix-dlls\Assembly-CSharp.dll
reverse-output\managed\hotfix-dlls\WorldMap.dll
```

`Assembly-CSharp.dll` 已建立索引：

```text
types=8928
methods=37802
uiTypes=1407
```

### UI 框架

核心 UI 框架已还原：

```text
UIRoot2d      场景 UI 根和层级
UIControl     事件、RPC、Timer、Tween、CancellationToken 清理
ViewBehaviour Open/Close/Destroy/遮罩/栈顶/返回/BGM
LaunchView    启动视频 launch.mp4
LoginView     登录、隐私协议、服务器列表、公告
LoadingView   登录后进度条，进 MainScene
MainUIView    主城主界面
```

已确认启动主链路：

```text
LaunchView 播放 launch.mp4
  -> LoginView
  -> 登录按钮 / RPCSession.Connect
  -> LoadingView.UpdateProcess
  -> GameHelper.LoadMainScene
  -> SceneLoadManagerExtension.LoadAsyncScene("MainScene")
  -> MainUIView
```

`MainUIView` 已确认包含：

```text
玩家信息
主界面壁纸/角色展示
玩法入口
商业化入口
章节任务
底部导航
红点系统
TopBar
```

### 资源类别

YooAsset manifest 已整理：

```text
reverse-output\assets\manifest\manifest-assets.csv
reverse-output\assets\manifest\manifest-ui-prefabs.csv
reverse-output\assets\manifest\manifest-ui-prefab-category-stats.csv
reverse-output\assets\manifest\manifest-scenes.csv
reverse-output\assets\manifest\manifest-dll-bytes.csv
```

UI prefab 分类统计显示，体量最大的类别包括：

```text
Activity       285
Common          64
Hero            64
Roguelike       59
Gal             59
Arena           39
Alliance        39
Remnants        35
LotteryDraw     19
Prayer          10
Wallpaper        8
MainUI           8
Login            6
Launch           2
Update           1
```

## 本游戏单机版的核心卖点判断

本游戏单机版不应该优先复刻完整联网 RPG 生态。更高价值的 MVP 应围绕：

```text
抽卡
好看的人物立绘
人物动画
角色收集
主界面展示/壁纸/看板娘
基础养成反馈
```

因此第一版目标建议是：

```text
离线登录
主界面
抽卡
获得角色
角色图鉴
角色详情
立绘/Spine/Live2D 或序列动画展示
基础资源消耗与奖励
本地存档
```

可延后：

```text
完整战斗
联盟
竞技场
跨服
活动
排行榜
支付
广告
公告和远程更新
复杂红点
```

## 开始实现前还必须整理的信息

### 1. 抽卡系统

这是最高优先级。

需要还原：

```text
抽卡入口 View：
LotteryDraw 相关 View/Panel/Grid
Prayer 相关 View/Panel/Grid
抽卡按钮、十连按钮、跳过动画按钮
抽卡结果界面
抽卡历史或保底提示
```

需要还原数据：

```text
卡池配置
角色池列表
权重
稀有度
UP 角色
保底规则
十连规则
消耗道具
免费次数
抽卡结果奖励结构
```

需要重点反编译类型：

```text
LotteryDraw*
Prayer*
Recruit*
Gacha*
Draw*
HeroRecruit*
EntityLottery*
LotteryDrawModel
PrayerModel
```

需要整理产物：

```text
docs\shaonv-gacha-system-analysis.md
derived\gacha\pools.json
derived\gacha\rates.json
derived\gacha\offline-rules.json
```

### 2. 角色数据与立绘资源

抽卡结果必须能展示角色，所以要先建立角色数据到资源的映射。

需要还原：

```text
角色 ID
角色名
稀有度
阵营/职业/属性
默认皮肤
皮肤列表
半身立绘
全身立绘
头像
小头像
战斗模型
主界面展示模型
Spine/SkeletonData 资源
触摸区域/互动配置
```

重点类型和方法：

```text
HeroModel
HeroMainView
HeroDetailInfoView
HeroRecruitView
EntityHero
HeroStatic
HeroSkinStatic
AssetsHelper.LoadSpriteFromHero*
AssetsHelper.LoadSkeletonDataFromHero*
AssetsHelper.LoadSpineFromUI
SpineTouchManager
SpineTouchConfigSO
```

需要整理产物：

```text
docs\shaonv-character-resource-analysis.md
derived\characters\characters.json
derived\characters\character-assets.json
derived\characters\skins.json
```

最低可用字段：

```json
{
  "heroId": "string",
  "name": "string",
  "rarity": 0,
  "defaultSkinId": "string",
  "portrait": "asset path",
  "halfPortrait": "asset path",
  "headIcon": "asset path",
  "spine": {
    "skeleton": "asset path",
    "atlas": "asset path",
    "texture": "asset path"
  }
}
```

### 3. 人物动画展示链路

卖点是“好看的人物立绘加动画”，所以不能只导 PNG。必须确认动画技术栈。

需要判断：

```text
主界面人物是 Spine、Unity Animator、Video、序列帧，还是混合方案
角色详情页展示使用哪个 prefab
抽卡出货动画使用哪个 prefab / Timeline / Spine
皮肤展示和触摸互动是否独立配置
```

需要整理：

```text
Spine atlas/skel/json 与贴图成套关系
SkeletonDataAsset 所在 bundle
动画名列表：idle、touch、show、appear、special 等
角色展示 prefab 到 SkeletonGraphic/SkeletonAnimation 的绑定
抽卡动画 prefab 到角色资源的替换点
```

重点类型：

```text
InteractiveRole
WallpaperPanel
WallpaperPreView
SpineTouchManager
SpineTouchConfigSO
HeroRecruitView
LotteryDrawFinishView
LaunchView
```

需要整理产物：

```text
docs\shaonv-character-animation-analysis.md
derived\characters\spine-bundles.json
derived\characters\animation-names.json
derived\characters\display-prefabs.json
```

### 4. 抽卡 UI 与资源绑定

需要把抽卡系统做成第一版体验，必须知道 UI prefab 的层级和按钮绑定。

需要导出并整理：

```text
Prefabs/UI/LotteryDraw/*
Prefabs/UI/Prayer/*
Prefabs/UI/Hero/*
Prefabs/UI/Common/RewardGrid
Prefabs/UI/Common/TopResGrid
```

需要确认：

```text
抽卡入口在 MainUIView 哪个按钮
抽卡界面 prefab 字段绑定
抽卡结果格子 prefab
稀有度特效 prefab
角色展示容器
货币显示和不足提示
返回/关闭流程
```

需要整理产物：

```text
docs\shaonv-gacha-ui-prefab-analysis.md
derived\ui\gacha-prefabs.json
derived\ui\reward-grid-binding.json
```

### 5. 配置表和静态数据格式

当前已经能看见 `StaticCenter.Get<T>()`、`DataConfigStatic`、各种 `*Static` 类型，但还需要导出真实表数据。

优先级：

```text
HeroStatic
HeroSkinStatic
Lottery/Recruit/Prayer 相关 Static
Reward 相关 Static
Item 相关 Static
Language/Scx.Lang 文本表
DataConfigStatic
```

需要确认：

```text
表资源文件名
序列化格式：MemoryPack / bytes / json / ScriptableObject
字段结构
ID 引用关系
```

需要整理产物：

```text
docs\shaonv-static-table-analysis.md
derived\tables\hero.json
derived\tables\hero_skin.json
derived\tables\gacha_pool.json
derived\tables\item.json
derived\tables\lang.json
```

### 6. 本地存档最小结构

抽卡单机版至少需要：

```text
玩家 ID / 名字
钻石或抽卡券
已拥有角色
角色皮肤
抽卡历史
卡池保底计数
主界面看板角色
是否看过启动视频
设置项
```

建议第一版存档：

```json
{
  "version": 1,
  "player": {
    "name": "Player",
    "level": 1
  },
  "wallet": {
    "diamond": 99999,
    "tickets": {}
  },
  "heroes": {},
  "skins": {},
  "gacha": {
    "pity": {},
    "history": []
  },
  "home": {
    "wallpaperHeroId": "",
    "skinId": ""
  },
  "flags": {
    "launchVideoSeen": false
  }
}
```

### 7. 可用资源导出清单

目前 UnityPy 脚本已经可导出图片和 TextAsset，但单机版实现还要建立更完整导出规范。

需要补齐：

```text
Sprite/Texture2D 全量导出路径
TextAsset bytes 导出
Spine atlas/skel/json 导出
AudioClip 导出
Prefab 结构导出或 AssetRipper 工程导出
场景 MainScene/Root 导出
材质和 shader 降级策略
```

建议产物：

```text
reverse-output\assets\unitypy-all-assets\
derived\asset-index\sprites.csv
derived\asset-index\spine.csv
derived\asset-index\audio.csv
derived\asset-index\prefabs.csv
```

## 推荐下一轮任务顺序

按“尽快做出有卖点的单机版”排序：

```text
P0-1 反编译 LotteryDraw/Prayer/HeroRecruit 调用链
P0-2 导出抽卡、角色、皮肤相关 Static 表
P0-3 建立 heroId -> 角色名 -> 稀有度 -> 立绘/Spine 资源映射
P0-4 导出并验证 3-5 个代表角色的立绘和动画资源
P0-5 整理抽卡 UI prefab 和结果展示 prefab
P0-6 设计离线抽卡规则和本地存档
P0-7 实现单机版最小闭环：主界面 -> 抽卡 -> 结果 -> 图鉴/角色展示
```

## MVP 范围建议

第一版可以这样收敛：

```text
启动页：可跳过 launch.mp4
登录页：离线点击进入
主界面：显示一个看板角色、基础货币、抽卡入口、图鉴入口
抽卡页：单抽/十连、固定卡池、保底
结果页：展示角色立绘/稀有度/新获得标记
图鉴页：角色列表、详情页、立绘/动画展示
存档：JSON 本地保存
```

第一版不做：

```text
真实联网
真实支付
完整主线战斗
全部活动
全部红点
复杂养成
服务器公告
热更新下载
```

## 相关文档

```text
docs\shaonv-yooasset-decryption-hotfix-export.md
docs\shaonv-yooasset-manifest-analysis.md
docs\shaonv-unpack-runtime-cache-analysis.md
docs\shaonv-hotfix-ui-lifecycle-analysis.md
docs\shaonv-analysis-process.md
```

