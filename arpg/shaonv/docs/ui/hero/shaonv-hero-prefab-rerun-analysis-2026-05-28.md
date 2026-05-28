# 幻灵英雄列表与详情 prefab 复查分析

生成时间：2026-05-28。

本次按用户反馈重新导出并逐个分析 `HeroListView`、`HeroMainView`、`HeroDetailInfoView`。结论先放前面：当前 Godot MVP 的列表外壳有几处坐标已经贴近 prefab，但详情页主体仍然是功能优先的近似稿；尤其是 `HeroMainView` 的角色舞台、左侧功能 tab、筛选弹层、右侧面板语义没有按原 prefab 复位，`HeroDetailInfoView` 也被缩成了右侧小面板，导致观感不像原界面。

## 重新导出清单

| Prefab | 导出文档 | 节点 / Image / Text / Button | 结论 |
|---|---|---:|---|
| `HeroListView` | `docs/ui/hero/shaonv-herolistview-full-control-resource-inventory-2026-05-28-rerun.md` | `104 / 64 / 32 / 14` | 主列表外壳、左侧阵营 tab、顶部按钮、排序条可按清单还原。英雄卡片不是该 prefab 的子节点。 |
| `HeroMainView` | `docs/ui/hero/shaonv-heromainview-full-control-resource-inventory-2026-05-28-rerun.md` | `233 / 146 / 48 / 43` | 详情主屏骨架完整：全屏背景、角色展示遮罩、左侧角色选择条、左侧功能 tab、右侧核心面板、筛选弹层。 |
| `HeroDetailInfoView` | `docs/ui/hero/shaonv-herodetailinfoview-full-control-resource-inventory-2026-05-28-rerun.md` | `73 / 25 / 36 / 4` | 这是 1080x610 的角色信息详情面板，包含头像、姓名、属性、技能、灵装、源神、神具。当前不应直接缩成 0.5 后塞到右侧小栏。 |

导出命令：

```powershell
python scripts/assets/export_prefab_full_inventory.py HeroListView --repo-root . --source-override files/yoo/Default/BundleFiles/e1/e1e72bc826b32ec48c2d8867cbba6e88/__data --out docs/ui/hero/shaonv-herolistview-full-control-resource-inventory-2026-05-28-rerun.md
python scripts/assets/export_prefab_full_inventory.py HeroMainView --repo-root . --out docs/ui/hero/shaonv-heromainview-full-control-resource-inventory-2026-05-28-rerun.md
python scripts/assets/export_prefab_full_inventory.py HeroDetailInfoView --repo-root . --out docs/ui/hero/shaonv-herodetailinfoview-full-control-resource-inventory-2026-05-28-rerun.md
```

## 坐标基准

Godot MVP 的画布是 `1670x750`。对中心锚点的 Unity RectTransform，可按下面方式换算到 Godot 左上角坐标：

- `left = 835 + anchored_x - width / 2`
- `top = 375 - anchored_y - height / 2`

例如 `HeroListView/svHero pos(115,-46) size(978,658)` 换算为 `left=461, top=92`，这与当前 `hero_screen.gd` 的 `HERO_LIST_SCROLL_POS := Vector2(461, 92)` 一致。

## HeroListView 分析

`HeroListView` 是英雄列表的主外壳，不包含实际英雄卡片控件。

可直接还原的骨架：

| 节点 | prefab 布局 | Godot 当前实现 | 判断 |
|---|---|---|---|
| `imgBg` / `imgBg_mask/imgBg` | `hero_bg_01`，`1670x750` 全屏 | `_draw_hero_list_background()` 使用 `hero_bg_01` 全屏 | 基本符合，但当前额外叠了 `hero_bg_10` 与深色遮罩，原 `HeroListView` 没有这层。 |
| `@fx_imgBg_star` | `1670x750` 星光层 | 当前使用 `hero_bg_01_star` | 方向正确，透明度需按原界面观感微调。 |
| `svHero` | `pos(115,-46) size(978,658)`，换算 `461,92` | `HERO_LIST_SCROLL_POS/SIZE = 461,92 / 978,658` | 坐标准确。 |
| `imgLine` | `pos(52,-335) size(8,610)`，约 `x=52 y=100` | 当前画在 `Vector2(52,100)` | 符合。 |
| `tabScrollView` | `pos(127,-75) size(206,600)`，约 `x=24 y=150` | `HERO_LIST_LEFT_TAB_POS = 24,151` | 基本符合。 |
| 六个 `@LeftCommonTabGrid` | y 为 `222,133,44,-45,-134,-223`，间距 89 | `HERO_LIST_LEFT_TAB_STEP = 89` | 基本符合。 |
| `pnlTop/pnlfunc` | 顶部 `x=691 y=24`，按钮 `150x44` | `HERO_LIST_TOP_BUTTON_POS = 691,24` | 符合。 |
| `tabOrdination` | `x=1011 y=24 size=473x44` | `HERO_LIST_SORT_POS = 1011,24` | 符合。 |

