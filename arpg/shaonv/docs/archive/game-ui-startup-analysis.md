# 游戏界面与启动顺序分析

分析对象：Android APK 反编译目录与 Unity IL2CPP dump。

> 目录纠偏：本文中的 Unity IL2CPP dump 路径来自相邻目录 `../merge/reverse-output`，只能作为参考。`shaonv` 本目录当前确认拥有 `resources/lib/arm64-v8a/libil2cpp.so` 和 `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`，后续应重新导出本目录专用 dump 后复核。详见 `docs/analysis-scope-correction.md`。

- Android 壳：`resources/AndroidManifest.xml`
- Unity IL2CPP dump：`../merge/reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/dump.cs`
- 资源索引：`../merge/reverse-output/assets/assetstudio-cli-inventory.csv`

注意：IL2CPP dump 只保留类型、字段、方法签名，方法体为空；启动顺序与界面归类基于类名、字段、方法名、Manifest 与资源名推断。

## Android 启动入口

- 包名：`com.and.gt.snhl`
- 版本：`versionName="1.18"`，`versionCode="19"`
- 主 Activity：`com.daiei.monv.UnityPlayerActivity`
- 启动 Intent：`android.intent.action.MAIN` + `android.intent.category.LAUNCHER`
- 屏幕方向：`userLandscape`
- Unity 标记：`unityplayer.UnityActivity=true`

Android 启动链路：

1. 系统启动 `com.daiei.monv.UnityPlayerActivity`。
2. UnityPlayer 加载 Unity runtime、原生库与资源。
3. Unity 场景初始化游戏单例和 UI 根节点。
4. 进入游戏 Loading / 登录 / 数据加载流程。
5. 根据玩家状态进入 `OutGame` 大厅、`InGame` 玩法、或 `Story` 剧情。

## Unity 主状态

`GameStep` 定义了游戏 UI 的顶层状态：

- `Loading = 0`
- `InGame = 1`
- `OutGame = 2`
- `Story = 3`

相关核心类：

- `GameManager`
- `GamePlayManager`
- `ResourceManager`
- `TableDataManager`
- `UserDataManager`
- `OutGameManager`
- `InGame_BlockManager`
- `InGame_MapManager`
- `InGame_RequestManager`
- `PlatformLoginManager`
- `UIManager`
- `UIPopupManager`
- `TutorialManager`

## 推断启动顺序

1. Android 启动 `UnityPlayerActivity`。
2. Unity runtime 初始化并加载初始场景。
3. 游戏管理器初始化：配置、资源、表数据、用户数据、音频、事件、通知等。
4. `UIManager.Initialize()` 初始化 UI 根节点、Canvas、相机、安全区、弹窗管理器、Loading。
5. `UIManager.LoadInit()` 预载或绑定运行期 UI 资源。
6. `PlatformLoginManager.CheckPlatformLogin()` 检查平台登录、Google、Apple、Facebook 账号状态。
7. `UILoading` 显示加载图、进度和文案。
8. 数据加载完成后根据状态进入：
   - `UIOutGame` / `UILobby`：大厅与经营外层。
   - `UIInGame`：合成棋盘和关卡内界面。
   - `UIPopup_Story` / cutscene UI：剧情界面。
9. 场景或大状态切换时走：
   - `UIManager.StartSceneMoveLoading()`
   - `SceneLoadingPrev()`
   - `SceneLoadingFinish()`
   - `UISceneLoading`

## UI 管理层

`UIManager` 主要字段显示 UI 被分成以下根节点：

- `UIOutGame uiOutGame`
- `UILobby uiLobby`
- `UIInGame uiInGame`
- `UIGlobal uiGlobal`
- `UIPopupManager uiPopupManager`
- `UILoading uiLoading`
- `UISceneLoading uiSceneLoading`
- `UIUseItemBlock uiUseItemBlock`
- `UIInGameBG uiInGameBG`

`UIManager` 关键方法：

- `Initialize()`
- `LoadInit()`
- `SetUI(GameStep _gameStep)`
- `StartSceneMoveLoading(Action _finish)`
- `ShowUI(bool _isShow, bool isDirect, bool isLobby, Action onEndCallback)`
- `ShowTouchCover(bool _isShow)`
- `PlayBuildAnimFade(bool _isShow, Action onEndCallback)`
- `PlayBlackFadeLoading(Action event01, Action end)`
- `PlayMaidLobbyLoading(bool toOutGame)`

