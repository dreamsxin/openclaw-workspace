# ExpeditionMainView 首屏布局修复记录

生成时间：2026-05-27。

本文记录一条更具体的修复链路：依据 `WorldMap` 场景资源、`ExpeditionMainView.prefab` 原始布局和真实截图，修正 Godot MVP 中 `ExpeditionMainView` 的首屏场景、驻扎角色和按钮布局。

## 结论摘要

- `ExpeditionMainView` 首屏不是白底 UI 面板，也不是 `ExpeditionMapView` 的滚动地图首屏。
- 当前最强证据链指向：
  - 底层主场景：`worldmap04_main_view.png`
  - 叠加 UI：`ExpeditionMainView.prefab`
  - 子入口：`imgMap/btnMap -> ExpeditionMapView`
- `ExpeditionMainView.prefab` 的关键首屏布局已经闭合到具体锚点：
  - `imgMap`: 右上锚点，`160x160`，`anchoredPosition = (-64, -23)`
  - `btnCrossReward`: 左上锚点，`352x70`，`anchoredPosition = (64, -100)`
  - `btnFight`: 右下锚点，`160x160`，`anchoredPosition = (-64, 23)`
  - `btnDispatch / btnHero / btnMarch`: 右下锚点，`90x90`
  - `btnStronger`: 左下锚点，`152x152`
  - `btnReward`: 右下锚点，`172x172`
- 当前 Godot MVP 已按这条证据链修回首屏：
  - 底图改为 `worldmap04_main_view`
  - 右上小地图入口恢复为原 prefab 的 `160x160` 入口块
  - 底部按钮和挂机奖励区按原始锚点重排
  - 驻扎角色从圆头像占位改为 baked Spine 本体

## 1. 证据链

### 1.1 真实截图

原始截图：

- [塵世探秘界面.jpg](D:/work/openclaw-workspace/arpg/shaonv/screenshot/塵世探秘界面.jpg)

可见特征：

- 场景是固定俯视院落，不是纯 UI 面板背景
- 中部有驻扎角色/骑乘单位
- 右上是圆形小地图入口
- 左上是跨关奖励条
- 底部是 `变强 / 派遣 / 星灵 / 阵容 / 挑战` 与挂机宝箱的组合

### 1.2 场景底图

当前最吻合的 AFKMap 主场景资源：

- [worldmap04_main_view.png](D:/work/openclaw-workspace/arpg/shaonv/standalone/godot-mvp/assets/ui/expedition/afkmap/worldmap04_main_view.png)

它与截图共通的宏观结构：

- 中央主殿 + 右侧回廊
- 下方桥面/平台
- 左下角树木与灯柱
- 右下角通向圆形区域的台阶/平台

### 1.3 `ExpeditionMainView.prefab` 布局锚点

从 `reverse-output/godot-layout-inspect/ExpeditionMainView.layout.json` 可确认：

#### `pnlBottom`

- `btnFight`
  - anchor: `right-bottom`
  - size: `160x160`
  - pos: `(-64, 23)`
- `pnlReward`
  - anchor: `right-bottom`
  - pos: `(-253, 23)`
- `btnMarch`
  - anchor: `right-bottom`
  - size: `90x90`
  - pos: `(-435, 27)`
- `btnHero`
  - anchor: `right-bottom`
  - size: `90x90`
  - pos: `(-535, 27)`
- `btnDispatch`
  - anchor: `right-bottom`
  - size: `90x90`
  - pos: `(-635, 27)`
- `btnStronger`
  - anchor: `left-bottom`
  - size: `152x152`
  - pos: `(64, 24)`

#### `pnlMap`

- `imgMap`
  - anchor: `right-top`
  - size: `160x160`
  - pos: `(-64, -23)`
- `btnCrossReward`
  - anchor: `left-top`
  - size: `352x70`
  - pos: `(64, -100)`

这组锚点说明：

- `imgMap` 是一块贴着右上角的小地图入口，不应被误做成中部/偏下的大图。
- `btnCrossReward` 应贴左上角，不应漂到其它层。
- 底部 5 个按钮本来就分属左右两侧锚点系统，不能只靠目测散摆。

## 2. Godot 修复内容

代码位置：

- [expedition_screen.gd](D:/work/openclaw-workspace/arpg/shaonv/standalone/godot-mvp/scripts/screens/expedition_screen.gd)

### 2.1 首屏底图

修正前：

- 首屏曾经使用错误的简化场景/白底构图
- 与 `塵世探秘界面.jpg` 的院落场景差异很大

修正后：

- `show_expedition_main()` 直接以 `worldmap04_main_view.png` 作为底层主场景
- 只保留很轻的整体遮罩，不再叠大面积错误面板

### 2.2 右上小地图入口

