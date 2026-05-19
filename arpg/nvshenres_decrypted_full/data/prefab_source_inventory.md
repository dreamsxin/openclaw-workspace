# Prefab Source Inventory

该文件由 `tools/export_prefab_source_inventory.py` 生成，用于手工还原界面前确认 prefab 资源、源码入口和文档线索。

## 统计

- `prefabs.csv` 中 prefab 总数：1018
- 源码 `assets/main/index.js` 直接引用的 prefab：492
- 现有文档已提到的 prefab：129
- 源码引用但 `prefabs.csv` 未收录的 prefab：5

## 分类数量

- `ActivityPanel`：120
- `HerolhPrefab`：93
- `HeroPrefab`：90
- `SkyCityPanel`：60
- `Guild`：53
- `JingjiPrefab`：43
- `Battle`：30
- `HeroPanel`：30
- `MaoxianPanel`：28
- `mapprefabs`：24
- `UserInfo`：23
- `comPrefab`：22
- `yjTreasure`：22
- `ForgePanel`：19
- `ShiLuoFanePanel`：18
- `guajiPanel`：16
- `pvpActivityPanel`：15
- `BagPanel`：14
- `HeroActivityPanel`：14
- `Welfare`：14
- `longComing`：14
- `HeroPalace`：13
- `TreasurePanel`：12
- `CombatPrefab`：11
- `DrawCard`：9
- `HeroTeachPre`：8
- `TaskPanel`：8
- `TeachPlace`：8
- `ZhiYeTower`：8
- `rank`：8
- `stssActivityPrefab`：8
- `HeroListPanel`：7
- `HeroXZPrefab`：7
- `RechargePanel`：7
- `RewordPanel`：7
- `Chat`：6
- `MozhuPanel`：6
- `WarPathPanel`：6
- `WarReport`：6
- `WarcraftPanel`：6
- `bigImage`：6
- `binglongPanel`：6
- `guide`：6
- `PassPrefab`：5
- `StarPlanPanel`：5
- `payPanel`：5
- `FindTreasurePanel`：4
- `Shop`：4
- `SkinShopPanel`：4
- `XQkaifu`：4
- `loading`：4
- `ElevatePanel`：3
- `FriendPanel`：3
- `FuWen`：3
- `HeroLhPanel`：3
- `alert`：3
- `login`：3
- `mainpanel`：3
- `zhanbu`：3
- `(root)`：2
- `ActivityForecastPanel`：2
- `EmailPanel`：2
- `GetGoldPanel`：2
- `Gift`：2
- `Help`：2
- `KuafuPvpPane`：2
- `OnlineRewordPanel`：2
- `WelfareDayPanel`：2
- `fangchenmi`：2
- `CreateRolePanel`：1
- `DailyGift`：1
- `FirstRechargePanel`：1
- `HeroDetailPanel`：1
- `NewHeroEffectPanel`：1
- `ResDebug`：1
- `RolePanel`：1
- `TalkPanel`：1

## 源码高频入口

