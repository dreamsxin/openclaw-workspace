# ExpeditionMap WorldMap 图源反查记录

生成时间：2026-05-27。

本文记录 `ExpeditionMapView` 真实地图图源的当前反查状态，重点回答两件事：

1. `AssetsHelper.LoadSpriteFromExpeditionWorldMap(...)` 实际加载什么资源  
2. `AssetsHelper.LoadSpriteFromExpeditionWorldMapIcon(...)` 当前本地资源集里到底能闭合到哪些 `map_pic_*.png`

## 结论摘要

- `ExpeditionMapView` 的真实地图底图不是单张大图，而是按 tile 分块加载。
- 当前已确认的 tile 命名规则为：
  - `Assets/Game/RawAssets/Sprite/Expedition/WorldMap/WorldMap_<x>_<y>.png`
- `ExpeditionMapGrid` / `ExpeditionMapView` 的章节节点图标使用独立图源。
- 当前本地 manifest + physical 资源集中，**只确认到一张真实章节 icon：**
  - `Assets/Game/RawAssets/Sprite/Expedition/WorldMapIcon/map_pic_1001.png`
- `map_pic_1002.png` 及之后的文件，**目前没有在本地资源集中反查到真实物理文件**。若 Godot 侧存在同名图片，它们只是为了让路径规则和占位显示稳定而复制生成的占位资源，不能当作真实图源证据。

## 1. 直接证据

### 1.1 Loader 方法存在

在类型/方法索引里已确认：

- `AssetsHelper.LoadSpriteFromExpeditionWorldMap(System.String)`
- `AssetsHelper.LoadSpriteFromExpeditionWorldMapIcon(System.String)`

可见位置：

- `reverse-output/managed/Assembly-CSharp-index/ui-methods.csv`
- `reverse-output/managed/Assembly-CSharp-index/methods.csv`

这说明：

- 地图块 key 是字符串驱动，不是写死在 prefab 的 `Image.sprite`
- 节点 icon key 同样是字符串驱动

### 1.1.1 已拿到的真实方法体结论

本轮已直接从 `reverse-output/managed/hotfix-dlls/Assembly-CSharp.dll` 提取到以下状态机方法体：

- `AssetsHelper/<LoadSpriteFromExpeditionWorldMapIcon>d__111::MoveNext`
- `ExpeditionMapGrid/<Init>d__10::MoveNext`
- `ExpeditionMapView/<GenerateMap>d__47::MoveNext`

这些方法体把此前的“推断”推进成了可验证的事实。

#### `LoadSpriteFromExpeditionWorldMapIcon`

真实 IL 关键片段：

```text
ldstr        Expedition/WorldMapIcon
ldfld        ...::fileName
call         AssetsHelper::LoadSprite(System.String,System.String,UIControl)
```

可确认：

- 该方法不是自己拼完整 assetPath。
- 它把固定目录 `"Expedition/WorldMapIcon"` 和传入的 `fileName` 交给通用 `AssetsHelper.LoadSprite(...)`。

所以 icon 规则已经可以确认到：

- 目录：`Expedition/WorldMapIcon`
- 文件名：由上层逻辑传入

#### `ExpeditionMapGrid.Init`

真实 IL 关键片段：

```text
set_CfgChapterId(cfgChapterId)
ConquerChapterStatic.GetItem(cfgChapterId.ToString())
RectTransform.anchoredPosition = (mapX.ToFloat(), mapY.ToFloat())
txtName.text = Lang.Get(mapName)
ExpeditionMapView.Instance.GetChapterState(cfgChapterId)
btnClick.interactable = chapterState
```

可确认：

- `cfgChapterId` 直接对应 `ConquerChapterStaticItem.id`
- 节点位置直接取 `ConquerChapterStaticItem.mapX` / `mapY`
- 节点标题直接取 `ConquerChapterStaticItem.mapName`
- 节点可点击状态取决于 `ExpeditionMapView.GetChapterState(cfgChapterId)`
- 节点点击行为本体不在这里；`ExpeditionMapGrid.OnBtnClickClick()` 会打开：
  - `Prefabs/UI/Expedition/ExpeditionChapterMapDetailView`

