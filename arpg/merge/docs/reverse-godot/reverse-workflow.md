# Reverse Workflow

This workflow is intended to recover enough behavior and data to rebuild the game in Godot.

## Phase 1: Preserve Original Inputs

Keep these files unchanged and treat them as canonical inputs:

```text
resources/lib/arm64-v8a/libil2cpp.so
resources/assets/bin/Data/Managed/Metadata/global-metadata.dat
resources/assets/bin/Data/data.unity3d
resources/assets/bin/Data/datapack.unity3d
resources/assets/bin/Data/resources.resource
resources/assets/aa/catalog.bin
resources/assets/aa/Android/*.bundle
resources/AndroidManifest.xml
```

Recommended output locations for future generated data:

```text
reverse-output/il2cpp/
reverse-output/assets/
reverse-output/addressables/
reverse-output/notes/
```

Do not mix generated reverse output into `resources/` or `sources/`.

Every meaningful tool run should also be recorded in [Tooling and Process](tooling-and-process.md), including tool version, input paths, output paths, command line or UI steps, findings, and failed attempts.

## Phase 2: IL2CPP Metadata Dump

Use `libil2cpp.so` and `global-metadata.dat` together.

Candidate tools:

- Il2CppDumper
- Il2CppInspector
- Cpp2IL
- Ghidra or IDA for deeper native analysis after metadata recovery

Expected outputs:

- Type list
- Method list
- Field list
- Dummy DLLs
- `script.json` or equivalent symbol map
- Function address mapping

Immediate targets:

- `Assembly-CSharp`
- `GameManager`
- `HighscoreService`
- Merge board classes
- Item definitions
- Save/load classes
- Economy and reward classes
- Tutorial classes
- IAP and ad reward bridge classes
- Remote config or backend client classes

## Phase 3: Unity Asset Extraction

Use Unity-aware tooling against:

```text
resources/assets/bin/Data/data.unity3d
resources/assets/bin/Data/datapack.unity3d
resources/assets/bin/Data/resources.resource
resources/assets/bin/Data/sharedassets0.resource
resources/assets/aa/catalog.bin
resources/assets/aa/Android/*.bundle
```

Candidate tools:

- AssetStudio
- UABEA
- UnityPy
- AssetRipper

Expected outputs:

- Texture2D
- Sprite
- SpriteAtlas
- AudioClip
- TextAsset
- MonoBehaviour serialized data
- ScriptableObject data
- Prefabs
- Scenes
- Materials and shaders
- Localization tables

High-value asset types for Godot:

- Item icons and atlas textures
- Board/grid UI sprites
- Character/maid art
- Spine skeletons and atlases, if present
- Audio and music
- Localization tables
- JSON or binary TextAssets containing item/economy/config data

## Phase 4: Build the System Map

For every recovered system, record:

- Original class names and method names
- Data assets used by the system
- Runtime flow
- Save data fields
- External service dependencies
- Godot equivalent scene/script plan

Use [Game Systems Backlog](game-systems-backlog.md) as the tracking checklist.

## Phase 5: Rebuild in Godot

Recommended order:

1. Static data import pipeline.
2. Merge board simulation.
3. Inventory/item model.
4. Save/load.
5. UI shell.
6. Level/tasks/orders/progression.
7. Rewards/economy.
8. Audio, VFX, and polish.
9. Service replacement layer for ads/IAP/analytics.

Keep Godot code independent from Unity naming where possible, but maintain a mapping table for traceability.

## Godot Startup Verification

Fresh pull behavior:

- `godot-project/assets/**` contains the committed source PNG/Spine/JSON assets and `.import` metadata required by `run-game.bat`.
- `godot-project/.godot/imported/**` is Godot's generated texture cache, is ignored by git, and must not be committed.
- `run-game.bat` runs `Godot_console.exe --headless --import --path godot-project` before opening the restored startup window so a clean checkout regenerates `.ctex` texture imports automatically.

Use the restored startup capture helper after any change to `UILoading`, `UISceneLoading`, Spine baking, or texture import paths:

```powershell
.\capture-startup.bat
```

It runs:

```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --resolution 540x960 --quit-after 360 -- --restored-startup --startup-capture-dir=D:\work\openclaw-workspace\arpg\merge\reverse-output\startup-captures
```

Expected outputs:

```text
reverse-output/startup-captures/01-runtimecanvas.png
reverse-output/startup-captures/02-uiloading.png
reverse-output/startup-captures/03-uisceneloading.png
reverse-output/startup-captures/04-uisceneloading-late.png
reverse-output/startup-captures/05-maidlobbyloading.png
reverse-output/startup-captures/06-outgame.png
```

Use the gameplay capture helper after any change to `UIOutGame` transitions, `UIInGame`, or portrait gameplay layout:

```powershell
.\capture-gameplay.bat
```

It runs the same restored startup flow with `--auto-enter-ingame` and writes `07-ingame.png` under `reverse-output/gameplay-captures/`.

Checks:

- `01-runtimecanvas.png` should show the recovered runtime Canvas/SafeArea bootstrap structure before the first visible loading prefab.
- `02-uiloading.png` should show the recovered app loading page and bottom progress bar.
- `03-uisceneloading.png` should show the recovered `kokomi_Loading` Spine character, background, and progress bar.
- `04-uisceneloading-late.png` should differ from `03-uisceneloading.png`; if the files are visually identical, inspect the baked frame clock and `SceneLoadingReferenceScreen._draw_spine_baked_animation`.
- `05-maidlobbyloading.png` should show the recovered `UIMaidLobbyLoading` structural transition after scene loading.
- `06-outgame.png` should show the first `UIOutGame` reference layer after startup: maid layer, dialog box, bottom buttons, and village rebuild progress bar.
- `07-ingame.png` from `capture-gameplay.bat` should show the first portrait gameplay shell after `UIOutGame/InGameBtn`, with the board centered and bottom actions coming from the recovered `UIInGame` shell instead of standalone debug buttons.
- The `UIOutGame/InGameBtn` hit region should be clickable in `run-game.bat` and should enter the playable merge-board prototype. For headless validation, run `.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame`.
- If the second screen shows only the progress bar, first check UV handling. The baked Spine UVs are normalized `0..1`; do not multiply them by texture page size before passing them to Godot `draw_polygon`.
- If `06-outgame.png` shows disassembled body parts, a Spine atlas page has been incorrectly drawn as a static portrait. Keep the maid area as a placeholder until the reusable Spine renderer is wired for LD maid assets.
