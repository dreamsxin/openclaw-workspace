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
| `scenes/original_loading.tscn` | `scripts/original_loading.gd` | `Prefab/loading/LoadingPre` | 启动加载逻辑 / `LoadingPanelNode` | 已按 `LoadingPre.json` 收敛：底部 1018 宽进度条、进度文字、连接服务器文案、`dl_progressbar1_jiazai` 指针和 `uispine/denglu/loading_jindutiao` 扫光动效已接入；中部 `ani` 引用的压缩 UUID 是 `5cVkzAe5tNQY7WMdd9nXao`，解码为 `5c564cc0-7b9b-4d41-8ed6-31d77d9d76a8`，但当前解密工程缺少对应 import 文件，暂不能导出 Spine runtime。 | 后续从原始包或补解密资源里找回 `5c564cc0-7b9b-4d41-8ed6-31d77d9d76a8.json`。 |
| `scenes/original_login.tscn` | `scripts/original_login.gd` | `Prefab/login/LoginPre` | `LoginPanel` | `LoginPanel` 是调试/账号直连页，不是正式启动选服页；已按 `LoginPre.json` 补回四个调试输入框 `tbg1~tbg4`、版本号、右侧协议/用户/公告按钮。`logo` 节点在 prefab 中 `_active=false`，当前不再强行显示。背景改用 `uispine/denglu/bg`，这是带静态登录人物的整张背景。 | 后续补 `LoginCom` 中文本输入、公告/用户弹窗和版本号真实值。 |
| `scenes/original_server_select.tscn` | `scripts/original_server_select.gd` | `Prefab/login/pfLoginPanelPre` | `PFLoginPanel` | `PFLoginPanel` 是正式登录/选服入口；已按 `pfLoginPanelPre.json` 和 `PFLoginCom` 补回服务器浮框、`txtServer`、开始按钮、右侧公告/切换账号/Discord/Facebook、版号/适龄提示、隐私勾选与协议文案。背景改用 `uispine/denglu/bg`。服务器框/切换箭头/火爆/新服/维护标签来自 `image/com/login` SpriteFrame。已新增本地服务器列表弹层，参考 `nodeSv/svBg/scrollTab/scrollserver` 坐标。 | 后续补公告弹层 `nodeGG`、隐私协议真实弹窗和服务器列表 ScrollView 真实滚动/分组数据。 |
| `scenes/original_home_screen.tscn` | `scripts/original_home_screen.gd` | `Prefab/mainpanel/MainPre` + `Prefab/mainpanel/daohangPre` | `MainUIPanel` / `DaohangPanel` | 主屏已用 `MainPre.json` 叠加节点和 105004 Spine；105004 继续按 `Prefab/HerolhPrefab/105004` 的 Skeleton 子节点坐标、scale 放置，遮挡问题改由主 UI 层级处理；底部导航保留 `daohangPre` 坐标；右侧九入口继续用 `MainPre` 的 `zjm_btn_rukou*` 坐标，图标已按 `image/com/mainpanel` 中的真实 `zjm_icon_yinghun/duanzao/zhanbu/xunxing/shanghui` 等 SpriteFrame 修正；左侧活动矩阵补入 `zjm_icon_xinfu/gonghuizhan/shengxingjihua/zhaohuantehui/yuzhuche` 等资源；头像/名字/战力条改用 `daohangPre` 坐标和 SpriteFrame；顶部 SHOP 改用 `cm_icon_Shop`，货币条按 `MoneyItemPre` 与 `image/common/cm_frame_HuoBi*`、`sj-jinbi/sj-zuanshi` 重组。 | 继续按 `MainPre.json` 修底部广告和默认角色位置。 |
| `scenes/original_hero_list_panel.tscn` | `scripts/original_hero_list_panel.gd` | `Prefab/HeroListPanel/HeroListPre` | `HeroListPanel` | 英雄列表展示有 Spine 的英雄，点击进入详情；Prefab 按钮已指向“英雄列表”。 | 替换卡片为 `HeroGridPre/HeroBookItemPre` 的真实资源和布局。 |
| `scenes/original_hero_panel.tscn` | `scripts/original_hero_panel.gd` | `Prefab/HeroPanel/HeroBookDetailPre` + `Prefab/mainpanel/daohangPre` | `HeroBookDetailPanel` / `DaohangPanel` | 已切换文案和预览入口到 `HeroBookDetailPre`，角色 Spine、语音、衣装、全屏预览可用。 | 用 `HeroBookDetailPre.json` 精确重排左上品质、右侧白纸面板、技能/装备列和页签。 |
| `scenes/original_draw_card_panel.tscn` | `scripts/original_draw_card_panel.gd` | `Prefab/DrawCard/drawCardPre` | `DrawMainPanel` | 抽卡页有页签和部分 `ZhaoHuan_*` Spine。 | 继续追 `HeroShowPre`、十连展示、抽卡特效和活动抽卡入口。 |
| `scenes/original_shop_panel.tscn` | `scripts/original_shop_panel.gd` | `Prefab/Shop/ShopPre` | `ShopPanel` | 商会可从主屏进入，已有商品网格和购买弹窗。 | 按 `ShopPre/GoodsItemPre/ShopItemPre` 重排主类型、子类型、刷新节点和货币条。 |
| `scenes/original_bag_panel.tscn` | `scripts/original_bag_panel.gd` | `Prefab/BagPanel/BagPre` | `BagPanel` | 仓库可从主屏进入，已有分类和格子。 | 按 `BagPre/GridBoxItemPre` 替换真实格子、背包页签、合成/神器入口。 |

