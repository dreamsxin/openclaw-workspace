# Implementation Roadmap

This roadmap turns the reverse-engineering notes into an execution plan for rebuilding the game in Godot.

## Current State

Confirmed:

- APK has already been unpacked/decompiled into `resources/` and `sources/`.
- Unity IL2CPP inputs are present:
  - `resources/lib/arm64-v8a/libil2cpp.so`
  - `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`
- Unity data archives are present:
  - `resources/assets/bin/Data/data.unity3d`
  - `resources/assets/bin/Data/datapack.unity3d`
  - `resources/assets/bin/Data/resources.resource`
- Project documentation has started under `docs/reverse-godot/`.
- Reverse output directories have been created under `reverse-output/`.
- Initial AssetStudio CLI export has produced Texture2D, Sprite, TextAsset, JSON metadata, and a CSV asset inventory.
- Initial Godot prototype exists under `godot-project/`.

Current local tool availability:

| Tool | Available |
| --- | --- |
| Java | yes |
| Python | yes |
| Git | yes |
| .NET SDK/runtime | bundled with selected tools where needed |
| Il2CppDumper | yes |
| Cpp2IL | yes |
| AssetStudio | yes |
| AssetRipper | yes |
| UABEA | yes |
| Ghidra | yes |
| apktool | no |
| jadx | no |

## Execution Strategy

The work has two parallel tracks:

1. Reverse-engineering track: recover code structure, data, assets, and behavior.
2. Godot implementation track: build a clean replacement architecture and fill it with recovered rules/assets.

Do not wait for perfect reverse coverage before starting Godot. Start with a testable merge-board skeleton once item and board rules are known enough.

## Milestones

### M0: Workspace and Tooling Baseline

Goal: make the reverse process repeatable.

Deliverables:

- `reverse-output/` directory structure.
- Tool registry updated with actual installed tool paths.
- First IL2CPP tool selected.
- First Unity asset extraction tool selected.
- Every tool run logged in `tooling-and-process.md`.

Status: done for baseline tooling and first-pass exports.

### M1: IL2CPP Code Map

Goal: recover game class/method/type names and enough pseudo-code to understand gameplay systems.

Inputs:

- `libil2cpp.so`
- `global-metadata.dat`

Deliverables:

- Dummy DLLs or equivalent recovered assemblies.
- Method/type/field list.
- Function address map.
- `Assembly-CSharp` class inventory.
- Initial system map for boot, board, items, save, economy, ads, IAP.

Success criteria:

- `GameManager.OnGameStart` is located.
- Board/item/merge-related classes are identified.
- Save/load classes are identified.
- Config/data loading path is identified.

### M2: Unity Asset and Data Inventory

Goal: export and classify assets and serialized data.

Inputs:

- `data.unity3d`
- `datapack.unity3d`
- `resources.resource`
- Addressables catalog and bundles

Deliverables:

- Exported textures/sprites/audio/text assets.
- Scene/prefab inventory.
- ScriptableObject and MonoBehaviour data inventory.
- Localization table export.
- Candidate item icons and merge-chain assets.

Success criteria:

- Main UI/gameplay art can be located.
- Item icon atlas or individual item icons are identified.
- Data assets used by gameplay are identified or ruled out.

### M3: Gameplay Specification

Goal: convert reverse findings into a Godot-ready spec.

Deliverables:

- Board model spec.
- Item model spec.
- Merge recipe spec.
- Generator/spawner spec.
- Task/order spec.
- Economy/reward spec.
- Save schema.
- Service integration boundaries.

Success criteria:

- A deterministic merge-board prototype can be implemented without guessing core rules.

### M4: Godot Prototype

Goal: build a playable core loop without production services.

Deliverables:

- Godot project skeleton.
- Data import pipeline.
- Merge board scene.
- Drag/drop merge interaction.
- Item spawning.
- Local save/load.
- Minimal HUD.

Success criteria:

- User can open the game, interact with a board, merge items, and persist state.

### M5: Content and UI Reconstruction

Goal: rebuild the visible game flow.

Deliverables:

- Main screen flow.
- Popup system.
- Shop/reward screens.
- Maid/NPC/customer catalog import.
- Maid profile, level, skill, gift, costume, chat, and dialog data models.
- Customer catalog and customer episode/progression model.
- Localization integration.
- Audio and basic effects.
- Character/decoration presentation systems.

Success criteria:

- The prototype resembles the original user flow and can exercise progression.

### M6: Services and Release Layer

Goal: replace mobile SDK features cleanly.

