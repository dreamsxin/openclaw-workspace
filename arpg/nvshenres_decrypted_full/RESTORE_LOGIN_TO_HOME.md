# 登录到主页面界面还原梳理

目标：从游戏启动初始化加载页到进入主页面，按原始 Cocos prefab 和运行时代码逐步还原界面。禁止用截图冒充界面资源；截图只作为视觉参考。

## 当前 Godot 流程

Godot 默认入口：

```text
project.godot -> run/main_scene="res://scenes/original_loading.tscn"
```

当前链路：

```text
original_loading.tscn
  -> original_login.tscn
  -> original_server_select.tscn
  -> original_home_screen.tscn
```

旧链路曾经直接从登录页开始：

```text
original_login.tscn
  -> original_server_select.tscn
  -> original_home_screen.tscn
```

对应脚本：

- `scripts/original_login.gd`
- `scripts/original_server_select.gd`
- `scripts/original_home_screen.gd`
- `scripts/original_loading.gd`

## 原始 Cocos Prefab 对应关系

### 0. 启动初始化加载页

Godot 场景：

```text
scenes/original_loading.tscn
```

原始 prefab：

```text
Prefab/loading/LoadingPre
assets/resources/import/71/71d56f9c-78d3-4b4c-99a5-7582c52b12f3.json
data/prefab_layouts/LoadingPre.json
```

相关 prefab：

```text
Prefab/loading/loadingProgress
assets/resources/import/8b/8b71b1c2-4572-4283-8bf1-32396e03cf64.json
data/prefab_layouts/loadingProgress.json
```

已确认背景资源：

```text
assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png
```

说明：

- 用户提供的 `加载页.jpg` 是该资源的 `1280x576` 显示裁切/缩放参考。
- 原始资源尺寸为 `1575x720`。
- `LoadingPre` 中包含 `bg`、`logo`、`dl_progressbar1_jiazai`、`loading_jindutiao`、进度文字和提示文字。
- `Scene/Main.fire` 摘要里存在 `loadingLayer`，说明该页属于游戏启动初始化流程。
- `Scene/updataScene.fire` 摘要里存在 `updataBtn`、`updataNode`，应属于热更新/初始化流程。

当前 Godot 实现状态：

- 已新增 `original_loading.tscn`。
- 默认启动场景已改为 `original_loading.tscn`。
- 加载页显示真实背景资源和本地进度条。
- 加载完成后自动进入 `original_login.tscn`。

下一步：

1. 将加载页也改为完全读取 `LoadingPre.json`。
2. 补 `loading_jindutiao` Spine 或进度条动画。
3. 将 `LoadingPre` 中的提示文本、进度文本、logo 坐标按 prefab 精确还原。

### 1. 登录页

Godot 场景：

```text
scenes/original_login.tscn
```

原始 prefab：

```text
Prefab/login/LoginPre
assets/resources/import/a3/a3a9989b-23b1-46a6-ad24-112682294a7c.json
data/prefab_layouts/LoginPre.json
```

当前导出结果：

```text
nodes: 39
texture_nodes: 6
```

关键贴图节点：

- `bg`：登录背景，当前导出为 `assets/resources/native/e8/e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
- `loginBtn` / `Background`：登录按钮区域
- `wenziDi`：底部文字/遮罩区域
- `logo`：原 prefab 中存在，但 `_active=false`

当前 Godot 实现状态：

- 已能显示登录背景、Logo、底部装饰、登录按钮。
- 点击登录进入选服页。
- 目前实现仍偏手工，未完全由 `LoginPre.json` 自动生成。

下一步：

1. 将 `original_login.gd` 改为读取 `data/prefab_layouts/LoginPre.json`。
2. 保留少量手工补丁只处理点击区域和离线跳转。
3. 正确处理 `_active=false` 的 logo：默认不画，除非确认运行时代码会开启。
4. 处理九宫格/拉伸节点，避免按钮或底部条失真。

### 2. 选服页

Godot 场景：

```text
scenes/original_server_select.tscn
```

原始 prefab：

```text
Prefab/login/pfLoginPanelPre
assets/resources/import/fc/fc3b94c3-c07b-4eb2-826e-2ad5d962c9e7.json
data/prefab_layouts/pfLoginPanelPre.json
```

当前导出结果：

```text
nodes: 101
texture_nodes: 10
```

关键贴图节点：

- `2`：大背景，当前导出为 `assets/resources/native/e8/e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
- `btnSwitchAcount`：切换账号按钮
- `btnGG`：公告按钮
- `wenziDi`：底部文字/装饰区域
- `button`：原始按钮节点，但 `_active=false`
- `logo`：存在但 `_active=false`

当前 Godot 实现状态：

- 选服页已经能显示背景、公告/账号按钮、本地演示服、开始按钮。
- 点击开始进入主页面。
- 目前服务器列表是本地 mock，符合“不连接服务端”的目标。
- 当前实现仍偏手工，未完全由 `pfLoginPanelPre.json` 自动生成。

下一步：

1. 将背景、公告按钮、账号按钮、底部装饰切换为 prefab 自动渲染。
2. 服务器列表继续用本地 mock 数据填充。
3. 补 `Label`、`Button`、`NinePatchRect` 映射。
4. 明确哪些节点由服务端列表数据动态生成，不从 prefab 静态找。

### 3. 主页面

Godot 场景：

```text
scenes/original_home_screen.tscn
```

原始 prefab：

```text
Prefab/mainpanel/MainPre
assets/resources/import/fd/fd77b1d2-32ad-46c4-be16-ef14bc2423d0.json
data/prefab_layouts/MainPre.json
```

当前导出结果：

```text
nodes: 227
texture_nodes: 27
```

相关子 Prefab：

```text
Prefab/mainpanel/daohangPre
data/prefab_layouts/daohangPre.json

Prefab/mainpanel/heroHead
data/prefab_layouts/heroHead.json

Prefab/comPrefab/MoneyItemPre
data/prefab_layouts/MoneyItemPre.json
```

底部导航定位：

```text
daohangPre.json
  cm_tab_ChengZhen1  global_position ~= (-448.355, -295.829)
  cm_tab_YingXiong1  global_position ~= (-280.898, -294.476)
  cm_tab_ZhaoHuan    global_position ~= ( -95.901, -292.829)
  btn3               global_position ~= ( -79.694, -293.768)
  cm_tab_FuBen       global_position ~= ( 269.368, -295.829)
  cm_tab_GongHui1    global_position ~= ( 447.148, -295.829)
```

反编译代码确认：

```text
assets/main/index.js
  DaohangPanel.onfrist:
    L.default.instance.dhBtn3 = this.com.btn3
    L.default.instance.zhaohuan = this.com.btn3

  DaohangPanel.openSelectBtn:
    case "btn3" -> cm_tab_ZhaoHuan
```

结论：主屏底部第三个按钮是“召唤”，不是“仓库”。仓库入口属于 `MainPre` 右侧入口条 `zjm_btn_cangku`，底栏不应占用 `btn3` 位置。Godot 主屏已将底栏第三项改为“召唤”，点击进入 `original_draw_card_panel.tscn`；右侧 `zjm_btn_yinghun` 因图标资源名为 `zjm_icon_zhaohuan`，离线 Demo 暂时也路由到召唤页。

