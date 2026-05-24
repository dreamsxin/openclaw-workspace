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
    adventure_mvp.json
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
- 战役：`adventure_mvp.json` 驱动离线章节，按玩家战力判定挑战，胜利推进关卡并发放喚靈券、源石和角色碎片。
- 挂机收益：每日可收取一次喚靈券、源石和碎片，作为单机循环的稳定资源入口。
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
  "battle_count": 0,
  "max_stage_id": 0,
  "next_stage_id": 101,
  "claimed_tasks": {},
  "claimed_mail": {},
  "daily_claimed_date": "",
  "afk_claimed_date": "",
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
| `data/adventure_mvp.json` | 单机战役章节、关卡推荐战力、通关奖励、每日挂机收益 |
| `data/draw_pool_summary.json` | 逆向导出的抽卡表摘要 |
| `data/hero_resource_map.json` | 逆向导出的角色资源映射 |

已导入 Godot 工程的角色资源：

| 角色 | 路径 | 当前用途 |
|---|---|---|
| 哪吒/hero_001 | `assets/spine/hero_001` | 已生成 `hero_001.baked.json`，播放 `wait/wait1` |
| 莉莉絲/hero_003Dh | `assets/spine/hero_003Dh` | 已生成 `hero_003Dh.baked.json`，播放 `wait/wait1` |
| 蔡文姬/hero_005 | `assets/spine/hero_005` | 已生成 `hero_005.baked.json`，播放 `wait/wait1` |
| 天狐妲己/hero_016 | `assets/spine/hero_016` | 已生成 `hero_016.baked.json`，播放 `wait/wait1` |
| 女帝/hero_017 | `assets/spine/hero_017` | 已生成 `hero_017.baked.json`，优先播放 `wait/wait1` |

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

## 7. Spine 动画验证更新

2026-05-22 已完成 Spine MVP 验证：

- `hero_016.skel.bytes` 为 Spine binary `4.2.26`。
- 可用动画为 `wait`、`wait1`，没有名为 `idle` 的 clip；当前把 `wait` 作为待机动画。
- `D:\work\openclaw-workspace\arpg\merge` 的可运行方案是预烘焙 Spine 帧，再在 Godot 中用 `draw_polygon()` 绘制 attachment mesh。
- 已为本项目新增 `scripts/spine/bake_hero_spine_preview.mjs`、`standalone/godot-mvp/scripts/spine_baked_preview_canvas.gd`。
- 已为 `hero_001`、`hero_003Dh`、`hero_005`、`hero_016`、`hero_017` 生成 baked JSON，启动、登录、加载和主界面不再把 Spine atlas PNG 当作静态立绘展示。
- `main.gd` 会优先加载 `<hero>.baked.json` 播放 baked 动画；没有 baked 数据时继续退回 PNG 静态展示。
- 官方 Spine GDExtension zip 已探测，但命令行 `ClassDB` 没有注册出 Spine 类，本轮不作为 MVP 依赖提交。

详细记录见 `docs/shaonv-godot-spine-verification-2026-05-22.md`。

Godot Spine runtime 源码分析见 `docs/shaonv-godot-spine-runtime-analysis.md`。结论是：`spine-godot` 可通过 `SpineSprite + SpineSkeletonDataResource + SpineAtlasResource + SpineSkeletonFileResource` 播放动画，但当前 MVP 工程未安装 `.gdextension`，且游戏 skeleton 是 Spine `4.2.26`，与 `spine-godot 4.3` 存在版本风险；MVP 主路径继续使用 baked Spine。

## 8. 启动界面精修更新

2026-05-22 从启动链路开始做第一轮精修：

- `LaunchView`：按反编译结果保留可跳过启动视频页概念，界面标注 `launch.mp4`，没有视频资源时用代表角色和暗色视频框承接。
- `PreloadingView`：按 `processTxt/processSlider` 字段还原早期预加载页，显示本地资源校验进度。
- `LoginView`：按字段 `btnNotice/btnRepair/btnSwitchAccount/btnSelect/btnServerSel/togAgree/pnlVersion/imgLogo` 重建登录页，保留公告、修复、账号弹层和服务器选择区域。
- `LoadingView`：按 `txtPercent/sldSpeed/imgBg` 和 `GameHelper.LoadMainScene("MainScene")` 行为重建进入主城加载页。
- 新增 `SHAONV_MVP_START_VIEW=launch|preloading|login|loading|main` 调试入口，便于逐屏截图回归。

资源补查结果：

