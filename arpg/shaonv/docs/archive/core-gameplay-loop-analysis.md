# 单机版核心玩法循环分析

目标：基于反编译类型、字段和方法签名，整理可复刻的单机版核心玩法：启动、存档、棋盘、合成、生产、订单、奖励。

> 目录纠偏：本文早期引用了 `../merge/reverse-output` 中的相邻目录导出结果。后续实现必须以 `D:\work\openclaw-workspace\arpg\shaonv` 本目录重新导出的 IL2CPP dump 和资源清单为准。详见 `docs/analysis-scope-correction.md`。

## 核心结论

原游戏的核心循环是合成经营：

1. 玩家进入大厅或主房间。
2. 打开合成棋盘。
3. 棋盘中存在普通方块、生产器、锁格、泡泡块、特殊块。
4. 玩家拖拽相同方块合成更高级方块。
5. 生产器消耗能量或冷却后产出方块。
6. 订单请求指定方块，提交后给金币、资源、点数、剧情或进度奖励。
7. 方块、地图、订单、资源、角色、教程等状态写入本地或云存档。

## 使用过的命令

```powershell
rg -n "class (InGame_BlockManager|InGame_MapManager|InGame_RequestManager|RequestDataManager|MapDataManager|UserDataManager)|OnBlockMerge|NewProduceBlock|CompleteRequest|SaveData" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

```powershell
Get-Content ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs -Encoding UTF8 | Select-Object -Skip 8990 -First 380
```

```powershell
Get-Content ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs -Encoding UTF8 | Select-Object -Skip 16895 -First 340
```

```powershell
rg -n "class (User.*Data|.*SaveData|BlockSlotData|ProduceBlockData|RequestData|RequestItemData|Map.*Data|InGame.*Data)" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

## 运行时核心类

### InGame_BlockManager

职责：管理棋盘上的方块对象、合成、生产、出售、背包、匹配检测。

重要字段：

- `Select_ItemBlock`
- `Move_ProduceBlockData`
- `itemBlocks`
- `itemBlockIds_Main`
- `itemBlockIds_MapType`
- `SellBlockTableData`
- `SellBlockGoldValue`
- `sellProduceEnergy`
- `sellBlockUniqueID`
- `matchCheckItemBlocks`
- `matchRequestBlockList`
- `randBoxDropInfoProbList`
- `IsPossibleUseItem`
- `IsPossibleMerge`
- `IsPossibleProduce`
- `NewBlockId`
- `dropPossibleProduceBlockDatas`
- `produceBlockTDataList`
- `currentProduceBlockTDataList`

重要方法：

- `Initialize()`
- `OnInit()`
- `AddBlockItem(InGame_ItemBlock itemBlock)`
- `RemoveBlockItem(InGame_ItemBlock itemBlock)`
- `OnBlockMerge(BlockTableData mergeBlockTData, Vector2Int blockPos, int uniqueID, bool isUseJoker = False, bool isDormitory = False)`
- `OnMergeNewAddBlock(int blockId, Vector2Int cellPos)`
- `OnMergeDropBlock(int blockId, Vector2Int cellPos)`
- `OnBlockSplit(...)`
- `OnMergeBubbleBlock(int blockId, Vector2Int cellPos)`
- `OnNewProduceBlock(InGame_ItemBlock produceBlock, bool isAuto, bool isBag = False, bool isUseEnergy = True)`
- `OnNewGrowProduceBlock(InGame_ItemBlock produceBlock)`
- `OnNewFabricateProduce(InGame_ItemBlock produceBlock)`
- `OnNewProduceRandBox(InGame_ItemBlock produceBlock)`
- `OnNewProduceDesignedBox(InGame_ItemBlock produceBlock)`
- `OnMatchCompleteBlock(...)`
- `SellBlock()`
- `RecycleBlock()`
- `RestoreBlock()`
- `PutInInventory_BlockSlot(...)`
- `PutInInventory_ProduceBlockSlot(...)`
- `PullOutInventory(...)`
- `IsEqualBlock(...)`
- `IsItemBlock(...)`
- `IsCurrencyBlock(...)`
- `MatchBlockCount(...)`
- `GetDropPossibleProduceBlock(BlockTableData blockTData)`
- `GetRandomBlockItems(...)`
- `SetProduceBlockTDatas_MergeLastLevel(string groupName)`

