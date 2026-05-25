# GalMapEventGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `GalMapEventGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/GalMapEventGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_galmapeventgrid.bundle` / `files\yoo\Default\BundleFiles\ae\ae523cbed7e51933616f138d09331b3d\__data`
- 节点数：`2`。
- Image/Text/Button：`2` / `0` / `1`。
- Image 解析：外部 Sprite `2`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_54` | 1 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_54.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |
| `yhero_000` | 1 | `Assets/Game/RawAssets/Sprite/Head/Round/yhero_000.png` | `assets_game_rawassets_sprite_head_round.bundle` | `ed83c7f6493927f7eb32770282eb16b5.bundle`<br>`resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` | external CAB-f8ef5bffbbc70cdd4b384bfa099efd20 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-f8ef5bffbbc70cdd4b384bfa099efd20` | `assets_game_rawassets_sprite_head_round.bundle` | `resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `GalMapEventGrid` | Y | `pos(52.0,75.0) size(-1574.0,-646.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,GalMapEventGrid` | Image:gal_img_54 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 2 | 1 | `GalMapEventGrid/btnHead` | Y | `pos(0.0,4.0) size(-24.0,-32.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:yhero_000 [Simple] -> assets_game_rawassets_sprite_head_round.bundle<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
