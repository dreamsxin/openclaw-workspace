# RemnantsChangeGrid 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsChangeGrid`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsChangeGrid.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantschangegrid.bundle` / `files\yoo\Default\BundleFiles\57\572183013ced5201017f4f4806a0bd7a\__data`
- 节点数：`18`。
- Image/Text/Button：`13` / `3` / `1`。
- Image 解析：外部 Sprite `8`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `0`，未解析 `4`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsChangeGrid.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_remnants_remnantschangegrid.bundle` | `572183013ced5201017f4f4806a0bd7a.bundle`<br>`files\yoo\Default\BundleFiles\57\572183013ced5201017f4f4806a0bd7a\__data` | internal Sprite in prefab bundle |
| `common_img_73` | 2 | `Assets/Game/RawAssets/Sprite/Common/common_img_73.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_img_74` | 3 | `Assets/Game/RawAssets/Sprite/Common/common_img_74.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `hero_img_18` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_18.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_19` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_19.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_76` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_76.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 2 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 3 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 4 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |
| 5 | `CAB-34b95862cded399c7e60a6bd42fc750d` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsChangeGrid` | Y | `pos(0.0,-42.2) size(172.0,296.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,RemnantsChangeGrid` | - |
| 2 | 1 | `RemnantsChangeGrid/imgBg` | Y | `pos(0.0,0.0) size(172.0,296.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_18 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 3 | 1 | `RemnantsChangeGrid/imgRemnant` | Y | `pos(0.0,-125.0) size(160.0,250.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=5 pid=501290010759348784 cab=CAB-34b95862cded399c7e60a6bd42fc750d [Simple] |
| 4 | 1 | `RemnantsChangeGrid/imgFrame` | Y | `pos(0.0,46.0) size(160.0,108.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_19 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 5 | 1 | `RemnantsChangeGrid/txtName` | Y | `pos(0.0,-116.0) size(0.0,-276.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=20):"阿赛特节杖aaaa" |
| 6 | 1 | `RemnantsChangeGrid/imgSkillBg` | Y | `pos(-8.9,-2.9) size(62.2,62.2)` | `1.0,1.0->1.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=8376328699360261513 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 7 | 2 | `RemnantsChangeGrid/imgSkillBg/imgSkill` | Y | `pos(0.0,0.0) size(-24.0,-24.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_76 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 8 | 1 | `RemnantsChangeGrid/imgState` | Y | `pos(12.0,-6.0) size(64.0,22.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=117519149739391194 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 9 | 2 | `RemnantsChangeGrid/imgState/txtState` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=16):"当前上阵" |
| 10 | 1 | `RemnantsChangeGrid/@StarBar` | Y | `pos(-23.0,-79.0) size(112.0,36.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter,StarBar` | - |
| 11 | 2 | `RemnantsChangeGrid/@StarBar/@imgStar` | Y | `pos(18.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 12 | 2 | `RemnantsChangeGrid/@StarBar/@imgStar` | Y | `pos(37.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_73 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 13 | 2 | `RemnantsChangeGrid/@StarBar/@imgStar` | Y | `pos(56.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 14 | 2 | `RemnantsChangeGrid/@StarBar/@imgStar` | Y | `pos(75.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 15 | 2 | `RemnantsChangeGrid/@StarBar/@imgStar` | Y | `pos(94.0,-18.0) size(36.0,36.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_img_74 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 16 | 1 | `RemnantsChangeGrid/txtLevel` | Y | `pos(52.5,-74.0) size(36.0,20.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=30):"99" |
| 17 | 1 | `RemnantsChangeGrid/imgSelect` | Y | `pos(0.0,-140.0) size(160.0,280.0)` | `0.5,1.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=3 pid=6787950688082571629 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 18 | 1 | `RemnantsChangeGrid/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_remnants_remnantschangegrid.bundle, a=0.00<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
