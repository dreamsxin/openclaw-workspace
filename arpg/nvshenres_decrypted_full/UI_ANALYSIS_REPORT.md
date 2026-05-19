# 女神降临 (Nvshen) - UI资源分析报告

生成时间: 2026-05-19
分析来源: nvshenres (原始APK) + nvshenres_decrypted_full (解密资源)

---

## 一、资源总览

| 指标 | 数值 |
|---|---|
| 原始 Prefab 总数 | 1018 个 (prefabs.csv) |
| 源码直接引用的 Prefab | 492 个 |
| 解密资源文件总数 | 6942 个 |
| 　　其中 PNG | 5281 |
| 　　其中 MP3 | 1061 |
| 　　其中 Atlas | 505 |
| 　　其中 JPG | 83 |
| 　　其他 | 10 (ttf/sk/bin/plist) |
| 英雄数量 | 75 个 (53 SSS + 22 其他品质) |
| 有语音的英雄 | 61 个 |
| 有战斗Prefab的英雄 | 63 个 |
| 有皮肤/变体的英雄 | 17 个 |
| 设计分辨率 | 1280 × 720 |
| 游戏引擎 | 原 Cocos Creator → 迁移至 Godot 4 |

---

## 二、启动流程 (启动界面链路)

游戏从启动到进入主城的完整流程：

```
Loading (加载页) → Login (登录页) → ServerSelect (选服页) → Home (主城)
```

| 序号 | 界面 | 场景文件 | 对应 Cocos Prefab | 源码模块 |
|---|---|---|---|---|
| 1 | 加载页 | original_loading.tscn | Prefab/loading/LoadingPre | LoadingPanelNode |
| 2 | 登录页 | original_login.tscn | Prefab/login/LoginPre | LoginPanel |
| 3 | 选服页 | original_server_select.tscn | Prefab/login/pfLoginPanelPre | PFLoginPanel |
| 4 | 主城 | original_home_screen.tscn | Prefab/mainpanel/MainPre + daohangPre | MainUIPanel / DaohangPanel |

---

## 三、主界面层级结构 (MainPre Canvas Layers)

从底到顶的渲染层级：

```
scene (根节点)
　├── mapLayer (地图层)
　├── unitLayer (单位层)
　├── uiLayer (UI层)
　├── topuiLayer (顶层UI)
　├── dialogLayer (弹窗层)
　├── broadcastLayer (广播/跑马灯)
　├── loadingLayer (加载遮罩)
　├── guideLayer (引导层)
　├── soundLayer (音效层)
　└── backBtn (返回按钮)
```

---

## 四、主界面入口全景

### 4.1 底部导航栏 (6个入口)

| 入口名称 | 功能 | 跳转目标 |
|---|---|---|
| 城镇 | 主城首页 | 自身 (Home) |
| 英雄 | 英雄列表 | HeroListPanel → HeroBookDetailPanel |
| 召唤 | 抽卡/召唤 | DrawCard (DrawMainPanel) |
| 冒险 | 战斗系统 | Battle / MaoxianPanel |
| 副本 | 天空城副本 | SkyCityPanel |
| 公会 | 公会主页 | Guild (GuildMainPanel) |

### 4.2 右侧功能区 (9个入口)

| 入口名称 | 功能模块 | 对应 Prefab 分类 |
|---|---|---|
| 通行证 | 战令/Battle Pass | PassPrefab |
| 仓库 | 背包 | BagPanel |
| 竞技 | 竞技场PVP | JingjiPrefab |
| 学院 | 学院系统 | - |
| 英魂 | 召唤入口 | DrawCard |
| 锻造 | 装备锻造 | ForgePanel |
| 占卜 | 占卜系统 | zhanbu |
| 寻星 | 寻星系统 | StarPlanPanel |
| 商会 | 商店 | Shop / ShopPanel |

### 4.3 左侧快捷按钮 (5个入口)