这说明章节节点布局不是静态写在 prefab 里，而是完全由 `ConquerChapterStaticItem` 驱动。

#### `ExpeditionChapterMapDetailView.Init`

继续向上追调用者后，本轮又拿到：

- `ExpeditionChapterMapDetailView/<Init>d__10::MoveNext`

真实 IL 关键片段：

```text
txtTitle = Lang.Get(cfgChapter.mapName)
imgCover.sprite = LoadSpriteFromExpeditionWorldMapIcon(cfgChapter.mapPic)
txtDetail = Lang.Get(cfgChapter.mapDec)
```

可确认：

- `LoadSpriteFromExpeditionWorldMapIcon(...)` 的 `fileName` 参数不是来自 `CfgChapterId` 直接字符串拼接。
- 它来自：
  - `ConquerChapterStaticItem.mapPic`

这非常关键，因为它把之前的高置信推断修正成更精确的事实：

- `map_pic_<chapterId>` 只是当前最自然的资源命名猜测
- 但真实调用侧已经明确：**icon key 来源字段是 `ConquerChapterStaticItem.mapPic`**
- 若后续要完全闭合真实 icon 规则，应优先导出 / 解开 `ConquerChapterStaticItem.mapPic` 的实际值

#### `ExpeditionMapView.GenerateMap`

真实 IL 关键片段：

```text
ExpeditionModel.GetCurStageId()
ExpeditionStatic.GetItem(curStageId.ToString())
ConquerChapterStatic.GetItem(chapterId.ToString())
ConquerChapterStatic.GetItems()
GetChunk(new Vector2(chunkX * ExpeditionMapChunk.Size, chunkY * ExpeditionMapChunk.Size))
ChapterStateDict[chapterId] = !(chapterId > curChapterId)
TryParse(mapX/mapY)
GetChunk(mapPos).AddLandmarkId(chapterId)
pnlChunk.anchoredPosition = ...
imgMap.rectTransform.anchoredPosition = ...
InitMoveTool(curChapter.mapMove, curChapter(mapX,mapY)+_standPosOffset, "standby")
ScrollToObject(mapScroller, spineMoveToolRect, _zoomInScale, ...)
```

可确认：

- 当前关卡先映射到 `ExpeditionStaticItem.chapterId`
- 再用 `chapterId` 取 `ConquerChapterStaticItem`
- `ChapterStateDict` 的计算规则是：
  - `chapterId <= 当前章节Id` => 可用 / 已解锁
  - `chapterId > 当前章节Id` => 未解锁
- 每个章节节点最终会被加到某个 `ExpeditionMapChunk` 上
- 当前角色/移动工具初始化依赖：
  - `ConquerChapterStaticItem.mapMove`
  - 当前章节 `mapX/mapY`
  - 动画名 `"standby"`
- 当前章节详情入口与区域切换并不是简单跳章，而是：
  - 先 `GenerateMap()`
  - 再在 `OnOpen()` 里根据参数决定是否 `MoveToNewArea(cfgChapter, callback)`

这说明：

- `ExpeditionMapView` 的真实地图是 “chunk + landmark” 驱动，而不是简单地把若干按钮摆上去
- 节点 icon / move tool / 当前聚焦区域都由章节静态表和运行时当前章节共同决定

#### `ExpeditionMapChunk.Show`

继续向底层追后，本轮又拿到：

- `ExpeditionMapChunk::Show(ExpeditionMapChunkObj)`

真实 IL 关键片段：

```text
obj.root.name = string.Format("ExpeditionMapChunk{0}{1}", X, Y)
obj.root.anchoredPosition = new Vector2(X * ExpeditionMapChunk.Size, Y * ExpeditionMapChunk.Size)
obj.imgMap <- LoadSpriteFromExpeditionWorldMap(_mapSpriteStr)
```

