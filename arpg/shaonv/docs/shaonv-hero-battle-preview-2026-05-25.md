# 角色战斗动画预览器与资源关系

更新时间：2026-05-26

## 结论

- 角色战斗侧没有发现 `Assets/Game/RawAssets/Spine/Hero/hero_xxxq` 这类独立战斗 Spine。
- 2026-05-26 复核物理资源表后，仍未发现常规玩家角色 `hero_xxxq` 独立 Spine；仅看到特殊资源如 `hero_017_qi`、怪物 `monster_005q`。因此不要把“战斗 qKey”误解为一套可直接播放的角色 Spine。
- 战斗动作资源主要由三组资源组成：
  - `Assets/Game/RawAssets/Prefabs/3d/hero_xxxq_*.prefab`
  - `Assets/Game/RawAssets/Prefabs/Skill/Hero_xxxQ*.prefab`
  - `Assets/Game/RawAssets/Sound/Battle/hero_xxxq_*.wav`
- 中间角色预览仍使用本体 Spine baked JSON，例如 `hero_037`，战斗资源列表使用同编号 `hero_037q` 关联。
- 当前可预览的本体 baked Spine 已齐：索引统计 `68/68` 个角色有 `bakedExists=true`。

## 已新增文件

- `scripts/assets/export_hero_battle_preview_index.py`
  - 从 `standalone/godot-mvp/data/hero_resource_map.json` 和 `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` 生成战斗资源索引。
- `standalone/godot-mvp/assets/battle/hero_battle_resources.json`
  - Godot 预览器直接读取的导出结果。
  - 当前统计：68 个角色、450 个 3D prefab、137 个 Skill prefab、285 个战斗音效、68 个本体 baked 预览。
- `standalone/godot-mvp/scripts/hero_battle_preview.gd`
  - 专门的战斗动画/战斗资源预览器。
  - 2026-05-26 增强为接近 `spine_browser.tscn` 的浏览器：左侧搜索角色/ID/qKey，支持“只看缺失”，右侧可按全部、3D Prefab、Skill Prefab、Battle 音效筛选，点击资源条目查看 address 与物理 bundle 路径。
- `standalone/godot-mvp/scenes/hero_battle_preview.tscn`
  - 可直接启动的 Godot 场景。

## 使用方式

刷新索引：

```powershell
& 'C:\Users\admin\AppData\Local\Python\pythoncore-3.14-64\python.exe' scripts\assets\export_hero_battle_preview_index.py
```

打开预览场景：

```powershell
.\Godot\Godot_console.exe --path standalone/godot-mvp --scene res://scenes/hero_battle_preview.tscn --rendering-method mobile
```

指定默认角色可设置环境变量：

```powershell
$env:SHAONV_MVP_HERO='hero_037'
```

自动截图回归：

```powershell
$env:SHAONV_MVP_HERO='hero_037'
$env:SHAONV_MVP_CAPTURE='D:\work\openclaw-workspace\arpg\shaonv\tmp\screenshots\hero-battle-preview-enhanced.png'
.\Godot\Godot_console.exe --path standalone/godot-mvp --scene res://scenes/hero_battle_preview.tscn --rendering-method mobile --quit-after 3
```

本轮验证：

- 重新执行 `python scripts/assets/export_hero_battle_preview_index.py`，输出仍为 `68 heroes, 450 3d prefabs, 137 skill prefabs, 285 sounds, 68 baked previews`。
- 截图验证 `tmp/screenshots/hero-battle-preview-enhanced.png`，`hero_037` 可播放本体 baked Spine，并列出 `hero_037q` 的 3D prefab、Skill prefab 与 Battle wav。

## 后续拆解方向

- 预览器右侧已经列出 prefab 和音效的 bundle 物理路径，下一步可继续解析 prefab 内部节点、材质、贴图引用，把战斗特效从“资源列表”推进到“可视化预览”。
- 如果要恢复真正战斗动作，需要优先解析 `Prefabs/3d/hero_xxxq_*` 的节点层级，而不是继续寻找 `hero_xxxq` Spine。