| 入口名称 | 功能模块 | 对应 Prefab 分类 |
|---|---|---|
| 好友 | 好友系统 | FriendPanel |
| 邮件 | 邮件系统 | EmailPanel |
| 排行 | 排行榜 | rank |
| 新闻 | 公告/新闻 | - |
| 战报 | 战斗报告 | WarReport |

### 4.4 活动入口网格 (12个)

| 入口 | 说明 |
|---|---|
| 活动 | 活动中心 ActivityPanel |
| 福利 | 福利面板 Welfare |
| 开服 | 开服活动 kaifuactivity |
| 礼包 | 礼包系统 Gift |
| 限时 | 限时活动 |
| 皮肤 | 皮肤商店 SkinShopPanel |
| 竞技 | 竞技入口 |
| 升星 | 升星系统 |
| 首充 | 首充礼包 FirstRechargePanel |
| 特惠 | 特惠活动 jueduiactivity |
| 广告 | 广告活动 |
| 召唤 | 召唤入口 |

---

## 五、全部面板分类统计 (按 Prefab 数量降序)

| 分类 | 数量 | 主要内容 |
|---|---|---|
| ActivityPanel | 120 | 限时/节日活动(春节/圣诞/国庆/开服/合服/新英雄等) |
| HerolhPrefab | 93 | 英雄立绘大图(主城展示用) |
| HeroPrefab | 90 | 战斗角色prefab(Spine动画) |
| SkyCityPanel | 60 | 天空城副本 |
| Guild | 53 | 公会(Boss/排行/公告/加入等) |
| JingjiPrefab | 43 | 竞技场PVP |
| Battle | 30 | 战斗(多种结算面板/Buff提示/出击效果等) |
| HeroPanel | 30 | 英雄(详情/突破/技能/图鉴等) |
| MaoxianPanel | 28 | 冒险系统(含支援/友情等) |
| mapprefabs | 24 | 地图场景(战斗地图/挂机地图等) |
| UserInfo | 23 | 用户信息/改名/头像等 |
| comPrefab | 22 | 通用UI组件(按钮/列表等) |
| yjTreasure | 22 | 遗迹宝藏 |
| ForgePanel | 19 | 锻造(合成/分解/符文/战魂/神器/重置等) |
| ShiLuoFanePanel | 18 | 失落神殿 |
| guajiPanel | 16 | 挂机自动战斗 |
| pvpActivityPanel | 15 | PVP活动面板 |
| BagPanel | 14 | 背包(主界面/出售/格子提示/符文/水晶/合成等) |
| Welfare | 14 | 福利(含开服等级礼包等) |
| HeroActivityPanel | 14 | 英雄相关活动 |
| longComing | 14 | "即将开放"占位面板 |
| HeroPalace | 13 | 英雄殿堂(合成/分解/重生/置换/碎片分解等) |
| TreasurePanel | 12 | 宝藏 |
| CombatPrefab | 11 | 战力(羁绊/阵型/战环/任务等) |
| DrawCard | 9 | 抽卡(主界面/兑换/英雄切换/先知兑换/积分等) |
| TaskPanel | 8 | 任务系统 |
| rank | 8 | 排行榜 |
| ZhiYeTower | 8 | 职业塔 |
| TeachPlace | 8 | 教学场所 |
| HeroTeachPre | 8 | 英雄教学prefab |
| stssActivityPrefab | 8 | SSS英雄活动 |
| HeroListPanel | 7 | 英雄列表 |
| HeroXZPrefab | 7 | 英雄选择prefab |
| RechargePanel | 7 | 充值 |
| RewordPanel | 7 | 奖励面板 |
| Chat | 6 | 聊天(主界面/聊天面板) |
| MozhuPanel | 6 | 魔族面板 |
| WarPathPanel | 6 | 战争之路 |
| WarReport | 6 | 战报 |
| WarcraftPanel | 6 | 魔兽 |
| bigImage | 6 | 大图展示(1010/1020背景图层) |
| binglongPanel | 6 | 冰龙指引 |
| guide | 6 | 新手引导 |
| PassPrefab | 5 | 战令/通行证 |
| StarPlanPanel | 5 | 寻星计划 |
| payPanel | 5 | 支付面板 |
| FindTreasurePanel | 4 | 寻宝(含提示/祝福) |
| Shop | 4 | 商店(含购买装备) |
| SkinShopPanel | 4 | 皮肤商店 |
| XQkaifu | 4 | 新区开服 |
| loading | 4 | 加载(加载页/进度条) |
| ElevatePanel | 3 | 晋升面板 |
| FriendPanel | 3 | 好友(含添加好友) |
| FuWen | 3 | 符文(刷新/选择) |
| HeroLhPanel | 3 | 英雄立绘面板 |
| alert | 3 | 弹窗提示(Alert/断线提示) |
| login | 3 | 登录(LoginPre/pfLoginPanelPre) |
| mainpanel | 3 | 主界面(MainPre/daohangPre) |
| zhanbu | 3 | 占卜 |
| ActivityForecastPanel | 2 | 活动预告 |
| EmailPanel | 2 | 邮件 |
| GetGoldPanel | 2 | 获取金币 |
| Gift | 2 | 礼包 |
| Help | 2 | 帮助 |
| KuafuPvpPane | 2 | 跨服PVP |
| OnlineRewordPanel | 2 | 在线奖励 |
| WelfareDayPanel | 2 | 每日福利 |
| fangchenmi | 2 | 防沉迷(实名认证) |
| CreateRolePanel | 1 | 创建角色 |
| DailyGift | 1 | 每日礼包 |
| FirstRechargePanel | 1 | 首充面板 |
| HeroDetailPanel | 1 | 英雄详情 |
| NewHeroEffectPanel | 1 | 新英雄特效 |
| ResDebug | 1 | 资源调试 |
| RolePanel | 1 | 角色面板 |
| TalkPanel | 1 | 对话面板 |

