# Focused UI Prefab Audit

This audit checks the currently implemented Godot screens against focused AssetRipper prefab evidence.

## Summary

| UI | Priority | Status | Score | Prefab Rects | Godot Script | Referenced Rect Paths | Notes |
| --- | --- | --- | ---: | ---: | --- | ---: | --- |
| `UIInGame` | high | prefab_reference_shell | 25 | 1351 | `godot-project/scripts/ingame_reference_shell.gd` | 0 | low path coverage |
| `UIMaidLobby` | high | prefab_first_partial | 64 | 10 | `godot-project/scripts/maid_lobby_reference_screen.gd` | 6 | source driven |
| `UIPopup_Inventory` | high | prefab_first_partial | 64 | 131 | `godot-project/scripts/inventory_popup_reference_screen.gd` | 6 | low path coverage |
| `UIPopup_Shop` | high | prefab_first_partial | 76 | 932 | `godot-project/scripts/shop_popup_reference_screen.gd` | 9 | low path coverage |
| `UIPopup_MaidLobbySelect` | high | prefab_first_partial | 64 | 87 | `godot-project/scripts/maid_lobby_select_popup_reference_screen.gd` | 6 | source driven |
| `UIFurnitureQuest` | medium | manual_shell | 10 | 20 | `godot-project/scripts/furniture_quest_popup_reference_screen.gd` | 0 | manual Rect2 shell, low path coverage, no set_source |
| `UIVillageReBuild` | medium | prefab_first_partial | 64 | 6 | `godot-project/scripts/out_game_reference_screen.gd` | 6 | source driven |
| `UIMaidLobbyLoading` | medium | prefab_reference_shell | 45 | 86 | `godot-project/scripts/maid_lobby_loading_reference_screen.gd` | 3 | low path coverage |
| `UILoading` | baseline | mixed_unwired | 30 | 65 | `godot-project/scripts/loading_reference_screen.gd` | 7 | source driven |
| `UISceneLoading` | baseline | prefab_reference_shell | 25 | 323 | `godot-project/scripts/scene_loading_reference_screen.gd` | 3 | low path coverage |
| `UIOutGame` | baseline | prefab_first_partial | 64 | 26 | `godot-project/scripts/out_game_reference_screen.gd` | 6 | source driven |

## Target Details

### UIInGame

- Prefab: `Assets/Resources/prefabs/ui/uiroot/UIInGame.prefab`
- Godot: `godot-project/scripts/ingame_reference_shell.gd`
- Status: `prefab_reference_shell`
- RectTransforms: 1351
- Layout kinds: fixed_anchor=735, full_stretch=473, large_panel=7, mixed=136
- Components: CanvasRenderer=1089, Image=745, MonoBehaviour:004a2bbe=1, MonoBehaviour:029032da=1, MonoBehaviour:05dbec66=1, MonoBehaviour:10f9720a=3, MonoBehaviour:1522d51f=3, MonoBehaviour:16c0ec1e=49, MonoBehaviour:18d0a906=93, MonoBehaviour:19fbb4a3=39, MonoBehaviour:1be30ab7=44, MonoBehaviour:2170bc9e=1, MonoBehaviour:21c79540=18, MonoBehaviour:2343e4bd=1, MonoBehaviour:2aed1055=8, MonoBehaviour:2cbaf7f9=3, MonoBehaviour:2d052224=1, MonoBehaviour:2f92a323=8, MonoBehaviour:33e02753=1, MonoBehaviour:3f4b410b=1, MonoBehaviour:4293fd42=219, MonoBehaviour:43aaa35d=1, MonoBehaviour:57c62608=3, MonoBehaviour:598ca59b=44, MonoBehaviour:5eccd90b=16, MonoBehaviour:6c71a908=63, MonoBehaviour:75ba2a8b=44, MonoBehaviour:76ccfb4b=38, MonoBehaviour:8da296ca=3, MonoBehaviour:93ffe31a=24, MonoBehaviour:9721f7b1=1, MonoBehaviour:a0ce27fc=5, MonoBehaviour:a1e79089=38, MonoBehaviour:a535341f=1, MonoBehaviour:b321612e=12, MonoBehaviour:b66796e7=1, MonoBehaviour:c4ae4583=1, MonoBehaviour:ca450998=1, MonoBehaviour:da9b4ee3=87, MonoBehaviour:dc536df3=10, MonoBehaviour:df2bc122=4, MonoBehaviour:e1f86713=1, MonoBehaviour:e2bb3a5f=3, MonoBehaviour:e43d41b3=3, MonoBehaviour:e7250304=4, MonoBehaviour:f18f2cc2=29, MonoBehaviour:f3f93bf7=2, MonoBehaviour:f4311c77=20, MonoBehaviour:fc1e3da7=1, MonoBehaviour:ff326197=10, RectTransform=1351, TextMeshProUGUI=128
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 54

