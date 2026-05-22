# 单机版移植多任务计划

目标：使用 `D:\work\openclaw-workspace\arpg\shaonv` 目录内的原游戏资源和反编译结果，实现一版可离线运行的单机版游戏。本文拆分后续分析与实现任务，明确每条任务线的产出。

## 目录纠偏

此前部分分析引用了相邻目录 `../merge/reverse-output` 中的已导出产物。该目录只能作为参考，不能作为 `shaonv` 项目的最终依据。

`shaonv` 本目录当前确认拥有原始输入：

- `resources/AndroidManifest.xml`
- `resources/lib/arm64-v8a/libil2cpp.so`
- `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`
- `resources/assets/bin/Data/level0`
- `resources/assets/bin/Data/sharedassets0.assets`
- `resources/assets/asd/YooAsset`
- `resources/assets/yoo/Default/*.bundle`

后续 P0 必须先从这些文件重新导出 `shaonv/reverse-output`，再更新资源映射、表数据和玩法规则。纠偏详情见 `docs/analysis-scope-correction.md`。

## 当前已完成文档

- `docs/game-ui-startup-analysis.md`：游戏界面、启动顺序、UI 分类。
- `docs/game-ui-analysis-process.md`：分析过程、命令、工具和推断依据。
- `docs/resource-mapping-analysis.md`：资源加载、资源类别、资源映射方案。
- `docs/table-data-analysis.md`：配置表体系、MVP 必需表、关键字段。
- `docs/core-gameplay-loop-analysis.md`：合成、生产、订单、存档核心循环。

## 任务线 A：资源映射

目标：把资源从“文件清单”变成“单机版可加载的资源索引”。

优先级：P0

输入：

- `resources/assets/yoo/Default/*.bundle`
- `resources/assets/asd/YooAsset`
- `resources/assets/bin/Data/*`
- 待重新生成的 `reverse-output/assets/assetstudio-cli-inventory.csv`
- 待重新生成的 `reverse-output/assets/assetstudio-cli-data-*`
- `ResourceManager` 方法签名

产出：

- `derived/block_resources.json`
- `derived/npc_resources.json`
- `derived/ui_resources.json`
- `derived/story_resources.json`

待做：

1. 提取 `BlockTableData.BlockImage` 列表。
2. 在 AssetStudio Sprite / Texture2D 清单中匹配同名资源。
3. 建立 `blockId -> imageName -> spritePath`。
4. 提取 `NpcTableData` 字段，建立 `npcId -> 头像/立绘/Spine`。
5. 反查 `UIPopup_*` 和 prefab / MonoBehaviour 的绑定关系。
6. 检查 Spine 资源是否成套：`.atlas`、`.skel` 或 `.json`、贴图。

建议命令方向：

```powershell
Import-Csv ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis\table-data-fields.csv |
  Where-Object { $_.Class -eq 'BlockTableData' }
```

```powershell
Import-Csv ..\merge\reverse-output\assets\assetstudio-cli-inventory.csv |
  Where-Object { $_.Type -in @('Sprite','Texture2D','TextAsset') -and $_.Name -match 'Block|InGame|Maid|Popup|Loading' }
```

## 任务线 B：配置表导出

目标：恢复单机版运行必需的配置表数据。

优先级：P0

输入：

- `resources/lib/arm64-v8a/libil2cpp.so`
- `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat`
- 待重新生成的 `reverse-output/il2cpp/dump.cs`
- 待重新生成的 `reverse-output/il2cpp/analysis/excel-table-schema.csv`
- 待重新生成的 `reverse-output/il2cpp/analysis/table-data-fields.csv`
- AssetStudio TextAsset / ScriptableObject 导出
- `TableDataManager`、各 `*DataManager`

产出：

- `derived/tables/block_table.json`
- `derived/tables/board_table.json`
- `derived/tables/request_table.json`
- `derived/tables/item_table.json`
- `derived/tables/npc_table.json`
- `derived/tables/language_table.json`

待做：

1. 找到每个 `Table_*` 的真实资源文件。
2. 判断表数据格式：ScriptableObject、JSON、二进制、MessagePack 或自定义序列化。
3. 导出 `Table_Block` 全量数据。
4. 导出 `Table_Board` 地图和棋盘数据。
5. 导出 `Table_Request` 订单数据。
6. 导出 `Table_Language` 文本数据。
7. 补齐核心枚举：`BlockType`、`RewardType`、`CurrencyType`、`MapType`、`RequestGroupType`。

建议命令方向：

```powershell
Import-Csv ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\analysis\excel-table-schema.csv |
  Sort-Object Table,Field
```

