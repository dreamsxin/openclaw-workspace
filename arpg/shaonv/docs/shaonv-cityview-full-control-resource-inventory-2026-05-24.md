# CityView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `CityView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/City/CityView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_city_cityview.bundle` / `files\yoo\Default\BundleFiles\e3\e36f563f5a308c6797acb547b21886c7\__data`
- 节点数：`16`。
- Image/Text/Button：`15` / `0` / `7`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `7`，未解析 `7`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `city_bg_01` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/city_bg_01.png` | `assets_game_rawassets_sprite_background_city_bg_01.bundle` | `0b3b897cf508aad8b74a8dc5783dfc3e.bundle`<br>`files\yoo\Default\BundleFiles\0b\0b3b897cf508aad8b74a8dc5783dfc3e\__data` | external CAB-05ef73cd28cda29e9f4e00d95aa9ccf2 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-755b7f86b89daf8a2a077009b3ad4910` | `-` | `-` |
| 2 | `CAB-fe0668bdcadfeccb1da0b36c9fbe13a5` | `-` | `-` |
| 3 | `CAB-05ef73cd28cda29e9f4e00d95aa9ccf2` | `assets_game_rawassets_sprite_background_city_bg_01.bundle` | `files\yoo\Default\BundleFiles\0b\0b3b897cf508aad8b74a8dc5783dfc3e\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `CityView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,BackgroundMusic,CityView` | - |
| 2 | 1 | `CityView/imgBg` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:city_bg_01 [Simple] -> assets_game_rawassets_sprite_background_city_bg_01.bundle |
| 3 | 1 | `CityView/imgCoffee` | Y | `pos(-398.0,253.0) size(280.0,175.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=1702958892538491028 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 4 | 2 | `CityView/imgCoffee/btnCoffee` | Y | `pos(-36.0,0.0) size(370.0,175.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 5 | 1 | `CityView/imgHospice` | Y | `pos(-516.0,-124.0) size(118.0,343.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=-2744897272272948846 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 6 | 2 | `CityView/imgHospice/btnHospice` | Y | `pos(34.0,11.0) size(250.0,435.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 7 | 1 | `CityView/imgCamp` | Y | `pos(-145.0,-27.0) size(224.0,197.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=-3606043479443534987 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 8 | 2 | `CityView/imgCamp/btnCamp` | Y | `pos(-9.0,87.3) size(205.0,324.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 9 | 1 | `CityView/imgTactics` | Y | `pos(0.0,307.0) size(178.0,104.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=-4534490699983792918 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 10 | 2 | `CityView/imgTactics/btnTactics` | Y | `pos(0.0,-5.1) size(178.0,114.1)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 11 | 1 | `CityView/imgShelter` | Y | `pos(82.0,126.0) size(142.0,65.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=6843540240698695505 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 12 | 2 | `CityView/imgShelter/btnShelter` | Y | `pos(18.2,-66.1) size(195.8,197.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 13 | 1 | `CityView/imgLadder` | Y | `pos(-24.0,-250.0) size(147.0,250.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=1678989682215363023 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 14 | 2 | `CityView/imgLadder/btnLadder` | Y | `pos(0.0,0.0) size(147.0,250.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 15 | 1 | `CityView/imgPavilion` | Y | `pos(262.7,-110.0) size(160.0,117.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Grey` | Image:external fid=2 pid=6809092196970165335 cab=CAB-fe0668bdcadfeccb1da0b36c9fbe13a5 [Simple] |
| 16 | 2 | `CityView/imgPavilion/btnPavilion` | Y | `pos(0.0,-22.4) size(160.0,161.9)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
