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

## Prefab-First UI Restoration

For `UIOutGame` and other major screens, use this order before changing visible Godot placement:

1. Extract a focused layout report from AssetRipper prefabs and scenes.
2. Record the exact RectTransform chain for each target component, including parent transforms.
3. Record sprite, material, text, and button component references for the same nodes.
4. Inspect related AnimationClip bindings for show/hide or state changes.
5. Only then update Godot layout or asset binding.
6. Use `capture-outgame-popups.bat` screenshots to verify the result and catch regressions.

Do not promote a hand-placed sprite to the main UI unless the owning Unity component or runtime code path is known. Screenshot matching is acceptable for verification and for flagging issues, but not as the primary placement source.

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
.\tools\Godot\Godot_console.exe --path .\godot-project --resolution 540x960 --quit-after 480 -- --restored-startup --startup-capture-dir=D:\work\openclaw-workspace\arpg\merge\reverse-output\startup-captures
```

Expected outputs:

```text
reverse-output/startup-captures/01-bootservices.png
reverse-output/startup-captures/02-gamestartload.png
reverse-output/startup-captures/03-reloadscene.png
reverse-output/startup-captures/04-runtimecanvas.png
reverse-output/startup-captures/05-uiloading.png
reverse-output/startup-captures/06-uisceneloading.png
reverse-output/startup-captures/07-uisceneloading-late.png
reverse-output/startup-captures/08-maidlobbyloading.png
reverse-output/startup-captures/09-outgame.png
```

Use the gameplay capture helper after any change to `UIOutGame` transitions, `UIInGame`, or portrait gameplay layout:

```powershell
.\capture-gameplay.bat
```

It runs the same restored startup flow with `--auto-enter-ingame` and writes `10-ingame.png` plus the Bag popup regression frame `11-inventory.png` under `reverse-output/gameplay-captures/`.

Use the out-game popup capture helper after changes to `UIOutGame` home layout or any split out-game popup:

```powershell
.\capture-outgame-popups.bat
```

It runs the restored startup flow with `--auto-capture-outgame-popups` and writes these frames under `reverse-output/outgame-captures/`:

```text
10-outgame-home.png
11-outgame-shop.png
12-outgame-story.png
13-outgame-furniture.png
14-outgame-mail.png
15-outgame-settings.png
16-outgame-bag.png
17-outgame-menu.png
```

Use the character Spine browser when validating recovered maid/customer skeleton assets:

```powershell
.\run-spine-browser.bat
```

To regenerate the browser data from AssetRipper raw TextAssets:

```powershell
node .\scripts\reverse\bake_character_spine_previews.mjs --fps=8 --max-duration=0.9 --max-clips=2
```

To capture the browser regression frame:

```powershell
.\capture-spine-browser.bat
```

It writes:

```text
reverse-output/spine-browser-captures/18-character-spine-browser.png
```

Checks:

- `01-bootservices.png` should show the recovered pre-UI service order: runtime initialize hooks, `GameManager`, high score service, login/network gates, `ReloadManager`, and `UIManager`.
- `02-gamestartload.png` should show the recovered `GameManager.OnGameStartLoad` operation order before the Reload scene becomes visible.
- `03-reloadscene.png` should show the recovered `Reload.unity` Canvas, CanvasScaler, SafeArea, and `UILoading` mount order.
- `04-runtimecanvas.png` should show the recovered runtime Canvas/SafeArea bootstrap structure before the first visible loading prefab.
- `05-uiloading.png` should show the recovered app loading page and bottom progress bar.
- `06-uisceneloading.png` should show the recovered `kokomi_Loading` Spine character, background, and progress bar.
- `07-uisceneloading-late.png` should differ from `06-uisceneloading.png`; if the files are visually identical, inspect the baked frame clock and `SceneLoadingReferenceScreen._draw_spine_baked_animation`.
- `08-maidlobbyloading.png` should show the recovered `UIMaidLobbyLoading` structural transition after scene loading.
- `09-outgame.png` should show the first `UIOutGame` home shell after startup: top wallet HUD, cafe backdrop, village rebuild progress, maid stand-in/dialog, Merge/Maid entry buttons, and bottom app navigation.
- `10-ingame.png` from `capture-gameplay.bat` should show the first portrait gameplay shell after `UIOutGame/InGameBtn`, with the board centered, a producer auto-selected for regression, the recovered top `Request/RequestList` strip visible, and the recovered bottom operation bar showing Bag, Cafe, `UIBlockInfo`, `Btn_BoxOpen`, `Btn_Use`, and `Btn_CoolTime` instead of standalone debug buttons.
- `11-inventory.png` from `capture-gameplay.bat` should show the first-pass `UIPopup_Inventory` shell opened by the recovered Bag hit region, with separate `ProduceInventory` and `NormalInventory` slot sections.
- `10-outgame-home.png` through `17-outgame-menu.png` from `capture-outgame-popups.bat` should cover the current asset-backed `UIOutGame` home screen and every split first-pass out-game popup.
- `18-character-spine-browser.png` from `capture-spine-browser.bat` should show the list of recovered character skeletons on the left and a textured animated Spine preview in the main pane.
- The `UIOutGame/InGameBtn` hit region should be clickable in `run-game.bat` and should enter the playable merge-board prototype. For headless validation, run `.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame`.
- The `UIOutGame/MaidLobbyBtn` hit region should be clickable in `run-game.bat` and should enter the first `UIMaidLobby` shell. For headless validation, run `.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 9 -- --restored-startup --auto-enter-maid-lobby`; with a startup capture directory it writes `10-maidlobby.png`, `11-maidlobbyselect.png`, and `12-maiddialog.png`.
- If the second screen shows only the progress bar, first check UV handling. The baked Spine UVs are normalized `0..1`; do not multiply them by texture page size before passing them to Godot `draw_polygon`.
- If `09-outgame.png` shows disassembled body parts, a Spine atlas page has been incorrectly drawn as a static portrait. Keep the maid area as a placeholder until the reusable Spine renderer is wired for LD maid assets.
