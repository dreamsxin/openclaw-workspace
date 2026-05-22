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

- 主界面：按原 `MainUIView` 分析重排为顶部玩家/资源栏、壁纸看板区、右侧玩法入口、底部功能栏、章节任务信息。
- 抽卡：按 `LotteryDrawMainView -> LotteryDrawPanel` 分析重排为左侧卡池 tab、中部 UP/保底信息、右侧角色展示、底部单抽/十连/概率/记录按钮。
- 结果页：按 `HeroRecruitView/LotteryRewardShowView` 职责拆分，显示主出货角色、稀有度标题、十连结果格、新角色和重复碎片，点击结果进入角色详情。
- 图鉴：角色收集状态、持有数量、重复碎片，点击进入角色详情。
- 角色详情：显示获得状态、碎片、资源路径和 Spine key，可设为看板。
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
| `data/gacha_pools_mvp.json` | 卡池、UP、消耗、保底 |
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

## 7. 下一步

## 7. 当前还原依据和缺口

本轮 Godot UI 还原依据：

- `docs/shaonv-hotfix-ui-lifecycle-analysis.md` 中 `MainUIView` 字段分组：`pnlPlayerInfo`、`_topBar`、`pnlFunny`、`pnlBottom`、`WallpaperPanel`、`btnDraw`、`btnPrayer`、`btnHero`、`btnBagpack`、`btnTask` 等。
- `MainUIView.InitPnlTask()` 中的章节任务刷新、领取事件和 `ReqGetChapterTask` 行为，被简化为本地 `TASKS` 表和 `claimed_tasks` 存档。
- `pnlCommercialization/btnWelfare/btnShop` 被简化为每日补给、邮件和商店入口。
- `docs/shaonv-p0-continuation-2026-05-22.md` 中抽卡调用链：`LotteryDrawMainView -> LotteryDrawPanel -> LotteryDrawModel -> LotteryDrawFinishView/HeroRecruitView`。
- `docs/shaonv-yooasset-physical-mapping-fix.md` 中已定位的抽卡 prefab 物理映射。
- 已导入 Godot 的 5 个代表角色 Spine 三件套中的 PNG，用作看板和抽卡展示。

当前仍未完全还原：

- 原 `MainUIView`、`LotteryDrawMainView` prefab 的完整 RectTransform 层级尚未转换为 Godot scene。
- 抽卡 UI 图集、按钮图、结果光效、音效仍未批量导入 Godot。
- Spine 运行时尚未接入，当前仍是 PNG 静态展示。
- 原游戏真实掉落表、商城/任务/邮件资源产出规则仍需继续补齐；当前任务/邮件/每日补给是可玩性 MVP 规则。

## 8. 下一步

1. 用 Godot 编辑器检查布局并调整主题、字体、按钮样式。
2. 接入 Spine Godot 运行方案，验证 `.skel.bytes + .atlas.txt + .png` 播放。
3. 将抽卡 UI 图集、结果光效和音效导入 Godot，并建立 Godot 资源命名规范。
4. 用真实掉落表替换当前 MVP 概率。
5. 将 `HeroRecruitView/LotteryDrawMainView/LotteryDrawFinishView` 的结构分析转成 Godot Control 节点重建清单。
6. 把抽卡结果演出、角色详情页、商店和图鉴筛选做成独立 scene，降低 `main.gd` 复杂度。
7. 将任务、邮件、每日补给拆成独立 scene，并继续把 `live_ops_mvp.json` 对齐到原 `QuestView/GameShopView/Welfare/Mail` 资源与文本。
