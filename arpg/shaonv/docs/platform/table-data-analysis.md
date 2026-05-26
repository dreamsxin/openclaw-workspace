# 单机版表数据分析

目标：整理原游戏配置表体系，识别单机版必须保留的数据表、字段和导出优先级。

> 目录纠偏：本文早期引用了 `../merge/reverse-output` 中的相邻目录导出结果。后续实现必须先在 `D:\work\openclaw-workspace\arpg\shaonv` 本目录重新导出 IL2CPP 和资源清单，再复核本文结论。详见 `docs/analysis-scope-correction.md`。

## 数据来源

- `resources/lib/arm64-v8a/libil2cpp.so`
- `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`
- 待重新生成的 `reverse-output/il2cpp/dump.cs`
- 待重新生成的 `reverse-output/il2cpp/analysis/excel-table-schema.csv`
- 待重新生成的 `reverse-output/il2cpp/analysis/table-data-fields.csv`

## 使用过的命令

```powershell
Import-Csv ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis\excel-table-schema.csv |
  Group-Object Table |
  Sort-Object Name |
  ForEach-Object { $_.Name }
```

```powershell
Import-Csv ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis\table-data-fields.csv |
  Group-Object Class |
  Sort-Object Name |
  ForEach-Object {
    $fields=($_.Group | Select-Object -First 12 | ForEach-Object { "$($_.Type) $($_.Field)" }) -join '; '
    "$($_.Name): $fields"
  }
```

## 已识别表清单

配置表以 `Table_*` 命名，继承或关联 `ExcelImporterRoot`，多数带有 `[ExcelAsset]`。

已识别表：

- `Table_Album`
- `Table_AlwaysMiniGame`
- `Table_Attendance`
- `Table_Block`
- `Table_BlockBox`
- `Table_BlockFabricate`
- `Table_Board`
- `Table_Collectible`
- `Table_CustomerEpisode`
- `Table_DailyMission`
- `Table_EchoArchive`
- `Table_Event`
- `Table_Event_Arcade`
- `Table_Event_Band`
- `Table_Event_Bingo`
- `Table_Event_BloodWorm`
- `Table_Event_CardPack`
- `Table_Event_Cartoon`
- `Table_Event_CumulativeQuest`
- `Table_Event_Fishing`
- `Table_Event_MatchCard`
- `Table_Event_MateRace`
- `Table_Event_PointCollect`
- `Table_Event_PuddingJump`
- `Table_Event_SchoolUniform`
- `Table_Event_SeasonPass`
- `Table_Event_SummerFestival`
- `Table_Event_SurpriseBox`
- `Table_Event_TreasureSand`
- `Table_Event_VendingMachine`
- `Table_Event_WhiteDay`
- `Table_FindEvidence`
- `Table_FriendInvite`
- `Table_HighKuji`
- `Table_Inventory`
- `Table_Item`
- `Table_Language`
- `Table_LevelPass`
- `Table_MaidAIChat`
- `Table_MaidChat`
- `Table_MemoryCard`
- `Table_MissionPass`
- `Table_Notice`
- `Table_Npc`
- `Table_OutGame`
- `Table_Package`
- `Table_PhotoCard`
- `Table_RandomObject`
- `Table_Request`
- `Table_Roulette`
- `Table_SeriouslyMerge`
- `Table_Shop`
- `Table_SNS`
- `Table_Story`
- `Table_UserKey`
- `Table_VideoBonus`
- `Table_WorkLog`

## 单机版 MVP 必需表

第一版单机核心循环建议只保留：

- `Table_Block`：方块定义、合成链、产出、冷却、出售、商店价格。
- `Table_Board`：棋盘格、地图尺寸、锁格、初始布局。
- `Table_Request`：订单需求、奖励、随机订单规则。
- `Table_Item`：道具、奖励箱、资源皮肤、玩家物品。
- `Table_Npc`：女仆/顾客基础信息和头像映射。
- `Table_Language`：UI、方块名、角色名、说明文本。
- `Table_OutGame`：大厅/经营解锁、房间或主线进度。
- `Table_Inventory`：背包槽、容量、方块入库规则。
- `Table_Story`：剧情文本和演出资源，MVP 可选。
- `Table_Shop`：如果保留本地商店，需要金币/钻石/方块售卖配置。

第二阶段再考虑：

- `Table_Attendance`
- `Table_DailyMission`
- `Table_LevelPass`
- `Table_MemoryCard`
- `Table_MaidChat`
- `Table_MaidAIChat`
- `Table_Collectible`
- `Table_PhotoCard`
- `Table_Event_*`

## 关键表结构

### Table_Block

字段组：

- `List<BlockTableData> BlockTableData`
- `List<BlockCoolTimeTableData> BlockCoolTimeTableData`
- `List<BlockDropTableData> BlockDropTableData`
- `List<BlockBubbleDropTableData> BlockBubbleDropTableData`
- `List<BlockDesignedDropTableData> BlockDesignedDropTableData`
- `List<BlockProduceTableData> BlockProduceTableData`
- `List<BlockProduceMsgTableData> BlockProduceMsgTableData`
- `List<BlockGrowProduceTableData> BlockGrowProduceTableData`
- `List<BlockSpineTableData> BlockSpineTableDatas`
- `List<BlockMergeDropRateTableData> BlockMergeDropRateTableData`
- `List<BlockMergeDropPoolTableData> BlockMergeDropPoolTableData`
- `List<BubbleRewardTableData> BubbleRewardTableData`

`BlockTableData` 已确认字段：

