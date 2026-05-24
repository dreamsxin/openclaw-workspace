# Docs 索引

> AI 助手读取顺序建议：自上而下

---

## 快速导航

| 你想做什么 | 读哪个文件 |
|-----------|-----------|
| 了解 MVP 当前状态 | `shaonv-godot-mvp-start.md` |
| 知道还有什么没做 | `shaonv-mvp-gap-closure-analysis-2026-05-23.md` |
| 查看启动链布局 | `shaonv-startup-prefab-layout-analysis-2026-05-23.md` |
| 查看主界面布局 | `shaonv-mainui-prefab-layout-analysis-2026-05-23.md` |
| 查看主界面截图对照 | `shaonv-mainui-screenshot-layout-comparison-2026-05-24.md` |
| 查看 MainUIView 全控件资源清单 | `shaonv-mainui-full-control-resource-inventory-2026-05-24.md` |
| 查看 Prefab 全量清单导出路线 | `shaonv-prefab-full-inventory-export-route-2026-05-24.md` |
| 查看抽卡布局 | `shaonv-gacha-prefab-layout-analysis-2026-05-23.md` |
| 查 sprite 绑定 | `prefabs/monobehaviour-fields-report-2026-05-23.md` |
| 查节点数量审计 | `prefabs/node-count-audit-2026-05-23.md` |
| 查渲染层级 | `prefabs/rendering-layer-analysis-2026-05-23.md` |
| 查某个 prefab 详情 | `prefabs/<Name>-layout-analysis-2026-05-23.md` |
| 查背景图映射 | `shaonv-startup-background-layout-reanalysis-2026-05-24.md` |
| 了解架构决策 | `shaonv-single-player-implementation-decision.md` |
| 了解工具链 | `analysis-process-log.md` |

---

## 目录结构