Deliverables:

- Ads service.
- IAP service.
- Analytics service.
- Crash/log service.
- Optional notifications.
- Optional deep links.
- Android export settings.

Success criteria:

- Gameplay works without services in development.
- Services can be enabled per platform/build target.

## Immediate Next Tasks

| ID | Task | Status | Output |
| --- | --- | --- | --- |
| T001 | Create `reverse-output/` structure | done | `reverse-output/*` |
| T002 | Record current local tool availability | done | `tooling-and-process.md` |
| T003 | Install or provide IL2CPP dump tool | done | `tools/Il2CppDumper/`, `tools/Cpp2IL/` |
| T004 | Run first IL2CPP dump | done | `reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/` |
| T005 | Install or provide Unity asset extraction tool | done | `tools/AssetRipper/`, `tools/AssetStudio/`, `tools/UABEA/` |
| T006 | Run first asset inventory export | done | `reverse-output/assets/assetstudio-cli-data-*` |
| T007 | Create class inventory from IL2CPP output | done | `il2cpp-code-map.md`, `analysis/*.csv` |
| T008 | Create asset inventory from export output | done | `reverse-output/assets/assetstudio-cli-inventory.csv`, `unity-asset-inventory.md` |
| T009 | Start Godot project skeleton | done | `godot-project/`, `godot-prototype.md` |
| T010 | Identify real block/item table assets | done | `reverse-output/assets/assetstudio-cli-data-monobehaviour-raw/MonoBehaviour/Table_Block.dat` |
| T011 | Replace prototype merge chain with recovered data | done | `godot-project/data/blocks.json` |
| T012 | Export AssetRipper Unity Project for serialized table rows | done | `reverse-output/assets/assetripper-main/` |
| T013 | Inspect `TableDataManager.LoadTable_Block` if Unity Project rows are missing | pending | Ghidra notes |
| T014 | Decode `Table_Block` child lists and numeric tail fields | done | `scripts/reverse/parse_table_block_raw.py`, `scripts/reverse/parse_table_block_child_lists.py`, `reverse-output/assets/derived/table_block_children/*.csv` |
| T015 | Wire decoded production/drop/cooldown data into Godot gameplay services | done | `godot-project/data/block_rules.json`, `BlockCatalog.load_rules`, first-pass spawn/rule lookup |
| T016 | Map recovered block sprite keys into Godot assets | done | `scripts/reverse/import_godot_block_sprites.py`, 505 copied icons, `godot_block_sprite_import_manifest.json` |
| T017 | Build producer interaction and cooldown UI | done | first-pass producer selection, `Produce` button, deterministic recovered drop |
| T018 | Implement producer cooldown/cost/count state | done | 1 AP produce cost, cooldown timers, cooldown save/load |
| T019 | Implement weighted/random drop selection and production charges | done | weighted normal drops, designed-drop queues, and producer energy counters implemented |
| T020 | Map designed drop count ranges and producer charges | done | `count_min/count_max` queues and `BlockTableData.ProduceEnergy` per-cell counters wired into Godot |
| T021 | Inspect runtime producer methods for refill/open/cooldown semantics | in progress | Ghidra target index generated in `producer-runtime-notes.md` and `producer-runtime-methods.csv` |
| T022 | Decompile producer runtime targets in Ghidra | pending | Confirm energy decrement/refill, open-state, cooldown, and drop-weight mutation semantics |
| T023 | Inventory Maid/NPC/customer character tables and assets | done | first-pass asset/table inventory in `character-system-inventory.md`, `character_asset_inventory.csv`, `character_asset_summary.json` |
| T024 | Build Godot character catalog data pipeline | done | first-pass resources copied; `Table_Npc` static lists decoded; Godot character JSON generated with static-vs-Spine asset classification |
| T025 | Implement first-pass character/profile UI in Godot | done | right-side Maid/customer browser; static PNGs display directly, Spine atlas pages show metadata placeholders |
| T026 | Decode mixed-format character dialog/customer tail lists | in progress | initial tail scan shows row 1400 enters mixed dialog/presentation payload before remaining list boundaries |
| T027 | Implement Spine character render path | in progress | `kokomi_Loading.skel.bytes` is parsed by official `@esotericsoftware/spine-core@4.2.43`; `Idle` and `Interaction` are baked to exact world-vertex frames, rendered through Godot textured polygons with normalized UVs, and verified by startup screenshots; reusable renderer for other characters still pending |
| T028 | Inventory original Unity UI prefab layouts | done | 1,137 UI prefabs and 84,034 RectTransforms indexed in `ui-layout-analysis.md` |
| T029 | Map startup UI flow and Canvas scaling | in progress | startup focus layout details generated and converted into `godot-project/data/ui_layout_reference.json`; Canvas/SafeArea/CanvasScaler mount points indexed in `canvas_layout_inventory.*`; CanvasScaler reference-resolution fields still require runtime/native confirmation |
| T030 | Build first Godot UI layout reference screens | in progress | `run-game.bat` restored startup mode now flows through recovered `UILoading`, `UISceneLoading`, clickable `UIOutGame`, and clickable first `UIInGame` shell; remaining screens still pending |
| T031 | Add repeatable startup visual regression capture | done | `capture-startup.bat`, `--startup-capture-dir=<path>`, and workflow docs for `01-uiloading.png`, `02-uisceneloading.png`, `03-uisceneloading-late.png` |
| T032 | Add multi-clip baked Spine playback for loading character | done | `kokomi_Loading.baked.json` schema v2 with `clips.Idle` and `clips.Interaction`; `SceneLoadingReferenceScreen` switches clips during scene loading |
| T033 | Add first UIOutGame structural reference layer | done | `OutGameReferenceScreen`, `OutGame Ref` toggle, restored-startup `04-outgame.png` capture, and recovered `UIMaidLD`/dialog/buttons/fillbar layout skeleton |
| T034 | Extract Canvas/SafeArea serialized topology | done | `scripts/reverse/extract_canvas_layout_inventory.py`, `canvas_layout_inventory.json`, and `canvas_layout_inventory.csv`; 104 Canvas, 12 CanvasScaler, and 8 SafeArea components indexed across startup/UI focus files |
| T035 | Wire UIOutGame entry into playable prototype | done | `OutGameReferenceScreen` exposes recovered `InGameBtn`, `MaidLobbyBtn`, and `Btn_ToInteraction` hit regions; `run-game.bat` now reaches clickable out-game and `InGameBtn` transitions into the merge board |
| T036 | Add restored UIInGame shell for portrait gameplay | done | `InGameReferenceShell` draws recovered `UIInGame` top/request/bottom regions; `run-game.bat` portrait gameplay now centers the 7x7 board and hides desktop debug panels |
| T037 | Wire first UIInGame action regions | done | `InGameReferenceShell` exposes recovered bottom action hit regions; Produce reuses current producer logic, Bag is now superseded by the T046 popup shell, and Cafe returns to `UIOutGame` |
| T038 | Add gameplay capture and portrait action polish | done | `capture-gameplay.bat` records startup plus `05-ingame.png`; portrait `run-game.bat` now hides the legacy debug Produce button so bottom actions are driven by recovered `UIInGame` hit regions |
| T039 | Add first real out-game character stand-in and clean portrait shell | done | `UIOutGame` now draws a committed full SD maid PNG stand-in instead of only a sketch placeholder; portrait `UIInGame` hides remaining desktop reference controls and uses committed background/currency sprites in its shell |
| T040 | Restore UIMaidLobbyLoading into startup order | done | `run-game.bat` restored startup now follows `UILoading -> UISceneLoading -> UIMaidLobbyLoading -> UIOutGame`; captures now include `04-maidlobbyloading.png`, `05-outgame.png`, and gameplay `06-ingame.png` |
| T041 | Add runtime Canvas/SafeArea bootstrap stage | done | `run-game.bat` now begins with a recovered `Game.unity`/`UIManager.prefab` Canvas/SafeArea bootstrap visualization before `UILoading`; captures now include `01-runtimecanvas.png`, `06-outgame.png`, and gameplay `07-ingame.png` |
| T042 | Add pre-UI boot services startup stage | done | `run-game.bat` now begins with a structural `RuntimeInitializeOnLoad`/`GameManager`/login/network/`ReloadManager` service stage before runtime Canvas bootstrap; captures now include `01-bootservices.png`, `07-outgame.png`, and gameplay `08-ingame.png` |
| T043 | Add GameManager start-load operation stage | done | `run-game.bat` now inserts a `GameManager.OnGameStartLoad` operation stage between boot services and runtime Canvas bootstrap; captures now include `02-gamestartload.png`, `08-outgame.png`, and gameplay `09-ingame.png` |
| T044 | Add Reload scene mount stage | done | `run-game.bat` now inserts a `Reload.unity` Canvas/SafeArea/UILoading mount stage between `GameStartLoad` and runtime Canvas bootstrap; captures now include `03-reloadscene.png`, `09-outgame.png`, and gameplay `10-ingame.png` |
| T045 | Confirm native startup timings and first scene load chain | pending | Use Ghidra on `GameManager.OnGameStartLoad`, `PlatformLoginManager.CheckPlatformLogin`, `GameManager.CheckNetwork`, `ReloadManager.LoadScene`, and `UIManager.Initialize` |
| T046 | Add first recovered inventory popup shell | done | `UIInGame` Bag now opens a top-level `UIPopup_Inventory` structural shell with `ProduceInventory` and `NormalInventory` sections; `capture-gameplay.bat` now writes `11-inventory.png` |
| T047 | Rebuild UIInGame bottom operation bar | done | `InGameReferenceShell` now uses recovered `Bottom` dimensions to draw Bag, Cafe, central `UIBlockInfo`, and first-pass `Btn_BoxOpen`/`Btn_Use`/`Btn_CoolTime` operation buttons; gameplay capture auto-selects a producer before `10-ingame.png` |
| T048 | Add first UIInGame request strip | done | Recovered `Request/RequestList` evidence now drives a top request strip with quest card, reward slots, and skill placeholders; portrait mode hides leftover debug labels |
| T049 | Restore first UIOutGame home shell | done | `OutGameReferenceScreen` now draws a first-pass home screen with top wallet HUD, cafe backdrop, village rebuild progress, maid stand-in/dialog, Merge/Maid entry buttons, and bottom app navigation; only `Merge` is functionally wired |
| T050 | Rebuild remaining out-game interaction surfaces | in progress | Split into concrete visible targets: `UIMaidLobby`, `UIPopup_MaidLobbySelect`, maid interaction/dialog, shop/app popups, mail/settings, request detail, story/memory/collection, exact original cafe/furniture sprites, reusable LD maid Spine renderer, and asset-backed navigation icons |
| T051 | Add first UIMaidLobby shell and route | done | `UIOutGame/MaidLobbyBtn` now enters `MaidLobbyReferenceScreen`; the shell uses recovered `UIMaidLobby` evidence (`BG`, `White`, `SpinePos`, `Gradient`, `Npc_Dialog`, `DialogBtn`) with Back/Talk/Select regions and `--auto-enter-maid-lobby` capture support |
| T052 | Add UIPopup_MaidLobbySelect shell | done | `Select` from `UIMaidLobby` now opens `MaidLobbySelectPopupReferenceScreen`; the popup reconstructs `Panel`, `TextTitle`, `Btn_Close`, `MaidList`, first maid list-item states, close/select handling, and `11-maidlobbyselect.png` capture support |
| T053 | Add maid interaction/dialog shell | done | `UIMaidLobby/Talk` and `UIOutGame/Btn_ToInteraction` now open `MaidDialogPopupReferenceScreen`; it uses current maid data plus decoded `dialogs.json` rows, supports close/next, and captures `12-maiddialog.png` |
| T054 | Replace out-game placeholder art with recovered UI sprites | in progress | Existing committed character, loading, currency, and maid-chat assets are used where available; exact `UIOutGame`/`UIMaidLobby` background, entry-button, app-nav, and popup sprites still need import from AssetStudio/AssetRipper exports |
| T055 | Record original gameplay and feature analysis | done | `gameplay-and-features.md` now documents the merge-cafe core loop, confirmed systems, content scale, pending unknowns, and reimplementation priority |
| T056 | Add first out-game app navigation popup shell | done | `UIOutGame` bottom Shop/Story/Bag/Menu actions now open `OutGameAppPopupReferenceScreen`; Maid continues to route to `UIMaidLobby` |
| T057 | Add first UIInGame request detail popup shell | done | Clicking the `UIInGame/Request` quest card now opens `RequestDetailPopupReferenceScreen` with required item, placeholder rewards, board candidates, and a Deliver action shell |
| T058 | Wire UIOutGame utility buttons | done | The two top-right home buttons now open first-pass Mail and Settings shells through `OutGameAppPopupReferenceScreen` |
| T059 | Add first UIOutGame FurnitureQuest shell | done | `FurnitureQuest` and `UIVillageReBuild/Fillbar` regions now open `FurnitureQuestPopupReferenceScreen` with rebuild progress, task rows, rewards, and a Go action placeholder |
| T060 | Add first UIOutGame maid interaction mode | done | `UIMaidLD/Btn_ToInteraction` now enters an interaction overlay with Talk/Gift/Profile actions, `Btn_ToNormal` returns to the normal home state, and Talk reuses the maid dialog popup |
| T061 | Add first UIOutGame Story/Memory shell | done | The bottom Story entry now opens `StoryMemoryPopupReferenceScreen` with Story/Memory/Echo tabs and recovered SubStory thumbnail assets |
| T062 | Add first UIOutGame Shop shell | done | The bottom Shop entry now opens `ShopPopupReferenceScreen`, with `UIPopup_Shop`/`UIList_ShopNormal` evidence represented by wallet pills, shop tabs, product rows, ad reward, package, and event-memory placeholders |
| T063 | Add first UIOutGame Mail/Settings shell | done | The top-right Mail and Settings entries now open `MailSettingsPopupReferenceScreen`, with inbox/reward/notice rows and sound/account/language rows staged for later table/runtime binding |
| T064 | Add first UIOutGame Bag/Menu shell | done | The bottom Bag and Menu entries now open `BagMenuPopupReferenceScreen`, with item/chat/collection cards and profile/notice/support cards staged from current evidence |
| T065 | Add asset-backed UIOutGame navigation icons | done | `OutGameReferenceScreen` now maps committed PNG resources onto Shop/Story/Maid/Bag/Menu and Mail/Settings buttons, with geometric fallback if an asset is missing |
| T066 | Import recovered UIOutGame app icons | done | AssetStudio `Appicon_Story`, `Appicon_Maid`, `Appicon_Collection`, `Appicon_Organize`, `icon_mail`, and `icon_setting` are copied into `godot-project/assets/ui_icons` and used by the home navigation |
| T067 | Import recovered cafe home background assets | done | AssetStudio `CafeHall` and basic cafe furniture sprites are copied into `godot-project/assets/cafe`; `OutGameReferenceScreen` now draws an asset-backed cafe background with geometric fallback |
| T068 | Import recovered UIOutGame frame assets | done | AssetStudio button, panel, circle-frame, and gauge sprites are copied into `godot-project/assets/ui_frames` and used by home buttons, top HUD, bottom nav, and rebuild progress |
| T069 | Add UIOutGame popup regression capture | done | `capture-outgame-popups.bat` and `--auto-capture-outgame-popups` now capture the home screen plus Shop, Story, FurnitureQuest, Mail, Settings, Bag, and Menu popup states |

