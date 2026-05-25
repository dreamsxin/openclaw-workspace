# 角色战斗动画预览器与资源关系

更新时间：2026-05-25

## 结论

- 角色战斗侧没有发现 `Assets/Game/RawAssets/Spine/Hero/hero_xxxq` 这类独立战斗 Spine。
- 战斗动作资源主要由三组资源组成：
  - `Assets/Game/RawAssets/Prefabs/3d/hero_xxxq_*.prefab`
  - `Assets/Game/RawAssets/Prefabs/Skill/Hero_xxxQ*.prefab`
  - `Assets/Game/RawAssets/Sound/Battle/hero_xxxq_*.wav`
- 中间角色预览仍使用本体 Spine baked JSON，例如 `hero_037`，战斗资源列表使用同编号 `hero_037q` 关联。

## 已新增文件

- `scripts/assets/export_hero_battle_preview_index.py`
  - 从 `standalone/godot-mvp/data/hero_resource_map.json` 和 `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` 生成战斗资源索引。
- `standalone/godot-mvp/assets/battle/hero_battle_resources.json`
  - Godot 预览器直接读取的导出结果。
  - 当前统计：68 个角色、450 个 3D prefab、137 个 Skill prefab、285 个战斗音效、68 个本体 baked 预览。
- `standalone/godot-mvp/scripts/hero_battle_preview.gd`
  - 专门的战斗动画/战斗资源预览器。
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

## 后续拆解方向

- 预览器右侧已经列出 prefab 和音效的 bundle 物理路径，下一步可继续解析 prefab 内部节点、材质、贴图引用，把战斗特效从“资源列表”推进到“可视化预览”。
- 如果要恢复真正战斗动作，需要优先解析 `Prefabs/3d/hero_xxxq_*` 的节点层级，而不是继续寻找 `hero_xxxq` Spine。