可确认：

- 地图底图 tile 不是由 `GenerateMap()` 直接拼 assetPath，而是由每个 `ExpeditionMapChunk` 自己持有：
  - `_mapSpriteStr`
- `LoadSpriteFromExpeditionWorldMap(...)` 的 `fileName` 参数就是 `_mapSpriteStr`
- 当前还没完全闭合的是：
  - `ExpeditionMapChunk::.ctor(System.String, Int32, Int32)` 里 `_mapSpriteStr` 是如何生成的

但至少已经能把调用链补全为：

- `ExpeditionMapView.GenerateMap()`
- `GetChunk(...)`
- `ExpeditionMapChunk.Show(...)`
- `LoadSpriteFromExpeditionWorldMap(_mapSpriteStr)`

### 1.2 地图块地址已在 manifest 中暴露

`manifest-assets.csv` / `manifest-parsed-assets.csv` 中直接存在：

- `Assets/Game/RawAssets/Sprite/Expedition/WorldMap/WorldMap_0_0.png`
- `WorldMap_0_1.png`
- `WorldMap_0_2.png`
- `WorldMap_0_-2.png`
- `WorldMap_1_0.png`
- `WorldMap_-2_-4.png`
- `WorldMap_3_2.png`

以及更多同类地址。

这说明地图底图的命名规则已经闭合到：

`WorldMap_<x>_<y>.png`

而不是此前猜测的单张背景图。

### 1.3 章节 icon 当前只闭合到 `map_pic_1001`

当前本地 manifest / physical 资源集中，仅找到：

- `Assets/Game/RawAssets/Sprite/Expedition/WorldMapIcon/map_pic_1001.png`

对应行可见于：

- `reverse-output/assets/manifest/manifest-assets.csv`
- `reverse-output/assets/manifest-parsed-py/manifest-parsed-assets.csv`
- `reverse-output/assets/yoo-physical-map/physical-asset-map.csv`

没有发现 `map_pic_1002.png`、`map_pic_1003.png` 等更多 `WorldMapIcon` 资源行。

## 2. 与 `ExpeditionMapView` / `ExpeditionMapGrid` 的关系

### 2.1 `ExpeditionMapView`

已确认：

- `ExpeditionMapView.MoveToNewArea(ConquerChapterStaticItem, Action)`
- `ExpeditionMapView.GenerateMap()`
- `ExpeditionMapView.GenerateShadow()`
- `ExpeditionMapView.InitMoveTool(System.String, Vector2, System.String)`

这说明地图视图是围绕 `ConquerChapterStaticItem` 驱动的，而不是简单的静态 UI 容器。

### 2.2 `ExpeditionMapGrid`

已确认：

- `ExpeditionMapGrid.CfgChapterId`
- `ExpeditionMapGrid.Init(System.Int32)`

同时 prefab 清单显示：

- `ExpeditionMapGrid` 自身有章节牌底图 `expedition_img_22`
- `txtName` 文本示例为 `"霍德尔学院"`
- `btnClick` 是透明点击层

此前对 icon 规则最自然的猜测是：

- `map_pic_<CfgChapterId>.png`

但本轮方法体分析后，应该把它修正成更准确的表达：

- `CfgChapterId` 决定节点数据与点击目标
- **真实 icon key 来源字段是 `ConquerChapterStaticItem.mapPic`**
- 若 `mapPic` 的值恰好长成 `map_pic_1001` 这类形式，那么才会落到 `map_pic_<chapterId>.png`

因此当前状态是：

- `map_pic_<chapterId>` 不再是“首要规则”
- `mapPic` 才是首要规则
- 只是当前本地真实资源集只闭合到一张 `map_pic_1001.png`

## 3. 当前边界

### 已证实