Key serialized rect paths:

- `UIInGame` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:c4ae4583
- `UIInGame/BorderTop` active=True size=x=0,y=100 components=RectTransform
- `UIInGame/BorderTop/BorderTop` active=False size=x=100,y=100 components=RectTransform
- `UIInGame/Request` active=True size=x=0,y=0 components=RectTransform
- `UIInGame/Request/RequestList` active=True size=x=0,y=1000 components=RectTransform,MonoBehaviour:029032da
- `UIInGame/Request/RequestList/ScrollView` active=True size=x=0,y=7.62939e-06 components=RectTransform,MonoBehaviour:2cbaf7f9,CanvasRenderer,Image
- `UIInGame/Request/RequestList/ScrollView/Viewport` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/BarSkinSlot` active=True size=x=4000,y=0 components=RectTransform,MonoBehaviour:4293fd42
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/BarSkinSlot/IngameBGBot_Default` active=True size=x=0,y=200 components=RectTransform,CanvasRenderer,Image
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:19fbb4a3
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest` active=False size=x=0,y=125 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask` active=False size=x=400,y=445.78 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/Hand_R` active=False size=x=64,y=64 components=RectTransform,CanvasRenderer,Image
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/Hand_L` active=False size=x=64,y=64 components=RectTransform,CanvasRenderer,Image
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/finger` active=False size=x=64,y=64 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:e7250304
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/Npc_Dialog` active=False size=x=300,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42,MonoBehaviour:f18f2cc2,MonoBehaviour:21c79540
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/Npc_Dialog/Icon_Dialog` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b,MonoBehaviour:4293fd42
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/Npc_Dialog/Image` active=False size=x=25,y=15 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42,MonoBehaviour:76ccfb4b
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/NoQuest/Mask/Npc_Dialog/Text_Dialog` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,TextMeshProUGUI,MonoBehaviour:1be30ab7
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/Grid_QuestList` active=True size=x=0,y=176.4 components=RectTransform,CanvasRenderer,MonoBehaviour:18d0a906,MonoBehaviour:4293fd42
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/Grid_QuestList/Img_QuestList` active=True size=x=160,y=224 components=RectTransform,CanvasRenderer,Image
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/Grid_QuestList/Img_QuestList/Noti/UFX_BtnClearQuest` active=True size=x=100,y=100 components=RectTransform,CanvasRenderer,MonoBehaviour:2f92a323
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/Grid_QuestList/Img_QuestList/Noti/UFX_Noti/Image` active=True size=x=54,y=54 components=RectTransform,CanvasRenderer,Image
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/Grid_QuestList/Img_QuestList/Noti/UFX_Noti/Image/UIParticle` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:6c71a908
- `UIInGame/Request/RequestList/ScrollView/Viewport/Content/Grid_Request/Grid_QuestList/Img_QuestList/RequiredGold (1)` active=True size=x=420,y=60 components=RectTransform,MonoBehaviour:1522d51f,MonoBehaviour:4293fd42

### UIMaidLobby

- Prefab: `Assets/Resources/prefabs/ui/UIMaidLobby.prefab`
- Godot: `godot-project/scripts/maid_lobby_reference_screen.gd`
- Status: `prefab_first_partial`
- RectTransforms: 10
- Layout kinds: fixed_anchor=4, full_stretch=4, large_panel=1, mixed=1
- Components: CanvasRenderer=8, Image=6, MonoBehaviour:18d0a906=1, MonoBehaviour:1be30ab7=1, MonoBehaviour:21c79540=1, MonoBehaviour:4293fd42=2, MonoBehaviour:76ccfb4b=1, MonoBehaviour:d699a3d5=1, MonoBehaviour:da9b4ee3=1, MonoBehaviour:f18f2cc2=1, RectTransform=10, TextMeshProUGUI=1
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 28

Key serialized rect paths:

- `UIMaidLobby` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:d699a3d5
- `UIMaidLobby/BG` active=True size=x=5000,y=400 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobby/White` active=True size=x=400,y=400 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobby/SpinePos` active=True size=x=100,y=100 components=RectTransform
- `UIMaidLobby/Gradient` active=True size=x=400,y=200 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobby/Npc_Dialog` active=True size=x=540,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:f18f2cc2,MonoBehaviour:21c79540,MonoBehaviour:da9b4ee3
- `UIMaidLobby/Npc_Dialog/Icon_Dialog` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b,MonoBehaviour:4293fd42
- `UIMaidLobby/Npc_Dialog/Tail` active=True size=x=25,y=15 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42
- `UIMaidLobby/Npc_Dialog/Text_Dialog` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,TextMeshProUGUI,MonoBehaviour:1be30ab7
- `UIMaidLobby/DialogBtn` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906

### UIPopup_Inventory

- Prefab: `Assets/Resources/prefabs/ui/popup/UIPopup_Inventory.prefab`
- Godot: `godot-project/scripts/inventory_popup_reference_screen.gd`
- Status: `prefab_first_partial`
- RectTransforms: 131
- Layout kinds: fixed_anchor=48, full_stretch=56, mixed=27
- Components: CanvasRenderer=108, Image=101, MonoBehaviour:16c0ec1e=25, MonoBehaviour:18d0a906=11, MonoBehaviour:19fbb4a3=5, MonoBehaviour:1be30ab7=2, MonoBehaviour:21c79540=5, MonoBehaviour:25b8ef92=1, MonoBehaviour:2cbaf7f9=2, MonoBehaviour:4293fd42=24, MonoBehaviour:598ca59b=3, MonoBehaviour:76ccfb4b=4, MonoBehaviour:8ffc7d92=2, MonoBehaviour:da9b4ee3=1, MonoBehaviour:e7250304=1, MonoBehaviour:f18f2cc2=2, RectTransform=131, TextMeshProUGUI=5
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 15

Key serialized rect paths:

- `UIPopup_Inventory` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:25b8ef92
- `UIPopup_Inventory/Dim` active=True size=x=400,y=400 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIPopup_Inventory/BG` active=True size=x=0,y=1630 components=RectTransform,MonoBehaviour:f18f2cc2,MonoBehaviour:21c79540
- `UIPopup_Inventory/BG/ProduceInventory` active=True size=x=920,y=0 components=RectTransform,MonoBehaviour:4293fd42
- `UIPopup_Inventory/BG/ProduceInventory/BG` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42
- `UIPopup_Inventory/BG/ProduceInventory/BG/Color` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/BG/Image` active=True size=x=0,y=120 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/BG/Image/Image_1` active=True size=x=128,y=256 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/BG/Image/Image_2` active=True size=x=128,y=256 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/TOT` active=True size=x=0,y=-80 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e,MonoBehaviour:4293fd42
- `UIPopup_Inventory/BG/ProduceInventory/TOT/Image` active=True size=x=460,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/TOT/Image_1` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/TOT/Bot_3` active=True size=x=-80,y=-80 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/TOT/Bot_2` active=True size=x=-78,y=-78 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/ScrollViewMask` active=True size=x=-86,y=-166 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/ScrollViewMask/Scroll View` active=True size=x=790,y=1065 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:2cbaf7f9,MonoBehaviour:4293fd42
- `UIPopup_Inventory/BG/ProduceInventory/ScrollViewMask/Scroll View/Viewport` active=True size=x=0,y=-123 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/Iron/Iron_1` active=True size=x=-2,y=-2 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/Iron/Iron_1/Image` active=True size=x=0,y=13 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/Iron/Image_6` active=True size=x=30,y=8 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/Iron/Image_2` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Inventory/BG/ProduceInventory/OL` active=True size=x=2,y=2 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42
- `UIPopup_Inventory/BG/ProduceInventory/Irons` active=True size=x=2,y=-80 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e,MonoBehaviour:4293fd42
- `UIPopup_Inventory/BG/ProduceInventory/Irons/Iron/Iron_1` active=True size=x=-2,y=-2 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Inventory/BG/ProduceInventory/Irons/Iron/Iron_1/Image` active=True size=x=0,y=13 components=RectTransform,CanvasRenderer,Image

### UIPopup_Shop

- Prefab: `Assets/Resources/prefabs/ui/popup/shop/UIPopup_Shop.prefab`
- Godot: `godot-project/scripts/shop_popup_reference_screen.gd`
- Status: `prefab_first_partial`
- RectTransforms: 932
- Layout kinds: fixed_anchor=553, full_stretch=320, large_panel=4, mixed=55
- Components: CanvasRenderer=754, Image=385, MonoBehaviour:09d2eff8=10, MonoBehaviour:16c0ec1e=40, MonoBehaviour:18d0a906=48, MonoBehaviour:19fbb4a3=46, MonoBehaviour:1be30ab7=64, MonoBehaviour:21c79540=31, MonoBehaviour:2cbaf7f9=3, MonoBehaviour:2f92a323=3, MonoBehaviour:32753fc3=1, MonoBehaviour:35faa8f5=1, MonoBehaviour:4293fd42=122, MonoBehaviour:594212b2=1, MonoBehaviour:598ca59b=7, MonoBehaviour:5eccd90b=20, MonoBehaviour:62677321=2, MonoBehaviour:6c71a908=5, MonoBehaviour:75ba2a8b=46, MonoBehaviour:76ccfb4b=23, MonoBehaviour:7f04cdee=1, MonoBehaviour:865ff746=1, MonoBehaviour:8d5f9603=1, MonoBehaviour:8da296ca=15, MonoBehaviour:8ffc7d92=9, MonoBehaviour:93716f31=5, MonoBehaviour:a1b197ce=6, MonoBehaviour:a1e79089=165, MonoBehaviour:abd451f2=2, MonoBehaviour:da9b4ee3=3, MonoBehaviour:e43d41b3=15, MonoBehaviour:e7250304=8, MonoBehaviour:f18f2cc2=9, MonoBehaviour:f3f93bf7=1, MonoBehaviour:fe7d7fa5=2, MonoBehaviour:ff326197=41, RectTransform=932, TextMeshProUGUI=101
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 28

Key serialized rect paths:

- `UIPopup_Shop` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:865ff746
- `UIPopup_Shop/Dim` active=True size=x=400,y=400 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG` active=True size=x=0,y=40 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b
- `UIPopup_Shop/BG/Top` active=True size=x=-24,y=400 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_Shop/BG/Top/BG` active=True size=x=2048,y=270 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Shadow` active=True size=x=0,y=100 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/SkeletonGraphic (Customer11_SD_Store)` active=True size=x=612.026,y=909.01 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UIPopup_Shop/BG/Top/Char` active=False size=x=500,y=500 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title` active=True size=x=0,y=100 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:598ca59b,MonoBehaviour:16c0ec1e
- `UIPopup_Shop/BG/Top/Title/deco` active=True size=x=100,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (1)` active=True size=x=163.938,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (2)` active=True size=x=131.507,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (3)` active=True size=x=20.0674,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (4)` active=True size=x=100,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (5)` active=True size=x=163.938,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (6)` active=True size=x=131.507,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/deco (7)` active=True size=x=20.0674,y=5 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/Image (2)` active=True size=x=700,y=400 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/Image (3)` active=True size=x=700,y=400 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/Image` active=True size=x=700,y=400 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/Image (1)` active=True size=x=700,y=400 components=RectTransform,CanvasRenderer,Image
- `UIPopup_Shop/BG/Top/Title/Text (TMP)` active=True size=x=-280,y=100 components=RectTransform,CanvasRenderer,TextMeshProUGUI,MonoBehaviour:1be30ab7
- `UIPopup_Shop/BG/Top/ChatBox` active=True size=x=540,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b,MonoBehaviour:da9b4ee3,MonoBehaviour:21c79540,MonoBehaviour:f18f2cc2
- `UIPopup_Shop/BG/Top/ChatBox/Tail` active=True size=x=32,y=22 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b,MonoBehaviour:4293fd42
- `UIPopup_Shop/BG/Top/ChatBox/Text (TMP)` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,TextMeshProUGUI,MonoBehaviour:1be30ab7,MonoBehaviour:4293fd42

