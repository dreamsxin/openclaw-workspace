# 单机版资源映射分析

目标：为使用原游戏资源实现单机版，整理当前已确认的资源来源、加载路径、代码入口和后续需要建立的映射表。

> 目录纠偏：本文早期引用了 `../merge/reverse-output` 中的相邻目录导出结果。后续实现必须以 `D:\work\openclaw-workspace\arpg\shaonv` 本目录重新导出的 `reverse-output` 为准。详见 `docs/analysis-scope-correction.md`。

## 输入来源

- APK 内置资源：`resources/assets/`
- YooAsset / AssetBundle：`resources/assets/yoo/Default/*.bundle`
- AssetStudio 导出清单：待从 `shaonv/resources` 重新生成，例如 `reverse-output/assets/assetstudio-cli-inventory.csv`
- AssetStudio 导出资源：
  - 待重新生成的 `reverse-output/assets/assetstudio-cli-data-sprite/`
  - 待重新生成的 `reverse-output/assets/assetstudio-cli-data-texture2d/`
  - 待重新生成的 `reverse-output/assets/assetstudio-cli-data-textasset/`
  - 待重新生成的 `reverse-output/assets/assetstudio-cli-data-json/`
- IL2CPP dump：待从 `resources/lib/arm64-v8a/libil2cpp.so` 和 `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat` 重新生成

## 使用过的命令

```powershell
Get-ChildItem -Path ..\merge\reverse-output\assets -Force | Select-Object Name,Mode,Length,LastWriteTime
```

```powershell
Import-Csv ..\merge\reverse-output\assets\assetstudio-cli-inventory.csv | Select-Object -First 10 | Format-List
```

```powershell
Import-Csv ..\merge\reverse-output\assets\assetstudio-cli-inventory.csv |
  Where-Object { $_.Type -match 'Scene|MonoBehaviour|GameObject|Prefab|TextAsset' -or $_.Name -match 'UI|Popup|Lobby|Loading|InGame|OutGame|Scene' } |
  Select-Object Type,Name,RelativePath |
  Sort-Object Type,Name |
  Select-Object -First 200 |
  Format-Table -AutoSize
```