---

## 六、已还原的 Godot 场景清单

| Godot 场景 | 对应 Prefab | 状态 |
|---|---|---|
| scenes/original_loading.tscn | Prefab/loading/LoadingPre | 已还原基础布局 |
| scenes/original_login.tscn | Prefab/login/LoginPre | 可进入选服页 |
| scenes/original_server_select.tscn | Prefab/login/pfLoginPanelPre | 已实现选服+开始 |
| scenes/original_home_screen.tscn | Prefab/mainpanel/MainPre + daohangPre | 主屏(含Spine英雄/底部导航/右侧入口) |
| scenes/original_hero_list_panel.tscn | Prefab/HeroListPanel/HeroListPre | 英雄列表+详情入口 |
| scenes/original_hero_panel.tscn | Prefab/HeroPanel/HeroBookDetailPre | 英雄详情+Spine+语音+衣装 |
| scenes/original_draw_card_panel.tscn | Prefab/DrawCard/drawCardPre | 抽卡页(页签+Spine) |
| scenes/original_shop_panel.tscn | Prefab/Shop/ShopPre | 商会(商品网格+购买弹窗) |
| scenes/original_bag_panel.tscn | Prefab/BagPanel/BagPre | 仓库(分类+格子) |
| scenes/resource_browser.tscn | - | 资源浏览器 |
| scenes/cocos_prefab_preview.tscn | - | Prefab 对照预览器 |
| scenes/spine_character_viewer.tscn | - | Spine 角色查看器 |
| scenes/main_demo.tscn | - | 主 Demo 导航页 |
| scenes/login_demo.tscn | - | 登录 Demo |

---

## 七、界面数量总结

| 统计维度 | 数量 |
|---|---|
| 启动/登录流程全屏界面 | 4 个 (加载/登录/选服/主城) |
| 底部导航可达的主要界面 | 6 个 |
| 右侧功能区主要界面 | 9 个 |
| 左侧快捷入口界面 | 5 个 |
| 活动入口界面 | 12 个 |
| 其他独立功能界面 | ~15 个 (锻造/符文/占卜/寻宝/职业塔等) |
| **核心独立界面总计** | **约 40-50 个** |
| 弹窗/子面板/Tips | 大量 (数百个) |
| **全部 Prefab 组件总计** | **1018 个** |