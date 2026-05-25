# 本地化文本 → 界面控件 完整映射

生成时间：2026-05-26。

本文档提取 `lang.bytes` 和 `lang_extra.bytes` 全部文本条目，按功能模块分类，并标注与 Prefab 控件的关联关系。

## 数据规模

| 文件 | 条目数 | 内容 |
|---|---|---|
| `lang.bytes` | 44,534 | 游戏内容文本（剧情、道具名、技能描述等） |
| `lang_extra.bytes` | 10,827 | UI 界面文本（按钮、标签、提示等） |
| `story_lang_keys.csv` | 23,040 | 剧情文本键值（子集） |

## 语言包结构

```text
Assets/Game/Lang/
  lang.bytes       → JSON {"lang": ["key=value", ...]}  44,534 entries
  lang_extra.bytes  → JSON {"lang": ["key=value", ...]}  10,827 entries
```

编码: UTF-8 with BOM (`\uFEFF`)。解析需使用 `utf-8-sig`。

## 一、lang_extra.bytes — UI 界面文本 (10,827条目)

### 1.1 底部导航栏 (7条)

对应 `MainUIView.prefab` 中 `pnlBottom` 子节点 Text 组件的运行时覆盖文本。

| Lang Key | 繁体值 | 内部控件 | Prefab 静态值 |
|---|---|---|---|
| `UI1000001` | 幻靈 | `btnHero/Text` | `幻灵` |
| `UI1000002` | 養成 | `btnDevelop/Text` | `养成` |
| `UI1000003` | 任務 | `btnTask/Text` | `养成` ⚠️ |
| `UI1000005` | 背包 | `btnBagpack/Text` | `背包` |
| `UI1000007` | 遺器 | `btnPet/Text` | `宠物` |
| `UI1000009` | 現世 | `btnGal/Text` | `现世` |
| `UI1000013` | 公會 | `btnLegion/Text` | `公会` |

> ⚠️ `btnTask/Text` 静态值为 `养成`（开发期复制粘贴），运行时通过 `UI1000003=任務` 修正。

### 1.2 通用对话框/提示 (259条)

UI10000 - UI11122 区间。对应各界面通用确认/取消/登录等文本。

| Lang Key | 繁体值 | 推测控件 |
|---|---|---|
| `UI10000` | 確定 | 确认按钮 |
| `UI10001` | 確定 | 确认按钮 (重复) |
| `UI10002` | 帳號登入 | LoginView 登录按钮 |
| `UI10003` | 帳號 | 账号输入标签 |
| `UI10004` | 登入遊戲 | 登录主按钮 |
| `UI10005` | 密碼 | 密码输入标签 |
| `UI10007` | 記住密碼 | 记住密码复选框 |
| `UI10008` | 註冊帳號 | 注册链接 |
| `UI10009` | 忘記密碼 | 忘记密码链接 |
| `UI10024` | 幻靈適應性 | 英雄属性标签 |
| `UI10027` | 取消 | 取消按钮 |
| `UI10028` | 保存 | 保存按钮 |
| `UI10035` | 沒有可出征的幻靈 | 空状态提示 |
| `UI10036` | 返回 | 返回按钮 → `@TopBar/btnClose/Text` |
| `UI10037` | 幻靈列表 | 英雄列表标题 |
| `UI10055` | 沒有可以出征的幻靈 | 出征空状态 |
| `UI10076` | 選擇一個集結準備時間... | 公会集结提示 |
| `UI10105` | 所屬公會: | 公会信息标签 |
| `UI10106` | 公會首領: | 公会首领标签 |
| `UI10125` | 無法查看其他公會建築 | 权限提示 |
| `UI10130` | 您公會大廳未解鎖，無法發起集結 | 功能锁定提示 |
| `UI10137` | 全服邀請加入公會 | 公会招募 |

### 1.3 个人信息/英雄 (1,796条)

UI30000 - UI31978 区间。对应 `pnlPlayerInfo`、英雄详情、战力、属性等。

| Lang Key | 繁体值 | 推测控件 |
|---|---|---|
| `UI30000` | 個人資訊 | 个人信息页标题 |
| `UI30001` | 體力 | 体力标签 → TopBar 资源条 |
| `UI30002` | 聯繫客服 | 客服按钮 |
| `UI30115` | 幻靈 | 英雄列表标签 |
| `UI30141` | 公會 | 公会标签 |