### UIPopup_MaidLobbySelect

- Prefab: `Assets/Resources/prefabs/ui/popup/outgame/UIPopup_MaidLobbySelect.prefab`
- Godot: `godot-project/scripts/maid_lobby_select_popup_reference_screen.gd`
- Status: `prefab_first_partial`
- RectTransforms: 87
- Layout kinds: fixed_anchor=42, full_stretch=41, mixed=4
- Components: CanvasRenderer=64, Image=53, MonoBehaviour:16c0ec1e=10, MonoBehaviour:18d0a906=10, MonoBehaviour:19fbb4a3=1, MonoBehaviour:1be30ab7=3, MonoBehaviour:21c79540=1, MonoBehaviour:4293fd42=3, MonoBehaviour:5eccd90b=2, MonoBehaviour:8da296ca=1, MonoBehaviour:8ffc7d92=1, MonoBehaviour:bc52f174=1, MonoBehaviour:e43d41b3=7, MonoBehaviour:f18f2cc2=1, MonoBehaviour:ff326197=8, RectTransform=87, TextMeshProUGUI=3
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 14

Key serialized rect paths:

- `UIPopup_MaidLobbySelect` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:bc52f174
- `UIPopup_MaidLobbySelect/Dim` active=True size=x=600,y=600 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG` active=True size=x=100,y=100 components=RectTransform
- `UIPopup_MaidLobbySelect/BG/Panel` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:f18f2cc2,MonoBehaviour:21c79540
- `UIPopup_MaidLobbySelect/BG/Panel/TextTitle` active=True size=x=0,y=105 components=RectTransform,CanvasRenderer,TextMeshProUGUI,MonoBehaviour:1be30ab7,MonoBehaviour:4293fd42
- `UIPopup_MaidLobbySelect/BG/Panel/Btn_Close` active=True size=x=150,y=124 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906,MonoBehaviour:4293fd42
- `UIPopup_MaidLobbySelect/BG/Panel/Btn_Close/Img_Close` active=True size=x=50,y=50 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:8ffc7d92
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone/Mask` active=True size=x=-2,y=-2 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone/Mask/Image` active=True size=x=240,y=240 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone/OutLine` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone/Select` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone/Select/Select` active=False size=x=10,y=10 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1/Mask` active=True size=x=-2,y=-2 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1/Mask/SpinePos/Maid_1001_SD_Ingame` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:e43d41b3
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1/Mask/SpinePos/Maid_1001_SD_Ingame/SkeletonGraphic (Ch_Maid01_Basic01_SD)` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1/OutLine` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1/Select` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_1/Select/Select` active=False size=x=10,y=10 components=RectTransform,CanvasRenderer,Image
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_2` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_2/Mask` active=True size=x=-2,y=-2 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_2/Mask/SpinePos/Maid_1002_SD_InGame` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:e43d41b3
- `UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_2/Mask/SpinePos/Maid_1002_SD_InGame/SkeletonGraphic (Ch_Maid02_Basic01_SD)` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197

### UIFurnitureQuest

- Prefab: `Assets/Resources/prefabs/ui/UIFurnitureQuest.prefab`
- Godot: `godot-project/scripts/furniture_quest_popup_reference_screen.gd`
- Status: `manual_shell`
- RectTransforms: 20
- Layout kinds: fixed_anchor=15, full_stretch=4, mixed=1
- Components: CanvasRenderer=18, Image=12, MonoBehaviour:16c0ec1e=1, MonoBehaviour:18d0a906=1, MonoBehaviour:2f92a323=1, MonoBehaviour:6c71a908=1, MonoBehaviour:8b6b0933=1, MonoBehaviour:9aade2ae=1, RectTransform=20, TextMeshProUGUI=1
- Godot has `set_source`: False
- Godot has RectTransform helpers: False
- Godot hard-coded `Rect2(...)` calls: 12

Key serialized rect paths:

- `UIFurnitureQuest` active=True size=x=200,y=200 components=RectTransform,MonoBehaviour:9aade2ae,CanvasRenderer
- `UIFurnitureQuest/Button` active=True size=x=180,y=180 components=RectTransform,CanvasRenderer,MonoBehaviour:18d0a906
- `UIFurnitureQuest/Button/chaMask` active=False size=x=183.641,y=154.79 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:16c0ec1e
- `UIFurnitureQuest/Button/chaMask/RawImage` active=False size=x=200,y=200 components=RectTransform,CanvasRenderer,MonoBehaviour:8b6b0933
- `UIFurnitureQuest/Button/chaMask/chaImg` active=False size=x=203.706,y=268.18 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image (2)` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image` active=True size=x=-72,y=-72 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image/Image` active=True size=x=12,y=12 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image/Image (1)` active=True size=x=12,y=12 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image/Image (2)` active=True size=x=12,y=12 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image (1)` active=False size=x=-72,y=-72 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Image (1)/Image (1)` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Main` active=False size=x=50,y=50 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Sub` active=False size=x=50,y=50 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/Text (TMP)` active=False size=x=100,y=60 components=RectTransform,CanvasRenderer,TextMeshProUGUI
- `UIFurnitureQuest/Button/UFX_Noti_V2` active=False size=x=100,y=100 components=RectTransform,CanvasRenderer,MonoBehaviour:2f92a323
- `UIFurnitureQuest/Button/UFX_Noti_V2/Noti` active=False size=x=32,y=32 components=RectTransform,CanvasRenderer,Image
- `UIFurnitureQuest/Button/UFX_Noti_V2/UIParticle` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:6c71a908

### UIVillageReBuild

- Prefab: `Assets/Resources/prefabs/ui/UIVillageReBuild.prefab`
- Godot: `godot-project/scripts/out_game_reference_screen.gd`
- Status: `prefab_first_partial`
- RectTransforms: 6
- Layout kinds: fixed_anchor=4, full_stretch=2
- Components: CanvasRenderer=3, Image=3, MonoBehaviour:1522d51f=1, MonoBehaviour:898db6d9=1, RectTransform=6
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 79

Key serialized rect paths:

- `UIVillageReBuild` active=True size=x=100,y=100 components=RectTransform,MonoBehaviour:898db6d9
- `UIVillageReBuild/Fillbar` active=True size=x=560,y=100 components=RectTransform,MonoBehaviour:1522d51f
- `UIVillageReBuild/Fillbar/Background` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIVillageReBuild/Fillbar/Fill Area` active=True size=x=0,y=0 components=RectTransform
- `UIVillageReBuild/Fillbar/Fill Area/Fill` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIVillageReBuild/Fillbar/Image` active=True size=x=80,y=80 components=RectTransform,CanvasRenderer,Image

### UIMaidLobbyLoading

- Prefab: `Assets/Resources/prefabs/ui/UIMaidLobbyLoading.prefab`
- Godot: `godot-project/scripts/maid_lobby_loading_reference_screen.gd`
- Status: `prefab_reference_shell`
- RectTransforms: 86
- Layout kinds: fixed_anchor=19, full_stretch=67
- Components: CanvasRenderer=83, Image=67, MonoBehaviour:f18f2cc2=1, RectTransform=86
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 14

Key serialized rect paths:

- `UIMaidLobbyLoading` active=True size=x=0,y=0 components=RectTransform
- `UIMaidLobbyLoading/GameObject` active=True size=x=1200,y=1000 components=RectTransform,MonoBehaviour:f18f2cc2
- `UIMaidLobbyLoading/GameObject/Image_00` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer
- `UIMaidLobbyLoading/GameObject/Image_00/0` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_00/0/Deco` active=True size=x=-200,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_00/0/Deco_1` active=True size=x=-440,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_00/0/Deco_2` active=True size=x=-720,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_01` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer
- `UIMaidLobbyLoading/GameObject/Image_01/1` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_01/1/Deco` active=True size=x=-200,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_01/1/Deco_1` active=True size=x=-440,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_01/1/Deco_2` active=True size=x=-720,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_02` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer
- `UIMaidLobbyLoading/GameObject/Image_02/2` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_02/2/Deco` active=True size=x=-200,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_02/2/Deco_1` active=True size=x=-440,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_02/2/Deco_2` active=True size=x=-720,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_03` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer
- `UIMaidLobbyLoading/GameObject/Image_03/3` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_03/3/Deco` active=True size=x=-200,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_03/3/Deco_1` active=True size=x=-440,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_03/3/Deco_2` active=True size=x=-720,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_04` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer
- `UIMaidLobbyLoading/GameObject/Image_04/4` active=True size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIMaidLobbyLoading/GameObject/Image_04/4/Deco` active=True size=x=-200,y=0 components=RectTransform,CanvasRenderer,Image