| 次数 | 分类 | Prefab | 源码模块 | Import |
| ---: | --- | --- | --- | --- |
| 6 | `Battle` | `Prefab/Battle/BattleEndPre` | `BattleEndPanel, BattleWinType34Panel, BattleWinType35Panel, BattleWinType36Panel` | `assets/resources/import/9c/9c31f823-981f-4d07-a852-2256cc3640b1.json` |
| 5 | `HeroListPanel` | `Prefab/HeroListPanel/HeroBookItemPre` | `DrawMainPanel, HeroListPanel, HeroPalaceHeroDecomposePanel, HeroPalaceHeroShardDecomposePanel` | `assets/resources/import/9f/9f15c7db-035a-4205-bdb1-b48ec09bfb14.json` |
| 4 | `binglongPanel` | `Prefab/binglongPanel/BingLongGuidePre` | `BingLongGuidePanel, CombatguidePanel, TreasureShGuidePanel, oldgodGuidePanel` | `assets/resources/import/f2/f2ac8e55-5b73-4225-a558-f0ec751b3fa2.json` |
| 3 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceSynthesizePre` | `HeroPalacePanel, HeroPalaceSynrthesizePanel` | `assets/resources/import/9d/9df2eb14-2607-49ca-ad2f-ea63bece0160.json` |
| 3 | `mapprefabs` | `Prefab/mapprefabs/` | `BattleMap, guajiMapPanel, longFightReadyPanel` | `` |
| 2 | `Battle` | `Prefab/Battle/BattleJJCEndPre` | `BattleJJCEndPanel, BattleTianTiEndPanel` | `assets/resources/import/7f/7f8bdeeb-0707-412c-9103-91b3958fe015.json` |
| 2 | `Battle` | `Prefab/Battle/BattleRtPre` | `BattleMap, BattleRtPanel` | `assets/resources/import/98/9808cde4-a2f0-433a-a076-30729d2d5ccd.json` |
| 2 | `CombatPrefab` | `Prefab/CombatPrefab/combatJiBanPre` | `CombatJiBanPanel, CombatMainPanel` | `assets/resources/import/ae/ae109de8-9894-42bf-8a6a-82d0f813330a.json` |
| 2 | `DrawCard` | `Prefab/DrawCard/HeroShowPre` | `DrawMainPanel, HeroShowPanel` | `assets/resources/import/58/584e5be5-74d9-44e2-a237-1b1a6fa769a4.json` |
| 2 | `DrawCard` | `Prefab/DrawCard/drawCardPre` | `DrawMainPanel, MainUIPanel` | `assets/resources/import/4a/4adda260-915f-4845-a57c-64d7201e7eb1.json` |
| 2 | `ForgePanel` | `Prefab/ForgePanel/ForgeWarspiritGridPre` | `ForgeWarspiritPanel, WarPathPanel` | `assets/resources/import/02/0272fe4b-cd3a-4c21-a3fb-6f3b0367d856.json` |
| 2 | `ForgePanel` | `Prefab/ForgePanel/forgeRuneSelectTogglepre` | `ForgeRuneSelectPanel, ForgeSelectEquipSynthesisPanel` | `assets/resources/import/b7/b74a5556-d949-42f3-b2ec-00a079ea24a9.json` |
| 2 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceHeroDecomposePre` | `HeroPalaceHeroDecomposePanel, HeroPalacePanel` | `assets/resources/import/15/153f7311-9ac0-4554-958b-3e0930ce7bb7.json` |
| 2 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceHeroShardDecomposePre` | `HeroPalaceHeroShardDecomposePanel, HeroPalacePanel` | `assets/resources/import/97/9791ebe1-9bee-4902-94dd-752877dc739d.json` |
| 2 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceReplacementPre` | `HeroPalacePanel, HeroPalaceReplacementPanel` | `assets/resources/import/e8/e849f34b-1fc0-46c5-8ee8-ad97f4ab20cb.json` |
| 2 | `HeroPalace` | `Prefab/HeroPalace/HeroPaleceGoBackPre` | `HeroPalaceGoBackPanel, HeroPalacePanel` | `assets/resources/import/c7/c7cb8bfb-3d22-4fa9-8fe7-65ef90176552.json` |
| 2 | `HeroPalace` | `Prefab/HeroPalace/HeroPaleceRebirthPre` | `HeroPalacePanel, HeroPalaceRebirthPanel` | `assets/resources/import/11/11f0823c-56d1-49cf-a93b-1be88c98c939.json` |
| 2 | `HeroPanel` | `Prefab/HeroPanel/HeroBookDetailPre` | `HeroBookDetailPanel, HeroListPanel` | `assets/resources/import/90/901e5e08-d65e-418f-86ba-cd667c2f696b.json` |
| 2 | `HeroPanel` | `Prefab/HeroPanel/HeroBreakthroughPre` | `HeroBreakthroughPanel, HeroUpLvPanel` | `assets/resources/import/fe/fe765a30-1144-4277-bbb8-d24a8f88232c.json` |
| 2 | `HeroPanel` | `Prefab/HeroPanel/HeroGetNewSkillsPre` | `HeroGetNewSkillsPanel, HeroUpLvPanel` | `assets/resources/import/c6/c657a168-4d30-4502-9070-9b1ab425fc15.json` |
| 2 | `HeroPanel` | `Prefab/HeroPanel/HeroMainPre` | `HeroListPanel, HeroMainPanel` | `assets/resources/import/37/37a0a496-56d5-4322-8429-99ca7eeca5fb.json` |
| 2 | `MaoxianPanel` | `Prefab/MaoxianPanel/supportItemPre` | `FriendsSupportPanel, JWSYSupportPanel` | `assets/resources/import/56/569d71d4-6d0b-4eea-a8ce-05b54e07bc6d.json` |
| 2 | `Shop` | `Prefab/Shop/ShopBuyEquitPre` | `ShopBuyActivityPanel, ShopBuyEquitPanel` | `assets/resources/import/8c/8cc638a8-3fea-4b85-929b-ec5975c7b0d4.json` |
| 2 | `SkinShopPanel` | `Prefab/SkinShopPanel/SkinShowPre` | `HeroMainPanel, SkinShowPanel` | `assets/resources/import/57/57b66bc3-cdf7-45dd-a287-c1053ca5f5fa.json` |
| 2 | `StarPlanPanel` | `Prefab/StarPlanPanel/StarPlanSelectHeroPre` | `NewHeroActivityStarPlanSelectHeroPanel, StarPlanSelectHeroPanel` | `assets/resources/import/4b/4b97298c-cc9d-4452-912f-d545d0f7f436.json` |
| 2 | `TeachPlace` | `Prefab/TeachPlace/TeachPanel` | `TeachListPanel, TeachPanel` | `assets/resources/import/e3/e39c4831-5f0a-4a1e-be94-00b911c34cee.json` |
| 2 | `UserInfo` | `Prefab/UserInfo/UserInfoChangeNamePre` | `GuildNoticePanel, UserInfoChangeNamePanel` | `assets/resources/import/4b/4bcb396b-6aef-4d5a-afbd-f17cec58c267.json` |
| 2 | `alert` | `Prefab/alert/AlertPre` | `AlertPanel, DisconnectPanel` | `assets/resources/import/4f/4f9d8499-09cc-4462-a3e4-6a8892f8037a.json` |
| 2 | `fangchenmi` | `Prefab/fangchenmi/registeredPre` | `RealNamePanel, registeredPanel` | `assets/resources/import/09/09342f5c-0448-4971-a74a-e130f70b7ecc.json` |
| 1 | `ActivityForecastPanel` | `Prefab/ActivityForecastPanel/ActivityForecastPre` | `ActivityForecastPanel` | `assets/resources/import/c1/c1b0b182-4941-4683-af78-bb868a2605b3.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/ActivityGridPreviewPre` | `ActivityGridPreviewPanel` | `assets/resources/import/e6/e66f3573-a6cc-48f0-8c2a-cf93a3cd08b8.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/ActivityPre` | `ActivityPanel` | `assets/resources/import/4f/4fef39b3-cc9a-4c86-b745-be672e46c0ac.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/CycleActivity/CycleActivityPre` | `CycleActivityPanel` | `assets/resources/import/e5/e506770c-e1bb-42af-be5e-26e49b0bb0a9.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre` | `DrawCardActivityPanel` | `assets/resources/import/10/10a6e173-6611-48ba-b723-5489225d0076.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/HefuActivity/HefuActivityPre` | `HefuActivityPanel` | `assets/resources/import/f1/f1f7df95-d49a-4c56-90c4-a21b41c4d8a8.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/HefuActivity/HefuRewardPre` | `HefuActivityPanel` | `assets/resources/import/94/9432c84c-9b6a-41b9-a1ec-9c566bc8b3c7.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/JuHuiActivity/JuHuiActivityPre` | `JuHuiActivityPanel` | `assets/resources/import/68/68253f07-0cd9-4c6b-9310-7fc058b02b96.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/12007` | `NewHeroActivity12007Panel` | `assets/resources/import/69/69681972-d9fa-4de1-82ae-4a7dff791531.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/12008` | `NewHeroActivity12008Panel` | `assets/resources/import/08/08f58c31-3fca-47c9-b605-20c31ce2af28.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/NewHeroActivityChangeHeroPre` | `NewHeroActivityChangeHeroPanel` | `assets/resources/import/ed/ed6572d9-f272-4eec-977c-f51e0c724853.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/NewHeroActivityPre` | `NewHeroActivityPanel` | `assets/resources/import/f3/f3e99ddd-f2de-4a2a-ae96-de4d848d95b0.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroComing/NewHeroComingBaoXiangBLPre` | `NewHeroComingBaoXiangBLPanel` | `assets/resources/import/18/18ff4584-f0a9-405f-8c16-271a8aafc275.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroComing/NewHeroComingPre` | `NewHeroComingPanel` | `assets/resources/import/ac/ac043719-2542-4782-8b1c-5a3d9915774f.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/PreRegAvtivity/PreRegAvtivityPre` | `PreRegActivityPanel` | `assets/resources/import/54/54c12ba0-4473-445c-af9b-cd3083b4700b.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/YueChuActivity/YueChuActivityPre` | `YueChuActivityPanel` | `assets/resources/import/74/74d856f7-11b2-4992-87c8-a27e579c671d.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/YueChuActivity/YueChuRewardPre` | `YueChuActivityPanel` | `assets/resources/import/2f/2f1ee853-dbca-4e71-a932-ae48a819a1e2.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/ZhaoHuanActivity/ZhaoHuanActivityPre` | `ZhaoHuanActivityPanel` | `assets/resources/import/85/85b352d2-8601-4618-8b02-653a6913b8a1.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/blindboxactivity/BlindBoxPre` | `BlindBoxPanel` | `assets/resources/import/d6/d679a815-b873-42ab-93a1-5cc778428464.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/blindboxactivity/BlindBoxRewardPre` | `BlindBoxRewardPanel` | `assets/resources/import/1f/1ff77779-f119-462d-9f8e-8219bc7d95e0.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/changzhuactivity/ActivityFirstRechargePre` | `ActivityPanel` | `assets/resources/import/64/6485935d-5cbf-40cc-950a-60288213bd91.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/changzhuactivity/ActivityWangKaRewordPreviewPre` | `ActivityWangKaRewordPreviewPre` | `assets/resources/import/5b/5bb1d1c5-ec40-49cb-9648-b3a33e575b23.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/discordActivity/discordActivityPre` | `DiscordActivityPanel` | `assets/resources/import/81/818b3b4e-2b26-427e-be2f-fb03a1e05bbd.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingActivity` | `guoqingPre` | `assets/resources/import/7d/7d47195b-a08c-496e-8372-08137853385f.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingGetGiftPre` | `GuoqingGetGiftPre` | `assets/resources/import/58/5838be30-185e-4ceb-a99f-59bf289367b0.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingTaskPerPre` | `GuoqingTaskPerPrePanel` | `assets/resources/import/c0/c0fac440-256f-43ac-96a1-3f952af2d43d.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingTaskPre` | `GuoqingTaskPrePanel` | `assets/resources/import/2f/2fe6c67f-3a13-42a5-ad08-bb25306b3c4c.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/OrderGiftPre` | `OrderGiftPanel` | `assets/resources/import/de/de1a96af-5cb5-4d11-975d-2ad972bdec21.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/hitworkactivity/HitWorkPre` | `hitworkPre` | `assets/resources/import/b9/b933b7b8-23f1-4779-90cc-e6da4e9baa1f.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/hitworkactivity/buyworkpre` | `buyworkpre` | `assets/resources/import/44/44576dc9-ad4d-4d77-9791-05ded021a86c.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/jueduiactivity/TeHuiDetailPre` | `TeHuiDetailPanel` | `assets/resources/import/a4/a48aa0f2-953c-499d-812d-71d8ba8b8617.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/kaifuactivity/ActivityLevelGiftItem` | `WelfarePanel` | `assets/resources/import/2a/2a90191b-e7c5-46c8-88a6-8f78e853d9df.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/kaifuactivity/ActivityLevelGiftPre` | `WelfarePanel` | `assets/resources/import/15/157f5221-331a-4a13-b3a5-48150e4bb760.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/kaifuactivity/ActivityQiTianPre` | `ActivityPanel` | `assets/resources/import/90/908b6b40-b6ed-4a26-aad2-24952435f402.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/shengdanactivity/ShengDanActivity` | `ShengDanPanel` | `assets/resources/import/63/636828e0-73a9-4077-8154-8ce9ea8930df.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardActivityPre` | `ThousandDrawCardActivityPanel` | `assets/resources/import/51/512f5b54-2969-4bf1-9b7c-3096df3ce86b.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardDetailPre` | `ThousandDrawCardDetailPanel` | `assets/resources/import/de/de5d1fd1-aff9-4047-afa3-c3308a4d111c.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardRankPre` | `ThousandDrawCardRankPanel` | `assets/resources/import/5c/5cb99f45-bd03-41fd-ad49-c0eee8ef1d2b.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardSavePre` | `ThousandDrawCardSavePanel` | `assets/resources/import/e0/e0778a6a-69bf-47f2-83ef-5c798545289e.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/xinchunActivity/XinChunActivityPre` | `XinChunActivityPanel` | `assets/resources/import/ba/ba563827-3f98-4ed9-8050-16b8bf910bb7.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/xinchunActivity/XinChunGetGiftPre` | `XinChunGetGiftPanel` | `assets/resources/import/d0/d05a1295-4c5c-43ab-8939-d363f6e773a6.json` |
| 1 | `ActivityPanel` | `Prefab/ActivityPanel/yuanxiaoactivity/YuanxiaoActivity` | `YuanxiaoPanel` | `assets/resources/import/ac/acc432b7-dbc5-4cb1-930e-b929f2c1138e.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/BagPre` | `BagPanel` | `assets/resources/import/99/99dbedd1-111a-4a08-8ebc-cb26362081f5.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/BagSellEquipPre` | `BagSellEquipPanel` | `assets/resources/import/00/0016d26d-601e-47af-991b-257e45d01d39.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/GridBoxPre` | `GridBoxPanel` | `assets/resources/import/04/04dc3428-7c34-43ed-8071-9b55cfdc2cb0.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/GridTipsPre` | `ItemGridTip` | `assets/resources/import/d7/d76a0801-75fb-4d7b-99d8-b6041ba32838.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/HeroEquipTipsPre` | `EquipTip` | `assets/resources/import/9f/9fb9632d-9078-499c-96be-b3e1274cbab2.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/HeroShuiJingTipsPre` | `ShuiJingTip` | `assets/resources/import/a6/a66d64a3-de98-4c67-aa95-2d6182b1a319.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/buyGridPre` | `buyGridPanel` | `assets/resources/import/43/434f284f-48c5-4fb7-8fa7-1c0a2bba3c76.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/fuwenTipsPre` | `FuwenTip` | `assets/resources/import/b1/b192e48f-9e5c-460b-9701-59b92217e015.json` |
| 1 | `BagPanel` | `Prefab/BagPanel/hechengTipsPre` | `HechengPanel` | `assets/resources/import/64/642c3741-bc5b-44a2-8bdc-50dde120bbc6.json` |