单机版最小实现：

- 棋盘方块列表。
- 拖拽交换或移动。
- 相同 `GroupName + Level` 合成到下一等级。
- 生产器点击产出方块。
- 出售方块获得金币。
- 提交订单消耗方块。

### InGame_MapManager

职责：地图/棋盘格、方块生成、锁格、不同地图类型。

重要方法线索：

- `NewMergeBlock(...)`
- `NewProduceBlock(...)`
- `NewItemBlock(...)`
- `NewNeedBlock(...)`
- `NewLockBlock(...)`
- `NewAddBlock(...)`
- `NewExpendAlterBlock(...)`

相关存档：

- `MapSaveData`
- `MapCellData`
- `MapCellTypeData`
- `BlockSaveData`
- `MapBlockData`
- `ProduceBlockSaveData`
- `ProduceBlockData`

单机版最小实现：

- 固定棋盘尺寸，例如 7x9 或从 `MapCellTypeData.MapSizeX/Y` 读取。
- 每格存 `cellType`、锁定状态、当前方块 uniqueID。
- 初始方块从配置或手写初始数据生成。
- 锁格第一版可简化为不可用格，后续再支持解锁条件。

### RequestDataManager

职责：订单生成、订单完成、随机订单、紧急订单、宿舍订单、主线点数。

存档 key：

- `PATH_REQUEST_SAVE_DATA = "requestSaveData"`
- `KEY_REQUEST_DATA = "requestdata"`
- `KEY_REQUEST_REWARDPOINT_DATA = "requestrewardpointdata"`
- `KEY_REQUEST_COMPLETE_DATA = "requestcompletedata"`
- `KEY_REQUEST_TIME_DATA = "requesttimedata"`

重要方法：

- `Load(Action complete)`
- `OnCompleteLoad()`
- `CheckRequestTableData()`
- `CheckRequestDataRenewal()`
- `NewRequestMainRoom(...)`
- `NewRequestRandom(...)`
- `NewRequestUrgent(int targetBlockID)`
- `NewRequestDormitory(...)`
- `NewRequestMainPoint(...)`
- `NewRequestEvent(...)`
- `CompleteRequest_Id(int id)`
- `CheckUrgentQuest(...)`
- `RemoveUrgentQuest(int requestID)`
- `RemoveRandomQuest(int requestID, bool isRemoveRequest = False)`
- `AddCompletRequest(RequestData requestData)`
- `GetRequestRandomBlock(...)`
- `RandomBlockWeight(...)`
- `FilterBlockByLevel(...)`
- `GetRequestBlockGroupNames(...)`
- `IsPossibleDropBlock(...)`
- `IsShowRequest(...)`
- `IsAllCompleteMainRoom(...)`
- `GetRandomBlockTableData(...)`
- `GetRandomBlockTableData_Sort(...)`
- `GetRewardGoldPrice(...)`
- `IsMatchRequestBlock(...)`
- `IsMatchRequestBlockList(...)`

单机版最小实现：

- 固定生成 3 个订单。
- 每个订单需要 1 到 3 个方块。
- 订单奖励金币和经验。
- 完成订单后立即生成新订单。
- 后续再实现权重、紧急订单、主线点数、角色订单。

## 存档结构

原游戏大量数据继承 `UserSaveData`，说明存档本来就是模块化设计。

### 玩家基础数据

`UserData`：

