# shaonv Godot MVP 初始化记录

时间：2026-05-22

## 1. 工程位置

```text
D:\work\openclaw-workspace\arpg\shaonv\standalone\godot-mvp
```

Godot 工具：

```text
D:\work\openclaw-workspace\arpg\shaonv\Godot\Godot.exe
D:\work\openclaw-workspace\arpg\shaonv\Godot\Godot_console.exe
```

## 2. 当前选择

从授权和发行成本考虑，MVP 正式实现转向 Godot。此前的 `standalone/web-mvp` 和 `standalone/unity-mvp` 已删除，当前可运行实现以 `standalone/godot-mvp` 为唯一主线。

Godot 当前目标是“用原素材重制单机抽卡闭环”，不是直接复用 Unity prefab。原因：

- Godot 不能直接使用 Unity UGUI prefab、AnimatorController、Material。
- 现有 `skel.bytes + atlas.txt + png` 可以作为 Spine 运行输入，但需要 Godot Spine 插件或转换流程。
- 当前 MVP 先用 atlas PNG 静态展示角色，保证抽卡/图鉴闭环可运行。
- 注意：当前导入的 `hero_*.png` 多数是 Spine atlas 贴图，显示的是骨骼动画用的部件图，不等于 Unity 运行时已经摆好姿势的整张立绘。若要在 Godot 中达到原游戏角色展示效果，需要接入 Spine Godot 运行时，或先用 Spine/Unity/导出工具把指定动画帧渲染成整图再导入。
- Unity/Web 文档保留为逆向分析和方案演进记录，不再作为实现目录。

## 3. 当前内容

```text
standalone/godot-mvp/
  project.godot
  scenes/main.tscn
  scripts/main.gd
  data/
    heroes_mvp.json
    gacha_pools_mvp.json
    live_ops_mvp.json
    draw_pool_summary.json
    hero_resource_map.json
  assets/spine/
    hero_001/
    hero_003Dh/
    hero_005/
    hero_016/
    hero_017/
```

## 4. MVP 功能

`scripts/main.gd` 已实现：

- 启动链路：按原分析简化为 `LaunchView -> PreloadingView -> LoginView -> LoadingView -> MainUIView`，使用离线账号进入主界面。
- 启动资源预览：Launch/Login/Loading 阶段显示代表角色资源；若资源路径缺失，会在界面显示 `res://...` 缺失路径，便于定位导入问题。
- 主界面：按原 `MainUIView` 分析重排为顶部玩家/资源栏、壁纸看板区、右侧玩法入口、底部功能栏、章节任务信息。
- 玩家信息：顶部 `pnlPlayerInfo/btnPlayerInfo` 可点击，显示等级、名称、战力、收集数、抽卡数和看板设置。
- 设置：简化 `SystemSettingView/PlayerSetting`，支持看板自动播放、音乐、音效开关并写入存档。
- 抽卡：按 `LotteryDrawMainView -> LotteryDrawPanel` 分析重排为左侧卡池 tab、中部 UP/保底信息、右侧角色展示、底部单抽/十连/概率/记录按钮。
- 抽卡规则：`data/gacha_pools_mvp.json` 驱动概率、UP 权重、保底、重复碎片和 Static 来源字段。
- 喚靈演出：按 `LotteryDrawHelper.ShowLotteryAnimation` 职责补了抽卡前演出/确认页，展示卡池、次数、消耗、当前券数、保底进度，并提供开始、跳过和返回。
- 结果页：按 `LotteryDrawFinishView -> HeroRecruitView/LotteryRewardShowView` 职责拆分，显示主出货角色、稀有度标题、模拟稀有度光效层、十连结果格稀有度色框、新角色和重复碎片，点击结果进入角色详情。
- 图鉴：按 `GalCollectionView` 的分页/筛选/进度职责补了收集进度、全部/已获得/未获得/稀有度筛选、已获得优先和稀有度排序，未获得角色灰显。
- 角色详情：按 `CommonHeroView` 的角色信息页职责显示获得状态、稀有度、碎片、获得途径、资源路径和 Spine key；未获得角色叠加锁定遮罩，已获得角色可设为看板。
- 记录：抽卡历史。
- 商店：源石兑换喚靈券，并跳转每日补给、邮件、任务。
- 章节任务：按抽卡次数、收集数量发放喚靈券和源石，替代原 `InitPnlTask/ChapterTask` 的 MVP 版本。
- 每日补给：按本地日期每日领取一次资源。
- 邮件：提供启动补给和回归补给，模拟原游戏邮件奖励入口。
- 运营资源规则：`data/live_ops_mvp.json` 驱动任务、邮件、每日补给和商店兑换，后续可替换为原游戏表导出数据。
- 本地存档：`user://shaonv_godot_mvp_save.json`。