## 已知还原候选

| 源码 | 文档 | 分类 | Prefab | 入口模块 |
| ---: | ---: | --- | --- | --- |
| 6 | 0 | `Battle` | `Prefab/Battle/BattleEndPre` | `BattleEndPanel, BattleWinType34Panel, BattleWinType35Panel, BattleWinType36Panel` |
| 5 | 0 | `HeroListPanel` | `Prefab/HeroListPanel/HeroBookItemPre` | `DrawMainPanel, HeroListPanel, HeroPalaceHeroDecomposePanel, HeroPalaceHeroShardDecomposePanel` |
| 4 | 0 | `binglongPanel` | `Prefab/binglongPanel/BingLongGuidePre` | `BingLongGuidePanel, CombatguidePanel, TreasureShGuidePanel, oldgodGuidePanel` |
| 3 | 0 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceSynthesizePre` | `HeroPalacePanel, HeroPalaceSynrthesizePanel` |
| 3 | 0 | `mapprefabs` | `Prefab/mapprefabs/` | `BattleMap, guajiMapPanel, longFightReadyPanel` |
| 2 | 10 | `HeroPanel` | `Prefab/HeroPanel/HeroMainPre` | `HeroListPanel, HeroMainPanel` |
| 2 | 7 | `DrawCard` | `Prefab/DrawCard/drawCardPre` | `DrawMainPanel, MainUIPanel` |
| 2 | 2 | `HeroPanel` | `Prefab/HeroPanel/HeroBookDetailPre` | `HeroBookDetailPanel, HeroListPanel` |
| 2 | 1 | `DrawCard` | `Prefab/DrawCard/HeroShowPre` | `DrawMainPanel, HeroShowPanel` |
| 2 | 0 | `Battle` | `Prefab/Battle/BattleJJCEndPre` | `BattleJJCEndPanel, BattleTianTiEndPanel` |
| 2 | 0 | `Battle` | `Prefab/Battle/BattleRtPre` | `BattleMap, BattleRtPanel` |
| 2 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatJiBanPre` | `CombatJiBanPanel, CombatMainPanel` |
| 2 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeWarspiritGridPre` | `ForgeWarspiritPanel, WarPathPanel` |
| 2 | 0 | `ForgePanel` | `Prefab/ForgePanel/forgeRuneSelectTogglepre` | `ForgeRuneSelectPanel, ForgeSelectEquipSynthesisPanel` |
| 2 | 0 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceHeroDecomposePre` | `HeroPalaceHeroDecomposePanel, HeroPalacePanel` |
| 2 | 0 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceHeroShardDecomposePre` | `HeroPalaceHeroShardDecomposePanel, HeroPalacePanel` |
| 2 | 0 | `HeroPalace` | `Prefab/HeroPalace/HeroPalaceReplacementPre` | `HeroPalacePanel, HeroPalaceReplacementPanel` |
| 2 | 0 | `HeroPalace` | `Prefab/HeroPalace/HeroPaleceGoBackPre` | `HeroPalaceGoBackPanel, HeroPalacePanel` |
| 2 | 0 | `HeroPalace` | `Prefab/HeroPalace/HeroPaleceRebirthPre` | `HeroPalacePanel, HeroPalaceRebirthPanel` |
| 2 | 0 | `HeroPanel` | `Prefab/HeroPanel/HeroBreakthroughPre` | `HeroBreakthroughPanel, HeroUpLvPanel` |
| 2 | 0 | `HeroPanel` | `Prefab/HeroPanel/HeroGetNewSkillsPre` | `HeroGetNewSkillsPanel, HeroUpLvPanel` |
| 2 | 0 | `MaoxianPanel` | `Prefab/MaoxianPanel/supportItemPre` | `FriendsSupportPanel, JWSYSupportPanel` |
| 2 | 0 | `Shop` | `Prefab/Shop/ShopBuyEquitPre` | `ShopBuyActivityPanel, ShopBuyEquitPanel` |
| 2 | 0 | `SkinShopPanel` | `Prefab/SkinShopPanel/SkinShowPre` | `HeroMainPanel, SkinShowPanel` |
| 2 | 0 | `StarPlanPanel` | `Prefab/StarPlanPanel/StarPlanSelectHeroPre` | `NewHeroActivityStarPlanSelectHeroPanel, StarPlanSelectHeroPanel` |
| 2 | 0 | `TeachPlace` | `Prefab/TeachPlace/TeachPanel` | `TeachListPanel, TeachPanel` |
| 2 | 0 | `UserInfo` | `Prefab/UserInfo/UserInfoChangeNamePre` | `GuildNoticePanel, UserInfoChangeNamePanel` |
| 2 | 0 | `alert` | `Prefab/alert/AlertPre` | `AlertPanel, DisconnectPanel` |
| 2 | 0 | `fangchenmi` | `Prefab/fangchenmi/registeredPre` | `RealNamePanel, registeredPanel` |
| 1 | 22 | `HerolhPrefab` | `Prefab/HerolhPrefab/` | `DrawMainPanel` |
| 1 | 11 | `mainpanel` | `Prefab/mainpanel/MainPre` | `MainUIPanel` |
| 1 | 9 | `login` | `Prefab/login/pfLoginPanelPre` | `PFLoginPanel` |
| 1 | 8 | `login` | `Prefab/login/LoginPre` | `LoginPanel` |
| 1 | 7 | `HeroListPanel` | `Prefab/HeroListPanel/HeroListPre` | `HeroListPanel` |
| 1 | 6 | `Shop` | `Prefab/Shop/ShopPre` | `ShopPanel` |
| 1 | 4 | `ActivityPanel` | `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre` | `DrawCardActivityPanel` |
| 1 | 4 | `BagPanel` | `Prefab/BagPanel/BagPre` | `BagPanel` |
| 1 | 4 | `loading` | `Prefab/loading/LoadingPre` | `LoadingPanelNode` |
| 1 | 4 | `loading` | `Prefab/loading/loadingProgress` | `loadingProgressPanel` |
| 1 | 3 | `Guild` | `Prefab/Guild/GuildMainPre` | `GuildMainPanel` |
| 1 | 3 | `JingjiPrefab` | `Prefab/JingjiPrefab/JingjiPre` | `JingjiPanel` |
| 1 | 3 | `SkyCityPanel` | `Prefab/SkyCityPanel/SkyCityPre` | `SkyCityPanel` |
| 1 | 3 | `mainpanel` | `Prefab/mainpanel/daohangPre` | `DaohangPanel` |
| 1 | 1 | `HeroPrefab` | `Prefab/HeroPrefab/` | `DrawMainPanel` |
| 1 | 0 | `ActivityForecastPanel` | `Prefab/ActivityForecastPanel/ActivityForecastPre` | `ActivityForecastPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/ActivityGridPreviewPre` | `ActivityGridPreviewPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/ActivityPre` | `ActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/CycleActivity/CycleActivityPre` | `CycleActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/HefuActivity/HefuActivityPre` | `HefuActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/HefuActivity/HefuRewardPre` | `HefuActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/JuHuiActivity/JuHuiActivityPre` | `JuHuiActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/12007` | `NewHeroActivity12007Panel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/12008` | `NewHeroActivity12008Panel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/NewHeroActivityChangeHeroPre` | `NewHeroActivityChangeHeroPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroActivity/NewHeroActivityPre` | `NewHeroActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroComing/NewHeroComingBaoXiangBLPre` | `NewHeroComingBaoXiangBLPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/NewHeroComing/NewHeroComingPre` | `NewHeroComingPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/PreRegAvtivity/PreRegAvtivityPre` | `PreRegActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/YueChuActivity/YueChuActivityPre` | `YueChuActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/YueChuActivity/YueChuRewardPre` | `YueChuActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/ZhaoHuanActivity/ZhaoHuanActivityPre` | `ZhaoHuanActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/blindboxactivity/BlindBoxPre` | `BlindBoxPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/blindboxactivity/BlindBoxRewardPre` | `BlindBoxRewardPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/changzhuactivity/ActivityFirstRechargePre` | `ActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/changzhuactivity/ActivityWangKaRewordPreviewPre` | `ActivityWangKaRewordPreviewPre` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/discordActivity/discordActivityPre` | `DiscordActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingActivity` | `guoqingPre` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingGetGiftPre` | `GuoqingGetGiftPre` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingTaskPerPre` | `GuoqingTaskPerPrePanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/GuoqingTaskPre` | `GuoqingTaskPrePanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/guoqingactivity/OrderGiftPre` | `OrderGiftPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/hitworkactivity/HitWorkPre` | `hitworkPre` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/hitworkactivity/buyworkpre` | `buyworkpre` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/jueduiactivity/TeHuiDetailPre` | `TeHuiDetailPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/kaifuactivity/ActivityLevelGiftItem` | `WelfarePanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/kaifuactivity/ActivityLevelGiftPre` | `WelfarePanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/kaifuactivity/ActivityQiTianPre` | `ActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/shengdanactivity/ShengDanActivity` | `ShengDanPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardActivityPre` | `ThousandDrawCardActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardDetailPre` | `ThousandDrawCardDetailPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardRankPre` | `ThousandDrawCardRankPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/thousandDrawCardActivity/ThousandDrawCardSavePre` | `ThousandDrawCardSavePanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/xinchunActivity/XinChunActivityPre` | `XinChunActivityPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/xinchunActivity/XinChunGetGiftPre` | `XinChunGetGiftPanel` |
| 1 | 0 | `ActivityPanel` | `Prefab/ActivityPanel/yuanxiaoactivity/YuanxiaoActivity` | `YuanxiaoPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/BagSellEquipPre` | `BagSellEquipPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/GridBoxPre` | `GridBoxPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/GridTipsPre` | `ItemGridTip` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/HeroEquipTipsPre` | `EquipTip` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/HeroShuiJingTipsPre` | `ShuiJingTip` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/buyGridPre` | `buyGridPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/fuwenTipsPre` | `FuwenTip` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/hechengTipsPre` | `HechengPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/huoquTipsPre` | `ToobtainWayPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/piliangTipsPre` | `UseItemPanel` |
| 1 | 0 | `BagPanel` | `Prefab/BagPanel/sellGridPre` | `SellGridPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleBuffTipPre` | `BattleBuffTipPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleGuildEndPre` | `BattleGuildEndPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleJJCzhanshenEndPre` | `BattleJJCzhanshenEndPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleJiBanPre` | `BattleJiBanPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleTongjiPre` | `BattleTongjiPane` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinCommonPre` | `BattleWinCommonPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType14Pre` | `BattleWinType14Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType20Pre` | `BattleWinType20Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType23Pre` | `BattleWinType23Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType24Pre` | `BattleWinType24Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType28Pre` | `BattleWinType28Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType29Pre` | `BattleWinType29Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/BattleWinType7Pre` | `BattleWinType7Panel` |
| 1 | 0 | `Battle` | `Prefab/Battle/ChuZhanEffect` | `CombatMainPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/battleBuffAllPre` | `battleBuffAllPanel` |
| 1 | 0 | `Battle` | `Prefab/Battle/battleMapEnterEffect` | `UIManager` |
| 1 | 0 | `Chat` | `Prefab/Chat/ChatMainItemPre` | `MainUIPanel` |
| 1 | 0 | `Chat` | `Prefab/Chat/ChatPanelPre` | `ChatPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/CombatFormPre` | `CombatFormPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatPanel` | `CombatMainPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatRingDetailPre` | `CombatRingDetailPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatRingItemPre` | `CombatRingDetailPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatTaskItemPre` | `CombatTaskPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatTaskPre` | `CombatTaskPanel` |
| 1 | 0 | `CombatPrefab` | `Prefab/CombatPrefab/combatTypeItemPre` | `CombatMainPanel` |
| 1 | 0 | `CreateRolePanel` | `Prefab/CreateRolePanel/CreateRolePre` | `CreateRolePanel` |
| 1 | 0 | `DailyGift` | `Prefab/DailyGift/DailyGiftPre` | `DailyGiftPanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/DrawRewardPreviewPre` | `DrawRewardPreviewPanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/ExchangePre` | `ExchangePanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/HeroChangePre` | `HeroChangePanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/ProphetExchangePre` | `ProphetExchangePanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/crystallizationPrefab` | `ProphetExchangePanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/drawScorePre` | `DrawScoreMainPanel` |
| 1 | 0 | `DrawCard` | `Prefab/DrawCard/essencePrefab` | `ProphetExchangePanel` |
| 1 | 0 | `ElevatePanel` | `Prefab/ElevatePanel/ElevatePre` | `ElevatePanel` |
| 1 | 0 | `EmailPanel` | `Prefab/EmailPanel/EmailPre` | `EmailPanel` |
| 1 | 0 | `FindTreasurePanel` | `Prefab/FindTreasurePanel/FindTreasurePre` | `FindTreasurePanel` |
| 1 | 0 | `FindTreasurePanel` | `Prefab/FindTreasurePanel/FindTreasureTipPre` | `FindTreasureTipPanel` |
| 1 | 0 | `FindTreasurePanel` | `Prefab/FindTreasurePanel/ZhuFuPre` | `ZhuFuPanel` |
| 1 | 0 | `FirstRechargePanel` | `Prefab/FirstRechargePanel/firstRechargePre` | `firstRechargePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeEquipDecomposePre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeEquipResetPre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeEquipSynthesisPre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeEquipSynthesisQueryPre` | `ForgeEquipSynthesisQueryPanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeEquipSynthesisRecordPre` | `ForgeEquipSynthesisRecordPanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgePre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeRuneRefinePre` | `ForgeRuneRefinePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeRuneSelectPanel` | `ForgeRuneSelectPanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeRuneSynthesisPre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeSelectEquipSynthesis` | `ForgeSelectEquipSynthesisPanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeShenQiDecomposePre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeShenQiSynthesisPre` | `ForgePanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/ForgeWarspiritPanel` | `ForgeWarspiritPanel` |
| 1 | 0 | `ForgePanel` | `Prefab/ForgePanel/LingliRewardPre` | `LingliRewardPanel` |
| 1 | 0 | `FriendPanel` | `Prefab/FriendPanel/AddFriendPanel` | `AddFriendPanel` |
| 1 | 0 | `FriendPanel` | `Prefab/FriendPanel/FriendPanel` | `FriendPanel` |
| 1 | 0 | `FuWen` | `Prefab/FuWen/FuwenRefreshPre` | `FuwenRefreshPanel` |
| 1 | 0 | `FuWen` | `Prefab/FuWen/SelectFuwenItemPre` | `SelectFuwenPanel` |
| 1 | 0 | `FuWen` | `Prefab/FuWen/SelectFuwenPre` | `SelectFuwenPanel` |
| 1 | 0 | `GetGoldPanel` | `Prefab/GetGoldPanel/GetGoldPanel` | `GetGoldPanel` |
| 1 | 0 | `Gift` | `Prefab/Gift/GiftPre` | `GiftPanel` |
| 1 | 0 | `Guild` | `Prefab/Guild/GuildBoss/GuildBossHeadPre` | `GuildBossPanel` |
| 1 | 0 | `Guild` | `Prefab/Guild/GuildBoss/GuildBossPre` | `GuildBossPanel` |
| 1 | 0 | `Guild` | `Prefab/Guild/GuildBoss/GuildBossRankPre` | `GuildBossRankPanel` |

## 源码引用但未在 prefabs.csv 找到

| 次数 | Prefab | 源码模块 |
| ---: | --- | --- |
| 3 | `Prefab/mapprefabs/` | `BattleMap, guajiMapPanel, longFightReadyPanel` |
| 1 | `Prefab/HeroPrefab/` | `DrawMainPanel` |
| 1 | `Prefab/HerolhPrefab/` | `DrawMainPanel` |
| 1 | `Prefab/WarcraftPanel/WarcraftActivePre` | `WarcreaftActivePanel` |
| 1 | `Prefab/WarcraftPanel/WarcraftPre` | `WarcraftPanel` |

