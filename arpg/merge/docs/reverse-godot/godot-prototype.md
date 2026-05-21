# Godot Prototype

This document records the first Godot reimplementation prototype.

## Location

```text
godot-project/
```

Main scene:

```text
godot-project/scenes/main.tscn
```

Run with:

```powershell
.\run-godot.bat
```

Equivalent direct command:

```powershell
.\tools\Godot\Godot.exe --path .\godot-project
```

Headless validation:

```powershell
.\tools\Godot\Godot_console.exe --headless --import --path .\godot-project
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --quit-after 2
```

## Implemented Scope

The prototype is intentionally small and data-driven:

- 7x7 board.
- Locked corner cells.
- Block instances.
- Drag/drop movement.
- Same-id merge into next chain level.
- Spawn button consuming AP.
- First-pass production/drop/cooldown rule import from recovered `Table_Block` child lists.
- Producer selection and first-pass Produce button using recovered drop rules.
- Wallet display for AP, gold, and jewel.
- Local save/load at `user://prototype-save.json`.

## Data Files

| File | Purpose |
| --- | --- |
| `godot-project/data/blocks.json` | Recovered block catalog and merge chains from `Table_Block.dat` |
| `godot-project/data/block_rules.json` | Recovered production, drop, cooldown, and merge-drop rules from `Table_Block` child lists |
| `godot-project/data/initial_board.json` | Initial board, wallet, locked cells, and block placement |

## Imported Assets

Godot-runtime assets are copied into the project tree. Raw reverse exports remain under `reverse-output/`.

| Target | Purpose |
| --- | --- |
| `godot-project/assets/sprites/` | Board, currency, and block sprites used by the merge prototype |
| `godot-project/assets/characters/` | First-pass maid, maid costume, customer, and maid-chat static image assets |

Current catalog summary:

```text
blocks.json: 74 non-currency chains, 541 blocks
block_rules.json: 117 produce blocks, 23 cooldown groups, 12 merge-drop rate blocks
block sprites: 505 recovered sprite keys copied, 0 missing references
```

Recovered block sprites are copied from AssetStudio Sprite output into `godot-project/assets/sprites`. `Block_Unknown.png` remains only as a fallback.

## Scripts

| Script | Responsibility |
| --- | --- |
| `scripts/main.gd` | UI composition, input handling, board rendering |
| `scripts/models/block_catalog.gd` | Data-driven block lookup and merge resolution |
| `scripts/models/merge_board_model.gd` | Board state, move/merge rules, wallet state |
| `scripts/services/save_manager.gd` | JSON save/load |

## Character Data

First-pass recovered character catalogs are now generated under:

```text
godot-project/data/characters/npcs.json
godot-project/data/characters/maids.json
godot-project/data/characters/customers.json
godot-project/data/characters/dialogs.json
```

The JSON files are generated from `Table_Npc.dat` by `scripts/reverse/parse_table_npc.py` and `scripts/reverse/build_godot_character_catalog.py`.
The main scene now loads these files and shows a first-pass character browser on the right side of the prototype.
Use the mode button to switch between maids and customers, then the arrow buttons to step through recovered entries.

Imported character PNGs require Godot import metadata. Regenerate it after adding new copied character images with:

```powershell
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --import
```

## Current Interaction Notes

- Initial board includes producer block `1101104` (`BlockName_ToolPocket`).
- Click/select that block, then press `Produce` to create the first recovered designed drop, currently `1201101`.
- Produce consumes 1 AP and applies the first recovered cooldown duration for the producer group.
- Weighted random selection is implemented for normal drop pools.
- Designed drop ranges now build a per-producer-cell shuffled queue from recovered `count_min/count_max` values, and each Produce consumes one queued block.
- `BlockTableData.ProduceEnergy` is treated as producer internal energy/capacity, matching `ProduceBlockData.produceEnergy` in the runtime save model.
- Designed drop queues and remaining producer energy are saved with the board state so partial producer cycles survive load.

## Reverse Mapping

Current prototype modules map to recovered Unity concepts:

| Godot prototype | Unity/IL2CPP evidence |
| --- | --- |
| `MergeBoardModel` | `InGame_MapManager`, `InGame_BlockManager`, `MapSaveData`, `MapBlockData` |
| block instance id | `blockId`, `uniqueID`, `MapBlockData` |
| locked cells | `MapCellData.mapCellType`, board blockers |
| spawn button/AP | `ProduceBlockData.produceEnergy`, `UserSaveDataMetaInfo.ap` |
| wallet | `UserSaveDataMetaInfo.ap/gold/jewel` |
| save/load | `UserSaveData`, `MapSaveData`, `BlockSaveData` |

## Next Implementation Targets

1. Inspect `InGame_ItemBlock.OnProduce` and `SetProduceEnergyData` for refill and open/cooldown edge cases.
2. Add producer refill/reset behavior once native runtime semantics are confirmed.
3. Add basic request/order model after `RequestDataManager` and request table assets are mapped.

Current schema reference:

```text
docs/reverse-godot/data-table-schema.md
```