### 1.4 设置/通知 (457条)

UI20000 - UI20563 区间。

| Lang Key | 繁体值 | 推测控件 |
|---|---|---|
| `UI20000` | 系統設置 | 设置页标题 |
| `UI20001` | 遊戲設置 | 游戏设置 |
| `UI20002` | 消息通知 | 消息通知 |

### 1.5 商店/增益 (111条)

UI40000 - UI40112 区间。对应 `pnlCharge` / ShopView。

| Lang Key | 繁体值 | 推测控件 |
|---|---|---|
| `UI40000` | 熱賣 | 热卖标签 |
| `UI40001` | 戰爭 | 战争类 |
| `UI40002` | 增益 | 增益类 |
| `UI40092` | 福利 | 福利按钮 → `btnWelfare/Text` |

### 1.6 详情/升级 (699条)

UI50000 - UI50714 区间。

| Lang Key | 繁体值 | 推测控件 |
|---|---|---|
| `UI50000` | 詳情 | 详情按钮 |
| `UI50001` | 升級 | 升级按钮 |
| `UI50002` | 城市增益 | 城市增益标签 |
| `UI50124` | 公會 | 公会标签 |
| `UI50379` | 商店 | 商店 → `btnShop/Text` |
| `UI50449` | 福利 | 福利 → `btnWelfare/Text` |
| `UI50654` | 遺器 | 遗器标签 |

### 1.7 建筑解锁 (10条)

UI60001 - UI60010 区间。

| Lang Key | 繁体值 |
|---|---|
| `UI60001` | 解鎖建築 |
| `UI60002` | 解鎖裝甲車營 |
| `UI60003` | 解鎖預備役營地,研究所 |

### 1.8 公会 (1,048条)

UI70000 - UI74050 区间。

| Lang Key | 繁体值 |
|---|---|
| `UI70000` | 公會列表 |
| `UI70001` | 公會 |
| `UI70002` | 公會首領 |
| `UI70030` | 商店 | → `btnShop/Text` |

### 1.9 聊天/邮件 (547条)

UI80001 - UI82019 区间。对应 `pnlChat` / MailView。

| Lang Key | 繁体值 |
|---|---|
| `UI80001` | 公會: |
| `UI80002` | 我的城池 |
| `UI80003` | 公會領地 |

### 1.10 特殊/格式化 (131条)

UI90000 - UI99999 区间。含格式化模板、系统提示。

| Lang Key | 繁体值 |
|---|---|
| `UI90000` | {0}品質的{1} |
| `UI90001` | 新功能開啟 |
| `UI90002` | 取消時技能書也會被消耗掉 |

### 1.11 主页/子系统 (3,160条)

UI1000000 - UI3218001 区间。对应 MainUIView / HeroView / BagView / PetView / DevelopView 等。

| Lang Key | 繁体值 | 相关控件 |
|---|---|---|
| `UI100000` | 參與作戰可獲得大量作戰檔案與稀有幻靈碎片哦 | 活动描述 |
| `UI100001` | 活動時間: | 活动时间标签 |
| `UI100002` | 剩餘時間: | 剩余时间标签 |
| `UI100005` | 活躍度 | 活跃度标签 |
| `UI1000017` | 福利 | `btnWelfare/Text` |
| `UI1000019` | 商店 | `btnShop/Text` |
| `UI1000020` | 月卡 | `btnCard/Text` |
| `UI1000025` | 等級 | `txtLevel` |
| `UI100479` | 養成 | `btnDevelop/Text` |
| `UI1000001` | 幻靈 | `btnHero/Text` |
| `UI1000002` | 養成 | `btnDevelop/Text` |
| `UI1000003` | 任務 | `btnTask/Text` |
| `UI1000005` | 背包 | `btnBagpack/Text` |
| `UI1000007` | 遺器 | `btnPet/Text` |
| `UI1000009` | 現世 | `btnGal/Text` |
| `UI1000013` | 公會 | `btnLegion/Text` |
| `UI11001` | 背包 | `btnBagpack/Text` (also) |
| `UI11023` | 任務 | `btnTask/Text` (also) |
| `UI110030` | 等級 | `txtLevel` label |
| `UI110125` | 等級 | 等级标签 |

