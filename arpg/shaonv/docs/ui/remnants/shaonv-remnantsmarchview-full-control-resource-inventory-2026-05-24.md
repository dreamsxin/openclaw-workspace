# RemnantsMarchView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsMarchView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsMarchView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantsmarchview.bundle` / `files\yoo\Default\BundleFiles\48\480ad1a7b5afc9e41a4ab6b4443507dc\__data`
- 节点数：`31`。
- Image/Text/Button：`20` / `4` / `3`。
- Image 解析：外部 Sprite `4`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `3`，未解析 `13`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `remnants_bg_04` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/remnants_bg_04.png` | `assets_game_rawassets_sprite_background_remnants_bg_04.bundle` | `b660fc16584ba36fb8ed9e7c43125ea7.bundle`<br>`files\yoo\Default\BundleFiles\b6\b660fc16584ba36fb8ed9e7c43125ea7\__data` | external CAB-52621869c75421230fc2fc4baa105231 |
| `ypet_003` | 3 | `Assets/Game/RawAssets/Sprite/Head/Round/ypet_003.png` | `assets_game_rawassets_sprite_head_round.bundle` | `ed83c7f6493927f7eb32770282eb16b5.bundle`<br>`resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` | external CAB-f8ef5bffbbc70cdd4b384bfa099efd20 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-f8ef5bffbbc70cdd4b384bfa099efd20` | `assets_game_rawassets_sprite_head_round.bundle` | `resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` |
| 2 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 4 | `CAB-52621869c75421230fc2fc4baa105231` | `assets_game_rawassets_sprite_background_remnants_bg_04.bundle` | `files\yoo\Default\BundleFiles\b6\b660fc16584ba36fb8ed9e7c43125ea7\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsMarchView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 2 | 1 | `RemnantsMarchView/imgBg` | Y | `pos(0.0,0.0) size(1250.0,650.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_bg_04 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_04.bundle |
| 3 | 2 | `RemnantsMarchView/imgBg/@imgTitle` | Y | `pos(-470.0,277.0) size(278.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-6352638712246672658 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 4 | 3 | `RemnantsMarchView/imgBg/@imgTitle/Text` | Y | `pos(0.0,7.5) size(278.0,-25.0)` | `0.5,0.0->0.5,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"遗器替换" |
| 5 | 2 | `RemnantsMarchView/imgBg/tabFightType` | Y | `pos(155.0,-27.9) size(272.0,529.9)` | `0.0,0.5->0.0,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |
| 6 | 2 | `RemnantsMarchView/imgBg/tabRemnantsType` | Y | `pos(33.5,282.0) size(645.0,68.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |
| 7 | 2 | `RemnantsMarchView/imgBg/svRemnants` | Y | `pos(142.0,-159.5) size(906.0,311.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,GridScroller` | - |
| 8 | 2 | `RemnantsMarchView/imgBg/@pnlRemnant0` | Y | `pos(-75.0,148.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 9 | 3 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=3353819637829980886 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 10 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg/imgAdd` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3079843426699289289 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 11 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg/imgHead` | Y | `pos(0.0,0.0) size(92.0,92.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:ypet_003 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 12 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg/imgType` | Y | `pos(0.0,-48.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-9172875475482654612 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 13 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg/imgPos` | Y | `pos(0.0,-7.0) size(152.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3254074831650597370 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 14 | 5 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg/imgPos/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"主站" |
| 15 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant0/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 16 | 2 | `RemnantsMarchView/imgBg/@pnlRemnant1` | Y | `pos(145.0,148.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 17 | 3 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=3353819637829980886 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 18 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg/imgAdd` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3079843426699289289 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 19 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg/imgHead` | Y | `pos(0.0,0.0) size(92.0,92.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:ypet_003 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 20 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg/imgType` | Y | `pos(0.0,-48.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-8584579573083175077 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 21 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg/imgPos` | Y | `pos(0.0,-7.0) size(152.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3254074831650597370 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 22 | 5 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg/imgPos/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"辅助" |
| 23 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant1/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 24 | 2 | `RemnantsMarchView/imgBg/@pnlRemnant2` | Y | `pos(365.0,148.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 25 | 3 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=3353819637829980886 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 26 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg/imgAdd` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3079843426699289289 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 27 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg/imgHead` | Y | `pos(0.0,0.0) size(92.0,92.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:ypet_003 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 28 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg/imgType` | Y | `pos(0.0,-48.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-8584579573083175077 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 29 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg/imgPos` | Y | `pos(0.0,-7.0) size(152.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3254074831650597370 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 30 | 5 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg/imgPos/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"辅助" |
| 31 | 4 | `RemnantsMarchView/imgBg/@pnlRemnant2/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