### UILoading

- Prefab: `Assets/Resources/prefabs/ui/UILoading.prefab`
- Godot: `godot-project/scripts/loading_reference_screen.gd`
- Status: `mixed_unwired`
- RectTransforms: 65
- Layout kinds: fixed_anchor=53, full_stretch=10, mixed=2
- Components: CanvasRenderer=54, GraphicRaycaster=2, Image=38, MonoBehaviour:1522d51f=1, MonoBehaviour:16c0ec1e=3, MonoBehaviour:18d0a906=3, MonoBehaviour:19fbb4a3=1, MonoBehaviour:1be30ab7=3, MonoBehaviour:5eccd90b=1, MonoBehaviour:abceb3f4=1, MonoBehaviour:e7250304=1, MonoBehaviour:ff326197=6, RectTransform=65, TextMeshProUGUI=5
- Godot has `set_source`: True
- Godot has RectTransform helpers: False
- Godot hard-coded `Rect2(...)` calls: 5

Key serialized rect paths:

- `UILoading` active=True size=x=1080,y=1920 components=RectTransform,MonoBehaviour:abceb3f4,GraphicRaycaster
- `UILoading/Loading_Type` active=True size=x=0,y=0 components=RectTransform
- `UILoading/Loading_Type/BG_Base` active=True size=x=2048,y=2048 components=RectTransform
- `UILoading/Loading_Type/BG_Base/BG` active=True size=x=2048,y=2048 components=RectTransform,CanvasRenderer,Image
- `UILoading/Loading_Type/BG_Base/BG_Event` active=True size=x=2048,y=2048 components=RectTransform,CanvasRenderer,Image
- `UILoading/Loading_Type/BG_Base/HalloweenBG` active=False size=x=3072,y=2048 components=RectTransform,CanvasRenderer,Image
- `UILoading/Loading_Type/BG_Base/HalloweenBG/White` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UILoading/Ch` active=True size=x=100,y=0 components=RectTransform
- `UILoading/Ch/1` active=True size=x=100,y=100 components=RectTransform
- `UILoading/Ch/2` active=True size=x=100,y=100 components=RectTransform
- `UILoading/Ch/3` active=True size=x=100,y=100 components=RectTransform
- `UILoading/LogoArea` active=True size=x=0,y=0 components=RectTransform
- `UILoading/LogoArea/LogoImage` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer,Image
- `UILoading/LogoArea/Logo_KR` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer
- `UILoading/LogoArea/Logo_KR/SkeletonGraphic (MugeMaidcafe Logo)` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UILoading/LogoArea/Logo_EN` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer
- `UILoading/LogoArea/Logo_EN/SkeletonGraphic (MaidCafe_Logo_Eg)` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UILoading/LogoArea/Logo_JP` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer
- `UILoading/LogoArea/Logo_JP/SkeletonGraphic (MaidCafe_Logo_Jp)` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UILoading/LogoArea/Logo_CH` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer
- `UILoading/LogoArea/Logo_CH/SkeletonGraphic (MaidCafe_Logo_CH)` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UILoading/LogoArea/Logo_CHS` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer
- `UILoading/LogoArea/Logo_CHS/SkeletonGraphic (MaidCafe_Logo_CH)` active=False size=x=512,y=512 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UILoading/LoadingBar` active=True size=x=670,y=50 components=RectTransform,MonoBehaviour:1522d51f
- `UILoading/LoadingBar/Background` active=True size=x=10,y=10 components=RectTransform,CanvasRenderer,Image

