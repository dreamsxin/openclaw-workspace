# RemnantsShowRoomGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsShowRoomGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsShowRoomGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsshowroomgrid.bundle` / `files\yoo\Default\BundleFiles\a8\a8317523e4797dc91eda1970ab21c07b\__data`
- 节点数：`19`。
- Image/Text/Button：`7` / `6` / `1`。
- Image 解析：外部 Sprite `6`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_73` | 2 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_74` | 3 | `Assets/Game/RawAssets/Sprite/Common/common_img_74.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `remnants_img_12` | 1 | `Assets/Game/RawAssets/Sprite/Remnants/remnants_img_12.png` | `assets_game_rawassets_sprite_remnants_remnants_img_12.bundle` | `95760626081bbcb1892bea25c2bf229b.bundle`<br>`files\yoo\Default\BundleFiles\95\95760626081bbcb1892bea25c2bf229b\__data` | external CAB-1518fd6bb404f9ebd3b5a093f1a14496 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-d658a91595cb5cdab7e786ba072b54a2` | `-` | `-` |
| 3 | `CAB-1518fd6bb404f9ebd3b5a093f1a14496` | `assets_game_rawassets_sprite_remnants_remnants_img_12.bundle` | `files\yoo\Default\BundleFiles\95\95760626081bbcb1892bea25c2bf229b\__data` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsShowRoomGrid` | Y | `pos(0.0,0.0) size(306.0,580.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,RemnantsShowRoomGrid,CanvasGroup` | - |
| 2 | 1 | `RemnantsShowRoomGrid/imgBg` | Y | `pos(0.0,0.0) size(306.0,580.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_img_12 [Simple] -> assets_game_rawassets_sprite_remnants_remnants_img_12.bundle |
| 3 | 2 | `RemnantsShowRoomGrid/imgBg/pnlSpine` | N | `pos(0.0,-32.9) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 4 | 3 | `RemnantsShowRoomGrid/imgBg/pnlSpine/spineRemnants` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 5 | 2 | `RemnantsShowRoomGrid/imgBg/txtName` | Y | `pos(0.0,-102.0) size(88.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"奥丁之眼" |
| 6 | 2 | `RemnantsShowRoomGrid/imgBg/txtLv` | Y | `pos(0.0,-134.5) size(44.0,29.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"LV.1" |
| 7 | 2 | `RemnantsShowRoomGrid/imgBg/@StarBar` | Y | `pos(0.0,-165.0) size(112.0,36.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter,StarBar` | - |
| 8 | 3 | `RemnantsShowRoomGrid/imgBg/@StarBar/@imgStar` | Y | `pos(18.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 9 | 3 | `RemnantsShowRoomGrid/imgBg/@StarBar/@imgStar` | Y | `pos(36.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 10 | 3 | `RemnantsShowRoomGrid/imgBg/@StarBar/@imgStar` | Y | `pos(54.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 11 | 3 | `RemnantsShowRoomGrid/imgBg/@StarBar/@imgStar` | Y | `pos(72.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 12 | 3 | `RemnantsShowRoomGrid/imgBg/@StarBar/@imgStar` | Y | `pos(90.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 13 | 2 | `RemnantsShowRoomGrid/imgBg/pnlAttr` | Y | `pos(0.0,-229.0) size(182.0,66.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 14 | 3 | `RemnantsShowRoomGrid/imgBg/pnlAttr/txtAttrName0` | Y | `pos(36.0,53.0) size(72.0,26.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"阵容攻击" |
| 15 | 3 | `RemnantsShowRoomGrid/imgBg/pnlAttr/txtAttrName1` | Y | `pos(36.0,13.0) size(72.0,26.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"阵容攻击" |
| 16 | 3 | `RemnantsShowRoomGrid/imgBg/pnlAttr/txtAttrValue0` | Y | `pos(-36.0,53.0) size(72.0,26.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"9999" |
| 17 | 3 | `RemnantsShowRoomGrid/imgBg/pnlAttr/txtAttrValue1` | Y | `pos(-36.0,13.0) size(72.0,26.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"9999" |
| 18 | 2 | `RemnantsShowRoomGrid/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 19 | 2 | `RemnantsShowRoomGrid/imgBg/pnlRedDot` | Y | `pos(0.0,0.0) size(228.0,452.8)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
