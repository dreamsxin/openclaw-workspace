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
- 原始 Cocos 启动入口是 `assets/src/settings.js` 的 `Scene/updataScene.fire`，随后 `GameWorld` 打开 `LoadingPanelNode`、预加载 `pfLoginPanelPre/MainPre/daohangPre` 等公共资源，再走 `PFLoginPanel` 选服/开始游戏。当前 Godot 流程是离线简化版，缺少热更新、公告、隐私/适龄提示、真实服务器请求和连接握手。
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

主屏角色坐标链记录：

- `MainUIPanel` 默认 `_roleLhbody = "105004"`，`onShow()` 调用 `showLh(this.roleLhbody)`。
- `showLh()` 通过 `RoleLh` 动态加载 `Prefab/HerolhPrefab/105004`，并把实例直接挂到 `MainPre` 的 `herolh` 全屏节点。
- `MainPre.herolh` 在 Cocos 中是 `(0,0)`、`1280x720`、锚点 `(0.5,0.5)`，换算到 Godot 设计分辨率后根原点为屏幕中心 `(640,360)`。
- `Prefab/HerolhPrefab/105004` 内真正的 Skeleton 子节点本地坐标是 `(-68,-333)`、scale 为 `(1,0.95)`，Godot 侧需要换算成屏幕偏移 `(-68,+333)` 后再绘制。
- 因此主城默认 105004 不能再用矩形 fit 居中，否则角色会整体放大并向上裁切；当前 `original_home_screen.gd` 已按 prefab 子节点偏移放置。

主屏红点资源记录：

- 红点节点名通常是 `hongdian` / `cm_icon_HongDian`，不能直接使用 `MainPre.json` 某些 `hongdian` 导出的整图路径；这些节点在压缩 prefab 中容易被误解析成父按钮 SpriteFrame。
- 可稳定复用的真实 SpriteFrame 来自 `MoneyItemPre`：`assets/resources/native/18/18b29ae48.png`，rect `[375,295,31,31]`，sprite 名 `cm_icon_HongDian`。
- `original_home_screen.gd` 当前统一通过 `_add_red_dot()` 裁剪该 SpriteFrame，替换早期纯红色方块。

主屏顶部资源条记录：

- `DaohangPanel.creatMoney()` 运行时实例化两个 `MoneyItemPre`：`money2` 金币 x=319，`money1` 钻石 x=521，父节点是 `moneyBox`。
- `MoneyItemPre.btnAdd` 使用 `image/common/cm_btn_JiaHao`，SpriteFrame 为 `assets/resources/native/15/15a1d9111.png` rect `[996,828,24,24]`。

主屏商会/商店入口记录：