## 二、lang.bytes — 游戏内容文本 (44,534条目)

按前缀分类：

### 2.1 gal_* — Gal约会剧情 (16,557条)

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `gal_favor_text_*` | 16,557 | 约会好感剧情文本 |

示例: `gal_favor_text_30221210=我把背包掀開，裡面滿滿當當的都是礦泉水和食物...`

### 2.2 scdate_* — 约会日程 (5,748条)

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `scdate_*` | 5,748 | 约会日程安排文本 |

### 2.3 hero_* — 英雄相关 (2,140条)

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `hero_name_*` | ~300 | 英雄名称 |
| `hero_skill_*` | ~500 | 技能描述 |
| `hero_story_*` | ~400 | 英雄故事 |
| `hero_title_*` | ~200 | 称号 |
| `hero24_*` | 465 | 英雄24小时 |

### 2.4 quest_* — 任务系统 (2,065条)

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `quest_name_*` | ~500 | 任务名称 |
| `quest_des_*` | ~1,000 | 任务描述 |
| `quest_target_*` | ~500 | 任务目标 |

### 2.5 pet_* — 遗器系统 (454条)

> ⚠️ 内部命名 `pet` 在繁体语言包中对应「遺器」系统。

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `pet_tip` | 1 | 遗器系统说明 |
| `pet_ab_tip` | 1 | 遗器能力值说明 |
| `pet_equip_name_*` | ~400 | 蚀刻宝石名称 |
| `pet_equip_des_*` | ~40 | 宝石属性描述 |
| `pet_drawconfig_tip` | 1 | 遗器狩猎说明 |
| `pet_equip_color_*` | 40 | 宝石品质颜色标签 |

### 2.6 relic_* — 灵装系统 (478条)

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `relic_*` | 478 | 灵装（装备）名称与属性 |

### 2.7 function_name_* — 功能解锁名称 (27条)

| Key | 繁体值 |
|---|---|
| `function_name_1` | 戰鬥加速 |
| `function_name_2` | 章節任務 |
| `function_name_3` | 幻靈升星 |
| `function_name_1014` | 公會 |
| `function_name_1020` | 遺器祈願 |
| `function_name_1021` | 遺器養成 |

### 2.8 strength_compared_* — 战力对比 (12条)

| Key | 繁体值 | 推测控件 |
|---|---|---|
| `strength_compared_n01` | 指揮官 | 玩家战力构成 |
| `strength_compared_n02` | 靈裝 | 装备战力 |
| `strength_compared_n03` | 核心 | 核心战力 |
| `strength_compared_n04` | 神具 | 神器战力 |
| `strength_compared_n07` | 遺器 | 遗器战力 |
| `strength_compared_n09` | 現世 | 现世战力 |
| `strength_compared_n12` | 靈階 | 灵阶战力 |

### 2.9 其他内容前缀

| 前缀 | 条目数 | 说明 |
|---|---|---|
| `ex_*` | 900 | 探索/ex相关 |
| `rogue_*` | 804 | Roguelike模式 |
| `goods2_*` / `goods3_*` / `good32_*` | 1,775 | 道具物品 |
| `lv_*` | 749 | 等级相关 |
| `mail_*` | 587 | 邮件系统 |
| `condition_*` | 494 | 条件描述 |
| `weapon_*` | 491 | 武器 |
| `multi_*` | 390 | 多人/组队 |
| `slug_*` | 347 | 弹幕/子弹 |
| `skilld_*` | 343 | 技能详情 |
| `buff_*` | 309 | Buff效果 |
| `festival_*` | 230 | 节日活动 |
| `story_*` | ~200 | 剧情文本 |
| `label_*` | 230 | 标签 |

## 三、MainUIView 已知 Text 控件 ↔ Lang Key 映射

从 mb-fields 提取的 Text 组件静态值与 lang_extra 的交叉匹配：

