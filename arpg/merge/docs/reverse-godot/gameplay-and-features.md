# Gameplay and Feature Analysis

This document records the current working analysis of the original game design. It separates confirmed reverse-engineering evidence from inferred behavior that still needs native-code or runtime confirmation.

## High-Level Classification

The original game is best described as a mobile merge-management game with a maid-cafe theme.

The confirmed user flow is not a traditional ARPG loop. It is a lobby and character presentation layer wrapped around a merge board:

```text
startup/loading -> cafe/out-game home -> merge board -> produce and merge items -> request/order progression -> return to cafe and maid interaction
```

The current Godot route mirrors this structure:

```text
BootServices -> GameStartLoad -> ReloadScene -> RuntimeCanvas/SafeArea -> UILoading -> UISceneLoading -> UIMaidLobbyLoading -> UIOutGame -> UIInGame/UIMaidLobby/popups
```

## Core Loop

1. The app boots through service checks, table loading, scene loading, and UI canvas setup.
2. The player lands in `UIOutGame`, a cafe/home screen with wallet, maid presentation, rebuild/progress area, and navigation.
3. The player enters `UIInGame`, the merge-board screen.
4. Producer blocks generate items, consuming AP and producer energy.
5. Same-id items are dragged together and merged upward through recovered block chains.
6. Request/order UI asks for specific item goals and displays reward slots.
7. Rewards and progression feed back into wallet, unlocks, cafe/home presentation, and character systems.
8. The player can return to out-game surfaces such as maid lobby, dialogs, inventory, shop/story/app popups, and other collection or progression screens.

## Confirmed Gameplay Systems

| System | Evidence | Current Godot state |
| --- | --- | --- |
| Merge board | `InGame_MapManager`, `InGame_BlockManager`, `InGame_ItemCell`, `MapSaveData` | 7x7 board, drag/drop, move/merge |
| Block instances | `InGame_ItemBlock`, `MapBlockData`, `BlockSaveData` | data-driven block ids and sprites |
| Merge chains | recovered `Table_Block.dat`, generated `blocks.json` | 74 non-currency chains, 541 blocks |
| Producer blocks | `ProduceBlockData`, `ProduceBlockSaveData`, `FabricateBlockMapData` | first-pass production, AP cost, cooldown, energy |
| Drop rules | decoded `Table_Block` child lists, generated `block_rules.json` | weighted drops and designed drop queues |
| Wallet | `UserSaveDataMetaInfo.ap/gold/jewel` | AP, gold, jewel HUD values |
| Inventory UI | `UIInGame/Bottom/UIInventory`, `UIPopup_Inventory` layout evidence | first-pass popup shell |
| Request strip | `UIInGame/Request/RequestList`, reward slots, skill placeholders | first-pass structural strip |
| Cafe/out-game home | `UIOutGame.prefab`, `UIMaidLD`, `InGameBtn`, `MaidLobbyBtn`, `UIVillageReBuild` | first-pass home shell |
| Maid lobby | `UIMaidLobby.prefab`, `SpinePos`, `Npc_Dialog`, `DialogBtn` | first-pass lobby shell |
| Maid select popup | `UIPopup_MaidLobbySelect` layout evidence | first-pass selectable popup |
| Maid dialog | `Table_Npc.InGameNpcDialog`, generated `dialogs.json` | first-pass dialog popup |

## Content Scale

Current recovered content indicates the game is content-heavy:

| Area | Current recovered count or signal |
| --- | --- |
| Blocks | 541 block records in generated Godot catalog |
| Non-currency merge chains | 74 chains |
| Producer blocks | 117 producer-capable blocks |
| Cooldown groups | 23 groups |
| Merge-drop rate blocks | 12 blocks |
| Block sprites copied into Godot | 505 recovered sprite keys |
| Maid/base/costume/customer assets | many static and Spine-backed character assets under `godot-project/assets/characters/` |
| NPC dialog | large multilingual dialog table, generated into `dialogs.json` |
| UI prefab scale | 1,137 UI prefabs and 84,034 RectTransform records indexed |

## Feature Character

The main design characteristics are:

- Merge-board play is the core interaction, not only a side minigame.
- Producers are stateful objects with AP cost, internal energy, drop queues, and cooldown behavior.
- Requests/orders likely provide the main directed goals for what to merge.
- The cafe home acts as the main navigation and presentation hub.
- Maid/NPC/customer systems are large enough to be treated as first-class features.
- Character presentation uses both static PNG assets and Spine atlas/skeleton pairs.
- Economy uses AP, gold, and jewel, with UI evidence for premium and acceleration paths.
- The UI is mobile portrait-first, with Unity Canvas/SafeArea/CanvasScaler layout.
- There are event/sub-map/story surfaces suggested by `UIInGame/SubMapUI`, `UIEchoArchive`, and event UI names.

## Inferred or Pending Details

These areas have strong evidence but are not yet precise enough for final gameplay parity:

- Exact request/order table schema, refresh rules, completion logic, and reward grants.
- Producer refill, open-state, cooldown, and drop mutation semantics from native runtime methods.
- Inventory slot persistence and distinction between produce inventory and normal inventory.
- Board blockers, bubbles, boxes, special cells, and their unlock/removal rules.
- Shop, mailbox, settings, story, memory, collection, and event popup interaction flows.
- Exact IAP products, rewarded ad rewards, and premium acceleration values.
- Exact LD maid Spine rendering path outside the loading-screen baked Spine proof.
- Audio, UI particles, masks, and original visual effects.

## Reimplementation Priority

For gameplay fidelity, the next systems should be restored in this order:

1. Decode `RequestDataManager` and request/order table assets.
2. Confirm producer runtime semantics in Ghidra for energy, refill, open state, cooldown, and drop selection.
3. Replace remaining hand-drawn out-game navigation surfaces with recovered UI sprites.
4. Implement real inventory persistence and item submission to requests.
5. Continue rebuilding out-game app popups: shop, story/memory, mail/settings, collection, and event surfaces.
6. Generalize Spine rendering for LD maid presentation outside the loading screen.

