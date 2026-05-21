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

Restored startup mode:

```powershell
.\run-game.bat
```

`run-game.bat` now follows the restored flow `UILoading -> UISceneLoading -> UIOutGame`. The `UIOutGame/InGameBtn` region is clickable and enters the current recovered merge-board prototype. For non-interactive validation, pass:

```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame
```

Capture restored startup screenshots:

```powershell
.\capture-startup.bat
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
| `godot-project/data/ui_layout_reference.json` | Startup UI RectTransform reference data derived from AssetRipper prefabs/scenes |

## Imported Assets

Godot-runtime assets are copied into the project tree. Raw reverse exports remain under `reverse-output/`.

| Target | Purpose |
| --- | --- |
| `godot-project/assets/sprites/` | Board, currency, and block sprites used by the merge prototype |
| `godot-project/assets/characters/` | First-pass maid, maid costume, customer, and maid-chat static image assets |
| `godot-project/assets/loading/` | First-pass loading screen PNG assets copied from AssetStudio Sprite/Texture2D exports |

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

Character images are classified before use:

- `static_png_only`: loaded directly as a profile preview.
- `spine_atlas_page_with_skel`: has same-name `.atlas.dat` and `.skel.dat`; shown as Spine metadata until a renderer is integrated.
- `spine_atlas_page_no_skel`: has atlas data but no copied skeleton companion yet; shown as incomplete Spine metadata.

The current profile browser does not treat atlas page PNGs as full static portraits.

## UI Layout Reference

The top-right `UI Ref` control reads `godot-project/data/ui_layout_reference.json`.

Use `Next UI` to cycle through recovered startup/root layout sources:

- `UILoading`
- `UISceneLoading`
- `UIMaidLobbyLoading`
- `UIOutGame`
- `UIInGame`

The selector shows the source RectTransform count and writes the reference resolution plus key node sizes to the status panel. A small portrait wireframe preview draws the first key RectTransforms in the 1080 x 1920 reference space so original layouts can be compared visually while the actual Godot screens are still being rebuilt.

The loading-screen reference layer is shown by default on startup, and the left-side `Loading Ref` / `OutGame Ref` buttons toggle recovered layout overlays. `run-game.bat` starts the project in restored startup mode, passes `--restored-startup`, and displays the startup flow full-window in a portrait-oriented 540 x 960 window. Restored startup mode now advances through `UILoading`, then `UISceneLoading`, then displays the first `UIOutGame` reference layer. Clicking the recovered `InGameBtn` hit area hides the out-game layer and enters the current playable merge-board prototype.

`UILoading` uses the recovered RectTransforms for the 1080 x 1920 root, background layers, logo area, loading bar, and version-label corners. `UISceneLoading` uses the recovered root/background structure and now draws `SkeletonGraphic (kokomi_Loading)` from official Spine-runtime output. The original `.atlas.txt`, `.skel.bytes`, and texture pages are copied under `godot-project/assets/spine/loading/kokomi_Loading/`; `bake_kokomi_loading_spine.mjs` uses `@esotericsoftware/spine-core@4.2.43` to parse the binary skeleton and write `kokomi_Loading.baked.json` with exact draw order, UVs, triangles, and world vertices. The current baked schema keeps legacy top-level `Idle` data and also includes `clips.Idle` plus `clips.Interaction`; Godot plays `Interaction` during the middle scene-loading progress window as the first multi-clip playback slice. The older `kokomi_Loading.rig.json` path remains only as a fallback.

Startup screenshot capture is built into `scripts/main.gd` behind the user argument `--startup-capture-dir=<path>`. `capture-startup.bat` wraps the full command and writes:

```text
reverse-output/startup-captures/01-uiloading.png
reverse-output/startup-captures/02-uisceneloading.png
reverse-output/startup-captures/03-uisceneloading-late.png
reverse-output/startup-captures/04-outgame.png
```

Use this whenever loading-screen layout or Spine rendering changes. The direct equivalent is:

```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --resolution 540x960 --quit-after 360 -- --restored-startup --startup-capture-dir=D:\work\openclaw-workspace\arpg\merge\reverse-output\startup-captures
```

The latest `UISceneLoading` fix was verified with these captures. The baked Spine UVs are normalized `0..1` coordinates, so Godot must pass them directly to `draw_polygon`; multiplying by texture page size makes the second screen render as a blank progress-only view.

`UIOutGame` is currently a structural reconstruction layer rather than a final screen. It uses the recovered `UIOutGame.prefab` RectTransforms for `UIMaidLD`, `Npc_Dialog`, `InGameBtn`, `MaidLobbyBtn`, and `UIVillageReBuild/Fillbar`. `InGameBtn`, `MaidLobbyBtn`, and `Btn_ToInteraction` now have recovered hit regions; only `InGameBtn` is wired to a working scene transition. The maid LD character area is an explicit placeholder because the recovered maid LD assets are Spine atlas pages, not complete static portraits; replacing it requires the reusable Spine character renderer planned under T027.

`UIInGame` now has a first gameplay shell in `run-game.bat` mode. `InGameReferenceShell` reads the recovered `UIInGame` RectTransforms and draws the top wallet bar plus candidate `Request`, `Bottom/UIBlockInfo`, inventory, and lobby regions behind the playable board. In the 540 x 960 portrait window, the 7x7 board is centered and the older desktop debug panels are hidden so the restored path remains playable after `UIOutGame/InGameBtn`. The shell exposes first hit regions for Produce, Bag, and Cafe; Produce calls the current recovered producer logic, Bag reports the pending inventory restore, and Cafe returns to `UIOutGame`.

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
