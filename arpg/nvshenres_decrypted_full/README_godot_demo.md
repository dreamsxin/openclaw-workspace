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
- 登录流程：启动加载页 -> 正式选服页 -> 连接服务器提示 -> 原始主城页；`LoginPre` 只作为 debug 直连页保留。
- 原始 Cocos 启动入口是 `assets/src/settings.js` 的 `Scene/updataScene.fire`，随后 `GameWorld.init()` 调用 `LoadingPanelNode.open()`。`loadingComplete()` 预加载 `Prefab/login/pfLoginPanelPre/MainPre/daohangPre` 等公共资源；非 debug 模式进入 `PFLoginPanel.getLastSever()`，debug 模式才进入 `LoginPanel.showProgess()`。当前 Godot 主流程已按此改为 `LoadingPre -> pfLoginPanelPre`，缺少真实服务器请求和连接握手。
- 主城页保留了导航按钮，可进入资源浏览器、Prefab 预览器和旧的浮岛主城预览。
- 主城底部导航第三个入口已按原始 `daohangPre.btn3/cm_tab_ZhaoHuan` 修正为“召唤”，点击进入本地抽卡页；仓库入口保留在右侧入口条。
- `DaohangPanel.changeTabPanel()` 的底栏源码路由已核对：`btn4` 是 `openchujiPanel()` 主线/挂机入口，`btn5` 是 `openmaoxianPanel()` 冒险副本地图，二者不是同一个页面。Godot 底栏现在按原始资源名区分为“冒险”->`Prefab/guajiPanel/guajiPrefab` 预览，“副本”->`MaoxianMapPreTop` 预览。
- `MainUIPanel.onShow()` 的右侧入口绑定已核对：`yingHunDian` 调用 `openHeroPalacePanel()`，不是召唤。当前主屏右侧“英魂”进入 `英魂殿` prefab 预览；`HeroPalacePre` 已加入 `tools/export_cocos_prefab_layout.py` 并导出为 `data/prefab_layouts/HeroPalacePre.json`。
- `HeroPalacePanel` 不是单一静态页：源码 `clickPaginationButtonCallback()` 会在合成、英雄分解、碎片分解、重生、回退、置换间切换并懒加载 `HeroPalaceSynthesizePre`、`HeroPalaceHeroDecomposePre`、`HeroPalaceHeroShardDecomposePre`、`HeroPaleceRebirthPre`、`HeroPaleceGoBackPre`、`HeroPalaceReplacementPre`，还会打开材料选择、分解预览、回退确认、置换成功等弹层。Godot `英魂殿` 预览器已增加运行时页签 overlay，所有这些子 prefab 已可直接预览。
- 主屏右侧九入口按源码和 `MainPre.json` 文本修正为：宝具、仓库、竞技、学院、英魂、锻造、占卜、寻星、商会。`pass/通行证` 是另一个运行期活动入口，不是右侧第一项；`xunbao` 打开 `zhanbuPre`，`xunxing` 才打开 `FindTreasurePre`。
- 仓库页源码复核：`BagPanel.preUrl="Prefab/BagPanel/BagPre"`，构造时 `selectIndex=2`，`onfrist()` 给 `com.tab.children[0..4]` 绑定五个页签；`btn_item()` 按装备、道具、碎片、符文、神器切换，并用 `ceil(itemarr.length / 8)` 设置虚拟列表行数。`BagPre.scrollview` 是 `[134.226,71.222,996,560]`，`GridBoxItemPre` 物品框是 `110x110`，导出的占位格横向从 `x=165` 开始每 `120` 像素一个，所以 Godot 仓库页使用 8 列 `110x110` 格子，右侧页签使用 `button1..5` 的原始 y 坐标。
- 仓库子面板源码链路已补入导出：`btn_sellequip()` 打开 `BagSellEquipPanel.preUrl="Prefab/BagPanel/BagSellEquipPre"`；普通物品出售走 `SellGridPanel.preUrl="Prefab/BagPanel/sellGridPre"`；批量使用走 `UseItemPanel.preUrl="Prefab/BagPanel/piliangTipsPre"`；获取途径走 `ToobtainWayPanel.preUrl="Prefab/BagPanel/huoquTipsPre"`；碎片合成提示走 `HechengPanel.preUrl="Prefab/BagPanel/hechengTipsPre"`；自选礼包走 `GridBoxPanel.preUrl="Prefab/BagPanel/GridBoxPre"`；神器页图鉴走 `ShenQiHandBookPanel.preUrl="Prefab/HeroPanel/ShenQiHandBookPre"`。Godot 仓库页已按页签显示这些入口：装备页显示出售装备，道具页显示自选/使用/出售/获取，碎片页显示一键合成/使用/获取，符文页显示出售/获取，神器页显示神器图鉴/获取。
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
- `daohangPre` 的底栏背景节点 `cm_menu_BeiJing` 在导出 JSON 中被错误映射成太阳光 SpriteFrame。真实背景来自 `config.json` 的 `image/com/mainpanel/cm_menu_BeiJing`，native 是 `assets/resources/native/f5/f58085bc-21e6-40ed-a4cf-b55f6b0cc8f9.png`；选中光 `cm_menu_TaiYangGuang` 需要按 `DaohangPanel.init()` 对齐到 `btn1`。
- 主屏底部导航的图标和文字均来自 `Prefab/mainpanel/daohangPre`：图标节点为 `IconTs/cm_tab_ChengZhen1/cm_tab_YingXiong1/cm_tab_ZhaoHuan/cm_tab_FuBen/cm_tab_GongHui1` 以及 `cm_icon_ChuJi/cm_tab_ChuJi1`，文字来自这些节点下的 `dt1`。`original_home_screen.gd` 现在按 `screen_rect` 直接绘制，不再把文字按本地 `box.size` 放到图标下方，也不再把第三个召唤入口回退成仓库图标。

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
- 商店页坐标依据：`ShopPre.goodsScrollView` 是 `[269.456,64.114,834,662]`，内部 `view` 是 `[336.456,179.775,700,550]`，所以 Godot 商品滚动区使用 `panel=(269.456,64.114)`、`scroll=(67,115.661)`、两列 `350x120` 且列间距为 0；`mainTypeNode/MainItemPre1/2` 对应主页签 `x=312.671/547.888,y=86.602,w=150,h=40`；`shopTypeScrollView` 是 `[1069,138.388,250,480]`，`ShopItemPre` 单项 `180x64`，源码 `showShopData()` 每项向下间隔 `height+30`；`freeRefresh/chargeRefresh` 原始按钮宽约 `196x54`，运行时根据 `refreshType` 切换显示。
- 主城右侧九个入口已修复可点击性：可视斜条继续按原始布局旋转显示，点击使用独立顶层矩形命中层，并在 `_input` 中按设计坐标分发，避免旋转 Control 和角色 hit 区截获鼠标事件；红点也移到图标右上角，避免遮住入口图标。
- 主城底部导航也使用独立命中层和 `_input` 坐标兜底；底部“英雄”按钮已验证不会再被主城角色 Spine/角色点击区挡住，回归参数为 `--home-click-at 359,654 --capture-hero-list <png>`。
- 主屏入口回归命令示例：
  - 主屏截图：`D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full --scene res://scenes/original_home_screen.tscn --resolution 1280x720 --log-file logs/codex_runtime/home.log --quit-after 80 -- --capture-home-screen screenshots/codex_runtime/home.png`
  - 打开右侧英魂：`D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full --scene res://scenes/original_home_screen.tscn --resolution 1280x720 --log-file logs/codex_runtime/home_yinghun.log --quit-after 100 -- --home-open-entry 英魂`
  - 单独预览英魂殿：`D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full --scene res://scenes/cocos_prefab_preview.tscn --resolution 1280x720 --log-file logs/codex_runtime/prefab_heropalace.log --quit-after 80 -- --prefab-layout 英魂殿 --capture-prefab-preview screenshots/codex_runtime/prefab_heropalace.png`