- 真实地图底图 tile 规则：`WorldMap_<x>_<y>.png`
- `WorldMap` tile 物理资源本地大范围存在，可批量导出
- `WorldMapIcon` 至少存在 `map_pic_1001.png`
- `ExpeditionMapView` 的章节区域由 `ConquerChapterStaticItem` 驱动
- `ConquerChapterStaticItem.mapX/mapY/mapName/mapMove` 在地图生成流程里被直接读取
- `ExpeditionMapGrid.Init(cfgChapterId)` 直接用 `cfgChapterId` 取 `ConquerChapterStaticItem`
- `LoadSpriteFromExpeditionWorldMapIcon` 固定目录就是 `Expedition/WorldMapIcon`
- `ExpeditionChapterMapDetailView.Init` 直接用 `cfgChapter.mapPic` 作为 icon fileName
- `ExpeditionMapChunk.Show` 直接用 `_mapSpriteStr` 作为 world map tile fileName

### 未证实

- `map_pic_1002+` 是否存在于未下载资源、运行时缓存或其它资源包
- `ConquerChapterStaticItem.mapPic` 的真实值全集
- `ExpeditionMapChunk::.ctor(System.String, Int32, Int32)` 如何生成 `_mapSpriteStr`

### 需要特别标注

当前 Godot 项目中若存在：

- `map_pic_1002.png`
- `map_pic_1003.png`
- `map_pic_1004.png`
- `map_pic_1005.png`
- `map_pic_1006.png`

它们只是基于 `map_pic_1001.png` 复制出来的**临时占位资源**，用于让路径和节点逻辑稳定，不属于真实反查结果。

## 4. 对恢复工作的直接启示

- `ExpeditionMapView` 应优先使用真实 `WorldMap_<x>_<y>.png` tile 拼接地图底图。
- 章节节点图标的路径规则可以先按 `map_pic_<chapterId>.png` 预留。
- 但只有 `map_pic_1001.png` 可以标为真实落地资源，其余章节 icon 目前必须继续标为占位 / 未闭合。
- Godot 侧恢复节点时，应把单个章节节点按 `ExpeditionMapGrid` 的 prefab 语义来建：
  - 根尺寸 `168x180`
  - 透明 `btnClick` 覆盖整格
  - `btnClick/Image/txtName` 使用 `expedition_img_22`
  - `imgIcon` 是章节图标层，真实资源来源仍以 `mapPic` 为准
- 点击链不应直接跳到 `ChapterTaskView`。更贴近原始逻辑的顺序是：
  - `ExpeditionMapGrid.OnBtnClickClick()`
  - 打开 `Prefabs/UI/Expedition/ExpeditionChapterMapDetailView`
  - `ExpeditionChapterMapDetailView.Init` 写入 `txtTitle / imgCover / txtDetail`
  - 详情中的继续按钮再进入章节任务或挑战流程
- 当前本地还没有 `ExpeditionChapterMapDetailView` 的 layout JSON；manifest 已确认 prefab 存在，后续可用 `scripts/assets/export_prefab_full_inventory.py` 为该 prefab 补一份单 prefab 清单。
- 后续若要补齐真实章节 icon，优先方向不是继续盲扫 manifest，而是：
  - 深挖 `WorldMap.dll` / `ConquerChapterStaticItem`
  - 查运行时缓存 / 远端热更资源

## 4.1 Godot MVP 恢复经验

本轮 `standalone/godot-mvp/scripts/screens/expedition_screen.gd` 的恢复策略：

- `@mapScroller/Viewport/Content` 维持 `4096x4096` 内容尺寸，`pnlChunk/imgMap/pnlShadow/pnlGrid/pnlMoveTool` 按 prefab 层级拆开。
- `pnlGrid` 的节点函数命名为 `ExpeditionMapGrid` 语义，节点点击先打开地图详情，不再直接进入 `ChapterTaskView`。
- 地图详情按已证实 IL 字段恢复：标题取章节名，封面取 `mapPic` 规则下的 `WorldMapIcon`，说明取 `mapDec` 风格文本；由于当前静态表还未全量稳定导出，Godot 侧先把这些值折叠进节点字典。
- `ChapterTaskView` 继续作为 expedition 内部子入口保留，详情面板上的“章节任务”按钮接回 `app._show_chapter_panel()`。
- 资源边界必须写在代码附近或文档中：`map_pic_1002+` 目前只是占位图，不能在恢复结论中当作真实资源。

