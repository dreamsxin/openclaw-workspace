# RemnantsListView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsListView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsListView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantslistview.bundle` / `files\yoo\Default\BundleFiles\38\38b3569f24c273ec921b1126c05c0975\__data`
- 节点数：`36`。
- Image/Text/Button：`15` / `16` / `3`。
- Image 解析：外部 Sprite `4`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `10`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Remnants_bg_01` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/Remnants_bg_01.png` | `assets_game_rawassets_sprite_background_remnants_bg_01.bundle` | `78bfef76a153b86673775025d5919d84.bundle`<br>`files\yoo\Default\BundleFiles\78\78bfef76a153b86673775025d5919d84\__data` | external CAB-4a87eaee50d71cf83fefcc89956df6e8 |
| `remnants_img_01` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_01.png` | `assets_game_rawassets_sprite_remnants_remnants_img_01.bundle` | `f49636aeb5cd00b4a01d3f1e4908d6e4.bundle`<br>`files\yoo\Default\BundleFiles\f4\f49636aeb5cd00b4a01d3f1e4908d6e4\__data` | external CAB-c8d9a6fb2edf635d245c901d4934c86e |
| `remnants_img_02` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_02.png` | `assets_game_rawassets_sprite_remnants_remnants_img_02.bundle` | `6002d181f716cc3e1d8626cb15f71a12.bundle`<br>`files\yoo\Default\BundleFiles\60\6002d181f716cc3e1d8626cb15f71a12\__data` | external CAB-b65b100297551a94b40d0e63c3c6fd9c |
| `remnants_img_04` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_04.png` | `assets_game_rawassets_sprite_remnants_remnants_img_04.bundle` | `f138efd6c66a47b49f0a63baa730541a.bundle`<br>`files\yoo\Default\BundleFiles\f1\f138efd6c66a47b49f0a63baa730541a\__data` | external CAB-2b122efb2f8a239e0e0a0fc710b7bc43 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-0d5731a6a534bfedecdb443e393185d2` | `-` | `-` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 4 | `CAB-b65b100297551a94b40d0e63c3c6fd9c` | `assets_game_rawassets_sprite_remnants_remnants_img_02.bundle` | `files\yoo\Default\BundleFiles\60\6002d181f716cc3e1d8626cb15f71a12\__data` |
| 5 | `CAB-c8d9a6fb2edf635d245c901d4934c86e` | `assets_game_rawassets_sprite_remnants_remnants_img_01.bundle` | `files\yoo\Default\BundleFiles\f4\f49636aeb5cd00b4a01d3f1e4908d6e4\__data` |
| 6 | `CAB-2b122efb2f8a239e0e0a0fc710b7bc43` | `assets_game_rawassets_sprite_remnants_remnants_img_04.bundle` | `files\yoo\Default\BundleFiles\f1\f138efd6c66a47b49f0a63baa730541a\__data` |
| 7 | `CAB-447c0d7e9c627349de840c9abff682b1` | `assets_game_rawassets_prefabs_ui_common_leftcommontabgridmask.bundle` | `files\yoo\Default\BundleFiles\66\66f460cc4ba1aed37025f3e0e7a624c2\__data` |
| 8 | `CAB-4a87eaee50d71cf83fefcc89956df6e8` | `assets_game_rawassets_sprite_background_remnants_bg_01.bundle` | `files\yoo\Default\BundleFiles\78\78bfef76a153b86673775025d5919d84\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsListView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RemnantsListView,Animator` | Image:none [Sliced], a=0.00 |
| 2 | 1 | `RemnantsListView/imgBg` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:Remnants_bg_01 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_01.bundle |
| 3 | 1 | `RemnantsListView/imgBase` | Y | `pos(-220.0,0.0) size(1042.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:remnants_img_01 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_01.bundle |
| 4 | 2 | `RemnantsListView/imgBase/btnConfirm` | Y | `pos(0.0,-312.0) size(316.0,86.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=3 pid=6771108641299508787 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 5 | 3 | `RemnantsListView/imgBase/btnConfirm/Text` | Y | `pos(0.0,8.0) size(52.0,38.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=26):"培养" |
| 6 | 3 | `RemnantsListView/imgBase/btnConfirm/@pnlRd` | Y | `pos(134.3,38.4) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 7 | 2 | `RemnantsListView/imgBase/Text` | Y | `pos(0.0,32.5) size(-930.0,-709.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=28):"基座共鸣" |
| 8 | 2 | `RemnantsListView/imgBase/imgAttribute` | Y | `pos(0.0,-124.0) size(580.0,254.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_img_02 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_02.bundle |
| 9 | 3 | `RemnantsListView/imgBase/imgAttribute/txtLv` | Y | `pos(0.0,113.0) size(160.0,38.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"LV.99" |
| 10 | 3 | `RemnantsListView/imgBase/imgAttribute/txtGlobalTitle` | Y | `pos(195.5,-49.0) size(349.0,32.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"全局属性加成" |
| 11 | 3 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 12 | 4 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid0` | Y | `pos(-140.0,41.0) size(260.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=-1827012799220695969 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 13 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid0/txtTitle` | Y | `pos(59.0,0.0) size(100.0,30.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 14 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid0/txtValue` | Y | `pos(-80.0,0.0) size(142.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 15 | 4 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid1` | Y | `pos(140.0,41.0) size(260.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=-1827012799220695969 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 16 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid1/txtTitle` | Y | `pos(59.0,0.0) size(100.0,30.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 17 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid1/txtValue` | Y | `pos(-80.0,0.0) size(142.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 18 | 4 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid2` | Y | `pos(-140.0,1.0) size(260.0,-224.0)` | `0.5,0.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=-1827012799220695969 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 19 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid2/txtTitle` | Y | `pos(59.0,0.0) size(100.0,30.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 20 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlGlobalAttribute/@globalAttrGrid2/txtValue` | Y | `pos(-80.0,0.0) size(142.0,30.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"Default" |
| 21 | 3 | `RemnantsListView/imgBase/imgAttribute/txtStarTitle` | Y | `pos(251.9,-185.0) size(461.9,32.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"遗器满星加成（遗器总星级：10星）" |
| 22 | 3 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 23 | 4 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute/@starAttrGrid0` | Y | `pos(-185.0,-95.0) size(170.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=-1827012799220695969 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Sliced] |
| 24 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute/@starAttrGrid0/txtValue` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"遗器能量值+5%" |
| 25 | 4 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute/@starAttrGrid1` | Y | `pos(0.0,-95.0) size(170.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=-1827012799220695969 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Sliced] |
| 26 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute/@starAttrGrid1/txtValue` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"遗器能量值+5%" |
| 27 | 4 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute/@starAttrGrid2` | Y | `pos(185.0,-95.0) size(170.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=-1827012799220695969 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Sliced] |
| 28 | 5 | `RemnantsListView/imgBase/imgAttribute/pnlStarAttribute/@starAttrGrid2/txtValue` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"遗器能量值+5%" |
| 29 | 2 | `RemnantsListView/imgBase/imgIcon` | Y | `pos(0.0,208.5) size(403.0,325.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=21721582758192110 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 30 | 1 | `RemnantsListView/svRemnants` | Y | `pos(-324.0,-45.0) size(532.0,660.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller,CanvasGroup` | - |
| 31 | 1 | `RemnantsListView/imgTypeBg` | Y | `pos(-324.0,329.0) size(520.0,44.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:remnants_img_04 [Filled] -> assets_game_rawassets_sprite_remnants_remnants_img_04.bundle |
| 32 | 2 | `RemnantsListView/imgTypeBg/tabType` | Y | `pos(0.0,0.0) size(520.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |
| 33 | 1 | `RemnantsListView/btnWarOrder` | Y | `pos(104.0,-141.0) size(90.0,90.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,CanvasGroup` | Image:external fid=3 pid=7594439247281769184 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 34 | 2 | `RemnantsListView/btnWarOrder/Text` | Y | `pos(0.0,8.0) size(90.0,26.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=18):"山海基金" |
| 35 | 1 | `RemnantsListView/btnBattle` | Y | `pos(104.0,-250.0) size(90.0,90.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,CanvasGroup` | Image:external fid=3 pid=-73437953188983281 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 36 | 2 | `RemnantsListView/btnBattle/Text` | Y | `pos(0.0,8.0) size(90.0,26.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=18):"时序奇点" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