主要偏差：

- 当前列表背景额外叠加了 `hero_bg_10`、深色全屏遮罩、列表区域半透明面板，这些不是 `HeroListView` 主 prefab 的节点，视觉会明显偏暗偏“自制 UI”。
- 左侧 tab 当前新增了阵营数量小数字；原节点只含 normal/highlight 图标与文本，`txtNew/imgAllRed` 是红点类提示，不是常驻数量。
- `HeroListView` 只有滚动容器 `svHero`，英雄卡片本体不在这份清单中。当前 `HERO_LIST_CARD_SIZE := 222x252`、四列卡片、卡片边框和状态文案都是 MVP 手工构造，不能称为 prefab 复刻。
- 相关补充清单 `shaonv-herolisthorlistgrid-runtime-template-2026-05-28.md` 只有 `HeroListHorListGrid size(978,296)` 一个空根节点，说明横向列表行是运行时容器，真实卡片还要继续追运行时代码或更深模板。

## HeroMainView 分析

`HeroMainView` 是详情主屏。当前 Godot 详情页最不像原界面的偏差主要都在这里。

可还原骨架：

| 节点 | prefab 布局 | Godot 当前实现 | 判断 |
|---|---|---|---|
| `imgBg` | `hero_bg_01`，`1670x750` 全屏 | 当前详情背景用 `HERO_MAIN_BG_POS := Vector2(-195,-15)` | 明确偏移，应该先回到 `0,0 / 1670,750`。 |
| `Image` / `imgBg_spinemask` | `hero_bg_10`，`1670x750` 全屏 | 当前同样从 `-195,-15` 绘制 | 明确偏移。 |
| `pnlRole` | `pos(-100,0) size(1060,750)`，换算约 `x=205 y=0` | 当前角色舞台 `x=206 y=30 size=660x680` | x 接近，但尺寸严重偏小，舞台应是大遮罩区域，不是窄卡槽。 |
| `pnllLeft/pnlSelectHero` | `pos(36,-90) size(100,640)`，左侧头像条 | `HERO_SELECTOR_PANEL_POS = 36,90 size=100x640` | 面板位置基本符合。 |
| `pnlSelectHero/btnSort` | `size=54x54`，原坐标在选择条下半部 | 当前放在 `HERO_SELECTOR_PANEL_POS + (23,243)`，约 `59,333` | 偏上，按中心锚点估算原位置接近底部 `y≈653`。 |
| `pnllLeft/tabPnl` | `pos(247.5,-370) size(161,500)`，左侧功能 tab 面板 | 当前没有；改成右上横向 `总览/核心/属性/...` | 主要结构缺失。 |
| `pnlRight/pnl4` | inactive，`454x732.5`，`HeroCorePanel`，含核心槽位/属性/按钮 | 当前用 `HeroDetailInfoView` 缩放面板替代 | 语义不匹配。`pnl4` 是核心页，不是通用信息页。 |
| `btnSortSelectHero` | inactive 全屏透明遮罩，内部筛选图标坐标 `186/242/...` | 当前详情筛选弹层从选择条右侧 `x=150 y=90` 展开 | 不匹配；运行时 `@heroFilterBar` 明确给了 `pos(355,106) size(360,130)`。 |

主要偏差：

- 详情页背景不是原始全屏铺法，当前偏移会让角色、UI 和 prefab 坐标系统错开。
- `pnlRole` 原本是 `1060x750` 的大角色展示遮罩，当前 `660x680` 让角色显示区域变窄，整体会像“右侧信息卡 + 中间预览”而不是原 `HeroMainView`。
- 原详情页的功能 tab 是左侧 `tabPnl` 竖向列表，当前做成右上横向标签，信息架构已经变了。
- 原右侧导出的主要 panel 是 `pnl4/HeroCorePanel` 与 `pnlGet/HeroGetPanel`。当前右侧信息面板并非来自 `HeroMainView`，而是把 `HeroDetailInfoView` 缩小后复用。
- 当前“设主看板/设Gal/收藏/返回”等底部按钮是 MVP 功能补位，不在 `HeroMainView` 导出的主结构里。可以保留功能，但需要重新挂到还原后的布局边界内。

## HeroDetailInfoView 分析