- `Level`
- `Exp`
- `Ap`
- `Gold`
- `Jewel`
- `MasterHeartPiece`
- `MasterHeart`
- `ApRechargeAdCount`
- `PreAddGold`
- `PreAddJewel`
- `PreAddAp`
- `PreUseGold`
- `PreUseJewel`
- `PreUseAp`

单机版字段：

- level
- exp
- energy
- gold
- gem

### 时间与统计

`UserTimeData`：

- `CurrentDay`
- `DailyResetTime`
- `LastApRefillTime`
- `ApRechargeResetTime`
- `LastLocalSaveTime`
- `SaveCount`
- `LastPlayTime`
- `StartDay`

`UserPlayInfoData`：

- `TotalProduceCount`
- `TotalMergeCount`
- `TotalSellCount`
- `PlayTime`
- `TotalRequestCompleteCount`
- `TotalShopOpenCount`
- `TotalInvenOpenCount`
- `IsFinishShowIntro`

单机版建议：

- 第一版只保存 `LastLocalSaveTime`、`SaveCount`、`TotalMergeCount`、`TotalRequestCompleteCount`。
- 每日重置可后置。

### 地图存档

`MapSaveData`：

- `IsInitBlock`
- `Dictionary<int, List<MapCellData>> MapCellDatas`
- `List<MapCellTypeData> MapCellTypeDatas`
- `CrashCount`

`MapCellData`：

- `xPos`
- `yPos`
- `mapCellType`
- `value`
- `mapCellLockType`
- `isDirectOpenLock`
- `lockValue`
- `sizeUpValue`
- `isLock`

`MapCellTypeData`：

- `MapType`
- `MapID`
- `BoardID`
- `DeskID`
- `IsInitBlock`
- `MapCellDatas`
- `MapSizeX`
- `MapSizeY`

单机版建议：

```json
{
  "mapId": 1,
  "size": [7, 9],
  "cells": [
    { "x": 0, "y": 0, "locked": false, "type": "normal" }
  ]
}
```

### 方块存档

`BlockSaveData`：

- `UniqueID`
- `SubUniqueID`
- `ProduceBlockUnLockDatas`
- `FabricateBlockUnlockIds`
- `MapBlockDatas`
- `MapBlockTypeDatas`

`MapBlockData`：

- `mapID`
- `uniqueID`
- `blockId`
- `xPos`
- `yPos`
- `sizeUpX`
- `sizeUpY`
- `lockBlock`
- `BubbleBlock`
- `isAddLineLock`
- `isDormitoryBlock`

单机版建议：

```json
{
  "nextUniqueId": 100,
  "blocks": [
    { "uid": 1, "blockId": 1001, "x": 2, "y": 3, "locked": false, "bubble": false }
  ]
}
```

### 生产器存档

`ProduceBlockSaveData`：

- `ProduceBlockDatas`
- `GrowProduceBlockDatas`
- `FabricateBlockDatas`
- `ProduceSellPossibleList`
- `ProducePossibleGroupName`

`ProduceBlockData`：

- `uniqueID`
- `mapID`
- `xPos`
- `yPos`
- `blockId`
- `produceEnergy`
- `dailyCoolTimeCount`
- `startCoolTime`
- `coolTimeMax`
- `subCoolTime`
- `startOpenCoolTime`
- `isProduce`
- `open`

单机版建议：

- 可直接合并进方块存档，给方块增加 `cooldownEndTime`、`energy`、`isOpen`。

### 订单存档

`RequestSaveData`：

- `RequestIdSeq`
- `LastSpawnNpcId`
- `LastClearNpcId`
- `CurrentShowNpcDatas`
- `MainRoomRequestDatas`
- `MainRoomSingleRequestDatas`
- `MainRoomConstructRequestDatas`
- `RequestGroupDatas`
- `RequestRandomDatas`
- `RequestUrgentDatas`
- `RequestEventDatas`
- `RequestMainPointDatas`
- `RequestDormitoryData`
- `RequestRandomPossibleGroupName`
- `RequestRandomWeightDic_GroupName`
- `RequestTotalDatas`
- `isRenewalStart`

