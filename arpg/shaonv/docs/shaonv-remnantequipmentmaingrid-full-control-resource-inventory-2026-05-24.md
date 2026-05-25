# RemnantEquipmentMainGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantEquipmentMainGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantEquipmentMainGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantequipmentmaingrid.bundle` / `files\yoo\Default\BundleFiles\86\8651f0f51708f50a2f72fdc1fb781d40\__data`
- 节点数：`10`。
- Image/Text/Button：`7` / `2` / `1`。
- Image 解析：外部 Sprite `0`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `2`，未解析 `4`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantEquipmentMainGrid.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_remnants_remnantequipmentmaingrid.bundle` | `8651f0f51708f50a2f72fdc1fb781d40.bundle`<br>`files\yoo\Default\BundleFiles\86\8651f0f51708f50a2f72fdc1fb781d40\__data` | internal Sprite in prefab bundle |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantEquipmentMainGrid` | Y | `pos(-250.5,1.5) size(160.0,160.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,RemnantEquipmentMainGrid` | Image:external fid=1 pid=4939920992070507061 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 2 | 1 | `RemnantEquipmentMainGrid/pnlHave` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer` | - |
| 3 | 2 | `RemnantEquipmentMainGrid/pnlHave/imgEquip` | Y | `pos(0.7,-0.6) size(64.0,64.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 4 | 2 | `RemnantEquipmentMainGrid/pnlHave/txtLv` | Y | `pos(0.0,-21.0) size(82.0,16.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=18):"999级" |
| 5 | 2 | `RemnantEquipmentMainGrid/pnlHave/pnlStar` | Y | `pos(0.0,-44.0) size(100.0,22.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-6130884744495347796 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 6 | 3 | `RemnantEquipmentMainGrid/pnlHave/pnlStar/txtStar` | Y | `pos(0.0,0.0) size(160.0,30.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=18):"Default" |
| 7 | 1 | `RemnantEquipmentMainGrid/pnlNone` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.00 |
| 8 | 2 | `RemnantEquipmentMainGrid/pnlNone/imgNone` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-2410850803834350640 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 9 | 1 | `RemnantEquipmentMainGrid/btnClick` | Y | `pos(0.0,0.0) size(105.0,105.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantequipmentmaingrid.bundle, a=0.00<br>Button |
| 10 | 1 | `RemnantEquipmentMainGrid/imgPos` | N | `pos(0.0,32.0) size(-54.0,-54.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-3523480614720189170 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
