# Reverse Tooling and Process

This file records the tools, commands, inputs, outputs, and process used during reverse engineering. Keep it updated whenever a new tool is tried or a generated output is produced.

## Canonical Input Files

Never modify these original extracted APK files:

| Purpose | Path |
| --- | --- |
| Android manifest | `resources/AndroidManifest.xml` |
| IL2CPP binary | `resources/lib/arm64-v8a/libil2cpp.so` |
| IL2CPP metadata | `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat` |
| Main Unity data | `resources/assets/bin/Data/data.unity3d` |
| Packed Unity data | `resources/assets/bin/Data/datapack.unity3d` |
| Unity resources | `resources/assets/bin/Data/resources.resource` |
| Addressables catalog | `resources/assets/aa/catalog.bin` |
| Addressables settings | `resources/assets/aa/settings.json` |
| Local bundles | `resources/assets/aa/Android/*.bundle` |

## Output Directory Convention

Generated reverse output should go under:

```text
reverse-output/
├── il2cpp/
├── assets/
├── addressables/
├── apk/
├── runtime/
└── logs/
```

Suggested rule: each tool run gets a timestamped subfolder.

Example:

```text
reverse-output/il2cpp/2026-05-21-il2cppdumper/
reverse-output/assets/2026-05-21-assetstudio-data/
reverse-output/logs/2026-05-21-initial-scan.md
```

## Tool Registry

Record installed or planned tools here.

| Tool | Purpose | Status | Version | Location | Notes |
| --- | --- | --- | --- | --- | --- |
| Il2CppDumper | Dump IL2CPP metadata and method maps | ready | v6.7.46 | `tools/Il2CppDumper/Il2CppDumper.exe` | Use with `libil2cpp.so` and `global-metadata.dat` |
| Cpp2IL | Alternative IL2CPP analysis and pseudo-C# recovery | ready | 2022.0.7 | `tools/Cpp2IL/Cpp2IL.exe` | Useful if Il2CppDumper output is incomplete |
| Il2CppInspector | IL2CPP structure and IDA/Ghidra scripts | planned | unknown | unknown | Optional deeper analysis |
| Ghidra | Native code analysis | ready | 12.1 | `tools/Ghidra/ghidra_12.1_PUBLIC/ghidraRun.bat` | Headless analyzer also available at `support/analyzeHeadless.bat` |
| AssetStudio | Export Unity assets | ready | v0.16.47 net6 | `tools/AssetStudio/AssetStudioGUI.exe` | May not fully support Unity 6000; use as first visual inventory attempt |
| AssetStudio CLI | Export Unity assets from command line | ready | net10 build | `D:/work/openclaw-workspace/arpg/tools/AssetStudio-net10.0-win/AssetStudio.CLI.exe` | Successfully exported Texture2D, Sprite, TextAsset, and JSON metadata from Unity 6000 data |
| UABEA | Inspect/edit Unity asset bundles | ready | v8 | `tools/UABEA/UABEAvalonia.exe` | Useful for bundle-level inspection |
| UnityPy | Scripted Unity asset extraction | planned | unknown | unknown | Good for repeatable extraction |
| AssetRipper | Higher-level Unity project reconstruction | ready | 1.3.14 | `tools/AssetRipper/AssetRipper.GUI.Free.exe` | Supports Unity 6000 range; likely best asset reconstruction candidate |
| apktool | APK resources and manifest decode | candidate | unknown | unknown | Current tree already appears decoded |
| jadx | Java/Kotlin decompilation | candidate | unknown | unknown | Current `sources/` already contains Java output |
| Godot | Target engine | ready | 4.6.2 stable | `tools/Godot/Godot_console.exe` | Console runner verified with `--version` |

## Current Local Tool Check

Checked on 2026-05-21 from `D:/work/openclaw-workspace/arpg/merge`.

| Tool | Found | Path |
| --- | --- | --- |
| dotnet | no | |
| java | yes | `C:/Program Files/Common Files/Oracle/Java/javapath/java.exe` |
| python | yes | `C:/Python314/python.exe` |
| git | yes | `D:/Program Files/Git/cmd/git.exe` |
| ghidraRun | no | |
| Il2CppDumper | no | |
| Cpp2IL | no | |
| AssetStudio | no | |
| apktool | no | |
| jadx | no | |

Also searched under `D:/work/openclaw-workspace` for common reverse tool names and did not find local copies.

Updated on 2026-05-21:

- User provided downloaded archives in `D:/work/openclaw-workspace/arpg/tools`.
- Archives/executables were copied or extracted into this workspace under `tools/`.
- Il2CppDumper, Cpp2IL, Ghidra headless, and Godot console were verified by help/version output.
- AssetStudio, AssetRipper, and UABEA GUI executable paths were verified.
- `apktool` and `jadx` are still absent, but not currently blocking because decoded `resources/` and `sources/` are already present.

## Process Log

Add entries newest-last.

### 2026-05-21 Initial Workspace Scan

Inputs:

- `resources/`
- `sources/`
- `resources/AndroidManifest.xml`
- `resources/assets/bin/Data/ScriptingAssemblies.json`
- `resources/assets/bin/Data/RuntimeInitializeOnLoads.json`
- `resources/assets/aa/settings.json`

Commands/process:

- Listed root directories.
- Counted file extensions.
- Checked manifest package/version/activity.
- Checked Unity scripting assemblies.
- Checked runtime initialize methods.
- Checked Unity data and native library sizes.
- Checked Addressables settings and local bundles.

Findings:

- Package is `puzzle.merge.maid.cafe`.
- App name is `MergeMaidCafe`.
- Version is `0.2.74`, versionCode `74`.
- Main Activity is `com.singular.unitybridge.SingularUnityActivity`.
- Unity version string appears as `6000.0.73f1`.
- The game uses IL2CPP.
- Main game logic is expected in `libil2cpp.so` plus `global-metadata.dat`.
- `Assembly-CSharp.dll` is listed in `ScriptingAssemblies.json`.
- Startup methods include `GameManager.OnGameStart` and `HighscoreService.HighscoreService.OnGameStart`.
- Java `sources/` mostly contains third-party SDKs; app package only has `R.java`.

Outputs:

- `docs/reverse-godot/README.md`
- `docs/reverse-godot/project-map.md`
- `docs/reverse-godot/reverse-workflow.md`
- `docs/reverse-godot/unity-asset-inventory.md`
- `docs/reverse-godot/runtime-and-services.md`
- `docs/reverse-godot/godot-reimplementation-plan.md`
- `docs/reverse-godot/game-systems-backlog.md`
- `docs/reverse-godot/open-questions.md`
- `docs/reverse-godot/tooling-and-process.md`

### 2026-05-21 Roadmap and Output Directory Setup

Inputs:

- Existing documentation under `docs/reverse-godot/`
- Canonical Unity/IL2CPP inputs under `resources/`