## 主要 UI 根界面

这些类更像完整页面、主界面或常驻 UI，而不是列表项：

- `UIGlobal`
- `UILoading`
- `UISceneLoading`
- `UIOutGame`
- `UILobby`
- `UILobbyBtn`
- `UILobbyItem`
- `UILobby_CollectibleBtn`
- `UILobby_MaidNoteBtn`
- `UIMaidLobby`
- `UIMaidLD`
- `UIInGame`
- `UIInGameBG`
- `UIInGameBag`
- `UIInGameSubMap`
- `UIInGameSubMap_Event`
- `UIInGameSubMap_EchoArchive`
- `UIInGame_EchoArchive_Fabricate`
- `UIInGame_SchoolUniform`
- `UIInventory`
- `UIRequestInfo`
- `UIBlockInfo`
- `UIFabricateInfo`
- `UISkillInfo`
- `UISurpriseBoxInfo`
- `UIUseItemBlock`
- `UINpcDialog`
- `UIVillageReBuild`
- `UIUserInfo`
- `UIUserProfile`
- `UIMaidInfo`
- `UIMaidLevelInfo`
- `UIMaidReward`
- `UIMaidChat`
- `UIMaidChatRoom`
- `UIMaidChatSelectBtn`
- `UIMaidAIChat`
- `UIMaidAIChatCreateView`
- `UIMaidAIChatListView`
- `UIMaidAIChatRoomView`
- `UIMaidAIChatMemoryArchive`
- `UIMemoryCardGallery`
- `UIPhotoCardInfo`
- `UICostumeInfo`
- `UIMaidNote_Album`
- `UIMaidNote_Collection`
- `UIMaidNote_Customer`
- `UIMaidNote_Remodeling`
- `UIMaidNote_StoryReplay`
- `UIMaidNote_TeamFormation`

## 主要弹窗界面

以下为 `UIPopup_*` 类型，基本代表独立弹窗、活动页、商店页或覆盖式大界面。

### 通用与系统

- `UIPopup_Loading`
- `UIPopup_NetworkError`
- `UIPopup_GeneralNotify`
- `UIPopup_SelectBox`
- `UIPopup_Option`
- `UIPopup_Language`
- `UIPopup_GameClose`
- `UIPopup_GameAccount`
- `UIPopup_GameAccountChange`
- `UIPopup_GameData`
- `UIPopup_GameDataLoad`
- `UIPopup_GameDataSelect`
- `UIPopup_DeleteAccount`
- `UIPopup_ContactUs`
- `UIPopup_UpdateNotify`
- `UIPopup_VersionNotify`
- `UIPopup_Debug`
- `UIPopup_Debug_PW`
- `UIPopup_Status`
- `UIPopup_LoadSaveFile`

### 账号、平台与用户提示

- `UIPopup_BlockUser`
- `UIPopup_CautionUser`
- `UIPopup_SaveCampaign`
- `UIPopup_RateReview`
- `UIPopup_Survey`
- `UIPopup_Attention_Abandon`
- `UIPopup_Attention_Sell`

### 大厅、角色、顾客

- `UIPopup_UserProfile`
- `UIPopup_CafeNameChange`
- `UIPopup_MaidNote`
- `UIPopup_MaidSelect`
- `UIPopup_MaidLobbySelect`
- `UIPopup_MaidCouponSelect`
- `UIPopup_MaidLevelUp`
- `UIPopup_NewMaid`
- `UIPopup_NewNpc`
- `UIPopup_CustomerInfo`
- `UIPopup_CustomerChat`
- `UIPopup_CustomerStory`
- `UIPopup_CustomerEpisodeGuide`

### 背包、道具、合成

- `UIPopup_Inventory`
- `UIPopup_InventoryBM`
- `UIPopup_BlockInfo`
- `UIPopup_BlockDetailInfo`
- `UIPopup_ItemDetailInfo`
- `UIPopup_ItemUseCopy`
- `UIPopup_ItemUseJoker`
- `UIPopup_ItemUseSplit`
- `UIPopup_ProduceBlockInfo`
- `UIPopup_FabricateBlockInfo`
- `UIPopup_FabricateProduct_BlockInfo`
- `UIPopup_SeriouslyMerge`
- `UIPopup_SeriouslyMergeInfo`
- `UIPopup_SeriouslyMergeGuide`
- `UIPopup_NeedleBlockInfo`
- `UIPopup_LikeAbilityBlockInfo`

