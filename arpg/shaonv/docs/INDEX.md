# shaonv 文档索引

> AI 阅读策略：先读本文件 → 用 `list_dir` 进入目标子目录 → 只 `read_file` 需要的那一份。
> 全控件清单 (`*-full-control-resource-inventory-*`) 体量大，按需打开。

---

## 目录布局

```
docs/
├── INDEX.md                ← 本文件
├── meta/         (9)       流程 / MVP / 架构决策 / 全量导出指南
├── platform/    (13)       资源管线：YooAsset / Spine / 文本 / 数表
├── ui/
│   ├── startup/      (3)   启动链 (Launch + Login + Loading + 视频)
│   ├── mainui/       (14)  主界面 / City / Activity / 章节 / 背景采样
│   ├── lottery/      (7)   抽卡 / 祈愿 / LotteryDrawNewStageView 链路
│   ├── hero/         (8)   英雄主界面 / 详情 / 列表 / 战斗预览
│   ├── remnants/    (32)   遗器 / 聖物 全模块（装备/列表/升星/进阶/展示）
│   ├── gal/         (40)   约会 / 宿舍 / 收藏 / 关卡 / 特殊触摸
│   └── spine-touch/  (2)   Spine 触摸教学 / 拖拽特效
├── prefabs/    (10)        自动生成的单 prefab 原始布局/绑定（脚本写入区，勿手改）
└── archive/    (8)         历史文档（被新版替代，不再活跃）
```

---

## meta/ — 流程、决策、导出路线

| 文档 | 用途 |
|---|---|
| `analysis-process-log.md` | 工具链 + 数据路径 + 完整分析时间线 |
| `single-player-planning-history.md` | MVP 范围 / 架构决策 合并历史 |
| `shaonv-godot-mvp-start.md` | Godot MVP 初始化记录 + 存档结构 |
| `shaonv-mvp-gap-closure-analysis-2026-05-23.md` | 综合缺口：数据层 + 实现层 |
| `shaonv-single-player-implementation-decision.md` | 选择 Godot 单机实现的理由 |
| `shaonv-prefab-full-inventory-export-route-2026-05-24.md` | 通用全控件清单脚本路线 |
| `shaonv-prefab-inventory-export-master-guide-2026-05-25.md` | 全量清单脚本主指南（最新） |
| `shaonv-docs-reverse-output-audit-2026-05-25.md` | 文档与 reverse-output 审计 |
| `shaonv-hotfix-ui-lifecycle-analysis.md` | ViewBehaviour / UIRoot2d IL 生命周期 |

## platform/ — 资源管线

| 文档 | 用途 |
|---|---|
| `shaonv-yooasset-decryption-hotfix-export.md` | XOR 解密 + DLL 导出 |
| `shaonv-yooasset-manifest-analysis.md` | YooAsset Manifest 结构 |
| `shaonv-yooasset-physical-mapping-fix.md` | 物理路径映射修复 |
| `shaonv-unpack-runtime-cache-analysis.md` | `files/` 运行时缓存分析 |
| `shaonv-godot-spine-runtime-analysis.md` | Spine 接入方案 |
| `shaonv-godot-spine-verification-2026-05-22.md` | Spine 验证记录 |
| `shaonv-godot-spine-pma-fix-2026-05-24.md` | Spine PMA 修复 |
| `shaonv-story-text-analysis.md` | 故事文本导出 |
| `shaonv-localization-full-mapping-2026-05-25.md` | 本地化全量映射 |
| `shaonv-localization-text-lookup-experience-2026-05-25.md` | 本地化文本查找经验 |
| `table-data-analysis.md` | 配置表分析 |
| `shaonv-yooasset-manifest-reverse-dependency-guide-2026-05-27.md` | Manifest 反向定位 / asset→bundle→physical 手册 |
| `shaonv-bundle-resource-name-index-guide-2026-05-27.md` | 按资源名直查本地 bundle 内容索引，避开 `__data` 人肉定位 |

