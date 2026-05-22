# 少女回战抽卡单机版 P0 分析

日期：2026-05-22  
目录：`D:\work\openclaw-workspace\arpg\shaonv`

## 1. P0 结论

本轮按 `shaonv-single-player-knowledge-summary.md` 的 P0 清单推进，已完成：

- P0-1：抽卡调用链收敛到 `LotteryDrawMainView + LotteryDrawPanel + LotteryDrawModel` 和 `PrayerView + PrayerBasePanel + PrayerModel` 两条链路。
- P0-2：导出并解析抽卡、角色、皮肤相关 Static 表。
- P0-3：建立 `heroId -> 角色名 -> 稀有度 -> 立绘/Spine` 映射。
- P0-4：定位 5 个代表角色资源；实际导出并验证了 `hero_003Dh` Spine 文件组。
- P0-5：整理抽卡 UI prefab、结果 prefab、Prayer prefab。
- P0-6：设计离线抽卡规则与本地存档结构。
- P0-7：定义单机最小闭环：主界面 -> 抽卡 -> 结果 -> 图鉴/角色展示。

核心输出目录：

- `D:\work\openclaw-workspace\arpg\shaonv\reverse-output\gacha-static`
- `D:\work\openclaw-workspace\arpg\shaonv\reverse-output\gacha-analysis`

## 2. 抽卡业务调用链

普通抽卡主链：

```text
LotteryDrawMainView.OnOpen
  -> LotteryDrawModel.UniTaskReqInfo / ReqGetDrawInfo.SendData
  -> LotteryDrawModel.OnGetLotteryDrawInfo / RecvGetDrawInfo
  -> LotteryDrawMainView.InitBtnListAndPnl / InitViewByDrawType
  -> LotteryDrawPanel.UpdatePanel / UpdateCostShow
  -> LotteryDrawPanel.OnBtnOneClick / OnBtnTenClick
  -> LotteryDrawMainView.OnDrawClick(EventParam)
  -> LotteryDrawMainView.CheckCondition()
  -> LotteryDrawModel.ReqLotteryDraw(LotteryDraw, DrawOperateType)
  -> ReqLotteryDraw.SendData()
  -> RecvLotteryDraw
  -> LotteryDrawMainView.OnRecvLotteryDrawOnce(EventParam)
  -> LotteryDrawHelper.ShowLotteryAnimation(...)
  -> LotteryDrawNewStageView / LotteryDrawStageView
  -> LotteryDrawFinishView.ShowReward(LotteryDrawInfo)
  -> HeroRecruitView.InitView(...)
```

Prayer 分支：

```text
PrayerView.OnOpen / OnOpenAsync
  -> PrayerModel.Init / OnGetDrawInfo
  -> PrayerView.CreatePage
  -> PrayerBasePanel.Init / Show / OnShow
  -> PrayerBasePanel.OnBtnOnceClick / OnLotteryDraw(EventParam)
  -> RecvLotteryDraw
  -> PrayerBasePanel.DrawAnimation()
  -> PrayerRewardView.OnOpen / ShowRecruitView(IItemShow)
  -> HolyRelicRecruitView / RemnantRecruitView / MechaRecruitView
```

主界面红点侧证据：

- `MainUIView.InitRedDot` 出现 `LotteryDraw.LotteryDrawHero.7805`
- `MainUIView.InitRedDot` 出现 `LotteryDraw.Prayer.4036`

后续若要做完全一致的动画跳转，还需要优先反编译：

- `LotteryDrawMainView`
- `LotteryDrawPanel`
- `LotteryDrawModel`
- `LotteryDrawHelper`
- `LotteryDrawFinishView`
- `HeroRecruitView`
- `PrayerView`
- `PrayerBasePanel`
- `PrayerRewardView`

## 3. Static 表导出

新增脚本：

`D:\work\openclaw-workspace\arpg\shaonv\reverse-output\scripts\export-gacha-static.py`

执行结果：

```json
{
  "drawconfig": 11,
  "ac_limit_draw": 23,
  "ac_limit_drawconfig": 15,
  "ac_draw_gift": 2,
  "crazy_draw": 5,
  "draw_integral_reward": 3000,
  "draw_sound": 5,
  "integral_draw": 6,
  "hero": 69,
  "hero_skin": 108,
  "skin": 44,
  "characters": 108,
  "gal_character": 16,
  "gal_hero": 7,
  "gal_hero_skin": 14,
  "illustrate_hero": 69
}
```

无解析错误。主要产物：

