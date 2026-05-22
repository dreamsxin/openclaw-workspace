# UI Layout Analysis

This document records the first-pass static UI layout inventory extracted from the AssetRipper Unity Project export.

## Inputs

- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/**/*.prefab`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Scenes/*.unity`

## Generated Outputs

- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.csv`
- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.json`
- `reverse-output/assets/derived/ui_layout/startup_ui_candidates.json`
- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.csv`
- `reverse-output/assets/derived/ui_layout/startup_ui_layout_details.json`
- `godot-project/data/ui_layout_reference.json`

## Summary

- UI prefab files scanned: 1137
- Scene files scanned: 2
- RectTransform records in UI prefabs: 84034
- Categories: app=10, banner=27, button=9, ingame=55, listitem=608, misc=29, popup=284, screen_or_manager=46, tutorial=69

## Startup Candidates

| Name | Type | Path | RectTransforms | Keywords |
| --- | --- | --- | ---: | --- |
| `UIManager` | prefab | `Assets/Resources/prefabs/ui/UIManager.prefab` | 3754 | loading, lobby, outgame, manager, scene, story |
| `Game` | scene | `Assets/Scenes/Game.unity` | 3754 | lobby, outgame, story |
| `UIPopup_MaidNote` | prefab | `Assets/Resources/prefabs/ui/popup/outgame/UIPopup_MaidNote.prefab` | 1880 | loading, story |
| `UIInGame` | prefab | `Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab` | 1351 | lobby, outgame |
| `UIList_ShopNormal` | prefab | `Assets/Resources/prefabs/ui/listitem/shop/UIList_ShopNormal.prefab` | 958 | loading, story |
| `UIPopup_Shop` | prefab | `Assets/Resources/prefabs/ui/popup/shop/UIPopup_Shop.prefab` | 932 | loading, story |
| `UIPopup_MissionPass_Christmas_1` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_Christmas_1.prefab` | 880 | loading, story |
| `UIPopup_MissionPass_Christmas_2` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_Christmas_2.prefab` | 880 | loading, story |
| `UIPopup_MissionPass_Summer` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_Summer.prefab` | 810 | loading, story |
| `UIPopup_MissionPass_Summer_2` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_Summer_2.prefab` | 808 | loading, story |
| `UIPopup_MemoryTicketExchangeShop 1` | prefab | `Assets/Resources/prefabs/ui/popup/shop/UIPopup_MemoryTicketExchangeShop 1.prefab` | 715 | loading, story |
| `UIPopup_EventWhiteDay` | prefab | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventWhiteDay.prefab` | 530 | loading, story |
| `UIPopup_Event_SummerFestivalShop` | prefab | `Assets/Resources/prefabs/ui/popup/event/UIPopup_Event_SummerFestivalShop.prefab` | 499 | loading, story |
| `UIPopup_MissionPass_2` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_2.prefab` | 481 | loading, story |
| `UIPopup_MissionPass_1` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_1.prefab` | 477 | loading, story |
| `UISceneLoading` | prefab | `Assets/Resources/prefabs/ui/UISceneLoading.prefab` | 323 | loading, scene |
| `UIPopup_Debug` | prefab | `Assets/Resources/prefabs/ui/popup/debug/UIPopup_Debug.prefab` | 178 | reload, story |
| `UIMaidLobbyLoading` | prefab | `Assets/Resources/prefabs/ui/UIMaidLobbyLoading.prefab` | 86 | loading, lobby |
| `Reload` | scene | `Assets/Scenes/Reload.unity` | 67 | loading, reload |
| `UIOutGame` | prefab | `Assets/Resources/prefabs/ui/UIOutGame.prefab` | 26 | lobby, outgame |
| `UIPopup_EventBand` | prefab | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventBand.prefab` | 5594 | story |
| `UIPopup_EventCumulativeQuest` | prefab | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventCumulativeQuest.prefab` | 2220 | story |
| `UIPopup_MiniGameEvent_VendingMachine` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_VendingMachine.prefab` | 1107 | story |
| `UIPopup_Event_PC_VendingMachine` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_Event_PC_VendingMachine.prefab` | 1105 | story |
| `UIPopup_MiniGameEvent_PuddingJump` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_PuddingJump.prefab` | 928 | story |

## Focus Startup Layout Sources

| Name | Type | RectTransforms | Path |
| --- | --- | ---: | --- |
| `UIManager` | prefab | 3754 | `Assets/Resources/prefabs/ui/UIManager.prefab` |
| `Game` | scene | 3754 | `Assets/Scenes/Game.unity` |
| `UIInGame` | prefab | 1351 | `Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab` |
| `UISceneLoading` | prefab | 323 | `Assets/Resources/prefabs/ui/UISceneLoading.prefab` |
| `UIMaidLobbyLoading` | prefab | 86 | `Assets/Resources/prefabs/ui/UIMaidLobbyLoading.prefab` |
| `Reload` | scene | 67 | `Assets/Scenes/Reload.unity` |
| `UIOutGame` | prefab | 26 | `Assets/Resources/prefabs/ui/UIOutGame.prefab` |
| `UILoading` | prefab | 65 | `Assets/Resources/prefabs/ui/UILoading.prefab` |
| `UIOutGame` | prefab | 3 | `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab` |

Key recovered layout facts from `startup_ui_layout_details.*`:

- `UILoading` root is a fixed 1080 x 1920 RectTransform.
- `Reload.unity` contains `Canvas/UILoading` with the same large loading background structure.
- `UISceneLoading` uses full-stretch root layout plus 2000 x 2000 centered Spine loading character nodes.
- `UIOutGame` and `UIInGame` use full-stretch roots; their child controls are primarily fixed-anchor panels/buttons.
- `UIManager.prefab` and `Game.unity` embed the large startup/UI root tree rather than only referencing external prefabs.

## Godot Reference Data

`scripts/reverse/build_godot_ui_layout_reference.py` converts the startup layout details into `godot-project/data/ui_layout_reference.json`.

The Godot data currently includes:

- `UILoading`
- `UISceneLoading`
- `UIMaidLobbyLoading`
- both exported `UIOutGame` roots
- `UIInGame`

This file is intentionally a reference layer, not a final scene export. It preserves Unity RectTransform anchors, pivots, positions, sizes, and source paths so the Godot UI can be rebuilt screen-by-screen while keeping a direct evidence trail back to the original prefabs.

The current Godot prototype reads this file and exposes a small `UI Ref` selector in the top-right control area. Use it to cycle through recovered startup UI roots, show the source resolution and key RectTransform entries in the status panel, and preview the first key rectangles as a scaled 1080 x 1920 portrait wireframe.

`UILoading` is now also represented by a first Godot structural reference layer. It maps the recovered 1080 x 1920 root, `Loading_Type/BG_Base` background stack, `LogoArea`, `LoadingBar`, and `Ver` / `Ver (1)` corner labels into a centered preview panel. First-pass loading PNGs are copied into `godot-project/assets/loading/` and used for the visible background/logo/loading fill where possible. Spine logo renderer behavior still needs a proper runtime or baked-frame replacement.

`UISceneLoading` now has a Godot reference layer in restored startup mode. It maps the recovered full-stretch root and background candidates and renders the original `SkeletonGraphic (kokomi_Loading)` target from official Spine-runtime data. The current implementation imports `kokomi_Loading.atlas.txt`, `kokomi_Loading.skel.bytes`, `kokomi_Loading.png`, and `kokomi_Loading_2.png` from the AssetRipper export, uses `@esotericsoftware/spine-core@4.2.43` to parse the binary skeleton, and bakes the `Idle` animation to `kokomi_Loading.baked.json`. Godot then renders each frame's original draw order, UVs, triangles, and world vertices. The earlier generated bridge rig remains as a fallback; raw atlas page PNGs remain evidence/crop sources only and should not be drawn directly as final character art.

`UIOutGame` now has a first Godot home-screen shell. It uses the recovered `UIMaidLD` character area, `Npc_Dialog` dialog box, `InGameBtn`, `MaidLobbyBtn`, and `UIVillageReBuild/Fillbar` controls as layout evidence, then draws the current portrait home view with wallet HUD, cafe backdrop, village rebuild progress, maid stand-in/dialog, Merge/Maid entry buttons, and bottom app navigation. Character art remains a safe committed SD PNG stand-in because the original maid LD data still needs Spine reconstruction rather than drawing atlas pages as portraits.

## UIOutGame Prefab-First Restoration Rule

Further `UIOutGame` home-screen work should be driven by serialized Unity evidence rather than visual trial placement.

Primary evidence:

- `Assets/Resources/prefabs/ui/UIOutGame.prefab`
- `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab`
- `Assets/Resources/animations/**/OutGameUIShow*.anim`
- `Assets/Resources/animations/**/OutGameUIHide*.anim`
- AssetStudio sprite and texture exports only after the owning prefab component is identified.

Required extraction before the next layout pass:

- Full GameObject hierarchy and active state.
- RectTransform anchor, pivot, anchored position, size delta, and sibling order for every child.
- Image/SpriteRenderer sprite references, material references, and source asset names.
- Button/click target nodes and their runtime method evidence from IL2CPP, where available.
- Text/TextMeshPro node bounds and any serialized text keys or fallback strings.
- AnimationClip bindings that alter position, scale, alpha, enabled state, or sprite choice.

Screenshots remain useful as regression checks, but they are not the source of truth for component placement. If a sprite looks plausible but its owning prefab component cannot be identified, it should be recorded as a candidate asset and not used for final home-screen positioning.

Focused `UIOutGame` evidence is now generated by `scripts/reverse/extract_uioutgame_layout_report.py` into:

- `docs/reverse-godot/uioutgame-layout-report.md`
- `godot-project/data/uioutgame_layout_reference.json`

Current Godot use:

- `OutGameReferenceScreen` reads the focused source through `main.gd` instead of the broad startup inventory when drawing the home screen.
- `InGameBtn`, `MaidLobbyBtn`, `Btn_ToInteraction`, and `Npc_Dialog` are positioned from recovered RectTransforms.
- `UIVillageReBuild` and `FurnitureQuest` now use source RectTransforms for evidence preview, but their runtime activation and final mount state still need confirmation because `UIVillageReBuild` is serialized inactive and some child nodes are centered placeholders.
- `OutGameUIShow*` and `OutGameUIHide*` are documented as transition clips and should be implemented as animation states, not as edits to the base RectTransform table.

## Focused UI Prefab Audit

`scripts/reverse/extract_focused_ui_layout_reports.py` now generates a cross-screen prefab-first audit:

- `docs/reverse-godot/focused-ui-prefab-audit.md`
- `godot-project/data/focused_ui_layout_reference.json`

Current audit status:

- `UIOutGame`, `UIVillageReBuild`, and `UIMaidLobby` are `prefab_first_partial`.
- `UIMaidLobbyLoading`, `UISceneLoading`, and `UIInGame` are `prefab_reference_shell` or lower because they still have low exact path coverage.
- `UIPopup_Inventory` now loads focused prefab data and references `BG`, `ProduceInventory`, `NormalInventory`, `ScrollViewMask`, and `Btn_Close`, but the visible popup keeps a fallback root because the serialized `BG` spans beyond the practical portrait panel.
- `UIPopup_MaidLobbySelect` now loads focused prefab data and references `Panel`, `TextTitle`, `MaidList`, `BtnArea/Btn`, `Btn_Close`, and list-item rows; screenshot verification confirms the close button is no longer misplaced over the list.
- `UIPopup_Shop` now loads focused prefab data and references `BG`, `Top`, `Title`, `Btn_Close`, `Scroll View`, `Viewport`, `UIList_ShopNormal`, and first section groups including `Grid_Package`, `BannerGroup`, `Grid_Costume`, and `Grid_Daily`.
- `UIFurnitureQuest` now loads focused prefab data for the original 200x200 out-game entry button, including `Button`, icon layers, optional main/sub/text nodes, and notification badge evidence. This is entry-prefab evidence, not proof of a separate furniture quest popup prefab.

The focused audit is the gate for future UI completion labels: a screen must load focused prefab data and reference concrete RectTransform paths before it can be marked as prefab-first.
Converted source rectangles are additionally sanity-checked at runtime. If a recovered RectTransform is valid but lands far outside the current fallback panel, Godot keeps the stable fallback region and leaves the source path in the audit for later normalization.

`UIPopup_Shop` is a large staged case: the first focused pass restores its top/title/chat/scroll/list section structure, while exact product row layout and sprite mapping remain pending because the prefab has 932 RectTransforms and several inactive or scroll-clipped item groups.
`UIFurnitureQuest` is intentionally treated as an out-game entry component. The current Godot detail panel remains a reconstruction shell layered behind the recovered entry-button evidence until a distinct furniture quest detail prefab or runtime screen is identified.

Latest startup recheck:

- `UILoading/LoadingBar` is a direct child of the 1080 x 1920 root, fixed at anchor `(0.5, 0.0)`, anchored position `(0, 300)`, size `670 x 50`, pivot `(0.5, 0.5)`.
- `UILoading/LoadingBar/Fill Area/Image` is local to `LoadingBar`; it must not be converted as a root-space RectTransform. Godot now derives the visible fill rect from the recovered `LoadingBar` root rect and only scales its width by progress.
- `UISceneLoading/SceneObjects/TypeA/SkeletonGraphic (kokomi_Loading)` is the character root, not the zero-size `Renderer*` children. Its recovered rect is anchor `(0.5, 0.0)`, anchored position `(0, 0)`, size `2000 x 2000`, pivot `(0.5, 0.0)`; Godot now resolves this through the `UISceneLoading/SceneObjects/TypeA` parent chain rather than as a root-space shortcut.
- The baked `Idle` data is not static: frame-delta checks show large vertex movement between frames, so missing second-screen motion should be treated as a Godot target-rect or mesh-render path problem, not as a bake-data problem.
- Screenshot verification confirmed the exact render bug: baked UVs are normalized, and multiplying them by texture page size made the second screen sample the wrong texture coordinates. Godot now passes normalized UVs directly to textured polygons.

## Canvas And SafeArea Inventory

`scripts/reverse/extract_canvas_layout_inventory.py` records Canvas, CanvasScaler, and SafeArea evidence from the startup/UI focus files into:

- `reverse-output/assets/derived/ui_layout/canvas_layout_inventory.json`
- `reverse-output/assets/derived/ui_layout/canvas_layout_inventory.csv`

Current target set:

- `Assets/Resources/prefabs/ui/BGCanvas.prefab`
- `Assets/Scenes/Reload.unity`
- `Assets/Scenes/Game.unity`
- `Assets/Resources/prefabs/ui/UIManager.prefab`
- `Assets/Resources/prefabs/ui/UILoading.prefab`
- `Assets/Resources/prefabs/ui/UISceneLoading.prefab`
- `Assets/Resources/prefabs/ui/UIMaidLobbyLoading.prefab`
- `Assets/Resources/prefabs/ui/UIOutGame.prefab`
- `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab`
- `Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab`

Recovered counts:

- 104 `Canvas` components.
- 12 `CanvasScaler` components.
- 8 `SafeArea` MonoBehaviour components.
- 8 RectTransforms named `SafeArea`.
- 0 `CanvasScaler` components with serialized `m_UiScaleMode`, `m_ReferenceResolution`, `m_ScreenMatchMode`, or `m_MatchWidthOrHeight` fields present in the AssetRipper YAML.

Important mount points:

- `Reload.unity`: `Canvas` has a `CanvasScaler`; `Canvas/SafeArea` has the project `SafeArea` component.
- `Game.unity`: `Canvas`, `BGCanvas`, `TouchEffectCanvas`, `UIStory/StoryGroup/StoryObjectCanvas`, and `UIStory/StoryGroup/StoryUICanvas` have `CanvasScaler` components.
- `Game.unity`: `Canvas/SafeArea`, `BGCanvas/SafeArea`, and `UIStory/StoryGroup/StoryUICanvas/SafeArea` have `SafeArea` components.
- `UIManager.prefab`: same main runtime canvas topology as `Game.unity`, including `Canvas/SafeArea`, `BGCanvas/SafeArea`, and `UIStory/StoryGroup/StoryUICanvas/SafeArea`.
- `BGCanvas.prefab`: root `BGCanvas` has a `CanvasScaler`; `BGCanvas/SafeArea` has the project `SafeArea` component.

Script GUID mapping recovered from AssetRipper meta files:

- `CanvasScaler`: `6dfc8ec6aebac6665d9781d273993f23`
- `SafeArea`: `cedddb77dbd60a683455a2b226c5fd56`
- `GraphicRaycaster`: `86fe8f3fc59dc06ea6b45a1bbee64682`
- `Image`: `3cf5a44414476512e00c3e7a2569a919`
- `TextMeshProUGUI`: `3f96b1d166d19b209697e35b35d65c76`
- `UIInGameBG`: `ab0e0bb351e7be9b1ef3f8a3fe9811f4`

Interpretation:

- CanvasScaler components are present on the original runtime canvases, but AssetRipper did not recover their serialized reference-resolution fields.
- The 1080 x 1920 working coordinate system remains evidence-backed by `UILoading` and other root RectTransforms, not by a recovered `CanvasScaler.referenceResolution` value.
- The exact scale mode and match mode must be confirmed by IL2CPP/native analysis of the runtime CanvasScaler setup or by a more complete Unity export that preserves those fields.
- Godot should keep using the recovered RectTransform tree for layout reconstruction and treat CanvasScaler policy as a runtime compatibility layer until the missing fields are confirmed.

## Inventory Popup Evidence

Relevant serialized UI assets:

- `Assets/Resources/prefabs/ui/ingame/UIInventory.prefab`
- `Assets/Resources/prefabs/ui/popup/UIPopup_Inventory.prefab`
- `Assets/Resources/prefabs/ui/listitem/UIListItem_InvenSlot_Block.prefab`
- `Assets/Resources/prefabs/ui/listitem/UIListItem_InvenSlot_BM.prefab`
- `Assets/Resources/prefabs/ui/listitem/UIListItem_InvenSlot_Gift.prefab`
- `Assets/Resources/prefabs/ui/listitem/UIListItem_InvenSlot_ProduceBlock.prefab`

Runtime class evidence from the IL2CPP dump links the popup to `InvenDataManager`, `BlockSlotData`, `ProduceBlockSlotData`, `InGame_BlockManager.PutInInventory_BlockSlot`, `PutInInventory_ProduceBlockSlot`, `PullOutInventory`, and `PullOutInventory_ProduceBlock`.

Current Godot state:

- `UIInGame` Bag opens a focused-data `UIPopup_Inventory` shell.
- The shell separates producer candidates into `ProduceInventory` and normal blocks into `NormalInventory`, using recovered prefab node paths where the converted rectangles pass runtime sanity checks.
- The popup root currently rejects the serialized `UIPopup_Inventory/BG` as a visible rect because the converted root is taller than the portrait panel; this is tracked as a RectTransform normalization follow-up rather than a missing prefab reference.
- Exact slot scroll/list layout, persistent `InvenDataManager` data, and drag-out/put-in behavior remain pending.

## Largest UI Prefabs

| Name | Category | RectTransforms | Large Rects | Path |
| --- | --- | ---: | ---: | --- |
| `UIPopup_EventBand` | popup | 5594 | 12 | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventBand.prefab` |
| `UIManager` | screen_or_manager | 3754 | 12 | `Assets/Resources/prefabs/ui/UIManager.prefab` |
| `UIPopup_EventCumulativeQuest` | popup | 2220 | 4 | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventCumulativeQuest.prefab` |
| `UIPopup_MaidNote` | popup | 1880 | 12 | `Assets/Resources/prefabs/ui/popup/outgame/UIPopup_MaidNote.prefab` |
| `UIpopup_HighKuji_PackageBase` | popup | 1439 | 3 | `Assets/Resources/prefabs/ui/popup/package/nomalbase/UIpopup_HighKuji_PackageBase.prefab` |
| `UIpopup_HighKuji_Package_2025Christmas` | popup | 1439 | 3 | `Assets/Resources/prefabs/ui/popup/package/UIpopup_HighKuji_Package_2025Christmas.prefab` |
| `UIpopup_HighKuji_Package_2025Summer` | popup | 1439 | 3 | `Assets/Resources/prefabs/ui/popup/package/UIpopup_HighKuji_Package_2025Summer.prefab` |
| `UIpopup_HighKuji_Package_2026School` | popup | 1439 | 3 | `Assets/Resources/prefabs/ui/popup/package/UIpopup_HighKuji_Package_2026School.prefab` |
| `UIInGame` | ingame | 1351 | 12 | `Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab` |
| `UIPopup_MiniGameEvent_VendingMachine` | popup | 1107 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_VendingMachine.prefab` |
| `UIPopup_Event_PC_VendingMachine` | popup | 1105 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_Event_PC_VendingMachine.prefab` |
| `UIList_ShopNormal` | listitem | 958 | 12 | `Assets/Resources/prefabs/ui/listitem/shop/UIList_ShopNormal.prefab` |
| `UIPopup_Event_CardPack` | popup | 950 | 12 | `Assets/Resources/prefabs/ui/popup/event/UIPopup_Event_CardPack.prefab` |
| `UIPopup_Shop` | popup | 932 | 12 | `Assets/Resources/prefabs/ui/popup/shop/UIPopup_Shop.prefab` |
| `UIPopup_MiniGameEvent_PuddingJump` | popup | 928 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_PuddingJump.prefab` |
| `UIPopup_Event_PC_PuddingJump` | popup | 918 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_Event_PC_PuddingJump.prefab` |
| `UIPopup_MissionPass_Christmas_1` | popup | 880 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_Christmas_1.prefab` |
| `UIPopup_MissionPass_Christmas_2` | popup | 880 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_MissionPass_Christmas_2.prefab` |
| `UIPopup_MiniGameEvent_BloodWorm` | popup | 852 | 12 | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_BloodWorm.prefab` |
| `UIpopup_HighKuji_Choice` | popup | 839 | 2 | `Assets/Resources/prefabs/ui/popup/package/UIpopup_HighKuji_Choice.prefab` |

## Current Limits

- This pass reads static serialized prefab and scene YAML only.
- Runtime-instantiated UI, localization-driven text sizing, safe-area adjustment, and code-driven show/hide states still require IL2CPP/native flow analysis.
- CanvasScaler mount points are now confirmed in serialized data, but AssetRipper did not recover their reference resolution or match-mode fields. The next step is native/runtime method analysis around `UIManager.Initialize`, `SafeArea.Awake`, and CanvasScaler setup.

## Next Steps

1. Map startup flow through `ReloadManager`, `LoginMenuHandler`, `UIRoot`, `UIManager`, `UIPopupManager`, and `UISceneLoading`.
2. Confirm CanvasScaler reference resolution and SafeArea anchor updates from IL2CPP/Ghidra method bodies.
3. Replace remaining loading static fallbacks with Spine output, then convert `UIOutGame` and the first in-game HUD from reference data into actual Godot Control scenes.
