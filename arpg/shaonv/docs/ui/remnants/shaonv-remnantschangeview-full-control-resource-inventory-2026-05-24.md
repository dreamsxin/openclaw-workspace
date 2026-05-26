# RemnantsChangeView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `RemnantsChangeView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Remnants/RemnantsChangeView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_remnants_remnantschangeview.bundle` / `files\yoo\Default\BundleFiles\31\31c780db91f35ab4d5ba19f36608bd0d\__data`
- 节点数：`33`。
- Image/Text/Button：`24` / `4` / `4`。
- Image 解析：外部 Sprite `5`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `6`，未解析 `13`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `remnants_bg_04` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/remnants_bg_04.png` | `assets_game_rawassets_sprite_background_remnants_bg_04.bundle` | `b660fc16584ba36fb8ed9e7c43125ea7.bundle`<br>`files\yoo\Default\BundleFiles\b6\b660fc16584ba36fb8ed9e7c43125ea7\__data` | external CAB-52621869c75421230fc2fc4baa105231 |
| `common_btn_16` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_16.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `ypet_003` | 3 | `Assets/Game/RawAssets/Sprite/Head/Round/ypet_003.png` | `assets_game_rawassets_sprite_head_round.bundle` | `ed83c7f6493927f7eb32770282eb16b5.bundle`<br>`resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` | external CAB-f8ef5bffbbc70cdd4b384bfa099efd20 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-2072e8a4ebb206b06dc45efec76dc158` | `-` | `-` |
| 3 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 4 | `CAB-f8ef5bffbbc70cdd4b384bfa099efd20` | `assets_game_rawassets_sprite_head_round.bundle` | `resources\assets\yoo\Default\ed83c7f6493927f7eb32770282eb16b5.bundle` |
| 5 | `CAB-52621869c75421230fc2fc4baa105231` | `assets_game_rawassets_sprite_background_remnants_bg_04.bundle` | `files\yoo\Default\BundleFiles\b6\b660fc16584ba36fb8ed9e7c43125ea7\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `RemnantsChangeView` | Y | `pos(0.0,0.0) size(1034.0,517.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,RemnantsChangeView` | - |
| 2 | 1 | `RemnantsChangeView/imgBg` | Y | `pos(0.0,0.0) size(1250.0,650.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:remnants_bg_04 [Simple] -> assets_game_rawassets_sprite_background_remnants_bg_04.bundle |
| 3 | 2 | `RemnantsChangeView/imgBg/Image` | Y | `pos(-470.0,277.0) size(278.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-6352638712246672658 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 4 | 3 | `RemnantsChangeView/imgBg/Image/Text` | Y | `pos(0.0,7.5) size(155.8,35.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=24):"更换遗器" |
| 5 | 2 | `RemnantsChangeView/imgBg/btnClose` | Y | `pos(-8.0,-8.0) size(60.0,60.0)` | `1.0,1.0->1.0,1.0 p(1.0,1.0)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_16 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 6 | 2 | `RemnantsChangeView/imgBg/svList` | Y | `pos(139.5,-29.5) size(909.0,541.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,CanvasRenderer,Image,GridScroller,RectMask2D` | Image:none [Simple], a=0.00 |
| 7 | 2 | `RemnantsChangeView/imgBg/@pnlRemnant0` | Y | `pos(77.0,-74.0) size(156.0,156.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform` | - |
| 8 | 3 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=3353819637829980886 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 9 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg/imgAdd` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3079843426699289289 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 10 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg/imgHead` | Y | `pos(0.0,0.0) size(92.0,92.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:ypet_003 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 11 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg/imgType` | Y | `pos(0.0,-48.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-9172875475482654612 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 12 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg/imgPos` | Y | `pos(0.0,3.0) size(152.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3254074831650597370 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 13 | 5 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg/imgPos/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"主站" |
| 14 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant0/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 15 | 2 | `RemnantsChangeView/imgBg/@pnlRemnant1` | Y | `pos(77.0,-264.0) size(156.0,156.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform` | - |
| 16 | 3 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=3353819637829980886 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 17 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg/imgAdd` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3079843426699289289 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 18 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg/imgHead` | Y | `pos(0.0,0.0) size(92.0,92.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:ypet_003 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 19 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg/imgType` | Y | `pos(0.0,-48.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-8584579573083175077 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 20 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg/imgPos` | Y | `pos(0.0,3.0) size(152.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3254074831650597370 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 21 | 5 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg/imgPos/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"辅助" |
| 22 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant1/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 23 | 2 | `RemnantsChangeView/imgBg/@pnlRemnant2` | Y | `pos(77.0,-454.0) size(156.0,156.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform` | - |
| 24 | 3 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=3353819637829980886 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 25 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg/imgAdd` | Y | `pos(0.0,0.0) size(156.0,156.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3079843426699289289 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 26 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg/imgHead` | Y | `pos(0.0,0.0) size(92.0,92.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:ypet_003 [Simple] -> assets_game_rawassets_sprite_head_round.bundle |
| 27 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg/imgType` | Y | `pos(0.0,-48.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-8584579573083175077 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 28 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg/imgPos` | Y | `pos(0.0,3.0) size(152.0,30.0)` | `0.5,0.0->0.5,0.0 p(0.5,1.0)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=2 pid=-3254074831650597370 cab=CAB-2072e8a4ebb206b06dc45efec76dc158 [Simple] |
| 29 | 5 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg/imgPos/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=22):"辅助" |
| 30 | 4 | `RemnantsChangeView/imgBg/@pnlRemnant2/imgBg/btnClick` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Sliced], a=0.00<br>Button |
| 31 | 2 | `RemnantsChangeView/imgBg/tabType` | Y | `pos(33.5,282.0) size(645.0,68.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,TabScrollView` | - |
| 32 | 3 | `RemnantsChangeView/imgBg/tabType/@imgLine0` | Y | `pos(-108.5,-0.5) size(2.0,27.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 33 | 3 | `RemnantsChangeView/imgBg/tabType/@imgLine1` | Y | `pos(109.5,-0.5) size(2.0,27.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