## 原始界面关联关系

源码入口主要在 `assets/main/index.js`。原游戏 UI 不是“一页一个 prefab”这么简单，而是 `Panel` 类通过 `preUrl` 加运行时 `open()`、`uilist/preloadAnyList` 和子 prefab 动态组合。

| 原始模块 | 源码关系 | 原始资源链 | 当前 Godot 对应 | 对应状态 |
| --- | --- | --- | --- | --- |
| 启动加载 | `LoadingPanelNode.preUrl="Prefab/loading/LoadingPre"`；`onprogess()` 改 `maskjinbi.width`、`huanchong.x`、`loadmagic.x`、`t3` 百分比 | `LoadingPre` + `uispine/denglu/loading_jindutiao` + `sound/bgm/loading` | `original_loading.tscn` | 基本一一对应；已实现进度条宽度、百分比、指针和扫光 Spine。中部 `ani` 的 SkeletonData UUID 已解出，但 import 文件缺失。 |
| 登录 | `LoginPanel` 使用 `Prefab/login/LoginPre`，平台登录面板走 `PFLoginPanel` / `Prefab/login/pfLoginPanelPre` | `LoginPre` + `pfLoginPanelPre` | `original_login.tscn` -> `original_server_select.tscn` | 流程对应；`LoginPre` 是调试账号页，`pfLoginPanelPre` 才是正式选服入口。两页关键静态资源已改用 `config_index/image__com__login.json` 的 SpriteFrame。 |
| 进入主城 | `MainUIPanel.preUrl="Prefab/mainpanel/MainPre"`；`_roleLhbody="105004"`；`showBg` 运行时加载 `Prefab/bigImage/<id>`；角色用 `RoleLh` 加载 `Prefab/HerolhPrefab/<bodyID>` | `MainPre` + `daohangPre` + `heroHead` + `Prefab/bigImage/*` + `Prefab/HerolhPrefab/105004` | `original_home_screen.tscn` | 主流程对应；主 UI/导航/头像/105004 Spine 已接入，右侧九入口使用导出坐标和真实图标 SpriteFrame；左侧活动矩阵已按原始标签和资源名收敛一轮。 |
| 英雄入口 | 主屏 `DaohangPanel` 打开 `HeroListPanel`；`HeroListPanel.preUrl="Prefab/HeroListPanel/HeroListPre"`；点击英雄后 `HeroMainPanel` 或 `HeroBookDetailPanel` | `HeroListPre`、`HeroGridPre`、`HeroBookItemPre`、`HeroMainPre`、`HeroBookDetailPre` | `original_hero_list_panel.tscn` -> `original_hero_panel.tscn` | 流程对应；列表/详情是手工版，已支持有 Spine 的英雄、详情动画、语音、衣装/全屏预览；布局未完全贴合原始 prefab。 |
| 抽卡入口 | `DrawMainPanel` 使用 `Prefab/DrawCard/drawCardPre`；抽卡展示另有 `HeroShowPre`、奖励预览 `DrawRewardPreviewPre` | `drawCardPre` + `HeroShowPre` + `DrawRewardPreviewPre` + `uispine/ZhaoHuan*` | `original_draw_card_panel.tscn` | 有独立手工页；卡池 Spine 和结果预览已实现，`HeroShowPre` 十连展示还未独立还原。 |
| 仓库入口 | `BagPanel.preUrl="Prefab/BagPanel/BagPre"`；格子/出售/获取途径等为子面板 | `BagPre` + `GridBoxItemPre` + `BagSellEquipPre` 等 | `original_bag_panel.tscn` | 有独立手工页；分类/格子/详情可用，真实格子与子面板还未完全还原。 |
| 商会入口 | `ShopPanel` 使用 `Prefab/Shop/ShopPre`；商品、页签、购买确认分别是子 prefab | `ShopPre` + `ShopItemPre` + `GoodsItemPre` + `ShopBuyEquitPre` | `original_shop_panel.tscn` | 有独立手工页；商品、页签、购买弹窗可用，仍需按 prefab 精排。 |
| 活动入口 | `ActivityPanel.preUrl="Prefab/ActivityPanel/ActivityPre"`；`ActivityType.prefabArray` 决定首充、占卜、基金、限时礼包等子 prefab；也可 `openByPanelId()` | `ActivityPre` + `ActivityFirstRechargePre` + `ActivityAuguryPre` + 活动子 prefab | 主屏打开 prefab 预览 | 入口已覆盖，但大部分还不是独立手工页。 |
| 右侧系统入口 | `MainUIPanel.rightNodeArr` 包含 `baoju/cangku/jingji/teach/yingHunDian/duanZao/xunbao/xunxing/shop/lihui` | 通行证、仓库、竞技、学院、英魂、锻造、占卜、寻星、商会等 prefab | 独立页或 prefab 预览 | 仓库、召唤、商会有独立页；通行证、学院、锻造、占卜、寻星目前是 prefab 预览覆盖。 |