- `Assets/Game/RawAssets/Sprite/Login/*.png` 已从 manifest 定位到 `assets_game_rawassets_sprite_login*.bundle`、`logo.bundle`、`server_bg_011.bundle` 等物理文件。
- 当前 UnityPy 对这些 bundle 返回空对象，暂未能直接导出 Login sprite；本轮先按结构和字段还原布局，后续需要用 AssetStudio 或补完整 YooAsset bundle 解码路径继续导出原图。
- `loading_tip.bytes` 已确认含 `loading_1_1...loading_6_9` 等加载图 key，可作为后续加载提示和背景映射依据。

## 9. MainUIView 精修更新

2026-05-22 对进入 `MainScene` 后的第一屏做了一轮结构精修：

- 顶部保留 `pnlPlayerInfo` 等价玩家按钮和 `_topBar/TopResGrid` 等价资源栏，显示等级、名称、战力、邮件、喚靈券和源石。
- 中央 `WallpaperPanel` 区域改为主视觉层，优先播放当前看板角色 baked Spine 动画，并保留“壁紙/隱藏”控制入口。
- 左侧补 `btnChapterInfo/txtChapterTitle/svChapterReward` 的等价章节任务面板，并增加挂机收益/收取入口，对齐 `InitPnlTask` 和 `RefreshAutoFight` 证据。
- 右侧拆成 `pnlCommercialization` 小按钮区和 `pnlFunny` 玩法入口区，覆盖活动、福利、商店、月卡、战役、喚靈、竞技、祈愿、冒险、收获、援助。
- 底部 `pnlBottom` 改成固定功能栏，覆盖约会、武将、背包、宠物、养成、任务、军团，并保留红点占位。
- `spine_baked_preview_canvas.gd` 增加退化三角形过滤，避免部分 baked Spine attachment 在 Godot 中触发 `Invalid polygon data`。

本轮仍是结构精修，原 `MainUIView.prefab` 的具体图片、按钮九宫格和动效还未导入；后续应继续导出 MainUI 图集和 prefab RectTransform。

## 10. 当前还原依据和缺口

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
- 已导入 Godot 的 5 个代表角色 Spine 三件套，并全部生成 baked Spine 动画数据，用作看板、登录、加载和抽卡展示。

当前仍未完全还原：

- 启动视频 `launch.mp4`、真实热更进度、服务器/SDK 登录仍未接入；当前为离线可跳过流程。
- 原 `MainUIView`、`LotteryDrawMainView`、`GalCollectionView`、`CommonHeroView` prefab 的完整 RectTransform 层级尚未转换为 Godot scene；当前 `MainUIView` 已按字段和调用链完成第一轮结构还原。
- 登录 UI 图集、抽卡 UI 图集、按钮图、真实结果光效、音效仍未批量导入 Godot；当前结果页用 Godot 半透明色块模拟稀有度光效。
- Spine GDExtension 运行时尚未接入；当前采用 baked Spine 动画，适合 MVP 展示，但不支持运行时换装和混合动画。
- 原游戏 reward 掉落表仍需继续展开；当前概率和重复碎片已数据化，但仍是基于 `drawconfig/ac_limit_draw` 字段的 MVP 近似规则。

## 11. 原游戏资源接入更新

2026-05-23 已完成第一批原游戏 UI 资源接入 Godot MVP。

资源导出来源：

```text
reverse-output/assets/yoo-physical-map/physical-asset-map.csv
reverse-output/scripts/export-unitypy-all-assets.py
reverse-output/godot-resource-export/
```

本轮用 `physical-asset-map.csv` 反查已闭合物理包，并用 UnityPy 按 `--xor-prefix 222 --xor-key 0x16 --container-paths` 导出图片资源。中间导出目录为 `reverse-output/godot-resource-export/`，最终纳入 Godot 工程的资源目录为：

```text
standalone/godot-mvp/assets/ui/
  background/
  common/
  gallery/
  hero/half/
  hero/recruit/
  login/
  lottery/
  lottery/bg/
  mainui/
  skill/
```

已接入 Godot 的 PNG：

