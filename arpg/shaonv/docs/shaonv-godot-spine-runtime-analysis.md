# Godot Spine Runtime 接入分析

日期：2026-05-22

## 1. 分析范围

本轮分析目录：

```text
D:\work\openclaw-workspace\arpg\shaonv\spine-runtimes-4.3
```

该目录包含官方 Spine runtimes 源码，其中 `spine-runtimes-4.3\spine-runtimes-4.3\spine-godot` 是 Godot runtime/GDExtension 源码。

## 2. 关键结论

`spine-godot` 可以在 Godot 中直接播放 Spine 动画，但当前 MVP 还没有真正接入该 runtime。

原因：

- 当前 `standalone/godot-mvp` 工程内没有 `.gdextension` 文件，也没有 `.godot/extension_list.cfg`。
- 当前用户下载的插件 zip 位于 `tools/spine-godot/spine-godot-extension-4.3-4.6.2-stable.zip`，尚未作为可运行扩展安装到 Godot 项目内。
- 之前命令行 `ClassDB` 探测 `SPINE_CLASS_COUNT=0`，说明扩展类没有注册成功；结合当前工程文件判断，主要问题不是类名猜错，而是 GDExtension 没有被 Godot 加载。
- 官方 README 写明 `spine-godot works with data exported from Spine 4.3.xx`。本游戏当前验证角色的 `.skel.bytes` 版本是 Spine `4.2.26`，与 4.3 runtime 存在版本风险。当前 baked 路线使用 `@esotericsoftware/spine-core@4.2.43`，版本更匹配。

## 3. Godot Runtime 注册的核心类

`spine_godot/register_types.cpp` 注册了这些关键类：

```text
SpineAtlasResource
SpineSkeletonFileResource
SpineSkeletonDataResource
SpineSprite
SpineMesh2D
SpineSkeleton
SpineAnimationState
SpineAnimation
SpineTrackEntry
SpineSlotNode
SpineBoneNode
SpineSkin
SpineAttachment
SpineEvent
```

`SpineSprite` 是 Godot 里真正显示和播放 Spine 的节点，继承 `Node2D`。

## 4. 资源加载机制

`SpineSkeletonFileResource` 支持读取：

```text
.spjson
.spskel
.spine-json
.skel
```

源码中 `load_from_file(path)` 对 `.spjson/.spine-json` 按 JSON 解析，其他路径按 binary skeleton 解析。

当前 MVP 资源文件名是：

```text
hero_016.skel.bytes
hero_016.atlas.txt
hero_016.png
```

因此如果直接走插件自动资源加载，建议额外生成或复制：

```text
hero_016.skel
hero_016.atlas
hero_016.png
```

`SpineAtlasResource` 有两个加载路径：

- `load_from_atlas_file(path)`：直接读取原始 `.atlas` 文本，并加载 atlas 中引用的 PNG。
- `load_from_file(path)`：读取 Godot 保存后的 `.spatlas` JSON 包装资源，字段包括 `source_path`、`atlas_data`、`normal_texture_prefix`、`specular_texture_prefix`。

官方编辑器导入插件会把原始 `.atlas` 导入保存为 `.spatlas`。

## 5. 最小 GDScript 使用方式

如果 GDExtension 已正确加载，理论上可以用脚本手动创建：

```gdscript
var atlas := SpineAtlasResource.new()
var atlas_error := atlas.load_from_atlas_file("res://assets/spine/hero_016/hero_016.atlas")

var skeleton_file := SpineSkeletonFileResource.new()
var skeleton_error := skeleton_file.load_from_file("res://assets/spine/hero_016/hero_016.skel")

var skeleton_data := SpineSkeletonDataResource.new()
skeleton_data.set_atlas_res(atlas)
skeleton_data.set_skeleton_file_res(skeleton_file)
skeleton_data.update_skeleton_data()

var sprite := SpineSprite.new()
sprite.set_skeleton_data_res(skeleton_data)
sprite.get_animation_state().set_animation("wait", true, 0)
add_child(sprite)
```

`SpineAnimationState` 的关键 API：

```text
set_animation(animation_name, loop=true, track_id=0)
add_animation(animation_name, delay, loop=true, track_id=0)
clear_track(track_id)
clear_tracks()
set_empty_animation(track_id, mix_duration)
get_track(track_id)
```

`SpineSprite` 的关键 API：

```text
set_skeleton_data_res(resource)
get_animation_state()
get_skeleton()
update_skeleton(delta)
get_global_bone_transform(bone_name)
set_global_bone_transform(bone_name, transform)
new_skin(name)
```

## 6. 当前 MVP 推荐策略

短期继续使用 baked Spine 路线。

理由：

- 游戏资源是 Spine `4.2.26`，当前 baked 工具链使用 `spine-core@4.2.43`，兼容性已经通过 5 个代表角色验证。
- Godot 4.6 插件 zip 是 `spine-godot 4.3`，直接加载 4.2 skeleton 可能失败。
- baked JSON 已能稳定显示角色待机动画，并且不依赖 Godot 编辑器导入缓存。

中期可以并行验证插件路线，但不要替换 MVP 主路径：

1. 解压 `tools/spine-godot/spine-godot-extension-4.3-4.6.2-stable.zip` 到 `standalone/godot-mvp/bin`。
2. 确认项目内存在 `res://bin/spine_godot_extension.gdextension`。
3. 用 Godot 编辑器打开项目，让扩展进入 `.godot/extension_list.cfg`。
4. 用 ClassDB 探测确认 `SpineSprite`、`SpineAtlasResource`、`SpineSkeletonFileResource`、`SpineSkeletonDataResource` 注册成功。
5. 为 `hero_016` 生成 `.skel/.atlas` 副本。
6. 用上面的 GDScript 最小代码创建 `SpineSprite` 并播放 `wait`。
7. 如果 4.2 skeleton 被 4.3 runtime 拒绝，插件路线暂停，继续 baked 路线。

## 7. 对单机版还原的影响

如果插件路线可用：

- 可以运行时切换动画、混合动画、换 skin、挂接 `SpineSlotNode/SpineBoneNode`。
- 更适合后续触摸互动、换装、抽卡登场演出和角色详情页。

如果插件路线不可用：

- 当前 baked 路线仍足以支撑 MVP 的主界面、抽卡、图鉴展示。
- 需要为每个角色预烘焙 `wait/wait1/show/special` 等关键 clip。
- 后续要做触摸互动时，需要再增加“预烘焙动画切换”或回到插件/自研 runtime。
