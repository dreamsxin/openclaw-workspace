# RemnantsUpdateSelectGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsUpdateSelectGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsUpdateSelectGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsupdateselectgrid.bundle` / `files\yoo\Default\BundleFiles\ea\ea3a961a6a1142e495218af4e4678b39\__data`
- 节点数：`12`。
- Image/Text/Button：`10` / `0` / `1`。
- Image 解析：外部 Sprite `9`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_img_01` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_01.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_07` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_07.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_10` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_10.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_73` | 5 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `fpet_001` | 1 | `Assets/Game/RawAssets/Sprite/Head/Square/fpet_001.png` | `assets_game_rawassets_sprite_head_square.bundle` | `c891ba87e85bf4a5fb50f9a6b4a17ec4.bundle`<br>`resources\assets\yoo\Default\c891ba87e85bf4a5fb50f9a6b4a17ec4.bundle` | external CAB-affdf3ff19638c78732cb086997a78d2 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 2 | `CAB-affdf3ff19638c78732cb086997a78d2` | `assets_game_rawassets_sprite_head_square.bundle` | `resources\assets\yoo\Default\c891ba87e85bf4a5fb50f9a6b4a17ec4.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsUpdateSelectGrid` | Y | `pos(0.0,0.0) size(112.0,112.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,RemnantsUpdateSelectGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `RemnantsUpdateSelectGrid/imgBg` | Y | `pos(0.0,0.0) size(112.0,112.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_07 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 3 | 2 | `RemnantsUpdateSelectGrid/imgBg/imgRemnant` | Y | `pos(0.0,0.8) size(100.8,99.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:fpet_001 [Simple] -> assets_game_rawassets_sprite_head_square.bundle |
| 4 | 2 | `RemnantsUpdateSelectGrid/imgBg/imgStar` | Y | `pos(0.0,-14.4) size(100.8,17.6)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_10 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 5 | 3 | `RemnantsUpdateSelectGrid/imgBg/imgStar/pnlStarContent` | Y | `pos(5.6,0.0) size(89.6,29.2)` | `0.0,0.5->0.0,0.5 p(0.0,0.5)` | `RectTransform` | - |
| 6 | 4 | `RemnantsUpdateSelectGrid/imgBg/imgStar/pnlStarContent/imgStar0` | Y | `pos(14.4,-14.6) size(28.8,28.8)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 7 | 4 | `RemnantsUpdateSelectGrid/imgBg/imgStar/pnlStarContent/imgStar1` | Y | `pos(29.6,-14.6) size(28.8,28.8)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 8 | 4 | `RemnantsUpdateSelectGrid/imgBg/imgStar/pnlStarContent/imgStar2` | Y | `pos(44.8,-14.6) size(28.8,28.8)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 9 | 4 | `RemnantsUpdateSelectGrid/imgBg/imgStar/pnlStarContent/imgStar3` | Y | `pos(60.0,-14.6) size(28.8,28.8)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 10 | 4 | `RemnantsUpdateSelectGrid/imgBg/imgStar/pnlStarContent/imgStar4` | Y | `pos(75.2,-14.6) size(28.8,28.8)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 11 | 1 | `RemnantsUpdateSelectGrid/imgSelect` | N | `pos(0.0,0.0) size(112.0,112.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_01 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 12 | 1 | `RemnantsUpdateSelectGrid/@pnlRd` | Y | `pos(50.3,50.5) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