```
docs/
├── INDEX.md                                  ← 本文件
│
├── analysis-process-log.md                   [05-22~24 合并] 工具链 + 数据路径 + 时间线
├── single-player-planning-history.md         [05-22~23 合并] MVP 范围 + 架构决策
│
├── shaonv-godot-mvp-start.md                 [05-22] MVP 初始化记录 + 存档结构
├── shaonv-mvp-gap-closure-analysis-2026-05-23.md  [05-23] 综合缺口：数据层 + 实现层
│
├── shaonv-startup-background-layout-reanalysis-2026-05-24.md  [05-24] 背景图映射修正
├── shaonv-startup-prefab-layout-analysis-2026-05-23.md        [05-23] 启动链 3 屏 + 十大偏差
├── shaonv-mainui-prefab-layout-analysis-2026-05-23.md         [05-23] MainUI 212 节点 + C# IL 状态机
├── shaonv-mainui-screenshot-layout-comparison-2026-05-24.md   [05-24] MainUI 截图对照 + 完整可见布局
├── shaonv-mainui-full-control-resource-inventory-2026-05-24.md [05-24] MainUIView 212 节点 + Image/Text/Button + bundle 清单
├── shaonv-prefab-full-inventory-export-route-2026-05-24.md    [05-24] 通用全量清单脚本路线 + City/Activity 验证
├── shaonv-cityview-full-control-resource-inventory-2026-05-24.md [05-24] CityView 全控件资源清单
├── shaonv-activitymainview-full-control-resource-inventory-2026-05-24.md [05-24] ActivityMainView 全控件资源清单
├── shaonv-galdormitoryview-full-control-resource-inventory-2026-05-24.md [05-24] 约会/宿舍主壳全控件资源清单
├── shaonv-galdormitorymainpanel-full-control-resource-inventory-2026-05-24.md [05-24] 约会/宿舍主面板全控件资源清单
├── shaonv-galdateselectview-full-control-resource-inventory-2026-05-24.md [05-24] 约会选择界面全控件资源清单
├── shaonv-heromainview-full-control-resource-inventory-2026-05-24.md [05-24] 英雄详情主屏全控件资源清单
├── shaonv-herodetailinfoview-full-control-resource-inventory-2026-05-24.md [05-24] 英雄详情信息弹层全控件资源清单
├── shaonv-heromainselectherogrid-full-control-resource-inventory-2026-05-24.md [05-24] 英雄详情选择格全控件资源清单
├── shaonv-herolisttabgrid-full-control-resource-inventory-2026-05-24.md [05-24] 英雄列表分类 Tab 清单
├── shaonv-herolistordinationtabgrid-full-control-resource-inventory-2026-05-24.md [05-24] 英雄列表排序 Tab 清单
├── shaonv-herolistview-physical-bundle-gap-2026-05-24.md [05-24] HeroListView 物理 bundle 缺口记录
├── shaonv-mainui-data-mapping-2026-05-23.md                  [05-23] Node→Sprite/Text/Button 映射
├── shaonv-gacha-prefab-layout-analysis-2026-05-23.md          [05-23] 抽卡 2 屏布局
├── shaonv-background-prefab-sampling-2026-05-24.md            [05-24] 20 额外 prefab 采样
│
├── shaonv-single-player-implementation-decision.md  [05-22] Godot 选择理由
├── shaonv-hotfix-ui-lifecycle-analysis.md           [05-22] ViewBehaviour/UIRoot2d IL
├── shaonv-godot-spine-runtime-analysis.md           [05-22] Spine 接入方案
├── shaonv-godot-spine-verification-2026-05-22.md    [05-22] Spine 验证记录
├── shaonv-unpack-runtime-cache-analysis.md          [05-22] files/ 目录分析
├── shaonv-yooasset-decryption-hotfix-export.md      [05-22] XOR 解密 + DLL 导出
├── shaonv-yooasset-manifest-analysis.md             [05-22] Manifest 结构
├── shaonv-yooasset-physical-mapping-fix.md          [05-22] 物理路径修复
├── shaonv-story-text-analysis.md                    [05-22] 故事文本导出
├── table-data-analysis.md                           [05-22] 配置表分析
│
├── prefabs/                                        ← 每个 prefab 独立分析
│   ├── LaunchView-layout-analysis-2026-05-23.md       4 节点
│   ├── LoginView-layout-analysis-2026-05-23.md       39 节点 + IL
│   ├── LoadingView-layout-analysis-2026-05-23.md      9 节点 + IL + PreloadingView
│   ├── MainUIView 主界面 → 见上层 shaonv-mainui-prefab-layout-analysis
│   ├── LotteryDrawMainView-layout-analysis-2026-05-23.md   265 节点
│   ├── LotteryDrawFinishView-layout-analysis-2026-05-23.md  344 节点
│   ├── HeroRecruitView-layout-analysis-2026-05-23.md       186 节点
│   ├── TopResGrid-layout-analysis-2026-05-23.md              6 节点
│   ├── monobehaviour-fields-report-2026-05-23.md     Image/Text/Button 绑定表
│   ├── node-count-audit-2026-05-23.md                节点数量审计
│   └── rendering-layer-analysis-2026-05-23.md        5 层 + Canvas 分布
│
└── archive/                                       ← 历史文档，不再活跃
    ├── shaonv-ui-startup-analysis.md              [05-22] → 被 startup-prefab 替代
    ├── game-ui-startup-analysis.md                [05-22] → 同上
    ├── shaonv-single-player-ui-data-gap-analysis.md  [05-22] → 被 gap-closure 替代
    ├── core-gameplay-loop-analysis.md             [05-22] → MVP 已实现
    ├── resource-mapping-analysis.md               [05-22] → 被 mainui-data-mapping 替代
    ├── analysis-scope-correction.md               [05-22] → 一次性纠偏
    ├── shaonv-gacha-single-player-p0-analysis.md   [05-22] → 被 gacha-prefab 替代
    └── shaonv-mainui-resource-analysis-2026-05-23.md  [05-23] → 被 data-mapping 替代
```

## 关键数据文件（不在 docs/ 中）

| 数据 | 路径 |
|------|------|
| Prefab 布局 JSON | `reverse-output/godot-layout-inspect/*.layout.json` |
| MonoBehaviour 字段 | `reverse-output/monobehaviour-fields/*.mb-fields.json` |
| 背景 Prefab 布局 | `reverse-output/background-layout-inspect/*.layout.json` |
| IL callgraph | `reverse-output/managed/Assembly-CSharp-ui-callgraph/*.il.txt` |
| 物理资产映射 | `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` |
| 本地化文本 | `reverse-output/assets/story-textassets/Assets/Game/Lang/lang_extra.bytes` |
| Godot MVP 代码 | `standalone/godot-mvp/scripts/` |

---

*索引自动生成于 2026-05-24。新增文档时请更新本文件。*
