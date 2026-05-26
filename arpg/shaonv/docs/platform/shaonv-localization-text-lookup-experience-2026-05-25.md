# 本地化文本查找经验

生成时间：2026-05-25。

本文记录从原始资源中追踪 `lang.bytes` / `lang_extra.bytes` 文本并映射到 Prefab 控件的完整方法。

## 问题起源

MainUIView 的 `gap-analysis` 中发现 `btnPet/Text` Prefab 静态值为 `"宠物"`（简体中文），但实际游戏截图显示 `"遺器"`（繁体中文）。需要找到运行时覆盖文本的来源。

## 查找步骤

### 1. 确认 Prefab 静态值

从 `reverse-output/monobehaviour-fields/MainUIView.mb-fields.json` 提取所有 Text 组件的 `text` 字段，交叉 layout.json 复原完整层级路径：

```
MainUIView/pnlAdapter/pnlBottom/btnPet/Text  →  "宠物"
MainUIView/pnlAdapter/pnlBottom/btnTask/Text  →  "养成"  (dev copy-paste)
MainUIView/pnlAdapter/pnlBottom/btnHero/Text  →  "幻灵"
```

结论：Prefab 中的 Text 静态值是简体中文开发期占位符。

### 2. 定位运行时语言包

回顾 `docs/table-data-analysis.md`，找到 `Table_Language` 的存在线索。在 `reverse-output/assets/` 路径下发现两个关键文件：

```
reverse-output/assets/story-textassets-raw/by_container/Assets/Game/Lang/
  lang.bytes        → 44,534 条目
  lang_extra.bytes  → 10,827 条目
```

### 3. 解析语言包结构

两个文件均以 `\uFEFF` (BOM) 开头，内容为 JSON：

```json
{"lang": ["key1=value1", "key2=value2", ...]}
```

使用 `encoding='utf-8-sig'` 读取即可处理 BOM。

### 4. 搜索目标文本

**直接二进制搜索**（最快）：

```python
data = open('lang.bytes', 'rb').read()
pos = data.find('遺器'.encode('utf-8'))
```

结果：`lang.bytes` 中 `遺器` 首次出现在 byte 2510，上下文为 `pet_tip` 系统提示文本。

**结构化 JSON 搜索**（更精确）：

```python
with open('lang_extra.bytes', 'r', encoding='utf-8-sig') as f:
    data = json.load(f)
for entry in data['lang']:
    key, val = entry.split('=', 1)
    if val.strip() == '遺器':
        print(f'{key} = {val}')
```

结果找到 `UI1000007 = 遺器` 等多条匹配。其中 `UI1000001` ~ `UI1000013` 区间恰好对应底部导航：

```
UI1000001 = 幻靈    (btnHero)
UI1000005 = 背包    (btnBagpack)
UI1000007 = 遺器    (btnPet)
UI1000009 = 現世    (btnGal)
UI1000002 = 養成    (btnDevelop)
UI1000003 = 任務    (btnTask)
UI1000013 = 公會    (btnLegion)
```

### 5. 确认映射正确性

与游戏截图交叉验证：

| 内部名 | 语言包键 | 语言包值 | 截图实际 | 一致 |
|---|---|---|---|---|
| btnHero | UI1000001 | 幻靈 | 幻靈 | ✅ |
| btnBagpack | UI1000005 | 背包 | 背包 | ✅ |
| btnPet | UI1000007 | 遺器 | 遺器 | ✅ |
| btnDevelop | UI1000002 | 養成 | 養成 | ✅ |
| btnTask | UI1000003 | 任務 | 任務 | ✅ |
| btnLegion | UI1000013 | 公會 | 公會 | ✅ |
| btnGal | UI1000009 | 現世 | 現世 | ✅ |

## 关键经验

### 语言包位置

```
Assets/Game/Lang/lang.bytes       → 游戏内容文本（gal_*, hero_*, pet_*, quest_*, ...）
Assets/Game/Lang/lang_extra.bytes  → UI 界面文本（UIXXXXXX 格式键）
```

### 键名模式

| 模式 | 含义 | 示例 |
|---|---|---|
| `UIXXXXXX` | UI 通用文本 | `UI10001=確定`, `UI1000007=遺器` |
| `gal_*` | Gal 约会剧情 (16,557条) | `gal_favor_text_*` |
| `pet_*` | 遗器系统 (454条) | `pet_tip`, `pet_equip_*` |
| `hero_*` | 英雄相关 (2,140条) | `hero_skill_*`, `hero_story_*` |
| `quest_*` | 任务系统 (2,065条) | `quest_name_*`, `quest_des_*` |
| `scdate_*` | 约会日程 (5,748条) | `scdate_*` |
| `relic_*` | 灵装/遗物 (478条) | `relic_*` |
| `function_name_*` | 功能解锁名 (27条) | `function_name_1014=公會` |
| `strength_compared_*` | 战力对比项 (12条) | `strength_compared_n07=遺器` |

### UI 键编号约定

`lang_extra.bytes` 采用 `UI` + 数字键名，每组数字范围对应不同界面模块：

| 区间 | 条目数 | 可能界面 |
|---|---|---|
| UI10000 - UI11122 | 226 | 通用对话框/登录 |
| UI20000 - UI20563 | 457 | 设置/通知 |
| UI30000 - UI31978 | 1,796 | 个人信息/英雄 |
| UI50000 - UI50714 | 699 | 详情/升级 |
| UI70000 - UI74050 | 1,048 | 公会 |
| UI100000 - UI100479 | 464 | 活动/作战 |
| UI110000 - UI111224 | 1,213 | 订阅/奖励 |
| UI1000000+ | ~3,000 | 主页/英雄/养成/各种子系统 |

### 搜索技巧

1. **二进制 grep 最快**：当不确定编码时，用 `grep -la "搜索词"` 搜全目录
2. **BOM 处理**：Unity TextAsset 常带 `\uFEFF`，用 `utf-8-sig` 解码
3. **键值分离**：文件是 `key=value` 格式嵌套在 JSON `"lang"` 数组中
4. **截图验证**：语言包值 ≠ 最终显示值，必须截图交叉确认

### 局限性

- 无法直接从语言包键映射到 Prefab 控件（C# 脚本中的 `Lang.Get("UI1000007")` 调用不在 Prefab 静态数据中）
- 只能通过键名语义（如 `function_name_*`）和截图人工确认映射关系
- `lang.bytes` 内容文本（44K+ 条）可全文索引，但无法自动关联到具体界面控件

## 文件清单

| 文件 | 路径 | 说明 |
|---|---|---|
| lang.bytes 原始 | `reverse-output/assets/story-textassets-raw/by_container/Assets/Game/Lang/lang.bytes` | 游戏内容文本 |
| lang_extra.bytes 原始 | `reverse-output/assets/story-textassets-raw/by_container/Assets/Game/Lang/lang_extra.bytes` | UI 界面文本 |
| lang_parsed.json | `reverse-output/story-texts/lang_parsed.json` | 解析后的 44,534 条目 |
| lang_extra_parsed.json | `reverse-output/story-texts/lang_extra_parsed.json` | 解析后的 10,827 条目 |
| story_lang_keys.csv | `reverse-output/story-texts/story_lang_keys.csv` | 已导出的剧情文本键值表 (23,040条) |