修正前：

- `imgMap` 被做成了偏大的中央预览块
- 视觉语义更像地图窗口，不像主界面的右上入口

修正后：

- 恢复到 `160x160` 小地图入口语义
- 位置对齐 `ExpeditionMainView.prefab` 的右上锚点
- `btnMap` 保持整块透明点击区，点击后切到 `ExpeditionMapView`

### 2.3 左上跨关奖励条

修正后按 prefab 结构恢复：

- `btnCrossReward` 作为左上角 `352x70` 条
- 图标 `imgCrossRewardIcon` 和两行文本保持在条内
- 与真实截图中的“再过 N 关可得”区块语义一致

### 2.4 底部按钮与挂机宝箱

按原始锚点重排：

- 左下：`我要变强`
- 右下依次：`派遣 / 星灵 / 阵容 / 挂机奖励 / 挑战`
- `挑战` 按钮下方恢复 `imgLevelLimit` 解锁条
- `btnReward` 上方恢复 `imgRewardTip`
- `txtHookTime` 回到奖励宝箱自身的时间条上

### 2.5 驻扎角色层

修正前：

- 中部驻扎点使用圆头像占位
- 只能表达“这里有个点位”，不能表达真实首屏的驻扎角色气质

修正后：

- 优先使用 hero 的 baked Spine：
  - 当前验证用例成功加载 `hero_022.baked.json`
- 若 baked 不存在，再退回 PNG / portrait
- 角色本体压到院落桥面区域，替代之前的圆头像占位

### 2.6 AFKMap 场景单位补证

本轮继续往 AFKMap 侧追后，又拿到一组更贴近“驻扎场景单位”的证据：

- `PlayerTileMovement.prefab`
  - `Shadow`
  - `Sprite`
  - `Weapon`
- `Player.prefab`
  - `Shadow`
  - `Spine`
  - `Sprite`
  - `Weapon`
- `Tip_EnterVehicle.prefab`
  - 独立 `TextMesh` 提示体

这说明：

- AFKMap 运行时角色本来就不是简单 UI 头像，而是带：
  - 独立阴影
  - Spine/场景单位本体
  - 武器/附加 sprite
  - 车辆/载具相关提示入口

也就是说，“首屏驻扎角色应继续朝 AFKMap 场景单位语义逼近”这条方向，现在已经有 prefab 级直接证据支撑，不再只是截图联想。

本轮 Godot 侧也据此把首屏角色进一步调整为更像场景单位的版本：

- 优先尝试 `hero_022h.baked.json`
- 退回顺序：
  - `hero_022.baked.json`
  - PNG
  - portrait
- 同时移除粗糙的伪载具多边形占位，只保留更自然的地面阴影与驻扎标签

## 3. 验证结果

### 修正前

- [shaonv-expedition-capture-mainview-v4.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/shaonv-expedition-capture-mainview-v4.png)

主要问题：

- 场景是错误的低保真简化平台
- 右上 `imgMap` 不是原始入口形态
- 驻扎角色是圆头像占位

### 修正后

- [shaonv-expedition-capture-mainview-v6.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/shaonv-expedition-capture-mainview-v6.png)

当前已确认改善：

- 底图回到真实院落场景
- 右上小地图入口回到 `160x160` 入口块语义
- 底部按钮区与挂机奖励条回到 `ExpeditionMainView` 的原始锚点系统
- 驻扎角色替换成真实角色本体预览

### 继续推进后

- [shaonv-expedition-capture-mainview-v7.png](D:/work/openclaw-workspace/arpg/shaonv/tmp/shaonv-expedition-capture-mainview-v7.png)

相较 `v6`，新增改善：

- 场景单位切到更像 AFKMap 单位的 `hero_022h` 变体
- 去掉明显假的伪载具占位块
- 保留独立地面阴影，让中部驻扎单位更贴近真实游戏的场景化角色表达

## 4. 当前仍未闭合的点

- 当前驻扎角色已经从“头像占位”推进到“AFKMap 风格场景单位”，但还不是原截图那种完整“骑乘/载具”表现。
- `btnFight`、`btnReward`、`btnMap` 的按钮本体已经回位，但粒子/soft guide 仍未恢复。
- 主场景中的其它 NPC / 路径装饰 / 实时战斗单位没有恢复。
- `worldmap04_main_view.png` 目前是最强证据底图，但 `WorldMap04` 源包本体、对应 `AutoTileMapData` 和场景装饰逻辑还没继续追到。

## 5. 下一步建议