| 目录 | 文件 | 用途 |
|---|---|---|
| `assets/ui/background` | `login_bg_01.png` | `LoginView` 背景 |
| `assets/ui/background` | `mainui_bg_01.png` | `MainUIView` 主城背景 |
| `assets/ui/background` | `mainui_bg_02.png` | 后续 MainUI 背景候选 |
| `assets/ui/login` | `logo.png` | 登录页 logo |
| `assets/ui/login` | `server_bg_03.png` | 登录页服务器栏 |
| `assets/ui/login` | `server_bg_011.png` | 后续服务器选择背景候选 |
| `assets/ui/login` | `server_bg_107.png` | 后续服务器状态条候选 |
| `assets/ui/login` | `login_btn_03.png` | 后续登录按钮图候选 |
| `assets/ui/lottery` | `lottery_img_01.png` | `LotteryDrawMainView` 背景 |
| `assets/ui/lottery` | `lottery_img_02.png` | 抽卡背景候选 |
| `assets/ui/lottery` | `lottery_img_03.png` | 抽卡横向装饰候选 |
| `assets/ui/lottery` | `lottery_img_60.png` | 抽卡演出/结果背景 |
| `assets/ui/lottery` | `lottery_img_60_l.png` | 抽卡演出左侧光效 |
| `assets/ui/lottery` | `lottery_img_60_r.png` | 抽卡演出右侧光效 |
| `assets/ui/lottery` | `lottery_img_alpha_l.png` | 抽卡页左侧装饰光 |
| `assets/ui/lottery` | `lottery_img_alpha_r.png` | 抽卡页右侧装饰光 |
| `assets/ui/mainui` | `mainui_img_01.png` | 后续主界面装饰候选 |
| `assets/ui/mainui` | `mainui_img_10.png` | 当前 MainUI 顶部装饰条 |
| `assets/ui/mainui` | `mainui_img_12.png` | 后续主界面装饰候选 |
| `assets/ui/mainui` | `mainui_img_44.png` | 后续主界面整屏候选 |
| `assets/ui/hero/recruit` | `zhero_001.png` | 哪吒招募头像，图鉴/抽卡结果静态头像 |
| `assets/ui/hero/recruit` | `zhero_003.png` | 莉莉絲招募头像，图鉴/抽卡结果静态头像 |
| `assets/ui/hero/recruit` | `zhero_005.png` | 蔡文姬招募头像，图鉴/抽卡结果静态头像 |
| `assets/ui/hero/recruit` | `zhero_016.png` | 天狐妲己招募头像，图鉴/抽卡结果静态头像 |
| `assets/ui/hero/recruit` | `zhero_017.png` | 女帝招募头像，图鉴/抽卡结果静态头像 |
| `assets/ui/hero/recruit` | `zhero_022.png` | 阿修羅对应招募头像，图鉴/抽卡结果静态头像 |
| `assets/ui/hero/half` | `phero_003r*.png` | 莉莉絲图鉴半身候选 |
| `assets/ui/gallery` | `gal_gallery_pic_240065*.png` | 莉莉絲图鉴背景候选 |
| `assets/ui/common` | `lottery_btn_05.png`、`lottery_btn_06.png` | 抽卡按钮底图 |
| `assets/ui/lottery/bg` | `lottery_bg_01..09.png` | 現世/幻靈抽卡界面背景候选 |
| `assets/ui/item` | `draw_01..07.png` | 抽卡道具图标候选 |
| `assets/ui/skill` | `skill_icon_240037/045/055/065/068/069*.png` | 角色详情页技能图标 |

2026-05-23 追加了可复用导出工具和计划文件：

```powershell
python scripts\assets\export_unity_bundle_images.py `
  --plan scripts\assets\godot_mvp_resource_plan.json