### 任务、奖励、进度

- `UIPopup_QuestInfoList`
- `UIPopup_RequestGroupInfo`
- `UIPopup_RequestMainPointInfo`
- `UIPopup_RoomQuestInfo`
- `UIPopup_DormitoryQuest`
- `UIPopup_DormitoryChoice`
- `UIPopup_DormitoryGuide`
- `UIPopup_WorkLog`
- `UIPopup_WorkLog_GetDouble`
- `UIPopup_DailyMission`
- `UIPopup_AttendanceDaily`
- `UIPopup_LevelUp`
- `UIPopup_RewardGetNormal`
- `UIPopup_RewardGetPhotoCard`
- `UIPopup_RewardGetMaidCoin`
- `UIPopup_RewardGetMaidRelationship`
- `UIPopup_RewardGetUserProfile`
- `UIPopup_RewardGet_InGameRes`
- `UIPopup_RewardGet_CardPack`
- `UIPopup_RewardGet_Costume`
- `UIPopup_Reward_CustomerCoupon`
- `UIPopup_SubMapEnd_RewardGet`

### 商店、付费、礼包

- `UIPopup_Shop`
- `UIPopup_BuyPurchase`
- `UIPopup_Energy`
- `UIPopup_AddLinePack`
- `UIPopup_AddLineUnlock`
- `UIPopup_AdsRemovePackage`
- `UIPopup_NormalPackage`
- `UIPopup_StartPackage`
- `UIPopup_SpecialBlockPackage`
- `UIPopup_BenefitMorePackage`
- `UIPopup_BenefitSalePackage`
- `UIPopup_EnergyPackage`
- `UIPopup_GemJarPackage`
- `UIPopup_GemJarProgress`
- `UIPopup_DuckTube`
- `UIPopup_GoldenWorm`
- `UIPopup_RoulettePackage`
- `UIPopup_SpecialAttendancePackage`
- `UIPopup_WhiteDayPackage`

### 活动、赛季、小游戏

- `UIPopup_EventStart`
- `UIPopup_EventEnd`
- `UIPopup_EventPreStart`
- `UIPopup_EventBand`
- `UIPopup_EventBandGuide`
- `UIPopup_EventBingo`
- `UIPopup_EventBingoGuide`
- `UIPopup_EventBingoRewardInfo`
- `UIPopup_EventCartoon`
- `UIPopup_EventCumulativeQuest`
- `UIPopup_EventHouse`
- `UIPopup_EventMatch3d`
- `UIPopup_EventMatchCard`
- `UIPopup_EventMatchCardGuide`
- `UIPopup_EventMateRace`
- `UIPopup_EventMateRaceGuide`
- `UIPopup_EventOcean`
- `UIPopup_EventPudding`
- `UIPopup_EventPuddingGuide`
- `UIPopup_EventSpring`
- `UIPopup_EventWinter`
- `UIPopup_EventTreasureSand`
- `UIPopup_EventWhiteDay`
- `UIPopup_EventWhiteDayGuide`
- `UIPopup_Event_CardPack`
- `UIPopup_Event_Fishing`
- `UIPopup_Event_FishingConfirm`
- `UIPopup_Event_Spring_01`
- `UIPopup_Event_SummerFestivalShop`
- `UIPopup_Event_PC_BloodWorm`
- `UIPopup_Event_PC_PuddingJump`
- `UIPopup_Event_PC_VendingMachine`
- `UIPopup_Event_PointCollectGuide`
- `UIPopup_EventSchoolUniform_Guide`
- `UIPopup_EventSummerFestivalGuide`
- `UIPopup_EventSurpriseBox`
- `UIPopup_EventSurpriseBoxGuide`
- `UIPopup_EventFindEvidenceGuide`
- `UIPopup_EventFishingGuide`
- `UIPopup_MiniGameAlways_BloodWorm`
- `UIPopup_MiniGameAlways_PuddingJump`
- `UIPopup_MiniGameAlways_VendingMachine`
- `UIPopup_MiniGameEvent_BloodWorm`
- `UIPopup_MiniGameEvent_PuddingJump`
- `UIPopup_MiniGameEvent_VendingMachine`
- `UIPopup_MiniGame_Revival`
- `UIPopup_MinigameGuide`
- `UIPopup_MissionPass`
- `UIPopup_MissionPassBase`
- `UIPopup_MissionPassClose_PassCheck`
- `UIPopup_MissionPassClose_RewardGet`
- `UIPopup_MissionPassPurchase`
- `UIPopup_MissionPassQuestComplete`
- `UIPopup_CompleteMissionPass`
- `UIPopup_SeasonPass_Christmas_2025`
- `UIPopup_SeasonPass_Halloween_2025`
- `UIPopup_SeasonPass_Summer_2025`
- `UIPopup_SeasonPass_Preview`
- `UIPopup_SeasonPass_Purchase_Christmas_2025`
- `UIPopup_SeasonPass_Purchase_Halloween_2025`
- `UIPopup_SeasonPass_Purchase_Summer_2025`
- `UIPopup_SeasonPassGuide_Christmas_2025`
- `UIPopup_SeasonPassGuide_Halloween_2025`
- `UIPopup_SeasonPassGuide_Summer_2025`