```powershell
rg -n "class (ResourceManager|AssetBundleManager)|YooAssets|LoadAsset|LoadBundle|GetBlockIcon|GetNpcPrefab" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

## 资源加载相关类

### AssetBundleManager

`AssetBundleManager : MonoBehaviourSingleton<AssetBundleManager>`

字段：

- `bundleInfoURL`
- `downloadURL`
- `bundleInfoFile`
- `version`
- `assetBundleLoadList`
- `timeOut`
- `testMode`

方法：

- `SetTestMode()`
- `LoadAssetBundle(Action finish)`
- `ParseBundleInfo(string bundleInfo, Action finish)`
- `LoadBundleInfo(Action<string> callback)`
- `LoadBundleFile(string bundleName, int bundleVersion, uint crc, string hash, Action<AssetBundle> finish)`
- `LoadBundle(AssetBundle bundle)`
- `UnLoadAssetBundle()`

结论：

- 游戏有自定义 AssetBundle 下载/解析流程。
- `bundleInfoURL`、`downloadURL`、`bundleInfoFile` 暗示曾支持远程热更或资源清单。
- 单机版可以跳过远程下载，直接使用本地导出的 bundle 或转换后的资源。

### ResourceManager

`ResourceManager : MonoBehaviourSingleton<ResourceManager>`

字段显示它是运行期资源索引中心：

- `rewardTypeResList`
- `eventCoinIconTypeResList`
- `blockCategoryResList`
- `BoxTypeResList`
- `EventContentList`
- `mateRes`
- `dormitoryRes`
- `MaidSkillResList`
- `MaidMiniResList`
- `CardPackTicketResList`
- `m_skeletonDictionary`
- `m_skeletonUseInstanceID`
- `mainPointIcon`
- `treasureSandResList`

关键方法：

- `GetBlockIcon(string imageName)`
- `GetBlockIcon(BlockTableData blockData)`
- `GetBlockIcon(int blockID)`
- `GetUIIcon(string name)`
- `GetRewardIcon(RewardType rewardType, int id, int iconType = 0)`
- `GetRewardName(RewardType rewardType, int id, int amount, bool isAddAmount = True)`
- `GetItemIcon(ItemType itemType, int id)`
- `GetCategoryIcon(string name)`
- `GetPhotoCardImage(string imagePath)`
- `GetPhotoCardObject(string name)`
- `GetNpcPrefab_SD(int npcID, int skinID = -1)`
- `GetNpcPrefab_SD_OutGame(int npcID, int skinID = -1)`
- `GetNpcPrefab_LD(int npcID, int skinID = -1)`
- `GetMaidProfile(int maidID)`
- `GetMaidMiniProfile(int maidID)`
- `GetNpcName(int charID, int skinID = 0, bool isFullName = False)`
- `GetStoryItemImage(string storyItemName)`
- `GetFurnitureIcon(string name)`
- `GetMissionPassIcon(MissionQuestType questType)`
- `GetEventIcon(EventTypeID eventType)`

结论：

- 单机版应优先复刻一个轻量 `ResourceManager`，提供同名或等价查询接口。
- 表数据中的 `BlockImage`、角色 ID、奖励类型、道具类型都需要映射到 Sprite / Prefab / Spine / Audio。

## 当前已识别的资源类别

### UI 与弹窗

资源清单中出现：

- `Popup_Window`
- `Popup_Window2`
- `Popup_Window3`
- `Popup_Window4`
- `Popup_WindowNoTilte`
- `Popup_Back`
- `Popup_X`
- `Window_PopupInside`
- `ui_btn_white_256`
- `ui_headerFrame256`
- `ui_icon_warningExclamation`
- `ui_icon_warningTriangle`
- `UICheckMark`
- `UINote`
- `UISprite`

用途推断：

- 通用弹窗背景、关闭按钮、警告图标、按钮底图。

### Loading

资源清单中出现：

- `Image_Loading`
- `Loading_maid_2`
- `LoadingIcon64`
- `Album_01_Kokomi_Loading`
- `Album_02_Aku_Loading`
- `Album_03_Yuki_Loading`
- `Album_04_Kaede_Loading`
- `Album_05_Akane_Loading`
- `Album_06_Kurone_Loading`
- `Album_07_Aiko_Loading`

对应代码：

- `UILoading`
- `UISceneLoading`
- `GameLoadingInfo`
- `MaidSceneLoadingTableData`

单机版建议：

- 先实现固定 Loading 图和进度条。
- 后续再根据 `GameLoadingInfo`、角色或章节切换 Loading 图。

### 大厅与游戏内

资源清单中出现：

- `InLobby`
- `OutLobby`
- `BG_Ingame_0003`
- `BG_Ingame_0004`
- `BG_Ingame_mid`
- `BG_Ingame_Night`
- `BG_Ingame_2026SchoolEvent`
- `InGameSkin_Board_*`
- `InGameSkin_DeskA_*`
- `InGameSkin_DeskB_*`
- `IngameSkin_BGIcon_*`

对应代码：

- `UIOutGame`
- `UILobby`
- `UIInGame`
- `UIInGameBG`
- `UserInGameResourceData`
- `InGameResTableData`

单机版建议：

- 最小版本只需要一个大厅背景和一套棋盘/桌面皮肤。
- 后续再按 `UserInGameResourceData.CurrentBGID / CurrentBoardID / CurrentDeskID` 做皮肤切换。

### 方块与道具

表字段：

- `BlockTableData.BlockImage`
- `BlockTableData.IsSpineBlock`
- `BlockTableData.BlockType`
- `BlockTableData.GroupName`
- `BlockTableData.Level`

对应代码：

- `ResourceManager.GetBlockIcon(...)`
- `InGame_ItemBlock`
- `InGame_BlockManager`

单机版建议：

- 建立 `block_id -> block_table -> image_name -> sprite_path` 映射。
- 对 `IsSpineBlock=true` 的方块单独标记，先用静态图替代，后续再接 Spine。

### 角色、女仆、Spine

资源和代码线索：

- `ResourceManager.GetMateSkeletonDataAsset(int npcId, int skinId = 0)`
- `ResourceManager.GetNpcPrefab_SD(...)`
- `ResourceManager.GetNpcPrefab_SD_OutGame(...)`
- `ResourceManager.GetNpcPrefab_LD(...)`
- `ResourceManager.GetMaidProfile(...)`
- `ResourceManager.GetMaidMiniProfile(...)`
- `m_skeletonDictionary`

单机版建议：

- 建立 `npc_id -> profile sprite -> mini sprite -> LD prefab -> SD prefab -> spine asset` 映射。
- 最小版本只需要头像和大厅立绘，不必立即实现全 Spine 动画。

### 剧情与相册

资源清单中出现：

- `MainRoom*_Scene`
- `*Room*Popup*`
- `Story*`
- `Album*`
- `PhotoCard*`

对应代码：

- `UIPopup_Story`
- `UI_CutsceneController`
- `UI_CutsceneDialog`
- `UIPopup_AlbumDetail`
- `UIPopup_PhotoCardDetail`
- `StoryDataManager`
- `StoryTableDataManager`

单机版建议：

- 剧情可以先做静态对话框：背景 + 角色立绘 + 文本。
- 演出动画、Spine、Timeline 后置。

### 活动资源

资源清单中出现：

- `2025SummerPopup_*`
- `2025XmasPopup_*`
- `202508BandPopUp_*`
- `20260301EventPopup_*`
- `EventPopup_*`

对应代码：

- 大量 `UIPopup_Event*`
- `EventManager`
- `EventConfigManager`

单机版建议：

- 第一版不建议实现活动系统。
- 可以保留活动资源清单，后续作为章节或静态收藏内容开放。

## 单机版资源映射表建议

建议创建以下中间表，供新工程加载：

### block_resources.json

```json
{
  "blockId": 1001,
  "imageName": "xxx",
  "spritePath": "Sprite/xxx.png",
  "isSpine": false,
  "spinePath": null
}
```

### npc_resources.json

```json
{
  "npcId": 1,
  "nameKey": "NpcName_001",
  "profileSprite": "Sprite/...",
  "miniSprite": "Sprite/...",
  "ldPrefab": "Prefab/...",
  "sdPrefab": "Prefab/...",
  "spine": "TextAsset/..."
}
```

### ui_resources.json

```json
{
  "uiClass": "UIPopup_Inventory",
  "prefabName": "UIPopup_Inventory",
  "bundle": null,
  "sprites": []
}
```

### story_resources.json

```json
{
  "storyId": 1001,
  "background": "Sprite/...",
  "characters": [],
  "dialogTable": "..."
}
```

## 待补充分析

- 解析 YooAsset 清单，确认 Address / AssetPath / BundleName。
- 从 AssetRipper 或 MonoBehaviour dump 中反查 prefab 上挂载的脚本类。
- 建立 `UIPopup_* -> prefab -> sprite list` 的自动化索引。
- 建立 `BlockTableData.BlockImage -> Sprite 文件` 的自动化校验。
- 建立 `NpcTableData -> 角色资源` 映射。
- 检查 Spine `.atlas` / `.skel` / `.json` / texture 是否齐全。
