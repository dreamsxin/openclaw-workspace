# ExpeditionMap WorldMap 源分包布局重建记录

生成时间：2026-05-27。

本文只处理一件事：把用户指定的 `share_assets_art_worldmap01~10*` 逻辑分包，与当前本地已经闭合的 `ExpeditionMapView` 运行时 tile / icon / prefab 布局串成一条可复用的重建链路。

## 结论摘要

- 用户给出的 27 个 `worldmap` 逻辑分包 hash 中，当前已经确认：
  - `worldmap01` 家族 5 个包可从本地资源根直接解包
  - `worldmap03~10` 的 `*_images.bundle` 可从 `files/yoo/Default/BundleFiles` 直接导出
  - `worldmap02_images.bundle` 目前仍缺
- `worldmap01` 不是 `ExpeditionMapView` 直接消费的 UI prefab 包，而是一个**地图源场景/源拼图包**：
  - 主体节点：`WorldMap_00`
  - 子块数量：`64`
  - 子块命名：`00_01` 到 `00_64`
  - 子块贴图：来自 `share_assets_art_worldmap01_images.bundle`
- `worldmap01` 的源布局可以重建成一个 **8x8 的原始拼图面**：
  - 每块 sprite 尺寸：`388x388`
  - 总尺寸：`8 * 388 = 3104`
  - 这与 `WorldMap01_AutoTileMapData` 的 `97x97`、tile 尺寸 `32x32` 完全对齐：
    - `97 * 32 = 3104`
- 因此可以把当前链路闭合成：
  - `share_assets_art_worldmap01*` 提供**源地图拼图、建筑裁片、水面特效和 mask**
  - 后续烘焙/切分后，运行时再落到 `ExpeditionMapView` 使用的 `WorldMap_<x>_<y>.png` tile
  - `ExpeditionMapView` 本身只负责 `4096x4096` 滚动容器、chunk 容器、chapter shadow / grid / move tool 的 UI 排布

## 1. 输入资源与本地可用性

本轮按用户提供的逻辑包名 + hash 逐个核对本地 `resources/assets/yoo/Default`：

### 1.1 本地实际存在

| 逻辑包名 | hash | 大小 |
|---|---|---:|
| `share_assets_art_worldmap01.bundle` | `5d4af0fe2cf4ff814d2723e4ea2aebaf` | 665,086 |
| `share_assets_art_worldmap01_images.bundle` | `16fac9e83261009b6be4e9d43ea3fa21` | 2,198,931 |
| `share_assets_art_worldmap01_texture.bundle` | `6fd3eace6063c75b24cd38b80f3a5824` | 11,535 |
| `share_assets_art_worldmap01_texture_imgeffect.bundle` | `13934445cb40ae60bc70fa551db69404` | 477,354 |
| `share_assets_art_worldmap01_texture_imgeffect_masktextures.bundle` | `d5274fb2ccd523cc877510c44a19fbad` | 2,294,072 |

### 1.2 运行时缓存补充可用

用户本轮补充导出后，已确认以下 `images` 逻辑包虽然不在 `resources/assets/yoo/Default`，但能从运行时缓存 `files/yoo/Default/BundleFiles` 或 `UnpackBundleFiles` 成功导出 64 张分块图：

| 逻辑包名 | hash | 来源 | 导出结果 |
|---|---|---|---|
| `share_assets_art_worldmap01_images.bundle` | `16fac9e83261009b6be4e9d43ea3fa21` | `UnpackBundleFiles` | `64 png` |
| `share_assets_art_worldmap03_images.bundle` | `5016b559e2a30a20755e90bcff1d303b` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap04_images.bundle` | `e75cee4031318e49f7bfae1822f0489e` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap05_images.bundle` | `a4e7c73ec6dc93d1152433847716a5ac` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap06_images.bundle` | `a98dd054e53f07be9a7165dc0fbfcb22` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap07_images.bundle` | `685d6b4ed52d9c7c38827aaa3617d6da` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap08_images.bundle` | `f6f87b89154a0e6782d945bd78dffb57` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap09_images.bundle` | `ee7978651afb4cb0e8b11a367d97370b` | `BundleFiles` | `64 png` |
| `share_assets_art_worldmap10_images.bundle` | `54fb9420538519ec1908090974f61a53` | `BundleFiles` | `64 png` |

