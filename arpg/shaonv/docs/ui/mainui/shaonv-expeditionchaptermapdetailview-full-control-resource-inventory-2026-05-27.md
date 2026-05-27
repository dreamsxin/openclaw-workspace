# ExpeditionChapterMapDetailView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `ExpeditionChapterMapDetailView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Expedition/ExpeditionChapterMapDetailView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_expedition_expeditionchaptermapdetailview.bundle` / `files\yoo\Default\BundleFiles\5d\5d60efd9a44c1959d50d1cc174970f17\__data`
- 节点数：`9`。
- Image/Text/Button：`5` / `3` / `2`。
- Image 解析：外部 Sprite `4`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `1`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_bg_08` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/common_bg_08.png` | `assets_game_rawassets_sprite_background_common_bg_08.bundle` | `69568309ad2ea0f6e0c6ae08276fa5c1.bundle`<br>`files\yoo\Default\BundleFiles\69\69568309ad2ea0f6e0c6ae08276fa5c1\__data` | external CAB-c7844917f066f4b6b942103f51eb6db0 |
| `common_btn_16` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_16.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_btn_17` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_17.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `expedition_img_10` | 1 | `Assets/Game/RawAssets/Sprite/Expedition/expedition_img_10.png` | `assets_game_rawassets_sprite_expedition_expedition_img_10.bundle` | `3319c3c9d6256d02e9ec2cc9d76830c5.bundle`<br>`files\yoo\Default\BundleFiles\33\3319c3c9d6256d02e9ec2cc9d76830c5\__data` | external CAB-63bbabf62be29a370211c4046b91ddb7 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 2 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 3 | `CAB-63bbabf62be29a370211c4046b91ddb7` | `assets_game_rawassets_sprite_expedition_expedition_img_10.bundle` | `files\yoo\Default\BundleFiles\33\3319c3c9d6256d02e9ec2cc9d76830c5\__data` |
| 4 | `CAB-c7844917f066f4b6b942103f51eb6db0` | `assets_game_rawassets_sprite_background_common_bg_08.bundle` | `files\yoo\Default\BundleFiles\69\69568309ad2ea0f6e0c6ae08276fa5c1\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `ExpeditionChapterMapDetailView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,ExpeditionChapterMapDetailView` | - |
| 2 | 1 | `ExpeditionChapterMapDetailView/Image` | Y | `pos(0.0,0.0) size(708.0,608.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_bg_08 [Simple] -> assets_game_rawassets_sprite_background_common_bg_08.bundle |
| 3 | 2 | `ExpeditionChapterMapDetailView/Image/btnClose` | Y | `pos(317.0,269.0) size(60.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_16 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 4 | 2 | `ExpeditionChapterMapDetailView/Image/txtTitle` | Y | `pos(-125.0,275.4) size(-298.0,-583.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"千星都会" |
| 5 | 2 | `ExpeditionChapterMapDetailView/Image/imgCover` | Y | `pos(0.0,117.0) size(640.0,200.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:expedition_img_10 [Simple] -> assets_game_rawassets_sprite_expedition_expedition_img_10.bundle |
| 6 | 2 | `ExpeditionChapterMapDetailView/Image/txtDetail` | Y | `pos(0.0,-85.0) size(640.0,160.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=22):"在这座名为【千星都会】的梦幻之地，古老的存在正借助星灵的..." |
| 7 | 2 | `ExpeditionChapterMapDetailView/Image/Image` | Y | `pos(0.0,-195.0) size(-48.0,-606.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple], a=0.10 |
| 8 | 2 | `ExpeditionChapterMapDetailView/Image/btnConfirm` | Y | `pos(0.0,-248.0) size(320.0,64.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_17 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 9 | 3 | `ExpeditionChapterMapDetailView/Image/btnConfirm/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"已通关" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