当前手工布局实现约定：

- 底栏按钮中心点直接采用 `daohangPre.json` 的 `cm_tab_*` / `btn4` 坐标换算到 1280x720，不再使用早期等距手写坐标。
- 底栏“冒险”使用 `image/com/mainpanel/cm_icon_ChuJi` 的 SpriteFrame，避免残留英文 `image/en/mainpanel/cm_btn_Maoxian` 图。
- 底栏“召唤”目前使用 `image/com/mainpanel/zjm_icon_kuafuzhaohuan` 静态 SpriteFrame 作为召唤语义替代；`daohangPre` 中 `cm_tab_ZhaoHuan` 的真实动态主体仍需要继续追踪 `sp.Skeleton`/UISpine 资源。
- 仓库只保留在右侧 `zjm_btn_cangku` 入口条，点击进入本地背包/仓库页。
- 顶部金币/钻石条使用 `MoneyItemPre` 的 `cm_frame_HuoBi2` 背景，图标按 `MoneyItem.setType()` 源码映射到 `image/equipment/101` 和 `image/equipment/102`。
- 顶部资源条位置按 `DaohangPanel.creatMoney()`：金币 `money2.x = 319`，钻石 `money1.x = 521`，父节点 `moneyBox` 在 Cocos y=328；Godot 中分别换算到中心 `(959,32)` 和 `(1161,32)`。
- 资源条加号使用 `image/common/cm_btn_JiaHao`：`assets/resources/native/15/15a1d9111.png`，rect `[996,828,24,24]`。
- 主屏红点统一使用 `MoneyItemPre` 中可确认的 `cm_icon_HongDian` SpriteFrame：`assets/resources/native/18/18b29ae48.png`，rect `[375,295,31,31]`。不要直接使用 `MainPre.json` 里部分 `hongdian` 导出的 texture_path；压缩序列化解析会把它误指向父按钮图标或碎片图。
- 主屏 `openShop()` 已确认不是额外的主屏静态 prefab：源码在 `assets/main/index.js:35031` 附近调用 `PanelManager.openShop(ShopPanel.SHOP_TYPE_BLACKMARKET, MainUIPanel.instance)`；`ShopPanel.preUrl` 在 `assets/main/index.js:144648` 附近指向 `Prefab/Shop/ShopPre`。
- `ShopPre` 已加入核心导出清单，`data/prefab_layouts/ShopPre.json` 当前有 67 个节点、7 个贴图节点；主屏顶部 `SHOP` 和右侧 `商会` 入口现在进入独立 `original_shop_panel.tscn`，面板内的 `Prefab` 按钮可跳回 `商店` prefab 预览。
- `ShopItemPre`、`GoodsItemPre`、`ShopBuyEquitPre` 已加入导出；`GoodsItemPre` 关键绑定为 `equitNode/discount/rare/fight/prize/limit/selectBtn/without`，商品卡尺寸为 `350x120`。
- `original_shop_panel.gd` 已按 `ShopPanel.setData()` 手工复刻本地商店：主类型页签、右侧商店类型、两列商品、货币条、刷新条和购买弹窗；本地商品图标使用 `data/equipment_icon_index.json` 的真实装备 SpriteFrame，商品卡布局参考 `GoodsItemPre`，购买确认框参考 `ShopBuyEquitPre`。
- 商店子 prefab 当前可用资源链：
  - `ShopItemPre`：右侧商店类型条使用 `image/equipment/102` 图标结构，Godot 侧按 `SHOP_TYPES.icon` 映射 `named_resource_index.json`。
  - `GoodsItemPre`：折扣标签来自 `assets/resources/native/18/184257350.png` 的 `sc_tag_xiyou`，稀有标签来自同 atlas 的 `sc_tag_vip`，战意/禁用态暂用 `default_btn_disabled`。
  - `ShopBuyEquitPre`：弹窗背景用 `default_btn_normal` 九宫格替代，标题线用 `default_btn_disabled`，数量加减用 `sc_frame9_kongjian1di2`，滑条用 `xs_slider_qingbao1`，确认/MAX 按钮用 `cm_btn_LvSe1` / `cm_btn_LvSe1_1`。
- Godot `Button` 的子 `TextureRect` 会压住内部文字，商店页现在统一用“按钮空文本 + SpriteFrame 子图 + 独立 Label”来保证底图和文字层级。
- 主城 `hero_hit_area` 用于点击角色切换 Spine 动作，必须低于 UI 按钮层；当前 `prefab_layer.z_index = 20`、`hero_hit_area.z_index = 10`，否则右侧“商会”等入口会被角色点击区截获。
- 右侧九个斜向入口不要直接依赖旋转 Control/Button 的命中。当前实现把显示层和命中层拆开：`_add_ribbon_button()` 只画旋转资源，`right_ribbon_hit_layer` 放置独立不旋转矩形 hit area，`_input()` 再按 `right_ribbon_hits` 的设计坐标兜底分发点击。这样最后一个“商会”在真实鼠标点击下也能进入商店。
- 右侧入口红点不要放在图标中心，当前移到图标右上角，避免遮住 `通行证/仓库/竞技/.../商会` 的图标。
- 商店页回归参数：`--shop-open-buy <index>` 可启动时打开购买确认框，`--capture-shop-panel <png>` 可截图。
- 主城入口回归参数：`--home-open-entry 商会` 可启动后自动走主城入口路由，用于验证会进入 `original_shop_panel.tscn`；`--home-click-at 1059,547` 可模拟真实屏幕点击商会区域。
- 新增 `tools/inspect_prefab_layout.py`，用于快速打印 `ShopPre` 这类 layout 的贴图/文本节点和 `component_bindings`，后续定位 UI 字段不需要反复写临时 PowerShell。
- 截图和日志统一输出到 `debug_outputs/`，不要再写到工程根目录；该目录已在 `.gitignore` 中忽略。

主屏剩余缺口：

1. 底部导航主体在原始 prefab 中有 `cm_menu_*` Spine 节点，当前 Godot 仍是静态 SpriteFrame 替代。
2. 顶部 `moneyBox` 已接入 `MoneyItemPre` 背景、金币/钻石图标和加号 SpriteFrame；商店入口已路由到独立商店页，但真实 `MoneyItem` 动态刷新仍待实现。
3. 左侧活动入口存在运行时开关和运营数据驱动，当前只固定展示一组常见入口。
4. 右侧入口条 `zjm_btn_rukou5` 缺同名 SpriteFrame，需要继续从运行时代码或 atlas 中确认商会入口背景。
5. 主城背景和角色虽可切换，但还没有从 `Prefab/bigImage/*` 与 `Prefab/HerolhPrefab/*` 自动生成完整候选列表。

辅助追踪文件：

```text
data/mainpre_asset_trace.json
```

该文件记录了主城相关 `image/com/mainpanel/*` 路径到真实 SpriteFrame/native atlas/rect 的映射，后续替换占位按钮优先查它。