- `assets/main/index.js:35031` 附近：`MainUIPanel.openShop()` 调用 `PanelManager.openShop(ShopPanel.SHOP_TYPE_BLACKMARKET, MainUIPanel.instance)`。
- `assets/main/index.js:144648` 附近：`ShopPanel.preUrl = "Prefab/Shop/ShopPre"`，黑市商店类型常量 `SHOP_TYPE_BLACKMARKET = 1`。
- `data/prefabs.csv` 中 `Prefab/Shop/ShopPre` 对应 import `assets/resources/import/7c/7c718dca-b02d-4286-8545-996490fc0bc7.json`。
- `tools/export_cocos_prefab_layout.py` 已把 `商店` 加入核心 prefab 导出；`data/prefab_layouts/ShopPre.json` 当前导出 67 个节点、7 个贴图节点。
- `ShopPre` 的动态子 prefab 已继续导出：`ShopItemPre.json`、`GoodsItemPre.json`、`ShopBuyEquitPre.json`，用于还原商店页签、商品卡和购买确认框。
- `tools/inspect_prefab_layout.py 商店 --limit 25` 可快速打印 `ShopPre` 的贴图/文本/Mask 节点和 `ShopCom` 字段绑定。
- 已新增 `scenes/original_shop_panel.tscn` 和 `scripts/original_shop_panel.gd`。主屏顶部 `SHOP` 和右侧 `商会` 入口现在进入独立商店页；Prefab 按钮仍可回看原始 `ShopPre` 布局。
- 独立商店页按 `ShopPanel.setData()` 的运行逻辑手工实现：顶部货币条、基础/战斗商城主页签、右侧商店类型、两列商品列表、刷新条和本地购买弹窗；商品图标从 `data/equipment_icon_index.json` 读取真实 SpriteFrame，商品卡尺寸和主要元素坐标参考 `GoodsItemPre`，购买确认框参考 `ShopBuyEquitPre`。
- 商店页已继续接入子 prefab 的真实 SpriteFrame：`ShopItemPre` 的右侧页签图标，`GoodsItemPre` 的折扣/稀有标签，`ShopBuyEquitPre` 的购买确认背景、标题线、加减按钮、滑条和绿色确认按钮。按钮文字不要直接放在 `Button.text` 上被子贴图覆盖，当前改为 SpriteFrame 底图 + 独立 `Label`。
- 主城右侧九个入口已修复可点击性：可视斜条继续按原始布局旋转显示，点击使用独立顶层矩形命中层，并在 `_input` 中按设计坐标分发，避免旋转 Control 和角色 hit 区截获鼠标事件；红点也移到图标右上角，避免遮住入口图标。
- 主城底部导航也使用独立命中层和 `_input` 坐标兜底；底部“英雄”按钮已验证不会再被主城角色 Spine/角色点击区挡住，回归参数为 `--home-click-at 359,654 --capture-hero-list <png>`。
- 商店页可用 `--shop-open-buy <index>` 启动参数直接打开购买确认框，配合 `--capture-shop-panel` 做回归截图。

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
- `data/config_index/summary.json`：从 `assets/resources/config.json` 拆出的 resources bundle 摘要，当前共 17141 条逻辑路径资源。
- `data/config_index/by_type/*.json`：按 Cocos 类型拆分的资源索引，例如 `cc.SpriteFrame.json`、`cc.Prefab.json`、`sp.SkeletonData.json`。
- `data/config_index/by_path_prefix/*.json`：按常用路径前缀拆分的索引；主城优先查 `image__com__mainpanel.json` 和 `Prefab__mainpanel.json`。
- `data/prefabs.csv`：原始 prefab 清单。
- `data/prefab_layouts.json`：已导出的核心 prefab 布局清单。
- `data/prefab_layouts/MoneyItemPre.json`：资源条 prefab，主城顶部金币/钻石条使用。
- `data/prefab_layouts/ShopPre.json`：商会/黑市商店 prefab，主屏 `openShop()` 的目标。
- `data/prefab_layouts/GoodsItemPre.json`：商店商品卡 prefab，含 `GoodsItemCom` 的 `discount/rare/fight/prize/limit/selectBtn` 绑定。
- `data/prefab_layouts/HeroMainPre.json`：英雄主界面 prefab，独立英雄页的中心 Spine、右侧信息面板和功能页签布局参考。
- `data/prefab_layouts/HeroBookDetailPre.json`：截图里的英雄详情/图鉴详情页主体 prefab。源码入口是 `HeroBookDetailPanel.preUrl="Prefab/HeroPanel/HeroBookDetailPre"`，包含 `heroBodyBox/skinBodyBox/rightBox/skinBox/infoToggle/skinToggle/btnChaKan/btnLingqu/btnPingLun` 等字段绑定。
- `data/hero_resource_inventory.json`：英雄资源完整清单，来自 `config.json`、`named_resource_index.json` 和反编译源码字段链。
- `data/hero_catalog.json`：Godot 英雄列表运行时目录，当前 75 个 6 位英雄 id，按 `SSS > SSR > SR > R > N` 排序。
- `HERO_RESOURCE_INVENTORY.md`：英雄资源分析文档，记录头像、图鉴、立绘 prefab、战斗 prefab、语音、皮肤/变体和离线品质推断规则。
- `tools/export_hero_resource_inventory.py`：重新生成英雄资源清单和 Godot 英雄目录的工具。
- `data/prefab_source_inventory.json/.csv/.md`：从 `prefabs.csv`、反编译源码 `preUrl/url` 和已有文档线索交叉生成的完整 prefab 索引。当前统计为 1018 个 prefab、492 个源码直接引用入口、129 个文档已知候选。
- `tools/export_prefab_source_inventory.py`：重新生成完整 prefab 资源索引的工具。下一步手工还原界面时，优先查看 `data/prefab_source_inventory.md` 的“源码高频入口”和“已知还原候选”。
- `data/prefab_layouts/HeroTabPre.json`：英雄页签 prefab，确认 `cm_tab2_on/off` 页签资源。
- `data/prefab_layouts/HeroListPre.json`：完整英雄列表页 prefab。当前 Godot 已新增独立 `original_hero_list_panel.tscn`，主屏“英雄”先打开列表，点击英雄后进入 `HeroBookDetailPre` 风格详情页。
- `data/prefab_layouts/HeroGridPre.json`、`HeroBookItemPre.json`、`HeroLevelSharedPre.json`、`HeroNormalarrayPre.json`、`HeroStarPre.json`：英雄列表页的卡片、图鉴、共享等级、阵容和升星子 prefab 布局参考。
- 英雄列表/详情页回归参数：`--hero-list-open-id <id>` 可从列表按 id 打开详情；`--hero-list-click-at 200,260` 可模拟点击首个卡片；`--hero-id <id>` 可直接指定详情页英雄。图鉴页优先使用 `image/heroBook/<id>` 长图。
- 英雄详情页新增衣装、全屏预览和语音回归：`--hero-full-preview` 隐藏其他 UI 只显示角色，`--hero-click-once` 模拟点击角色并播放 `sound/cv/<hero>/<soundId>`。语音索引由 `tools/export_hero_voice_index.py` 生成到 `data/hero_voice_index.json`，MP3 拷贝在 `assets/hero_voice/**`。
- `data/prefab_restore_inventory.csv`：整理后的 prefab 还原清单。
- `data/prefab_restore_inventory.md`：按分类和优先级整理的 prefab 清单。
- `data/spine_preview_index.json`：Spine 预览索引。
- `RESTORE_LOGIN_TO_HOME.md`：登录页 -> 选服页 -> 主页面的专项还原梳理。
- `SOURCE_DIRECTORY_GUIDE.md`：原始目录、解密目录、Cocos bundle、反编译源码和工具脚本的作用索引。
- `tools/inspect_prefab_layout.py`：检查导出的 prefab layout、贴图节点、文本节点、Mask/ScrollView 和脚本字段绑定。
- `tools/export_cocos_config_index.py`：重新拆分 `assets/resources/config.json` 到 `data/config_index`，用于反查资源逻辑路径、UUID、native 文件和 SpriteFrame 裁剪信息。
- `debug_outputs/`：本地截图、Godot stdout/stderr 日志和临时回归输出目录。该目录默认被 git 忽略，只保留 `.gitkeep`。

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
- `Prefab/Shop/ShopPre`
- `Prefab/HeroListPanel/HeroListPre`
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