- PowerShell 重定向日志时不要写 `$log.stdout`，这会被解析成变量属性。应使用独立变量，例如 `$stdout = "$log.stdout"; & $godot ... *> $stdout; Select-String -Path $log,$stdout -Pattern 'SCRIPT ERROR|Parse Error|ERROR'`。
- `HeroPalacePre` 的 `assets/resources/native/1d/1d9c822a-b0c7-4347-a697-1017eac7c334.png` 文件头不是 PNG；预览器现在优先查找 `converted/png|jpg|jpeg` 同名文件，实际加载 `converted/jpg/1d9c822a-b0c7-4347-a697-1017eac7c334.jpg`，避免 Godot 回归日志出现 `ERR_FILE_CORRUPT`。
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
- `data/prefab_layouts/LoadingPre.json`：完整启动加载页 prefab。`LoadingPanelNode.isFist=0` 是普通启动加载，显示 `dl_progressbg1_jiazai/expMask/ani/t3`；`isFist=1` 是连接服务器 alert 模式，隐藏进度条和 `ani/t3`，显示 `alert`。
- `data/prefab_layouts/LoginPre.json`：debug 直连登录页 prefab，源码 `LoginPanel.preUrl="Prefab/login/LoginPre"`。它有四个输入框 `tbg1~tbg4`，用于 IP、端口、账号、密码，不是正式玩家选服页。
- `data/prefab_layouts/pfLoginPanelPre.json`：正式平台登录/选服页 prefab，源码 `PFLoginPanel.preUrl="Prefab/login/pfLoginPanelPre"`。`PFLoginCom` 绑定 `txtServer/btnSelect/btnStart/nodeSv/nodeGG/nodeAlert/cheks/ysTxt/shilingBtn` 等；`PFLoginPanel.onShow()` 会触发公告，截图主体可加 `--no-auto-notice`。
- `data/prefab_layouts/MoneyItemPre.json`：资源条 prefab，主城顶部金币/钻石条使用。
- `data/prefab_layouts/MaoxianMapPreTop.json`、`data/prefab_layouts/MaoxianMapPreBotton.json`：冒险地图上下两层 prefab，主屏底栏 `btn5` / `openMaoxianUIPanel()` 的还原入口。
- `data/prefab_layouts/FuBenPre.json`、`fubenItemPrefab.json`：冒险地图内部副本列表和条目。顶部地图运行时入口已按源码标出：荣耀之路->失落神庙，命运->天空城，遗迹探险->`yjTreasurePre`，冰龙巢穴->冰龙引导/副本。
- `data/prefab_layouts/yjTreasurePre.json`、`shiLuoFanePre.json`、`BingLongGuidePre.json`：冒险地图顶部几个大入口的后续面板。
- `data/prefab_layouts/guajiPrefab.json`：底栏 `btn4/openchujiPanel()` 对应的主线/挂机面板主体。源码会先 `CG_BATTLE_QUERY()`，再由挂机控制器打开 `guajiPanel`，不是直接进入 `Prefab/Battle/battle`。
- “挂机主线”预览页额外覆盖 `guajiPanel.onShow()` 的运行时绑定：小地图、战斗、扫荡、章节、升级、排行、战报、任务等入口都会指向当前已导出的本地页面或 prefab 预览。
- `data/prefab_layouts/worldMapPre.json`、`worldMapItemPre.json`、`WorldtgMapPre.json`、`GuajiZhangjiePre.json`、`GuajiupPre.json`：挂机主线相关子界面，用于后续还原章节地图、通关地图、章节选择和升级面板。`worldMapPre` 本体只保存框架，真实世界地图图片由源码 `WorldMapPanel.uilist` 动态加载 `map/worldMap/map/images/world_01..world_45`；Prefab 预览器已为“挂机世界地图”补一层动态资源缩略预览。
- `data/prefab_layouts/TreasurePre.json`：主屏右侧“宝具”入口，源码 `baoju -> openTreasurePanel()`。
- `data/prefab_layouts/TeachListPre.json`：主屏右侧“学院”入口，源码 `teach -> openTeachListPanel()`。`BraveManTriedPassInfoPre` 是学院塔/试炼信息页，不是右侧学院入口。
- `data/prefab_layouts/zhanbuPre.json`：主屏右侧“占卜”入口，源码 `xunbao -> openZhanbu()`。
- `data/prefab_layouts/FindTreasurePre.json`：主屏右侧“寻星”入口，源码 `xunxing -> openXunbao()`。
- `data/prefab_layouts/ActivityAuguryPre.json`：活动面板内的占卜活动子页，当前在 manifest 中标为“活动占卜”，避免和主屏右侧“占卜”混淆。
- `data/prefab_layouts/ActivityYiwuPre.json`、`ActivityYiwuTapPre.json`、`HitWorkPre.json`：左侧活动“打工”入口，源码 `opendagong() -> PanelManager.open(PANEL_ID_3610)`，不是右侧学院入口。
- `data/prefab_layouts/DailyGiftPre.json`：左侧活动矩阵“每日礼包”，源码 `daily -> openDailyGift() -> PANEL_ID_3200`。
- `data/prefab_layouts/GiftPre.json`：左侧活动矩阵“礼包”，源码 `openlibao -> PANEL_ID_6000 -> GiftPanel.open()`。
- `data/prefab_layouts/BigPassPanel.json`：主屏活动“通行证”，源码 `pass -> openPassPanel()`，由 `PANEL_ID_10000` 活动状态打开。
- `data/prefab_layouts/GuoqingActivity.json`：左侧活动矩阵“特惠”，源码 `thank -> openThank() -> PANEL_ID_5000`，源码模块名是 `guoqingPre`，catalog 中 prefab 路径为 `Prefab/ActivityPanel/guoqingactivity/GuoqingActivity`。
- `data/prefab_layouts/ActivityXianShiLiHePre.json`：左侧活动矩阵“限时”，源码 `openxianshi()` 只处理 `PANEL_ID_7010/7021`，两者共用限时礼包面板。
- `data/prefab_layouts/ActivityTeHuiLiHePre.json`：绝对活动特惠礼盒子页，后续还原 `PANEL_ID_7000/特惠礼盒` 时使用。
- `data/prefab_layouts/zhanshencomePre.json`：开服活动 TYPE_3 的战神降临子页，当前作为“新服/开服”入口的 prefab 预览目标。
- `data/prefab_layouts/JuHuiActivityPre.json`：左侧活动矩阵“超级钜惠”，源码 `juhui -> openJuHui() -> PANEL_ID_7101`。
- `data/prefab_layouts/ZhaoHuanActivityPre.json`：左侧活动矩阵“召唤卡”，源码 `openZhaoHuanActivity() -> PANEL_ID_14200`。
- `data/prefab_layouts/pvpActivityPanel.json`：左侧活动矩阵“竟榜抽奖”，源码 `openPvpActivity()`。
- `data/prefab_layouts/oldgodsgraceentrancePre.json`：左侧活动矩阵“食铁神兽”，源码 `openstssActivity()`。
- `data/prefab_layouts/PreRegAvtivityPre.json`：左侧活动矩阵“预注册”，源码 `openPreregActivity() -> PANEL_ID_15000`。
- `data/prefab_layouts/ElevatePre.json`：左侧活动矩阵“升阶礼包”，源码 `openElevateGift() -> PANEL_ID_14400`。
- `data/prefab_layouts/AdvertisingPre.json`：运行时广告奖励入口，源码 `openAdvertisingPanel() -> PANEL_ID_14000`。
- `data/prefab_layouts/BindPre.json`：绑定平台弹窗，源码 `bind -> bindCount()`，由平台绑定查询控制是否显示。
- `data/prefab_layouts/discordActivityPre.json`：Discord 活动面板，源码 `DiscordActivityPanel.preUrl`；主屏 `discordBtn` 默认隐藏。
- `data/prefab_layouts/moZhuPre.json`：左侧活动矩阵“次元魔战”，源码 `openCymz() -> PANEL_ID_2801`；原始 `zjm_icon_cymz` 默认隐藏，活动状态打开后才显示。
- `data/prefab_layouts/FriendPanel.json`：左侧快捷“好友”，源码 `openhaoyouPanel() -> openFriendPanel()`。
- `data/prefab_layouts/EmailPre.json`：左侧快捷“邮件”，源码 `openyoujianPanel() -> openEmailPanel()`。
- `data/prefab_layouts/RankListPanel.json`：左侧快捷“排行”，源码 `openpaihangPanel() -> openRankList()`。
- `data/prefab_layouts/WarReportPanel.json`：左侧快捷“战报”，源码 `openzhanbaoPanel() -> openWarReport(0)`。
- `data/prefab_layouts/TaskPre.json`：左侧快捷“任务”，源码 `opentaskPanel() -> openTask()`。
- `data/prefab_layouts/KeFuPanel.json`：左侧快捷“客服”，源码 `openKeFuPanel()`；Godot 原先显示成“新闻”的节点已按源码改名。
- `data/prefab_layouts/GuildBossPre.json`：公会主界面“公会首领”，源码 `GuildMainPanel.openBoss()`。
- `data/prefab_layouts/GuildRedBagPre.json`：公会主界面“公会红包”，源码 `GuildMainPanel.openRedbao()`；原始主界面默认隐藏红包按钮。
- `data/prefab_layouts/GuildSciencePre.json`：公会主界面“公会科技”，源码 `GuildMainPanel.openskill()`。
- `data/prefab_layouts/GuildXiangqingPre.json`：公会主界面“公会详情”，源码 `GuildMainPanel.openDetail()`。
- `data/prefab_layouts/GuildWarHallPre.json`：左侧活动矩阵“公会战”，源码 `openGuildWarPanel()`。
- `data/prefab_layouts/GuildTaskPre.json`：公会主界面“公会任务”，源码 `GuildMainPanel.openTask()`，原游戏等待 `CG_UNION_LIVENESS_QUERY()` 回包后展示。
- `data/prefab_layouts/GuilddonationPre.json`：公会主界面“公会捐献”，源码 `GuildMainPanel.openDonate()`，原游戏等待 `CG_UNION_DONATE_QUERY()` 回包后展示。
- `data/prefab_layouts/teamPre.json`：左侧活动矩阵“组队竞技”，源码 `openPvp() -> openJingjiZuDui()`；右侧“竞技”仍对应 `JingjiPre`。
- `data/prefab_layouts/KuafuPvpPre.json`：跨服 PVP 面板，源码 `openkuafuPanel() -> openKuafuPvpPanel()`。当前 `MainPre` 未找到可见跨服入口或 `MainCom` 字段绑定，只作为独立 prefab 预览资源。
- `data/prefab_layouts/tiantiPre.json`：左侧活动矩阵“天梯”，源码 `openTianti() -> PANEL_ID_3402`。
- `data/prefab_layouts/wangzhePre.json`：左侧活动矩阵“王者争霸”，源码 `openwangzhe() -> PANEL_ID_1803`。
- `data/prefab_layouts/SkinShopPre.json`：左侧活动矩阵“皮肤”，源码 `openSkinShop() -> PANEL_ID_2014`。
- `data/prefab_layouts/ShopPre.json`：商会/黑市商店 prefab，主屏 `openShop()` 的目标。
- `data/prefab_layouts/GoodsItemPre.json`：商店商品卡 prefab，含 `GoodsItemCom` 的 `discount/rare/fight/prize/limit/selectBtn` 绑定。
- `data/prefab_layouts/ShopItemPre.json`：商店右侧分类页签 prefab；源码 `ShopPanel.showShopData()` 会按 `-(height+30)` 纵向排布。
- `data/prefab_layouts/HeroMainPre.json`：英雄主界面 prefab，独立英雄页的中心 Spine、右侧信息面板和功能页签布局参考。
- `data/prefab_layouts/HeroBookDetailPre.json`：截图里的英雄详情/图鉴详情页主体 prefab。源码入口是 `HeroBookDetailPanel.preUrl="Prefab/HeroPanel/HeroBookDetailPre"`，包含 `heroBodyBox/skinBodyBox/rightBox/skinBox/infoToggle/skinToggle/btnChaKan/btnLingqu/btnPingLun` 等字段绑定。
- `data/hero_resource_inventory.json`：英雄资源完整清单，来自 `config.json`、`named_resource_index.json` 和反编译源码字段链。
- `data/hero_catalog.json`：Godot 英雄列表运行时目录，当前 75 个 6 位英雄 id，按 `SSS > SSR > SR > R > N` 排序。
- `HERO_RESOURCE_INVENTORY.md`：英雄资源分析文档，记录头像、图鉴、立绘 prefab、战斗 prefab、语音、皮肤/变体和离线品质推断规则。
- `tools/export_hero_resource_inventory.py`：重新生成英雄资源清单和 Godot 英雄目录的工具。
- `data/prefab_source_inventory.json/.csv/.md`：从 `prefabs.csv`、反编译源码 `preUrl/url` 和已有文档线索交叉生成的完整 prefab 索引。当前统计为 1018 个 prefab、492 个源码直接引用入口、129 个文档已知候选。
- `tools/export_prefab_source_inventory.py`：重新生成完整 prefab 资源索引的工具。下一步手工还原界面时，优先查看 `data/prefab_source_inventory.md` 的“源码高频入口”和“已知还原候选”。
- `data/prefab_layouts/HeroTabPre.json`：英雄页签 prefab，确认 `cm_tab2_on/off` 页签资源。
- `data/prefab_layouts/HeroListPre.json`：完整英雄列表页 prefab。当前 Godot 已新增独立 `original_hero_list_panel.tscn`，主屏“英雄”先打开列表；英雄背包卡点击进入 `HeroMainPre` 培养页模式，图鉴卡点击进入 `HeroBookDetailPre` 图鉴详情模式。
- `data/prefab_layouts/HeroGridPre.json`、`HeroBookItemPre.json`、`HeroLevelSharedPre.json`、`HeroNormalarrayPre.json`、`HeroStarPre.json`：英雄列表页的卡片、图鉴、共享等级、阵容和升星子 prefab 布局参考。
- 英雄列表当前按 `HeroListPre.content` 和源码 `HeroListPanel` 实现。关键源码在 `assets/main/index.js` 的 `HeroListPanelCom/HeroListPanel` 段：`btnHero -> changeTab1(menuType=1)`、`btnBook -> changeTab2(menuType=2)`、`btnShared -> changeTab3(menuType=3)`、`btnYingHun -> openYinghun()`、`btnNormalarray -> changeTab4(menuType=4)`、`btnStar -> changeTab5(menuType=5)`。因此右侧视觉/行为顺序按源码修正为“英雄、图鉴、共鸣、英魂、法阵、星辉”，其中英魂不是普通 `showTab` 页，而是打开 `HeroPalacePanel` 的入口，本地 Demo 已改为跳转 `英魂殿/HeroPalacePre` prefab 预览。
- 英雄列表源码布局规则：`initScrollView()` 负责英雄背包列表，先按 `HeroListControl.onHeroSortByHeroDataArr()` 排序，再按 `campType` 过滤，最后设置 `gridList.numItems` 和 `lblHeroCount=t.length/capNum`；`initScrollView2()` 负责图鉴，读取 `dataBookMap[campType]`，按 `heros.grade` 降序生成 `HeroBookItemPre`。`showTab()` 中英雄页显示全部阵营按钮，图鉴页隐藏 `btnTypeAll` 并默认 `campType=1`，共鸣/法阵/星辉隐藏阵营筛选和容量条。
- 共鸣、法阵、星辉不是英雄列表内的本地假卡片：源码 `changeTab3/changeTab4/changeTab5` 会懒加载 `HeroLevelSharedPre/HeroNormalarrayPre/HeroStarPre`。当前 Godot 点击这些右侧页签直接进入 `英雄等级共享/英雄阵容/英雄升星` prefab 预览。
- 英雄列表点击卡片进入详情依赖 `Navigation.go_with_args(HERO_DETAIL_SCENE, {"hero_id": id, "mode": "main|book"})`。注意列表里的右侧页签层和底部导航层是全屏父容器，必须设置为 `MOUSE_FILTER_IGNORE`，否则会挡住卡片点击；卡片同时绑定 `pressed` 和 `gui_input` 鼠标释放作为保险。
- 底部导航文字要覆盖在图标/按钮下半部，而不是排在图标下面。主屏直接使用 `daohangPre` 中每个 `dt1.screen_rect`；英雄列表和英雄详情页仍按同一视觉规则使用图标主体、`y≈25` 的文字叠加和阴影。
- `HeroListPre.scrollview/view` 的真实可视区是 `[109,101.552,900,568]`，不是早期手工版的 `900x432`；`HeroGridPre` 根尺寸是 `110x110`，英雄列表卡片已按 110 根尺寸重排头像、阵营、等级、星级、上阵/助战和红点。`HeroBookItemPre` 的根尺寸是 `108x374`，图鉴页优先加载 `image/heroBook/<id>` 长图，缺图时回退头像。
- `HeroListPanel.showTab()` 的 3/4/5 页签是列表内嵌子 prefab：共鸣 `HeroLevelSharedPre`、法阵 `HeroNormalarrayPre`、星辉 `HeroStarPre`；英魂按钮是独立 `openHeroPalacePanel()`。Godot 英雄列表复用 `cocos_prefab_layer.gd` 在内容区嵌入这三个 layout，便于继续按源码收敛。
- 法阵/星辉页的子 prefab 已继续导出：法阵克制为 `HeroFormationrestraintPre`；星辉节点和弹层包括 `StaritemPre`、`StarSkillPre`、`StarUpPre`、`skillUpPre`。Godot 在法阵和星辉内嵌页右侧补了这些快捷预览入口。
- 英雄列表右下 `arrange` 是 `btnBuZhen/openBuZhen()` 布阵入口，走 `CombatFormPre`，不要混同为右侧“法阵”页签；法阵页签是 `btnNormalarray/changeTab4()`。
- 英雄详情培养页的升级链已拆清：`btnUpLv -> HeroUpLvPre`，`btnJinJie -> HeroBreakthroughPre`，`btnReset -> HeroResetPre`，获得新技能弹窗为 `HeroGetNewSkillsPre`。这些都已导出，手工页按钮应优先打开真实 prefab 预览，不再只做文字提示。
- 英雄详情装备页入口：`equipBox1..6 -> HeroEquipChangePre`，`fuwenIcon1/2 -> SelectFuwenPre`，符文刷新为 `FuwenRefreshPre`。锁定提示仍按本地状态显示，但可点击入口应保留源码链路。
- `image/common/cm_tab1_on/off` 已通过 `tools/export_named_resource_index.py` 的 `image/common/cm_tab*` 前缀进入 `named_resource_index`，右侧页签使用原始 SpriteFrame；如果其他 common 资源缺失，优先扩展索引前缀而不是在界面脚本里写死替代图。
- 英雄详情源码入口已拆分：`HeroMainPanel.preUrl="Prefab/HeroPanel/HeroMainPre"` 是英雄背包列表点击后的培养/装备/升星页；`HeroBookDetailPanel.preUrl="Prefab/HeroPanel/HeroBookDetailPre"` 是图鉴单卡和 `GC_HERO_BOOK_SINGLE_QUERY()` 打开的图鉴详情。Godot 详情页使用 `--hero-mode main|book` 或 `Navigation` 的 `mode` 参数区分两种入口，当前主视觉仍共用一套手工布局，后续继续分别按两个 prefab 精修。
- `HeroMainPre` 的五个功能页签来自 `tab01..tab05`，导出坐标为 `x=608` 的中间竖列，资源由源码 `HeroMainPanel.hideTabOn()/showTab()` 指向 `image/common/cm_tab2_off/on`。Godot `main` 模式已按这些坐标和资源重排，不再使用旧版屏幕最右侧大页签。
- `HeroMainPre` 右侧内容区需要使用白板局部坐标，而不是复用图鉴详情偏移：`jinengBox1..4` 对应白板内 `x≈0,y≈90/174/259/348`，`btn_xianQing` 对应 `x≈329,y≈202`，`btnUpLv` 对应 `x≈112,y≈442`。当前 Godot `main` 培养页已按这组坐标放置技能列、详情按钮和升级按钮。
- `HeroMainPanel.showTab()` 切 tab 时会替换 `thisPanel.imgBg`：培养 `yx_img_PeiYang`，装备 `yx_img_ZhuangBei`，升星 `yx_img_ShengXing`，战意 `yx_img_ZhanYi`，衣装 `yx_skin_bg`。源码会先隐藏旧内容再加载对应子 prefab，非培养页不能叠加培养摘要。当前 Godot `main` 模式已导出并接入 `Prefab/HeroPanel/zhuangbeiBox`、`shengxingBox` 与 `zhanyiBox`：装备页按 6 个装备位、2 个符文/神器位和“一键穿戴”坐标绘制；升星页按属性提升、材料位、英魂按钮和升星按钮坐标绘制，点击升星会打开 `HeroUpgradeStarPre` 本地成功弹层；战意页按 3 个战意节点、“战意预览”和帮助按钮坐标绘制。衣装页使用 `HeroMainPre.skinBox` 的原始坐标，资源路径遵循源码 `image/skin/showImg/<body>`。
- `shengxingBox.btnYHD` 是升星材料里的英魂入口，当前本地 Demo 用 `Navigation.go_with_args(PREFAB_PREVIEW, {"layout":"英魂殿"})` 打开 `HeroPalacePre` 预览；预览器参数必须是 `layout`，不要使用旧的 `prefab` 键。
- 装备页状态来自 `HeroMainPanel.updateEquipBox()/updateEquitHongDian()/checkFuwengOpen()`：`equipBox5` 40 级前显示锁定，`equipBox6` 显示“敬请期待”，符文 1 需 100 级解锁，符文 2 需 7 星解锁；装备位和一键穿戴按钮红点由 `updateEquitHongDian()` 控制。Godot 已按这些规则补状态层。
- 培养页技能列来自 `HeroMainPanel.upSkillBox()/setSkillData()` 填充 `SkillGrid`，点击技能时进入 `HeroSkillTips`；装备页 `equipBox5` 走水晶提示或激活，`equipBox6` 走神器体系，相关 prefab 包括 `HeroShuiJingTipsPre`、`HeroGetShuiJingPre`、`HeroShenQiPre`、`HeroShenQiUpgradePre`、`HeroShuiJingUpLevelPre/ChangePre/ResetPre`。Godot 已把技能格接到“英雄技能提示”，装备第 5/6 位分别接到水晶/神器预览。
- 英雄详情交互入口继续按源码落地：属性详情按钮打开 `HeroAttrTips` prefab 预览；装备页“一键穿戴”对应源码 `btnQuickPut()`，本地 Demo 不连服务器，只显示离线模拟提示；战意页 `btnYuLan` 打开 `ForgeWarspiritPanel` prefab 预览，帮助按钮对应 `HelpManeger.HELP_MISC_58`，`zhanyi0..2` 走 `onZhanyiClick()`：锁定显示锁定文案，未学习打开 `HeroWarpathGraspPre`，已学习后查询并进入 `HeroWarpathUpPanel`。Godot 战意节点已按这个链路接入本地预览。
- 英雄详情左侧按钮继续按源码落地：`imgPingLun -> btnComment() -> HeroCommentPanel/HeroCommentPre`，`imgFenXiang -> btnShare()` 只显示 `HeroSidePrefab/fenxiangBox`，其中跨服/世界/公会按钮分别走 `CHAT_TYPE_MIDDLE/WORLD/UNION`。Godot 已把评论接入 prefab 预览，分享改成本地三选菜单。衣装页 `setSkinData()` 按 `ind/isOn` 三选显示 `getBtn/wearBtn/takeBtn`，`getSkin()` 打开 `SkinShopPre`，`wearSkin/takeSkin` 走 `CG_SKIN_ON/OFF`，`playBtn -> showSkinEffect()` 走 `CG_ABS_ACT_HERO_COME_COMBAT`。Godot 已把获取接到“皮肤商店”，穿戴/卸下做本地状态切换，展示接到“衣装展示”。
- `HeroMainPanel.setZhanyiBox()` 不是固定三战意位：英雄星级 `<13` 时隐藏 `zhanyi2`，并把 `zhanyi0/zhanyi1` 改成双节点布局；星级 `>=13` 才显示 `zhanyi2` 并使用旋转三节点布局。Godot 战意页已按这个分支处理，锁定文字按星级显示。
- `HeroBookDetailPre` 只有 `infoToggle/skinToggle` 两个主要切换，不应复用 `HeroMainPre` 的五个功能页签。Godot 图鉴模式已按导出坐标把页签收敛到 `toggleInfo=[608,260,64,100]` 和 `toggleSkin=[608,360,64,100]`，显示为“档案/衣装”两态。
- 英雄详情当前右侧信息板参考 `HeroMainPre/HeroBookDetailPre` 的白板区域：`x=797,y=86,w=404,h=527`，左侧装备/技能列与右侧正文分开；详情页回归参数是 `--hero-id <id> --hero-mode main|book --capture-hero-panel <png>`。
- 英雄详情左侧信息采用“prefab 坐标 + 截图修正”：名字/职业仍参考 `lblHeroName/lblNickname`，品质和星级按截图手工排版；`ft_zhanli` 使用 `HeroBookDetailPre` 的 `[380.823,579.262,104.17,40]` 一带作为文字位置，底框使用 `[235.823,574.262,394,38]`。
- 英雄列表/详情页回归参数：`--hero-list-open-id <id>` 可从列表按 id 打开详情，默认进入 `HeroMainPre` 模式；`--hero-list-click-at 200,260` 可模拟点击首个卡片；`--hero-id <id> --hero-mode main|book` 可直接指定详情页英雄和入口模式。图鉴页优先使用 `image/heroBook/<id>` 长图。
- 共鸣页子链路继续按源码补齐：`HeroListPanel.changeTab3()` 懒加载 `HeroLevelSharedPre`，槽位组件 `HeroLevelSharedItemCom` 还会打开 `HeroLevelSharedHeroInfoPre`、`HeroLevelSharedRemovePre`、`HeroLevelSharedSuccessPre`、`AlertHeroLevelSharedPre`。Godot 共鸣页已在内嵌原始 layout 右侧补这些预览入口，后续可逐个手工化。
- 英雄详情页新增衣装、全屏预览和语音回归：`--hero-full-preview` 隐藏其他 UI 只显示角色，`--hero-click-once` 模拟点击角色并播放 `sound/cv/<hero>/<soundId>`。语音索引由 `tools/export_hero_voice_index.py` 生成到 `data/hero_voice_index.json`，MP3 拷贝在 `assets/hero_voice/**`。
- `data/prefab_restore_inventory.csv`：整理后的 prefab 还原清单。
- `data/prefab_restore_inventory.md`：按分类和优先级整理的 prefab 清单。
- `data/spine_preview_index.json`：Spine 预览索引。
- `RESTORE_LOGIN_TO_HOME.md`：登录页 -> 选服页 -> 主页面的专项还原梳理。
- `SOURCE_DIRECTORY_GUIDE.md`：原始目录、解密目录、Cocos bundle、反编译源码和工具脚本的作用索引。
- `tools/inspect_prefab_layout.py`：检查导出的 prefab layout、贴图节点、文本节点、Mask/ScrollView 和脚本字段绑定。
- `tools/export_cocos_config_index.py`：重新拆分 `assets/resources/config.json` 到 `data/config_index`，用于反查资源逻辑路径、UUID、native 文件和 SpriteFrame 裁剪信息。
- `debug_outputs/`：本地截图、Godot stdout/stderr 日志和临时回归输出目录。该目录默认被 git 忽略，只保留 `.gitkeep`。

