# Prefab 全量清单分析导出 — 经验总结

生成时间：2026-05-25。

本文档综合 `shaonv-prefab-full-inventory-export-route-2026-05-24.md` 和后续多轮实践，总结从 Unity Prefab 逆向到 Godot 还原的完整工作流。

## 一、工作流全景

```
APK/xml/bundle ─── physical-asset-map.csv ─┐
                                             ├─→ export_prefab_full_inventory.py
manifest-ui-candidates.csv ──────────────────┘
                                                   │
        ┌──────────────────────────────────────────┤
        ▼                    ▼                      ▼
   layout.json         mb-fields.json         *-inventory.md
   (RectTransform)     (Image/Text/Button)    (资源Bundle表)
        │                    │                      │
        └────────────────────┴──────────────────────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
              gap-analysis.md   lang.bytes/extra
              (覆盖率/偏差/缺失)   (语言包文本)
                    │                 │
                    ▼                 ▼
             Godot home_screen.gd   map_text_to_controls.py
```

## 二、导出覆盖统计 (截至 2026-05-25)

| 系统 | Prefab 数 | 已导出 | 缺失 | 覆盖率 |
|---|---:|---:|---:|---:|
| MainUI | 1 | 1 (212n) | 0 | 100% |
| Hero | 6 | 5 | 1 (HeroListView) | 83% |
| Gal | 48 | 37 | 11 | 77% |
| Login/Startup | 3 | 3 | 0 | 100% |
| LotteryDraw | 2 | 2 | 0 | 100% |
| CityView | 1 | 1 | 0 | 100% |
| ActivityMainView | 1 | 1 | 0 | 100% |
| BagView | 1 | 0 | 1 | 0% |
| **合计** | **63** | **50** | **13** | **79%** |

> 缺失 bundle 来源单一：install-time APK 不包含全部 `play asset delivery` 资源包，需热更新或 runtime cache 补。

## 三、关键工具链

### 3.1 导出脚本

| 脚本 | 路径 | 功能 |
|---|---|---|
| `export_prefab_full_inventory.py` | `scripts/assets/` | 主导出脚本：RectTransform + MonoBehaviour → 3 文件 |
| `extract_prefab_monobehaviour_fields.py` | `scripts/assets/` | 单独提取 Image/Text/Button 绑定 |
| `inspect_unity_prefab_layout.py` | `scripts/assets/` | 单独提取 RectTransform 层级 |
| `export_unity_bundle_images.py` | `scripts/assets/` | 从 CAB bundle 提取 Sprite → PNG |
| `parse_lang_bytes.py` | `tools/` | 解析 lang.bytes / lang_extra.bytes 语言包 |
| `categorize_lang_keys.py` | `tools/` | UI 键按数字范围分类 (17 类别) |
| `map_text_to_controls.py` | `tools/` | mb-fields Text ↔ lang key 交叉映射 |

### 3.2 使用模式

```powershell
# 单视图导出
python scripts/assets/export_prefab_full_inventory.py GalLevelView --repo-root .

# 批量导出 (逐个调用)
for view in GalLevelView GalMapView GalSpecialTouchView; do
    python scripts/assets/export_prefab_full_inventory.py $view --repo-root .
done

# 语言包解析
python tools/parse_lang_bytes.py
python tools/categorize_lang_keys.py

# 文本映射
python tools/map_text_to_controls.py MainUIView
```

## 四、常见陷阱与解决

### 4.1 bundle 缺失

**现象**: `Prefab not found in physical map`

**解决**:
1. 先确认 manifest 中有该 address
2. 再查 `physical-asset-map.csv` 中 `physicalExists` 列
3. 若 `physicalExists=False`，检查是否需补 APK 分割包或热更新 manifest

```bash
grep "TargetView" reverse-output/assets/yoo-physical-map/physical-asset-map.csv
```

### 4.2 CAB 大小写不一致

`m_Dependencies` 中写 `cab-xxxx`，而 SerializedFile external 是 `CAB-XXXX`。脚本需 normalize 为 `CAB-` + 小写 hash。

### 4.3 Unknown 组件误判

当 m_Script 类名解析为 Unknown 时，不应跳过。检查 typetree 稳定字段：

```
m_Sprite + m_RaycastTarget + m_Type  → Image
m_Text   + m_FontData                → Text
m_Interactable + m_OnClick           → Button
```

### 4.4 Image:none 误判为资源缺失

`Image.sprite = {fileID: 0, pathID: 0}` + `color.a = 0` + `raycastTarget = 1` = 透明点击热区，非资源缺失。

### 4.5 LayoutGroup 子节点 pos(0,0)

所有 `HorizontalLayoutGroup` / `GridLayoutGroup` / `ContentSizeFitter` 下的子节点 RectTransform 都是 `pos(0,0)`。Godot 复刻时需按布局语义手工展开。

### 4.6 静态 Text ≠ 运行时 Text

Prefab Text 组件的 `text` 字段是开发期占位符（简体中文），运行时通过语言包 `lang.bytes` / `lang_extra.bytes` 覆盖为繁体中文。

```json
// lang_extra.bytes
{"lang": ["UI1000007=遺器", "UI1000001=幻靈", ...]}
// 覆盖 MainUIView 中 btnPet/Text 的静态值 "宠物"
```

## 五、坐标转换公式

```
Unity Prefab: 1668×750, anchor/pivot 定位
       ↓
先算 Unity 左上角: left = parentLeft + anchorX*parentW + posX - pivotX*width
       ↓
再映射 Godot:   godotX = unityLeft * 0.767 (1280/1668)
               godotY = unityTop  * 0.96  (720/750)
```

## 六、文件组织规范

```
docs/
  shaonv-<view>-full-control-resource-inventory-2026-05-24.md  # 自动化产物
  shaonv-<view>-godot-*-analysis-2026-05-25.md                 # 分析文档
  shaonv-localization-*.md                                      # 文本/语言包

reverse-output/
  godot-layout-inspect/<View>.layout.json                       # RectTransform 层级
  monobehaviour-fields/<View>.mb-fields.json                    # Image/Text/Button
  story-texts/lang*_parsed.json                                 # 语言包解析
  story-texts/lang_extra_categorized.json                       # UI 键分类

tools/
  parse_lang_bytes.py, categorize_lang_keys.py, map_text_to_controls.py

scripts/assets/
  export_prefab_full_inventory.py (主脚本, 含 KNOWN_PREFABS 字典)
```

## 七、递进式分析顺序

1. **导出清单** → 批量运行 `export_prefab_full_inventory.py`
2. **间隙分析** → 对照清单与 Godot 代码，生成 gap-analysis
3. **文本映射** → 运行 `map_text_to_controls.py` + `parse_lang_bytes.py`
4. **截图验证** → 对每个界面截图交叉核对位置与文本
5. **修正迭代** → 逐轮 commit，每轮截图验证
6. **审计** → 检查 docs 对 reverse-output 的引用覆盖率

## 八、尚未覆盖的系统

| 系统 | Prefab 数 | 阻塞原因 |
|---|---|---|
| BagView | 1 | 未运行导出（物理 bundle 存在） |
| LotteryDrawFinishView | 1 | 未运行导出 |
| HeroListView | 1 | bundle 缺失 |
| 其他未分类 | ~10+ | 待 manifest 扫描 |
