# docs/ 对 reverse-output/ 引用覆盖审计

审计时间：2026-05-25。

## 概况

| 指标 | 数值 |
|---|---|
| docs/ 总文档数 | 58 |
| 引用 reverse-output 的文档 | 17 (29%) |
| 被引用的 reverse-output 子目录 | ~30 |
| 未被引用的 reverse-output 子目录 | ~15 |

## 引用覆盖良好的目录

| reverse-output 目录 | 引用文档数 | 主要文档 |
|---|---|---|
| `godot-layout-inspect/` | 8+ | MainUI/Layout/Startup 分析 |
| `monobehaviour-fields/` | 8+ | 全量清单、gap-analysis |
| `il2cpp/` / `il2cpp/il2cppdumper/` | 5+ | table-data-analysis, analysis-scope-correction |
| `assets/story-textassets-raw/` | 2 | localization-text-lookup-experience |
| `story-texts/` | 2 | localization-full-mapping |
| `godot-resource-export/` | 3+ | background-layout, startup analysis |
| `managed/` | 2 | mvp-start, single-player implementation |
| `gacha-static/` | 3+ | gacha-prefab-layout, gacha-single-player |
| `background-layout-inspect/` | 2 | startup-background-layout-reanalysis |
| `yoo-default-xor16-prefix222/` | 2 | yooasset-manifest-analysis |

## 引用不足或缺失的目录

| reverse-output 目录 | 状态 | 建议 |
|---|---|---|
| `assets/manifest/` (12 files) | 🔴 未引用 | 已有 `shaonv-yooasset-manifest-analysis.md` 覆盖 manifest-parsed，可标注原始数据来源 |
| `assets/yoo-physical-map/` (4 files) | 🔴 未引用 | `physical-asset-map.csv` 被脚本引用但文档未提及 |
| `assets/assetstudio-decoded-json/` | 🟡 中间产物 | AssetStudio 解码中间文件，可由脚本生成 |
| `assets/unitypy-*-test/` | 🟡 试验数据 | 开发期试验，无需文档 |
| `assets/unpack-samples-export/` | 🟡 试验数据 | 同上 |
| `assets/unpack-analysis/` | 🟡 试验数据 | 同上 |
| `gacha-analysis/` (1 files) | 🟡 未引用 | 卡池分析中间产物 |
| `managed/il/` | 🟡 中间产物 | IL 反编译输出，dumped cs 已在 dump.cs 引用 |
| `managed/Assembly-CSharp-*-callgraph/` | 🟡 辅助数据 | UI 生命周期分析 `shaonv-hotfix-ui-lifecycle-analysis.md` 可能引用 |
| `scripts/` | ⚪ 工具目录 | 非分析产物 |

## 结论

1. **核心提取资源已充分覆盖**: `godot-layout-inspect/`, `monobehaviour-fields/`, `godot-resource-export/`, `story-texts/` 等关键产出目录均有对应文档说明
2. **语言包提取刚刚补全**: `lang.bytes`/`lang_extra.bytes` 的解析和映射文档在本次 audit 中生成
3. **15 个未引用目录中 12 个为试验/中间产物**: AssetStudio 中间解码、unitypy 测试、解包试验等，不是正式分析产出，可归档清理
4. **需要补充引用的**: `assets/manifest/` 可改链接到 `manifest-parsed/`; `assets/yoo-physical-map/` 可在 yoasset 文档中标注物理文件映射关系
5. **docs 引用的 reverse-output 路径使用了多种格式**: `reverse-output/`, `reverse-output\`, `../reverse-output/` — 建议统一为 `reverse-output/`
