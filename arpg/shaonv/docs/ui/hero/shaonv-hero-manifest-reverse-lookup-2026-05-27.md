# Hero UI Manifest 反查记录

生成时间：2026-05-27。

本文按 `docs/ui/shaonv-yooasset-manifest-reverse-dependency-guide-2026-05-27.md` 复查英雄界面资料缺口，重点确认 `HeroListView` 以及英雄列表相关模板的 manifest、resolved bundle 和本地 physical 状态。

## 反查要点

- `manifest-parsed-assets.csv` 的 `bundleID` 不是 parsed bundle 表的直接 id；英雄 prefab 行里存在 `bundleIDOffset=-133`，应使用 `resolvedBundleID`，或用 `bundleName/hashFileName` 双键核对。
- `HeroListView`、`HeroListDividerLine`、`HeroListHorListGrid` 在 manifest 中都有 asset 地址和 hash，但本地 parsed bundle / physical map 均显示无物理文件。
- `HeroListTabGrid`、`HeroListOrdinationTabGrid`、`HeroMainSelectHeroGrid`、`HeroMainView`、`HeroDetailInfoView` 可直接按现有全控件清单作为还原依据。

## HeroList 相关 Prefab 状态

| Prefab | asset id | resolvedBundleID | hashFileName | physical | 结论 |
|---|---:|---:|---|---|---|
| `HeroListDividerLine` | 2374 | 2192 | `5c76bba77021106b032334ecba1375f8.bundle` | 否 | 只能从 manifest 依赖确认相关 Spine 资源，不能导出节点。 |
| `HeroListHorListGrid` | 2375 | 2193 | `14a474359c68fa33cdc9fd9c87c251ae.bundle` | 否 | 列表横向卡片原 prefab 缺失，且 `dependAssetIDs` 为空。 |
| `HeroListOrdinationTabGrid` | 2376 | 2194 | `74e0767f134b569c4935811d865b0e97.bundle` | 是 | 可导出；排序 tab 为 111x44，文本为“战力”。 |
| `HeroListTabGrid` | 2377 | 2195 | `0a5d481788549bdbd647e64afa859fda.bundle` | 是 | 可导出；分类 tab 为 206x62，选中图为 `common_btn_07`。 |
| `HeroListView` | 2378 | 2196 | `6ee0abcfd37a8ba5a54acfc9003167ca.bundle` | 否 | 主列表 prefab 缺失，不能生成完整节点树。 |

## HeroListView 依赖展开

`HeroListView.dependAssetIDs`：

`2117|2118|2327|5272|5273|5430|5500|5501|5893|6609|6640|6748|6749|6815|6873`

已展开结果中，`5272` 之后主要是英雄 Spine bundle，且 physical 均存在，例如 `hero_023h`、`hero_028`、`hero_032`、`hero_045`、`hero_056`、`hero_059`、`hero_060h`、`hero_061_s01h`。这说明 manifest 能确认列表主界面会触达英雄展示素材，但不能补回缺失的 `HeroListView` / `HeroListHorListGrid` 节点结构。

前三个依赖分别落到 `Chat` / `GameShop` prefab，当前 physical 也不存在；它们不应被当作英雄列表卡片模板使用。

## 可还原边界

可以按原始资料还原：

- 分类 Tab：`HeroListTabGrid`，206x62，`common_btn_07` 选中态。
- 排序 Tab：`HeroListOrdinationTabGrid`，111x44，透明按钮 + normal/highlight 双文本。
- 详情页左侧头像格：`HeroMainSelectHeroGrid`，70x70 圆头像，100x100 高亮 `hero_img_119`，等级角标 `common_img_61`，星条 `common_img_62`，头像框 `common_img_64`。
- 英雄详情主屏：`HeroMainView` 和 `HeroDetailInfoView` 清单继续作为主依据。

需要标记为推断还原：

- `HeroListView` 主容器布局。
- `HeroListHorListGrid` 列表卡片原始节点、尺寸和资源。
- `HeroListDividerLine` 原始分隔线节点。

Godot 当前英雄列表因此采用“可验证资源 + 推断列表容器”的方式修复：排序默认按等级，卡片显示等级角标，分类/排序控件优先贴近已导出的 tab/grid 资源。

## Godot 还原检查记录

2026-05-27 复查后已对齐的 Godot 项：

| Godot 区域 | 原始依据 | 处理 |
|---|---|---|
| 英雄排序默认项 | 用户要求“英雄按照等级排列”；`HeroListOrdinationTabGrid` 为排序 tab 模板 | `gallery_sort_mode` 默认改为 `level`，排序菜单将“等级”置于第一项。 |
| 详情左侧头像选择格 | `HeroMainSelectHeroGrid`：70x70 头像、100x100 高亮、`common_img_61/62/64`、`hero_img_119/60` | 继续按等级排序，保留等级角标、星条、头像框和选中高亮。 |
| 英雄列表卡片等级 | `HeroMainSelectHeroGrid/Image/txtLv` 与 `common_img_61` | 列表卡片显示等级角标，避免只改内部排序但界面不可见。 |
| 英雄列表小星级 | `HeroMainSelectHeroGrid/pnlStar/imgStar1-5` 使用 `hero_img_60`，14x14 | 列表卡片的小星级从 `R` 文本恢复为 `hero_img_60` 星图标。 |
| 筛选面板背景 | `HeroMainView/@heroFilterBar/Image`，360x130，资源 `hero_img_108` | Godot 继续使用 `hero_img_108` 作为筛选面板背景。 |
| 筛选面板职业/阵营两排图标 | `HeroMainView/btnSortSelectHero/btnOccupation*` 与 `btnCamp*`，56x56 点击区，图标 `hero_img_109-119/199` | Godot 增加职业筛选状态，并按两排图标布局显示 occupation/camp 过滤入口。 |
| 详情信息框 | `HeroDetailInfoView/imgBg`，1080x610，资源 `guessing_bg_03`；标题条 `common_img_199`；技能框 `common_img_208` | Godot 以 0.5 缩放复刻详情信息框，保留属性、技能、灵装/源神/神具区块。 |

仍需保留为推断项：

- 英雄列表横向卡片 `HeroListHorListGrid` 缺 physical，Godot 卡片布局不能声明为原始还原。
- 英雄列表主容器 `HeroListView` 缺 physical，当前列表网格位置、列数、卡片尺寸为 MVP 推断布局。
