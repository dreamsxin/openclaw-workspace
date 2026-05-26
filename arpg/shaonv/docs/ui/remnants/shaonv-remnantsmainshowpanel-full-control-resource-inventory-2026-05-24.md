# RemnantsMainShowPanel 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsMainShowPanel`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsMainShowPanel.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsmainshowpanel.bundle` / `files\yoo\Default\BundleFiles\c6\c695f988fc2682e0915688e4c1736ec2\__data`
- 节点数：`19`。
- Image/Text/Button：`10` / `4` / `3`。
- Image 解析：外部 Sprite `7`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `2`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_73` | 2 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_74` | 3 | `Assets/Game/RawAssets/Sprite/Common/common_img_74.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `remnants_img_02` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_02.png` | `assets_game_rawassets_sprite_remnants_remnants_img_02.bundle` | `6002d181f716cc3e1d8626cb15f71a12.bundle`<br>`files\yoo\Default\BundleFiles\60\6002d181f716cc3e1d8626cb15f71a12\__data` | external CAB-b65b100297551a94b40d0e63c3c6fd9c |
| `remnants_img_06` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_06.png` | `assets_game_rawassets_sprite_remnants_remnants_img_06.bundle` | `aa00ec5613b074e8e1e89d9f87d0977c.bundle`<br>`files\yoo\Default\BundleFiles\aa\aa00ec5613b074e8e1e89d9f87d0977c\__data` | external CAB-c1b44e78df6c1d6271547441a7571ed4 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-d658a91595cb5cdab7e786ba072b54a2` | `-` | `-` |
| 3 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 4 | `CAB-b65b100297551a94b40d0e63c3c6fd9c` | `assets_game_rawassets_sprite_remnants_remnants_img_02.bundle` | `files\yoo\Default\BundleFiles\60\6002d181f716cc3e1d8626cb15f71a12\__data` |
| 5 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 6 | `CAB-c1b44e78df6c1d6271547441a7571ed4` | `assets_game_rawassets_sprite_remnants_remnants_img_06.bundle` | `files\yoo\Default\BundleFiles\aa\aa00ec5613b074e8e1e89d9f87d0977c\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsMainShowPanel` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,RemnantsMainShowPanel` | - |
| 2 | 1 | `RemnantsMainShowPanel/imgContent` | Y | `pos(0.0,404.0) size(226.0,404.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_img_02 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_02.bundle |
| 3 | 2 | `RemnantsMainShowPanel/imgContent/btnAdd` | Y | `pos(0.0,126.7) size(212.0,212.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=5 pid=5716415776903518313 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 4 | 3 | `RemnantsMainShowPanel/imgContent/btnAdd/txtLockTip` | Y | `pos(0.0,-115.2) size(160.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"玩家等级40级解锁" |
| 5 | 2 | `RemnantsMainShowPanel/imgContent/btnUpdate` | Y | `pos(0.0,126.7) size(212.0,212.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 6 | 2 | `RemnantsMainShowPanel/imgContent/pnlSpine` | Y | `pos(0.0,-26.0) size(100.0,100.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 7 | 3 | `RemnantsMainShowPanel/imgContent/pnlSpine/spineRemnant` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 8 | 2 | `RemnantsMainShowPanel/imgContent/btnChange` | Y | `pos(129.0,205.0) size(76.0,76.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=5 pid=-7332196548149887623 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple]<br>Button |
| 9 | 2 | `RemnantsMainShowPanel/imgContent/txtType` | Y | `pos(0.0,-106.5) size(40.0,29.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"主战" |
| 10 | 2 | `RemnantsMainShowPanel/imgContent/pnlInfo` | Y | `pos(0.0,-210.5) size(254.0,115.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_img_06 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_06.bundle |
| 11 | 3 | `RemnantsMainShowPanel/imgContent/pnlInfo/txtName` | Y | `pos(0.0,41.5) size(160.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"奥丁之眼" |
| 12 | 3 | `RemnantsMainShowPanel/imgContent/pnlInfo/txtLv` | Y | `pos(0.0,9.0) size(66.0,29.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"LV.1" |
| 13 | 3 | `RemnantsMainShowPanel/imgContent/pnlInfo/@StarBar` | Y | `pos(0.0,-21.5) size(112.0,36.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter,StarBar` | - |
| 14 | 4 | `RemnantsMainShowPanel/imgContent/pnlInfo/@StarBar/@imgStar` | Y | `pos(18.4,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 15 | 4 | `RemnantsMainShowPanel/imgContent/pnlInfo/@StarBar/@imgStar` | Y | `pos(37.2,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 16 | 4 | `RemnantsMainShowPanel/imgContent/pnlInfo/@StarBar/@imgStar` | Y | `pos(56.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 17 | 4 | `RemnantsMainShowPanel/imgContent/pnlInfo/@StarBar/@imgStar` | Y | `pos(74.8,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 18 | 4 | `RemnantsMainShowPanel/imgContent/pnlInfo/@StarBar/@imgStar` | Y | `pos(93.6,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 19 | 2 | `RemnantsMainShowPanel/imgContent/pnlRedDot` | Y | `pos(70.8,392.7) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