`RequestData`：

- `id`
- `requestGroupID`
- `requestID`
- `maidId`
- `npcId`
- `skinID`
- `npcDialogId`
- `requestBlocksTotalDiff`
- `requestBlockDatas`
- `rewardItemDatas`
- `rewardPointDatas`
- `rewardMainQuestPoints`
- `complete`
- `groupType`
- `startTime`
- `endTime`
- `isRenewal`

`RequestItemData`：

- `rewardType`
- `id`
- `amount`
- `isNewBlock`

单机版建议：

```json
{
  "nextRequestId": 10,
  "requests": [
    {
      "id": 1,
      "required": [{ "blockId": 1003, "amount": 1 }],
      "rewards": [{ "type": "Gold", "id": 0, "amount": 50 }],
      "complete": false
    }
  ]
}
```

## MVP 单机玩法方案

### 阶段 1：可玩合成棋盘

功能：

- 加载固定棋盘。
- 显示方块图标。
- 拖拽同级同组方块合成。
- 合成后生成下一等级方块。
- 保存棋盘状态。

依赖：

- `BlockTableData`
- `MapBlockData`
- `MapCellData`
- `ResourceManager.GetBlockIcon`

### 阶段 2：生产器与能量

功能：

- 生产器点击产出随机方块。
- 消耗 `ProduceEnergy` 或玩家 `Ap`。
- 进入冷却，冷却完成后可再次生产。

依赖：

- `BlockTableData.ProduceEnergy`
- `BlockTableData.CoolTime`
- `BlockDropTableData`
- `ProduceBlockData`

### 阶段 3：订单

功能：

- 生成订单。
- 检查棋盘是否有订单所需方块。
- 提交订单，删除方块，发放奖励。
- 自动刷新新订单。

依赖：

- `RequestData`
- `RequestItemData`
- `RequestRandomBlockTableData`
- `RequestDataManager` 方法逻辑。

### 阶段 4：大厅和基础成长

功能：

- 大厅展示角色和入口按钮。
- 玩家等级、金币、体力。
- 任务完成增加经验和金币。

依赖：

- `UserData`
- `UserPlayInfoData`
- `NpcTableData`
- `Table_Language`

## 可以删除或简化的联网功能

第一版单机可删除：

- 平台登录：Google / Apple / Facebook / QuickGame。
- 云存档：`UserDataSaveCloud`。
- 广告奖励、插屏、激励视频。
- IAP 购买。
- 远程活动。
- 推送通知。
- 排行榜。
- 反作弊和封号提示。

需要本地替代：

- 登录状态 -> 默认本地用户。
- 云存档 -> 本地 JSON。
- 广告加速 -> 金币或免费加速。
- IAP 商品 -> 本地商店或禁用。

## 技术实现建议

如果继续用 Unity：

- 资源复用成本最低。
- 可直接复刻 UGUI、Sprite、Spine、Audio。
- 需要解决 AssetBundle / YooAsset 解包和 prefab 引用恢复。

如果用 Web / Godot / 其他引擎：

- 逻辑可重写更快。
- UI 和资源绑定要重建。
- Spine、字体、图集、九宫格、动画迁移成本更高。

建议：

- MVP 用 Unity。
- 表数据转 JSON。
- 资源先从 AssetStudio 导出的 PNG/TextAsset 加载。
- Prefab 无法完整恢复时，手工重建最小 UI。

## 下一步分析任务

- 完整导出 `BlockTableData`、`Request*TableData`、`Map*TableData` 的字段。
- 反查 `BlockImage` 到 Sprite 文件路径。
- 解析棋盘初始布局表。
- 确认 `BlockType`、`RewardType`、`MapType` 枚举值。
- 建立最小存档 JSON schema。
- 根据资源映射做一个可视化棋盘原型。