对应输出目录在：

- [tmp/worldmap-series](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series)
- 总览表： [tmp/worldmap-series-preview-sheet.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series-preview-sheet.png)

### 1.3 当前仍缺失

以下逻辑包名虽在 manifest 字符串中出现，但对应 hash 文件当前不在本地 `resources/assets/yoo/Default`：

- `share_assets_art_worldmap02.bundle`
- `share_assets_art_worldmap02_images.bundle`
- `share_assets_art_worldmap03.bundle`
- `share_assets_art_worldmap03_images.bundle`
- `share_assets_art_worldmap04.bundle`
- `share_assets_art_worldmap04_images.bundle`
- `share_assets_art_worldmap05.bundle`
- `share_assets_art_worldmap05_images.bundle`
- `share_assets_art_worldmap06.bundle`
- `share_assets_art_worldmap06_images.bundle`
- `share_assets_art_worldmap07.bundle`
- `share_assets_art_worldmap07_fx_images.bundle`
- `share_assets_art_worldmap07_images.bundle`
- `share_assets_art_worldmap08.bundle`
- `share_assets_art_worldmap08_fx_images.bundle`
- `share_assets_art_worldmap08_images.bundle`
- `share_assets_art_worldmap09.bundle`
- `share_assets_art_worldmap09_fx_images.bundle`
- `share_assets_art_worldmap09_images.bundle`
- `share_assets_art_worldmap10.bundle`
- `share_assets_art_worldmap10_fx_images.bundle`

这意味着：

- 本轮可以做**真实结构解包**的仍然只有 `worldmap01` 家族。
- `worldmap03~10` 当前已经能确认其 `images` 分块图存在，并且都能导出为 64 张 `00_01..00_64.png`。
- `worldmap02` 目前仍是唯一明确缺口。

## 2. `worldmap01` 家族实际解包结果

### 2.1 `share_assets_art_worldmap01.bundle`

解包后主要对象类型：

- `GameObject`: 65
- `Transform`: 65
- `SpriteRenderer`: 64
- `Texture2D`: 7
- `Material`: 2
- `MonoBehaviour`: 2

关键对象名：

- `WorldMap_00`
- `WorldMap01_AutoTileset`
- `WorldMap01_AutoTileMapData`
- `WorldMap01_AutoTileset atlas material`
- `map01_buildingcut1` ~ `map01_buildingcut6`

可确认：

- 这是一个**源地图拼图场景**，不是 `ExpeditionMapView` 运行时 UI 容器。
- 根对象 `WorldMap_00` 下挂了 `64` 个命名为 `00_01`~`00_64` 的子块。
- 每个子块都是独立 `GameObject + Transform + SpriteRenderer`。

### 2.2 `share_assets_art_worldmap01_images.bundle`

解包后主要对象类型：

- `Texture2D`: 64
- `Sprite`: 64

关键特征：

- 资源名同样是 `00_01`~`00_64`
- 每块纹理尺寸统一为：`388x388`

这说明：

- `worldmap01.bundle` 里的 `64` 个 `SpriteRenderer`，正好消费 `worldmap01_images.bundle` 提供的 64 张拼图块。
- 这是一套**一一对应的源拼图**，不是运行时 `WorldMap_<x>_<y>.png` tile。

### 2.3 `share_assets_art_worldmap01_texture.bundle`

解包内容很小，但能确认它混入了若干运行时会复用的共通纹理：

- `mainui_img_17`
- `Fighting_xuetiao_04`
- `Fighting_xuetiao_05`
- `Zha009`
- `Bdd_04`

可确认：

- 这个包不是地图主体拼图。
- 更像是 `worldmap01` 场景会引用到的一小组杂项共用纹理。