## 主屏入口覆盖

| 主屏入口 | 当前目标 | 说明 |
| --- | --- | --- |
| 英雄 | `scenes/original_hero_list_panel.tscn` | 独立手工英雄列表，点击进入英雄详情。 |
| 仓库 | `scenes/original_bag_panel.tscn` | 独立手工仓库页。 |
| 召唤 / 英魂 | `scenes/original_draw_card_panel.tscn` | 独立手工抽卡页。 |
| 商会 / 商店 | `scenes/original_shop_panel.tscn` | 独立手工商店页。 |
| 通行证 | `Prefab/PassPrefab/BigPassPanel` | 已导出 `BigPassPanel.json`，当前进入原始 prefab 预览。 |
| 学院 | `Prefab/MaoxianPanel/BraveManTriedPassInfoPre` | 已导出 `BraveManTriedPassInfoPre.json`，当前进入原始 prefab 预览。 |
| 锻造 | `Prefab/ForgePanel/ForgePre` | 已导出 `ForgePre.json`，当前进入原始 prefab 预览。 |
| 占卜 | `Prefab/ActivityPanel/changzhuactivity/ActivityAuguryPre` | 已导出 `ActivityAuguryPre.json`，当前进入原始 prefab 预览。 |
| 寻星 | `Prefab/FindTreasurePanel/FindTreasurePre` | 已导出 `FindTreasurePre.json`，当前进入原始 prefab 预览。 |
| 活动 / 开服 / 限时 | `Prefab/ActivityPanel/ActivityPre` | 已导出 `ActivityPre.json`，当前进入原始 prefab 预览。 |
| 福利 / 礼包 / 特惠 | `Prefab/Welfare/WelfarePre` | 已导出 `WelfarePre.json`，当前进入原始 prefab 预览。 |
| 首充 | `Prefab/FirstRechargePanel/firstRechargePre` | 已导出 `firstRechargePre.json`，当前进入原始 prefab 预览。 |
| 升星 | `Prefab/HeroXZPrefab/StarUpPre` | 已导出 `StarUpPre.json`，当前进入原始 prefab 预览。 |

## 已修正问题

