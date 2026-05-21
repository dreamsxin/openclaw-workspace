# UI Layout Analysis

This document records the first-pass static UI layout inventory extracted from the AssetRipper Unity Project export.

## Inputs

- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Resources/prefabs/ui/**/*.prefab`
- `reverse-output/assets/assetripper-main/ExportedProject/Assets/Scenes/*.unity`

## Generated Outputs

- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.csv`
- `reverse-output/assets/derived/ui_layout/ui_prefab_layout_inventory.json`
- `reverse-output/assets/derived/ui_layout/startup_ui_candidates.json`

## Summary

- UI prefab files scanned: 1137
- Scene files scanned: 2
- RectTransform records in UI prefabs: 84034
- Categories: app=10, banner=27, button=9, ingame=55, listitem=608, misc=29, popup=284, screen_or_manager=46, tutorial=69

## Startup Candidates

| Name | Type | Path | RectTransforms | Keywords |
| --- | --- | --- | ---: | --- |
| `UIManager` | prefab | `Assets/Resources/prefabs/ui/UIManager.prefab` | 3754 | loading, lobby, outgame, manager, scene, story |
| `Reload` | scene | `Assets/Scenes/Reload.unity` | 67 | loading, reload, manager |
| `Game` | scene | `Assets/Scenes/Game.unity` | 3754 | manager, story |
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
| `UIOutGame` | prefab | `Assets/Resources/prefabs/ui/UIOutGame.prefab` | 26 | lobby, outgame |
| `UIPopup_EventBand` | prefab | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventBand.prefab` | 5594 | story |
| `UIPopup_EventCumulativeQuest` | prefab | `Assets/Resources/prefabs/ui/popup/event/UIPopup_EventCumulativeQuest.prefab` | 2220 | story |
| `UIPopup_MiniGameEvent_VendingMachine` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_VendingMachine.prefab` | 1107 | story |
| `UIPopup_Event_PC_VendingMachine` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_Event_PC_VendingMachine.prefab` | 1105 | story |
| `UIPopup_MiniGameEvent_PuddingJump` | prefab | `Assets/Resources/prefabs/ui/popup/UIPopup_MiniGameEvent_PuddingJump.prefab` | 928 | story |

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
- CanvasScaler reference resolution was not confirmed in this pass; the next step is to inspect `UIRoot`, `UICanvasManager`, and any serialized Canvas scaler components or runtime setup code.

## Next Steps

1. Map startup flow through `ReloadManager`, `LoginMenuHandler`, `UIRoot`, `UIManager`, `UIPopupManager`, and `UISceneLoading`.
2. Expand the extractor to reconstruct parent/child paths for selected high-value screens.
3. Build Godot reference layouts for `UILoading`, `UISceneLoading`, `UILobbyUIOn`, `UIOutGame`, and the first in-game HUD.
