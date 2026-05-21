# Data Table Schema

This document records the recovered table schema used for the Godot data import pipeline.

## Current Finding

The game uses an `ExcelImporter` style table system.

Evidence:

- `ExcelImporterRoot : ScriptableObject`
- `ExcelAssetAttribute`
- Many classes named `Table_* : ExcelImporterRoot`
- `TableDataManager` stores serialized `Table_*[]` references and builds dictionaries/lists at runtime.

Generated schema files:

```text
reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/excel-table-schema.csv
reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/key-table-row-fields.csv
reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/table-data-fields.csv
```

## Important Tables

| Unity table | Purpose | Godot target |
| --- | --- | --- |
| `Table_Block` | Main block, drop, producer, bubble, collection, and merge-drop data | `blocks.json`, producer/drop tables |
| `Table_BlockBox` | Box/select-box block rewards | box reward data |
| `Table_BlockFabricate` | Fabrication recipes and init blocks | fabricate recipe data |
| `Table_Item` | Items, reward boxes, tickets, user profile, in-game resources | item/resource catalog |
| `Table_Request` | Request/order definitions and random block groups | request/order model |
| `Table_SeriouslyMerge` | Special merge mode levels/skills/config | optional special-mode model |
| `Table_Board` | Board/map cells and board unlocks | board layout data |

## `Table_Block`

`Table_Block` contains these lists:

| Field | Row type |
| --- | --- |
| `BlockTableData` | `BlockTableData` |
| `BlockCoolTimeTableData` | `BlockCoolTimeTableData` |
| `BlockDropTableData` | `BlockDropTableData` |
| `BlockBubbleDropTableData` | `BlockBubbleDropTableData` |
| `BlockDesignedDropTableData` | `BlockDesignedDropTableData` |
| `BlockProduceTableData` | `BlockProduceTableData` |
| `BlockProduceMsgTableData` | `BlockProduceMsgTableData` |
| `BlockGrowProduceTableData` | `BlockGrowProduceTableData` |
| `BlockSpineTableDatas` | `BlockSpineTableData` |
| `BlockMergeDropRateTableData` | `BlockMergeDropRateTableData` |
| `BlockMergeDropPoolTableData` | `BlockMergeDropPoolTableData` |
| `BubbleRewardTableData` | `BubbleRewardTableData` |
| `BlockCollectionTableDatas` | `BlockCollectionTableData` |

High-value `BlockTableData` fields:

| Field | Meaning for Godot |
| --- | --- |
| `ID` | Canonical block id |
| `CategoryName` | Category grouping |
| `SubCategoryName` | Sub-category grouping |
| `GroupName` | Merge chain group |
| `BlockType` | Block behavior class |
| `Level` | Merge level within group |
| `BlockTier` | Economy/progression tier |
| `BlockName` | Localization/name key candidate |
| `BlockImage` | Sprite/spine asset key |
| `IsSpineBlock` | Use Spine asset instead of static sprite |
| `ParentBlockID` | Parent/producer relation candidate |
| `ProduceEnergy` | AP/energy cost or generator energy |
| `CoolTime` | Generator cooldown |
| `ProduceRewardType/ID/Value` | Producer output reward |
| `OpenCoolTime/OpenType` | Unlock/opening behavior |
| `AddedDropRate/AddedDropBlockID` | Extra drop behavior |
| `BubbleBlockRate` | Bubble spawn chance |
| `ObtainRewardType/Id/Value` | Reward on obtain |
| `SellAvailable/SellGoldCoef` | Sell behavior |
| `DisplayInCollection` | Collection visibility |
| `IsActiveMerge` | Whether block participates in merge rules |

Godot merge-chain rule can be derived from:

```text
GroupName + Level
```

For each active merge block, the next block is expected to be the same `GroupName` with `Level + 1`. Last-level detection is handled in Unity by `TableDataManager.GetLastLevelBlockTableData(...)` and `IsMaxLevelBlock(...)`.

## Current Extraction Status

AssetStudio JSON and AssetRipper Primary Content/Unity Project expose table component names but not the actual row lists.

Observed examples:

```text
reverse-output/assets/assetstudio-cli-data-json/MonoBehaviour/Table_Block.json
reverse-output/assets/assetstudio-cli-data-json/MonoBehaviour/Table_Item.json
reverse-output/assets/assetstudio-cli-data-json/MonoBehaviour/TableDataManager.json
```