> Spine 补导出 / `batch_bake_all_export_spines.py` 排障提示：
> 先查 `D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default\{BundleFiles,UnpackBundleFiles}`，
> 再判断是不是烘焙脚本问题。详见 `platform/shaonv-yooasset-physical-mapping-fix.md`。
> 2026-05-28 已新增 Expedition 实战案例：`hero_053_s02 / hero_053_s02h` 是通过“按资源名直扫所有本地 bundle 内容”补回的，
> 见 `platform/shaonv-bundle-resource-name-index-guide-2026-05-27.md`
> 与 `ui/mainui/shaonv-expeditionmainview-worldmap-layout-fix-2026-05-27.md`。

---

## ui/startup/ — 启动链

| 文档 | 用途 |
|---|---|
| `shaonv-startup-prefab-layout-analysis-2026-05-23.md` | 启动链 3 屏 + 十大偏差 |
| `shaonv-startup-background-layout-reanalysis-2026-05-24.md` | 启动背景图映射修正 |
| `shaonv-launch-video-prefab-reverse-and-godot-fix-2026-05-26.md` | 启动视频 Prefab 逆向 + Godot 修复 |

> 单 prefab 原始布局：`prefabs/LaunchView-…`、`LoginView-…`、`LoadingView-…`

## ui/mainui/ — 主界面 / City / Activity

| 文档 | 用途 |
|---|---|
| `shaonv-mainui-prefab-layout-analysis-2026-05-23.md` | MainUI 212 节点 + C# IL 状态机 |
| `shaonv-mainui-full-control-resource-inventory-2026-05-24.md` | MainUIView 全控件 + bundle 清单 |
| `shaonv-mainui-data-mapping-2026-05-23.md` | Node→Sprite/Text/Button 映射 |
| `shaonv-mainui-screenshot-layout-comparison-2026-05-24.md` | 主界面截图对照 |
| `shaonv-mainui-godot-gap-analysis-2026-05-25.md` | Godot 主界面缺口分析 |
| `shaonv-mainui-godot-home-fix-experience-2026-05-25.md` | Godot Home 修复经验（坐标错位） |
| `shaonv-mainui-manifest-reverse-lookup-2026-05-27.md` | 主界面 manifest 反查 / 用户头像与资源栏还原检查 |
| `shaonv-mainui-pnlfunny-pnlstory-reverse-lookup-2026-05-27.md` | `pnlFunny` / `pnlStory` / 挂机与章节入口反查 |
| `shaonv-expeditionmap-worldmap-reverse-lookup-2026-05-27.md` | `ExpeditionMapView` 真实 `WorldMap` tile / `map_pic_*` 反查边界 |
| `shaonv-expeditionmap-worldmap-source-bundle-layout-reconstruction-2026-05-27.md` | `share_assets_art_worldmap01*` 源分包解包、8x8 原始拼图和运行时 tile 链路重建 |
| `shaonv-expeditionmainview-worldmap-layout-fix-2026-05-27.md` | `ExpeditionMainView` 首屏场景、驻扎角色和按钮锚点修复记录 |
| `shaonv-chapterrewarddetailgrid-full-control-resource-inventory-2026-05-27.md` | 章节奖励详情格子 |
| `shaonv-chapterrewarddetailview-full-control-resource-inventory-2026-05-27.md` | 章节奖励详情弹层 |
| `shaonv-chaptertaskcell-full-control-resource-inventory-2026-05-27.md` | 章节任务 Cell |
| `shaonv-chaptertaskview-full-control-resource-inventory-2026-05-27.md` | 章节任务视图 |
| `shaonv-cityview-full-control-resource-inventory-2026-05-24.md` | CityView 全控件 |
| `shaonv-activitymainview-full-control-resource-inventory-2026-05-24.md` | ActivityMainView 全控件 |
| `shaonv-background-prefab-sampling-2026-05-24.md` | 20 个背景 prefab 采样 |

## ui/lottery/ — 抽卡 / 祈愿

