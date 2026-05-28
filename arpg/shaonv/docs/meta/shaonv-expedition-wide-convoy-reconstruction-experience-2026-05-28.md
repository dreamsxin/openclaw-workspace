# 塵世探秘宽屏与 5 人移动队伍复刻经验

生成时间：2026-05-28。

本文记录本轮 `ExpeditionMainView / ExpeditionMapView` 继续复刻时确认的实现经验，重点是 `1670x750` 宽屏锚点、5 人 Q 版移动队伍、HeroQ baked Spine 的 run/standby clip 重烘，以及后续复刻时容易误判的点。

## 结论摘要

- 项目当前全局画布已经是 `1670x750`，塵世探秘内部不能继续写死 `1280x720`。
- `ExpeditionMainView.prefab` 的锚点仍可沿用原始 `anchoredPosition`，但 Godot 位置必须用当前 `app.CANVAS_WIDTH/HEIGHT` 换算。
- 首屏移动角色不是单人占位，也不应保留伪载具底座；本轮实现为 5 人 Q 版队伍，沿 AFKMap 路径移动。
- `HeroQ__hero_053q_s01` 是本轮指定重点资源，必须进入队伍并优先播放 `run`。
- “skeleton 里有 run”不等于 Godot 当前 baked JSON 能播 run；Godot MVP 播放的是 `*.baked.json` 的 `clips` 字段，缺 clip 时需要重烘。
- 本轮重烘了常用/本地队伍会触达的 HeroQ baked，使它们包含 `run,standby,back,attack`。

## 代码位置

- [expedition_screen.gd](D:/work/openclaw-workspace/arpg/shaonv/standalone/godot-mvp/scripts/screens/expedition_screen.gd)

核心入口：

- `_anchor_left_top / _anchor_right_top / _anchor_left_bottom / _anchor_right_bottom`
- `_map_viewport_size`
- `_draw_main_afk_move_layer`
- `_draw_expedition_team_convoy`
- `_expedition_team_heroes`
- `_afk_hero_baked_candidates`
- `_add_map_move_tool_actor`
- `_draw_map_side_buttons`

## 1670x750 锚点换算

不要把 prefab 坐标先手工换成 `1280x720` 再平移。保留 Unity prefab 的锚点语义，在 Godot 里统一换算：

```gdscript
func _anchor_right_top(anchor: Vector2, size: Vector2) -> Vector2:
	return Vector2(float(app.CANVAS_WIDTH) + anchor.x - size.x, -anchor.y)

func _anchor_right_bottom(anchor: Vector2, size: Vector2) -> Vector2:
	return Vector2(float(app.CANVAS_WIDTH) + anchor.x - size.x, float(app.CANVAS_HEIGHT) - anchor.y - size.y)
```

典型结果：

| Prefab 节点 | Anchor | Size | anchoredPosition | 1670x750 Godot pos |
|---|---|---:|---:|---:|
| `imgMap` | right-top | `160x160` | `(-64,-23)` | `(1446,23)` |
| `btnFight` | right-bottom | `160x160` | `(-64,23)` | `(1446,567)` |
| `pnlReward/btnReward` | right-bottom | `172x172` | `(-253,23)` | `(1245,555)` |
| `btnDispatch` | right-bottom | `90x90` | `(-635,27)` | `(945,633)` |
| `btnHero` | right-bottom | `90x90` | `(-535,27)` | `(1045,633)` |
| `btnMarch` | right-bottom | `90x90` | `(-435,27)` | `(1145,633)` |
| `btnStronger` | left-bottom | `152x152` | `(64,24)` | `(64,574)` |
| `btnCrossReward` | left-top | `352x70` | `(64,-100)` | `(64,100)` |

地图页的 viewport 也要用 `app.CANVAS_SIZE`，否则拖拽边界和初始聚焦仍会按旧 1280 宽度截断。

## 5 人队伍规则

本轮队伍生成规则：

1. 若存在可选 `save.expedition_team_ids`，先按该列表去重取英雄。
2. 若没有显式队伍，把 `240101 / hero_053` 作为尘世探秘默认领队先入队。
3. 再追加当前看板 `selected_hero_id`。
4. 再追加已拥有英雄。
5. 再用默认列表 `[240101, 240055, 240061, 240092, 240037]` 补足。
6. 如果显式队伍里没有 `240101`，最终仍会把 `hero_053` 补进 5 人队伍。

