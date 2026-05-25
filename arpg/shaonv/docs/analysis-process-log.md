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
| 05-24 | 启动链背景映射修正、LoadingView 修复、20 额外 prefab 采样、sprite 绑定修正、节点审计、MainUIView 全量控件与资源清单、Prefab 全量清单脚本化 |
| 05-25 | 按 MainUIView 全量清单修复 Godot Home，记录 RectTransform 原始清单到 Godot 屏幕坐标的偏差原因 |

## 核心决策

- MVP 使用 Godot 4.6.2 (非 Unity)，因授权和发行成本
- Spine 使用 baked JSON 方案 (非 GDExtension)，因 API 兼容性问题
- 视图栈使用 CanvasLayer 架构，映射 Unity UIRoot2d 5 层体系
- 布局使用 layout.json 锚点换算 (1670→1280)，不凭感觉放

## 修正经验

- PowerShell 读取 UTF-8 文档时显式设置 `[Console]::OutputEncoding`，并用 `Get-Content -Encoding UTF8`，否则中文可能显示成 `?`。
- 生成含中文说明的 Markdown 时，避免把中文说明放进 PowerShell here-string 再交给 Python 写入；优先用 `apply_patch` 写说明文本，或只让脚本写从 UTF-8 JSON 读取出来的原始文本。
- MainUIView 的 `Image.sprite` 解析不能只看 `MainUI.spriteatlas`。需要同时处理 prefab bundle 内置 Sprite、SerializedFile external CAB 依赖、`physical-asset-map.csv` 的物理 bundle 反查。
- `imgBackGround` 在 prefab 中无 sprite 是运行时注入背景的正常结构；主界面截图确认当前使用 `mainui_bg_01.png`。
- 通用导出脚本见 `scripts/assets/export_prefab_full_inventory.py`。已用 `CityView` 和 `ActivityMainView` 验证：`ActivityMainView` 图片全解析，`CityView` 背景已解析但建筑局部图依赖的 `CAB-fe0668bd...` 当前物理集合未定位。
- CAB 名称需要统一成 `CAB-` + 小写 hash；否则 `m_Dependencies` 的 `cab-*` 与 SerializedFile external 的 `CAB-*` 会在回挂 `m_FileID` 时错开。
- 约会主界面由 `GalDormitoryView` 主壳 + `GalDormitoryMainPanel` 主面板构成，`GalDateSelectView` 是 `btnDate` 后续选择界面。部分 Unity UI 组件的 `m_Script` 类名会解析成 `Unknown`，但 typetree 仍有 `m_Sprite/m_Text/m_OnClick` 等稳定字段；脚本已加入字段反推 Image/Text/Button 的修正。
- Godot Gal 主界面按 `现世界面.jpg` 复核后确认：房间背景不是 `gal_img_122`，而是 `gal_bg_room_4`；中间角色应使用 Gal 专用 spine `hero_037r_s01|hero_037r`，当前 `hero_037r_s01` baked 渲染已验证正常。`Head/Round/yhero_*` 圆头像已按 `physical-asset-map.csv` 的 `address` 列全量导出到 Godot，Gal 角色头像链路优先命中 `yhero_*r_s01`。
- 英雄详情主屏 `HeroMainView`、详情信息弹层 `HeroDetailInfoView`、详情页选择格 `HeroMainSelectHeroGrid` 已全量导出。`HeroListView` 在 manifest 中存在，但当前 `files/yoo` 物理集合缺 `6ee0abcfd37a8ba5a54acfc9003167ca.bundle`，只能先导出可用的 `HeroListTabGrid` / `HeroListOrdinationTabGrid` 并记录缺口。
- 复核完整 APK 后确认：`base.apk`、`split_config.arm64_v8a.apk`、`split_install_time_asset_pack.apk` 均不包含 `HeroListView` 的目标 hash / bundle name；`split_install_time_asset_pack.apk` 的 `assets/yoo/Default` 与当前 resources 集合一致。后续补齐应转向已安装客户端缓存、热更 manifest 或网络下载源。
- MainUIView 全量清单给的是 Unity `RectTransform` 原始值，不是 Godot 可直接使用的屏幕左上角坐标。修 Godot Home 时必须同时处理父容器、锚点、pivot、Y 轴方向、非等比画布缩放、LayoutGroup/ContentSizeFitter 运行时排布和运行时数据注入。详细经验见 `shaonv-mainui-godot-home-fix-experience-2026-05-25.md`。

## 已删除/归档的原始文档

- `game-ui-analysis-process.md` → 合并于此
- `shaonv-analysis-process.md` → 合并于此
- `shaonv-gacha-p0-analysis-process.md` → 合并于此
- `analysis-scope-correction.md` → 归档 (一次性纠偏)