- `reverse-output\gacha-static\tables\*.csv`
- `reverse-output\gacha-static\tables\*.json`
- `reverse-output\gacha-static\draw_pool_summary.csv`
- `reverse-output\gacha-static\hero_resource_map.csv`
- `reverse-output\gacha-static\sample_character_assets.csv`
- `reverse-output\gacha-static\ui_prefab_candidates.csv`

字段顺序来自 `Assembly-CSharp.dll` 内 `*StaticItem` formatter 的 IL dump，原始记录在：

- `reverse-output\gacha-analysis\static-and-gacha-types-il.txt`

## 4. 抽卡池摘要

主抽卡池：

| table | id | 名称 | 单抽消耗 | 十连消耗 | 关键保底字段 |
|---|---:|---|---|---|---|
| drawconfig | 1201 | 普通喚靈 | `230102;1` | `230102;10` | `cnt2=50; cnt3=2000; cnt4=9; cntF=30; cntF2=14` |
| drawconfig | 1100 | 高級喚靈 | `230103;1` | `230103;10` | `cnt2=50; cnt3=60; cnt4=9; cntF=16; cntF2=15` |
| drawconfig | 1300 | 進階喚靈 | `230106;1` | `230106;10` | `cnt2=50; cnt3=60; cnt4=9; cntF=39; cntF2=19` |
| ac_limit_draw | 241055 | 天狐妲己 | `230118;1` | `230118;10` | `cnt2=50; cnt3=60; cntF2=50` |

`draw_pool_summary.csv` 已解析：

- 卡池 id
- 卡池名称语言文本
- `showHeroIds`
- `showHeroNames`
- 单抽/十连消耗
- `cnt2/cnt3/cnt4/cntF/cntF2` 保底参数
- 原始 reward 字段

## 5. 角色资源映射

业务 `heroId` 与资源编号不是同一套编号。正确路径是：

```text
hero.bytes / HeroStaticItem.id
  -> hero.name / rare
  -> characters.bytes / CharactersStaticItem.hero
  -> spine / recruitImg / halfIcon / modelIcon
  -> manifest-assets.csv 中的 Assets/Game/RawAssets/Spine/Hero/...
```

代表映射：

| heroId | 角色名 | rare | spine | recruitImg | halfIcon |
|---:|---|---:|---|---|---|
| 240045 | 蔡文姬 | 3 | `hero_005` | `zhero_005` | `bhero_005` |
| 240055 | 天狐妲己 | 4 | `hero_016`, `hero_016_s01` | `zhero_016`, `zhero_016_s01` | `bhero_016`, `bhero_016_s01` |
| 240065 | 莉莉絲 | 3 | `hero_003`, `hero_003_s01`, `hero_003_s02` | `zhero_003`, `zhero_003_s01` | `bhero_003`, `bhero_003_s01`, `bhero_003_s02` |
| 240068 | 哪吒 | 3 | `hero_001` | `zhero_001` | `bhero_001` |
| 240069 | 女帝 | 3 | `hero_017` | `zhero_017` | `bhero_017` |

示例资源路径均已在 `sample_character_assets.csv` 中列出。典型 Spine 文件组：

```text
Assets/Game/RawAssets/Spine/Hero/hero_003/hero_003.atlas.txt
Assets/Game/RawAssets/Spine/Hero/hero_003/hero_003.png
Assets/Game/RawAssets/Spine/Hero/hero_003/hero_003.skel.bytes
Assets/Game/RawAssets/Spine/Hero/hero_003/hero_003_Atlas.asset
Assets/Game/RawAssets/Spine/Hero/hero_003/hero_003_SkeletonData.asset
```

## 6. 样本资源导出验证

已导出并验证一个实际 Spine 文件组：

原始 bundle：

```text
resources\assets\yoo\Default\b61d633c6f7beec5301d9f48ffb87909.bundle
```

导出目录：

```text
reverse-output\gacha-static\sample-export\b61d633c6f7beec5301d9f48ffb87909
```

导出对象：

| type | name | 说明 |
|---|---|---|
| Texture2D | `hero_003Dh` | 已导出 PNG |
| TextAsset | `hero_003Dh.atlas` | Spine atlas |
| TextAsset | `hero_003Dh.skel` | Spine skeleton 二进制 |
| MonoBehaviour | `hero_003Dh_SkeletonData` | Unity Spine SkeletonData |
| MonoBehaviour | `hero_003Dh_Atlas` | Unity Spine Atlas |
| Material | `hero_003Dh_Material` | 材质 |
| Material | `hero_003Dh_Material-Additive` | 叠加材质 |

命中路径：

```text
reverse-output\gacha-static\sample-export\b61d633c6f7beec5301d9f48ffb87909\by_container\Assets\Game\RawAssets\Spine\Hero\hero_003Dh
```

限制：