冒险地图入口结论：

- 底栏 `btn5` 源码路由是 `DaohangPanel.changeTabPanel()` -> `openmaoxianPanel()`，不是天空城。
- `MaoxianMapTopPanel.preUrl="Prefab/MaoxianPanel/MaoxianMapPreTop"`，默认打开顶部地图；`MaoxianMapBottonPanel.preUrl="Prefab/MaoxianPanel/MaoxianMapPreBotton"` 是下半区地图。
- `MaoxianMoveCom.touchEnd()` 根据滑动方向切换 Top/Bottom：顶部向上滑打开底部，底部向下滑回顶部。
- `cocos_prefab_preview.gd` 对“冒险地图顶部/底部”使用 clean prefab preview：隐藏预览器工具栏、说明栏和无贴图灰色占位，只显示导出的真实 Sprite/Label。灰色空洞代表仍有 SpriteFrame/动态节点未映射，后续应修导出器或 Scroll/Mask 初始偏移，不再用手写 mock 覆盖。
- 导出器已对 `Prefab/MaoxianPanel/*` 增加同模块节点名反查：`image/com/MaoxianPanel/<node_name>`。这解决了 `1-1/1-5/2-6/BG01/BG02/mxbg1/mx_frame_biaotidi*` 等地图主体贴图缺失问题。当前 `MaoxianMapPreTop` 为 35 个贴图节点，`MaoxianMapPreBotton` 为 45 个贴图节点；剩余缺失主要是 `tab1/double` 运行状态控件。

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
- `MainPre.jingJiBattle/TianTiBattle/cymzBattle`：竞技、天梯、次元魔战的战斗返回/状态提示。源码由 `setJingJiBattle()`、`setTianTiBattle()`、`setMozhuBattle()` 控制显示，默认隐藏，不能按普通按钮还原。
- `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre`
- `Prefab/Guild/GuildMainPre`
- `Prefab/JingjiPrefab/JingjiPre`
- `Prefab/SkyCityPanel/SkyCityPre`

## 当前限制

- 主城页已改为 `MainPre` UI 层 + 可切换背景 + 可切换角色预览，但还不是完整 Cocos 运行时复刻。
- Spine 角色可用轻量 runtime 播放已导出的 runtime JSON，但复杂约束、clipping/path 等仍未完整支持。
- Label、ScrollView、Layout、Widget、九宫格 Sprite 仍需要继续映射。
- 一些界面资源由脚本或子 prefab 动态挂载，不能只看父 prefab 的贴图数量判断是否缺资源。
