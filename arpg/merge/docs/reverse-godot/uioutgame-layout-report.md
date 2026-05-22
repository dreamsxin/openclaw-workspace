# UIOutGame Layout Evidence

This report is generated from the AssetRipper Unity Project export and is the current source of truth for the Godot home-screen restoration pass.

## Inputs

- `Assets/Resources/prefabs/ui/UIOutGame.prefab`
- `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab`
- `Assets/Resources/animation/OutGameUIShow.anim`
- `Assets/Resources/animation/OutGameUIHide.anim`
- `Assets/Resources/animation/OutGameUIShow_Lobby.anim`
- `Assets/Resources/animation/OutGameUIHide_Lobby.anim`

## Generated Outputs

- `godot-project/data/uioutgame_layout_reference.json`
- `docs/reverse-godot/uioutgame-layout-report.md`

## Summary

- `Assets/Resources/prefabs/ui/UIOutGame.prefab`: 26 GameObjects, 26 RectTransforms, 26 key RectTransforms.
- `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab`: 3 GameObjects, 3 RectTransforms, 3 key RectTransforms.
- `OutGameUIShow`: 9 float animation bindings.
- `OutGameUIHide`: 9 float animation bindings.
- `OutGameUIShow_Lobby`: 7 float animation bindings.
- `OutGameUIHide_Lobby`: 7 float animation bindings.

## Key Findings

- `UIOutGame.prefab` is a small controller/home-layout prefab: the serialized hierarchy contains the maid LD area, dialog controls, entry buttons, furniture quest, and rebuild progress anchors.
- `uiroot/UIOutGame.prefab` is only a root-level mount wrapper, so placement work should primarily follow `Resources/prefabs/ui/UIOutGame.prefab`.
- `Npc_Dialog` and `MaidLobbyBtn` are serialized inactive in the base prefab; their visible state is controlled by runtime logic and animation/state transitions.
- `OutGameUIShow*` and `OutGameUIHide*` animate `InGameBtn`, `MaidLobbyBtn`, `UIMaidLD`, `UILobby`, and `UIGlobal` anchors, so Godot should model static RectTransforms and transition offsets separately.

## Key RectTransforms