```powershell
rg -n "public enum (BlockType|RewardType|CurrencyType|MapType|RequestGroupType)" ..\merge\reverse-output\il2cpp\2026-05-21-101217-il2cppdumper\dump.cs
```

## 任务线 C：核心玩法规则

目标：还原合成棋盘最小可玩规则。

优先级：P0

输入：

- `InGame_BlockManager`
- `InGame_MapManager`
- `RequestDataManager`
- `BlockTableData`
- `MapSaveData`
- `RequestSaveData`

产出：

- `docs/core-gameplay-loop-analysis.md` 持续补充。
- `derived/gameplay-rules.md`
- 单机版逻辑伪代码或原型代码。

待做：

1. 明确合成条件：同组、同等级、非锁定、`IsActiveMerge=true`。
2. 明确合成结果：下一等级 block、特殊掉落、泡泡概率。
3. 明确生产器产出：消耗、冷却、掉落池、权重。
4. 明确订单完成：需要物、奖励、删除方块、刷新订单。
5. 明确背包规则：普通方块槽、生产器槽、容量。
6. 明确出售规则：金币计算。

MVP 可先采用简化规则：

- 只允许相同 `GroupName + Level` 合成。
- 合成结果取同 `GroupName` 的 `Level + 1`。
- 生产器使用固定掉落池。
- 订单只检查 `blockId + amount`。
- 奖励只发金币和经验。

## 任务线 D：本地存档

目标：替换账号、云存档、服务器数据，设计纯本地存档。

优先级：P0

输入：

- `UserSaveData`
- `UserData`
- `MapSaveData`
- `BlockSaveData`
- `ProduceBlockSaveData`
- `RequestSaveData`
- `UserItemData`
- `UserTutorialSaveData`

产出：

- `derived/save-schema.json`
- `docs/local-save-schema.md`

待做：

1. 设计本地 JSON 存档结构。
2. 映射原始 key：
   - `userdata`
   - `mapdata`
   - `blockdata`
   - `produceblockdata`
   - `requestdata`
   - `useritemdata`
   - `usertutorialdata`
3. 定义新存档版本号。
4. 定义初始化新用户数据。
5. 定义每日刷新和离线冷却处理。

## 任务线 E：UI 最小闭环

目标：基于已分析 UI 类，做单机版最小 UI。

优先级：P1

MVP UI：

- Loading
- Lobby
- InGame
- Inventory
- Quest / Request
- Reward popup
- Option

暂缓 UI：

- 活动页
- AI 聊天
- IAP 商店
- 广告奖励
- 排行榜
- 平台账号页
- 大量活动弹窗

待做：

1. 从 `UIManager` 根节点设计新 UI 层级。
2. 确定要复用哪些原图。
3. 建立 `uiClass -> 新单机页面` 映射。
4. 手工重建或恢复 prefab。

## 任务线 F：技术原型

目标：尽快验证“资源可显示、方块可合成、存档可读写”。

优先级：P1

建议技术路线：

- 首选 Unity，降低 Sprite / Spine / Audio 复用成本。
- 表数据转 JSON。
- 最小 UI 手工搭建。
- 原始 prefab 能恢复则复用，不能恢复就重建。

原型里程碑：

1. 显示 Loading 和 Lobby。
2. 进入棋盘，加载 10 个方块图标。
3. 拖拽两个方块合成。
4. 点击生产器生成方块。
5. 完成一个订单并发金币。
6. 退出重进后恢复棋盘和金币。

## 建议执行顺序

1. P0：基于 `shaonv/resources/lib/arm64-v8a/libil2cpp.so` 和 `shaonv/resources/assets/bin/Data/Managed/Metadata/global-metadata.dat` 重新导出 IL2CPP dump。
2. P0：基于 `shaonv/resources/assets/bin/Data` 和 `shaonv/resources/assets/yoo/Default` 重新导出 AssetStudio / AssetRipper 资源清单。
3. P0：用新导出的 `shaonv/reverse-output` 重新验证 UI、表、玩法类。
4. P0：导出并验证 `BlockTableData`。
5. P0：建立 `blockId -> sprite` 映射。
6. P0：设计本地存档 JSON schema。
7. P0：写核心合成规则伪代码。
8. P1：导出 `Request` 和 `Board` 数据。
9. P1：做 Unity 原型棋盘。
10. P1：补 Lobby / Loading / Reward UI。
11. P2：补角色、剧情、收藏。
12. P2：选择性接入活动内容。

## 当前风险

- 方法体为空，部分规则需要从 native 反汇编或运行观察确认。
- AssetBundle / YooAsset 清单尚未完整解析。
- Prefab 与脚本绑定关系尚未恢复。
- 表数据真实格式尚未确认。
- 原资源授权和合规问题需要单独确认。
