# Godot UI Resource Export Notes

Date: 2026-05-23

These PNG files were exported from the original YooAsset bundles with:

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  <physicalPath> `
  reverse-output\godot-resource-export\<asset-key> `
  --xor-prefix 222 --xor-key 0x16 --container-paths `
  --types Texture2D,Sprite,TextAsset,AudioClip
```

The intermediate export folder is `reverse-output/godot-resource-export/`. The runtime Godot assets are the curated PNG files in this directory tree.

| Godot file | Original asset |
|---|---|
| `background/login_bg_01.png` | `Assets/Game/RawAssets/Sprite/BackGround/login_bg_01.png` |
| `background/mainui_bg_01.png` | `Assets/Game/RawAssets/Sprite/BackGround/mainui_bg_01.png` |
| `background/mainui_bg_02.png` | `Assets/Game/RawAssets/Sprite/BackGround/mainui_bg_02.png` |
| `login/logo.png` | `Assets/Game/RawAssets/Sprite/Login/logo.png` |
| `login/login_btn_03.png` | `Assets/Game/RawAssets/Sprite/Login/Login_btn_03.png` |
| `login/server_bg_011.png` | `Assets/Game/RawAssets/Sprite/Login/server_bg_011.png` |
| `login/server_bg_03.png` | `Assets/Game/RawAssets/Sprite/Login/server_bg_03.png` |
| `login/server_bg_107.png` | `Assets/Game/RawAssets/Sprite/Login/server_bg_107.png` |
| `lottery/lottery_img_01.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_01.png` |
| `lottery/lottery_img_02.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_02.png` |
| `lottery/lottery_img_03.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_03.png` |
| `lottery/lottery_img_60.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_60.png` |
| `lottery/lottery_img_60_l.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_60_l.png` |
| `lottery/lottery_img_60_r.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_60_r.png` |
| `lottery/lottery_img_alpha_l.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_alpha_l.png` |
| `lottery/lottery_img_alpha_r.png` | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_alpha_r.png` |
| `mainui/mainui_img_01.png` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_01.png` |
| `mainui/mainui_img_10.png` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_10.png` |
| `mainui/mainui_img_12.png` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_12.png` |
| `mainui/mainui_img_44.png` | `Assets/Game/RawAssets/Sprite/MainUI/mainui_img_44.png` |

