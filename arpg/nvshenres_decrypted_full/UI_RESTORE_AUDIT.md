# UI Restore Audit

本文件记录当前 Godot 手工界面与原始 Cocos prefab/源码入口的对应关系。后续逐页还原时先查本表，再打开 `data/prefab_source_inventory.md` 和对应 `data/prefab_layouts/*.json`。

## 当前流程

启动链路：

1. `original_loading.tscn` -> `original_server_select.tscn`
2. `original_server_select.tscn` 默认展示 `PFLoginPanel` 公告，可用 `--no-auto-notice` 查看选服主体。
3. 点击开始后显示 `LoadingPre.isFist=1` 的连接服务器提示，再进入 `original_home_screen.tscn`。
4. `original_login.tscn` 只保留为 `LoginPre` debug/直连页，不属于正式非 debug 启动链路。
4. 主屏底部/右侧入口进入英雄列表、抽卡、仓库、商会等本地页面。

## 页面映射

| Godot 场景 | 手工脚本 | 原始 prefab | 源码入口模块 | 当前状态 | 下一步 |
| --- | --- | --- | --- | --- | --- |
| `scenes/original_loading.tscn` | `scripts/original_loading.gd` | `Prefab/loading/LoadingPre` | 启动加载逻辑 / `LoadingPanelNode` | 已按 `GameWorld.load()/loadingComplete()` 重新确认：普通启动 `isFist=0`，显示底部 1018 宽进度条、`t1/t3` 和加载动画，不显示中部“正在连接服务器”；加载完成后进入 `PFLoginPanel/pfLoginPanelPre`，不是 `LoginPre`。连接服务器时才走 `isFist=1` alert 模式；`sound/bgm/loading` 已按 `cc.AudioClip` native 路径接入循环播放。 | 后续补 `LoadingPre.ani` 缺失 Spine runtime，并把连接服务器 alert 模式独立复核。 |
| `scenes/original_login.tscn` | `scripts/original_login.gd` | `Prefab/login/LoginPre` | `LoginPanel` | `LoginPanel` 是 debug/直连登录页，只在 `Global.isDebug != 0` 时由 `GameWorld.showSeverPanel()` 打开；正式玩家启动不会先看到它。当前保留四个直连输入框、版本号、右侧协议/用户/公告按钮，并移除本地调试导航。 | 后续按 `LoginPre.bg/logo/textbg` 的真实资源链重新核查背景，不再把它作为正式登录页优化优先级。 |
| `scenes/original_server_select.tscn` | `scripts/original_server_select.gd` | `Prefab/login/pfLoginPanelPre` | `PFLoginPanel` | `PFLoginPanel` 是正式登录/选服入口；`PFLoginPanel.onShow()` 会 `loginCom.onShow()`、设置版本号、勾选隐私 toggle、绑定隐私/适龄入口，并调用 `loginCom.onBtnGGClick()` 拉公告。当前主启动链已改为 `LoadingPre -> pfLoginPanelPre`；默认会打开公告层，也可用 `--no-auto-notice` 截主界面主体。 | 后续把公告层从本地说明改为按 `nodeGG/tmptxt` 和真实公告资源/文本清洗显示，并继续精修选服按钮资源。 |
| `scenes/original_home_screen.tscn` | `scripts/original_home_screen.gd` | `Prefab/mainpanel/MainPre` + `Prefab/mainpanel/daohangPre` | `MainUIPanel` / `DaohangPanel` | 主屏已用 `MainPre.json` 叠加节点和 105004 Spine；105004 继续按 `Prefab/HerolhPrefab/105004` 的 Skeleton 子节点坐标、scale 放置，遮挡问题改由主 UI 层级处理；底部导航保留 `daohangPre` 坐标，并按 `cm_menu_BeiJing/cm_menu_TaiYangGuang` 绘制底栏光效；`DaohangPanel.creatMoney()` 只创建金币、钻石两个 `MoneyItem`，Godot 已按 `moneyBox` 顶部容器坐标修正，不再显示第三条货币；右侧九入口继续用 `MainPre` 的 `zjm_btn_rukou*` 坐标，图标已按 `image/com/mainpanel` 中的真实 `zjm_icon_yinghun/duanzao/zhanbu/xunxing/shanghui` 等 SpriteFrame 修正；左侧活动矩阵补入 `zjm_icon_xinfu/gonghuizhan/shengxingjihua/zhaohuantehui/yuzhuche` 等资源；头像/名字/战力条改用 `daohangPre` 坐标和 SpriteFrame；顶部 SHOP 改用 `cm_icon_Shop`。 | 继续按 `MainPre.json` 修默认角色与右侧入口层级细节。 |
| `scenes/original_hero_list_panel.tscn` | `scripts/original_hero_list_panel.gd` | `Prefab/HeroListPanel/HeroListPre` | `HeroListPanel` | 已按源码逐段修正右侧入口：`btnHero/btnBook/btnShared/btnYingHun/btnNormalarray/btnStar` 对应“英雄、图鉴、共鸣、英魂、法阵、星辉”；英雄/图鉴保留手工列表，`btnShared/btnYingHun/btnNormalarray/btnStar` 已切到 `HeroLevelSharedPre/HeroPalacePre/HeroNormalarrayPre/HeroStarPre` 原始 prefab 预览。 | 后续把共鸣、英魂、法阵、星辉各自做成独立手工页；继续精修英雄/图鉴卡片细节。 |
| `scenes/original_hero_panel.tscn` | `scripts/original_hero_panel.gd` | `Prefab/HeroPanel/HeroMainPre` / `Prefab/HeroPanel/HeroBookDetailPre` + `Prefab/mainpanel/daohangPre` | `HeroMainPanel` / `HeroBookDetailPanel` / `DaohangPanel` | 已按源码拆分入口语义：英雄列表卡片进入 `HeroMainPre` 培养页模式，图鉴卡片进入 `HeroBookDetailPre` 图鉴详情模式；`HeroMainPre` 五页签已按 `tab01..tab05` 坐标收敛到 `x=608` 竖列并使用 `image/common/cm_tab2_on/off`；main 模式右侧内容不再复用图鉴偏移，技能列、详情按钮和升级按钮已按 `HeroMainPre` 白板内坐标收敛；图鉴模式只保留 `infoToggle/skinToggle` 两态，页签位置按 `HeroBookDetailPre.toggleInfo/toggleSkin` 坐标收敛；角色 Spine、语音、衣装、全屏预览可用。 | 继续分别按 `HeroMainPre.json` 和 `HeroBookDetailPre.json` 精确重排装备/升星/战意/衣装子页内容。 |
| `scenes/original_draw_card_panel.tscn` | `scripts/original_draw_card_panel.gd` | `Prefab/DrawCard/drawCardPre` | `DrawMainPanel` | 抽卡页有页签和部分 `ZhaoHuan_*` Spine；已按 `onDrawCardOpResult()` 补 `HeroUiBox` 十连结果 overlay，结果头像按 `bookPosArr` 近似排布，点击进入独立 `original_draw_hero_show.tscn`。 | 继续补完整抽卡翻牌特效和 `HeroBookItemPre` 更精确卡片视觉。 |
| `scenes/original_draw_hero_show.tscn` | `scripts/original_draw_hero_show.gd` | `Prefab/DrawCard/HeroShowPre` | `HeroShowPanel` | 新增抽卡单英雄展示页，复用英雄目录、Spine runtime 和语音索引，播放 `show` 动作，带分享/评论/再召唤按钮。 | 继续按 `HeroShowPre.showModelBox/showLHBox` 精确重排高稀有/普通英雄展示层和分享弹层。 |
| `scenes/original_shop_panel.tscn` | `scripts/original_shop_panel.gd` | `Prefab/Shop/ShopPre` | `ShopPanel` | 商会可从主屏进入；商品滚动区、主页签、右侧类型、刷新条和货币条已按 `ShopPre/GoodsItemPre/ShopItemPre` 的 1280x720 坐标重排，购买弹窗继续参考 `ShopBuyEquitPre`；顶部货币条已改用 `MoneyItemPre` 的 `cm_frame_HuoBi2/cm_btn_JiaHao` SpriteFrame，右侧分类补选中高亮。 | 继续补 `ShopItemPre` 完整选中态底图和真实服务器商品数据。 |
| `scenes/original_bag_panel.tscn` | `scripts/original_bag_panel.gd` | `Prefab/BagPanel/BagPre` | `BagPanel` | 仓库可从主屏进入；已按 `BagPanel.selectIndex=2` 默认显示道具页，列表改为源码 `ceil(itemarr.length / 8)` 最少 4 行、每行 8 槽的虚拟列表结构；源码子面板 `BagSellEquipPre/sellGridPre/piliangTipsPre/huoquTipsPre/hechengTipsPre/GridBoxPre/ShenQiHandBookPre` 已导出并按页签接入预览；源码列表单格由运行时 `Grid` 创建，`GridBoxItemPre` 是自选礼包/预览条目。 | 继续把手工槽位替换为真实 `Grid` 视觉组件，并把子面板从 prefab 预览收敛为手工可交互弹窗。 |

## 原始界面关联关系

源码入口主要在 `assets/main/index.js`。原游戏 UI 不是“一页一个 prefab”这么简单，而是 `Panel` 类通过 `preUrl` 加运行时 `open()`、`uilist/preloadAnyList` 和子 prefab 动态组合。

