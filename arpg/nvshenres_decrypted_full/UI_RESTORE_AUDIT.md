# UI Restore Audit

本文件记录当前 Godot 手工界面与原始 Cocos prefab/源码入口的对应关系。后续逐页还原时先查本表，再打开 `data/prefab_source_inventory.md` 和对应 `data/prefab_layouts/*.json`。

## 当前流程

启动链路：

1. `original_loading.tscn` -> `original_login.tscn`
2. `original_login.tscn` -> `original_server_select.tscn`
3. `original_server_select.tscn` -> `original_home_screen.tscn`
4. 主屏底部/右侧入口进入英雄列表、抽卡、仓库、商会等本地页面。

## 页面映射

| Godot 场景 | 手工脚本 | 原始 prefab | 源码入口模块 | 当前状态 | 下一步 |
| --- | --- | --- | --- | --- | --- |
| `scenes/original_loading.tscn` | `scripts/original_loading.gd` | `Prefab/loading/LoadingPre` | 启动加载逻辑 / `LoadingPanelNode` | 第一轮已按 `LoadingPre.json` 收敛：底部 1018 宽进度条、进度文字、连接服务器文案和设计尺寸适配。 | 后续补 `loading_jindutiao` / `ani` Spine 动效。 |
| `scenes/original_login.tscn` | `scripts/original_login.gd` | `Prefab/login/LoginPre` | `LoginPanel` | 已恢复为可显示资源：背景使用 `1176e8f9...png`，logo/底部带使用可裁剪 atlas，登录按钮使用 `5bdf6505...png`；坐标继续参考 `LoginPre.json`。 | 不再直接使用 `LoginPre` 中 40x40 占位 native；后续先通过 SpriteFrame 裁剪验证再替换。 |
| `scenes/original_server_select.tscn` | `scripts/original_server_select.gd` | `Prefab/login/pfLoginPanelPre` | `PFLoginPanel` | 已恢复为可显示资源：背景、底部带和开始按钮使用已验证可显示资源；服务器选择条、右侧入口坐标继续参考 `pfLoginPanelPre.json`。 | 后续补服务器列表弹层 `nodeSv`、公告弹层 `nodeGG`、维护/新服图标；替换资源前先排除 40x40 占位图。 |
| `scenes/original_home_screen.tscn` | `scripts/original_home_screen.gd` | `Prefab/mainpanel/MainPre` + `Prefab/mainpanel/daohangPre` | `MainUIPanel` / `DaohangPanel` | 主屏已用 `MainPre.json` 叠加节点和 105004 Spine；底部导航保留 `daohangPre` 坐标，前三个使用可显示原图，后几个暂回退到可显示 atlas 近似，避免横条/11px 切片当图标。 | 继续按 `MainPre.json` 修右侧九个入口、左侧活动入口、顶部头像资源条、底部广告和默认角色位置。 |
| `scenes/original_hero_list_panel.tscn` | `scripts/original_hero_list_panel.gd` | `Prefab/HeroListPanel/HeroListPre` | `HeroListPanel` | 英雄列表展示有 Spine 的英雄，点击进入详情；Prefab 按钮已指向“英雄列表”。 | 替换卡片为 `HeroGridPre/HeroBookItemPre` 的真实资源和布局。 |
| `scenes/original_hero_panel.tscn` | `scripts/original_hero_panel.gd` | `Prefab/HeroPanel/HeroBookDetailPre` + `Prefab/mainpanel/daohangPre` | `HeroBookDetailPanel` / `DaohangPanel` | 已切换文案和预览入口到 `HeroBookDetailPre`，角色 Spine、语音、衣装、全屏预览可用。 | 用 `HeroBookDetailPre.json` 精确重排左上品质、右侧白纸面板、技能/装备列和页签。 |
| `scenes/original_draw_card_panel.tscn` | `scripts/original_draw_card_panel.gd` | `Prefab/DrawCard/drawCardPre` | `DrawMainPanel` | 抽卡页有页签和部分 `ZhaoHuan_*` Spine。 | 继续追 `HeroShowPre`、十连展示、抽卡特效和活动抽卡入口。 |
| `scenes/original_shop_panel.tscn` | `scripts/original_shop_panel.gd` | `Prefab/Shop/ShopPre` | `ShopPanel` | 商会可从主屏进入，已有商品网格和购买弹窗。 | 按 `ShopPre/GoodsItemPre/ShopItemPre` 重排主类型、子类型、刷新节点和货币条。 |
| `scenes/original_bag_panel.tscn` | `scripts/original_bag_panel.gd` | `Prefab/BagPanel/BagPre` | `BagPanel` | 仓库可从主屏进入，已有分类和格子。 | 按 `BagPre/GridBoxItemPre` 替换真实格子、背包页签、合成/神器入口。 |

## 已修正问题