Immediate next implementation targets:

1. Bind more recovered sprite assets into the Shop, Mail/Settings, Bag/Menu, Story/Memory, and FurnitureQuest shells, then map table/config IDs where available.
2. Continue main UI exactness work: tighter cafe/furniture placement, original button text/icon composition, and LD maid Spine rendering.
3. Replace structural placeholders with source-derived request/task/shop/mail/settings/menu rules as table/runtime evidence is mapped.
4. Use `capture-outgame-popups.bat` frames to tighten per-popup layout and detect visual regressions.

## Tool Acquisition Options

Because the required reverse tools are not currently available locally, choose one route:

1. Put portable tool builds into a local `tools/` directory and record their paths.
2. Install tools globally and record versions/paths.
3. Use a separate reverse workstation and copy outputs into `reverse-output/`.

Preferred local layout:

```text
tools/
├── Il2CppDumper/
├── Cpp2IL/
├── AssetStudio/
├── AssetRipper/
├── UABEA/
└── Ghidra/
```

## Decision Points

- Godot language: default to GDScript for gameplay unless recovered logic suggests heavy C# reuse.
- Asset policy: first build with extracted placeholders or neutral debug assets, then replace with final approved assets.
- Services: use no-op mocks until core gameplay is stable.
- Data format: start with JSON/CSV, migrate to Godot resources only if it improves workflow.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| IL2CPP dump fails due to metadata changes or protection | Cannot recover code easily | Try Cpp2IL/Il2CppInspector; use Ghidra with metadata scripts |
| Assets are packed or encrypted | Slower asset recovery | Compare AssetStudio, UABEA, UnityPy, AssetRipper |
| Gameplay data is remote-configured | Local APK incomplete | Inspect network/client config and runtime behavior |
| Third-party SDK code obscures real logic | Time wasted | Focus on `Assembly-CSharp` and Unity assets, ignore SDK packages |
| Godot implementation starts before rules are known | Rework | Keep prototype modular and data-driven |

## Progress Update Rules

At the end of each work session:

1. Update this roadmap task table.
2. Append tool/process notes to `tooling-and-process.md`.
3. Move confirmed facts into the relevant system document.
4. Add unresolved issues to `open-questions.md`.