- 英雄详情页不再把截图主体误标为 `HeroMainPre`，改为 `HeroBookDetailPre`。
- 英雄列表页的 Prefab 按钮改为打开 `HeroListPre`。
- 英雄详情页的 Prefab 按钮改为打开 `HeroBookDetailPre`。
- 英雄详情底部“召唤”跳转修正为 `res://scenes/original_draw_card_panel.tscn`。
- 登录页“原始界面预览”按钮改为直接打开 `LoginPre` 对应的“登录面板”。
- 加载页按 `LoadingPre` 重排底部进度条和连接服务器文案。
- 登录页曾尝试直接使用 `LoginPre` 里的 `bg/logo/wenziDi` native 文件，但这些文件实际只有 40x40，已恢复为可显示资源并保留 prefab 坐标。
- 选服页曾尝试直接使用 `pfLoginPanelPre` 里的背景/底部带 native 文件，但这些同样是 40x40 占位，已恢复为可显示资源并保留 prefab 坐标。
- 登录/选服页不能盲目照 `texture_path`：`LoginPre.bg`、`LoginPre.wenziDi`、`pfLoginPanelPre.wenziDi` 的 native 是 40x40 默认图。`image/com/login/dl_bg` 对应 `assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png`，实际更像启动加载页背景；原始登录页的静态人物背景来自 `config_index/by_path_prefix/uispine.json` 的 `uispine/denglu/bg`，native 是 `assets/resources/native/a8/a84d3470-bde7-4589-9b33-65a957c34507.jpg`，文件头实际为 PNG，Godot 使用转换后的 `converted/png/a84d3470-bde7-4589-9b33-65a957c34507.png`。`uispine/denglu/HB_BG` 是云城背景，不是登录人物。`LoginPre.logo` 虽有坐标但 `_active=false`，不应显示在调试登录页。
- `PFLoginCom.onShow()` 会设置 `vesiontxt`、检查隐私 toggle，并主动打开公告；离线 Demo 不连服务器时只展示本地版号/隐私行，公告弹层后续用本地 mock 还原。
- `PFLoginPanel.getLastSever()` / `getAllSever()` 原本走 `game/getServerList.php` 网络请求。离线 Demo 不能连真实服务器，因此选服页用本地 mock 数据复原 `nodeSv` 弹层；点击服务器条打开列表，选择服务器只更新展示名称和状态标签，不改变网络连接逻辑。
- 主屏底部导航保留 `daohangPre` 的坐标；对 SpriteFrame 指向横条/极薄切片的图标，已回退到之前可显示的 atlas 近似资源。
- 登录页、选服页、主屏已开始从 `data/prefab_layouts/*.json` 的 `screen_rect` 读取位置和尺寸；手工脚本只保留已验证可显示的贴图选择。
- 主屏右侧九入口、底部导航、广告入口、左侧快捷栏、头像/名字/战力条已改为读取 `MainPre/daohangPre` 节点坐标，点击热区同步使用同一来源。
- 主屏右侧/活动入口已补全可点击目标：通行证、学院、锻造、占卜、寻星、活动、福利、首充、升星、新服、召唤卡、预注册等没有独立手工页时会打开对应原始 prefab 预览。
- 主屏活动矩阵不能完全照搬 `screen_rect`：原节点挂在可滚动/偏移父容器下，第一列导出后落在屏幕外侧。当前按 prefab 网格间距保留，但对可见区整体右移 `100px`，避免和左侧快捷栏重叠。
- 主城默认 `105004` 应照 `Prefab/HerolhPrefab/105004` 的 Skeleton 子节点坐标 `(-68,-333)` 和 scale `(1,0.95)` 放到 `MainPre.herolh` 全屏容器下；如果武器或头发遮住按钮，优先修 Godot/Cocos 层级映射，不要为了避让按钮改角色尺寸和坐标。当前主屏 UI 层已显式高于 Spine slot 子节点。
- 已确认 `assets/resources/config.json` 是完整 Cocos 资源路径表，`paths` 里记录逻辑路径、类型和 UUID 下标，`uuids` 里记录压缩 UUID。现有 `data/named_resource_index.json` 只有一部分路径，不能作为完整资源索引。
- 已新增 `tools/export_cocos_config_index.py`，可把 `assets/resources/config.json` 拆到 `data/config_index`。当前统计 resources bundle 共 17141 条路径资源，其中 `cc.SpriteFrame=8139`、`cc.Texture2D=4744`、`cc.Prefab=1007`、`sp.SkeletonData=993`、`cc.AudioClip=1061`。
- 后续查资源优先看 `data/config_index/by_path_prefix`：主城静态图标/按钮查 `image__com__mainpanel.json`，主城 prefab 查 `Prefab__mainpanel.json`，英雄页查 `Prefab__HeroPanel.json` / `image__com__HeroListPanel.json`，抽卡查 `Prefab__DrawCard.json` / `image__com__DrawCard.json`。
- `texture_path` 为空不一定代表资源不存在。很多 prefab 节点没有直接挂 `_spriteFrame`，但节点名与 `config.json` 的 `image/com/<模块>/<节点名>` 路径一致，例如 `zjm_btn_rukou0`、`zjm_icon_baoju`、`cm_icon_ChengZhen`。
- `texture_path` 不为空也不一定可信。若导出节点名和 SpriteFrame 名明显不一致，优先用节点名到 `data/config_index/by_path_prefix/image__com__<模块>.json` 回查。例如主屏 `zjm_icon_zhaohuan` 在右侧多处被 layout 复用，但真实入口图标应按功能改为 `zjm_icon_yinghun`、`zjm_icon_duanzao`、`zjm_icon_zhanbu`、`zjm_icon_xunxing`、`zjm_icon_shanghui`。
- 手工页图标选择优先级：`screen_rect` 取坐标；资源先用同名 `image/com/<模块>/<node_name>`；若 prefab 子节点引用了错误/重复图标，再用功能名映射到 config 里确认的 SpriteFrame；最后才使用旧的手工 atlas fallback。
- 活动矩阵属于滚动/偏移容器，`screen_rect` 只能作为网格相对位置依据，不能完全照搬第一列导出坐标。当前主屏对活动矩阵整体右移 `100px`，这是为了贴近原图可见区并避免压住左侧快捷栏。
- `tools/export_cocos_prefab_layout.py` 已新增 `config.json` 兜底解析：当 prefab 引用缺失时，会按资源路径推断 SpriteFrame UUID，再解析 import/native/rect/originalSize/offset/rotated/capInsets。
- 底部导航 `cm_tab_ZhaoHuan` 没有 `image/com/mainpanel/cm_icon_ZhaoHuan`，当前确认源码中 `btn3` 是召唤入口，静态替代资源使用 `image/com/mainpanel/zjm_icon_zhaohuan`；动态抽卡资源在 `uispine/ZhaoHuan*`，属于抽卡页效果，不是底栏静态图标。
- `daohangPre` 的 `moneyBox` 是运行时空容器，没有静态货币子节点。主屏货币条应参考 `Prefab/comPrefab/MoneyItemPre` 的背景 `cm_frame_HuoBi2`，再按通用资源 `image/common/cm_frame_HuoBi1/2/3`、`cm_icon_HuoBi1/2`、`sj-jinbi`、`sj-zuanshi` 组合。
- 主屏 SHOP 不是文字按钮，资源在 `image/com/mainpanel/cm_icon_Shop`，对应 atlas `assets/resources/native/1a/1a7921f32.png` 的 `[163,3,91,53]`。
- 已把 `BigPassPanel`、`KnighthoodPanel`、`ForgePre`、`ActivityAuguryPre`、`FindTreasurePre`、`WelfarePre`、`firstRechargePre`、`StarUpPre`、`ActivityPre`、`ActivityForecastPre`、`BraveManTriedPassInfoPre`、`HeroShowPre`、`DrawRewardPreviewPre` 加入 `data/prefab_layouts`。这些页面还未全部手工实现，但可以从主屏或预览器打开查看原始布局。

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

## 当前覆盖结论

已能一一走通的主流程：启动加载 -> 登录 -> 选服 -> 主城 -> 英雄列表/英雄详情、仓库、召唤、商会。

已能从主屏打开但仍是 prefab 预览覆盖的入口：通行证、学院、锻造、占卜、寻星、活动、福利、首充、升星。它们已有原始 prefab layout，可作为下一阶段手工页实现依据。

尚未做到一一对应的主要原因：

- 原游戏不少页面由一个主 prefab 加多个运行时子 prefab 组合，不能只按入口 prefab 静态还原。
- 活动页由 `ActivityType.prefabArray` 和服务端 panelId 决定展示内容，本地 Demo 目前只做离线可视化，不模拟服务端活动状态。
- 部分系统入口需要战斗/养成/背包数据驱动，当前仅用静态资源和本地 mock 数据展示。
