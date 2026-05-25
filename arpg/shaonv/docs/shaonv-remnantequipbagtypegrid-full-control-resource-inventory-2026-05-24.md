# RemnantEquipBagTypeGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantEquipBagTypeGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantEquipBagTypeGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantequipbagtypegrid.bundle` / `files\yoo\Default\BundleFiles\db\db6cac96725b71c84d1ac6cccf77faa4\__data`
- 节点数：`3`。
- Image/Text/Button：`1` / `2` / `1`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `Resources_btn_02` | 1 | `Assets/Game/RawAssets/Sprite/Login/Resources_btn_02.png` | `assets_game_rawassets_sprite_login.bundle` | `8cfe4e0148670640e919adc92c841d6c.bundle`<br>`resources\assets\yoo\Default\8cfe4e0148670640e919adc92c841d6c.bundle` | external CAB-54755a9f79c14d66f3154d096ad52589 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-54755a9f79c14d66f3154d096ad52589` | `assets_game_rawassets_sprite_login.bundle` | `resources\assets\yoo\Default\8cfe4e0148670640e919adc92c841d6c.bundle` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantEquipBagTypeGrid` | Y | `pos(0.5,219.7) size(113.5,44.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,RemnantEquipBagTypeGrid` | Image:Resources_btn_02 [Simple] -> assets_game_rawassets_sprite_login.bundle<br>Button |
| 2 | 1 | `RemnantEquipBagTypeGrid/txtNormal` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"武器" |
| 3 | 1 | `RemnantEquipBagTypeGrid/txtHelight` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"武器" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
