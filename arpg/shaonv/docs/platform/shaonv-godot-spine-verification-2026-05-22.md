# 少女回战 Godot MVP Spine 验证记录

日期：2026-05-22

## 1. 验证目标

本轮目标是验证 `hero_016` 是否能在 Godot MVP 中使用原游戏 Spine 资源播放待机动画：

```text
standalone/godot-mvp/assets/spine/hero_016/hero_016.skel.bytes
standalone/godot-mvp/assets/spine/hero_016/hero_016.atlas.txt
standalone/godot-mvp/assets/spine/hero_016/hero_016.png
```

结论：可以播放，但当前采用的是 `merge` 项目已验证过的预烘焙帧方案，而不是直接接入 Godot Spine GDExtension。

## 2. merge 项目的 Spine 实现方式

分析 `D:\work\openclaw-workspace\arpg\merge` 后确认，merge 的可运行 Godot 实现没有直接依赖 Spine GDExtension。它的路径是：

1. 使用 Node.js + `@esotericsoftware/spine-core@4.2.43` 读取 `.skel.bytes`、`.atlas.txt`、atlas PNG。
2. 在脚本中逐帧采样 Spine animation，导出 Godot 友好的 baked JSON。
3. Godot 脚本读取 baked JSON，按 attachment 的 `vertices / triangles / uvs` 调用 `draw_polygon()` 绘制。

关键文件：

```text
D:\work\openclaw-workspace\arpg\merge\scripts\reverse\bake_character_spine_previews.mjs
D:\work\openclaw-workspace\arpg\merge\scripts\reverse\bake_kokomi_loading_spine.mjs
D:\work\openclaw-workspace\arpg\merge\godot-project\scripts\spine_baked_preview_canvas.gd
D:\work\openclaw-workspace\arpg\merge\docs\reverse-godot\reverse-audit-knowledge.md
```

关键渲染规则：

- 使用 Spine runtime 输出的 mesh triangles，不自行重排顶点。
- UV 是 normalized `0..1`，传给 Godot `draw_polygon()` 时不要乘 atlas 像素尺寸。
- Spine 世界坐标进入 Godot canvas 时需要翻转 Y。
- atlas page 必须是完整 `Texture2D` 导出的页面，不能用 Unity Sprite 裁剪图替代。

## 3. hero_016 资源验证结果

`hero_016.skel.bytes` 是 Spine binary：

```text
Spine version: 4.2.26
hash: -c8db683329d1b5a
width: 1021.847
height: 1301.786
bones: 272
slots: 83
skins: default
animations: wait, wait1
```

注意：该角色没有名为 `idle` 的动画。`wait` 是当前可用的待机等价动画，`wait1` 是第二个待机/展示片段。

## 4. Godot Spine GDExtension 探测

用户已下载：

```text
D:\work\openclaw-workspace\arpg\shaonv\tools\spine-godot-extension-4.3-4.6.2-stable.zip
```

该 zip 内包含：

```text
bin/spine_godot_extension.gdextension
bin/windows/libspine_godot.windows.editor.x86_64.dll
bin/windows/libspine_godot.windows.template_debug.x86_64.dll
bin/windows/libspine_godot.windows.template_release.x86_64.dll
```

将 Windows GDExtension 文件放入 Godot MVP 后，用命令行脚本查询 `ClassDB`，没有发现任何已注册的 Spine 类：

```text
SPINE_CLASS_COUNT=0
SpineSprite=false
SpineSkeletonDataResource=false
SpineAtlasResource=false
SpineAnimationState=false
SpineSlotNode=false
```

因此本轮没有把 GDExtension 文件提交到 MVP 工程。后续如果继续走插件路线，需要用 Godot 编辑器正式打开项目确认 GDExtension 是否被加载，并核对该版本实际注册的类名和资源导入流程。

## 5. 本轮已接入 MVP 的实现

新增本地烘焙依赖：

```text
tools/spine-baker-js/package.json
tools/spine-baker-js/package-lock.json
tools/spine-baker-js/.gitignore
```

新增烘焙脚本：

```text
scripts/spine/bake_hero_spine_preview.mjs
```

新增 baked 动画数据：

```text
standalone/godot-mvp/assets/spine/hero_001/hero_001.baked.json
standalone/godot-mvp/assets/spine/hero_003Dh/hero_003Dh.baked.json
standalone/godot-mvp/assets/spine/hero_005/hero_005.baked.json
standalone/godot-mvp/assets/spine/hero_016/hero_016.baked.json
standalone/godot-mvp/assets/spine/hero_017/hero_017.baked.json
```

新增 Godot baked Spine 渲染器：

```text
standalone/godot-mvp/scripts/spine_baked_preview_canvas.gd
```

修改主界面角色绘制：

```text
standalone/godot-mvp/scripts/main.gd
```

`main.gd` 现在会优先查找：

```text
res://assets/spine/<hero>/<hero>.baked.json
```

如果存在 baked JSON，则使用 `spine_baked_preview_canvas.gd` 播放动画；否则退回原始 PNG 静态展示。

## 6. 使用命令

安装烘焙依赖：

```powershell
cd D:\work\openclaw-workspace\arpg\shaonv\tools\spine-baker-js
npm install
```

烘焙当前 MVP 的五个代表角色：

```powershell
cd D:\work\openclaw-workspace\arpg\shaonv
foreach ($hero in @('hero_001','hero_003Dh','hero_005','hero_016','hero_017')) {
  node .\scripts\spine\bake_hero_spine_preview.mjs --hero=$hero --fps=8 --max-duration=1.2 --max-clips=2
}
```

代表输出：

```text
baked hero_016: wait, wait1 -> standalone\godot-mvp\assets\spine\hero_016\hero_016.baked.json
```

运行截图验证：

```powershell
$env:SHAONV_MVP_CAPTURE = "D:\work\openclaw-workspace\arpg\shaonv\tmp\screenshots\godot-hero016-baked.png"
.\Godot\Godot_console.exe --path standalone\godot-mvp --scene res://scenes/main.tscn --rendering-method mobile --quit-after 3
```

截图结果：

```text
tmp/screenshots/godot-hero016-baked.png
```

画面中 `hero_016` 已经不是 atlas 散图，而是按 Spine attachment 组合后的角色立绘。

## 7. 对单机版实现的影响

当前判断：Godot 继续可行，不必为了 Spine 立即切回 Unity。

短期 MVP 推荐继续使用 baked Spine 路线：

- 优点：不依赖 Godot 插件导入链，源码运行、截图验证、git 同步都稳定。
- 缺点：运行时不能动态混合动画、换装、骨骼交互；需要预先烘焙要展示的 animation clip。

对抽卡卖点来说，MVP 首批只需要：

- 看板待机：每个重点角色烘焙 `wait/idle/show` 等 1 到 2 个 clip。
- 抽卡结果：烘焙登场展示 clip 或使用静态立绘加 Godot 粒子光效。
- 图鉴展示：复用待机 baked clip，后续再补语音、背景、触摸反馈。

后续若要更接近原游戏，再评估 GDExtension 或自建运行时骨骼播放。