| 文档 | 用途 |
|---|---|
| `shaonv-gacha-prefab-layout-analysis-2026-05-23.md` | 抽卡 2 屏布局总览 |
| `shaonv-lotterydraw-stage-layout-snapshot-2026-05-26.md` | LotteryDrawStage 演出快照 |
| `shaonv-lotterydrawmainview-full-control-resource-inventory-2026-05-26.md` | 抽卡主界面 全控件 |
| `shaonv-lotterydrawnewstageview-full-control-resource-inventory-2026-05-26.md` | 演出新版 stage view 全控件 |
| `shaonv-lotterydrawstageview-full-control-resource-inventory-2026-05-26.md` | 演出旧版 stage view 全控件 |
| `shaonv-prayerview-full-control-resource-inventory-2026-05-26.md` | 祈愿入口 shell |
| `shaonv-prayerholyrelicpanel-full-control-resource-inventory-2026-05-26.md` | 遺器祈愿主面板 全控件 + pid 对照 |

> 单 prefab 原始布局：`prefabs/LotteryDrawMainView-…`、`LotteryDrawFinishView-…`、`HeroRecruitView-…`、`TopResGrid-…`

## ui/hero/ — 英雄

| 文档 | 用途 |
|---|---|
| `shaonv-heromainview-full-control-resource-inventory-2026-05-24.md` | 英雄详情主屏 全控件 |
| `shaonv-herodetailinfoview-full-control-resource-inventory-2026-05-24.md` | 英雄详情信息弹层 全控件 |
| `shaonv-heromainselectherogrid-full-control-resource-inventory-2026-05-24.md` | 详情主屏选择格 |
| `shaonv-herolisttabgrid-full-control-resource-inventory-2026-05-24.md` | 列表分类 Tab |
| `shaonv-herolistordinationtabgrid-full-control-resource-inventory-2026-05-24.md` | 列表排序 Tab |
| `shaonv-herolistview-physical-bundle-gap-2026-05-24.md` | HeroListView 物理 bundle 缺口 |
| `shaonv-hero-manifest-reverse-lookup-2026-05-27.md` | 英雄列表 manifest 反查 / 缺失 prefab 边界 |
| `shaonv-hero-battle-preview-2026-05-25.md` | 战斗 prefab/Skill/音效 + Godot 预览器 |

## ui/remnants/ — 遗器 / 聖物 (32 docs)

按功能聚类（命名 = `shaonv-<prefab>-full-control-resource-inventory-2026-05-24.md`）：

- **主壳/主面板**：`remnantsmainview`, `remnantsmainshowpanel`
- **列表**：`remnantslistview`, `remnantslistgrid`
- **装备**：`remnantsequipview`, `remnantequipbagview`, `remnantequipbagtypegrid`, `remnantequipmentmaingrid`, `remnantsmarchview`, `remnantsmarchtypegrid`, `remnantsmarchfighttypegrid`
- **属性**：`remnantsattributegrid`, `remnantsattributebonusview`, `remnantsattributebonusgrid`, `remnantinfogrid`
- **进阶/升星/升级**：`remnantsboxlevelview`, `remnantsstarupview`, `remnantsupdateview`, `remnantsupdateselectgrid`, `remnantsupdatetabgrid`, `remnantupeffectview`
- **更换**：`remnantschangeview`, `remnantschangegrid`, `remnantschooseview`
- **位置/分类**：`remnantspositionupdateview`, `remnantspositionpagegrid`, `remnantstageaddview`, `remnantstageaddgrid`, `remnantstypegrid`
- **展示室**：`remnantsshowroomview`, `remnantsshowroomgrid`, `remnantskilldesview`

## ui/gal/ — 约会 / 宿舍 (40 docs)

按子模块聚类：