| 原始模块 | 源码关系 | 原始资源链 | 当前 Godot 对应 | 对应状态 |
| --- | --- | --- | --- | --- |
| 启动加载 | `LoadingPanelNode.preUrl="Prefab/loading/LoadingPre"`；`onprogess()` 改 `maskjinbi.width`、`huanchong.x`、`loadmagic.x`、`t3` 百分比 | `LoadingPre` + `uispine/denglu/loading_jindutiao` + `sound/bgm/loading` | `original_loading.tscn` | 基本一一对应；已实现进度条宽度、百分比、指针和扫光 Spine。中部 `ani` 的 SkeletonData UUID 已解出，但 import 文件缺失。 |
| 登录 | `LoginPanel` 使用 `Prefab/login/LoginPre`，平台登录面板走 `PFLoginPanel` / `Prefab/login/pfLoginPanelPre` | `LoginPre` + `pfLoginPanelPre` | `original_login.tscn` -> `original_server_select.tscn` | 流程对应；`LoginPre` 是调试账号页，`pfLoginPanelPre` 才是正式选服入口。两页关键静态资源已改用 `config_index/image__com__login.json` 的 SpriteFrame。 |
| 进入主城 | `MainUIPanel.preUrl="Prefab/mainpanel/MainPre"`；`_roleLhbody="105004"`；`showBg` 运行时加载 `Prefab/bigImage/<id>`；角色用 `RoleLh` 加载 `Prefab/HerolhPrefab/<bodyID>` | `MainPre` + `daohangPre` + `heroHead` + `Prefab/bigImage/*` + `Prefab/HerolhPrefab/105004` | `original_home_screen.tscn` | 主流程对应；主 UI/导航/头像/105004 Spine 已接入，右侧九入口使用导出坐标和真实图标 SpriteFrame；左侧活动矩阵已按原始标签和资源名收敛一轮。 |
| 英雄入口 | 主屏 `DaohangPanel` 打开 `HeroListPanel`；`HeroListPanel.preUrl="Prefab/HeroListPanel/HeroListPre"`；英雄背包列表点击进 `HeroMainPanel`，图鉴单卡/单英雄查询进 `HeroBookDetailPanel` | `HeroListPre`、`HeroGridPre`、`HeroBookItemPre`、`HeroMainPre`、`HeroBookDetailPre` | `original_hero_list_panel.tscn` -> `original_hero_panel.tscn` | 流程对应；列表/详情是手工版，已支持 `mode=main/book` 两种入口、详情动画、语音、衣装/全屏预览；布局未完全贴合原始 prefab。 |
| 抽卡入口 | `DrawMainPanel` 使用 `Prefab/DrawCard/drawCardPre`；`onDrawCardOpResult()` 显示 `HeroUiBox` 十连结果；点击单卡进入 `HeroShowPanel.preUrl="Prefab/DrawCard/HeroShowPre"` | `drawCardPre` + `HeroBookItemPre` + `HeroShowPre` + `DrawRewardPreviewPre` + `uispine/ZhaoHuan*` | `original_draw_card_panel.tscn` -> `original_draw_hero_show.tscn` | 有独立手工页；卡池 Spine、结果 overlay、继续召唤按钮和单英雄展示页已实现，翻牌动画还未完整还原。 |
| 仓库入口 | `BagPanel.preUrl="Prefab/BagPanel/BagPre"`；`btn_sellequip`、普通出售、批量使用、获取途径、碎片合成、自选礼包、神器图鉴分别打开子面板 | `BagPre` + `GridBoxItemPre` + `BagSellEquipPre` + `sellGridPre` + `piliangTipsPre` + `huoquTipsPre` + `hechengTipsPre` + `GridBoxPre` + `ShenQiHandBookPre` | `original_bag_panel.tscn` | 有独立手工页；列表/页签已按源码 8 列与 `BagPre` 坐标收敛，子面板已能按页签进入 prefab 预览，后续转为手工弹层。 |
| 商会入口 | `ShopPanel` 使用 `Prefab/Shop/ShopPre`；商品、页签、购买确认分别是子 prefab | `ShopPre` + `ShopItemPre` + `GoodsItemPre` + `ShopBuyEquitPre` | `original_shop_panel.tscn` | 有独立手工页；商品、页签、购买弹窗可用，主体布局已按 prefab 坐标收敛。 |
| 活动入口 | `ActivityPanel.preUrl="Prefab/ActivityPanel/ActivityPre"`；`ActivityType.prefabArray` 决定首充、占卜、基金、限时礼包等子 prefab；也可 `openByPanelId()` | `ActivityPre` + `ActivityFirstRechargePre` + `ActivityAuguryPre` + 活动子 prefab | 主屏打开 prefab 预览 | 入口已覆盖，但大部分还不是独立手工页。 |
| 右侧系统入口 | `MainUIPanel.rightNodeArr` 包含 `baoju/cangku/jingji/teach/yingHunDian/duanZao/xunbao/xunxing/shop/lihui`；`onShow()` 分别绑定 `openTreasurePanel/openBag/openjingjiPanel/openTeachListPanel/openHeroPalacePanel/openduanZao/openXunbaoPanel/openZhuanPan/openShop` | 宝具、仓库、竞技、学院、英魂、锻造、占卜、寻星、商会等 prefab | 独立页或 prefab 预览 | 仓库、商会有独立页；宝具/学院/英魂/锻造/占卜/寻星已改为源码对应 prefab 预览；主屏单独的通行证节点仍走 `BigPassPanel`。 |

## 主屏入口覆盖

| 主屏入口 | 当前目标 | 说明 |
| --- | --- | --- |
| 英雄 | `scenes/original_hero_list_panel.tscn` | 独立手工英雄列表，点击进入英雄详情。 |
| 仓库 | `scenes/original_bag_panel.tscn` | 独立手工仓库页。 |
| 召唤 | `scenes/original_draw_card_panel.tscn` | 底部 `btn3 -> openZhaohuanPanel()`，独立手工抽卡页。 |
| 宝具 | `Prefab/TreasurePanel/TreasurePre` | 主屏右侧 `baoju -> openTreasurePanel()`，已导出 `TreasurePre.json`，当前进入原始 prefab 预览。 |
| 跨服PVP | `Prefab/KuafuPvpPane/KuafuPvpPre` | 源码存在 `MainUIPanel.openkuafuPanel() -> PanelManager.openKuafuPvpPanel()` 和 `KuafuPvpUIPanel.preUrl`，但当前 `MainPre` 没有命中可见的跨服入口节点，也没有 `MainCom` 字段绑定；先导出 prefab 供独立预览，不强行放到主屏。 |
| 英魂 | `Prefab/HeroPalace/HeroPalacePre` | 主屏右侧 `yingHunDian -> openHeroPalacePanel()`，已导出 `HeroPalacePre.json`，当前进入原始 prefab 预览。 |
| 商会 / 商店 | `scenes/original_shop_panel.tscn` | 独立手工商店页。 |
| 通行证 | `Prefab/PassPrefab/BigPassPanel` | 主屏 `pass` 运行期活动节点，不是右侧九入口第一项；已导出 `BigPassPanel.json`，当前进入原始 prefab 预览。 |
| 学院 | `Prefab/TeachPlace/TeachListPre` | 主屏右侧 `teach -> openTeachListPanel()`，已导出 `TeachListPre.json`。`BraveManTriedPassInfoPre` 属于学院塔/试炼信息，不是主屏右侧学院入口。 |
| 锻造 | `Prefab/ForgePanel/ForgePre` | 已导出 `ForgePre.json`，当前进入原始 prefab 预览。 |
| 占卜 | `Prefab/zhanbu/zhanbuPre` | 主屏右侧 `xunbao -> openZhanbu()`，已导出 `zhanbuPre.json`。活动面板里的占卜活动另保留为 `活动占卜` / `ActivityAuguryPre`。 |
| 寻星 | `Prefab/FindTreasurePanel/FindTreasurePre` | 主屏右侧 `xunxing -> openXunbao()`，已导出 `FindTreasurePre.json`。 |
| 活动 / 开服 / 限时 | `Prefab/ActivityPanel/ActivityPre` | 已导出 `ActivityPre.json`，当前进入原始 prefab 预览。 |
| 福利 / 礼包 / 特惠 | `Prefab/Welfare/WelfarePre` | 已导出 `WelfarePre.json`，当前进入原始 prefab 预览。 |
| 首充 | `Prefab/FirstRechargePanel/firstRechargePre` | 已导出 `firstRechargePre.json`，当前进入原始 prefab 预览。 |
| 升星 | `Prefab/HeroXZPrefab/StarUpPre` | 已导出 `StarUpPre.json`，当前进入原始 prefab 预览。 |
| 打工 | `Prefab/TaskPanel/ActivityYiwuPre` | 左侧活动矩阵 `dagong -> opendagong()`，源码走 `PanelManager.open(PANEL_ID_3610)` 并请求 `CG_HERO_GROWUP_TASK_QUERY/REWARD_QUERY`；已导出 `ActivityYiwuPre/ActivityYiwuTapPre/HitWorkPre`。 |
| 每日礼包 | `Prefab/DailyGift/DailyGiftPre` | `daily -> openDailyGift() -> PANEL_ID_3200`，不是广告入口。已导出 `DailyGiftPre.json`，主屏活动矩阵显示名从“广告”改为“每日礼包”。 |
| 礼包 | `Prefab/Gift/GiftPre` | `openlibao -> PANEL_ID_6000 -> GiftPanel.open()`，已导出 `GiftPre.json`，不再误指向福利页。 |
| 特惠 | `Prefab/ActivityPanel/guoqingactivity/GuoqingActivity` | `thank -> openThank() -> PANEL_ID_5000`，`PanelManager.getPanelById()` 返回 `guoqingPre` 模块；catalog 中真实 prefab 路径是 `GuoqingActivity`。 |
| 限时 | `Prefab/ActivityPanel/jueduiactivity/ActivityXianShiLiHePre` | `xianshi -> openxianshi()` 只在 `hongDianYunYingList` 中存在 `PANEL_ID_7010/7021` 时打开，两个 ID 共用限时礼包面板。 |
| 皮肤 | `Prefab/SkinShopPanel/SkinShopPre` | `openSkinShop() -> PANEL_ID_2014`，已导出 `SkinShopPre.json`；不应跳到英雄详情页。 |
| 新服/开服 | `Prefab/ActivityPanel/kaifuactivity/zhanshencomePre` | `openkaifu() -> openActivityPanel(TYPE_3)`；`ActivityType.prefabArray` 中 TYPE_3 的第一个子 prefab 是 `zhanshencomePre`，当前用它作为开服活动入口预览。 |
| 超级钜惠 | `Prefab/ActivityPanel/JuHuiActivity/JuHuiActivityPre` | `juhui -> openJuHui() -> PANEL_ID_7101`，已导出 `JuHuiActivityPre.json`。 |
| 召唤卡 | `Prefab/ActivityPanel/ZhaoHuanActivity/ZhaoHuanActivityPre` | `openZhaoHuanActivity() -> PANEL_ID_14200`，已导出 `ZhaoHuanActivityPre.json`。 |
| 组队竞技 | `Prefab/JingjiPrefab/team/teamPre` | 左侧 `pvp -> openJingjiZuDui()`，和右侧系统“竞技”不是同一个入口；已导出 `teamPre.json`。 |
| 天梯 | `Prefab/JingjiPrefab/tianti/tiantiPre` | `openTianti() -> PANEL_ID_3402`，已导出 `tiantiPre.json`。 |
| 王者争霸 | `Prefab/JingjiPrefab/wangzhe/wangzhePre` | `openwangzhe() -> PANEL_ID_1803`，已导出 `wangzhePre.json`。 |
| 公会战 | `Prefab/Guild/GuildWar/GuildWarHallPre` | `openGuildWarPanel()` 对应公会战大厅，已导出 `GuildWarHallPre.json`。 |
| 竟榜抽奖 | `Prefab/pvpActivityPanel/pvpActivityPanel` | `openPvpActivity()` 进入 PVP 活动面板，已导出 `pvpActivityPanel.json`。 |
| 食铁神兽 | `Prefab/stssActivityPrefab/oldgodsgraceentrancePre` | `openstssActivity()` 进入食铁神兽活动入口，已导出 `oldgodsgraceentrancePre.json`。 |
| 预注册 | `Prefab/ActivityPanel/PreRegAvtivity/PreRegAvtivityPre` | `openPreregActivity() -> PANEL_ID_15000`，活动状态由 `PANEL_ID_15000` 红点包控制。 |
| 升阶礼包 | `Prefab/ElevatePanel/ElevatePre` | `openElevateGift() -> PANEL_ID_14400`，活动状态由 `PANEL_ID_14400` 红点包控制。 |
| 广告奖励 | `Prefab/payPanel/AdvertisingPre` | `openAdvertisingPanel() -> PANEL_ID_14000`，这是运行时广告活动入口，不是 `daily` 每日礼包。 |
| 绑定平台 | `Prefab/payPanel/BindPre` | `bind -> bindCount()`，配合 `CG_GET_BIND_PALTFORM_QUERY/REWARD` 查询 SDK 绑定状态；当前只做 prefab 预览入口。 |
| Discord活动 | `Prefab/ActivityPanel/discordActivity/discordActivityPre` | `discordBtn -> openDiscord()` / `DiscordActivityPanel`，主屏源码初始化后默认 `discordBtn.active=false`。 |
| 次元魔战 | `Prefab/MozhuPanel/moZhuPre` | `cymz/btncymz -> openCymz() -> PANEL_ID_2801`，活动状态由 `PANEL_ID_2801` 控制；原始 `zjm_icon_cymz` 默认 `active=false`。 |
| 战斗返回提示 | `MainPre` 内部节点 | `jingJiBattle/TianTiBattle/cymzBattle` 是竞技、天梯、次元魔战战斗状态提示节点，源码由 `setJingJiBattle/setTianTiBattle/setMozhuBattle` 切换 active；它们默认隐藏，不是普通主屏入口。 |
| 好友 | `Prefab/FriendPanel/FriendPanel` | 左侧快捷 `haoyou -> openhaoyouPanel() -> openFriendPanel()`，已导出 `FriendPanel.json`。 |
| 邮件 | `Prefab/EmailPanel/EmailPre` | 左侧快捷 `email -> openyoujianPanel() -> openEmailPanel()`，已导出 `EmailPre.json`。 |
| 排行 | `Prefab/rank/RankListPanel` | 左侧快捷 `rank -> openpaihangPanel() -> openRankList()`，已导出 `RankListPanel.json`。 |
| 战报 | `Prefab/WarReport/WarReportPanel` | 左侧快捷 `zhanbao -> openzhanbaoPanel() -> openWarReport(0)`，已导出 `WarReportPanel.json`。 |
| 任务 | `Prefab/TaskPanel/TaskPre` | 左侧快捷 `task -> opentaskPanel() -> openTask()`，已导出 `TaskPre.json`。 |
| 客服 | `Prefab/UserInfo/KeFuPanel` | 左侧快捷 `kefu -> openKeFuPanel()`，已导出 `KeFuPanel.json`；Godot 原先显示为“新闻”的节点已按源码改为“客服”。 |
| 公会首领 | `Prefab/Guild/GuildBoss/GuildBossPre` | `GuildMainPanel.openBoss()`，由 `btnBoss.parent` 触发，进入公会首领面板。 |
| 公会红包 | `Prefab/Guild/GuildRedBag/GuildRedBagPre` | `GuildMainPanel.openRedbao()`，由 `btnRedbao` 触发；源码启动后默认 `btnRedbao.active=false`，本地预览保留入口方便检查。 |
| 公会科技 | `Prefab/Guild/GuildScience/GuildSciencePre` | `GuildMainPanel.openskill()`，由 `btnSkill.parent` 触发。 |
| 公会详情 | `Prefab/Guild/GuildXiangqingPre` | `GuildMainPanel.openDetail()`，进入详情后关闭当前公会主面板。 |
| 公会任务 | `Prefab/Guild/GuildTaskPre` | `GuildMainPanel.openTask()` 先请求 `CG_UNION_LIVENESS_QUERY()`，回包后打开任务面板；本地直接预览 prefab。 |
| 公会捐献 | `Prefab/Guild/Guilddonation/GuilddonationPre` | `GuildMainPanel.openDonate()` 先请求 `CG_UNION_DONATE_QUERY()`，回包后打开捐献面板；本地直接预览 prefab。 |
| 活动预告 | `Prefab/ActivityForecastPanel/ActivityForecastPre` | `forecast -> openActivityForecastPanel()`，并且主屏广告横幅当前也进入活动预告 prefab 预览。 |

