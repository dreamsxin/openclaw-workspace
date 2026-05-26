# HeroListTabGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `HeroListTabGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListTabGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_hero_herolisttabgrid.bundle` / `files\yoo\Default\BundleFiles\0a\0a5d481788549bdbd647e64afa859fda\__data`
- 节点数：`6`。
- Image/Text/Button：`4` / `2` / `1`。
- Image 解析：外部 Sprite `1`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `3`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_btn_07` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_07.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `HeroListTabGrid` | Y | `pos(-737.0,144.0) size(206.0,62.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,HeroListTabGrid` | Image:none [Simple], a=0.00<br>Button |
| 2 | 1 | `HeroListTabGrid/txtNormal` | Y | `pos(52.7,-1.6) size(103.4,76.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"总览" |
| 3 | 2 | `HeroListTabGrid/txtNormal/imgNormalIcon` | Y | `pos(-72.6,1.6) size(40.0,40.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 4 | 1 | `HeroListTabGrid/imgHighLight` | Y | `pos(0.0,0.0) size(206.0,64.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_btn_07 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 5 | 2 | `HeroListTabGrid/imgHighLight/txtHighLight` | Y | `pos(52.7,-1.6) size(103.4,76.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"总览" |
| 6 | 3 | `HeroListTabGrid/imgHighLight/txtHighLight/imgHighLightIcon` | Y | `pos(-72.6,1.6) size(40.0,40.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