1. 继续深挖 `worldmap04` 主包与 `*_imgeffect`，确认主场景上层是否还有独立角色停驻点、前景遮挡或动效层。
2. 继续深挖 `PlayerTileMovement.prefab`、`Player.prefab`、`Tip_EnterVehicle.prefab` 及其脚本字段，确认真实“进入载具/驻扎状态”链路。
3. 把驻扎角色从“AFKMap 风格单体单位”推进到“角色 + 坐骑/驻扎底座”的组合表现。
4. 若后续拿到 `ExpeditionMainView` 相关更多运行时字段，再补 `btnFight` 的真实解锁条件、`btnReward` 的挂机收益数值和 `btnCrossReward` 的真实章节阶段文案。

## 6. 2026-05-28 阶段进度补记

本轮继续沿同一条证据链推进，重点从“首屏大结构修回”转向“入口层级和真实交互壳补齐”。

### 6.1 `hero_053_s02 / hero_053_s02h` 已从本地 bundle 真补回

此前 `hero_053_s02` 在 manifest 中有完整 Spine 记录，但 `physical-asset-map.csv` 没有闭合到可用物理包。

本轮不再依赖 manifest 推导包名，而是直接按资源名扫描所有本地 bundle container path，最终命中：

- `files/yoo/Default/BundleFiles/d1/d133c1e76a9e76b3b5ebbb26131bb095/__data`
- `files/yoo/Default/BundleFiles/2e/2ebf56a5c569284708925de1bc096436/__data`

实际补回并导入成功的条目：

- `Hero__hero_053_s02`
- `Hero__hero_053_s02__hero_053_s02_bg`
- `Hero__hero_053_s02h`
- `Hero__hero_053_s02h__hero_053_s02h_bg`

并已完成 baked：

- `Hero__hero_053_s02.baked.json`
- `Hero__hero_053_s02h.baked.json`

这说明：

- `hero_053_s02` 系列不是“本地没有资源”
- 问题在于原先的物理映射没有闭合到运行时真实 bundle

### 6.2 首屏驻扎单位默认方案已切到 `hero_053_s02h`

当前首屏驻扎角色默认不再优先用：

- `HeroQ__hero_053q_s01`

而改为优先：

- `hero_053_s02h`

理由：

- `HeroQ` 更偏战斗/演出气质
- `hero_053_s02h` 更接近主界面静态驻扎单位
- 更符合“塵世探秘界面”里中部巡逻/载具入口的氛围

同时保留运行时切换能力，仍可对比：

- `heroq_s01`
- `hero_s02`
- `hero_s02h`

### 6.3 主界面三条核心入口行为已改成更接近原始层级

本轮已把以下交互链改成更像真实流程：

1. 首屏中部驻扎单位点击
   - 进入地图页
   - 自动打开当前章节详情

2. `btnMap`
   - 不再只打开地图页
   - 改为进入地图并聚焦当前章节详情

3. `btnCrossReward`
   - 改为直接进入章节奖励详情

4. `btnFight`
   - 改为先进章节页
   - 再从章节页进入挑战流

这条交互层级当前更接近：

`ExpeditionMainView -> ExpeditionMapView / ExpeditionChapterMapDetailView / ChapterTaskView`

### 6.4 首屏按钮内部子控件与状态语义继续补齐

本轮继续补了主界面里此前缺失、但 prefab 已确认存在的子层语义：

- `btnCrossReward`
  - `txtCrossRewardStage`
  - `txtCrossRewardNumber`
  - `imgCrossRewardIcon`

- `btnReward`
  - `txtHookTime`
  - `txtRewardTip`
  - `pnlHookSoftGuide` 轻量占位
  - 独立 hotspot

- `btnFight`
  - `imgLevelLimit`
  - `txtLevelLimit`
  - `pnlSoftGuide` 轻量占位

- `btnDispatch / btnHero / btnMarch`
  - `Text`
  - `@pnlRedDot` 占位

并且 `btnReward / btnFight` 已不再是纯静态文案：

- `btnReward`
  - 若今日未领取挂机收益：显示挂机时间与“快速战斗99次 / 可提升等级”
  - 若今日已领取：改成“今日挂机收益 / 已领取”
  - soft guide 随之关闭

- `btnFight`
  - 若有下一关且战力足够：显示“可进行挑战”
  - 若战力不足：显示“推荐战力xxxx”
  - 若无下一关：显示“全部通关”
  - 引导发光只在可挑战时显示

### 6.5 当前仍未闭合的点

1. 首屏驻扎单位已经更像“进入载具 / 巡逻入口”，但还没恢复成原截图里更完整的坐骑/巡逻组合。
2. `map_pic_1002+` 仍不能当作真实 world icon 资源使用。
3. `ConquerChapterStaticItem.mapPic / mapMove / mapDec` 真实数据链还未完整导入 Godot。
4. `WorldMap04` 源场景装饰逻辑与前景遮挡还没彻底打穿。