## 4.2 2026-05-27 落地补充

本轮继续细化后，Godot MVP 已经把前面反查到的结论真正落到了运行链路里：

- `standalone/godot-mvp/assets/ui/expedition/worldmap` 下的 `WorldMap_*.png` 已被 `ExpeditionMapView` 实际消费，不再只是“已导出待使用”的静态资源。
- 地图节点点击链已从“直接进章节任务”调整为更贴近原始逻辑的：
  - `ExpeditionMapGrid`
  - `ExpeditionChapterMapDetailView`
  - `ChapterTaskView`
- `ExpeditionChapterMapDetailView` 在 Godot 侧先按“可证实字段优先”恢复：
  - 标题：章节显示名
  - 封面：`map_pic_<chapterId>.png` 规则下可命中的本地图标
  - 说明：当前章节状态、进度、资源真实性说明

这次实现里还有一个非常重要的经验，需要单独记下：

- **主线 adventure 章节 ID 与 WorldMap 章节 ID 不是同一套编号。**
  - `adventure_mvp.json` 当前主线章节是 `1..N`
  - 世界地图节点 / 图标规则对应的是 `1001..` 这套 `ConquerChapterStaticItem.id`
- 因此 Godot 恢复时必须显式保留一层“`chapter_index -> WorldMap chapterId`”映射，不能把：
  - 主线章节 `id=1`
  - 世界地图图标 `map_pic_1001.png`
  误当成同一个 ID 体系直接拼接。

当前 Godot MVP 的处理原则是：

- 地图位置、节点视觉、图标路径按 `WorldMap chapterId` 驱动。
- 章节任务、奖励预览、推进状态按主线 adventure `chapter_index` / `chapter` 数据驱动。
- 对于 `1007+` 这类本地还没有对应 adventure 章节数据的节点，先保留地图点位与“待实装”状态，不伪造任务数据。

这也带出一个后续恢复上的稳妥顺序：

1. 先保证 `WorldMap` tile、节点位置、详情入口正确。
2. 再逐步补齐 `ConquerChapterStaticItem.mapPic / mapDec / mapMove` 等字段闭环。
3. 最后再把 `1007+` 之后的区域与真实章节数据、远端资源或热更表完全对上。

## 4.3 2026-05-27 运行核对补记

本轮又补做了一次运行级核对，先把结论记录下来，避免后续会话中断丢失：

- 已实际使用本地 Godot 项目启动并截图验证：
  - `SHAONV_MVP_START_VIEW=chapter`
  - `SHAONV_MVP_CAPTURE=.../tmp/shaonv-expedition-capture.png`
- 当前这条入口链先落到的是 **`ExpeditionMainView`**，不是 `ExpeditionMapView`。
- 因此用户反馈的“塵世探秘界面没有显示地图和角色移动”，要拆成两层问题看：
  1. `ExpeditionMainView` 主场景本身没有被正确恢复
  2. `ExpeditionMapView` 的 `WorldMap_*.png` / move tool 虽然已经接进代码，但并不会在 `ExpeditionMainView` 首屏直接出现

这次运行截图还确认了一个很关键的误差来源：

- 当前 Godot `ExpeditionMainView` 使用的 `expedition_bg_02.png` 实际是一张白底面板资源。
- 它不符合原始 `screenshot/塵世探秘界面.jpg` 那种“场景地图 + 角色驻扎 + 右下功能组”的主场景形态。
- 所以当前首屏出现的大面积白块，不是 `WorldMap_*.png` 丢失，而是 **主界面背景资源/场景层选错**。

