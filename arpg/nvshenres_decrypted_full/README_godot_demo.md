# Nvshen Godot 本地资源 Demo

工程目录：

```text
D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full
```

运行方式：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

本 Demo 的目标不是连接服务端，也不是复刻完整业务逻辑，而是基于已解密资源做一个本地可运行、可检查资源效果、可逐步还原界面的 Godot 工程。

## 当前入口

- `scenes/original_loading.tscn`：默认启动场景。
- 登录流程：启动加载页 -> 登录页 -> 选服页 -> 原始主城页。
- 主城页保留了导航按钮，可进入资源浏览器、Prefab 预览器和旧的浮岛主城预览。
- 主城底部导航第三个入口已按原始 `daohangPre.btn3/cm_tab_ZhaoHuan` 修正为“召唤”，点击进入本地抽卡页；仓库入口保留在右侧入口条。
- 资源浏览器支持图片、音频、文本、Prefab、Scene、Spine 索引查看。

## 已确认的主城资源链

不要把用户上传的 `主屏.jpg` 当作实际界面资源。它只适合作为参考截图。

`Prefab/mainpanel/MainPre` 不是完整“背景 + 角色 + UI”的静态页面，它主要描述主界面 UI 容器、按钮和若干入口节点。原游戏里背景和主城角色是运行时动态加载：

- `assets/main/index.js` 中默认 `_roleLhbody = "105004"`。
- `assets/main/index.js` 中默认 `_bgbody = 0`。
- `MainUIPanel.showBg` 按 `Prefab/bigImage/<id>` 加载背景 prefab。
- `HeroLhPanel.showHero` 创建 `RoleLh`，并按英雄 `headID/bodyID` 加载立绘。
- `RoleLh` 使用 `Prefab/HerolhPrefab/<bodyID>`，例如 `Prefab/HerolhPrefab/105004`。

结论：主城还原应分三层处理：

1. `MainPre.json` 负责 UI prefab 层。
2. `Prefab/bigImage/*` 负责可选背景层。
3. `Prefab/HerolhPrefab/*` 负责可选角色 Spine 立绘层。

## Spine 现状

角色立绘资源不是完整 PNG 立绘，而是 Spine 数据：

- 示例：`Prefab/HerolhPrefab/105004`
- Skeleton 名称：`LaRuiOu_LH`
- 贴图示例：`assets/resources/native/96/964573c8-6b8e-41e3-8fe1-ec4de01897e0.png`
- 动画名包括 `idle`、`show`

Godot 当前工程已接入项目内轻量 Spine runtime，用于本地预览角色立绘和部分界面特效。资源浏览器也支持 Spine 索引查看：

- `data/spine_preview_index.json`
- 显示 skeleton 名称、Spine 版本、骨骼数、slot 数、动画列表、atlas 贴图。
- 贴图可预览；已导出的 runtime JSON 可在 Spine Viewer 中播放。

当前主城默认角色已用 `105004` Spine 播放 `idle`，点击角色可切换可用动作；这仍是轻量 runtime，不等于官方 Spine Runtime，复杂约束和裁剪仍需继续补齐。

## Prefab 还原注意事项

早期错误来源：

- 不能递归抓 JSON 里的任意整数引用当作 SpriteFrame，会把 material、按钮状态或其它引用误当贴图。
- 不能把 Cocos 子节点坐标当作根坐标直接画。Prefab 节点坐标是本地坐标，必须根据 `_parent` 累加父节点变换。
- 不能把九宫格、动态面板、隐藏节点当普通贴图拉伸显示。

当前导出器已修正：

- `tools/export_cocos_prefab_layout.py`
- 解析 `cc.Sprite._spriteFrame`
- 解析 `cc.Button` 的状态 sprite
- 解析 `sp.Skeleton._N$skeletonData`
- 导出 `parent_index`、`active`、`position`、`global_position`
- 隐藏节点 `_active=false` 在 Godot 预览中跳过

## 资源与清单

- `data/catalog.json`：总资源索引。
- `data/prefabs.csv`：原始 prefab 清单。
- `data/prefab_layouts.json`：已导出的核心 prefab 布局清单。
- `data/prefab_restore_inventory.csv`：整理后的 prefab 还原清单。
- `data/prefab_restore_inventory.md`：按分类和优先级整理的 prefab 清单。
- `data/spine_preview_index.json`：Spine 预览索引。
- `RESTORE_LOGIN_TO_HOME.md`：登录页 -> 选服页 -> 主页面的专项还原梳理。
- `SOURCE_DIRECTORY_GUIDE.md`：原始目录、解密目录、Cocos bundle、反编译源码和工具脚本的作用索引。

当前统计：

```text
prefabs: 1007
spine: 993
png: 5268
jpg: 98
mp3: 1061
json: 18458
```

优先还原的界面：

- `Prefab/login/LoginPre`
- `Prefab/login/pfLoginPanelPre`
- `Prefab/mainpanel/MainPre`
- `Prefab/HeroPanel/HeroMainPre`
- `Prefab/BagPanel/BagPre`
- `Prefab/DrawCard/drawCardPre`
- `Prefab/Battle/battle`
- `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre`
- `Prefab/Guild/GuildMainPre`
- `Prefab/JingjiPrefab/JingjiPre`
- `Prefab/SkyCityPanel/SkyCityPre`

## 当前限制

- 主城页已改为 `MainPre` UI 层 + 可切换背景 + 可切换角色预览，但还不是完整 Cocos 运行时复刻。
- Spine 角色可用轻量 runtime 播放已导出的 runtime JSON，但复杂约束、clipping/path 等仍未完整支持。
- Label、ScrollView、Layout、Widget、九宫格 Sprite 仍需要继续映射。
- 一些界面资源由脚本或子 prefab 动态挂载，不能只看父 prefab 的贴图数量判断是否缺资源。