### 卡牌、抽奖、记忆

- `UIPopup_MemoryCardShop`
- `UIPopup_MemoryCardBoard`
- `UIPopup_MemoryCardInfo`
- `UIPopup_MemoryCardInfo_CardShop`
- `UIPopup_MemoryCardProbability`
- `UIPopup_MemoryCard_BuyTickets`
- `UIPopup_MemoryCard_GachaResult`
- `UIPopup_MemoryTicketExchangeShop`
- `UIPopup_Memory_GetEffect`
- `UIPopup_MemoryStart`
- `UIPopup_HighKuji`
- `UIPopup_HighKuji_Parent`
- `UIPopup_HighKuji_RatePopup`
- `UIPopup_Roulette_Parent`
- `UIPopup_CardPackInfo`
- `UIPopup_GetCardPackTicket`
- `UIPopup_BingoRegister`

### 剧情、图鉴、相册

- `UIPopup_Story`
- `UIPopup_InGameCutScene`
- `UIPopup_CartoonView`
- `UIPopup_CartoonPackage`
- `UIPopup_AlbumDetail`
- `UIPopup_PhotoCardDetail`
- `UIPopup_Collectible`
- `UIPopup_EchoArchive_SelectEpisode`
- `UIPopup_EchoArchiveGuide_Fabricate`
- `UIPopup_DesignedBoxOpen`
- `UIPopup_DiaryWriteConfirm`
- `UIPopup_CouponEnter`
- `UIPopup_DecoItemInfo`

### AI 与聊天

- `UIPopup_AIChatbotGuide`
- `UIPopup_MaidAIChatADItem`
- `UIPopup_MaidAIChatAIDisclosure`
- `UIPopup_MaidAIChatEndingImageGenerate`
- `UIPopup_MaidAIChatNetworkError`
- `UIPopup_MaidAIChatReport`
- `UIPopup_MaidAIChatServerCheck`
- `UIPopup_MaidChatNotice`
- `UIPopup_MaidChatSkip`
- `UIPopup_MasterHeartCharge`
- `UIPopup_MasterHeartChatEndingResult`

### 其他

- `UIPopup_AlarmSetting`
- `UIPopup_BandPackage`
- `UIPopup_CardPackInfo`
- `UIPopup_CartoonPackage`
- `UIPopup_BuildLoading`
- `UIPopup_MoreGames`
- `UIPopup_Notice`
- `UIPopup_NoticeContent`
- `UIPopup_PassClose`
- `UIPopup_ReNamePreset`
- `UIPopup_RequestComplete_Ads`
- `UIPopup_Unlock`
- `UIPopup_UnlockBtn`
- `UIPopup_UnlockNewFurniture`
- `UIPopup_VideoBonus`
- `UIPopup_VillageBuild`

## 教程界面

`UITutorial_*` 类型代表新手引导或功能教程：