- **入口/线框**：`gal-main-panel-wireframe`, `gal-restore-experience`
- **主壳**：`galdormitoryview`, `galdormitorymainpanel`, `galdormitorypaneltopbtns`, `galdormitoryplotctlbar`
- **角色**：`galrole`, `galroleselector`, `galroleselectgrid`, `galcharacterview`
- **约会**：`galdateselectview`, `galdateselectgrid`, `gallevelview`, `gallevelgroupgrid`, `gallevelupview`, `gallevelupunlockgrid`, `galmapeventgrid`, `galmaplocationgrid`, `galmemoryselectview`, `gallistentimesbar`
- **宿舍换装**：`galdormitorydressuppanel`, `galdormitorydressupbggrid`, `galdormitorydressupskingrid`, `galdormitorydressupeffectgrid`, `galdormitorydressupunlockgrid`
- **宿舍其他**：`galdormitoryfilespanel`, `galdormitorygiftpanel`, `galeffectgrid`
- **特殊触摸**：`galspecialtouchview`, `galspecialtouchselectview`, `galspecialtouchselectgrid`
- **收藏**：`galcollectionrecordpreview`, `galcollectionrecordgrid`, `galcollectionpagegrid`, `galcollectionrewardview`, `galcollectionrewardgrid`
- **代币/Toast/Tab**：`galtokendetailview`, `galtoastview`, `galtoastgrid`, `galtabgrid`

## ui/spine-touch/ — Spine 触摸

| 文档 | 用途 |
|---|---|
| `shaonv-spinetouchteachpanel-full-control-resource-inventory-2026-05-24.md` | Spine 触摸教学面板 |
| `shaonv-spinedrageffect01-full-control-resource-inventory-2026-05-24.md` | Spine 拖拽特效 |

---

## prefabs/ — 单 prefab 原始布局（脚本输出区）

由 `scripts/unity/batch_extract_all_prefabs.py` 自动生成，请勿手工编辑 / 移动：

- `LaunchView-layout-analysis-…` (4 节点)
- `LoginView-layout-analysis-…` (39 节点 + IL)
- `LoadingView-layout-analysis-…` (9 节点 + IL + Preloading)
- `LotteryDrawMainView-layout-analysis-…` (265 节点)
- `LotteryDrawFinishView-layout-analysis-…` (344 节点)
- `HeroRecruitView-layout-analysis-…` (186 节点)
- `TopResGrid-layout-analysis-…` (6 节点)
- `monobehaviour-fields-report-…` — Image/Text/Button 全量绑定
- `node-count-audit-…` — 节点数量审计
- `rendering-layer-analysis-…` — Canvas 层级分布

## archive/ — 历史文档（已被替代）

`shaonv-ui-startup-analysis.md`, `game-ui-startup-analysis.md`, `shaonv-single-player-ui-data-gap-analysis.md`, `core-gameplay-loop-analysis.md`, `resource-mapping-analysis.md`, `analysis-scope-correction.md`, `shaonv-gacha-single-player-p0-analysis.md`, `shaonv-mainui-resource-analysis-2026-05-23.md`

---

## 关键数据文件（不在 docs/）

| 数据 | 路径 |
|---|---|
| Prefab 布局 JSON | `reverse-output/godot-layout-inspect/*.layout.json` |
| MonoBehaviour 字段 | `reverse-output/monobehaviour-fields/*.mb-fields.json` |
| 背景 Prefab 布局 | `reverse-output/background-layout-inspect/*.layout.json` |
| IL callgraph | `reverse-output/managed/Assembly-CSharp-ui-callgraph/*.il.txt` |
| 物理资产映射 | `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` |
| Bundle 资源名索引 | `reverse-output/assets/bundle-name-index/bundle-resource-name-index.csv` |
| Bundle 摘要索引 | `reverse-output/assets/bundle-name-index/bundle-resource-summary.csv` |
| 本地化文本 | `reverse-output/assets/story-textassets/Assets/Game/Lang/lang_extra.bytes` |
| LotteryDraw 图集导出 | `reverse-output/godot-resource-export/lotterydraw-ce/` |
| Godot MVP 代码 | `standalone/godot-mvp/scripts/` |

## 本地 Bundle 文件清单

下次反查 `bundleName / hashFileName / physicalPath` 时，优先按这个顺序找本地物理文件：

