# SpineDragEffect01 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `SpineDragEffect01`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Gal/SpineTouch/SpineDragEffect01.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_gal_spinetouch_spinedrageffect01.bundle` / `files\yoo\Default\UnpackBundleFiles\69\6978e72a150ef211b3ce1307d460a9d5\__data`
- 节点数：`7`。
- Image/Text/Button：`3` / `0` / `0`。
- Image 解析：外部 Sprite `3`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `0`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `gal_img_999` | 3 | `Assets/Game/RawAssets/Sprite/Gal/gal_img_999.png` | `assets_game_rawassets_sprite_gal.bundle` | `9b3005c642f23a035f900e91974d2f1f.bundle`<br>`files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` | external CAB-29985079a0c30e92c06965acc8970fd6 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-29985079a0c30e92c06965acc8970fd6` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 2 | `CAB-fc7c42c20e664411707322f5c8b13ff9` | `-` | `-` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `SpineDragEffect01` | Y | `pos(242.3,-197.6) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SpineTouchDragEffect` | - |
| 2 | 1 | `SpineDragEffect01/fx_shower_bubble` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:gal_img_999 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 3 | 2 | `SpineDragEffect01/fx_shower_bubble/vfx` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 4 | 3 | `SpineDragEffect01/fx_shower_bubble/vfx/shuipao` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ParticleSystem,ParticleSystemRenderer,UiParticles,CanvasRenderer` | - |
| 5 | 4 | `SpineDragEffect01/fx_shower_bubble/vfx/shuipao/shuipao (1)` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ParticleSystem,ParticleSystemRenderer,UiParticles,CanvasRenderer` | - |
| 6 | 3 | `SpineDragEffect01/fx_shower_bubble/vfx/imgBg (3)` | N | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:gal_img_999 [Simple] -> assets_game_rawassets_sprite_gal.bundle |
| 7 | 1 | `SpineDragEffect01/Image` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:gal_img_999 [Simple] -> assets_game_rawassets_sprite_gal.bundle |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