Commands/process:

- Checked local availability of common reverse tools.
- Searched nearby workspace folders for tool executables.
- Created reverse output directories.
- Added implementation roadmap.

Findings:

- Java, Python, and Git are available locally.
- `.NET`, Il2CppDumper, Cpp2IL, AssetStudio, AssetRipper, UABEA, Ghidra, apktool, and jadx are not currently available on PATH.
- No nearby portable copies of common reverse tools were found under `D:/work/openclaw-workspace`.
- First real reverse step is blocked until an IL2CPP dump tool and a Unity asset extraction tool are provided or installed.

Outputs:

- `reverse-output/il2cpp/`
- `reverse-output/assets/`
- `reverse-output/addressables/`
- `reverse-output/apk/`
- `reverse-output/runtime/`
- `reverse-output/logs/`
- `docs/reverse-godot/implementation-roadmap.md`

### 2026-05-21 Manual Tool Drop Verification

Inputs:

- `D:/work/openclaw-workspace/arpg/tools`

Commands/process:

- Listed manually downloaded tool archives and executables.
- Extracted/copy tools into this workspace's `tools/` directory.
- Verified CLI/help output for:
  - `tools/Il2CppDumper/Il2CppDumper.exe`
  - `tools/Cpp2IL/Cpp2IL.exe`
  - `tools/Ghidra/ghidra_12.1_PUBLIC/support/analyzeHeadless.bat`
  - `tools/Godot/Godot_console.exe`
- Verified GUI executable paths for:
  - `tools/AssetStudio/AssetStudioGUI.exe`
  - `tools/AssetRipper/AssetRipper.GUI.Free.exe`
  - `tools/UABEA/UABEAvalonia.exe`

Findings:

- IL2CPP tooling is ready.
- Unity asset tooling is ready.
- Ghidra is ready and Java is sufficient.
- Godot is ready.
- `apktool` and `jadx` are not installed, but they are not immediate blockers.

Outputs:

- `tools/Il2CppDumper/`
- `tools/Cpp2IL/`
- `tools/Cpp2IL-net472/`
- `tools/AssetStudio/`
- `tools/AssetRipper/`
- `tools/UABEA/`
- `tools/Ghidra/`
- `tools/Godot/`

### 2026-05-21 Il2CppDumper First Dump

Tool:

- `tools/Il2CppDumper/Il2CppDumper.exe`

Inputs:

- `resources/lib/arm64-v8a/libil2cpp.so`
- `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`

Command:

```powershell
.\tools\Il2CppDumper\Il2CppDumper.exe `
  .\resources\lib\arm64-v8a\libil2cpp.so `
  .\resources\assets\bin\Data\Managed\Metadata\global-metadata.dat `
  .\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper
```

Outputs:

- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/dump.cs`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/il2cpp.h`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/script.json`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/stringliteral.json`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/DummyDll/`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/class-index.csv`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/gameplay-class-index.csv`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/keyword-counts.csv`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/key-class-members.csv`

Findings:

- Metadata version: 31.
- IL2CPP version: 31.
- Code registration found at `5829ea8`.
- Metadata registration found at `5a54cf0`.
- Tool warned that the file may be protected, but dump completed.
- Final process exit was nonzero because the tool attempted `Press any key to exit` in a redirected console.
- Extracted 17,435 type declarations from `dump.cs`.
- Extracted 3,888 gameplay/system keyword type declarations.
- High-priority classes include `InGame_BlockManager`, `InGame_ItemBlock`, `InGame_DragManager`, `InGame_MapManager`, `MapDataManager`, `RequestDataManager`, `RewardDataManager`, `ShopDataManager`, `TableDataManager`, and `UserDataManager`.

Follow-up:

- Use `docs/reverse-godot/il2cpp-code-map.md` as the current code map.
- Drill into key class member CSV for board, request, reward, and save behavior.

### 2026-05-21 Asset Tool Automation Probe

Tools:

- `tools/AssetRipper/AssetRipper.GUI.Free.exe`
- `tools/AssetStudio/AssetStudioGUI.exe`
- `tools/UABEA/UABEAvalonia.exe`

Commands/process:

- Ran AssetRipper `--version` and `--help`.
- Ran AssetStudioGUI `--help`, which timed out because it is GUI-oriented.
- Listed UABEA files and executable.

Findings:

- AssetRipper version: `AssetRipper.GUI.Web 1.3.14+7534ed93857d1ef4464bab6e3c7a13777529f94d`.
- AssetRipper supports `--headless`, but this means "do not launch browser automatically"; it still runs as a local web GUI/server, not a simple one-shot CLI export.
- AssetStudio and UABEA available builds are GUI-oriented.
- Asset extraction remains ready but needs either interactive GUI operation or a scripted Unity asset parser approach.

Follow-up:

- Prefer AssetRipper headless local web workflow for Unity 6000 asset reconstruction.
- If a fully scripted inventory is needed, evaluate UnityPy or write a small extractor using available libraries.

### 2026-05-21 AssetStudio CLI Data Export

Operator:

- Codex

Tool:

- `D:/work/openclaw-workspace/arpg/tools/AssetStudio-net10.0-win/AssetStudio.CLI.exe`

Inputs:

- `D:/work/openclaw-workspace/arpg/merge/resources/assets/bin/Data`
- `D:/work/openclaw-workspace/arpg/merge/reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/DummyDll`

Common options:

```powershell
--game Normal `
--unity_version 6000.0.73f1 `
--dummy_dlls D:/work/openclaw-workspace/arpg/merge/reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/DummyDll `
--logger_flags Debug,Info,Warning,Error
```

Commands/process:

- Ran a full JSON metadata export with `--export_type JSON --map_op All --map_type JSON --map_name assets_map`.
- Tried a combined multi-type `Convert` export for `Texture2D,Sprite,AudioClip,TextAsset`; this produced no files.
- Re-ran targeted single-type exports for `Texture2D`, `Sprite`, and `TextAsset` using `--export_type Convert`.
- Generated a CSV inventory from the successful exported files.

Outputs:

| Output | Files | Size |
| --- | ---: | ---: |
| `reverse-output/assets/assetstudio-cli-data-json/` | 130,943 | 130.11 MB |
| `reverse-output/assets/assetstudio-cli-data-texture2d/` | 1,798 | 444.07 MB |
| `reverse-output/assets/assetstudio-cli-data-sprite/` | 3,045 | 274.18 MB |
| `reverse-output/assets/assetstudio-cli-data-textasset/` | 1,235 | 13.37 MB |
| `reverse-output/assets/assetstudio-cli-inventory.csv` | 1 | 0.77 MB |

Logs:

- `reverse-output/logs/assetstudio-cli-data-json.log`
- `reverse-output/logs/assetstudio-cli-data-texture2d.log`
- `reverse-output/logs/assetstudio-cli-data-sprite.log`
- `reverse-output/logs/assetstudio-cli-data-textasset.log`
- `reverse-output/logs/assetstudio-cli-data-convert.log`

Findings:

- AssetStudio CLI can load `data.unity3d`, `datapack.unity3d`, and Unity default resources when Unity version is forced to `6000.0.73f1`.
- Single-type exports are reliable for the current first pass.
- Exported gameplay-visible assets include board backgrounds, board tiles, block/lock visuals, currency icons, cafe art, maid/character images, atlas files, and Spine `.skel`/`.atlas` text assets.
- Texture output is PNG-only in this run.
- Sprite output is PNG-only in this run.
- TextAsset output is `.dat`; many names indicate original `.skel`, `.atlas`, transform data, and catalog/config-like payloads.

Problems:

- The combined multi-type `Convert` attempt exported nothing.
- The full JSON pass produced useful metadata but logged duplicate-name/file-contention errors for some `MonoBehaviour` JSON files.
- Several `TextAsset` Spine/atlas/transform files logged export errors, but the pass completed and exported 1,235 files. Use AssetRipper/UABEA for any missing animation text assets.
- Unity default resources produced some `EndOfStreamException` load warnings; this does not block gameplay asset extraction.

Follow-up:

- Use `assetstudio-cli-inventory.csv` to identify item icons, board tiles, UI panels, character art, and localization/config files.
- Run AudioClip and Mesh exports as separate single-type passes if needed.
- Use AssetRipper primary-content export as a second source of truth for prefab, scene, MonoBehaviour, and animation structure.

### 2026-05-21 AssetRipper TextAsset Recovery Check

Operator:

- User exported primary content with AssetRipper.
- Codex checked output completeness.

Input/output:

- `reverse-output/assets/assetripper-primary/`

Process:

- Counted AssetRipper primary-content files and extensions.
- Extracted 92 failed TextAsset names from `reverse-output/logs/assetstudio-cli-data-textasset.log`.
- Checked those names against `reverse-output/assets/assetripper-primary/Assets/TextAsset`.
- Used strict matching for `name.bytes`, `name.txt`, or `name.json`.

Outputs:

- `reverse-output/assets/assetripper-primary-missing-check.csv`
- `reverse-output/assets/assetripper-primary-textasset-strict-check.csv`

Findings:

- AssetRipper primary content contains 10,224 files, about 882.30 MB.
- It includes 1,370 `.bytes` files under exported content.
- All 92 TextAsset names that failed in AssetStudio CLI were found in AssetRipper output.
- Strict missing count is 0.
- Recovered source-like TextAssets are under `reverse-output/assets/assetripper-primary/Assets/TextAsset/`.

Follow-up:

- For Spine and transform data, prefer AssetRipper `.bytes` files over AssetStudio `.dat` files when AssetStudio logged an export error.
- Rename or copy selected `.skel.bytes` / `.atlas.bytes` files to `.skel` / `.atlas` only inside a derived Godot import workspace, not in the reverse-output source archive.

### 2026-05-21 Godot Prototype Baseline

Tool:

- `tools/Godot/Godot_console.exe`
- Version: 4.6.2 stable

Inputs:

- Exported sprites from `reverse-output/assets/assetstudio-cli-data-sprite/Sprite`
- Current reverse docs and IL2CPP class map

Process:

- Created `godot-project/`.
- Copied a minimal subset of exported board, currency, and block sprites.
- Created `project.godot`, `scenes/main.tscn`, data JSON files, and GDScript models/services.
- Ran Godot import and headless project load validation.

Commands:

```powershell
.\tools\Godot\Godot_console.exe --headless --import --path .\godot-project
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --quit-after 2
```

Outputs:

- `godot-project/project.godot`
- `godot-project/scenes/main.tscn`
- `godot-project/scripts/main.gd`
- `godot-project/scripts/models/block_catalog.gd`
- `godot-project/scripts/models/merge_board_model.gd`
- `godot-project/scripts/services/save_manager.gd`
- `godot-project/data/blocks.json`
- `godot-project/data/initial_board.json`
- `docs/reverse-godot/godot-prototype.md`

Findings:

- The project imports assets and loads headlessly with no reported errors after running `--import`.
- The prototype supports board rendering, drag/drop movement, same-id merges, AP-consuming spawn, and JSON save/load.
- Current block chain is placeholder data using exported event candy sprites; it must be replaced with recovered block table data.

### 2026-05-21 Table Schema Recovery

Inputs:

- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/dump.cs`
- AssetStudio JSON export
- AssetRipper primary/main exports

Process:

- Searched AssetStudio/AssetRipper output for `Table_Block`, `Table_Item`, `Table_Request`, `Table_SeriouslyMerge`, and related terms.
- Confirmed table components exist in MonoBehaviour JSON, but current exports only include names/script references, not row data.
- Extracted table schemas from IL2CPP `dump.cs`.
- Tried Cpp2IL for method body recovery, but this build crashed while parsing Unity version `6000.0.73f1`.

Outputs:

- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/table-data-fields.csv`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/excel-table-schema.csv`
- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/key-table-row-fields.csv`
- `docs/reverse-godot/data-table-schema.md`
- `godot-project/tools/README.md`

Findings:

- The game uses `ExcelImporterRoot` ScriptableObject tables.
- `Table_Block` contains `List<BlockTableData>` and related drop/producer/bubble/collection lists.
- `BlockTableData` exposes the core fields needed for Godot: `ID`, `GroupName`, `Level`, `BlockName`, `BlockImage`, `BlockType`, `ProduceEnergy`, `CoolTime`, `IsActiveMerge`, and more.
- Merge chain can be derived from `GroupName + Level`.
- Real table row data was not recovered from AssetRipper Primary Content or Unity Project YAML, but was recovered from AssetStudio `MonoBehaviour` Raw export.

Follow-up:

- Decode remaining `Table_Block` child lists from `Table_Block.dat`.
- Inspect native `TableDataManager.LoadTable_Block` around RVA `0x2CA7620` to confirm numeric tail layout.

### 2026-05-21 AssetRipper Full Unity Project Check

Operator: Codex
Tool: AssetRipper

Input:

- `D:\work\openclaw-workspace\arpg\merge\resources\assets\bin\Data`

Output:

- `D:\work\openclaw-workspace\arpg\merge\reverse-output\assets\assetripper-main`

Findings:

- Export created `AuxiliaryFiles` and `ExportedProject`.
- Project size: 34,121 files, about 1.09 GB.
- `ExportedProject/Assets/Resources/table/*.asset` exists, including `Table_Block.asset`, `Table_Item.asset`, and `Table_Request.asset`.
- Table assets are still tiny YAML stubs, around 397-409 bytes each.
- Generated scripts in `ExportedProject/Assets/Scripts/Assembly-CSharp` are AssetRipper dummy classes; custom serialized fields are not reconstructed.
- Result: full Unity Project export is useful for assets/scenes/prefabs, but not sufficient for table rows.

### 2026-05-21 AssetStudio MonoBehaviour Raw Export

Operator: Codex
Tool: AssetStudio.CLI
Tool path:

- `D:\work\openclaw-workspace\arpg\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe`

Inputs:

- `D:\work\openclaw-workspace\arpg\merge\resources\assets\bin\Data`
- `D:\work\openclaw-workspace\arpg\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\DummyDll`

Command:

```powershell
& 'D:\work\openclaw-workspace\arpg\tools\AssetStudio-net10.0-win\AssetStudio.CLI.exe' `
  'D:\work\openclaw-workspace\arpg\merge\resources\assets\bin\Data' `
  'D:\work\openclaw-workspace\arpg\merge\reverse-output\assets\assetstudio-cli-data-monobehaviour-raw' `
  --game Normal `
  --unity_version 6000.0.73f1 `
  --dummy_dlls 'D:\work\openclaw-workspace\arpg\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\DummyDll' `
  --types MonoBehaviour `
  --export_type Raw `
  --map_op All `
  --logger_flags Debug,Info,Warning,Error
```

Outputs:

- `reverse-output/assets/assetstudio-cli-data-monobehaviour-raw/`
- `reverse-output/assets/derived/table_block_catalog.csv`
- `reverse-output/assets/derived/table_block_catalog.json`
- `godot-project/data/blocks.json`
- `reverse-output/logs/assetstudio-monobehaviour-raw.log`

Findings:

- Raw export produced 121,604 files, about 23 MB.
- `MonoBehaviour/Table_Block.dat` contains real serialized table data.
- The later all-assets Raw export produced a different `Table_Block.dat` payload with Chapter03/SubStory/Event records preserved.
- Prefer `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_Block.dat` for table decoding.
- Parsed 568 `BlockTableData` main-field rows from `Table_Block.dat`.
- Generated Godot catalog contains 74 non-currency chains and 541 blocks.
- Decoded all 12 `Table_Block` child lists into `reverse-output/assets/derived/table_block_children/*.csv`.

Known limits:

- Reliable fields: ID, category, subcategory, group, block type, level, tier, name key, image key.
- Child list field layout now aligns with `dump.cs` and byte stream end offset.
- Remaining work: attach child-list semantics to Godot systems and name enum values.
- AssetStudio `Dump` export failed because a concurrent Raw run locked `Maps/assets_map.bin`; this is a tooling concurrency issue, not proof that Dump is unusable.

### 2026-05-21 Table_Block Child List Decode

Operator: Codex
Script:

- `scripts/reverse/parse_table_block_child_lists.py`

Input:

- `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_Block.dat`

Outputs:

- `reverse-output/assets/derived/table_block_children/BlockCoolTimeTableData.csv` - 24 rows
- `reverse-output/assets/derived/table_block_children/BlockDropTableData.csv` - 260 rows
- `reverse-output/assets/derived/table_block_children/BlockBubbleDropTableData.csv` - 24 rows
- `reverse-output/assets/derived/table_block_children/BlockDesignedDropTableData.csv` - 65 rows
- `reverse-output/assets/derived/table_block_children/BlockProduceTableData.csv` - 117 rows
- `reverse-output/assets/derived/table_block_children/BlockProduceMsgTableData.csv` - 4 rows
- `reverse-output/assets/derived/table_block_children/BlockGrowProduceTableData.csv` - 8 rows
- `reverse-output/assets/derived/table_block_children/BlockSpineTableData.csv` - 16 rows
- `reverse-output/assets/derived/table_block_children/BlockMergeDropRateTableData.csv` - 12 rows
- `reverse-output/assets/derived/table_block_children/BlockMergeDropPoolTableData.csv` - 68 rows
- `reverse-output/assets/derived/table_block_children/BubbleRewardTableData.csv` - 29 rows
- `reverse-output/assets/derived/table_block_children/BlockCollectionTableData.csv` - 56 rows

Validation:

- Parser consumed the full file exactly: end offset `0x23284`, file size `0x23284`.
- This confirms the `Table_Block` list order and field widths are aligned.

### 2026-05-21 Godot Block Sprite Import

Operator: Codex
Script:

- `scripts/reverse/import_godot_block_sprites.py`

Inputs:

- `godot-project/data/blocks.json`
- `reverse-output/assets/assetstudio-cli-data-sprite/`

Outputs:

- `godot-project/assets/sprites/*.png`
- `godot-project/assets/sprites/*.png.import`
- `reverse-output/assets/derived/godot_block_sprite_import_manifest.json`

Findings:

- Requested 505 unique `sprite_key` PNGs from the recovered block catalog.
- Copied 505 PNGs from AssetStudio Sprite export.
- Missing sprite keys: 0.
- Rebuilt `blocks.json`; all 541 block entries now point to existing PNG files.
- Godot imported all sprites successfully; `godot-project/assets/sprites` now contains 520 PNG files and 520 `.import` files including UI/support images.

Validation:

```powershell
python .\scripts\reverse\import_godot_block_sprites.py
python .\scripts\reverse\build_godot_block_catalog.py
.\tools\Godot\Godot_console.exe --headless --import --path .\godot-project
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --quit-after 2
```

### 2026-05-21 Godot Producer Interaction Wiring

Operator: Codex

Inputs:

- `godot-project/data/blocks.json`
- `godot-project/data/block_rules.json`

Changes:

- `godot-project/scripts/models/merge_board_model.gd`
- `godot-project/scripts/main.gd`
- `godot-project/data/initial_board.json`

Findings:

- 105 producer rule IDs also exist in the recovered block catalog.
- Initial board now includes producer block `1101104`, which produces `1201101` through recovered `BlockProduceTableData`/drop rules.
- UI now has selected-block details and a `Produce` button.

Validation:

```powershell
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --quit-after 2
```

### 2026-05-21 Godot Launch Script and Producer Cooldown

Operator: Codex

Changes:

- Added `run-godot.bat`.
- Added `run-game.bat` for restored startup mode.
- Added producer AP cost and cooldown state in `MergeBoardModel`.
- Cooldown state is included in save/load data.

Run:

```powershell
.\run-godot.bat
.\run-game.bat
```

Validation:

- `.\run-godot.bat --headless --quit-after 1`

### 2026-05-21 Table_Npc Decode and Godot Character Catalog

Commands:

```powershell
python scripts\reverse\parse_table_npc.py
python scripts\reverse\build_godot_character_catalog.py
```

Inputs:

- `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_Npc.dat`
- `godot-project/assets/characters/`

Outputs:

- `reverse-output/assets/derived/table_npc/table_npc_decoded.json`
- `reverse-output/assets/derived/table_npc/table_npc_summary.json`
- `reverse-output/assets/derived/table_npc/*.csv`
- `godot-project/data/characters/npcs.json`
- `godot-project/data/characters/maids.json`
- `godot-project/data/characters/customers.json`
- `godot-project/data/characters/dialogs.json`

Result:

- Decoded 132 `NpcTableData` rows.
- Decoded 75 `MaidSkillTableData` rows.
- Decoded 140 `MaidLevelTableData` rows.
- Decoded 7 `MaidInfoTableData` rows.
- Decoded the first 1400 text-dialog `InGameNpcDialog` rows.
- Classified copied character PNGs by asset role: 47 complete Spine atlas pages, 32 atlas pages missing a copied `.skel.dat`, and 30 direct static PNGs.

Limit:

- `InGameNpcDialog` declares 1644 rows, but row 1400 changes into a mixed-format presentation/effect payload.
- Tail decode for customer detail rows, rewards, gifts, and loading scene rows is deferred to T026.

### 2026-05-21 Godot Character Profile UI

Commands:

```powershell
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --import
.\run-godot.bat --headless --quit-after 1
```

Inputs:

- `godot-project/data/characters/maids.json`
- `godot-project/data/characters/customers.json`
- `godot-project/assets/characters/`

Outputs:

- `godot-project/scripts/main.gd`
- `godot-project/assets/characters/**/*.png.import`
- `reverse-output/assets/derived/character_spine_asset_classification.csv`
- `reverse-output/assets/derived/character_spine_asset_classification.json`

Result:

- Added a right-side profile browser to the prototype.
- The browser switches between recovered maid and customer catalogs.
- It displays recovered direct static PNGs plus profile, skill, and unlock summaries.
- It does not render Spine atlas page PNGs as complete portraits; those entries show region/skeleton metadata until a Spine render path is implemented.
- Godot imported 109 character PNGs so runtime `load()` calls can resolve the copied project assets.

T026 note:

- A byte scan of the remaining `Table_Npc` tail found no direct plain `CustomerTableData` count/string boundary immediately after row 1400.
- Row 1400 begins a mixed dialog/presentation payload, so the remaining 244 declared dialog rows need a dedicated record parser before later list boundaries can be trusted.

### 2026-05-21 UI Layout Inventory

Command:

```powershell
python scripts\reverse\extract_ui_layout_inventory.py
```

Inputs:

- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/**/*.prefab`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Scenes/*.unity`

Outputs:

- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.csv`
- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.json`
- `reverse-output/assets/derived/ui_layout/startup_ui_candidates.json`
- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.csv`
- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.json`
- `docs/reverse-godot/ui-layout-analysis.md`

Result:

- Scanned 1,137 UI prefab files.
- Scanned 2 Unity scene files.
- Indexed 84,034 `RectTransform` records.
- First high-value boot/layout candidates: `Reload`, `Game`, `UIManager`, `UISceneLoading`, `UIMaidLobbyLoading`, `UIOutGame`, `UIInGame`.
- Generated focused node-path/anchor/size details for 9 startup layout sources, including `UILoading`.
- Recovered first static layout facts: `UILoading` is 1080 x 1920, `UISceneLoading` uses full-stretch root plus 2000 x 2000 centered Spine loading nodes, and `UIOutGame`/`UIInGame` roots are full-stretch.
- CanvasScaler reference resolution is still unconfirmed and requires runtime/code follow-up.

```powershell
.\run-godot.bat --headless --quit-after 1
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --quit-after 2
```

### 2026-05-21 Weighted Drop Selection

Operator: Codex

Change:

- `MergeBoardModel.produce_from_block()` now uses weighted random selection for normal `drops`.
- `designed_drops` remain deterministic until count-range semantics are mapped.

### 2026-05-21 Godot producer designed-drop queue pass

Command:

```powershell
.\run-godot.bat --headless --quit-after 1
```

Result:

- `MergeBoardModel` now expands recovered `BlockDesignedDropTableData.count_min/count_max` values into a shuffled per-producer-cell queue.
- Each Produce action consumes one queued designed drop; if the queue is empty, a new queue is generated from the current producer rule.
- Designed-drop queues are saved and loaded through the board save payload.
- Moving a producer cell carries its cooldown and designed-drop queue; merging clears stale per-cell producer state.
- Remaining unknown: producer charge/count caps are still not identified in the decoded fields and need native `TableDataManager.LoadTable_Block` confirmation.

### 2026-05-21 BlockTableData Tail Decode and Producer Energy Pass

Commands:

```powershell
python scripts\reverse\parse_table_block_raw.py
python scripts\reverse\build_godot_block_catalog.py
.\run-godot.bat --headless --quit-after 1
```

Evidence:

- `dump.cs` defines `BlockTableData.ProduceEnergy` at offset `0x5C` and `CoolTime` at offset `0x60`.
- `dump.cs` also defines runtime `ProduceBlockData.produceEnergy`, `dailyCoolTimeCount`, `startCoolTime`, `coolTimeMax`, and per-producer drop weight dictionaries.
- `InGame_ItemBlock.OnProduce(bool _isUseProduceEnergy = True, ...)` indicates produce energy is producer internal energy/capacity, not player AP.

Result:

- `parse_table_block_raw.py` now decodes the full 120-byte `BlockTableData` primitive tail into named fields.
- `build_godot_block_catalog.py` carries high-value tail fields into `godot-project/data/blocks.json`.
- `BlockCatalog.get_produce_energy()` exposes recovered producer energy.
- `MergeBoardModel` now initializes and saves per-cell remaining producer energy, decrements it by one per Produce, and still charges the prototype AP cost separately.
- `BlockCatalog.get_cooldown_seconds()` prefers recovered block-level `CoolTime` when present, falling back to `BlockCoolTimeTableData` group rules.

Remaining runtime work:

- Inspect `InGame_ItemBlock.SetProduceEnergyData`, `OnProduce`, and `InGame_MapManager.NewProduceBlock` to confirm refill/reset/open-cooldown edge cases.

### 2026-05-21 Producer Runtime Ghidra Target Index

Command:

```powershell
python scripts\reverse\extract_producer_runtime_notes.py
```

Outputs:

- `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/analysis/producer-runtime-methods.csv`
- `docs/reverse-godot/producer-runtime-notes.md`

Result:

- Extracted 28 producer-related native method targets from `dump.cs`.
- Extracted 30 producer-related field targets from `InGame_ItemBlock`, `ProduceBlockData`, and `BlockTableData`.
- High-priority Ghidra RVAs:
  - `InGame_ItemBlock.OnProduce`: `0x28B405C`
  - `InGame_ItemBlock.SetProduceEnergyData`: `0x28B5088`
  - `InGame_MapManager.NewProduceBlock`: `0x2AB000C`
  - `MapDataManager.SetNewProduceBlockData`: `0x2C5A1C8`
  - `MapDataManager.SetProduceBlockData_CoolTimeInfo`: `0x2C5AA7C`

Known limit:

- Il2CppDumper `dump.cs` has signatures and RVAs, not method bodies. Runtime semantics now require Ghidra/native decompilation at the generated RVA list.

### 2026-05-21 Character System Route Update

Evidence:

- AssetStudio inventory contains base maid textures for `Ch_Maid01` through `Ch_Maid07`.
- AssetStudio inventory contains maid costume textures for `Cos_Maid01` through `Cos_Maid07`, including seasonal variants.
- AssetStudio inventory contains customer textures for `Ch_Customer01` through `Ch_Customer15`.
- `dump.cs` contains `Table_Npc`, `NpcTableData`, `MaidInfoTableData`, `MaidLevelTableData`, `MaidSkillTableData`, `MaidGiftTableData`, `CustomerTableData`, `CustomerLikeLevelData`, `InGameNpcDialog`, `Table_MaidChat`, `Table_MaidAIChat`, and `Table_CustomerEpisode`.

Route update:

- Added confirmed Maid/NPC/customer systems to `game-systems-backlog.md`.
- Expanded M5 in `implementation-roadmap.md` to include character catalog/profile/dialog models.
- Added T023-T025 for character inventory, Godot data pipeline, and first-pass profile UI.

### 2026-05-21 Character Asset Inventory

Command:

```powershell
python scripts\reverse\inventory_character_assets.py
```

Outputs:

- `reverse-output/assets/derived/character_asset_inventory.csv`
- `reverse-output/assets/derived/character_asset_summary.json`
- `docs/reverse-godot/character-system-inventory.md`

Result:

- 483 character-related assets identified from the AssetStudio inventory.
- 37 base maid assets across Maid IDs 1-7.
- 146 maid costume assets across Maid IDs 1-7.
- 77 customer assets across Customer IDs 1-15.
- 14 maid/chat UI assets.
- 209 broader character UI, skin, and episode assets.

Next:

- Decode `Table_Npc.dat`, `Table_MaidChat.dat`, `Table_MaidAIChat.dat`, and `Table_CustomerEpisode.dat` from raw MonoBehaviour payloads.

### 2026-05-21 Godot Character Asset Import

Command:

```powershell
python scripts\reverse\import_godot_character_assets.py
```

Outputs:

- `godot-project/assets/characters/maid_base/`
- `godot-project/assets/characters/maid_costume/`
- `godot-project/assets/characters/customer/`
- `godot-project/assets/characters/maid_chat/`
- `reverse-output/assets/derived/godot_character_asset_import_manifest.json`

Result:

- Copied 274 first-pass character resource files into the Godot project, including static PNGs and available Spine `.atlas.dat` / `.skel.dat` companions.
- Missing source files: 0.
- This follows the project policy: keep raw exports in `reverse-output/`, but copy runtime-used assets into `godot-project/assets/`.

Validation:

```powershell
.\run-godot.bat --headless --quit-after 1
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --quit-after 2
```

### 2026-05-21 Godot UI Layout Reference Build

Command:

```powershell
python scripts\reverse\build_godot_ui_layout_reference.py
```

Inputs:

- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.json`

Outputs:

- `godot-project/data/ui_layout_reference.json`

Result:

- Converted recovered startup/root UI RectTransform details into a compact Godot-readable reference file.
- Included `UILoading`, `UISceneLoading`, `UIMaidLobbyLoading`, `UIOutGame`, and `UIInGame` sources.
- Added a prototype `UI Ref` selector so the Godot app can inspect source layout roots while rebuilding actual Control scenes.
- Added a scaled 1080 x 1920 wireframe preview Control for key RectTransforms in each selected source.
- Added a structural `UILoading` reference layer in Godot using recovered root, background, logo, loading bar, and version-label RectTransforms.
- Added `scripts/reverse/import_godot_loading_assets.py` and copied 11 first-pass loading/logo PNGs into `godot-project/assets/loading/`.
- Generated `reverse-output/assets/derived/godot_loading_asset_import_manifest.json`.
- Added restored startup flow in `run-game.bat` mode: the loading bar advances, status text changes, and the layer hides into the playable prototype.
- Added `UISceneLoading` restored startup phase using recovered layout data and an explicit Spine renderer placeholder for `SkeletonGraphic (kokomi_Loading)`.

Follow-up:

- Confirm CanvasScaler and SafeArea behavior from `UIManager`, `SafeArea`, and serialized Canvas components before treating positions as exact responsive layout.
- Resolve Spine logo renderers before treating the loading reference as fully visually accurate.

## Tool Run Template

Copy this section for every meaningful tool run.

```text
### YYYY-MM-DD Tool Name - Short Goal

Operator:
Tool:
Tool version:
Tool path:
Host OS:

Inputs:
- 

Command or UI steps:
```bash

```

Outputs:
- 

Findings:
- 

Problems:
- 

Follow-up:
- 
```

## Evidence Rules

- Record exact input paths.
- Record generated output paths.
- Record tool version whenever possible.
- Record command line or UI steps.
- Keep failed attempts; they prevent repeated dead ends.
- When a finding affects the Godot port, also update the relevant system document.
- Do not overwrite previous generated output unless it is intentionally disposable.

## Next Tool Runs

## 2026-05-21 - Import UISceneLoading Spine Loading Assets

Inputs:
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/TextAsset/kokomi_Loading.atlas.txt`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/TextAsset/kokomi_Loading.skel.bytes`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Texture2D/kokomi_Loading.png`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Texture2D/kokomi_Loading_2.png`

Commands:
```powershell
python scripts\reverse\import_godot_spine_loading_assets.py
python scripts\reverse\build_kokomi_loading_spine_rig.py
node scripts\reverse\bake_kokomi_loading_spine.mjs
.\tools\Godot\Godot_console.exe --headless --path .\godot-project --import
.\run-game.bat --headless --quit-after 5
.\run-godot.bat --headless --quit-after 1
```

Outputs:
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.atlas.txt`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.skel.bytes`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.png`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading_2.png`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.rig.json`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.baked.json`
- `reverse-output/assets/derived/godot_spine_loading_import_manifest.json`
- `reverse-output/assets/derived/kokomi_loading_spine_bake_manifest.json`

Findings:
- AssetRipper has the complete `kokomi_Loading` loading Spine evidence set: atlas text, binary skeleton, and both texture pages.
- The `.skel.bytes` string table identifies Spine `4.2.43` and includes region names plus bone-name samples such as `sub_root`, `Pelvis`, `Lower body_H`, `Skirt_H`, `body_1`, `body_2`, `nack`, and `Back_Ribbon_H`.
- `@esotericsoftware/spine-core@4.2.43` successfully parsed the binary skeleton: 383 bones, 111 slots, 2 animations (`Idle` 4.6667s and `Interaction` 2.5s).
- `bake_kokomi_loading_spine.mjs` bakes `Idle` at 30 FPS into 141 frames with original draw order, UVs, triangles, and world vertices.
- `UISceneLoading` now prefers `kokomi_Loading.baked.json` and renders baked Spine geometry directly. `kokomi_Loading.rig.json` remains only as a fallback when baked data is unavailable.

Follow-up:
- Add a baked `Interaction` clip or runtime clip switching once the original startup logic needs it.
- Generalize the baked Spine path before applying it to maid/customer Spine entries.

## 2026-05-21 - Bake Multiple UISceneLoading Spine Clips

Inputs:
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.atlas.txt`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.skel.bytes`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.png`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading_2.png`

Commands:
```powershell
node scripts\reverse\bake_kokomi_loading_spine.mjs
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 5 -- --restored-startup
.\capture-startup.bat
```

Outputs:
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.baked.json`
- `reverse-output/assets/derived/kokomi_loading_spine_bake_manifest.json`
- `reverse-output/startup-captures/02-uisceneloading.png`

Findings:
- `kokomi_Loading.baked.json` is now schema `openclaw-spine-baked-v2`.
- Legacy top-level `attachments`, `frames`, and `bake` fields are retained for compatibility.
- New `clips` data includes `Idle` with 141 frames / 111 attachments and `Interaction` with 76 frames / 112 attachments.
- Godot `SceneLoadingReferenceScreen` now reads `clips` when present and switches to `Interaction` during the middle scene-loading progress window, then returns to `Idle`.
- `capture-startup.bat` verified that `02-uisceneloading.png` displays the Interaction pose with the same recovered background/progress overlay.

Follow-up:
- Replace the hard-coded progress-window clip switch with the original runtime condition once `UISceneLoading` controller logic is mapped from IL2CPP.
- Promote the baked multi-clip reader into a reusable Spine renderer for maid/customer atlas pages.

## 2026-05-21 - Startup Screen Layout Recheck

Inputs:
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/UILoading.prefab`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/UISceneLoading.prefab`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.baked.json`

Commands:
```powershell
python scripts\reverse\build_godot_ui_layout_reference.py
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 5 -- --restored-startup
.\run-game.bat --headless --quit-after 5
```

Outputs:
- `godot-project/data/ui_layout_reference.json`
- `godot-project/scripts/loading_reference_screen.gd`
- `godot-project/scripts/scene_loading_reference_screen.gd`

Findings:
- `UILoading/LoadingBar` is root-space at anchor `(0.5, 0.0)`, anchored position `(0, 300)`, size `670 x 50`.
- `UILoading/LoadingBar/Fill Area/Image` is child-local and caused a wrong Godot fill position when interpreted as root-space.
- `UISceneLoading/SceneObjects/TypeA/SkeletonGraphic (kokomi_Loading)` is the real 2000 x 2000 character root; `Renderer*` children are stretch render helpers with zero size. Godot now resolves the character rect through its parent RectTransform chain.
- Baked `Idle` frame comparisons show large vertex deltas, confirming the Spine bake is animated.

Follow-up:
- Confirm original CanvasScaler/SafeArea runtime setup from IL2CPP.
- Capture visual screenshots from a non-headless Godot session if automated `--screenshot` remains unavailable.

## 2026-05-21 - UISceneLoading Screenshot Verification

Inputs:
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.baked.json`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading.png`
- `godot-project/assets/spine/loading/kokomi_Loading/kokomi_Loading_2.png`

Command:
```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --resolution 540x960 --quit-after 360 -- --restored-startup --startup-capture-dir=D:\work\openclaw-workspace\arpg\merge\reverse-output\startup-captures
```

Outputs:
- `reverse-output/startup-captures/01-uiloading.png`
- `reverse-output/startup-captures/02-uisceneloading.png`
- `reverse-output/startup-captures/03-uisceneloading-late.png`

Findings:
- The first screenshot after the layout fix showed `UISceneLoading` with only the progress bar and no character.
- Root cause: baked Spine UVs from `@esotericsoftware/spine-core` are normalized `0..1` texture coordinates; the Godot renderer incorrectly multiplied them by texture size before passing them to `draw_polygon`.
- After using normalized UVs directly, `02-uisceneloading.png` contains the full `kokomi_Loading` character and background.
- A later capture differs from the first scene-loading capture by 101,209 pixels (`diff_bounds=97,205-539,959`), confirming the second screen is animated rather than a static single frame.

Follow-up:
- Keep `--startup-capture-dir=<path>` as a local verification hook for future startup-screen regression checks.

## 2026-05-21 - Add UIOutGame Reference Layer

Inputs:
- `godot-project/data/ui_layout_reference.json`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/UIOutGame.prefab`

Commands:
```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 5 -- --restored-startup
.\capture-startup.bat
```

Outputs:
- `godot-project/scripts/out_game_reference_screen.gd`
- `reverse-output/startup-captures/04-outgame.png`

Findings:
- `UIOutGame` prefab has a compact first-pass structure: `UIMaidLD`, `Npc_Dialog`, `InGameBtn`, `MaidLobbyBtn`, and `UIVillageReBuild/Fillbar`.
- Godot now exposes an `OutGame Ref` toggle and restored startup shows the first `UIOutGame` reference layer after `UISceneLoading`.
- The first visual attempt accidentally drew a maid Spine atlas page as if it were a static portrait, producing disassembled body parts. The implementation was corrected to use an explicit placeholder until the reusable Spine renderer handles maid LD assets.

Follow-up:
- Replace the placeholder `UIMaidLD` area with real maid LD Spine playback.
- Map the original `UIOutGame` background/furniture assets before treating the screen as visually complete.

## 2026-05-21 - Canvas And SafeArea Layout Inventory

Inputs:
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Scenes/Reload.unity`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Scenes/Game.unity`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/BGCanvas.prefab`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/UIManager.prefab`
- startup UI focus prefabs: `UILoading`, `UISceneLoading`, `UIMaidLobbyLoading`, `UIOutGame`, `uiroot/UIOutGame`, `uiroot/UIInGame`

Commands:
```powershell
rg -n "m_UiScaleMode|m_ReferenceResolution|m_ScreenMatchMode|m_MatchWidthOrHeight|m_ScaleFactor|m_ReferencePixelsPerUnit|CanvasScaler" reverse-output/assets/assetripper-main/ExportedProject/Assets -g "*.prefab" -g "*.unity"
rg -n "CanvasScaler|referenceResolution|matchWidthOrHeight|screenMatchMode|SafeArea|UICanvas|UIRoot" reverse-output/il2cpp sources -g "*.cs"
python scripts\reverse\extract_canvas_layout_inventory.py
python -m py_compile scripts\reverse\extract_canvas_layout_inventory.py
```

Outputs:
- `scripts/reverse/extract_canvas_layout_inventory.py`
- `reverse-output/assets/derived/ui_layout/canvas_layout_inventory.json`
- `reverse-output/assets/derived/ui_layout/canvas_layout_inventory.csv`

Findings:
- The startup/UI focus set contains 104 `Canvas` components, 12 `CanvasScaler` components, 8 project `SafeArea` components, and 8 RectTransforms named `SafeArea`.
- `CanvasScaler` is present on `Reload.unity/Canvas`, `Game.unity/Canvas`, `Game.unity/BGCanvas`, `Game.unity/TouchEffectCanvas`, story canvases, and the matching `UIManager.prefab` canvases.
- `SafeArea` is present on `Canvas/SafeArea`, `BGCanvas/SafeArea`, and `UIStory/StoryGroup/StoryUICanvas/SafeArea`.
- AssetRipper did not preserve `CanvasScaler` serialized fields such as `m_ReferenceResolution`, `m_ScreenMatchMode`, or `m_MatchWidthOrHeight`; all 12 detected scaler components have no recovered scaler field values.
- IL2CPP dump confirms classes/properties for `UIManager.UICanvas`, `UIManager.UIBGCanvas`, `UIManager.SafeArea`, project `SafeArea`, and Unity `CanvasScaler`, but method bodies still need Ghidra/native analysis.

Follow-up:
- Use Ghidra on `UIManager.Initialize` and `SafeArea.Awake` to confirm exact CanvasScaler policy and safe-area anchor mutation.
- Keep Godot layout reconstruction based on recovered RectTransforms until runtime CanvasScaler values are confirmed.

## 2026-05-21 - UIOutGame Entry To Gameplay

Inputs:
- `godot-project/data/ui_layout_reference.json`
- `godot-project/scripts/out_game_reference_screen.gd`
- `godot-project/scripts/main.gd`

Commands:
```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup
.\capture-startup.bat
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame
```

Outputs:
- `godot-project/scripts/out_game_reference_screen.gd`
- `godot-project/scripts/main.gd`
- `reverse-output/startup-captures/04-outgame.png`

Findings:
- `run-game.bat` now reaches a restored `UIOutGame` screen and waits there instead of immediately exposing the debug/prototype controls.
- `OutGameReferenceScreen` derives hit regions from recovered RectTransforms for `InGameBtn`, `MaidLobbyBtn`, and `Btn_ToInteraction`.
- `InGameBtn` is wired to hide the out-game reference layer and show the current recovered merge-board prototype.
- `MaidLobbyBtn` and `Btn_ToInteraction` are recognized and produce status messages, but their target screens still need reconstruction.
- `--auto-enter-ingame` is a non-interactive validation hook for headless runs; it does not change the default `run-game.bat` manual click path.

Follow-up:
- Replace the current debug-styled merge-board panel with a restored `UIInGame` layout shell.
- Restore `MaidLobbyBtn` and maid interaction targets after `UIInGame` and maid LD Spine rendering are further along.

## 2026-05-21 - UIInGame Portrait Shell

Inputs:
- `godot-project/data/ui_layout_reference.json`
- `Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab`
- `godot-project/scripts/main.gd`

Commands:
```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame
.\capture-startup.bat
```

Outputs:
- `godot-project/scripts/ingame_reference_shell.gd`
- `godot-project/scripts/main.gd`

Findings:
- The `run-game.bat` portrait path now enters a 540 x 960 playable layout instead of the older 1280 x 720 debug layout.
- `InGameReferenceShell` reads the recovered `UIInGame` reference source and draws first-pass top wallet, request, bottom block-info, inventory, and lobby structure.
- The playable 7x7 merge board is centered in the portrait viewport, with selection/status and Produce controls below it.
- Desktop-only debug buttons, UI reference selector, and character browser are hidden in portrait gameplay mode but remain available in the wider development run.

Follow-up:
- Replace shell rectangles with recovered `UIInGame` textures and sprites as they are mapped.
- Move Produce, inventory, lobby, and request interactions onto the recovered `UIInGame` button regions.

## 2026-05-21 - UIInGame Action Regions

Inputs:
- `godot-project/data/ui_layout_reference.json`
- `godot-project/scripts/ingame_reference_shell.gd`
- `godot-project/scripts/main.gd`

Commands:
```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame
.\capture-startup.bat
```

Outputs:
- `godot-project/scripts/ingame_reference_shell.gd`
- `godot-project/scripts/main.gd`

Findings:
- `InGameReferenceShell` now derives bottom hit regions from recovered `UIInGame` RectTransforms.
- `Bottom/Lobby/GoToOutGame` is wired as the first working return path from InGame to `UIOutGame`.
- The shell exposes Produce, Bag, and Cafe labels over recovered bottom UI regions.
- Produce reuses the current recovered producer logic and updates the shell-selected block summary.
- Bag currently reports the pending inventory restore rather than opening a placeholder popup.

Follow-up:
- Replace the Produce fallback region with the exact original button once the correct `UIBlockInfo` action mapping is confirmed from runtime code.
- Restore the inventory popup/list after request/order and inventory data are mapped.

## 2026-05-21 - Gameplay Capture and Portrait Action Polish

Inputs:
- `godot-project/scripts/main.gd`
- `capture-startup.bat`
- recovered `UIInGame` hit regions in `godot-project/data/ui_layout_reference.json`

Commands:
```powershell
.\tools\Godot\Godot_console.exe --path .\godot-project --headless --quit-after 6 -- --restored-startup --auto-enter-ingame
.\capture-startup.bat
.\capture-gameplay.bat
```

Outputs:
- `capture-gameplay.bat`
- `reverse-output/gameplay-captures/05-ingame.png`

Findings:
- `capture-gameplay.bat` records the restored startup flow and automatically enters `UIInGame` for visual regression checks.
- `main.gd` now captures `05-ingame.png` when the recovered `UIOutGame/InGameBtn` path enters gameplay with `--startup-capture-dir`.
- Portrait gameplay hides the older standalone Produce debug button so Produce, Bag, and Cafe actions are driven by recovered `UIInGame` shell hit regions.
- Selection/status labels ignore mouse input, preventing helper text from blocking bottom-shell interaction.

Follow-up:
- Add exact recovered sprites/textures for `UIInGame` bottom action buttons after sprite GUID mapping is complete.
- Add `06-inventory.png` once the recovered inventory popup is wired.

Recommended next runs:

1. Run Il2CppDumper or Cpp2IL on `libil2cpp.so` and `global-metadata.dat`.
2. Export assets from `data.unity3d` and `datapack.unity3d` using AssetStudio or UnityPy.
3. Inspect `catalog.bin` and Addressables bundles.
4. Search dumped `Assembly-CSharp` for merge, board, item, order, save, reward, shop, ad, IAP, and tutorial classes.