| 用途 | 优先路径 | 说明 |
|---|---|---|
| 运行时缓存 bundle | `files/yoo/Default/BundleFiles/<hash前两位>/<hash>/__data` | 最重要。很多 Spine / Prefab / Sprite 物理包只在这里有，不在 APK 静态资源里。 |
| 运行时 unpack 缓存 | `files/yoo/Default/UnpackBundleFiles/<hash前两位>/<hash>/__data` | 已下载/已解包过的运行时缓存，部分 UI / 图片资源会落这里。 |
| APK 内静态 bundle | `resources/assets/yoo/Default/<hash>.bundle` | 安装包自带的 YooAsset bundle；不是所有 manifest 记录都会在这里存在。 |
| APK 原包复核 | `apk/base.apk`、`apk/split_install_time_asset_pack.apk`、`apk/split_config.arm64_v8a.apk` | 当 `resources/assets/yoo/Default` 没有目标 hash 时，用来确认是否 APK 本身就未下发。 |
| bundle 物理映射 | `reverse-output/assets/yoo-physical-map/physical-bundle-map.csv` | 查 `hashFileName -> physicalPath` 的第一落点。 |
| asset 物理映射 | `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` | 查 `assetPath/address -> bundleName/hashFileName/physicalPath`。 |
| 全量 manifest bundle 表 | `reverse-output/assets/manifest-parsed-py/manifest-parsed-bundles.csv` | 当 `physical-bundle-map.csv` 没有命中时，回到这里查 bundle 元数据。 |
| 全量 manifest asset 表 | `reverse-output/assets/manifest-parsed-py/manifest-parsed-assets.csv` | 当只知道某个 PNG / skel / atlas 资源名时，从这里反查 bundle。 |

固定排障顺序：

1. 先用 `manifest-parsed-assets.csv` 或 `manifest-parsed-bundles.csv` 查到目标 `bundleName` 和 `hashFileName`。
2. 先查 `files/yoo/Default/BundleFiles`，再查 `files/yoo/Default/UnpackBundleFiles`。
3. 只有前两处没有，再查 `resources/assets/yoo/Default/<hash>.bundle`。
4. 三处都没有时，再去 `apk/*.apk` 复核该 hash 是否随安装包下发。
5. 如果 manifest 有记录、但以上位置都没有物理文件，默认按“当前本地缺 bundle”处理，不要先怀疑导出脚本或烘焙脚本。

补充经验：不要只信 `physical-asset-map.csv` 或 manifest 推导出的包名。

- 如果 manifest 里能看到资源名，但 `physicalPath` 仍为空，下一步应该直接“按资源名扫所有本地 bundle 内部 container path”。
- 这一步已实证补回过漏包：
  - `hero_053_s02`
  - `hero_053_s02h`
- 当时 `manifest-parsed-assets.csv` 中这两组 Spine 资源的 `physicalExists=False`，但直接扫描本地 bundle 内容后，实际在以下位置找到了真包：
  - `files/yoo/Default/BundleFiles/d1/d133c1e76a9e76b3b5ebbb26131bb095/__data`
  - `files/yoo/Default/BundleFiles/2e/2ebf56a5c569284708925de1bc096436/__data`
- 所以下次如果出现“manifest 有行、hash 也有，但 physical map 没闭合”的情况，优先按资源名全扫本地 bundle，不要过早下结论说资源缺失。

和 Spine 相关的经验：

- `scripts/spine/batch_bake_all_export_spines.py` 只处理已经进入 `standalone/godot-mvp/assets/spine/all_export` 的条目。
- 如果某个 Spine 没进 `all_export`，优先检查上面这份 bundle 本地文件清单，而不是直接重试 baked。
- 如果 `physical-asset-map.csv` 仍旧漏掉某个 Spine，但你已经在 bundle 扫描里确认命中了资源名，允许先把该资源单独补导到 `tmp/all-spine-export`，再跑：
  - `scripts/spine/import_all_spines_to_godot.py`
  - `scripts/spine/bake_hero_spine_preview.mjs`
  - 或按需只烘新增条目

---

*重组于 2026-05-26，更新于 2026-05-27：补录 May 26-27 新增文档，修正错位文件。*
