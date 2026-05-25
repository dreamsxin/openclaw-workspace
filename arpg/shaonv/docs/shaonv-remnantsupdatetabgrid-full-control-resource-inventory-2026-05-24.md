# RemnantsUpdateTabGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsUpdateTabGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsUpdateTabGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsupdatetabgrid.bundle` / `files\yoo\Default\BundleFiles\96\969925ae92561becb44c32afd79da3b3\__data`
- 节点数：`7`。
- Image/Text/Button：`5` / `2` / `2`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `2`，未解析 `1`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsUpdateTabGrid.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_remnants_remnantsupdatetabgrid.bundle` | `969925ae92561becb44c32afd79da3b3.bundle`<br>`files\yoo\Default\BundleFiles\96\969925ae92561becb44c32afd79da3b3\__data` | internal Sprite in prefab bundle |
| `common_img_127` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_127.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 3 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsUpdateTabGrid` | Y | `pos(195.0,-22.0) size(150.0,44.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,Button,CanvasRenderer,Image,RemnantsUpdateTabGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `RemnantsUpdateTabGrid/Image` | Y | `pos(0.0,0.0) size(150.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 3 | 2 | `RemnantsUpdateTabGrid/Image/txtNormal` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"升级" |
| 4 | 2 | `RemnantsUpdateTabGrid/Image/imgLock` | Y | `pos(40.1,0.0) size(20.0,20.0)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_127 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 5 | 1 | `RemnantsUpdateTabGrid/Image` | N | `pos(0.0,0.0) size(130.0,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=1933107396982301870 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 6 | 2 | `RemnantsUpdateTabGrid/Image/txtHeighlight` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"升级" |
| 7 | 1 | `RemnantsUpdateTabGrid/btnLock` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantsupdatetabgrid.bundle, a=0.00<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