## Prefab 预览器与动态界面还原

Godot 场景：

```text
scenes/cocos_prefab_preview.tscn
scripts/cocos_prefab_preview.gd
```

当前定位：

- `cocos_prefab_preview.gd` 只作为 prefab 分析/取证工具，负责查看原始节点、坐标、贴图、Mask/ScrollView、脚本字段绑定和资源路径。
- 最终可运行界面改为独立 `original_*` 场景手工实现，避免预览器里静态 prefab、运行时 mock、过滤规则混画导致布局越来越偏。
- 主城、英雄、背包、抽卡等主要界面会逐步从 prefab 预览器 mock 迁移到独立场景。

命令示例：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full" --scene "res://scenes/cocos_prefab_preview.tscn" -- --prefab-layout "活动抽卡-抽数任务"
```

截图回归示例：

```powershell
$godot = "D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe"
$proj = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
$debug = Join-Path $proj "debug_outputs"
New-Item -ItemType Directory -Force -Path $debug | Out-Null
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "活动抽卡-抽数任务" --capture-prefab-preview "$proj\prefab_activity_13004_runtime_check.png" *> "$proj\prefab_activity_13004_runtime_check.log"
```

当前已接入的活动抽卡子页：

```text
活动抽卡-登录领取 -> Prefab/ActivityPanel/DrawCardActivity/13002
活动抽卡-循环礼包 -> Prefab/ActivityPanel/DrawCardActivity/13003
活动抽卡-抽数任务 -> Prefab/ActivityPanel/DrawCardActivity/13004
活动抽卡-许愿礼包 -> Prefab/ActivityPanel/DrawCardActivity/13005
```

源码定位：

```text
assets/main/index.js
DrawCardActivityPanel.checkToogle()
DrawCardActivity13002
DrawCardActivity13003
DrawCardActivity13004
DrawCardActivity13005
DrawCardActivityCycleItemCom
DrawCardActivityRenWuItemCom
```

关键结论：

- `DrawCardActivityPanel.checkToogle()` 按 `curPanelData.panelID` 动态加载 `Prefab/ActivityPanel/DrawCardActivity/<panelID>`。
- `13002` 是登录领取页，`rewardOne()` 领取当天奖励，`rewardall()` 一键领取。
- `13003` 是循环礼包/循环任务列表，`content` 下动态实例化 `DrawCardActivityCycleItemCom`。
- `13004` 是抽数任务页，`boxList` 驱动上方宝箱进度和红点，`taskList` 驱动下方任务列表。
- `13005` 是许愿礼包页，`giftContent` 下动态实例化 `giftItemPre`。
- `DrawCardActivityCycleItemCom` 和 `DrawCardActivityRenWuItemCom` 没有独立的明显 prefab 路径；`data/catalog.json` 显示它们的脚本 UUID 已分别嵌在 `13003`、`13004` prefab 的 `component_types` 中。

当前实现状态：

- `cocos_prefab_preview.gd` 对四个子页增加了运行时 mock 层，避免只显示 prefab 坐标框。
- mock 数据只替代服务端返回的 `setData(...)` 内容；按钮、宝箱、底板等仍尽量使用已解析出的原始 SpriteFrame。
- 对 `13003/13004/13005` 增加了页面级静态过滤，隐藏会干扰运行时列表的原始按钮、Label、进度和列表项占位节点。
- `tools/export_cocos_prefab_layout.py` 已新增 `component_bindings` 导出，记录自定义脚本组件字段到节点的推断绑定。
- `tools/export_cocos_prefab_layout.py` 已新增节点级 `component_types` 导出，后续可直接识别 `cc.Mask`、`cc.ScrollView`、`cc.ProgressBar`、自定义脚本等组件类型。
- `cocos_prefab_preview.gd` 已基于 `component_types` 创建通用 `cc.Mask` 裁剪容器登记表，并会沿 `parent_index` 查找最近的 Mask 祖先，把静态 prefab 子节点挂到对应 Godot `Control.clip_contents` 容器内。
- Mask 子树挂载时会把 Cocos 全局坐标转换为 Godot 裁剪容器内局部坐标；已覆盖 `HeroMainPre` 头像列表、右侧信息遮罩等存在明确父子链的节点。
- `cocos_prefab_preview.gd` 已开始推断导出时丢失父链的 ScrollView：对孤立的 `content + cc.Layout` 查找最近的 `view + cc.Mask`，并把 content 及其子树挂入对应裁剪容器；已验证 `HeroMainPre`、`BagPre`、`13003`。
- `HeroMainPre` 的原始 `tabTxt` 静态 Label 会被运行时 mock 过滤，避免在窄 ScrollView viewport 下被裁成单字列；后续应改为按 `HeroSidePrefab` 真实逻辑重建页签。
- 已新增独立英雄界面 `scenes/original_hero_panel.tscn` / `scripts/original_hero_panel.gd`，主城底部“英雄”入口进入该场景，不再打开 prefab 预览器。
- 独立英雄界面当前按 `HeroMainPre` 的视觉结构手工实现：左侧英雄头像列表、中心 Spine、右侧培养/装备/升星/战意/衣装页签、点击角色切换动作。
- 独立英雄界面读取 `data/named_resource_index.json` 加载头像框、头像、SSR 标、装备框等资源，兼容 `texture_path/sprite_rect` 和 `native_path/rect` 两种索引字段。
- 已新增独立背包/仓库界面 `scenes/original_bag_panel.tscn` / `scripts/original_bag_panel.gd`，主城底部“仓库”入口进入该场景，不再打开 prefab 预览器。
- 独立背包界面参考 `BagPre.json` 手工实现左侧滚动网格、右侧分类按钮、详情区和底部操作按钮；本地 mock 图标来自 `data/equipment_icon_index.json` 的真实装备 SpriteFrame。
- 独立背包界面支持页签切换和选中道具切换，并提供 `--bag-tab`、`--bag-item`、`--capture-bag-panel` 参数做截图回归。
- 已新增独立抽卡界面 `scenes/original_draw_card_panel.tscn` / `scripts/original_draw_card_panel.gd`，主城“召唤”入口进入该场景，不再打开 prefab 预览器。
- 独立抽卡界面参考 `drawCardPre.json` 手工实现中部卡池展示、奖励进度、召唤按钮、结果预览、积分兑换和右侧卡池页签；资源来自 `data/named_resource_index.json` 的 `image/com/DrawCard/*` 与英雄头像索引。
- 独立抽卡界面支持页签切换、召唤次数变化和结果预览刷新，并提供 `--draw-tab`、`--draw-count`、`--capture-draw-card` 参数做截图回归。
- prefab 预览器右侧详情栏会显示 `mask/scroll` 统计，便于判断哪些界面需要优先补裁剪关系。
- `13003.json` 现在可看到 `DrawCardActivityCycleItemCom` 的关键字段绑定：`girdLayout -> gridLayout`、`btn_buy -> btn_buy`、`JDT_progress -> progressBar`、`title -> label_name`。
- `13004.json` 现在可看到 `DrawCardActivityRenWuItemCom` 的关键字段绑定：`itemNode -> itemNode`、`descText -> title`、`taskProgress -> progressBar`、`taskProgressLab -> count`、`submitBtn -> getBtn`、`imgComplete -> isOver`。
- `cocos_prefab_preview.gd` 右侧详情栏已显示这些脚本字段绑定，用于后续按源码 `setData(...)` 精确替换手工 row。
- `活动抽卡-抽数任务` 的任务列表 mock 已改为参考 `13004.item` 模板内部坐标绘制：图标、标题、奖励文本、进度条、进度文本、按钮位置分别对应 `itemNode/title/count/progressBar/getBtn/isOver` 一组字段。
- `活动抽卡-循环礼包` 的礼包列表 mock 已改为参考 `13003.Item` 模板内部坐标绘制：奖励格、标题、奖励描述、进度条、进度文本、领取/前往/已领取状态分别对应 `girdLayout/title/txt_xiangou/JDT_progress/JDT_label/btn_buy/btn_qianwang/img_receive`。
- `活动抽卡-循环礼包` 和 `活动抽卡-抽数任务` 的 mock 行已绘制到 Godot `Control.clip_contents` 裁剪容器中，用于模拟 Cocos `cc.Mask` / `cc.ScrollView` 的可视范围；仍保留整行可视判断避免绘制完全越界的行。
- 活动抽卡列表奖励图标已从无效的 `image/Item/11001` 改为读取 `data/equipment_icon_index.json` 中真实 `image/equipment/*` SpriteFrame 裁剪图。
- 已用 Godot 控制台验证四个子页都可运行，无脚本解析错误。

遗留问题：

1. 子页列表已开始按 Cocos 原组件字段坐标绘制，但数据写入仍是本地 mock，不是完整 Cocos 组件实例化。
2. `Mask` 已开始自动裁剪存在明确 `parent_index` 祖先链的静态节点，并能对部分孤立 ScrollView content 做近邻推断；`Widget`、Layout 重排和滚动偏移尚未完整自动还原，动态列表仍需要结合源码组件逻辑和本地 mock 数据。
3. `cocos_prefab_preview.gd` 不再作为最终界面承载层；它的 mock 重叠问题后续不作为主线修复目标，只在影响取证时修。
4. Cocos 运行时真实奖励图标、礼包价格、任务进度来自服务端配置，本地 demo 当前使用固定 mock 数据。
5. 当前行底板继续使用原始资源，贴图自带亮线装饰，视觉上会穿过任务行背景；不是额外静态节点遮挡。
6. `component_bindings` 目前采用字段名/别名和 owner 子树推断，已验证活动抽卡关键字段，复杂跨树引用仍需结合源码确认。
7. 活动抽卡奖励图标目前复用装备图标索引作为本地 mock；后续应根据真实 `t.item` 配置和 `GridLogic.create(...)` 类型补完整 GridBox 样式。

关键结论：

`MainPre` 不是完整静态主城图。它主要是 UI 层，背景和角色由 JS 运行时选择。

运行时资源链：

```text
MainUIPanel.showBg -> Prefab/bigImage/<bgbody>
RoleLh -> Prefab/HerolhPrefab/<bodyID>
```

已确认默认值：

```text
_roleLhbody = "105004"
_bgbody = 0
```

左上头像：

```text
image/head/105004
assets/resources/native/d7/d7bf0f4d-1dc9-4fda-80c0-65dfeee3316a.png
```

右侧入口条：

```text
image/com/mainpanel/zjm_btn_rukou0 -> assets/resources/native/1f/1f6b547b4.png rect [639,292,364,50]
image/com/mainpanel/zjm_btn_rukou1 -> assets/resources/native/1f/1f6b547b4.png rect [675,65,341,56]
image/com/mainpanel/zjm_btn_rukou2 -> assets/resources/native/1f/1f6b547b4.png rect [675,230,336,56]
image/com/mainpanel/zjm_btn_rukou3 -> assets/resources/native/1f/1f6b547b4.png rect [675,3,342,56]
image/com/mainpanel/zjm_btn_rukou4 -> assets/resources/native/1f/1f6b547b4.png rect [684,591,387,58] rotated=1
```

常用主城图标 atlas：

```text
assets/resources/native/1a/1a7921f32.png
assets/resources/native/1f/1f6b547b4.png
assets/resources/native/14/140096250.png
assets/resources/native/18/18b29ae48.png
```

注意：部分 SpriteFrame 有 `rotated: 1`、`offset`、`originalSize`，直接裁剪 rect 会有黑块/偏移。当前导出器已写出 `sprite_offset`、`sprite_original_size`、`sprite_rotated`，通用 prefab layer、prefab 预览器和主城页已按 Cocos trim 规则复原到透明原始尺寸画布。

主城应分层：

```text
背景层：Prefab/bigImage/*
角色层：Prefab/HerolhPrefab/* Spine
UI 层：Prefab/mainpanel/MainPre
```

当前 Godot 实现状态：

- `original_home_screen.gd` 已读取 `MainPre.json` 渲染部分 UI。
- 已加入可切换背景按钮 `BG`。
- 已加入可切换角色按钮 `Hero`。
- 不再使用上传的 `主屏.jpg` 作为实际资源。
- 已使用 `global_position`，避免子节点局部坐标直接当根坐标。
- 已跳过 `_active=false` 隐藏节点。
- 已过滤一部分九宫格/动态面板误拉伸节点。
- 已将左侧竖排快捷按钮和左侧四列活动入口拆开坐标，避免图标重叠。
- 已确认主城活动广告入口资源为 `assets/resources/native/00/002545b0-69b1-4515-ac70-e545a4c8b5d2.png`，对应 `MainPre.json` 的 `zjm_image_GuanGao1`，尺寸约 `320x150`，全局中心约 `(-464.409, -115.622)`。
- 已按 `MainPre.json` 将右侧入口条收缩到 `260x34` 的父节点尺寸，并把底部导航替换为 `cm_icon_ChengZhen/YingXiong/CangKu/FuBen/GongHui` 等真实 SpriteFrame。
- 已用 `zjm_btn_rukou0..4` 的 `offset/originalSize/rotated` 元数据复原右侧入口条，`zjm_btn_rukou4` 不再依赖手工规避 rotated 裁剪。
- 已接入主城动态 Spine 角色轮换：`105004`、`SuLa_LH`、`YouDuoLa_LH`。
- 主城默认角色已改为原始逻辑对应的 `105004` Spine；静态 `Illustration` 仍保留在 Hero 轮换中，但不再作为默认主屏角色。
- `YouDuoLa_LH` 来源为 `assets/resources/native/1b/1baef3d2-6771-487a-84f3-f3222ae92456.png`，反查到 SkeletonData `2bb12a28-eeb0-4dbc-b5f3-c90d869cbc14`。
- 主城截图回归可用 `--home-hero <name>` 和 `--home-bg <name-or-index>` 指定角色/背景，例如 `--home-hero YouDuoLa_LH`。
- 主城角色展示区域可点击切换动作。`105004` 已验证可从 `idle` 切到 `show`，也可用 `--home-click-hero-once` 模拟点击。
- 主城动作可用 `--home-animation <name>` 指定，便于截图回归。
- 主城主要入口已接到对应 prefab 预览：
  - 底部 `英雄` -> `Prefab/HeroPanel/HeroMainPre`
  - 底部 `仓库` -> `Prefab/BagPanel/BagPre`
  - 底部 `冒险` -> `Prefab/Battle/battle`
  - 底部 `副本` -> `Prefab/SkyCityPanel/SkyCityPre`
  - 底部 `公会` -> `Prefab/Guild/GuildMainPre`
  - 左侧/右侧 `竞技` -> `Prefab/JingjiPrefab/JingjiPre`
  - `召唤` -> `Prefab/DrawCard/drawCardPre`
  - 活动广告/广告入口 -> `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre`
- `cocos_prefab_preview.gd` 支持从 `Navigation.go_with_args(..., {"layout": "英雄"})` 或命令行 `--prefab-layout 英雄` 打开指定界面。
- Prefab 预览器已改为优先使用导出的 `global_position`，并跳过无贴图根节点，核心界面骨架比局部坐标版更接近原布局。
- Prefab 导出器已补 `cc.Label` 文本字段；预览器可以显示真实 Label 文本并应用节点 scale。英雄、背包、抽卡等主要界面现在不再只显示节点名。
- Prefab 导出器已补 `cc.Sprite._type/_sizeMode` 和 SpriteFrame `capInsets`；预览器对 sliced Sprite 使用 `NinePatchRect` 渲染。
- `HeroMainPre` 预览已叠加本地 mock 的 `105004` Spine 角色展示，便于从主城进入英雄面板后检查角色展示效果。
- Prefab 导出器已补 `_anchorPoint`；预览器已按 Cocos anchor 计算节点左上角，减少 Label 和按钮相对面板的错位。
- Prefab 导出器已补 `cc.Widget` 的 `_alignFlags` 与 left/right/top/bottom，并在导出阶段做基础贴边/拉伸计算。登录面板等使用 Widget 的 prefab 更接近 Cocos 运行时布局。
- `BagPre` 预览已叠加本地背包条目 mock。条目结构来自 `Prefab/BagPanel/GridBoxItemPre`，真实图标来自 `assets/resources/config.json` 中的 `image/equipment/<icon>` 索引。
- 当前结论：prefab 可还原静态节点坐标、尺寸、锚点、Widget；背包列表等动态内容需要继续追源码中的 `cc.instantiate` / `setImgUrl` 规则，并用子 Prefab 加本地数据补齐。

当前不足：

- 角色 Spine 已能播放，但仍是项目内轻量 runtime，和官方 Spine runtime 可能有细节差异。
- `SuLa_LH` 的 `idle` 姿态偏横向，主城展示后续需要结合原角色面板确认是否应使用 `show` 或额外偏移。
- `MainPre` 和主要功能 prefab 的 Layout、ScrollView 仍未完整映射；当前主要界面是可进入且带文本/anchor/基础 Widget/基础九宫格的 prefab 骨架预览，还不是最终可交互面板。
- 顶部资源栏、底部入口、右侧入口还有大量运行时动态内容未补齐。

下一步：

1. 从 `Prefab/bigImage/*` 自动生成背景候选。
2. 从 `Prefab/HerolhPrefab/*` 自动生成角色候选，并接入主城和 Spine 列表。
3. 在资源浏览器中继续完善 Spine atlas/动画索引查看。
4. 继续补轻量 Spine runtime 的约束、clipping、path 等高级能力。
5. 逐步把 `MainPre` 的按钮/入口区域补成可点击导航。
6. 优先完善 `HeroMainPre`、`BagPre`、`drawCardPre` 的 Label、九宫格和滚动列表 mock 数据。

## 实施顺序

### 第一步：统一 prefab 渲染器

目标：登录页、选服页、主页面都使用同一套 Cocos prefab 渲染逻辑。

需要补齐：

- `cc.Node` -> `Control`
- `cc.Sprite` -> `TextureRect`
- `cc.Button` -> 可点击 `Button` + 状态贴图
- `cc.Label` -> `Label`
- `cc.Widget` -> anchor/offset
- `cc.Layout` -> 容器布局
- 九宫格 Sprite -> `NinePatchRect`

### 第二步：登录页从手工切到 prefab

目标：`original_login.gd` 只负责加载 `LoginPre.json` 和绑定登录按钮。

保留本地逻辑：

```text
点击登录 -> Navigation.go("res://scenes/original_server_select.tscn")
```

### 第三步：选服页从手工切到 prefab

目标：`original_server_select.gd` 使用 `pfLoginPanelPre.json` 渲染静态视觉，服务器列表用本地 mock 填充。

保留本地逻辑：

```text
点击开始 -> Navigation.go("res://scenes/original_home_screen.tscn")
```

### 第四步：主页面三层还原

目标：主页面不再靠固定图片，而是由三类资源组合：

```text
bigImage 背景 + HerolhPrefab 角色 + MainPre UI
```

短期可接受：

- 背景可选，不要求和账号数据完全一致。
- 角色可选，不要求和服务端阵容一致。
- 角色使用项目内 `SimpleSpinePlayer` 播放 Spine，允许和官方 runtime 有小差异。

长期目标：

- 继续提高 `idle` / `show` 动画精度。
- 主城入口按钮能跳转到对应 prefab 预览页。

## 验证方式

## Godot 使用说明

本工程固定使用 Godot 4.6.2 控制台版：

```powershell
$godot = "D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe"
$proj = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

常用运行方式：

```powershell
& $godot --path $proj
& $godot --path $proj --scene "res://scenes/original_home_screen.tscn"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" -- --prefab-layout "公会"
```

命令行参数规则：

- `--path <dir>` 指向 Godot 工程目录，目录内必须有 `project.godot`。
- `--scene <res://...>` 可直接启动指定场景，用于跳过前置流程调试某个页面。
- `--quit-after <frames>` 适合截图回归，等待若干帧后自动退出。
- `--log-file <file>` 写 Godot 引擎日志；PowerShell 的 `*> file.log` 同时收集 stdout/stderr。
- `--` 后面的参数不再由 Godot 引擎解析，而是由脚本通过 `OS.get_cmdline_user_args()` 读取。
- `--headless` 只能做语法/启动校验，不适合用 `get_viewport().get_texture()` 截图。
- Windows 下常见 `WASAPI: init_output_device error` 是音频设备初始化警告，界面截图和脚本校验时可忽略；真正需要优先处理的是 `SCRIPT ERROR`、`Parse Error`。

截图回归参数：

```powershell
& $godot --path $proj --scene "res://scenes/original_loading.tscn" --quit-after 100 -- --capture-loading "$debug\loading_check.png" *> "$debug\loading_check.log"
& $godot --path $proj --scene "res://scenes/original_login.tscn" --quit-after 100 -- --capture-login "$debug\login_check.png" *> "$debug\login_check.log"
& $godot --path $proj --scene "res://scenes/original_server_select.tscn" --quit-after 100 -- --capture-server-select "$debug\server_check.png" *> "$debug\server_check.log"
& $godot --path $proj --scene "res://scenes/original_home_screen.tscn" --quit-after 100 -- --capture-home-screen "$debug\home_check.png" *> "$debug\home_check.log"
```

功能界面 prefab 预览：

```powershell
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "英雄" --capture-prefab-preview "$debug\prefab_hero.png" *> "$debug\prefab_hero.log"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "背包" --capture-prefab-preview "$debug\prefab_bag.png" *> "$debug\prefab_bag.log"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "抽卡" --capture-prefab-preview "$debug\prefab_draw.png" *> "$debug\prefab_draw.log"
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "公会" --capture-prefab-preview "$debug\prefab_guild.png" *> "$debug\prefab_guild.log"
```

Spine 查看器：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn"
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 100 -- --spine-path "res://data/spine_runtime/105004.json" --spine-animation show --capture-spine-viewer "$debug\spine_105004_show.png" *> "$debug\spine_105004_show.log"
```

## 界面还原实现说明

当前还原不是用截图贴图，而是按以下链路把 Cocos Creator 资源转为 Godot 可渲染结构：

```text
assets/resources/config.json
  -> import/*.json / native/*.png / spine json+atlas
  -> tools/*.py 导出索引与 prefab layout
  -> data/*.json
  -> scripts/*.gd 在 Godot 中渲染和补运行时 mock 数据
```

核心导出脚本：

- `tools/export_cocos_prefab_layout.py`：把 Cocos prefab 导出为 `data/prefab_layouts/*.json`，包含节点树、全局坐标、尺寸、锚点、SpriteFrame、Label、Widget、NinePatch 信息。
- `tools/export_named_resource_index.py`：把源码/运行时常见的字符串资源路径导出为 `data/named_resource_index.json`，用于 `setImgUrl("image/...")` 这类动态加载。
- `tools/export_equipment_icon_index.py`：导出 `image/equipment/*`，用于背包等动态列表 mock。
- `tools/export_spine_runtime_data.py`：把 Cocos `sp.SkeletonData` 转为项目内轻量 Spine runtime 可读的 `data/spine_runtime/*.json`。
- `tools/cocos_spine_trace_tool.py`：用于 native PNG、SkeletonData、压缩 UUID 之间反查。

Godot 渲染脚本分工：

- `scripts/original_loading.gd`：启动初始化加载页，当前保留手工流程控制。
- `scripts/original_login.gd`：登录页，本地点击进入选服页。
- `scripts/original_server_select.gd`：选服页，本地 mock 服务器列表。
- `scripts/original_home_screen.gd`：主城页，组合 `bigImage` 背景、`HerolhPrefab` Spine 角色、`MainPre` UI。
- `scripts/cocos_prefab_preview.gd`：通用功能界面 prefab 预览器，负责英雄、背包、抽卡、公会等页面骨架和动态 mock 数据。
- `scripts/simple_spine_player.gd`：项目内轻量 Spine 3.8 播放器，用于主城角色和 Spine 查看器。

Prefab 静态节点按 Cocos 规则处理：

- 坐标优先使用导出的 `global_position`，避免把子节点局部坐标误当根坐标。
- `_active=false` 的节点默认不绘制。
- SpriteFrame 使用 `rect`、`offset`、`originalSize`、`rotated` 复原到透明原始尺寸画布。
- `cc.Sprite` 的 sliced 类型使用 `NinePatchRect`，读取 `capInsets`。
- `cc.Label` 读取 `_string`、字号、行高和对齐。
- `cc.Widget` 当前支持基础贴边、居中和四边拉伸。

运行时动态内容的处理原则：

- prefab 中没有实例化出来的列表项，不手工猜整张截图，而是查源码里的 `cc.instantiate`、`setImgUrl`、`loadRes` 规则。
- 动态列表使用对应子 prefab 加本地 mock 数据补齐，例如 `BagPre` 使用 `GridBoxItemPre`，图标来自 `image/equipment/*`。
- 按字符串路径加载的图片先扩展 `export_named_resource_index.py` 的前缀，再在 Godot 中通过 `_add_named_image()` 使用真实资源。
- 角色展示优先使用 `Prefab/HerolhPrefab/*` 对应 Spine；只有未导出 runtime 时才临时使用静态贴图。

当前已验证的功能界面补丁：

- `HeroMainPre`：叠加 `105004` Spine 展示区。
- `BagPre`：叠加本地背包条目，结构来自 `GridBoxItemPre`。
- `drawCardPre`：叠加抽卡卡池、卡牌、宝箱进度和召唤按钮。
- `GuildMainPre`：叠加公会大厅背景、旗帜、信息和入口。
- `SkyCityPre`：叠加天空城空岛、建筑、矿物、副本入口和底部操作按钮；资源来自 `image/com/skyCity/*`。
- `JingjiPre`：叠加 PVP 背景、五个竞技玩法入口、膜拜信息和赛季奖励；资源来自 `image/com/Jingji/*` 与 `image/com/pvpActivity/*`。
- `battle`：叠加地图背景、左右 5 个战斗站位、头像、血条、伤害/治疗反馈和胜利奖励面板；资源来自 `image/com/map/*`、`image/head/*`、`image/com/Battle*`。
- `DrawCardActivityPre`：叠加活动标题、倒计时、限定英雄概率提升、抽数奖励进度、活动兑换和操作按钮；资源来自 `image/com/ActivityPanel/ZhaoHuan/*`、`image/com/ActivityPanel/NewHeroComing/*`、`image/com/ActivityPanel/thousandDrawCardActivity/*`。
- `HeroMainPre`：叠加英雄列表、属性面板、技能格、装备格和 `105004` Spine 展示；资源来自 `image/en/HeroPanel/*`、`image/comHeroGrid/*`、`image/skill/*`、`image/head/*`。
- `BagPre`：叠加背包分类、道具列表、详情区和使用/出售/一键出售操作；装备/道具图标来自 `data/equipment_icon_index.json`，通用按钮来自 `image/common/cm_btn*`。

启动工程：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
```

当前默认入口是 `res://scenes/original_loading.tscn`，启动后按“加载页 -> 登录页 -> 选服页 -> 主城页”流程进入。登录页可显式运行：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full" --scene "res://scenes/original_login.tscn"
```

无窗口基础校验：

```powershell
D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe --headless --path "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full" --quit
```

截图检查：

- 登录页：`--capture-login`
- 选服页：`--capture-server-select`
- 主页面：`--capture-home-screen`

Godot 4.6.2 命令注意：

```powershell
$godot = "D:\work\openclaw-workspace\arpg\tools\Godot_v4.6.2-stable_win64_console.exe"
$proj = "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full"
$debug = Join-Path $proj "debug_outputs"
New-Item -ItemType Directory -Force -Path $debug | Out-Null
$out = Join-Path $debug "home_check.png"
$log = Join-Path $debug "godot_check.log"
$godotLog = Join-Path $debug "godot_engine.log"
& $godot --path $proj --scene "res://scenes/original_home_screen.tscn" --quit-after 80 --log-file $godotLog -- --capture-home-screen $out *> $log
```

- 指定场景使用 `--scene <path>`。
- `--` 后面的参数由 `OS.get_cmdline_user_args()` 读取。
- `--headless` 使用 dummy 渲染，不能用 `get_viewport().get_texture()` 截图。
- PowerShell 中使用 `*> file.log` 可同时重定向 stdout/stderr，方便查看 Godot 脚本错误。

Spine 查看器：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 80 --log-file $godotLog -- --spine-animation attack --capture-spine-viewer "D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\spine_attack.png" *> $log
```

也可以直接指定 runtime JSON：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 80 -- --spine-path "res://data/spine_runtime/YiKaLuoSi.json" --spine-animation attack --capture-spine-viewer "$debug\spine_attack.png" *> $log
```

资源浏览器：

- 进入 `Spine` 分类。
- 如果该 skeleton 已存在 `data/spine_runtime/<name>.json`，会出现 `Open Spine Viewer`。
- 点击后会带着 runtime 路径和默认动画进入 `spine_character_viewer.tscn`。

主要 prefab 预览：

```powershell
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "公会" --capture-prefab-preview "$debug\prefab_guild.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "英雄" --capture-prefab-preview "$debug\prefab_hero.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "天空城" --capture-prefab-preview "$debug\prefab_skycity.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "竞技" --capture-prefab-preview "$debug\prefab_jingji.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "战斗" --capture-prefab-preview "$debug\prefab_battle.png" *> $log
& $godot --path $proj --scene "res://scenes/cocos_prefab_preview.tscn" --quit-after 100 -- --prefab-layout "活动抽卡" --capture-prefab-preview "$debug\prefab_draw_activity.png" *> $log
```

- `背包`：使用 `GridBoxItemPre` + `image/equipment` mock 数据。
- `背包` 当前还额外补了分类按钮、详情面板和操作按钮；详情区仍受原 prefab 暗层影响，后续需统一处理 Mask/ScrollView 层级。
- 带运行时 mock 的 prefab 预览页会跳过无贴图、无文本的 Cocos 容器占位节点，避免 `content`、`mask`、`box` 这类半透明灰块遮住动态内容。
- `抽卡`：使用 `image/com/DrawCard` mock 数据。
- `抽卡` 当前还额外补了右侧卡池页签、召唤积分/消耗、十连结果预览和积分兑换信息；已加入页面级静态层过滤，后续继续接入抽卡 Spine 和结果子 Prefab。
- `抽卡` mock 布局已改为从 Cocos 全局坐标压缩映射：页签参考 `tabBtn_5/tabBtn_1/tabBtn_3/tabBtn_2/tabBtn_4`，召唤按钮参考 `btn_call1/btn_call10`，奖励条参考 `progressBar/txt_progress`，动态展示容器参考 `HeroUiBox`。
- `公会`：使用 `image/com/Guild`、`image/guildFlag` mock 数据。
- `天空城`：使用 `image/com/skyCity` mock 建筑、矿物、空岛和副本入口。
- `竞技`：使用 `image/com/Jingji`、`image/com/pvpActivity` mock 玩法入口、排名、奖励和膜拜信息。
- `战斗`：使用 `image/com/map`、`image/head`、`image/com/Battle*` mock 战场、站位、血条和胜利面板。
- `活动抽卡`：使用 `image/com/ActivityPanel/ZhaoHuan`、`image/com/ActivityPanel/NewHeroComing`、`image/com/ActivityPanel/thousandDrawCardActivity` mock 活动奖池、抽数奖励和兑换区；当前已导出 `13002` 登录领取、`13003` 循环礼包、`13004` 抽数任务、`13005` 许愿礼包和 `DrawCardActivityToggle` 子 prefab。
- `英雄`：使用 `image/en/HeroPanel`、`image/comHeroGrid`、`image/skill`、`image/head` mock 英雄列表、属性、技能、装备和角色展示。

抽卡源码定位：

- `assets/main/index.js:39976`：`DrawMainPanel.preUrl = "Prefab/DrawCard/drawCardPre"`，确认入口 prefab。
- `assets/main/index.js:39908`：`DrawMainPanelCom.onLoad` 绑定 `btnTabs[0]`、`btnTabs[1]`，并通过 `getChildByName("HeroUiBox")` 找到整屏动态展示容器。
- `assets/main/index.js:39916`：`onEnable` 调用 `setImgUrl(this.bg, "image/com/DrawCard/zh_bg")`，说明背景不是 prefab 静态贴图，而是运行时设置。
- `assets/main/index.js:39978` 到 `39994`：预加载 `uispine/ZhaoHuan_GaoJi`、`ZhaoHuan_XianZhi`、`ZhaoHuan_YouQing`、`ZhaoHuan_PuTong` 和 `Prefab/DrawCard/HeroShowPre`。
- `assets/main/index.js:39997` 到 `40015`、`40813` 到 `40815`、`41120` 到 `41134`：抽卡和切换卡池时使用 `ZhaoHuan_ChouKa`、`ZhaoHuan_ChouKa_back`、`ZhaoHuan_ChouKa_front`，以及不同卡池的 enter 动画。
- `original_draw_card_panel.gd` 已按上述源码接入真实 Spine runtime：
  - 普通：`data/spine_runtime/ZhaoHuan_PuTong.json`
  - 友情：`data/spine_runtime/ZhaoHuan_YouQing.json`
  - 高级/英灵来袭：`data/spine_runtime/ZhaoHuan_GaoJi.json`
  - 天命：`data/spine_runtime/ZhaoHuan_XianZhi.json`
  - 点击召唤：`data/spine_runtime/ZhaoHuan_ChouKa.json`
- 这些 runtime 由 `tools/export_spine_runtime_data.py --uuid <uuid> --out data/spine_runtime/<name>.json` 导出；对应 uuid 来自 `data/spine_preview_index.json`。
- `original_draw_card_panel.gd` 中的 `_fit_spine_to_rect()` 会先用 `SimpleSpinePlayer.get_draw_bounds()` 缩放，再按卡池配置补偿 Cocos 根骨坐标偏移。这个偏移是资源骨骼坐标造成的，不是资源丢失。
- `assets/main/index.js:33756` 到 `33764`、`39232`：奖励宝箱图标按状态动态切换 `image/com/DrawCard/bx_icon_0*` 和 `bx_icon_0*a`。
- `data/prefab_layouts/drawCardPre.json` 关键全局坐标：`tabBtn_5(501,252)`、`tabBtn_1(501,158)`、`tabBtn_3(501,53.774)`、`tabBtn_2(501,-44.813)`、`tabBtn_4(501,-150.879)`、`btn_call1(-466,-96)`、`btn_call10(-466,-192)`、`progressBar(-445.515,-34.509)`、`btn2_call1(-140.873,-229.353)`、`btn2_call10(188.935,-227.964)`、`HeroUiBox(0,0)`。

主屏与英雄页源码/布局线索：

- `MainUIPanel`/`DaohangPanel` 运行时代码在 `assets/main/index.js:34335` 附近；主城头像、导航按钮、红点、货币和运营入口都由脚本动态控制。
- 主屏默认角色定位源码链：
  - `assets/main/index.js:99534`：`MainUIPanel` 构造时 `_roleLhbody = "105004"`。
  - `assets/main/index.js:99797`：`onShow()` 调用 `this.showLh(this.roleLhbody)`。
  - `assets/main/index.js:26408` 附近：`lihuiCom.showLh(e)` 清空 `this.com.heroLh`，创建 `RoleLh`，设置 `this.lhpre.body = e`，然后 `this.com.heroLh.addChild(this.lhpre)`；这里没有额外 x/y/scale。
  - `RoleLh.body` 会加载 `Prefab/HerolhPrefab/<bodyID>`；`RoleLh.onloadOver()` 会用 prefab 内 Skeleton 节点 width/height 回填父节点尺寸。
  - `data/prefab_layouts/MainPre.json` 中 `herolh` 是全屏节点，Cocos 坐标 `(0,0)`、尺寸 `1280x720`、锚点 `(0.5,0.5)`，所以实例根原点对应 Godot `(640,360)`。
  - `Prefab/HerolhPrefab/105004` 的 import 为 `assets/resources/import/00/00482677-9b33-43a2-91b3-fd0d9c1259a6.json`；导出后可见 Skeleton 子节点 `105004` 的本地位置 `(-68,-333)`、scale `(1,0.95)`，Godot 需要映射成 `spine_prefab_offset = Vector2(-68,333)`。
- `data/prefab_layouts/MainPre.json` 关键节点：
  - 右侧弧形入口：`zjm_btn_jingji(465,122)`、`zjm_btn_baoju(430,221)`、`zjm_btn_cangku(448,172)`、`zjm_btn_yinghun(483,9)`、`zjm_btn_duanzao(477,-43)`、`zjm_btn_zhanbu(471,-96)`、`zjm_btn_xunxing(449,-148)`、`zjm_btn_shop(419,-187)`。
  - 左侧竖栏：`zjm_btn_HaoYou(-602,226)`、`zjm_btn_YouJian(-602,163)`、`zjm_btn_PaiHang(-602,103)`、`zjm_btn_XinWen(-602,41)`、`zjm_btn_ZhanBao(-602,-20)`。
  - 活动入口：`zjm_icon_zhaohuanactivity(-280,10)`、`advertisingbtn(-280,112)`、聊天区 `scrollview(-550,-237)`。
  - 角色展示容器：`lihui`、`herolh` 都是全屏容器，真实角色由 `RoleLh`/`Prefab/HerolhPrefab/<body>` 运行时挂载。
- `data/prefab_layouts/HeroMainPre.json` 说明当前独立英雄页还不对：原版不是左侧英雄头像列表，而是 `scrollview/content` 下的 `tab01..tab05` 竖向功能页签；中心是 `heroBodyBox`，左右切换按钮是 `btnPre(-500,10)` / `btnNext(91,10)`，右侧面板是 `heroContentPrefab(361,11)`，底部/右侧功能按钮在 `btnUpLv`、`btnJinJie`、`btnReset`、`btn_xianQing`。
- 因此后续 `original_hero_panel.gd` 需要从“左侧英雄列表”改为“中心立绘 + 左右切换 + 左侧功能页签 + 右侧属性/技能/装备区”的结构；英雄列表只作为资源浏览或调试入口，不应出现在原版主英雄页默认布局。
- 当前实现已按这个方向修改：默认界面不再显示左侧头像列表，改为左侧英雄信息、小功能按钮、中心 Spine、左右翻页、竖向页签和右侧信息面板。下一步继续追 `HeroSidePrefab`/`heroContentPrefab` 的真实 SpriteFrame 与脚本字段绑定。

活动抽卡源码定位：

- `assets/main/index.js:39512`：`DrawCardActivityPanel.preUrl = "Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre"`，父级 prefab 只提供背景、ScrollView/content 等容器。
- `assets/main/index.js:39562`：`checkToogle` 按 `curPanelData.panelID` 动态加载 `Prefab/ActivityPanel/DrawCardActivity/<panelID>`，所以完整界面依赖 `13002..13005` 子 prefab。
- `assets/main/index.js:38979`、`39107`、`39165`、`39264`：源码模块分别存在 `DrawCardActivity13002/13003/13004/13005`。
- 当前已生成 `data/prefab_layouts/13002.json..13005.json` 和 `DrawCardActivityToggle.json`，父级活动页签可跳转到这些真实子 prefab 预览；后续需要继续补 `setData` 运行时列表、奖励状态和按钮贴图。

Prefab 节点名用途推断：

- Cocos prefab 里的节点名可以作为还原依据，很多是拼音或缩写：`zjm`=主界面，`zh/zhaohuan`=召唤，`gh/gonghui`=公会，`cm`=通用，`btn`=按钮，`icon`=图标，`rukou`=入口，`dh/duihuan`=兑换，`tj`=推荐，`zhh`=转换，`hongdian`=红点。
- 已新增 `tools/analyze_prefab_node_names.py`，会读取 `data/prefab_layouts/*.json`，按节点名 token、驼峰拆分、数字后缀剥离等规则输出用途提示。
- 输出文件为 `data/prefab_node_name_hints.json`，可用于快速检查每个 prefab 的功能区。例如 `drawCardPre` 中 `btn_call1/btn_call10` 会识别为召唤按钮，`btn_dh` 识别为兑换按钮，`HeroUiBox` 识别为英雄展示容器，`tabBtn_*` 识别为页签按钮。
- 命名推断只作为辅助证据，最终仍需结合 `label_text`、`global_position`、`texture_path` 和 `assets/main/index.js` 运行时代码确认。

局部 slot 调试：

```powershell
& $godot --path $proj --scene "res://scenes/spine_character_viewer.tscn" --quit-after 80 -- --spine-path "res://data/spine_runtime/YiKaLuoSi.json" --spine-animation idle --debug-slots "YiKaLuoSi_zuodatui,YiKaLuoSi_zuojiao,YiKaLuoSi_youdatui,YiKaLuoSi_youjiao" --capture-spine-viewer "$debug\spine_legs.png" *> $log
```

YiKaLuoSi 当前还原记录：

- 头饰：`YiKaLuoSi_toushi03` 绑定独立 `bone21`，和头部 `bone5` 不同；当前在 runtime 内保留最小角色级补偿，避免头冠悬浮。
- 腿部：`yik` / `zik` 是 setup-only 二骨 IK，runtime 已补 IK 求解和 IK 后子骨骼重算。
- 左侧脚部：问题主要来自 `rotate: true` mesh atlas UV 方向，已修正 rotated mesh UV 映射。
- `YiKaLuoSi_zuojiao` 是 weighted mesh，使用 `bone9`、`bone10`、`bone11` 权重；未发现 idle/run/attack/skill 的 deform timeline。

## 当前判断

登录到主页面可以还原，但应避免继续扩大手工拼图。后续应先完善统一 prefab 渲染器，再把登录、选服、主城逐步切回原始 prefab 驱动；运行时动态部分用本地 mock 数据补齐。