当前存档字段：

```json
{
  "tickets": 120,
  "gems": 16800,
  "profile": {
    "name": "Player",
    "level": 88,
    "base_power": 999999
  },
  "settings": {
    "wallpaper_auto_play": true,
    "music": true,
    "effects": true
  },
  "owned": {},
  "shards": {},
  "pity": {},
  "history": [],
  "draw_count": 0,
  "claimed_tasks": {},
  "claimed_mail": {},
  "daily_claimed_date": "",
  "selected_hero_id": 240065,
  "active_pool_id": "advanced"
}
```

## 5. 资源

数据资源：

| 文件 | 当前用途 |
|---|---|
| `data/heroes_mvp.json` | 角色基础信息、稀有度和立绘/Spine key |
| `data/gacha_pools_mvp.json` | 卡池、UP、消耗、保底、概率、UP 权重、重复碎片、Static 来源 |
| `data/live_ops_mvp.json` | 每日补给、商店兑换、章节任务、邮件奖励 |
| `data/draw_pool_summary.json` | 逆向导出的抽卡表摘要 |
| `data/hero_resource_map.json` | 逆向导出的角色资源映射 |

已导入 Godot 工程的角色资源：

| 角色 | 路径 | 当前用途 |
|---|---|---|
| 哪吒/hero_001 | `assets/spine/hero_001` | 静态展示，保留 Spine 三件套 |
| 莉莉絲/hero_003Dh | `assets/spine/hero_003Dh` | 静态展示，保留 Spine 三件套 |
| 蔡文姬/hero_005 | `assets/spine/hero_005` | 静态展示，保留 Spine 三件套 |
| 天狐妲己/hero_016 | `assets/spine/hero_016` | 静态展示，保留 Spine 三件套 |
| 女帝/hero_017 | `assets/spine/hero_017` | 静态展示，保留 Spine 三件套 |

每个角色包含：

```text
*.png
*.atlas.txt
*.skel.bytes
```

## 6. 运行和校验

Windows 双击运行：

```bat
run-godot-mvp.bat
```

诊断截图：

```bat
capture-godot-mvp.bat
```

该脚本会让 Godot 直接从内部 viewport 保存截图到 `tmp/screenshots/godot-mvp-internal.png`。如果窗口显示异常但内部截图正常，说明资源和 UI 已加载，问题集中在本机窗口渲染后端或显卡驱动路径。

注意：`Godot_console.exe --headless` 可以执行脚本逻辑，但没有可读取的渲染 viewport texture，不能用于当前 UI 截图。自动截图应使用 `Godot_console.exe` 非 headless 模式创建窗口后，由 `SHAONV_MVP_CAPTURE` 触发内部 viewport 保存。

源码运行阶段角色贴图通过 `Image.load()` 从已提交的原始 PNG 直接创建 `ImageTexture`，不依赖 `.godot/imported/*.ctex`。这是为了避免 `git pull` 后本地没有 Godot 导入缓存时报 `Unable to open file: res://.godot/imported/*.ctex`。后续做导出包时再改回正式导入资源流程。

命令行校验：

```powershell
.\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
```

启动编辑器：

```powershell
.\Godot\Godot.exe --path standalone\godot-mvp
```

直接运行：

```powershell
.\Godot\Godot.exe --path standalone\godot-mvp --scene res://scenes/main.tscn
```

## 7. 当前还原依据和缺口

本轮 Godot UI 还原依据：