### UISceneLoading

- Prefab: `Assets/Resources/prefabs/ui/UISceneLoading.prefab`
- Godot: `godot-project/scripts/scene_loading_reference_screen.gd`
- Status: `prefab_reference_shell`
- RectTransforms: 323
- Layout kinds: fixed_anchor=29, full_stretch=290, large_panel=2, mixed=2
- Components: CanvasRenderer=310, Image=6, MonoBehaviour:0f1865a4=1, MonoBehaviour:19fbb4a3=2, MonoBehaviour:4293fd42=2, MonoBehaviour:a1e79089=287, MonoBehaviour:ff326197=15, RectTransform=323
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 20

Key serialized rect paths:

- `UISceneLoading` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:0f1865a4
- `UISceneLoading/SceneObjects` active=True size=x=1506.46,y=2105.96 components=RectTransform
- `UISceneLoading/SceneObjects/TypeA` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeA/SkeletonGraphic (kokomi_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeB` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeB/SkeletonGraphic (Aku_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeC` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeC/SkeletonGraphic (Aku_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeD` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeD/SkeletonGraphic (Aku_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeE` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeE/SkeletonGraphic (Aku_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeF` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeF/SkeletonGraphic (Aku_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeG` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeG/SkeletonGraphic (Aku_Loading)` active=False size=x=2000,y=2000 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/SceneObjects/TypeNormal` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeNormal/BG` active=False size=x=200,y=200 components=RectTransform,CanvasRenderer,Image
- `UISceneLoading/SceneObjects/TypeChristMas (1)` active=False size=x=1655.45,y=2314.24 components=RectTransform
- `UISceneLoading/SceneObjects/TypeChristMas (1)/BG` active=False size=x=1050,y=2686 components=RectTransform,CanvasRenderer,Image
- `UISceneLoading/Curtain_R` active=True size=x=190,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:19fbb4a3
- `UISceneLoading/Curtain_R/Curtain_L (1)` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42
- `UISceneLoading/Curtain_R/New SkeletonGraphic (1)` active=True size=x=185,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/Curtain_R/New SkeletonGraphic (2)` active=True size=x=185,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197
- `UISceneLoading/Curtain_R/New SkeletonGraphic (3)` active=True size=x=185,y=0 components=RectTransform,CanvasRenderer,MonoBehaviour:ff326197

### UIOutGame

- Prefab: `Assets/Resources/prefabs/ui/UIOutGame.prefab`
- Godot: `godot-project/scripts/out_game_reference_screen.gd`
- Status: `prefab_first_partial`
- RectTransforms: 26
- Layout kinds: fixed_anchor=15, full_stretch=11
- Components: CanvasRenderer=16, Image=14, MonoBehaviour:1522d51f=1, MonoBehaviour:18d0a906=5, MonoBehaviour:1be30ab7=1, MonoBehaviour:21c79540=1, MonoBehaviour:4293fd42=2, MonoBehaviour:475afc92=2, MonoBehaviour:76ccfb4b=3, MonoBehaviour:898db6d9=1, MonoBehaviour:93ffe31a=2, MonoBehaviour:b6611600=1, MonoBehaviour:da9b4ee3=1, MonoBehaviour:f18f2cc2=1, MonoBehaviour:f5569eb6=1, RectTransform=26, TextMeshProUGUI=1
- Godot has `set_source`: True
- Godot has RectTransform helpers: True
- Godot hard-coded `Rect2(...)` calls: 79

Key serialized rect paths:

- `UIOutGame` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:f5569eb6
- `UIOutGame/UIOutGame` active=True size=x=0,y=0 components=RectTransform
- `UIOutGame/UIOutGame/FurnitureQuest` active=True size=x=100,y=100 components=RectTransform
- `UIOutGame/UIOutGame/UIMaidLD` active=True size=x=0,y=0 components=RectTransform,MonoBehaviour:b6611600
- `UIOutGame/UIOutGame/UIMaidLD/Dim` active=True size=x=400,y=400 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:475afc92,MonoBehaviour:475afc92
- `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog` active=False size=x=540,y=158.8 components=RectTransform,CanvasRenderer,MonoBehaviour:f18f2cc2,MonoBehaviour:21c79540,MonoBehaviour:da9b4ee3
- `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog/Icon_Dialog` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b,MonoBehaviour:4293fd42
- `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog/Tail` active=False size=x=25,y=15 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:4293fd42
- `UIOutGame/UIOutGame/UIMaidLD/SpinePos/Npc_Dialog/Text_Dialog` active=False size=x=480,y=118.8 components=RectTransform,CanvasRenderer,TextMeshProUGUI,MonoBehaviour:1be30ab7
- `UIOutGame/UIOutGame/UIMaidLD/Btn_ToNormal` active=False size=x=400,y=400 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIOutGame/UIOutGame/UIMaidLD/Btn_ToInteraction` active=True size=x=320,y=590 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIOutGame/UIOutGame/UIMaidLD/Btn_InteractionArea` active=False size=x=-400,y=-199.9 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906
- `UIOutGame/UIOutGame/InGameBtn` active=True size=x=300,y=246 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906,MonoBehaviour:93ffe31a
- `UIOutGame/UIOutGame/InGameBtn/InGame` active=True size=x=300,y=246 components=RectTransform,CanvasRenderer,Image
- `UIOutGame/UIOutGame/MaidLobbyBtn` active=False size=x=200,y=200 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:18d0a906,MonoBehaviour:93ffe31a
- `UIOutGame/UIOutGame/MaidLobbyBtn/ToOutGame` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b
- `UIOutGame/UIOutGame/MaidLobbyBtn/ToMaidLobby` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image,MonoBehaviour:76ccfb4b
- `UIOutGame/UIOutGame/UIVillageReBuild` active=False size=x=100,y=100 components=RectTransform,MonoBehaviour:898db6d9
- `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar` active=False size=x=560,y=100 components=RectTransform,MonoBehaviour:1522d51f
- `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Background` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Fill Area` active=False size=x=0,y=0 components=RectTransform
- `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Fill Area/Fill` active=False size=x=0,y=0 components=RectTransform,CanvasRenderer,Image
- `UIOutGame/UIOutGame/UIVillageReBuild/Fillbar/Image` active=False size=x=80,y=80 components=RectTransform,CanvasRenderer,Image

## Required Next Work

1. Promote every `manual_shell` high-priority screen to `prefab_reference_shell` by loading this focused JSON and using RectTransform conversion helpers.
2. Raise high-priority screens to at least six source-referenced rect paths before marking them as prefab-first partial.
3. Resolve Image sprite GUIDs to concrete asset names for each focused prefab before replacing geometric fallbacks.
4. Keep screenshot captures as regression checks only; they do not count as source placement evidence.
