# IL2CPP Code Map

This document records the first IL2CPP dump and the initial gameplay code map.

## Dump Run

Tool:

- `tools/Il2CppDumper/Il2CppDumper.exe`
- Version: v6.7.46

Inputs:

- `resources/lib/arm64-v8a/libil2cpp.so`
- `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`

Output:

- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/`

Generated files:

- `dump.cs`
- `il2cpp.h`
- `script.json`
- `stringliteral.json`
- `DummyDll/*.dll`
- `analysis/class-index.csv`
- `analysis/gameplay-class-index.csv`
- `analysis/keyword-counts.csv`

Notes:

- Il2CppDumper printed `ERROR: This file may be protected.`
- It still found:
  - `CodeRegistration : 5829ea8`
  - `MetadataRegistration : 5a54cf0`
- Dump, struct generation, and dummy DLL generation completed.
- Final nonzero exit came from `Press any key to exit` in a redirected console, not from dump failure.

## Index Summary

Initial index counts:

- Type declarations extracted from `dump.cs`: 17,435
- Type declarations matching gameplay/system keywords: 3,888
- Largest dummy DLL: `Assembly-CSharp.dll`, about 4.3 MB

High-signal keyword hits:

| Keyword | Hits | Class hits |
| --- | ---: | ---: |
| `Item` | 15023 | 495 |
| `Quest` | 5778 | 454 |
| `Request` | 4961 | 374 |
| `Reward` | 4432 | 198 |
| `Block` | 4249 | 238 |
| `Task` | 3885 | 110 |
| `Map` | 3418 | 188 |
| `Maid` | 3192 | 267 |
| `Memory` | 1553 | 127 |
| `Level` | 1498 | 79 |
| `Tutorial` | 1462 | 130 |
| `Merge` | 585 | 34 |
| `Board` | 513 | 46 |
| `Shop` | 557 | 111 |
| `Save` | 777 | 89 |

## Core Gameplay Classes

The game appears to use `Block` terminology for merge-board items.

High-priority classes:

| Class | TypeDefIndex | Role hypothesis |
| --- | ---: | --- |
| `GameManager` | unknown from first filtered pass | Global game state and boot flow |
| `GameStep` | 129 | Runtime step enum: `Loading`, `InGame`, `OutGame`, `Story` |
| `InGame_ItemBlock` | 284 | Board item/block behavior |
| `InGame_ItemCell` | 296 | Board cell behavior |
| `InGame_BlockManager` | 301 | Board block lifecycle and merge logic candidate |
| `InGame_DragManager` | 310 | Drag/drop and item use flow |
| `InGame_MapManager` | 321 | In-game map/board manager |
| `InGame_RequestManager` | 327 | Runtime request/order handling |
| `InGameConfigManager` | 359 | In-game config loading |
| `MapDataManager` | 446 | Saved board/map/block state manager |
| `RequestDataManager` | 523 | Request/order persistent data manager |
| `RewardDataManager` | 537 | Reward persistent data manager |
| `ShopDataManager` | 574 | Shop state and purchases |
| `TableDataManager` | 660 | Static table loading root candidate |
| `UserDataManager` | 687 | User save root candidate |

## Save Data Classes

Important save structures found:

| Class | TypeDefIndex | Key fields |
| --- | ---: | --- |
| `UserSaveData` | 121 | Abstract base for user save data |
| `UserSaveDataMetaInfo` | 223 | `lv`, `exp`, `ap`, `gold`, `jewel`, `saveTime` |
| `MapSaveData` | 423 | `IsInitBlock`, `MapCellDatas`, `MapCellTypeDatas`, `CrashCount` |
| `BlockSaveData` | 426 | unique IDs, unlocked blocks, map block dictionaries |
| `ProduceBlockSaveData` | 429 | produce/grow/fabricate block dictionaries |
| `CollectionSaveData` | 435 | block/furniture/customer/echo archive collections |
| `BubbleBlockSaveData` | 440 | timed bubble block data |
| `BoxBlockSaveData` | 442 | selected box block data |
| `RequestSaveData` | 488 | request/order save data |
| `RequestCompleteSaveData` | 493 | completed request data |
| `RewardBlockSaveData` | 532 | reward block save data |
| `MaidSaveData` | 465 | maid list, active maid ids, gifts |
| `UserTutorialSaveData` | 667 | tutorial save root |
| `UserItemData` | 672 | item inventory/user item data |

## Board and Block Data

Key board-related structures:

- `MapCellData`
  - `xPos`
  - `yPos`
  - `mapCellType`
  - `value`
- `MapBlockData`
- `ProduceBlockData`
  - `uniqueID`
  - `mapID`
  - `xPos`
  - `yPos`
  - `blockId`
  - `produceEnergy`
- `FabricateBlockMapData`
- `FabricateInitBlockData`
- `GrowProduceBlockMapData`
- `BlockCollectionData`
- `BubbleBlockData`
  - `mapType`
  - `mapID`
  - `xPos`
  - `yPos`
  - `blockId`
  - `startTime`

This strongly suggests the Godot board model should separate:

- Cell grid state.
- Block instances.
- Produce/generator blocks.
- Fabricate blocks.
- Bubble/timed blocks.
- Collection/unlock state.

## Economy and Reward Classes

Confirmed enums/classes:

- `RewardType`
- `CurrencyType`
- `MaidCoinType`
- `RewardBoxType`
- `RewardCommonInfo`
- `RewardInfo`
- `RewardManager.RewardInfo`
- `Effect_Reward*`
- `RewardDataManager`
- `ServerRewardSaveData`
- `LocalRewardData`
- `CouponRewardSaveData`
- `FriendRewardSaveData`
- `InGameRewardData`

Known player meta currencies from `UserSaveDataMetaInfo`:

- `ap`
- `gold`
- `jewel`
- `exp`
- `lv`

## Request/Order System

The game uses `Request` terminology, likely equivalent to orders/tasks.

Important classes:

- `RequestType`
- `RequestGroupType`
- `RequestState`
- `RequestItemData`
- `RequestNpcData`
- `RequestSaveData`
- `RequestTotalData`
- `RequestRewardPointSaveData`
- `RequestData`
- `RequestDormitoryData`
- `RequestCompleteSaveData`
- `RequestCompleteData`
- `RequestTimeData`
- `RequestGroupData`
- `RequestMainPointData`
- `RequestDataManager`
- `InGame_RequestManager`

## Content and Meta Systems

Important managers:

- `LocalizeManager`
- `LocalizeTableDataManager`
- `Table_Language`
- `LevelConfigManager`
- `ShopConfigManager`
- `StoryDataManager`
- `StoryTableDataManager`
- `DailyDataManager`
- `AlbumDataManager`
- `EchoArchiveDataManager`
- `HighKujiDataManager`
- `LevelPassDataManager`
- `MemoryCardManager`
- `MiniGameDataManager`
- `NpcDataManager`
- `OutGameDataManager`
- `PhotoCardDataManager`
- `VideoBonusDataManager`

## Godot Implications

Initial Godot modules should be:

- `BlockCatalog`
- `MergeBoardModel`
- `BoardCell`
- `BlockInstance`
- `BlockGeneratorModel`
- `RequestModel`
- `RewardModel`
- `WalletModel`
- `SaveManager`
- `LocalizationManager`
- `ShopModel`
- `TutorialModel`

Use original names in comments or mapping tables, but keep Godot gameplay code clean and data-driven.

## Next Analysis Targets

1. Extract method lists for:
   - `InGame_BlockManager`
   - `InGame_ItemBlock`
   - `InGame_DragManager`
   - `MapDataManager`
   - `RequestDataManager`
   - `RewardDataManager`
   - `UserDataManager`
   - `TableDataManager`
2. Extract enum values for:
   - `BlockType`
   - `ItemType`
   - `MapType`
   - `RewardType`
   - `CurrencyType`
   - `RequestType`
   - `MissionQuestType`
3. Locate static table classes and serialized table assets.
4. Run asset extraction and map table assets to these classes.