这条核对结果直接修正了恢复优先级：

1. 先修 `ExpeditionMainView` 主场景，让首屏具备可见的地图/场景预览与驻扎角色标记。
2. 再继续精修 `ExpeditionMapView` 的滚动地图、节点和 move tool。
3. 不再把 `expedition_bg_02.png` 误当成塵世探秘主场景的大背景。

## 4.4 2026-05-27 源分包补记

本轮又把用户提供的 `share_assets_art_worldmap01*` 逻辑分包实际解开了一次，得到两个对后续恢复很重要的补充：

- `share_assets_art_worldmap01.bundle` 不是 `ExpeditionMapView` 直接消费的 UI 包，而是**地图源场景包**：
  - 根节点：`WorldMap_00`
  - 子块：`00_01` ~ `00_64`
  - 64 个 `SpriteRenderer` 按 `8x8` 网格摆放
- `share_assets_art_worldmap01_images.bundle` 为这 64 个子块提供同名 sprite：
  - 每块尺寸：`388x388`
  - 总拼图尺寸：`8 * 388 = 3104`
- 同包里的 `WorldMap01_AutoTileMapData` 又明确给出：
  - `TileMapWidth = 97`
  - `TileMapHeight = 97`
  - `TileWidth = 32`
  - `TileHeight = 32`
  - 即逻辑地图总尺寸同样是：`97 * 32 = 3104`

这说明可以把链路再往前补一层：

1. `share_assets_art_worldmap01*`
   - 保存作者态源拼图、tilemap 数据、建筑裁片和水面特效
2. 构建流程
   - 再把它们切成运行时 `WorldMap_<x>_<y>.png`
3. `ExpeditionMapView`
   - 在 `4096x4096` 内容区按 chunk 加载运行时 tile

也就是说：

- `WorldMap_<x>_<y>.png` 是**运行时切块结果**
- `share_assets_art_worldmap01*` 是**更上游的原始地图区域资源**

完整补记见：

- [shaonv-expeditionmap-worldmap-source-bundle-layout-reconstruction-2026-05-27.md](D:/work/openclaw-workspace/arpg/shaonv/docs/ui/mainui/shaonv-expeditionmap-worldmap-source-bundle-layout-reconstruction-2026-05-27.md)

## 5. 本轮导出结果

### 已导出的真实 WorldMap tile

已导出一整圈可用于当前可视区的 `WorldMap` 图块到：

- [standalone/godot-mvp/assets/ui/expedition/worldmap](D:/work/openclaw-workspace/arpg/shaonv/standalone/godot-mvp/assets/ui/expedition/worldmap)

### 已导出的真实 WorldMap icon

- `map_pic_1001.png`

### 占位 icon

以下文件名当前仅用于占位，不是 manifest / physical 已证实资源：

- `map_pic_1002.png`
- `map_pic_1003.png`
- `map_pic_1004.png`
- `map_pic_1005.png`
- `map_pic_1006.png`

## 5.1 2026-05-27 `worldmap-series` 批量导出补记

用户本轮继续从运行时缓存补做了一次 `share_assets_art_worldmap0X_images.bundle` 批量导出，结果需要覆盖掉本轮前半段“只有 worldmap01 可见”的旧边界。

当前已确认成功导出的源分块图系列：

- `worldmap01`
- `worldmap03`
- `worldmap04`
- `worldmap05`
- `worldmap06`
- `worldmap07`
- `worldmap08`
- `worldmap09`
- `worldmap10`

每个系列当前都满足：

- `64` 张分块图
- 文件名完整覆盖 `00_01.png` ~ `00_64.png`
- 已生成一张 composite
- 已生成一张单系列 preview

当前仍缺：

- `worldmap02`
  - `share_assets_art_worldmap02_images.bundle`
  - hash：`940be9d0d8ff8141f364a45f2c31b71e`

相关产物路径：

- 总目录：
  - [tmp/worldmap-series](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series)