- `UITutorial_ApRecharge`
- `UITutorial_AutoProduce`
- `UITutorial_BlockInfo`
- `UITutorial_BlockInfo_B`
- `UITutorial_BlockInfo_Fabricate`
- `UITutorial_BlockInfo_New`
- `UITutorial_BubbleBlock`
- `UITutorial_Collection`
- `UITutorial_Costume`
- `UITutorial_CustomerEpisode`
- `UITutorial_CustomerInfo`
- `UITutorial_Dormitory`
- `UITutorial_EchoArchive`
- `UITutorial_InGame`
- `UITutorial_InGameRes`
- `UITutorial_InGameTeamFormation`
- `UITutorial_Inventory`
- `UITutorial_LevelPass`
- `UITutorial_MaidAIChat`
- `UITutorial_MaidAlbum`
- `UITutorial_MaidChat`
- `UITutorial_MaidGift`
- `UITutorial_MaidGiftInfo`
- `UITutorial_MaidLobby`
- `UITutorial_MaidNote`
- `UITutorial_MaidSkill`
- `UITutorial_MaidTeamFormation`
- `UITutorial_MemoryCardCollection`
- `UITutorial_MemoryCardShop`
- `UITutorial_Merge`
- `UITutorial_Merge_A`
- `UITutorial_Merge_FindBlock`
- `UITutorial_MultipleQuest`
- `UITutorial_NewEvent`
- `UITutorial_Produce`
- `UITutorial_QuestInfoCheck`
- `UITutorial_RandomRequest`
- `UITutorial_Remodeling`
- `UITutorial_Remodeling_02`
- `UITutorial_Request_OutGame`
- `UITutorial_Request_OutGame_A`
- `UITutorial_RequestComplete_GroupQuest`
- `UITutorial_RequestComplete_New`
- `UITutorial_RequestComplete_Quest`
- `UITutorial_ResetCoolTime`
- `UITutorial_RewardBlock`
- `UITutorial_RewardRandomBlock`
- `UITutorial_SchoolUniform`
- `UITutorial_SellBlock`
- `UITutorial_SeriouslyMerge`
- `UITutorial_Shop`
- `UITutorial_StoryReplay`
- `UITutorial_TreasureSand`
- `UITutorial_UserProfile`
- `UITutorial_WorkLog`

## Android SDK 界面

Manifest 中还注册了大量非 Unity 游戏主 UI 的 Activity，主要来自登录、支付、广告、WebView SDK：

- Facebook：`com.facebook.FacebookActivity`, `com.facebook.CustomTabActivity`, `com.facebook.CustomTabMainActivity`
- QuickGame 登录/用户/支付：`AgreementActivity`, `DMAOptionActivity`, `DMAOptionUserCenterActivity`, `CheckThirdLoginBindActivity`, `CheckActivity`, `FreeLoginActivity`, `EmailCodeLoginActivity`, `HWLoginActivity`, `SwitchAccountActivity`, `GoogleBillingV5Activity`, `GoogleBillingV4Activity`, `GuestTipsAfterPayActivity`, `UserCenterActivity`, `ChangePwdActivity`, `NoticeActivity`, `BindEmailActivity`, `ThirdBindHelpActivity`, `GoogleLoginActivity`, `TTLoginActivity`, `PlayGameLoginActivity`, `FacebookLoginActivity`
- Web：`com.quickgame.android.sdk.activity.WebActivity`, `com.vuplex.webview.HelperActivity`
- 广告 SDK：ByteDance / Pangle、Mintegral、IronSource、Google Ads 等落地页、激励视频、全屏广告 Activity。

这些 Activity 是 SDK 外壳界面，通常不属于 Unity 内部 UI 树，但会在登录、付费、广告、网页公告等流程中覆盖游戏画面。

## 资源线索

资源索引中发现与界面相关的素材命名：

- Loading：`Image_Loading`, `Loading_maid_2`, `LoadingIcon64`, `Album_*_Loading`
- 大厅：`InLobby`, `OutLobby`
- 游戏内背景：`BG_Ingame_*`, `InGameSkin_*`
- 弹窗皮肤：`Popup_Window`, `Popup_Window2`, `Popup_Window3`, `Popup_Window4`, `Popup_WindowNoTilte`, `Popup_Back`, `Popup_X`
- 活动弹窗素材：`2025SummerPopup_*`, `2025XmasPopup_*`, `202508BandPopUp_*`, `20260301EventPopup_*`
- 教程素材：`Tutorial_Suitcase_01`

## 后续可继续确认的点

- 从 Unity prefab / MonoBehaviour dump 中反查每个 `UIPopup_*` 对应的资源路径。
- 从 AssetBundle 地址或 YooAsset 清单中还原 UI prefab 加载名。
- 对 `GameManager`、`GamePlayManager`、`OutGameManager`、`UIManager` 的原生地址做更深层反汇编，确认真实方法调用顺序。
- 结合运行截图或抓帧，把 UI 类名映射为实际游戏画面名称。