## 已修正问题

- 英雄详情页不再把截图主体误标为 `HeroMainPre`，改为 `HeroBookDetailPre`。
- 英雄列表页的 Prefab 按钮改为打开 `HeroListPre`。
- 英雄详情页的 Prefab 按钮改为打开 `HeroBookDetailPre`。
- 2026-05-20 英雄列表按 `HeroListPre.json` 重新收敛：阵营按钮参考 `btnTypeAll/btnType1...` 的顶部坐标，英雄内容区参考 `content` 的 `[190,360,900,175]` 下半区横向滚动布局，卡片比例参考 `HeroGridPre` 的 `imgKuamg 110x110`。
- 2026-05-20 英雄列表源码/prefab 复核：`classes-source\sources` 未直接命中 UI 名称，英雄 UI 的可靠线索在 `assets/main/index.js` 的 `HeroListControl/HeroListPanelCom/HeroListPanel`、`assets/resources/config.json` 拆出的 `Prefab__HeroListPanel.json` 与 `data/prefab_layouts/HeroListPre.json`。源码字段声明顺序是 `btnHero/btnBook/btnShared/btnYingHun/btnNormalarray/btnStar`；事件绑定是 `btnShared -> changeTab3()`，`btnYingHun -> openYinghun()`，所以本地页签行为顺序按“英雄、图鉴、共鸣、英魂、法阵、星辉”处理。Prefab 文本节点顺序不能单独作为行为依据。
- 2026-05-20 英雄列表第二轮：新增左侧 `image/com/HeroListPanel/bg01/yxtj_Frame_JueSeDi/yxtj_Frame_XinXiDi` 预览区；英雄卡从 152x206 改为接近 `HeroGridPre` 的 110 头像卡；图鉴页从短卡改为 `HeroBookItemPre` 的 108x374 竖卡并优先加载 `image/heroBook/<id>`。
- 2026-05-20 英雄列表源码逐段结论：`initScrollView()` 使用 `HeroListControl.onHeroSortByHeroDataArr(TYPE_COMBAT_TYPE1)`，按 `campType` 过滤后写入 `gridList.numItems`，容量显示为过滤数量 `/ capNum`；`initScrollView2()` 使用 `dataBookMap[campType]`，只展示当前阵营图鉴并按 `heros.grade` 降序；`showTab()` 中英雄页 `btnTypeAll.active=true`，图鉴页 `btnTypeAll.active=false` 并默认 `campType=1`，共鸣/法阵/星辉关闭阵营筛选和容量条。Godot 已按这些规则更新。
- 2026-05-20 英雄列表第三轮：按 `HeroListPre` 导出的 `btnTypeAll/btnType1...btnType5` 精确坐标重排顶部阵营筛选，右侧 `btnHero/btnBook/btnShared/btnYingHun/btnNormalarray/btnStar` 改为原始 `198x72` 热区；英雄卡从 86 调到 92 头像区，保留 7 列密度以贴近原截图。源码 `btnYingHun -> openYinghun() -> PanelManager.openHeroPalacePanel()`，已从本页碎片 mock 改为跳转 `英魂殿/HeroPalacePre` prefab 预览。
- 2026-05-20 英雄列表第四轮：`changeTab3/changeTab4/changeTab5` 分别懒加载 `HeroLevelSharedPre/HeroNormalarrayPre/HeroStarPre`，不应继续用本地假卡片。Godot 已把“共鸣/法阵/星辉”切到 `英雄等级共享/英雄阵容/英雄升星` prefab 预览；右侧页签点击也直接进入对应原始 prefab。已验证 `hero_shared_prefab.png`、`hero_array_prefab.png`、`hero_star_prefab.png`。
- 2026-05-20 英雄列表点击修复：`original_hero_list_panel.gd` 的右侧页签层和底部导航层都是覆盖全屏的 `Control`，之前默认 `mouse_filter=STOP` 会拦截英雄卡片点击，造成列表里点英雄不能进详情。已把这两个透明父容器改为 `MOUSE_FILTER_IGNORE`，`hero_scroll` 改为 `MOUSE_FILTER_PASS`，并给英雄卡/图鉴卡补 `gui_input` 鼠标释放回调作为 `pressed` 的保险；`--hero-list-open-id 105004` 回归可进入 `HeroMainPre`。
- 2026-05-20 英雄列表第五轮：重新按 `HeroListPre.scrollview/view=[109,101.552,900,568]` 扩大英雄列表可视区，不再使用早期 `900x432` 截断高度；英雄卡根尺寸改回 `HeroGridPre` 的 `110x110`，头像/阵营/等级/星级/上阵标签同步按 110 卡片重排。底栏公会图标补 `rotated=true`，召唤图标改回 `daohangPre.cm_tab_ZhaoHuan` 的真实 SpriteFrame `[707,551,34,34]`。
- 2026-05-20 底部导航文字修正：原始 `daohangPre` 的底栏文字不是独立排在图标下方，而是覆盖在图标/按钮下半部。Godot 主屏已有这个逻辑；英雄列表和英雄详情页已同步为“图标主体 + y≈25 的文字叠加 + 阴影”，避免文字跑到图标下面造成错位。
- 2026-05-20 英雄详情按 `HeroBookDetailPre.json` 和原截图重新收敛：右侧白色信息板改为 `leftImg` 的 `[797,86,404,527]` 尺寸，装备/技能列保留在左侧深色条，正文从白板右半开始排布；直接参数 `--hero-id 105004 --capture-hero-panel` 可回归截图。
- 2026-05-20 英雄详情入口拆分：源码中英雄背包列表通过 `HeroControl.dataHero` 进入 `HeroMainPanel.preUrl="Prefab/HeroPanel/HeroMainPre"`；图鉴单卡或 `GC_HERO_BOOK_SINGLE_QUERY()` 会设置 `HeroControl.isOpenBook=true` 并打开 `HeroBookDetailPanel.preUrl="Prefab/HeroPanel/HeroBookDetailPre"`。Godot 已给 `original_hero_panel.gd` 增加 `mode=main/book`：英雄列表卡片传 `mode=main`，图鉴卡片传 `mode=book`，直接回归参数为 `--hero-mode main|book`。
- 2026-05-20 `HeroBookDetailPre` 模式第二轮：源码只绑定 `infoToggle` 和 `skinToggle`，不是 `HeroMainPre` 的培养/装备/升星/战意/衣装五页签。Godot 图鉴模式已只显示“档案/衣装”两个页签，并按导出坐标 `toggleInfo=[608,260,64,100]`、`toggleSkin=[608,360,64,100]` 放置；图鉴说明文字压缩到白板底部，避免遮住按钮。
- 2026-05-20 `HeroMainPre` 模式第二轮：`HeroMainPanel.hideTabOn()`/`showTab()` 明确对 `tab1..tab5` 调 `setImgUrl(..., "image/common/cm_tab2_off/on")`，不能继续用旧手工最右侧大页签。Godot 已按 `HeroMainPre.json` 的 `tab01=[608,95.099,64,100]`、`tab02=[608,195.599,57,120]`、`tab03=[608,316.099,57,100]`、`tab04=[608,416.599,57,100]`、`tab05=[608,517.099,57,100]` 重排五页签；headless 下英雄详情捕获现在会跳过空 viewport，避免把本机无显示输出误报为脚本错误。
- 2026-05-20 `HeroMainPre` 模式第三轮：`HeroMainPre.heroContentPrefab=[799.378,85.868,404,527]`，内部 `jinengBox1..4` 的屏幕坐标是 `[798,175.531]`、`[798,260.105]`、`[798,344.679]`、`[798,433.43]`，对应白板内约 `x=0,y=90/174/259/348`；`btn_xianQing=[1125.929,288.247,54,54]`，对应白板内约 `x=329,y=202`；`btnUpLv=[909.041,527.716,275,60]`，对应白板内约 `x=112,y=442`。Godot main 培养页已按这些局部坐标放置技能列、详情按钮和升级按钮，图鉴模式仍保留 `HeroBookDetailPre` 的独立正文偏移。
- 2026-05-20 `HeroMainPre` 模式第四轮：源码 `HeroMainPanel.showTab()` 会在切换页签时替换 `thisPanel.imgBg`，培养/装备/战意/衣装分别设置为 `image/en/HeroPanel/yx_img_PeiYang`、`yx_img_ZhuangBei`、`yx_img_ZhanYi`、`yx_skin_bg`，升星走 `CG_HERO_JUEXING_QUERY()` 后续子面板。Godot 已让 main 模式右侧底图跟随 `selected_tab` 切换；`zhuangbeiBox`、`zhanyiBox` 已在 `prefabs.csv` 命中但尚未导出 layout，后续先导出再替换当前手工子页。
- 2026-05-20 `HeroMainPre` 升星页按钮修正：`shengxingBox.btnYHD` 是英魂材料入口，应该跳到 `HeroPalacePre/英魂殿` 预览。Godot 之前传了 `{"prefab":"英魂殿"}`，预览器实际消费的是 `layout` 参数，已改为 `{"layout":"英魂殿"}`；`--hero-mode main --hero-tab 2` 回归无脚本错误。
- 2026-05-20 英雄详情第二轮：左上名字/职业/品质/星级改为截图式手工布局；`ft_zhanli` 按 prefab 坐标移到 `x≈381,y≈576` 并提高层级，避免被角色 Spine 或底部导航遮挡；左侧三个功能按钮保留命中区和 tooltip，资源未命中时只显示低调底框，不再显示调试文字。
- 英雄详情底部“召唤”跳转修正为 `res://scenes/original_draw_card_panel.tscn`。
- 登录页“原始界面预览”按钮改为直接打开 `LoginPre` 对应的“登录面板”。
- 加载页按 `LoadingPre` 重排底部进度条和连接服务器文案。
- 登录页曾尝试直接使用 `LoginPre` 里的 `bg/logo/wenziDi` native 文件，但这些文件实际只有 40x40，已恢复为可显示资源并保留 prefab 坐标。
- 选服页曾尝试直接使用 `pfLoginPanelPre` 里的背景/底部带 native 文件，但这些同样是 40x40 占位，已恢复为可显示资源并保留 prefab 坐标。
- 登录/选服页不能盲目照 `texture_path`：`LoginPre.bg`、`LoginPre.wenziDi`、`pfLoginPanelPre.wenziDi` 的 native 是 40x40 默认图。`image/com/login/dl_bg` 对应 `assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png`，实际更像启动加载页背景；原始登录页的静态人物背景来自 `config_index/by_path_prefix/uispine.json` 的 `uispine/denglu/bg`，native 是 `assets/resources/native/a8/a84d3470-bde7-4589-9b33-65a957c34507.jpg`，文件头实际为 PNG，Godot 使用转换后的 `converted/png/a84d3470-bde7-4589-9b33-65a957c34507.png`。`uispine/denglu/HB_BG` 是云城背景，不是登录人物。`LoginPre.logo` 虽有坐标但 `_active=false`，不应显示在调试登录页。
- `PFLoginCom.onShow()` 会设置 `vesiontxt`、检查隐私 toggle，并主动打开公告；离线 Demo 不连服务器时展示本地版号/隐私行，公告按钮按 `nodeGG` 结构打开本地 mock 公告层。
- 隐私协议源码为 `useprivacyPanel.preUrl="Prefab/loading/useprivacyPre"`，正文来自 `configs/useprivacy`，拒绝调用 `cheks.uncheck()`，同意调用 `cheks.check()`。当前已导出 `data/prefab_layouts/useprivacyPre.json` 并用于 Godot 面板的 panel/title/scroll/button 坐标；真实正文后续从 `configs/useprivacy` 清洗替换。
- 切换账号源码 `PFLoginCom.clickAccountSwitch()` 对游客账号会弹“游客账号切换后将无法找回，是否确定切换账号？”；`pfLoginPanelPre` 中已有 `nodeAlert`、`cm_frame_TanChuang2`、`richtext`、`btnCancel`、`btnConfirm`。Godot 已补成本地确认框，取消关闭，确定回调试登录页。
- 适龄提示源码为 `shilingPanel.preUrl="Prefab/loading/shilingPre"`，`onShow()` 将 `configManage.shilingTxt` 写入 `t1`，点击 `btn` 关闭。当前已导出 `data/prefab_layouts/shilingPre.json` 并用于 Godot 面板的 panel/title/button 坐标；ScrollView 的 content 原点导出仍不完整，Godot 对正文区域做了局部内边距修正。
- `PFLoginPanel.getLastSever()` / `getAllSever()` 原本走 `game/getServerList.php` 网络请求。离线 Demo 不能连真实服务器，因此选服页用本地 mock 数据复原 `nodeSv` 弹层；点击服务器条打开列表，选择服务器只更新展示名称和状态标签，不改变网络连接逻辑。
- 点击开始游戏的原始链路不是直接进主城，也不是显示首次启动完整进度条：`PFLoginCom.onStartGame()` -> `PFLoginPanel.onStartGame()` -> `GameWorld.connect()`，其中 `GameWorld.connect()` 设置 `LoadingPanelNode.isFist=1`，打开 `Prefab/loading/LoadingPre`，添加 `FackProgressCom` 并 `show("正在连接服务器")`。`LoadingPanelNode.onShow()` 在 `isFist=1` 时隐藏 `dl_progressbg1_jiazai/expMask/ani/t3`，只显示 `alert`；连接成功后 `GameWorld.onConnect()` 把提示改为“正在登录服务器”。Godot 当前在选服页内叠加这个 alert 模式并延迟进入主城。`LoadingPre.alert` 里的中间 `ani` 与启动加载中部动画共用缺失 SkeletonData，当前只能用本地转动占位，不应当再按普通图片排查。
- 2026-05-20 选服页资源修正：`image__com__login.json` 的 `rect/texture_native/rotated/capInsets` 在 `sprite_frame` 子对象里，不能只读顶层字段。`original_server_select.gd` 已新增 `LOGIN_RESOURCE_INDEX` 和 `_login_texture()`，服务器框、右侧图标、状态 tag、开始按钮、公告框都改为按 `image/com/login/*` 逻辑路径加载。注意 `image/com/login/dl_bg` 有多条同名资源，不能简单按路径取第一条；当前 `PFLoginPanel` 主体背景继续用确认可见的 `uispine/denglu/bg` 静态人物背景，启动加载页单独使用 `LoadingPre` 的加载背景。
- 2026-05-20 `pfLoginPanelPre` 原始 import 中保留了公告 `tmptxt` 的 RichText 正文，简化后的 `data/prefab_layouts/pfLoginPanelPre.json` 未导出该字符串。Godot 公告层已改用这段原始公告的纯文本版，并继续使用 `image/com/login/gg_frame_gonggao` 作为真实公告框。
- 2026-05-20 `pfLoginPanelPre` 的公告层需要注意重复节点名：`lbl01` 在选服弹层和公告弹层各有一个，不能只按名字取第一个。公告关闭提示应取节点 index 118，screen rect 为 `[556.879,652.596,154,27.72]`；`tmptxt` 的 screen rect `[315,-390,650,1575.28]` 是 RichText 内容高度，不是 ScrollView 可视窗口。Godot 已给选服页脚本补充按 index 查询布局的 helper，并把公告框/标题/关闭提示改为读取 prefab 导出坐标。
- 2026-05-20 `nodeSv/svBg/xinxibg_baise` 的 SpriteFrame UUID 出现在 `assets/resources/import/fc/fc3b94c3-c07b-4eb2-826e-2ad5d962c9e7.json` 的 prefab 局部依赖里，但不在全局 `assets/resources/config.json` 的 `uuids/paths` 中，当前 `config_index` 无法直接按逻辑路径反查。尝试用 `image/com/login/G-diban` 替代会导致选服弹窗严重拉伸错位，已回退为稳定手工底板；服务器条目、状态 tag 和坐标仍保留原始布局/资源。后续若要完全还原 `svBg`，需要增强 prefab import 解包器，按局部依赖表解析 SpriteFrame import/native。
- 2026-05-20 隐私行按源码职责拆分：`cheks` 小框负责勾选/取消，`ysTxt/richtext` 文字负责打开 `useprivacyPre`。Godot 已把命中区拆成小框切换和文字打开协议，不再整行点击都弹协议。
- 2026-05-20 英雄列表继续按源码核对：`HeroListPanel.initScrollView()` 写 `lblHeroCount`，英雄背包列表使用 `scrollview/view/content/item`，首个 `HeroGrid` item 的导出 screen rect 是 `[190,375,110,110]`，因此 Godot 的 `GridContainer` 不能从 ScrollView 原点开始排，要用 `content.screen_rect - scrollview.screen_rect` 作为偏移。图鉴页使用独立 `scrollView2/view2/content2`，不是复用英雄背包滚动区域；`btnBuZhen` 坐标应取 `[1198.036,576.62,56,62]`。
- 2026-05-20 英雄详情继续按源码核对：英雄背包点击进入 `HeroMainPre`，图鉴点击进入 `HeroBookDetailPre`，两者共享很多节点名但坐标略有差异，不能固定一套坐标。`btnPre/btnNext/ft_zhanli/lblHeroName/lblNickName/lblNickname` 已改为按当前 `detail_mode` 从对应 prefab layout 读取；主培养页角色目标框优先使用 `HeroMainPre.skinBodyBox`；图鉴档案正文根区域已改为 `HeroBookDetailPre.scrollview=[897.27,177.157,300,420]`。衣装页的 `skinImg/getBtn/wearBtn/takeBtn/playBtn/noSkin` 以及重复名 `name/btnNext` 已按当前 prefab 和 parent_index 取坐标；主按钮显隐逻辑已按源码状态拆成获取/穿戴/卸下。后续继续补 `skinInfo/skinBox` 的完整容器层级。
- 主屏底部导航保留 `daohangPre` 的坐标；对 SpriteFrame 指向横条/极薄切片的图标，已回退到之前可显示的 atlas 近似资源。
- 登录页、选服页、主屏已开始从 `data/prefab_layouts/*.json` 的 `screen_rect` 读取位置和尺寸；手工脚本只保留已验证可显示的贴图选择。
- 主屏右侧九入口、底部导航、广告入口、左侧快捷栏、头像/名字/战力条已改为读取 `MainPre/daohangPre` 节点坐标，点击热区同步使用同一来源。
- 主屏右侧/活动入口已补全可点击目标：宝具、英魂、通行证、学院、锻造、占卜、寻星、活动、福利、首充、升星、新服、召唤卡、预注册等没有独立手工页时会打开对应原始 prefab 预览。
- 2026-05-20 主屏右侧入口源码复核：`MainUIPanel.onfrist()` 的 `rightNodeArr` 顺序为 `baoju/cangku/jingji/teach/yingHunDian/duanZao/xunbao/xunxing/shop/lihui`，`onShow()` 中 `yingHunDian` 绑定 `openHeroPalacePanel()`，不是抽卡。Godot 已把右侧“英魂”从 `original_draw_card_panel.tscn` 改为 `英魂殿` prefab 预览；`tools/export_cocos_prefab_layout.py` 同步补入 `("英魂殿", "Prefab/HeroPalace/HeroPalacePre")`，导出 `data/prefab_layouts/HeroPalacePre.json`。
- 2026-05-20 主屏右侧入口第二轮源码复核：`MainPre.json` 右侧 label 文本为“宝具、仓库、竞技、学院、英魂、锻造、占卜、寻星、商会”，另有独立 `pass` 节点显示“通行证”。源码中 `baoju -> openTreasurePanel()`，`teach -> openTeachListPanel()`，`xunbao -> openZhanbu()`，`xunxing -> openXunbao()`。Godot 已把第一项从“通行证”改回“宝具”，学院改为 `TeachListPre`，占卜改为 `zhanbuPre`，寻星保留 `FindTreasurePre`。注意左侧活动“打工”不是学院入口，它走 `opendagong() -> PANEL_ID_3610`，当前映射到 `ActivityYiwuPre`。
- 2026-05-20 主屏左侧活动矩阵源码复核：`daily -> openDailyGift(PANEL_ID_3200)`，所以 `zjm_icon_daily` 显示名应是“每日礼包”，不能当广告；`thank -> PANEL_ID_5000` 对应 `guoqingPre/GuoqingActivity`；`juhui -> PANEL_ID_7101` 对应 `JuHuiActivityPre`；`pvp -> openJingjiZuDui()` 对应 `JingjiPrefab/team/teamPre`，和右侧“竞技”分开；`openTianti/openwangzhe/openGuildWar/openZhaoHuanActivity/openPvpActivity/openstssActivity` 分别对应 `tiantiPre/wangzhePre/GuildWarHallPre/ZhaoHuanActivityPre/pvpActivityPanel/oldgodsgraceentrancePre`。Godot 已把这些入口从泛用“活动面板/福利/竞技”改为真实 prefab 预览。
- 2026-05-20 主屏左侧活动矩阵第三轮：`openSkinShop() -> PANEL_ID_2014 -> SkinShopPre`，所以“皮肤”不应进入英雄详情；`openPreregActivity() -> PANEL_ID_15000 -> PreRegAvtivityPre`，`openElevateGift() -> PANEL_ID_14400 -> ElevatePre`；`openxianshi()` 只处理 `PANEL_ID_7010/7021`，源码 `YunyingHandler.GC_YUNYING_GROUP_LIST` 中这两个 ID 都进入 `ActivityXianShiLiHePre`；`openkaifu() -> openActivityPanel(TYPE_3)`，TYPE_3 子 prefab 包括 `zhanshencomePre/ActivityQiTianPre/MengXinFuLi/ZhanLiChongCi`，当前主入口先映射到 `zhanshencomePre`。
- 2026-05-20 主屏左侧快捷按钮源码复核：`haoyou/email/rank/zhanbao/task/kefu/forecast` 分别绑定 `openFriendPanel/openEmailPanel/openRankList/openWarReport(0)/openTask/KeFuPanel.open/ActivityForecastPanel.open`。Godot 已给这些按钮补真实 prefab 预览目标。`zjm_btn_XinWen` 在本地旧实现里写成“新闻”，但源码对应的是 `kefu` 节点和 `openKeFuPanel()`，因此显示名改为“客服”。主屏广告横幅不再跳“活动抽卡”，改为打开“活动预告”预览；运行时广告活动节点仍单独映射到 `AdvertisingPre`。
- 2026-05-20 `MainCom` 字段补查：`forecast` 对应 `zjm_btn_forecast`，`advertising` 对应 `advertisingbtn`，`elevate` 对应 `zjm_icon_elevate`，`btncymz/cymz` 对应 `zjm_icon_cymz`/次元魔战活动。Godot 已补 `活动预告`、`广告奖励`、`升阶礼包` 和 `次元魔战` 的入口映射；其中 `zjm_icon_cymz` 继续尊重原始 `active=false`，不会无条件显示。
- 2026-05-20 `openkuafuPanel()` 源码补查：`MainUIPanel` 有跨服 PVP 打开方法，`PanelManager.openKuafuPvpPanel()` 对应 `Prefab/KuafuPvpPane/KuafuPvpPre`。但 `MainPre.json` 未找到跨服可见节点或字段绑定，所以当前只导出 `跨服PVP` prefab 作为预览资源，不放入主屏入口矩阵。
- 2026-05-20 战斗状态节点补查：`MainPre` 的 `jingJiBattle/TianTiBattle/cymzBattle` 均默认隐藏，源码由 `setJingJiBattle/setTianTiBattle/setMozhuBattle` 在竞技、天梯、次元魔战战斗流程中临时显示。它们是返回/状态提示，不是菜单按钮。
- 2026-05-20 `MainCom` 绑定/社区入口补查：`bind -> bindCount()` 使用 `payPanel/BindPre`，并由 `CG_GET_BIND_PALTFORM_QUERY(2)` 控制显示；`discordBtn -> openDiscord()` 会请求 `CG_GET_BIND_PALTFORM_REWARD(2)` 并打开 Discord 链接，另有 `DiscordActivityPanel.preUrl="Prefab/ActivityPanel/discordActivity/discordActivityPre"`。Godot 已补 `绑定平台` 和 `Discord活动` prefab 预览，但保持原始显隐状态，`discordBtn` 默认隐藏。
- 2026-05-20 主屏活动显隐规则补查：`MainUIPanel.onfrist()` 会先把 `libao/fuli/huodong/kaifu/ghz/skin/wangzhe/dagong/tianti/cymz/pass` 全部隐藏，后续 `YunyingHandler` 根据 panelId 再打开。`PANEL_ID_10000` 打开 `pass`，`PANEL_ID_6000` 打开顶部 `libaoBtn`，而 `MainCom.onShow()` 还同时给活动矩阵里的 `libao` 和顶部 `libaoBtn` 都绑定 `openlibao()`。Godot 已把“礼包”明确指向活动矩阵实例 `zjm_icon_libao` 的第二个 occurrence，并补出 `zjm_icon_pass -> 通行证` 入口。
- 主屏活动矩阵不能完全照搬 `screen_rect`：原节点挂在可滚动/偏移父容器下，第一列导出后落在屏幕外侧。当前按 prefab 网格间距保留，但对 x 小于左侧快捷栏右边界的节点做最小 x 钳制，避免压住左侧快捷按钮。
- 主城默认 `105004` 应照 `Prefab/HerolhPrefab/105004` 的 Skeleton 子节点坐标 `(-68,-333)` 和 scale `(1,0.95)` 放到 `MainPre.herolh` 全屏容器下；如果武器或头发遮住按钮，优先修 Godot/Cocos 层级映射，不要为了避让按钮改角色尺寸和坐标。当前主屏 UI 层已显式高于 Spine slot 子节点。
- 已确认 `assets/resources/config.json` 是完整 Cocos 资源路径表，`paths` 里记录逻辑路径、类型和 UUID 下标，`uuids` 里记录压缩 UUID。现有 `data/named_resource_index.json` 只有一部分路径，不能作为完整资源索引。
- 已新增 `tools/export_cocos_config_index.py`，可把 `assets/resources/config.json` 拆到 `data/config_index`。当前统计 resources bundle 共 17141 条路径资源，其中 `cc.SpriteFrame=8139`、`cc.Texture2D=4744`、`cc.Prefab=1007`、`sp.SkeletonData=993`、`cc.AudioClip=1061`。
- 后续查资源优先看 `data/config_index/by_path_prefix`：主城静态图标/按钮查 `image__com__mainpanel.json`，主城 prefab 查 `Prefab__mainpanel.json`，英雄页查 `Prefab__HeroPanel.json` / `image__com__HeroListPanel.json`，抽卡查 `Prefab__DrawCard.json` / `image__com__DrawCard.json`。
- `texture_path` 为空不一定代表资源不存在。很多 prefab 节点没有直接挂 `_spriteFrame`，但节点名与 `config.json` 的 `image/com/<模块>/<节点名>` 路径一致，例如 `zjm_btn_rukou0`、`zjm_icon_baoju`、`cm_icon_ChengZhen`。
- `texture_path` 不为空也不一定可信。若导出节点名和 SpriteFrame 名明显不一致，优先用节点名到 `data/config_index/by_path_prefix/image__com__<模块>.json` 回查。例如主屏 `zjm_icon_zhaohuan` 在右侧多处被 layout 复用，但真实入口图标应按功能改为 `zjm_icon_yinghun`、`zjm_icon_duanzao`、`zjm_icon_zhanbu`、`zjm_icon_xunxing`、`zjm_icon_shanghui`。
- 手工页图标选择优先级：`screen_rect` 取坐标；资源先用同名 `image/com/<模块>/<node_name>`；若 prefab 子节点引用了错误/重复图标，再用功能名映射到 config 里确认的 SpriteFrame；最后才使用旧的手工 atlas fallback。
- 活动矩阵属于滚动/偏移容器，`screen_rect` 只能作为网格相对位置依据，不能完全照搬第一列导出坐标。当前主屏把小于 `x=88` 的活动入口钳制到可见区，避免压住左侧快捷栏；同时尊重 `MainPre` 的 `active=false` 默认状态，`zjm_icon_pvpActivity` / `zjm_icon_stssActivity` 等运行期活动必须等源码中的剩余时间或服务器活动状态打开，否则会无条件叠到主角区域。
- 右侧九入口的 `screen_rect` 已经包含父节点旋转/缩放后的最终画布位置；手工实现不要再对入口容器额外 `rotation=-8`。背景、图标、label、红点都应以导出的子节点坐标为准，当前已去掉二次旋转和默认红点。
- `tools/export_cocos_prefab_layout.py` 已新增 `config.json` 兜底解析：当 prefab 引用缺失时，会按资源路径推断 SpriteFrame UUID，再解析 import/native/rect/originalSize/offset/rotated/capInsets。
- 底部导航 `cm_tab_ZhaoHuan` 没有 `image/com/mainpanel/cm_icon_ZhaoHuan`，当前确认源码中 `btn3` 是召唤入口，静态替代资源使用 `image/com/mainpanel/zjm_icon_zhaohuan`；动态抽卡资源在 `uispine/ZhaoHuan*`，属于抽卡页效果，不是底栏静态图标。
- `daohangPre` 的 `moneyBox` 是运行时空容器，没有静态货币子节点。源码 `DaohangPanel.creatMoney()` 只实例化两个 `MoneyItem`：钻石 `x=521`、金币 `x=319`，再挂到 `moneyBox` 下；这些 x 是 `moneyBox` 局部坐标，不要再用 Cocos 全屏原点转换。Godot 主屏为了贴合截图把两个货币条放在顶部右侧，但数量仍保持两个。
- 顶部 SHOP 和货币条都来自 `daohangPre` 运行时组合，不是 `MainPre` 静态节点。当前 Godot 维持两个货币条并向右收拢，避免与 `cm_icon_Shop` 重叠；后续如果补真实 `MoneyItemPre` 实例布局，应统一由 `moneyBox` 局部坐标计算。
- 底部导航不要再混用手工 atlas fallback。源码 `DaohangPanel.init()` 默认选中 `IconTs/cm_tab_ChengZhen1`，`changeTabPanel()` 每次也是在 `IconTs` 或 `cm_icon_ChuJi` 下取对应选中节点；因此 Godot 侧应直接用 `daohangPre.json` 的图标节点 `cm_tab_ChengZhen1/cm_tab_YingXiong1/cm_tab_ZhaoHuan/cm_tab_ChuJi1/cm_tab_FuBen/cm_tab_GongHui1` 加载 SpriteFrame。
- 底部导航文字不是按钮子控件里的本地排版，而是各图标节点下的 `dt1` 子节点。Godot 主屏已按 `parent_index` 查 `dt1`，使用其 `screen_rect` 绘制文字：城镇 `[164.645,674.969,44,27.72]`、英雄 `[347.102,675.616,44,27.72]`、召唤 `[522.099,675.969,44,27.72]`、冒险 `[702.662,668.612,44,27.72]`、副本 `[887.368,674.969,44,27.72]`、公会 `[1065.148,674.969,44,27.72]`。不要再把文字放到图标容器底部按 `box.size.y - 37` 计算。
- 底部导航当前核对结果：`btn1` 城镇 `cm_tab_ChengZhen1` -> `cm_icon_ChengZhen`；`btn2` 英雄 `cm_tab_YingXiong1` -> `cm_icon_YingXiong`；`btn3` 召唤 `cm_tab_ZhaoHuan` -> `zjm_icon_zhaohuan`；`btn4` 冒险 `cm_tab_ChuJi1` -> `cm_icon_ChuJi`；`btn5` 副本 `cm_tab_FuBen` -> `cm_icon_FuBen`；`btn6` 公会 `cm_tab_GongHui1` -> `cm_icon_GongHui rotated=true`。点击热区继续以 `btn1..btn6` 的 prefab `screen_rect` 为准。
- 游戏源码设计画布是 `1280x720`：`Global.STAGE_WIGTH=1280`、`STAGE_HEIGHT=720`，Godot `project.godot` 也设置为 `1280x720`。当前遮挡问题主要来自滚动容器导出的活动矩阵和手工层级，而不是横屏宽高比设置错误。
- `daohangPre` 底栏真实节点尺寸：`btn1..btn6` 热区均为 `120x120`；图标节点 screen_rect 分别是城镇 `[115.645,585.329,152,141]`、英雄 `[284.102,583.476,150,142]`、召唤逻辑位 `[481.599,591.329,125,123]`、冒险 `[645.211,582.972,150,145]`、副本 `[842.368,589.329,134,133]`、公会 `[1027.648,592.829,119,126]`；底栏背景 `cm_menu_BeiJing` 是 `[-493,540.552,2266,181]`，中央光 `cm_menu_TaiYangGuang` 是 `[451.254,601.201,340,97]`。主屏应按这些 1280x720 坐标落位，不要再按截图比例二次压缩。
- `daohangPre.json` 里 `cm_menu_BeiJing` 的 `texture_path/sprite_name` 会被解析成 `cm_menu_TaiYangGuang`，这是导出器解析错误。真实底栏背景必须从 `config.json` 查 `image/com/mainpanel/cm_menu_BeiJing`：SpriteFrame UUID `8c4e3857-d4f4-43d8-a7bc-04d1327e2a77`，Texture2D/native 为 `assets/resources/native/f5/f58085bc-21e6-40ed-a4cf-b55f6b0cc8f9.png`，rect `[0,0,2266,181]`。Godot 侧已改为手工指定该 native，不能再直接信 `daohangPre` 的贴图字段。
- `DaohangPanel.init()` 会把 `taiyang` 和 `DaoHangGuang` 的 x 对齐到 `btn1.x`，默认选中城镇。当前 Godot 将 `cm_menu_TaiYangGuang` 单独绘制并对齐 `btn1`，透明度降低，避免选中光误停在中间并遮住主城角色脚部。
- `DaohangPanel.changeTabPanel()` 源码底栏路由：`btn1 -> openchengzhen()`，`btn2 -> openHeroPanel()`，`btn3 -> openZhaohuanPanel()`，`btn4 -> openchujiPanel()`，`btn5 -> openmaoxianPanel()`，`btn6 -> opengonghuiPanel()`。本地 Demo 对应为：城镇留在主屏、英雄列表、抽卡、主线/挂机预览、副本冒险地图预览、公会预览；`btn5` 不应再误指向天空城。
- 2026-05-20 公会主界面源码复核：`GuildMainPanel.onShow()` 绑定 `btnBoss/btnRedbao/btnSkill/btnDetail/btnBattle/btnShop/btnTask/btnDonate`，分别进入公会首领、红包、科技、详情、公会战、公会商店、任务、捐献；`bossBattle/gongHuiBattle` 是战斗恢复提示节点，默认隐藏，不是普通入口。Godot 公会预览已按这条源码链补齐点击路由。
- 2026-05-20 底栏文本/路由二次修正：`openchujiPanel()` 不是直接打开 `Prefab/Battle/battle`，而是主线/挂机入口，源码会 `CG_BATTLE_QUERY()` 并由 `GuajiContro/guajiPanel` 进入 `Prefab/guajiPanel/guajiPrefab`；`openmaoxianPanel()` 才打开 `MaoxianMapPreTop/MaoxianMapPreBotton`。Godot 已把 `btn4` 显示为“冒险”并打开 `挂机主线` 预览，把 `btn5` 显示为“副本”并打开 `冒险地图顶部`。
- 2026-05-20 挂机世界地图源码补查：`WorldMapPanel.preUrl="Prefab/guajiPanel/worldMapPre"`，但真实地图图片不在 prefab 静态节点中，而是在 `uilist` 中动态预加载 `map/worldMap/map/images/world_01..world_45` 和 `worldMapItemPre`。因此 `worldMapPre` 导出后贴图很少是正常现象；`cocos_prefab_preview.gd` 已对“挂机世界地图”额外绘制这些动态地图缩略图。
- 2026-05-20 挂机主线入口补查：`guajiPanel.onShow()` 绑定 `saodang/zhandoubtn/guajiTimebtn/tgBox/tgReword/rank/zhanbao/task/minmapbg/longBtn/cardBtn/right/tisheng/lineReward/tongguanyl`。本地预览已为“挂机主线”补运行时入口层，明确小地图、战斗、扫荡、章节、升级、排行、战报、任务等源码目标；`original_home_screen.gd` 的“初级”旧别名也改为 `挂机主线`。
- 已补导出 `Prefab/MaoxianPanel/MaoxianMapPreTop` 和 `Prefab/MaoxianPanel/MaoxianMapPreBotton`，manifest 标签为“冒险地图顶部/冒险地图底部”。后续要继续还原 `openMaoxianUIPanel()` 时，应从这两个 prefab 与 `MaoxianMapTopPanel/MaoxianMapBottonPanel` 源码开始，而不是用 `SkyCityPre` 代替。
- `MaoxianMapTopPanel.preUrl="Prefab/MaoxianPanel/MaoxianMapPreTop"`，进入冒险地图时默认打开顶部地图；`MaoxianMapBottonPanel.preUrl="Prefab/MaoxianPanel/MaoxianMapPreBotton"` 是下半区地图。`MaoxianMoveCom.touchEnd()` 根据滑动方向在两个 Panel 间切换：顶部向上滑打开底部，底部向下滑回顶部。
- `MaoxianMapTopPanel` 源码入口：`rongyaoBtn -> openRongyao()` 打开 `ShiLuoFanePanel/失落神庙`，`mingyunBtn -> openMingyun()` 打开 `SkyCityPre/天空城`，`yijiBtn -> openYiji()` 查询并进入 `yjTreasurePre/遗迹探险`，`binglongBtn -> openBinglong()` 查询冰龙副本。`tab1` 点击切到 `MaoxianMapPreBotton`。`FuBenPre` 是地图内部的副本列表面板，已补导出为“冒险副本”。
- 冒险地图 prefab 的 `mapBox1/mapBox2/bg` 是大地图容器或空节点，真正可见地图由其子节点 Sprite 和 label 组成；不要再用手写 mock 覆盖。当前 `cocos_prefab_preview.gd` 对“冒险地图顶部/底部”启用 clean prefab preview：隐藏工具栏/右侧说明/灰色占位框，只显示导出的真实贴图和文本。
- 冒险地图截图中的灰色区域不是工具栏遮挡，而是部分 Cocos SpriteFrame/动态节点仍未映射完整，且原始地图通过 1280x720 面板承载 1575x3072 大图和上下两段滚动视图。下一步若要精确显示，应继续修导出器的缺失 SpriteFrame 和 Scroll/Mask 初始偏移，而不是恢复旧的 `_add_maoxian_map_mock()`。
- 2026-05-20 已修 `tools/export_cocos_prefab_layout.py`：当 prefab 位于 `Prefab/MaoxianPanel/*` 且节点本身 SpriteFrame 解析不到 texture 时，按 `image/com/MaoxianPanel/<node_name>` 反查 `assets/resources/config.json`。同时对 `hongdian/tip` 兜底到 `image/common/cm_icon_HongDian`，`suo` 兜底到 `image/common/cm_icon_SuoDing`，`xsyd_frame9_lihuiming` 兜底到 `image/com/guide/xsyd_frame9_lihuiming`。
- 冒险地图贴图补齐结果：`MaoxianMapPreTop` 从 7 个 texture 节点提升到 35 个，仅剩 `tab1` 未映射；`MaoxianMapPreBotton` 从 7 个 texture 节点提升到 45 个，仅剩 `tab1/double` 这类运行状态节点未映射。`screenshots/codex_runtime/maoxian_fuller_top.png` 和 `maoxian_fuller_bottom.png` 可作为当前视觉基线。
- 主屏 SHOP 不是文字按钮，资源在 `image/com/mainpanel/cm_icon_Shop`，对应 atlas `assets/resources/native/1a/1a7921f32.png` 的 `[163,3,91,53]`。
- 已把 `TreasurePre`、`TeachListPre`、`zhanbuPre`、`ActivityYiwuPre`、`ActivityYiwuTapPre`、`HitWorkPre`、`DailyGiftPre`、`GiftPre`、`GuoqingActivity`、`ActivityXianShiLiHePre`、`ActivityTeHuiLiHePre`、`zhanshencomePre`、`JuHuiActivityPre`、`ZhaoHuanActivityPre`、`pvpActivityPanel`、`oldgodsgraceentrancePre`、`PreRegAvtivityPre`、`ElevatePre`、`AdvertisingPre`、`BindPre`、`discordActivityPre`、`moZhuPre`、`FriendPanel`、`EmailPre`、`RankListPanel`、`WarReportPanel`、`TaskPre`、`KeFuPanel`、`GuildWarHallPre`、`teamPre`、`tiantiPre`、`wangzhePre`、`SkinShopPre`、`HeroPalacePre`、`BigPassPanel`、`KnighthoodPanel`、`ForgePre`、`ActivityAuguryPre`、`FindTreasurePre`、`WelfarePre`、`firstRechargePre`、`StarUpPre`、`ActivityPre`、`ActivityForecastPre`、`BraveManTriedPassInfoPre`、`HeroShowPre`、`DrawRewardPreviewPre`、`useprivacyPre`、`shilingPre` 加入 `data/prefab_layouts`。这些页面还未全部手工实现，但可以从主屏或预览器打开查看原始布局。
- 2026-05-20 资源索引修正：`tools/export_named_resource_index.py` 已把 `image/common/cm_tab*` 加入导出，`image/common/cm_tab1_on/off` 现在可从 `named_resource_index.json` 命中真实 SpriteFrame，英雄列表右侧页签改回原始切片。`cocos_prefab_preview.gd` 对 `assets/resources/native/*` 增加 `converted/png|jpg|jpeg` 优先加载，`HeroPalacePre` 中 `1d9c822a-b0c7-4347-a697-1017eac7c334.png` 实际使用 `converted/jpg/1d9c822a-b0c7-4347-a697-1017eac7c334.jpg`，不再报 `ERR_FILE_CORRUPT`。
- 2026-05-20 英雄详情子页补查：`tools/export_cocos_prefab_layout.py` 已加入 `Prefab/HeroPanel/zhuangbeiBox` 与 `Prefab/HeroPanel/zhanyiBox`，导出 `data/prefab_layouts/zhuangbeiBox.json` / `zhanyiBox.json`。`HeroMainPanel.showTab()` 源码会切换背景并隐藏旧内容，装备/战意页不能继续叠加培养页的技能列和属性摘要；Godot 已按导出的 `screen_rect` 接入装备页 6 个装备位、2 个符文/神器位、“一键穿戴”，以及战意页 3 个战意节点、“战意预览”和帮助按钮。
- 2026-05-20 英雄详情衣装/升星补查：`HeroMainPanel.showTab()` 的 tab3 先调用 `HeroControl.CG_HERO_JUEXING_QUERY()`，`HeroControl.GC_HERO_JUEXING_QUERY()` 返回后由 `HeroMainPanel.initUpStarUI()/updateUpStarData()` 加载 `Prefab/HeroPanel/shengxingBox`；执行升星后的成功弹窗才是 `Prefab/HeroPanel/HeroUpgradeStarPre`。Godot 已导出 `shengxingBox.json` / `HeroUpgradeStarPre.json`，主详情页升星 tab 使用 `yx_img_ShengXing` 背景，并按 `shengxingBox` 的属性提升、材料位、英魂按钮和升星按钮坐标绘制。tab5 直接激活 `HeroMainPre.skinBox` 并调用 `CG_SKIN_HERO()`，`setSkinData()` 使用 `image/skin/showImg/<body>`、`skinInfo/name/attrNode/getBtn/wearBtn/takeBtn/playBtn/btnNext/noSkin`，Godot 已把 `image/skin/showImg/` 加入 `named_resource_index` 并按导出的 `skinBox` 坐标恢复衣装页主体。
- 2026-05-20 升星成功弹窗补查：`HeroUpgradeStarPre` 的可视字段包括 `content`、标题“升星成功”、`yhd_image_jiantou`、五行属性变化和技能提升提示。`yhd_image_jiantou` 真实资源路径在 `image/com/HeroPalace/yhd_image_jiantou`，已把 `image/com/HeroPalace/` 加入 `tools/export_named_resource_index.py`。Godot 现在点击升星按钮会打开本地成功弹层，按 `HeroUpgradeStarPre.json` 坐标显示属性变化并支持点击空白或“确定”关闭。
- 2026-05-20 战意页星级分支补查：`HeroMainPanel.setZhanyiBox()` 在 `dataHero.star < 13` 时隐藏 `zhanyi2`，`zhanyi1` 使用局部 `(434,119)`、`zhanyi0` 使用局部 `(291,-21)` 并旋转 180 度；`star >= 13` 时显示 `zhanyi2`，`zhanyi1` 旋转 -75 度，`zhanyi0` 旋转 165 度。Godot 战意页已按星级切换双节点/三节点布局，并把锁定文案从“100级解锁”改成星级解锁语义。
- 2026-05-20 装备页状态补查：`updateEquipBox()` 重置 6 个装备位，`equipBox5` 根据 `dynamicData.lv < 40` 显示 `suo/lock_open`，`equipBox6.needLv` 文案为“敬请期待”；`checkFuwengOpen()` 里 `fuwenIcon1` 用 100 级解锁，`fuwenIcon2` 用 7 星解锁；`updateEquitHongDian()` 同时控制装备格、符文格和 `btnChuanDai` 红点。Godot 装备页已补锁定暗层、符文解锁状态和本地红点。
- 2026-05-20 英雄详情交互链补查：`btn_xianQing -> PanelManager.openHeroAttrTipsPanel() -> Prefab/HeroPanel/HeroAttrTips`，`btnChuanDai -> HeroMainPanel.btnQuickPut()` 走服务器快速穿戴，`btnYuLan -> ForgeWarspiritPanel.open()` 且设置 `isWarpath=true`，战意帮助按钮调用 `HelpManeger.HELP_MISC_58`。`tools/export_cocos_prefab_layout.py` 已新增并导出 `HeroAttrTips`、`HeroEquipChangePre`、`HeroWarpathGraspPre`、`HeroWarpathUpPanel`、`ForgeWarspiritPanel`、`HeroWarpathPreviewPanel`；Godot 详情页把属性详情和战意预览接到 prefab 预览器，把服务器动作映射为本地离线提示。
- 2026-05-20 英雄详情左侧功能按钮补查：`HeroMainPanel.initButtonEvent()` 将 `HeroSidePrefab.imgSuo/imgPingLun/imgFenXiang` 分别绑定到锁定、评论、分享；`btnChaKan()` 进入隐藏 UI 的查看模式。Godot 左侧三个按钮已改为“全屏预览 / 评论 / 分享或锁定”，不再是只有 tooltip 的死按钮。
- 2026-05-20 英雄列表页签补查：`HeroListPanel.showTab()` 中 `menuType=3/4/5` 并不会跳出英雄列表，而是分别把 `HeroLevelSharedPre`、`HeroNormalarrayPre`、`HeroStarPre` 实例化到 `heroLevelShared/normalarrayNode/starNode`；只有 `btnYingHun` 调 `openHeroPalacePanel()` 打开独立英魂殿。Godot 英雄列表已改为在列表内容区嵌入这三个导出 prefab，英魂页签继续进入 `HeroPalacePre` 预览。
- 2026-05-20 英雄列表 `arrange/btnBuZhen` 补查：`btnBuZhen.on(... openBuZhen)` 设置 `CombatControl._formation = CmbFormation.FSZ` 后调用 `PanelManager.openBuzhen(... TYPE_COMBAT_TYPE1 ...)`，不是右侧 `btnNormalarray/changeTab4` 法阵页签。已导出 `Prefab/CombatPrefab/CombatFormPre` 为“布阵”，Godot 右下 `arrange` 改为打开布阵预览。
- 2026-05-20 英雄培养按钮补查：`HeroMainPanel.btnUpLv()` 走 `CG_HERO_LEVEL_UP()`，`btnJinJie()` 走 `CG_HERO_UPGRADE_QUERY()` 后打开 `HeroUpLvPanel`/`HeroBreakthroughPanel`，`btnReset()` 打开 `HeroResetPanel`；相关 prefab 是 `HeroUpLvPre`、`HeroBreakthroughPre`、`HeroResetPre`，升级链还会预加载 `HeroGetNewSkillsPre`。已导出这 4 个 prefab，Godot 培养页按钮改为进入对应原始预览。
- 2026-05-20 英雄装备页入口补查：`updateEquipBox()` 给 `equipBox1..6` 绑定 `equipBoxClick()`，空装备位进入 `HeroEquipChangePanel/HeroEquipChangePre`，符文位 `fuwenIcon1/2` 绑定 `onFuWenGridClick()`，空符文位进入 `SelectFuwenPanel/SelectFuwenPre`，符文刷新面板为 `FuwenRefreshPre`。Godot 装备格点击已接到“英雄装备替换”，符文位点击已接到“符文选择”，并导出 `SelectFuwenPre/FuwenRefreshPre`。
- 2026-05-20 英雄战意节点入口补查：`HeroMainPanel.initButtonEvent()` 给 `zhanyi0..2` 绑定 `onZhanyiClick()`；源码先判断 `imgLock.active`，锁定时提示 `lblLock`，未锁定时扫描 `this.skills`，已有 `index == t + 1` 则调用 `CG_BINGSHU_LEVELUP_QUERY()` 进入 `HeroWarpathUpPanel`，没有则设置 `HeroWarpathGraspPanel.index = t + 1` 并打开 `HeroWarpathGraspPre`。Godot 战意节点已补透明点击区：锁定显示本地星级提示，解锁空位打开“战意领悟”，并提供“战意升级”预览入口覆盖已学习分支。
- 2026-05-20 英雄侧栏评论/分享补查：`btnComment()` 根据当前 `dataHero.index` 从 `HeroListControl.dataArr` 找英雄并打开 `HeroCommentPanel/HeroCommentPre`；`btnShare()` 不打开新 prefab，而是激活 `HeroSidePrefab.fenxiangBox`，`kuaiFuShare/worldShare/gongHuiShare` 分别调用聊天分享类型。已导出 `HeroCommentPre`，Godot 侧栏评论按钮接到“英雄评论”预览，分享按钮改为本地三选菜单。同步导出 `SkinShowPre` 为“衣装展示”，用于后续衣装战斗效果预览链。
- 2026-05-20 抽卡单英雄展示补查：`HeroShowPre` 根节点是 `1578x720`，实际会左右超出 1280 视口；不能把内容强行塞进右侧信息面板。关键坐标来自导出 `screen_rect`：关闭 `close=[12,11,65,48]`，分享 `btnFenXiang=[1202,118,49,49]`，评论 `btnPingLun=[1202,192,49,49]`，再召 1 次 `btn_call1=[525,597,300,66]`，再召 10 次 `btn_call10=[904,597,300,66]`，英雄信息底板 `imgHeroInfoBg=[69,438,449,190]`，技能位走底部 `jinengBox1..4`。Godot `original_draw_hero_show.gd` 已按这些坐标重排，并补本地 `fenxiangBox` 世界/公会频道弹层。
- 2026-05-20 MP3 播放逻辑补查：`assets/resources/config.json` 中 `cc.AudioClip` 路径全部导出到 `data/config_index/by_type/cc.AudioClip.json`，音频逻辑路径按 `sound/cv`、`sound/skill`、`sound/UI`、`sound/bgm` 分类。`tools/analyze_audio_index.py` 已生成 `data/audio_index_summary.json`，统计为 1061 条 AudioClip：CV 759、技能 233、UI 60、BGM 8、story 1。英雄语音路径规则是 `sound/cv/<hero_id>/<sound_id>`，Godot 已统一用 `scripts/audio_utils.gd` 从 MP3 文件字节创建 `AudioStreamMP3`，英雄详情页、抽卡英雄展示页和资源浏览器共用这一套。
- 2026-05-20 加载页 BGM 修正：`sound/bgm/loading` 在 `cc.AudioClip.json` 中对应 UUID `d67e8f53-c2d7-4d01-a4b0-269ce67ca973`，native 为 `assets/resources/native/d6/d67e8f53-c2d7-4d01-a4b0-269ce67ca973.mp3`。`original_loading.gd` 已接入 `AudioUtils.play_mp3(..., loop=true)`，和 Cocos `playMusic` 类循环 BGM 行为对齐。
- 2026-05-20 英雄衣装页按钮补查：`setSkinData()` 会先隐藏 `getBtn/takeBtn/wearBtn`，再按 `0 == skinData.ind` 显示获取、`1 == skinData.isOn` 显示卸下，否则显示穿戴；`getSkin()` 调 `PanelManager.openSkinShop()`，`wearSkin/takeSkin` 调 `CG_SKIN_ON/OFF`，`showSkinEffect()` 调 `CG_ABS_ACT_HERO_COME_COMBAT(heroId, 1, body)`。Godot 衣装页已按这条链拆分获取/穿戴/卸下/展示：获取打开“皮肤商店”预览，穿戴状态本地保存，展示打开“衣装展示”预览。
- 2026-05-20 英雄技能/神器/水晶链路补查：培养页 `upSkillBox()/setSkillData()` 通过 `SkillGrid` 显示主动/被动技能，技能详情面板为 `HeroSkillTips`；装备页 `equipBox5` 对应水晶，空且未激活时走 `CG_SHUIJING_JIHUO()`，已有时 `PanelManager.openShuiJingGridTip()`；`equipBox6` 对应神器体系，核心面板为 `HeroShenQiPre/HeroShenQiUpgradePre`。已导出 `HeroSkillTips`、`HeroShenQiPre`、`HeroShenQiUpgradePre`、`HeroGetShuiJingPre`、`HeroShuiJingUpLevelPre`、`HeroShuiJingChangePre`、`HeroShuiJingResetPre`、`HeroShuiJingTipsPre`，Godot 技能格和装备第 5/6 位已接到对应预览入口。
- 2026-05-20 英雄共鸣子面板补查：`HeroLevelSharedItemCom` 的槽位事件会触发添加、锁定、英雄信息、移除和 CD 操作；相关弹层/面板是 `HeroLevelSharedHeroInfoPre`、`HeroLevelSharedRemovePre`、`HeroLevelSharedSuccessPre`、`AlertHeroLevelSharedPre`。已导出这 4 个 prefab，Godot 共鸣页在 `HeroLevelSharedPre` 内嵌 layout 右侧补了快捷预览入口。
- 2026-05-20 英魂殿子面板补查：`HeroPalacePanel.clickPaginationButtonCallback()` 根据按钮名切换 `synthesizeButton/heroDecomposeButton/heroShardDecomposeButton/rebirthButton/goBackButton/replacementButton`，懒加载 `HeroPalaceSynthesizePre`、`HeroPalaceHeroDecomposePre`、`HeroPalaceHeroShardDecomposePre`、`HeroPaleceRebirthPre`、`HeroPaleceGoBackPre`、`HeroPalaceReplacementPre`；相关弹层还有材料选择、分解预览、碎片预览、回退确认、置换成功和英魂详情。已导出这些 prefab，并在 `英魂殿` 预览器 overlay 中增加快捷入口。
- 2026-05-20 法阵/星辉子面板补查：英雄列表 `changeTab4/changeTab5` 懒加载 `HeroNormalarrayPre/HeroStarPre`，相关子 prefab 还包括阵容克制 `HeroFormationrestraintPre`，星辉节点/技能/升级 `StaritemPre`、`StarSkillPre`、`StarUpPre`、`skillUpPre`。已导出这些 prefab，Godot 法阵/星辉页内嵌 layout 右侧已补快捷预览入口。

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

已能从主屏打开但仍是 prefab 预览覆盖的入口：宝具、通行证、学院、锻造、占卜、寻星、打工、每日礼包、礼包、特惠活动、限时礼包、超级钜惠、召唤卡、组队竞技、天梯、王者争霸、公会战、竟榜抽奖、食铁神兽、皮肤商店、预注册、升阶礼包、广告奖励、绑定平台、Discord活动、次元魔战、好友、邮件、排行、战报、任务、客服、活动预告、活动、福利、首充、升星。它们已有原始 prefab layout，可作为下一阶段手工页实现依据。

尚未做到一一对应的主要原因：

- 原游戏不少页面由一个主 prefab 加多个运行时子 prefab 组合，不能只按入口 prefab 静态还原。
- 活动页由 `ActivityType.prefabArray` 和服务端 panelId 决定展示内容，本地 Demo 目前只做离线可视化，不模拟服务端活动状态。
- 部分系统入口需要战斗/养成/背包数据驱动，当前仅用静态资源和本地 mock 数据展示。
