# Game Systems Backlog

Use this as the reverse and reimplementation checklist.

Status values:

- `unknown`: not analyzed yet.
- `candidate`: suspected from names/assets.
- `confirmed`: verified from code/assets/runtime.
- `ported`: implemented in Godot.
- `tested`: covered by tests or runtime verification.

## Boot and App Flow

| System | Status | Evidence | Godot target |
| --- | --- | --- | --- |
| Game startup | confirmed | `RuntimeInitializeOnLoads.json`: `GameManager.OnGameStart` | `GameApp` |
| Highscore service startup | confirmed | `RuntimeInitializeOnLoads.json`: `HighscoreService.OnGameStart` | service or omitted |
| Scene loading | unknown | Need IL2CPP dump and Unity scene export | `SceneRouter` |
| Loading screen | unknown | Need asset export | `scenes/boot` |

## Core Gameplay

| System | Status | Evidence | Godot target |
| --- | --- | --- | --- |
| Merge board/grid | ported | IL2CPP classes: `InGame_MapManager`, `InGame_BlockManager`, `InGame_ItemCell`, `MapSaveData`; prototype in `godot-project/scripts/models/merge_board_model.gd` | `MergeBoardModel` |
| Item instances | ported | IL2CPP classes use `Block` and `ItemBlock`: `InGame_ItemBlock`, `MapBlockData`, `ProduceBlockData`; prototype block ids in `godot-project/data/blocks.json` | `ItemInstance`/`BlockInstance` |
| Merge chains | ported | `Table_Block.dat` decoded into `godot-project/data/blocks.json`: 74 non-currency chains, 541 blocks | `MergeRuleResolver` |
| Item generators | ported | `ProduceBlockData`, `ProduceBlockSaveData`, `FabricateBlockMapData`; decoded `block_rules.json` includes 117 producer blocks, 23 cooldown groups | `SpawnerModel` |
| Board blockers/obstacles | candidate | `BubbleBlockData`, `BoxBlockSaveData`, map cell type data | board cell modifiers |
| Energy or stamina | ported | `UserSaveDataMetaInfo.ap`, `ProduceBlockData.produceEnergy`; prototype AP wallet and spawn cost | `EconomyModel` |
| Timers/cooldowns | ported, runtime semantics pending | first-pass cooldown groups decoded into `block_rules.json`; exact refill/open behavior still needs Ghidra | timer service |
| Tutorial | unknown | Need classes/assets | tutorial state machine |

## Progression

| System | Status | Evidence | Godot target |
| --- | --- | --- | --- |
| Player level | unknown | Need code/data | `ProgressionModel` |
| Tasks/orders | candidate | `UIInGame/Request/RequestList` and reward slots confirmed in UI layout; `RequestDataManager` and request tables still need decoding | `TaskModel` |
| Chapter/story progression | unknown | Need scenes/assets/localization | `StoryModel` |
| Unlock conditions | unknown | Need config | `UnlockResolver` |
| Highscore/leaderboard | candidate | `HighscoreService.OnGameStart` | `HighscoreService` or no-op |

## Economy and Monetization

| System | Status | Evidence | Godot target |
| --- | --- | --- | --- |
| Soft currency | unknown | Need code/data | `WalletModel` |
| Premium currency | unknown | Need code/data | `WalletModel` |
| Rewarded ads | candidate | Many ad SDKs | `AdsService` |
| Interstitial ads | candidate | Many ad SDKs | `AdsService` |
| IAP products | confirmed integration, unknown products | Billing and Unity IAP present | `IapService` |
| Daily rewards | unknown | Need code/data | reward system |
| Offline rewards | unknown | Need code/data | reward system |

## Content and Presentation

| System | Status | Evidence | Godot target |
| --- | --- | --- | --- |
| Localization | confirmed | Addressables localization bundles for EN, JA, KO, ZH-TW | Godot translations |
| Maid/NPC catalog | confirmed | `Table_Npc`, `NpcTableData`, `MaidInfoTableData`; assets include `Ch_Maid01`-`Ch_Maid07` | `NpcCatalog`, `MaidCatalog` |
| Maid profiles | confirmed | `MaidInfoTableData` fields include member, tribe, height, birthday, age, CV, favorite/hate, skill and gift preferences | `MaidProfileModel` |
| Maid levels and skills | confirmed | `MaidLevelTableData`, `MaidSkillTableData`, `GetMaidLevelTableData_ToLv`, `GetMaidSkillData` | `MaidProgressionModel`, `MaidSkillModel` |
| Maid costumes/skins | confirmed | `ShopNpcCostumeTableData`; assets include `Cos_Maid01`-`Cos_Maid07` with seasonal variants | `CostumeCatalog`, `SkinResolver` |
| Maid chat / AI chat | confirmed | `Table_MaidChat`, `Table_MaidAIChat`, `MaidChatTableData`, `MaidAIChatTableData` | `MaidChatModel` |
| Customer/NPC catalog | confirmed | `CustomerTableData`; assets include `Ch_Customer01`-`Ch_Customer15` | `CustomerCatalog` |
| Customer episodes | confirmed | `Table_CustomerEpisode`, `CustomerEpisodeData`, `CustomerLikeLevelData` | `CustomerEpisodeModel` |
| NPC dialog | confirmed | `InGameNpcDialog` with multilingual text and audio fields | `DialogCatalog`, `DialogRunner` |
| Spine animation | candidate | `spine-csharp`, `spine-unity` assemblies | Spine runtime or conversion |
| Static UI layout | confirmed | 1,137 UI prefabs and 84,034 `RectTransform` records from AssetRipper export | `UiLayoutReference`, Godot scene templates |
| Startup UI flow | candidate | `Reload` scene, `Game` scene, `UIManager`, `UISceneLoading`, `UIMaidLobbyLoading`, `UIOutGame` prefabs | `BootFlow`, loading/lobby screens |
| UI particles | confirmed dependency | `Coffee.UIParticle` | Godot particles or simplified FX |
| Soft masks | confirmed dependency | `Coffee.SoftMaskForUGUI` | Godot clipping/masks |
| Toony materials | confirmed dependency | `ToonyColorsPro.Runtime` | Godot materials/shaders |
| Audio | unknown | Need asset extraction | `AudioManager` |

## Save and Backend

| System | Status | Evidence | Godot target |
| --- | --- | --- | --- |
| Local save | ported | Many `UserSaveData` subclasses, `EncryptedPlayerPrefs`, manager keys like `mapdata`, `blockdata`; prototype JSON save at `user://prototype-save.json` | `SaveManager` |
| Cloud save | candidate | Firebase/Google Play present, verify usage | `CloudSaveService` |
| Analytics | confirmed integration | Firebase/GameAnalytics/Singular | `AnalyticsService` |
| Push notifications | confirmed integration, unknown usage | FCM and notification permissions | `NotificationService` |
| Remote config | unknown | Need code/network strings | config service |

## Analysis Tasks

1. Dump IL2CPP symbols and dummy assemblies.
2. Search recovered `Assembly-CSharp` for `GameManager`.
3. Search recovered `Assembly-CSharp` for item, merge, board, order, reward, save, shop, ad, IAP, tutorial names.
4. Export Unity assets and identify ScriptableObject/TextAsset configuration files.
5. Build a table of item IDs, names, icons, merge results, and spawn sources.
6. Build a save schema from code or runtime files.
7. Implement a minimal Godot board model and verify merge rules against recovered data.