这样既保留本地存档状态，也满足本轮指定的 `HeroQ__hero_053q_s01` 出场要求。

## HeroQ baked Spine 经验

### 候选顺序

Q 版移动队伍的 baked 优先级：

1. `res://assets/spine/HeroQ__<spine>q_s01/HeroQ__<spine>q_s01.baked.json`
2. `res://assets/spine/HeroQ__<spine>q/HeroQ__<spine>q.baked.json`
3. `hero_053` 特例 fallback：`Hero__hero_053_s02h / Hero__hero_053_s02`
4. 普通本体 fallback：`<spine>h / <spine>`
5. PNG / hero thumb fallback

调用 `BAKED_SPINE_CANVAS` 后要显式：

```gdscript
canvas.set_baked_path(baked_path, clip_name)
canvas.set_playing(true)
canvas.set_playback_speed(1.0)
```

### 关键坑：skeleton animation 不等于 baked clips

很多 Q 版资源的 skeleton 里有 `run` 和 `standby`，但旧 `*.baked.json` 只烘了 `attack,attack1,back,death`。

表现：

- 代码传入 `run`，但 `_active_clip()` 找不到时会退到 baked JSON 的第一个 clip。
- 视觉上会变成攻击动作，或者被候选过滤后退回普通 `hero_xxxh` / 静态图。

处理方式：

```powershell
$node='C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
& $node scripts/spine/bake_hero_spine_preview.mjs `
  --dir=assets/spine/HeroQ__hero_053q_s01 `
  --key=HeroQ__hero_053q_s01 `
  --fps=8 `
  --max-duration=1.2 `
  --max-clips=4 `
  --clips=run,standby,back,attack
```

本轮已确认这些 baked 包含 `run,standby,back,attack`：

- `HeroQ__hero_010q_s01`
- `HeroQ__hero_016q_s01`
- `HeroQ__hero_018q_s01`
- `HeroQ__hero_021q`
- `HeroQ__hero_022q`
- `HeroQ__hero_026q`
- `HeroQ__hero_037q`
- `HeroQ__hero_053q_s01`

其中 `hero_021/026/037` 是本地存档当前队伍会触达的资源，虽然不在默认 5 人列表里，也需要重烘，否则启动验证会看到它们退回普通 `hero_xxxh`。

## 地图页队伍表现

首屏和地图页共用 `_draw_expedition_team_convoy`：

- 首屏：传入 `run`，根节点沿 `MAIN_AFK_PATH_POINTS` tween。
- 地图页 `pnlMoveTool`：传入 `standby`，只保留轻微浮动。
- 两处都只保留地面阴影、点击区、提示文本，不再绘制伪载具底座。

## 验证标准

静态检查：

```powershell
.\Godot\Godot_console.exe --headless --path standalone/godot-mvp --check-only --quit
git diff --check -- standalone/godot-mvp/scripts/screens/expedition_screen.gd
```

启动验证：

```powershell
.\Godot\Godot_console.exe --headless --path standalone/godot-mvp --quit
$env:SHAONV_MVP_START_VIEW='expedition'
.\Godot\Godot_console.exe --headless --path standalone/godot-mvp --quit
Remove-Item Env:\SHAONV_MVP_START_VIEW
```

`SHAONV_MVP_START_VIEW=expedition` 日志里应看到 5 个 `HeroQ__...` baked 被加载，并且包含：

```text
[baked-canvas] loaded res://assets/spine/HeroQ__hero_053q_s01/HeroQ__hero_053q_s01.baked.json
```

如果看到 `hero_021h`、`hero_026h`、`hero_037h` 这类普通本体资源，说明对应 Q 版 baked 还没有可用的目标 clip，或队伍候选过滤失败。

## 后续建议

- 后续新增可编辑阵容时，优先写入可选 `save.expedition_team_ids`，不要改变现有存档结构的必需字段。
- 新上队伍英雄前先用 PowerShell 检查 `clips` 字段，而不是只看 `skeleton.animations`。
- 如果继续复刻真实寻路，需要另做路径节点和队形朝向；本轮只闭合静态路径 tween、真实 Q 版资源和主流程点击。
