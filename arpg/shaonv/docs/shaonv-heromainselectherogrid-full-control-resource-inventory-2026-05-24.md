# HeroMainSelectHeroGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `HeroMainSelectHeroGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainSelectHeroGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_hero_heromainselectherogrid.bundle` / `files\yoo\Default\BundleFiles\16\163716705c98e6b9d76ca8e251985463\__data`
- 节点数：`15`。
- Image/Text/Button：`12` / `1` / `1`。
- Image 解析：外部 Sprite `10`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Hero/HeroMainSelectHeroGrid.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_hero_heromainselectherogrid.bundle` | `163716705c98e6b9d76ca8e251985463.bundle`<br>`files\yoo\Default\BundleFiles\16\163716705c98e6b9d76ca8e251985463\__data` | internal Sprite in prefab bundle |
| `common_img_61` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_61.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_62` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_62.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_64` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_img_64.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `yhero_000` | 1 | `Assets/Game/RawAssets/Sprite/Head/Round/yhero_000.png` | `assets_game_rawassets_sprite_head_round.bundle` | `ed83c7f6493927f7eb32770282eb16b5.bundle`<br>`resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` | external CAB-f8ef5bffbbc70cdd4b384bfa099efd20 |
| `hero_img_119` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_119.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_60` | 5 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_60.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |
| 4 | `CAB-f8ef5bffbbc70cdd4b384bfa099efd20` | `assets_game_rawassets_sprite_head_round.bundle` | `resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `HeroMainSelectHeroGrid` | Y | `pos(0.0,0.0) size(70.0,70.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HeroMainSelectHeroGrid` | - |
| 2 | 1 | `HeroMainSelectHeroGrid/imgHightLight` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_119 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 3 | 1 | `HeroMainSelectHeroGrid/imgHero` | Y | `pos(0.0,0.0) size(70.0,70.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:yhero_000 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 4 | 1 | `HeroMainSelectHeroGrid/imgFrame` | Y | `pos(0.0,0.0) size(70.0,70.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_64 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 5 | 1 | `HeroMainSelectHeroGrid/pnlStar` | Y | `pos(0.0,-35.0) size(70.0,14.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,HorizontalLayoutGroup` | Image:common_img_62 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 6 | 2 | `HeroMainSelectHeroGrid/pnlStar/imgStar1` | Y | `pos(0.0,0.0) size(14.0,14.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_60 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 7 | 2 | `HeroMainSelectHeroGrid/pnlStar/imgStar2` | Y | `pos(0.0,0.0) size(14.0,14.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_60 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 8 | 2 | `HeroMainSelectHeroGrid/pnlStar/imgStar3` | Y | `pos(0.0,0.0) size(14.0,14.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_60 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 9 | 2 | `HeroMainSelectHeroGrid/pnlStar/imgStar4` | Y | `pos(0.0,0.0) size(14.0,14.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_60 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 10 | 2 | `HeroMainSelectHeroGrid/pnlStar/imgStar5` | Y | `pos(0.0,0.0) size(14.0,14.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_60 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 11 | 1 | `HeroMainSelectHeroGrid/Image` | Y | `pos(25.0,25.0) size(-42.0,-42.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_61 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 12 | 2 | `HeroMainSelectHeroGrid/Image/txtLv` | Y | `pos(0.0,0.0) size(23.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=16):"99" |
| 13 | 1 | `HeroMainSelectHeroGrid/imgCamp` | Y | `pos(-4.0,4.0) size(-42.0,-42.0)` | `0.0,0.0->1.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 14 | 1 | `HeroMainSelectHeroGrid/btn` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_hero_heromainselectherogrid.bundle, a=0.00<br>Button |
| 15 | 1 | `HeroMainSelectHeroGrid/pnlRedDot` | Y | `pos(0.0,0.0) size(70.0,70.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
