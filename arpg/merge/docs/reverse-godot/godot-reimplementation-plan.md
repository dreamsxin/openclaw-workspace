# Godot Reimplementation Plan

## Goal

Rebuild the game behavior in Godot using recovered gameplay rules, data, and assets where legally and practically allowed.

The first target is not visual parity. The first target is a playable vertical slice with correct merge mechanics, item data, progression, save/load, and core UI flow.

## Recommended Godot Version

Use Godot 4.x unless a specific plugin requirement forces Godot 3.x.

Reasons:

- Better resource pipeline.
- Better UI tooling.
- Better GDScript and C# options.
- Modern Android export support.

## Project Structure Proposal

```text
godot-project/
├── project.godot
├── assets/
│   ├── original-export/
│   ├── textures/
│   ├── audio/
│   ├── fonts/
│   └── localization/
├── data/
│   ├── items/
│   ├── recipes/
│   ├── economy/
│   ├── levels/
│   ├── tasks/
│   └── localization/
├── scenes/
│   ├── boot/
│   ├── main/
│   ├── merge_board/
│   ├── ui/
│   ├── shop/
│   └── popups/
├── scripts/
│   ├── core/
│   ├── merge/
│   ├── inventory/
│   ├── economy/
│   ├── progression/
│   ├── save/
│   ├── services/
│   └── ui/
└── tests/
```

## Architecture

Use data-driven gameplay:

- Item definitions are resources/data rows.
- Merge recipes are data.
- Board state is serializable.
- Economy and reward tables are data.
- UI reads from gameplay state but does not own rules.

Suggested autoloads:

```text
GameApp
DataRegistry
SaveManager
SceneRouter
ServiceHub
AudioManager
```

Suggested core modules:

```text
MergeBoardModel
MergeRuleResolver
ItemInstance
InventoryModel
TaskModel
EconomyModel
ProgressionModel
RewardResolver
```

## Migration Phases

### Phase 0: Reverse Engineering Baseline

Deliverables:

- IL2CPP dump output.
- Asset export output.
- Class and data map for `Assembly-CSharp`.
- Known entry flow from `GameManager.OnGameStart`.

### Phase 1: Data Import

Deliverables:

- Item catalog imported.
- Merge chain data imported.
- Localization imported.
- Basic asset references resolved.

### Phase 2: Merge Board Prototype

Deliverables:

- Board grid.
- Item spawn.
- Drag/drop.
- Merge validation.
- Merge result.
- Undo/debug commands if useful.
- Deterministic unit tests for merge rules.

### Phase 3: Progression and Economy

Deliverables:

- Tasks/orders.
- Rewards.
- Soft currency.
- Energy/timer systems if present.
- Level gating.

### Phase 4: Save/Load

Deliverables:

- Local save format.
- Versioned migration.
- Board state serialization.
- Inventory/economy/progression serialization.

### Phase 5: UI Recreation

Deliverables:

- Main screen.
- Board HUD.
- Inventory and shop screens.
- Reward popups.
- Settings.
- Localization switch for available languages.

### Phase 6: Platform Services

Deliverables:

- Ads abstraction.
- IAP abstraction.
- Analytics abstraction.
- Crash/log reporting.
- Optional deep links.
- Optional cloud save.

## Coding Rules For Reimplementation

- Keep gameplay rules testable without Godot scenes.
- Keep external services behind interfaces.
- Do not hardcode item chains in UI scripts.
- Preserve a mapping from recovered Unity class/data names to Godot equivalents.
- Prefer simple data formats first: JSON or CSV for imported tables, `.tres` later if useful.

## Traceability Template

Use this table when a recovered Unity system is ported:

| Unity source | Evidence | Godot file | Status | Notes |
| --- | --- | --- | --- | --- |
| `Assembly-CSharp/GameManager.OnGameStart` | IL2CPP dump | `scripts/core/game_app.gd` | planned | Boot flow target |
