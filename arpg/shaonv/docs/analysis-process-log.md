# 分析过程日志（合并）

> 合并自 `game-ui-analysis-process.md` + `shaonv-analysis-process.md` + `shaonv-gacha-p0-analysis-process.md`
> 保留关键工具命令、数据路径、决策节点

---

## 数据源

| 数据 | 路径 |
|------|------|
| 物理资产映射 | `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` (15,274 rows) |
| IL callgraph | `reverse-output/managed/Assembly-CSharp-ui-callgraph/*.il.txt` |
| 本地化文本 | `reverse-output/assets/story-textassets/Assets/Game/Lang/lang_extra.bytes` (10,827 UI keys) |
| 故事/表数据 | `reverse-output/story-texts/` (story_lang_keys.json, chapter_resolved.json 等) |

## 关键工具链

```
inspect_unity_prefab_layout.py  → 从 YooAsset bundle 提取 prefab RectTransform 层级 → layout.json
extract_prefab_monobehaviour_fields.py → 提取 Image.sprite / Text.text / Button.onClick → mb-fields.json
export_unity_ui_resources.py    → 从 bundle 批量导出 PNG sprite → assets/ui/
```

## 分析时间线

| 日期 | 里程碑 |
|------|--------|
| 05-22 | 初始任务拆分、YooAsset 解密、IL 反编译验证、Spine 运行时分析 |
| 05-23 | 7 prefab layout 全量提取、IL 生命周期分析、MainUI 数据映射、sprite 绑定提取、MVP 缺口分析、Godot 视图栈实现 |
| 05-24 | 启动链背景映射修正、LoadingView 修复、20 额外 prefab 采样、sprite 绑定修正、节点审计 |

## 核心决策

- MVP 使用 Godot 4.6.2 (非 Unity)，因授权和发行成本
- Spine 使用 baked JSON 方案 (非 GDExtension)，因 API 兼容性问题
- 视图栈使用 CanvasLayer 架构，映射 Unity UIRoot2d 5 层体系
- 布局使用 layout.json 锚点换算 (1670→1280)，不凭感觉放

## 已删除/归档的原始文档

- `game-ui-analysis-process.md` → 合并于此
- `shaonv-analysis-process.md` → 合并于此
- `shaonv-gacha-p0-analysis-process.md` → 合并于此
- `analysis-scope-correction.md` → 归档 (一次性纠偏)