```

该工具按 `physical-asset-map.csv` 反查物理包、自动处理 YooAsset 前 222 字节 XOR、只导出计划内图片，并复制到 Godot 工程。后续同类资源替换只需扩展 `scripts/assets/godot_mvp_resource_plan.json`，避免重复人工查找和手工复制。

代码接入：

- `main.gd` 新增 UI 资源常量和 `_draw_image()` helper。
- `heroes_mvp.json` 新增 `portraitResource` 字段，当前 6 个已有招募头像的角色可直接显示原始静态头像。
- `heroes_mvp.json` 追加 `skillResources`、`detailPortraitResource`、`galleryBackgroundResource`，角色详情页开始使用原游戏技能图标和图鉴资源。
- `LoginView` 优先显示 `login_bg_01.png`、`logo.png`、`server_bg_03.png`。
- `MainUIView` 背景替换为 `mainui_bg_01.png`，并叠加 `mainui_img_10.png` 装饰。
- `LotteryDrawMainView` 背景替换为 `lottery_img_01.png`，并叠加 `lottery_img_alpha_l/r.png`。
- 喚靈演出和结果页使用 `lottery_img_60.png`、`lottery_img_60_l/r.png`。
- 图鉴卡片、抽卡结果格和缺少 baked Spine 的角色展示会使用 `portraitResource` 作为静态兜底。
- `LotteryDrawMainView` 的单抽/十连按钮叠加原 `lottery_btn_05/06` 底图。
- `MainUIView` 的抽卡入口拆为“現世”和“幻靈”：現世显示普通/高级/进阶池，幻靈显示源神祈願池；两条入口使用不同真实 `lottery_bg_*` 背景，角色展示继续使用 baked Spine 动画。
- 新增 `SHAONV_MVP_START_VIEW=gacha|prayer|battle|gallery|hero_detail` 调试入口，`hero_detail` 可配合 `SHAONV_MVP_HERO_ID=240065` 直接回归角色详情页。

截图验证：

```text
tmp/screenshots/resource-login.png
tmp/screenshots/resource-main.png
tmp/screenshots/resource-gacha.png
```

命令行校验：

```powershell
.\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
```

校验可通过。当前仍会出现源码运行阶段直接 `Image.load()` PNG 的 Godot 警告，这是此前为避免缺少 `.godot/imported/*.ctex` 所采用的运行策略；导出正式包前再切回 Godot 导入资源流程。

## 12. 2026-05-23 prefab layout restart

因前一轮对“现世”入口后续界面的判断存在偏差，本轮开始把还原顺序重置为：

1. 先以 Unity prefab 的 `RectTransform` 层级为事实源，复刻启动页与 `MainUIView` 第一屏布局。
2. 再按主界面已存在菜单入口，逐个复刻子界面。
3. 抽卡“现世/幻灵”子界面暂停主观推断，后续必须先抽取对应 prefab、真实 UI 图集与 Spine 展示链路。

新增可复用工具：

```powershell
python scripts\assets\inspect_unity_prefab_layout.py `
  --repo-root . `
  --markdown docs\shaonv-prefab-layout-restart-2026-05-23.md `
  --markdown-depth 4
```

该工具会通过 `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` 解析 prefab 物理包，处理 YooAsset 前 222 bytes XOR，输出：

```text
reverse-output/godot-layout-inspect/LaunchView.layout.json
reverse-output/godot-layout-inspect/LoginView.layout.json
reverse-output/godot-layout-inspect/LoadingView.layout.json
reverse-output/godot-layout-inspect/MainUIView.layout.json
reverse-output/godot-layout-inspect/TopResGrid.layout.json
docs/shaonv-prefab-layout-restart-2026-05-23.md
```

本次抽取到的关键结论：

- `LaunchView.prefab` 实际只有 `LaunchView/Image/RawImage/video` 四个节点，Godot 启动页已改为以全屏 RawImage/video 占位为主。
- `LoginView.prefab` 包含 `imgBg`、`pnl`、`btnLogin`、`pnlFunction`、`pnlVersion`、`imgLogo`、`btnServerSel`、`inputAccount`、`@richUrl/togAgree` 等节点；Godot 登录页已按中轴布局重排。
- `LoadingView.prefab` 是 `imgBg + txtPercent + sldSpeed`，进度条在底部；Godot 载入页已改到底部进度条布局。
- `MainUIView.prefab` 不是外挂顶栏加内容区，而是 `MainUIView/pnlAdapter` 全屏布局；核心一层节点为 `@WallpaperPanel`、`@TopBar`、`pnlPlayerInfo`、`pnlFunny`、`pnlCommercialization`、`btnChapterInfo`、`pnlBottom`、`pnlChat`。
- Godot 首屏已改为全屏 `MainUIView` 方式：隐藏旧的独立 `top_bar/title_label/wallet_label`，把玩家信息、资源栏、右侧玩法入口、商业入口、章节任务、底栏和聊天条放回同一张 1280x720 画布。

验证命令：

```powershell
.\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
$env:SHAONV_MVP_START_VIEW='main'; .\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
```

两条命令均可完成启动。本轮还用非 headless 方式保存了主界面截图：

```text
tmp/screenshots/prefab-main-restart.png
```

当前仍会输出 Godot 对 `Image.load()` 直接载入 PNG 的导出警告，这与既有 MVP 源 PNG 载入策略一致，不影响本地验证。

## 13. 2026-05-23 screen split and LotteryDraw restart

按“界面一个文件”的方向开始拆分 Godot 脚本，避免 `main.gd` 继续膨胀：

```text
standalone/godot-mvp/scripts/main.gd
standalone/godot-mvp/scripts/screens/startup_screen.gd
standalone/godot-mvp/scripts/screens/home_screen.gd
standalone/godot-mvp/scripts/screens/gacha_screen.gd
```

当前分工：

- `main.gd`：保留数据读取、存档、路由、抽卡逻辑、通用 UI helper，以及暂未拆分的结果页/图鉴/角色详情/商店/任务/战役。
- `startup_screen.gd`：负责 `LaunchView`、预载入、`LoginView`、`LoadingView`。
- `home_screen.gd`：负责 `MainUIView` 第一屏。
- `gacha_screen.gd`：负责 `LotteryDrawMainView` 第一屏。

为避免 Windows 下中文注释和 UI 文案被误读，本轮给新增/常用脚本补了 UTF-8 标记：

```text
scripts/assets/export_unity_bundle_images.py
scripts/assets/inspect_unity_prefab_layout.py
standalone/godot-mvp/scripts/main.gd
standalone/godot-mvp/scripts/screens/startup_screen.gd
standalone/godot-mvp/scripts/screens/home_screen.gd
standalone/godot-mvp/scripts/screens/gacha_screen.gd
```

抽卡界面复刻重启依据：

```powershell
python scripts\assets\inspect_unity_prefab_layout.py `
  "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab" `
  "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab" `
  "Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab" `
  --repo-root . `
  --markdown docs\shaonv-lottery-prefab-layout-2026-05-23.md `
  --markdown-depth 3
```

输出：

```text
reverse-output/godot-layout-inspect/LotteryDrawMainView.layout.json
reverse-output/godot-layout-inspect/HeroRecruitView.layout.json
reverse-output/godot-layout-inspect/LotteryDrawFinishView.layout.json
docs/shaonv-lottery-prefab-layout-2026-05-23.md
```

本轮修正了 `LotteryDrawMainView` 的第一屏方向：卡池 tab 属于右侧 `pnlLeft/tabView`，单抽/十连按钮属于 `@LotteryDrawPanel/pnlRoot` 下方偏左区域，`pnlNormalWish/pnlEpicWish` 是祈愿角色位，不再沿用左侧卡池列表的错误布局。

补充修正：`startup_screen.gd` 的第一版只是结构占位，不是原始启动界面的完整复刻。根据 `LaunchView/LoginView/LoadingView` prefab 重新收敛后，已移除启动、登录、加载页里错误加入的看板角色展示：

- `LaunchView` 回到黑底/视频占位、跳过按钮的形态；真实 `launch.mp4` 仍未在当前资源中定位到。
- `LoginView` 使用 `login_bg_01.png`、`logo.png`、`login_btn_03.png`、`server_bg_03.png`，右侧保留公告/修复/账号/切换入口。
- `LoadingView` 使用底部进度条，不再显示角色。2026-05-24 复核后背景应改为 `loading_bg_01.png`，不是登录页的 `login_bg_01.png`。

本轮新增截图：

```text
tmp/screenshots/startup-launch-refine.png
tmp/screenshots/startup-login-refine.png
tmp/screenshots/startup-loading-refine.png
```

验证命令：

```powershell
python -m py_compile scripts\assets\inspect_unity_prefab_layout.py scripts\assets\export_unity_bundle_images.py
.\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
$env:SHAONV_MVP_START_VIEW='gacha'; .\Godot\Godot_console.exe --headless --path standalone\godot-mvp --quit-after 2
```

截图：

```text
tmp/screenshots/prefab-gacha-restart.png
```

## 14. 下一步

1. 用 Godot 编辑器检查布局并调整主题、字体、按钮样式。
2. 继续接入登录页按钮、服务器选择弹层、公告/修复弹层的真实 UI 切片。
3. 导出 `Prefabs/UI/MainUI/MainUIView` 的 RectTransform 与按钮图，替换当前 MainUIView 几何按钮。
4. 用真实掉落表替换当前 MVP 概率。
5. 将 `HeroRecruitView/LotteryDrawMainView/LotteryDrawFinishView` 的结构分析转成 Godot Control 节点重建清单。
6. 把抽卡结果演出、角色详情页、商店和图鉴筛选做成独立 scene，降低 `main.gd` 复杂度。
7. 将任务、邮件、每日补给拆成独立 scene，并继续把 `live_ops_mvp.json` 对齐到原 `QuestView/GameShopView/Welfare/Mail` 资源与文本。