- `hero_001/003/005/016/017` 在资源路径清单中完整存在。
- 但 YooAsset manifest 二进制解析仍会越界，暂不能稳定自动得到 `assetPath -> bundleName/fileHash` 的精确映射。
- 当前只通过明文命中和 UnityPy 实际加载验证了 `hero_003Dh` 所在 bundle。

## 7. 抽卡 UI prefab

普通抽卡：

```text
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawPanel.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryRewardShowView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryRewardShowGrid.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawRateView.prefab
Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawWishView.prefab
```

Prayer：

```text
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerRewardGrid.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerWishSelectView.prefab
Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerIntegralRewardView.prefab
```

角色展示：

```text
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListView.prefab
Assets/Game/RawAssets/Prefabs/UI/Hero/HeroSkinView.prefab
```

完整候选见：

```text
reverse-output\gacha-static\ui_prefab_candidates.csv
```

## 8. 单机抽卡规则设计

MVP 不需要复刻联网协议，建议以 Static 表为数据源，做确定性离线规则：

### 8.1 卡池配置

数据源：

- `draw_pool_summary.csv`
- `tables\hero.csv`
- `hero_resource_map.csv`

离线卡池对象：

```json
{
  "poolId": 1100,
  "name": "高級喚靈",
  "costItem": 230103,
  "singleCost": 1,
  "tenCost": 10,
  "featuredHeroIds": [240065, 240069],
  "allHeroIds": [],
  "rates": {
    "rare4": 0.02,
    "rare3": 0.12,
    "rare2": 0.86
  },
  "pity": {
    "rare4Hard": 60,
    "rare3Soft": 10
  }
}
```

### 8.2 抽卡结果

离线结果对象：

```json
{
  "drawId": "local-uuid",
  "poolId": 1100,
  "drawCount": 10,
  "results": [
    {
      "type": "hero",
      "heroId": 240065,
      "isNew": true,
      "rare": 3,
      "name": "莉莉絲",
      "spine": "hero_003",
      "halfIcon": "bhero_003"
    }
  ]
}
```

### 8.3 存档结构

建议本地 JSON 存档：

```json
{
  "version": 1,
  "profile": {
    "playerName": "Player",
    "createdAt": "2026-05-22T00:00:00+08:00"
  },
  "currency": {
    "230102": 9999,
    "230103": 9999,
    "230106": 9999
  },
  "gacha": {
    "pools": {
      "1100": {
        "totalDraws": 0,
        "pityRare4": 0,
        "history": []
      }
    }
  },
  "collection": {
    "heroes": {
      "240065": {
        "owned": true,
        "firstObtainedAt": "2026-05-22T00:00:00+08:00",
        "copies": 1,
        "skins": [24006500]
      }
    }
  },
  "showcase": {
    "homeHeroId": 240065,
    "homeSkinId": 24006500
  }
}
```

## 9. 单机最小闭环

推荐先实现一个资源驱动的轻量闭环：

```text
启动
  -> 加载 gacha-static JSON/CSV
  -> 主界面显示看板娘和入口
  -> 抽卡页显示卡池、消耗、概率入口、十连按钮
  -> 离线 DrawService 生成结果
  -> 结果页展示稀有度、角色名、立绘/Spine key
  -> 写入本地 save.json
  -> 图鉴页读取 collection 展示已获得角色
  -> 角色展示页加载 halfIcon 或 Spine
```

MVP 必须优先支持：

- 卡池列表：普通、高级、进阶、限定角色池。
- 单抽和十连。
- 结果页：新角色、高稀有高亮、重复转碎片或 copies。
- 图鉴：按 rare 排序、未获得灰显。
- 角色展示：先用 `halfIcon/recruitImg` 静态图，Spine 作为增强。
- 本地存档：货币、抽卡历史、保底计数、已获得角色。

## 10. 未完成风险

还需要补齐：

- YooAsset manifest 二进制字段顺序。当前 `parse-yoo-manifest.js` 解析 `Default_1001.1774870195.cht.bytes` 会越界，阻塞 `assetPath -> bundleName` 自动映射。
- 更多 Spine 样本的实际导出验证。现已验证 `hero_003Dh`，还需验证 `hero_001/005/016/017`。
- UI prefab 的 MonoBehaviour 字段结构。当前仅定位 prefab 路径，还没有解析 prefab 内绑定的按钮、特效和结果卡格字段。
- `LotteryDrawHelper.ShowLotteryAnimation` 的动画名、跳过动画逻辑和结果展示参数。
- 原始概率字段。Static 表有 `reward1/reward2/reward3/reward4/rewardF2/cnt*`，但 reward id 到真实概率/掉落表还需继续追 `reward` 表或协议展示字段。