- 总预览表：
  - [tmp/worldmap-series-preview-sheet.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series-preview-sheet.png)
- 系列 composite：
  - [worldmap01-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap01-composite.png)
  - [worldmap03-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap03-composite.png)
  - [worldmap04-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap04-composite.png)
  - [worldmap05-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap05-composite.png)
  - [worldmap06-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap06-composite.png)
  - [worldmap07-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap07-composite.png)
  - [worldmap08-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap08-composite.png)
  - [worldmap09-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap09-composite.png)
  - [worldmap10-composite.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/worldmap-series/worldmap10-composite.png)

这次补记带来的直接修正是：

- `worldmap03~10` 的源拼图图层已经具备继续做“原始大地图拼接 / 区域并排比较 / 与运行时 tile 对位”的前提。
- 但除 `worldmap01` 外，其它系列当前还只是拿到了 `images` 层；尚未补齐对应的：
  - 主包
  - `AutoTileMapData`
  - `imgeffect`
  - `masktextures`

## 5.2 2026-05-27 `ExpeditionMainView` 首屏落地核对

本轮又补做了一次非常重要的运行级核对：不再只停留在“`ExpeditionMainView` 应该比 `ChapterTaskView` 更像首屏”的判断，而是把它真正按 `WorldMap` 证据修回 Godot 首屏。

### 当前证据组合

- 原始截图：
  - `screenshot/塵世探秘界面.jpg`
- 主场景底图：
  - `standalone/godot-mvp/assets/ui/expedition/afkmap/worldmap04_main_view.png`
- prefab 布局：
  - `reverse-output/godot-layout-inspect/ExpeditionMainView.layout.json`

### 已落地修正

- `ExpeditionMainView` 首屏底图改回 `worldmap04_main_view`
- `imgMap/btnMap` 恢复为右上角 `160x160` 小地图入口块
- `btnCrossReward` 恢复为左上角跨关奖励条
- `btnFight / btnDispatch / btnHero / btnMarch / btnStronger / btnReward` 按 prefab 真实锚点重排
- 中部驻扎角色从圆头像占位改为 baked Spine 本体

### AFKMap 进一步补证

本轮继续下探 AFKMap prefab 后，又拿到：

- `PlayerTileMovement.prefab`
  - `Shadow / Sprite / Weapon`
- `Player.prefab`
  - `Shadow / Spine / Sprite / Weapon`
- `Tip_EnterVehicle.prefab`
  - 独立 `TextMesh` 提示体

这说明“驻扎角色/载具提示”这一层并不是后加 UI，而是 AFKMap 场景单位系统的一部分。

Godot 侧本轮已据此把首屏角色进一步切换为更像场景单位的 `hero_022h` 变体，并移除明显假的伪载具占位块。

### 运行截图

- 修正前：
  - [shaonv-expedition-capture-mainview-v4.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/shaonv-expedition-capture-mainview-v4.png)
- 修正后：
  - [shaonv-expedition-capture-mainview-v6.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/shaonv-expedition-capture-mainview-v6.png)
- 继续推进后：
  - [shaonv-expedition-capture-mainview-v7.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/shaonv-expedition-capture-mainview-v7.png)

### 这次核对带来的结论修正

- `ExpeditionMainView` 首屏已经不应再被描述成“白底面板 / 简化平台 / 错景占位”。
- 当前更准确的状态应表述为：
  - **主场景底图、按钮锚点和地图入口语义已基本回到真实证据链**
  - **驻扎角色已切换为 AFKMap 风格场景单位，但尚未闭合到原截图里的完整骑乘/载具表现**

因此后续优先级也应调整为：

1. 深挖 `worldmap04` 主包与场景附加层
2. 深挖 `PlayerTileMovement.prefab` / `Player.prefab` / `Tip_EnterVehicle.prefab`
3. 补驻扎载具/坐骑层
4. 再继续精修 `ExpeditionMapView` 与章节节点联动