- `docs/shaonv-hotfix-ui-lifecycle-analysis.md` 中启动顺序：`LaunchView.OnOpen/Awake -> LoginView -> LoadingView.UpdateProcess -> GameHelper.LoadMainScene -> MainUIView`。
- `docs/shaonv-hotfix-ui-lifecycle-analysis.md` 中 `MainUIView` 字段分组：`pnlPlayerInfo`、`_topBar`、`pnlFunny`、`pnlBottom`、`WallpaperPanel`、`btnDraw`、`btnPrayer`、`btnHero`、`btnBagpack`、`btnTask` 等。
- `MainUIView.InitPnlTask()` 中的章节任务刷新、领取事件和 `ReqGetChapterTask` 行为，被简化为本地 `TASKS` 表和 `claimed_tasks` 存档。
- `pnlCommercialization/btnWelfare/btnShop` 被简化为每日补给、邮件和商店入口。
- `docs/shaonv-p0-continuation-2026-05-22.md` 中抽卡调用链：`LotteryDrawMainView -> LotteryDrawPanel -> LotteryDrawModel -> LotteryDrawFinishView/HeroRecruitView`。
- `reverse-output/managed/Assembly-CSharp-index/gacha-character-methods.csv` 中 `LotteryDrawHelper.ShowLotteryAnimation/CheckIsNeedSkipAnim`、`LotteryDrawFinishView.GetLightEffect/GetMaskPic/Launch/ShowReward` 与 `HeroRecruitView.InitAnimationView/CreateSpine`，用于确定抽卡前演出、跳过演出、按稀有度切光效、主角色演出层和结果奖励格。
- `reverse-output/gacha-static/tables/drawconfig.json` 和 `draw_pool_summary.csv` 中的 `cnt3/rateUp` 字段，用于标注当前 MVP 卡池规则来源。
- `docs/shaonv-yooasset-physical-mapping-fix.md` 中已定位的抽卡 prefab 物理映射。
- `reverse-output/managed/Assembly-CSharp-index/methods.csv` 中 `GalCollectionView` 的 `OnSelectHero/GetGridCount/OnBtnNextClick/OnBtnPreviousClick/UpdateProgress` 和 `CommonHeroView` 的 `OnOpen/OnTabChange/UpdateSkill`，用于确定图鉴页需要进度、筛选、选择角色和角色详情信息区。
- 已导入 Godot 的 5 个代表角色 Spine 三件套中的 PNG，用作看板和抽卡展示。

当前仍未完全还原：

- 启动视频 `launch.mp4`、真实热更进度、服务器/SDK 登录仍未接入；当前为离线可跳过流程。
- 原 `MainUIView`、`LotteryDrawMainView`、`GalCollectionView`、`CommonHeroView` prefab 的完整 RectTransform 层级尚未转换为 Godot scene。
- 抽卡 UI 图集、按钮图、真实结果光效、音效仍未批量导入 Godot；当前结果页用 Godot 半透明色块模拟稀有度光效。
- Spine 运行时尚未接入，当前仍是 PNG 静态展示。
- 原游戏 reward 掉落表仍需继续展开；当前概率和重复碎片已数据化，但仍是基于 `drawconfig/ac_limit_draw` 字段的 MVP 近似规则。

## 8. 下一步

1. 用 Godot 编辑器检查布局并调整主题、字体、按钮样式。
2. 接入 Spine Godot 运行方案，验证 `.skel.bytes + .atlas.txt + .png` 播放。
3. 将抽卡 UI 图集、结果光效和音效导入 Godot，并建立 Godot 资源命名规范。
4. 用真实掉落表替换当前 MVP 概率。
5. 将 `HeroRecruitView/LotteryDrawMainView/LotteryDrawFinishView` 的结构分析转成 Godot Control 节点重建清单。
6. 把抽卡结果演出、角色详情页、商店和图鉴筛选做成独立 scene，降低 `main.gd` 复杂度。
7. 将任务、邮件、每日补给拆成独立 scene，并继续把 `live_ops_mvp.json` 对齐到原 `QuestView/GameShopView/Welfare/Mail` 资源与文本。