- `ID`
- `CategoryName`
- `SubCategoryName`
- `GroupName`
- `BlockType`
- `Level`
- `BlockTier`
- `ProductionDiff`
- `BlockName`
- `BlockImage`
- `IsSpineBlock`
- `ParentBlockID`
- `IsAllParentBlock`
- `ProduceEnergy`
- `CoolTime`
- `MaxSubtractCoolTimePer`
- `OnGoingAddedCoolTimeper`
- `ProduceRewardType`
- `ProduceRewardID`
- `ProduceRewardValue`
- `Expendability`
- `ExpendAlterBlockID`
- `OpenCoolTime`
- `OpenType`
- `AddedDropRate`
- `AddedDropBlockID`
- `BubbleBlockRate`
- `BubblePopCurrencyType`
- `JewelBubblePopCoef`
- `ObtainRewardType`
- `ObtainRewardId`
- `ObtainRewardValue`
- `SellAvailable`
- `SellGoldCoef`
- `GoldShopCoef`
- `JewelShopCoef`
- `ShopBlockCurrencyType`
- `ShopBlockCurrencyValue`
- `DisplayInCollection`
- `IsActiveMerge`

单机实现含义：

- `ID`：方块唯一配置 ID。
- `GroupName` + `Level`：合成链核心。
- `BlockType`：普通块、生产器、货币、特殊块等类型。
- `BlockImage`：资源映射关键字段。
- `ParentBlockID`：可用于推断合成前置或生产来源。
- `ProduceEnergy` / `CoolTime`：生产器消耗与冷却。
- `ProduceRewardType/ID/Value`：点击生产器产物。
- `SellAvailable` / `SellGoldCoef`：出售规则。
- `IsActiveMerge`：是否允许参与合成。

### 冷却与掉落

`BlockCoolTimeTableData`：

- `GroupName`
- `CurrencyType`
- `MinValue`
- `CoolTimeDuring`
- `CoolTimeDuringValue`

`BlockDropTableData`：

- `ID`
- `BlockID`
- `Ratio`
- `Weight`
- `FinalRatio`

`BlockBubbleDropTableData`：

- `GroupName`
- `LevelMin`
- `Ratio1`
- `Ratio2`
- `Ratio3`

单机实现含义：

- 生产器掉落可先用 `BlockDropTableData` 做权重随机。
- 泡泡块可以第一版禁用，后续实现。
- 冷却加速可以先固定时间，不接广告或付费。

### Table_Request

已确认相关数据类：

- `RequestMainRoomTableData`
- `RequestRandomTableData`
- `RequestRandomBlockTableData`
- `RequestUrgentTableData`
- `RequestDormitoryTableData`
- `RequestMainPointTableData`
- `RequestEventTableData`

`RequestRandomBlockTableData` 已确认字段：

- `GroupIdx`
- `Block_GroupName`
- `MinBlockLevelRange`
- `MaxBlockLevelRange`

单机实现含义：

- 订单需求可以按方块组和等级范围生成。
- `RequestDataManager.GetRequestRandomBlock(...)`、`FilterBlockByLevel(...)`、`RandomBlockWeight(...)` 说明原游戏有按权重和等级区间选块逻辑。

### Table_Language

字段组：

- `Common`
- `Notice`
- `UI`
- `BlockName`
- `CategoryName`
- `GroupName`
- `BlockInfo`
- `NpcName`
- `NpcInfo`
- `StoryReplayTitle`
- `AlbumTitle`
- `KOAKUCartoon`
- `StoryPrefabs`
- `MemoryCard`
- `CardPack`

单机实现含义：

- 中文/多语言文本需要从该表恢复。
- MVP 可先只导出 UI、BlockName、NpcName、BlockInfo。

### Table_Item

字段组：

- `ItemDatas`
- `ItemNeedleDatas`
- `RewardBoxDatas`
- `MemoryCardTicketData`
- `KujiTicketDatas`
- `UserProfileTableDatas`
- `inGameResTableDatas`

单机实现含义：

- 道具系统、奖励箱、头像框、游戏内皮肤都在这里。
- MVP 只需要 `ItemDatas` 和 `inGameResTableDatas`。

### Table_Npc

用途：

- 角色/女仆/顾客基础信息。
- 与 `ResourceManager.GetNpcName`、`GetNpcPrefab_*`、`GetMaidProfile` 配合。

单机实现：

- 先建立 `npcId -> 名称 -> 头像 -> 立绘`。
- 角色成长、皮肤、好感可以后置。

## 表管理器

关键管理器：

- `TableDataManager`
- `GameConfigManager`
- `InGameConfigManager`
- `MapDataManager`
- `RequestDataManager`
- `NpcDataManager`
- `RewardDataManager`
- `ShopDataManager`
- `StoryDataManager`
- `EventConfigManager`

分析结论：

- 表数据是强类型 C# 类，不是运行时随意 JSON。
- 单机版可以把原表转换成 JSON/SQLite，然后实现同名查询函数。
- 优先恢复 `BlockTableData`、`Map*Data`、`Request*Data`、`NpcTableData`、`LanguageCommon`。

## 单机版数据导出建议

建议输出以下中间文件：

- `tables/block_table.json`
- `tables/block_drop_table.json`
- `tables/board_table.json`
- `tables/request_table.json`
- `tables/request_random_block_table.json`
- `tables/item_table.json`
- `tables/npc_table.json`
- `tables/language_ui.json`
- `tables/language_block_name.json`
- `tables/language_npc_name.json`

## 待验证项

- 从实际 TextAsset / ScriptableObject 中导出每张表的真实数据行。
- 确认表数据是否加密、压缩或二进制序列化。
- 确认 `TableDataManager` 加载顺序和表对象资源名。
- 确认 `BlockType`、`RewardType`、`CurrencyType`、`MapType` 等枚举完整值。
- 确认 `RequestMainRoomTableData` 等订单表完整字段。