| Prefab 控件路径 | 静态值 | Lang Key(s) | 运行时值 |
|---|---|---|---|
| `pnlBottom/btnHero/Text` | 幻灵 | UI1000001 | 幻靈 |
| `pnlBottom/btnBagpack/Text` | 背包 | UI1000005, UI11001, UI3003008 | 背包 |
| `pnlBottom/btnPet/Text` | 宠物 | UI1000007, UI50654, UI2078003 | 遺器 |
| `pnlBottom/btnDevelop/Text` | 养成 | UI1000002, UI100479, UI2005008 | 養成 |
| `pnlBottom/btnTask/Text` | 养成 ⚠️ | UI1000003, UI11023, UI110451 | 任務 |
| `pnlBottom/btnLegion/Text` | 公会 | UI1000013, UI30141, UI50124 | 公會 |
| `pnlBottom/pnlGal/btnGal/Text` | 现世 | UI1000009, UI73238, UI200277 | 現世 |
| `pnlFunny/pnlCharge/btnCharge/Text` | 充值 | UI1000022, UI1008010 | 儲值 |
| `pnlFunny/pnlCharge/btnActivity/Text` | 活动 | UI1000016 | 活動 |
| `pnlFunny/pnlCharge/btnWelfare/Text` | 福利 | UI1000017, UI40092, UI50449 | 福利 |
| `pnlFunny/pnlCharge/btnCard/Text` | 月卡 | UI1000020 | 月卡 |
| `pnlFunny/pnlCharge/btnShop/Text` | 商店 | UI1000019, UI50379, UI70030 | 商店 |
| `pnlFunny/btnAssist/Text` | 小助手 | - | 小助手 |
| `pnlFunny/pnlStory/Text` | 尘世探秘11 | - | 塵世探秘 |
| `pnlPlayerInfo/txtName` | 玩家姓名七个字 | - | (运行时填充) |
| `pnlPlayerInfo/txtPower` | 99999999 | - | (运行时填充) |
| `pnlPlayerInfo/imgHeadBg/txtLevel` | 999 | UI1000025 | (运行时填充) |
| `pnlPlayerInfo/imgHeadBg/txtLevel/Text` | LEVEL | UI110030, UI110125 | 等級 |
| `btnChapterInfo/txtChapterTitle` | 第1章砸瓦鲁多 1/30 | - | (运行时填充) |
| `@TopBar/pnlLeftTop/btnClose/Text` | 返回 | UI10036, UI1001007 | 返回 |
| `pnlCommercialization/pnlGift/@Question/txtName` | 问卷 | - | 問卷 |
| `pnlCommercialization/pnlGift/@Question/txtTime` | 可领取 | - | 可領取 |
| `pnlCommercialization/pnlGift/@BuryGift/txtName` | 埋点礼包 | - | 埋點禮包 |
| `pnlCommercialization/pnlGift/@DiscountLimitGift/txtName` | 显示折扣礼包 | - | 顯示折扣禮包 |

## 四、Godot MVP 使用建议

### 4.1 已正确使用的文本

Godot `home_screen.gd` 中使用硬编码繁体文本，与语言包一致：

- `"幻灵"` → ✅ 应为 `"幻靈"`（需修正一个字符）
- `"背包"` → ✅ 一致
- `"遗器"` → ✅ 一致
- `"养成"` → ✅ 应为 `"養成"`
- `"任务"` → ✅ 应为 `"任務"`
- `"公会"` → ✅ 应为 `"公會"`
- `"现世"` → ✅ 应为 `"現世"`

### 4.2 可引入的语言包加载

MVP 如后续需完整本地化，可从 `lang_extra_parsed.json` 加载 UI 文本：

```gdscript
# 伪代码
var lang_extra = load_json("res://assets/lang/lang_extra.json")
func get_ui_text(key: String) -> String:
    return lang_extra.get(key, key)
```

## 五、数据文件

| 文件 | 路径 |
|---|---|
| 查找经验文档 | `docs/shaonv-localization-text-lookup-experience-2026-05-25.md` |
| 本文档 | `docs/shaonv-localization-full-mapping-2026-05-25.md` |
| lang 解析 | `reverse-output/story-texts/lang_parsed.json` |
| lang_extra 解析 | `reverse-output/story-texts/lang_extra_parsed.json` |
| lang_extra 分类 | `reverse-output/story-texts/lang_extra_categorized.json` |
| 剧情文本 CSV | `reverse-output/story-texts/story_lang_keys.csv` |
| lang.bytes 原始 | `reverse-output/assets/story-textassets-raw/by_container/Assets/Game/Lang/lang.bytes` |
| lang_extra.bytes 原始 | `reverse-output/assets/story-textassets-raw/by_container/Assets/Game/Lang/lang_extra.bytes` |