| Source | Path | Active | AnchorMin | AnchorMax | Pos | Size | Pivot | Components |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame` | yes | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, MonoBehaviour:f5569eb6 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame` | yes | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/FurnitureQuest` | yes | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=0 | x=100, y=100 | x=0.5, y=0.5 | RectTransform |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD` | yes | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, MonoBehaviour:b6611600 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/Dim` | yes | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=400, y=400 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:475afc92, MonoBehaviour:475afc92 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePosTarget_Normal` | yes | x=0, y=0 | x=0, y=0 | x=240, y=-650 | x=100, y=100 | x=0.5, y=0.5 | RectTransform |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePosTarget_Interaction` | yes | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=-1500 | x=100, y=100 | x=0.5, y=0.5 | RectTransform |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePos` | yes | x=0, y=0 | x=0, y=0 | x=240, y=-650 | x=100, y=100 | x=0.5, y=0.5 | RectTransform |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog` | no | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=1179.4 | x=540, y=158.8 | x=0.5, y=1 | RectTransform, CanvasRenderer, MonoBehaviour:f18f2cc2, MonoBehaviour:21c79540, MonoBehaviour:da9b4ee3 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog/Icon_Dialog` | no | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:76ccfb4b, MonoBehaviour:4293fd42 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog/Tail` | no | x=0.5, y=1 | x=0.5, y=1 | x=50, y=6 | x=25, y=15 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:4293fd42 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog/Text_Dialog` | no | x=0, y=1 | x=0, y=1 | x=270, y=-79.4 | x=480, y=118.8 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, TextMeshProUGUI, MonoBehaviour:1be30ab7 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/Btn_ToNormal` | no | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=400, y=400 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:18d0a906 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/Btn_ToInteraction` | yes | x=0, y=0 | x=0, y=0 | x=0, y=320 | x=320, y=590 | x=0, y=0 | RectTransform, CanvasRenderer, Image, MonoBehaviour:18d0a906 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIMaidLD/Btn_InteractionArea` | no | x=0, y=0 | x=1, y=1 | x=0, y=-100.05 | x=-400, y=-199.9 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:18d0a906 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/InGameBtn` | yes | x=1, y=0 | x=1, y=0 | x=-30, y=20 | x=300, y=246 | x=1, y=0 | RectTransform, CanvasRenderer, Image, MonoBehaviour:18d0a906, MonoBehaviour:93ffe31a |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/InGameBtn/InGame` | yes | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=0 | x=300, y=246 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/MaidLobbyBtn` | no | x=1, y=0 | x=1, y=0 | x=-360, y=35 | x=200, y=200 | x=1, y=0 | RectTransform, CanvasRenderer, Image, MonoBehaviour:18d0a906, MonoBehaviour:93ffe31a |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/MaidLobbyBtn/ToOutGame` | no | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:76ccfb4b |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/MaidLobbyBtn/ToMaidLobby` | no | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:76ccfb4b |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIVillageReBuild` | no | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=0 | x=100, y=100 | x=0.5, y=0.5 | RectTransform, MonoBehaviour:898db6d9 |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar` | no | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=0 | x=560, y=100 | x=0.5, y=0.5 | RectTransform, MonoBehaviour:1522d51f |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Background` | no | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Fill Area` | no | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Fill Area/Fill` | no | x=0, y=0 | x=0, y=0 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image |
| `Assets/Resources/prefabs/ui/UIOutGame.prefab` | `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Image` | no | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=0 | x=80, y=80 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image |
| `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab` | `UIOutGame` | yes | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, MonoBehaviour:f5569eb6 |
| `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab` | `UIOutGame/Button` | yes | x=0.5, y=0.5 | x=0.5, y=0.5 | x=0, y=0 | x=160, y=30 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, Image, MonoBehaviour:18d0a906 |
| `Assets/Resources/prefabs/ui/uiroot/UIOutGame.prefab` | `UIOutGame/Button/Text (TMP)` | yes | x=0, y=0 | x=1, y=1 | x=0, y=0 | x=0, y=0 | x=0.5, y=0.5 | RectTransform, CanvasRenderer, TextMeshProUGUI |

## Animation Bindings

| Clip | Path | Attribute | ClassID | Keyframes | First -> Last | Range |
| --- | --- | --- | ---: | ---: | --- | --- |
| `OutGameUIShow` | `UIGlobal/UITap_Left` | `m_AnchoredPosition.x` | 224 | 2 | -300 -> 0 | -300..0 |
| `OutGameUIShow` | `UIGlobal/UITap_Right` | `m_AnchoredPosition.x` | 224 | 2 | 300 -> 0 | 0..300 |
| `OutGameUIShow` | `UIGlobal/UITop` | `m_AnchoredPosition.y` | 224 | 2 | 300 -> 0 | 0..300 |
| `OutGameUIShow` | `UILobby` | `m_AnchoredPosition.y` | 224 | 2 | -300 -> 0 | -300..0 |
| `OutGameUIShow` | `UIOutGame/UIOutGame/InGameBtn` | `m_AnchoredPosition.y` | 224 | 2 | -300 -> 20 | -300..20 |
| `OutGameUIShow` | `UIOutGame/UIOutGame/MaidLobbyBtn` | `m_AnchoredPosition.y` | 224 | 2 | -300 -> 35 | -300..35 |
| `OutGameUIShow` | `UIOutGame/UIOutGame/UIMaidLD` | `m_AnchoredPosition.x` | 224 | 3 | -600 -> 0 | -600..0 |
| `OutGameUIShow` | `UIGlobal/UITap_Right/UITopBtn` | `m_Spacing` | 114 | 2 | -100 -> 20 | -100..20 |
| `OutGameUIShow` | `UIOutGame/UIOutGame/UIMaidLD` | `m_IsActive` | 1 | 3 | 0 -> 1 | 0..1 |
| `OutGameUIHide` | `UILobby` | `m_AnchoredPosition.y` | 224 | 2 | 0 -> -500 | -500..0 |
| `OutGameUIHide` | `UIGlobal/UITop` | `m_AnchoredPosition.y` | 224 | 2 | 0 -> 300 | 0..300 |
| `OutGameUIHide` | `UIGlobal/UITap_Left` | `m_AnchoredPosition.x` | 224 | 2 | 0 -> -500 | -500..0 |
| `OutGameUIHide` | `UIGlobal/UITap_Right` | `m_AnchoredPosition.x` | 224 | 2 | 0 -> 300 | 0..300 |
| `OutGameUIHide` | `UIOutGame/UIOutGame/InGameBtn` | `m_AnchoredPosition.y` | 224 | 2 | 20 -> -500 | -500..20 |
| `OutGameUIHide` | `UIOutGame/UIOutGame/MaidLobbyBtn` | `m_AnchoredPosition.y` | 224 | 2 | 35 -> -500 | -500..35 |
| `OutGameUIHide` | `UIOutGame/UIOutGame/UIMaidLD` | `m_AnchoredPosition.x` | 224 | 3 | 0 -> -600 | -600..0 |
| `OutGameUIHide` | `UIGlobal/UITap_Right/UITopBtn` | `m_Spacing` | 114 | 2 | 20 -> -100 | -100..20 |
| `OutGameUIHide` | `UIOutGame/UIOutGame/UIMaidLD` | `m_IsActive` | 1 | 2 | 1 -> 0 | 0..1 |
| `OutGameUIShow_Lobby` | `UIGlobal/UITap_Left` | `m_AnchoredPosition.x` | 224 | 2 | -300 -> 0 | -300..0 |
| `OutGameUIShow_Lobby` | `UIGlobal/UITap_Right` | `m_AnchoredPosition.x` | 224 | 2 | 300 -> 0 | 0..300 |
| `OutGameUIShow_Lobby` | `UIGlobal/UITop` | `m_AnchoredPosition.y` | 224 | 2 | 300 -> 0 | 0..300 |
| `OutGameUIShow_Lobby` | `UILobby` | `m_AnchoredPosition.y` | 224 | 2 | -300 -> 0 | -300..0 |
| `OutGameUIShow_Lobby` | `UIOutGame/UIOutGame/InGameBtn` | `m_AnchoredPosition.y` | 224 | 2 | -300 -> 20 | -300..20 |
| `OutGameUIShow_Lobby` | `UIOutGame/UIOutGame/MaidLobbyBtn` | `m_AnchoredPosition.y` | 224 | 2 | -300 -> 35 | -300..35 |
| `OutGameUIShow_Lobby` | `UIGlobal/UITap_Right/UITopBtn` | `m_Spacing` | 114 | 2 | -100 -> 20 | -100..20 |
| `OutGameUIHide_Lobby` | `UILobby` | `m_AnchoredPosition.y` | 224 | 2 | 0 -> -500 | -500..0 |
| `OutGameUIHide_Lobby` | `UIGlobal/UITop` | `m_AnchoredPosition.y` | 224 | 2 | 0 -> 300 | 0..300 |
| `OutGameUIHide_Lobby` | `UIGlobal/UITap_Left` | `m_AnchoredPosition.x` | 224 | 2 | 0 -> -500 | -500..0 |
| `OutGameUIHide_Lobby` | `UIGlobal/UITap_Right` | `m_AnchoredPosition.x` | 224 | 2 | 0 -> 300 | 0..300 |
| `OutGameUIHide_Lobby` | `UIOutGame/UIOutGame/InGameBtn` | `m_AnchoredPosition.y` | 224 | 2 | 20 -> -500 | -500..20 |
| `OutGameUIHide_Lobby` | `UIOutGame/UIOutGame/MaidLobbyBtn` | `m_AnchoredPosition.y` | 224 | 2 | 35 -> -500 | -500..35 |
| `OutGameUIHide_Lobby` | `UIGlobal/UITap_Right/UITopBtn` | `m_Spacing` | 114 | 2 | 20 -> -100 | -100..20 |

## Restoration Implications

1. Convert every home-screen hit region from the serialized RectTransform table instead of hand-tuned screenshot positions.
2. Treat inactive serialized nodes as valid layout evidence, but gate visibility through recovered UI state.
3. Apply animation clips as named transition states: normal show/hide and lobby show/hide should not overwrite base layout data.
4. Resolve remaining sprite GUIDs to AssetStudio/AssetRipper sprite names before replacing any geometric fallback.

## Remaining Unknowns

- Exact runtime code path that toggles `Npc_Dialog`, `MaidLobbyBtn`, `Btn_ToInteraction`, and `Btn_ToNormal`.
- CanvasScaler reference resolution and SafeArea updates, which are still not serialized in the AssetRipper YAML.
- Sprite GUID-to-name resolution for each Image component in this focused prefab.