### 2.4 `share_assets_art_worldmap01_texture_imgeffect.bundle`

关键对象名：

- `WorldMap01_imgeffect`
- `imgeffect_water01`
- `imgeffect_water02`
- `imgeffect_water03`
- `imgeffect_water01_mask`
- `imgeffect_water02_mask`
- `imgeffect_water03_mask`
- `imgeffect_water04_mask`
- `imgeffect02_1` ~ `imgeffect02_7`

可确认：

- `worldmap01` 源场景还包含了**地图表层动效/水面动效层**。
- 这些对象不是 `ExpeditionMapView` prefab 里的静态子节点，而是更接近世界地图底图作者态资源。

### 2.5 `share_assets_art_worldmap01_texture_imgeffect_masktextures.bundle`

关键对象名：

- `Noise10`
- `Noise43b`
- `Noise63`
- `fx_mask_01`
- `fx_mask_5`
- `fx_noise_01`
- `wenli09`

可确认：

- 这是上一层 `imgeffect` 的 mask / noise 纹理仓。
- 作用是给 `worldmap01` 场景动效提供遮罩、噪声和纹理扰动。

## 3. `worldmap01` 的原始布局如何重建

### 3.1 源拼图层级

已确认的源结构可以抽象成：

```text
WorldMap_00
  00_01
  00_02
  ...
  00_64
```

其中：

- `WorldMap_00` 是单个区域根节点
- `00_01`~`00_64` 是这一区域的 64 个拼图子块

### 3.2 子块排布

`Transform.localPosition` 已确认这些子块按固定步长摆成网格：

- X 取值：`0.00, 3.88, 7.76, 11.64, 15.52, 19.40, 23.28, 27.16`
- Y 取值：`0.00, -3.88, -7.76, -11.64, -15.52, -19.40, -23.28, -27.16`

这说明：

- `WorldMap_00` 是一个 **8x8** 源拼图面
- 每块间距统一
- 64 张 `388x388` 小图正好组成一张：
  - `3104 x 3104` 的源区域图

### 3.3 `AutoTileMapData` 与像素尺寸闭合

`WorldMap01_AutoTileset` / `WorldMap01_AutoTileMapData` 的关键字段：

- `TileWidth = 32`
- `TileHeight = 32`
- `TileMapWidth = 97`
- `TileMapHeight = 97`

因此：

- 逻辑地图尺寸 = `97 * 32 = 3104`
- 与 `8 * 388 = 3104` 完全一致

这非常关键，因为它把两条线闭合了：

1. 源美术拼图：64 张 `388x388`
2. 源 tilemap 数据：`97x97`、每格 `32x32`

所以 `share_assets_art_worldmap01*` 不是随便堆在一起的一组图，而是一份**可被 tilemap 数据驱动的源地图区域资源**。

## 4. 与 `ExpeditionMapView` 运行时 UI 的关系

### 4.1 `ExpeditionMapView` prefab 的真实容器结构

当前 `ExpeditionMapView.layout.json` 可确认：

```text
ExpeditionMapView
  imgBg
  @mapScroller
    Viewport
      Content (4096x4096)
        pnlChunk (4096x4096)
        imgMap   (4096x4096)
        Image
        Image (1)
        Image (2)
        Image (3)
  pnlRecycle
```

这说明运行时 UI 的职责是：

- 提供一个 `4096x4096` 的地图滚动舞台
- 在 `pnlChunk` / `imgMap` 上承载真正的地图块和附加层
- 叠加 chapter shadow / grid / move tool 等运行时元素

它**不是**直接把 `worldmap01.bundle` 里的 `WorldMap_00/00_01..00_64` 原样塞进 UI。

### 4.2 当前已经闭合的运行时 tile

另一条已经闭合的运行时链路是：

- `Assets/Game/RawAssets/Sprite/Expedition/WorldMap/WorldMap_<x>_<y>.png`

当前本地已成功导出并拼接的运行时 tile：