`HeroDetailInfoView` 是独立的 1080x610 详情信息面板，不是 `HeroMainView` 右侧 454 宽面板。

可直接还原的节点：

| 节点 | prefab 布局 | 当前实现 | 判断 |
|---|---|---|---|
| `imgBg` | `guessing_bg_03`，`1080x610` | `HERO_DETAIL_INFO_SCALE := 0.5`，绘制为 `540x305` | 缩放导致信息密度和原版完全不同。 |
| `imgHeadFrame/imgHead` | `12,-10 / 140x140`，头像 `126x126` | 当前按 0.5 缩放绘制 | 资源正确，尺寸不对。 |
| `pnlName/txtGod/txtName` | `txtGod fs22`，`txtName fs40` | 当前只显示一行名字和 Spine 文案 | 文案结构不对。 |
| `imgRare/pnlStar/imgOccupation/imgCamp` | 稀有徽章、5 星、职业/阵营图标 | 当前仅稀有、星级、碎片等近似 | 需要补职业/阵营图标区域。 |
| `pnlAttr` | `x=16 y=187 size=510x218`，两列属性 | 当前 10 个属性，缩放后排布 | 原版有 11 个属性标签，坐标也不同。 |
| `pnlSkill` | `x=16 y=426 size=510x135`，4 个 `84x84` 技能按钮 | 当前技能区域拆进 overview/tab | 应恢复为原位置。 |
| `pnlEquip/pnlSlug/pnlWeapon` | 右列三块，每块 `510` 宽，带 scroller | 当前以小槽位模拟 | 缺少原横向滚动区块外观。 |

主要偏差：

- 当前把 `HeroDetailInfoView` 当作详情主屏右侧半屏面板使用；按 prefab，它更像一个完整信息面板，居中时左上约为 `x=295 y=70`。
- 当前标签页内容覆盖在 `HeroDetailInfoView` 后半区，导致原本的属性、技能、灵装、源神、神具布局被二次改造。
- 当前没有保留 `txtGod/txtName` 双标题结构，也没有按原 `txtOccupation/txtCamp` 的图标+文字方式绘制。
- 原 `HeroDetailInfoView` 只有 4 个技能按钮；养成动作可以保留为本地 MVP 功能，但不应改变这个面板的基础布局。

## 当前 Godot 偏差归因

当前 `standalone/godot-mvp/scripts/screens/hero_screen.gd` 的实现是“可用优先”：

- 列表外壳坐标大体按 `HeroListView` 落了，但英雄卡片视觉是自行设计。
- 详情页把 `HeroMainView`、`HeroDetailInfoView`、本地养成功能揉成了一个混合布局。
- 为了交互完整性增加了多个非 prefab 控件：收集数、列表数量、提示弹窗、详情横向 tabs、底部动作按钮、局部深色面板。
- 这些控件本身可用，但会压低原界面复刻度。

## 下一步还原建议

建议按这个顺序继续改，而不是继续在现有混合布局上微调：

1. 先把 `HeroMainView` 坐标系统复位：背景 `0,0/1670,750`，`pnlRole` 改成 `x=205 y=0 size=1060x750`，左侧选择条保留 `36,90/100x640`。
2. 用 `HeroMainSelectHeroGrid` 清单重画左侧头像项：`70x70` 头像、`100x100` 高亮、`70x14` 星条、`common_img_61` 等级角标、`pnlRedDot`。
3. 恢复 `HeroMainView/pnllLeft/tabPnl` 竖向功能 tab，当前右上横向 tabs 先移除或降级为调试/快捷入口。
4. 按 `@heroFilterBar pos(355,106) size(360,130)` 重放详情筛选弹层；列表页不应强行使用这套弹层，除非原逻辑确有打开入口。
5. `HeroDetailInfoView` 不再以 0.5 缩放塞在右侧。要么作为完整信息弹窗居中 `1080x610`，要么只抽其中资源重做一个单独的右侧面板，但不能称为按该 prefab 还原。
6. 列表卡片继续追 `HeroListHorListGrid` 的运行时代码/子模板。仅凭这三份清单，最多能还原 `svHero` 容器和 978x296 行高，不能还原卡片内部原始控件。

## 可保留的 MVP 功能

这些功能可以继续保留，但应挂到原布局之后：

- 列表筛选、排序、滚动、未获得英雄可点。
- 详情角色左右切换、返回列表。
- 本地 save 驱动的培养、升星、技能升级、装备强化、收藏、设看板。
- PNG/Spine/baked fallback 加载修复继续保留，不需要回滚 `main.gd` 和 `spine_baked_preview_canvas.gd`。