- 英雄详情页不再把截图主体误标为 `HeroMainPre`，改为 `HeroBookDetailPre`。
- 英雄列表页的 Prefab 按钮改为打开 `HeroListPre`。
- 英雄详情页的 Prefab 按钮改为打开 `HeroBookDetailPre`。
- 英雄详情底部“召唤”跳转修正为 `res://scenes/original_draw_card_panel.tscn`。
- 登录页“原始界面预览”按钮改为直接打开 `LoginPre` 对应的“登录面板”。
- 加载页按 `LoadingPre` 重排底部进度条和连接服务器文案。
- 登录页曾尝试直接使用 `LoginPre` 里的 `bg/logo/wenziDi` native 文件，但这些文件实际只有 40x40，已恢复为可显示资源并保留 prefab 坐标。
- 选服页曾尝试直接使用 `pfLoginPanelPre` 里的背景/底部带 native 文件，但这些同样是 40x40 占位，已恢复为可显示资源并保留 prefab 坐标。
- 主屏底部导航保留 `daohangPre` 的坐标；对 SpriteFrame 指向横条/极薄切片的图标，已回退到之前可显示的 atlas 近似资源。
- 登录页、选服页、主屏已开始从 `data/prefab_layouts/*.json` 的 `screen_rect` 读取位置和尺寸；手工脚本只保留已验证可显示的贴图选择。
- 主屏右侧九入口、底部导航、广告入口和左侧快捷栏已改为读取 `MainPre/daohangPre` 节点坐标，点击热区同步使用同一来源。
- 主屏活动矩阵不能完全照搬 `screen_rect`：原节点挂在可滚动/偏移父容器下，第一列导出后落在屏幕外侧。当前按 prefab 网格间距保留，但对可见区整体右移 `100px`，避免和左侧快捷栏重叠。
- 已确认 `assets/resources/config.json` 是完整 Cocos 资源路径表，`paths` 里记录逻辑路径、类型和 UUID 下标，`uuids` 里记录压缩 UUID。现有 `data/named_resource_index.json` 只有一部分路径，不能作为完整资源索引。
- 已新增 `tools/export_cocos_config_index.py`，可把 `assets/resources/config.json` 拆到 `data/config_index`。当前统计 resources bundle 共 17141 条路径资源，其中 `cc.SpriteFrame=8139`、`cc.Texture2D=4744`、`cc.Prefab=1007`、`sp.SkeletonData=993`、`cc.AudioClip=1061`。
- 后续查资源优先看 `data/config_index/by_path_prefix`：主城静态图标/按钮查 `image__com__mainpanel.json`，主城 prefab 查 `Prefab__mainpanel.json`，英雄页查 `Prefab__HeroPanel.json` / `image__com__HeroListPanel.json`，抽卡查 `Prefab__DrawCard.json` / `image__com__DrawCard.json`。
- `texture_path` 为空不一定代表资源不存在。很多 prefab 节点没有直接挂 `_spriteFrame`，但节点名与 `config.json` 的 `image/com/<模块>/<节点名>` 路径一致，例如 `zjm_btn_rukou0`、`zjm_icon_baoju`、`cm_icon_ChengZhen`。
- `tools/export_cocos_prefab_layout.py` 已新增 `config.json` 兜底解析：当 prefab 引用缺失时，会按资源路径推断 SpriteFrame UUID，再解析 import/native/rect/originalSize/offset/rotated/capInsets。
- 底部导航 `cm_tab_ZhaoHuan` 没有 `image/com/mainpanel/cm_icon_ZhaoHuan`，当前确认源码中 `btn3` 是召唤入口，静态替代资源使用 `image/com/mainpanel/zjm_icon_zhaohuan`；动态抽卡资源在 `uispine/ZhaoHuan*`，属于抽卡页效果，不是底栏静态图标。

## 资源替换规则

- 不要仅凭 `texture_path` 替换手工页资源。先检查图片实际尺寸；`40x40` 常是占位或解析不完整资源。
- 有 `sprite_rect/originalSize/offset/rotated` 的节点必须经过 SpriteFrame 裁剪验证后再用于最终 UI。
- `data/prefab_layouts/*.json` 已导出 `screen_rect`，这是当前统一后的 Godot 设计画布坐标，优先级高于旧的 `position/global_position + anchor` 手算。
- `sprite_type_name` 表示显示模式：`simple` 普通拉伸、`sliced` 九宫格、`tiled` 平铺、`filled` 填充、`mesh` 网格；当前通用 layer/preview 已支持前三种，后两种还需专项实现。
- `sprite_cap_insets` 对应 Cocos 九宫格裁剪边距；不能把九宫格按钮直接当普通贴图等比显示。
- `sprite_size_mode_name`、`sprite_original_size`、`sprite_offset` 用于 trim 复原；直接显示 atlas 裁剪区会导致图标偏移或黑边。
- `cocos_prefab_layer.gd` 与 `cocos_prefab_preview.gd` 已开始统一使用 `screen_rect`，后续手工页应尽量从这些字段取坐标，避免继续维护多套坐标换算公式。

## 使用方式

- 查看完整 prefab 清单：`data/prefab_source_inventory.md`
- 查看 resources 路径索引：`data/config_index/summary.json`、`data/config_index/by_type/*.json`、`data/config_index/by_path_prefix/*.json`
- 查看核心布局导出：`data/prefab_layouts/*.json`
- 重新拆分 resources `config.json`：`python tools/export_cocos_config_index.py`
- 重新生成索引：`python tools/export_prefab_source_inventory.py`
- 重新导出核心布局：`python tools/export_cocos_prefab_layout.py`