- 数量：`40`
- 单块尺寸：`1024x1024`
- 坐标范围：
  - `x = -3 .. 3`
  - `y = -4 .. 2`

已输出拼接预览：

- `reverse-output/godot-resource-export/expedition-worldmap-bulk/worldmap-mosaic.png`

这说明真正的运行时 `ExpeditionMapView` 使用的是：

- **切好的大块 tile**：`WorldMap_<x>_<y>.png`

而不是：

- 作者态源拼图：`00_01`~`00_64`

### 4.3 可以合理推导出的资源生产链

当前能站得住脚的链路应写成：

1. `share_assets_art_worldmap01*`
   - 保存源区域拼图、tilemap 数据、建筑裁片、动效和 mask
2. 美术/构建流程
   - 将源地图烘焙/切分成运行时可加载的 `WorldMap_<x>_<y>.png`
3. `ExpeditionMapView`
   - 用 `LoadSpriteFromExpeditionWorldMap(_mapSpriteStr)` 在 `4096x4096` 内容区按 chunk 加载这些 tile
4. `ExpeditionMapGrid`
   - 再把章节 landmark / icon / 文本 / 点击层叠上去

## 5. 对“原始界面布局”反查的直接启示

### 5.1 原始地图不是单张大底图

这点现在可以分成两层表达：

- 对 `ExpeditionMapView` 运行时来说：
  - 地图是 `WorldMap_<x>_<y>.png` tile 按 chunk 拼出来的
- 对源资源来说：
  - `worldmap01` 又不是天然的运行时 tile，而是更早一层的源拼图/tilemap 作者态资源

### 5.2 地图场景和 UI 容器是两套东西

- `share_assets_art_worldmap01*` 提供的是**地图内容本体**
- `ExpeditionMapView.prefab` 提供的是**地图浏览 UI 容器**

这解释了为什么：

- 只看 `ExpeditionMapView.layout.json`，会看到 `4096x4096` 的大容器，却看不到源地图拼图结构
- 只看 `worldmap01.bundle`，又会看到 64 块地图内容，却看不到 UI 的滚动、点击和章节节点逻辑

### 5.3 `worldmap01` 对应的原始区域块大小已经闭合

当前已经可以把 `worldmap01` 的源区块尺寸写死成：

- `8x8` 拼图块
- 每块 `388x388`
- 总图 `3104x3104`
- 逻辑 tilemap `97x97`
- 逻辑 tile 单元 `32x32`

这组数字后续可直接作为：

- Godot 侧做作者态预览
- 二次拼图
- 源区域和运行时 tile 对位

的硬证据。

## 6. 当前边界

- 本轮只完成了 `worldmap01` 家族的真实结构解包与源布局重建。
- `worldmap03~10` 目前已拿到 `images` 分块图和 composite，但还没有像 `worldmap01` 那样继续解到：
  - 源场景根对象
  - `AutoTileset`
  - `AutoTileMapData`
  - `imgeffect` / `masktextures`
- `worldmap02` 目前仍缺 `images` 包，因此还不能和其它系列一起并排重建。
- 当前已知运行时 `WorldMap_<x>_<y>.png` 范围只是本地可见的一圈 tile，不等于全世界地图已完全闭合。
- `map_pic_*` 章节 icon 当前仍只实锤到：
  - `map_pic_1001.png`

## 7. 与其他文档的关系

- 运行时 tile / chapter icon / `ExpeditionMapView` 逻辑调用链：
  - `docs/ui/mainui/shaonv-expeditionmap-worldmap-reverse-lookup-2026-05-27.md`
- `pnlStory`、`塵世探秘` 主入口与 `ExpeditionMainView` / `ExpeditionMapView` 的场景关系：
  - `docs/ui/mainui/shaonv-mainui-pnlfunny-pnlstory-reverse-lookup-2026-05-27.md`
- 主界面 manifest 反查与当前 Godot 落地状态：
  - `docs/ui/mainui/shaonv-mainui-manifest-reverse-lookup-2026-05-27.md`