These contain script references and names only, not serialized rows.

The real rows were recovered from AssetStudio `MonoBehaviour` Raw export:

```text
reverse-output/assets/assetstudio-cli-data-monobehaviour-raw/MonoBehaviour/Table_Block.dat
```

Decoded output:

```text
reverse-output/assets/derived/table_block_catalog.csv
reverse-output/assets/derived/table_block_catalog.json
godot-project/data/blocks.json
```

Current `Table_Block` decode status:

- Parsed 568 main `BlockTableData` rows from the all-assets Raw export.
- Generated 74 non-currency merge chains and 541 Godot block entries.
- Reliable fields: `ID`, `CategoryName`, `SubCategoryName`, `GroupName`, `BlockType`, `Level`, `BlockTier`, `ProductionDiff`, `BlockName`, `BlockImage`.
- Each `BlockTableData` row has a 120-byte primitive tail after the string fields.
- The full `Table_Block` byte stream and child-list order now align with `dump.cs`.

Decoded child lists:

| List | Rows | Output |
| --- | ---: | --- |
| `BlockCoolTimeTableData` | 24 | `reverse-output/assets/derived/table_block_children/BlockCoolTimeTableData.csv` |
| `BlockDropTableData` | 260 | `reverse-output/assets/derived/table_block_children/BlockDropTableData.csv` |
| `BlockBubbleDropTableData` | 24 | `reverse-output/assets/derived/table_block_children/BlockBubbleDropTableData.csv` |
| `BlockDesignedDropTableData` | 65 | `reverse-output/assets/derived/table_block_children/BlockDesignedDropTableData.csv` |
| `BlockProduceTableData` | 117 | `reverse-output/assets/derived/table_block_children/BlockProduceTableData.csv` |
| `BlockProduceMsgTableData` | 4 | `reverse-output/assets/derived/table_block_children/BlockProduceMsgTableData.csv` |
| `BlockGrowProduceTableData` | 8 | `reverse-output/assets/derived/table_block_children/BlockGrowProduceTableData.csv` |
| `BlockSpineTableData` | 16 | `reverse-output/assets/derived/table_block_children/BlockSpineTableData.csv` |
| `BlockMergeDropRateTableData` | 12 | `reverse-output/assets/derived/table_block_children/BlockMergeDropRateTableData.csv` |
| `BlockMergeDropPoolTableData` | 68 | `reverse-output/assets/derived/table_block_children/BlockMergeDropPoolTableData.csv` |
| `BubbleRewardTableData` | 29 | `reverse-output/assets/derived/table_block_children/BubbleRewardTableData.csv` |
| `BlockCollectionTableData` | 56 | `reverse-output/assets/derived/table_block_children/BlockCollectionTableData.csv` |

Godot rule output:

```text
godot-project/data/block_rules.json
```

Current generated rule groups:

- `produce_by_block`: 117 producer/drop entries.
- `cooldown_by_group`: 23 cooldown groups.
- `merge_drop_rates`: 12 block entries.
- `merge_drop_pools`: 68 pool entries grouped by pool id.

## AssetRipper Unity Project Result

AssetRipper full Unity Project export was checked at:

```text
reverse-output/assets/assetripper-main
```

The project is useful for scenes, prefabs, images, audio, materials, and skeleton/text assets. It is not currently useful for table rows because `Assets/Resources/table/*.asset` files are tiny YAML stubs and generated C# scripts are dummy classes.

## Next Required Extraction

Inspect `TableDataManager.LoadTable_Block` in native code around:

```text
RVA 0x2CA7620
VA  0x2CA3620
```

and related loaders:

```text
LoadTable_BlockProduce
LoadTable_BlockDrop
LoadTable_BlockBubbleDrop
LoadTable_BlockBox
LoadTable_BlockFabricate
LoadTable_BlockMergeDrop
LoadTable_Item
```

## Godot Import Contract

The eventual converter should produce:

```json
{
  "chains": {
    "group_name": [
      {
        "id": "1001",
        "source_id": 1001,
        "level": 1,
        "name_key": "BlockName",
        "sprite": "res://assets/sprites/...",
        "is_spine": false,
        "block_type": "Normal",
        "next": "1002"
      }
    ]
  }
}
```

Current converter outputs `godot-project/data/blocks.json` and `godot-project/data/block_rules.json`.
