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

- 主界面：货币、看板角色、入口按钮。
- 抽卡：普通/高级/进阶/源神祈願池切换，单抽和十连，显示当前卡池、UP、保底和消耗。
- 结果页：显示抽卡结果卡片、新角色和重复，点击结果可设为看板并回主界面。
- 图鉴：角色收集状态、持有数量、重复碎片，点击进入角色详情。
- 角色详情：显示获得状态、碎片、资源路径和 Spine key，可设为看板。
- 记录：抽卡历史。
- 商店：源石兑换喚靈券，提供单机测试补给入口。
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
  "selected_hero_id": 240065,
  "active_pool_id": "advanced"
}
```

## 5. 资源

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

1. 用 Godot 编辑器检查布局并调整主题、字体、按钮样式。
2. 接入 Spine Godot 运行方案，验证 `.skel.bytes + .atlas.txt + .png` 播放。
3. 将抽卡 UI 图集、结果光效和音效导入 Godot，并建立 Godot 资源命名规范。
4. 用真实掉落表替换当前 MVP 概率。
5. 将 `HeroRecruitView/LotteryDrawMainView/LotteryDrawFinishView` 的结构分析转成 Godot Control 节点重建清单。
6. 把抽卡结果演出、角色详情页、商店和图鉴筛选做成独立 scene，降低 `main.gd` 复杂度。
7. 增加任务/邮件/每日补给，替代当前测试补给按钮。
