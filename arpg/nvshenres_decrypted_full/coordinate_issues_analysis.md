# UI 资源导出与坐标计算问题分析报告

分析时间：2026-05-19
分析对象：tools/ 目录下的 Python 导出工具 + Godot 场景脚本

---

## 涉及文件

### 导出工具（tools/）
- `export_cocos_prefab_layout.py` — 从 Cocos prefab 导出 layout JSON（坐标、sprite、widget 等）
- `build_godot_resource_demo.py` — 构建 Godot 资源索引

### Godot 脚本（nvshenres_decrypted_full/scripts/）
- `cocos_prefab_layer.gd` — 通用 prefab 渲染层（供 login/loading 等场景使用）
- `cocos_prefab_preview.gd` — Cocos Prefab 预览面板（所有布局的预览）
- `original_home_screen.gd` — 主城手工 Demo（大量硬编码坐标）

---

## 问题 1：三套不一致的坐标转换公式（严重程度：高）

### 现状

同一份 `prefab_layouts/*.json` 导出的坐标数据，三个脚本用了三套不同的屏幕坐标转换：

#### A. `cocos_prefab_layer.gd` (line 99-102)

```gdscript
func _cocos_to_screen(position: Vector2, size: Vector2, mode: String) -> Vector2:
    if mode == "bottom_left":
        return Vector2(position.x - size.x * 0.5, DESIGN_SIZE.y - position.y - size.y * 0.5)
    return Vector2(DESIGN_SIZE.x * 0.5 + position.x - size.x * 0.5,
                   DESIGN_SIZE.y * 0.5 - position.y - size.y * 0.5)
```

- 始终假定 anchor = (0.5, 0.5)，忽略导出的 anchor 字段
- two modes: bottom_left（原点在左下）和 center（原点在屏幕中心）

#### B. `cocos_prefab_preview.gd` (line 2003-2010)

```gdscript
func _prefab_node_rect(node: Dictionary) -> Rect2:
    var pos := Vector2(float(pos_arr[0]), -float(pos_arr[1]))
    var anchor := Vector2(float(anchor_arr[0]), 1.0 - float(anchor_arr[1]))
    return Rect2(_canvas_center() + pos - Vector2(size.x * anchor.x, size.y * anchor.y), size)
```

- 原点用 `_canvas_center()`（非固定 DESIGN_SIZE）
- Y 轴直接取反 `-pos_arr[1]`（而非 `DESIGN_SIZE.y - y`）
- anchor Y 分量翻转 `1.0 - anchor_y`
- 使用了导出的 anchor，但与 layer 脚本 anchor 处理完全不同

#### C. `original_home_screen.gd` (line 1022-1026)

```gdscript
func _cocos_to_screen(position: Vector2, size: Vector2) -> Vector2:
    return Vector2(DESIGN_SIZE.x * 0.5 + position.x - size.x * 0.5,
                   DESIGN_SIZE.y * 0.5 - position.y - size.y * 0.5)

func _cocos_center_to_screen(position: Vector2) -> Vector2:
    return Vector2(DESIGN_SIZE.x * 0.5 + position.x,
                   DESIGN_SIZE.y * 0.5 - position.y)
```

- 一套公式用于图片位置（带 size*0.5 偏移），另一套用于中心点
- 右侧 ribbon、底部导航等全部使用硬编码坐标，与导出的 JSON 无关

### 影响

同一个节点在 layer 渲染、prefab 预览、主城 Demo 中位于不同位置，无法交叉验证。

### 修复方案

**统一坐标转换基准：**在导出的 JSON 中直接将坐标归一化到屏幕坐标系，消除 Godot 侧的多套转换：

#### 步骤 1：在 `export_cocos_prefab_layout.py` 的 `export_layout()` 中，导出时完成坐标转换

在 `export_layout()` 末尾（line 176 之前），新增一个坐标标准化步骤：

```python
# 将 Cocos 坐标系转换为统一屏幕坐标系
# Cocos: 原点在左下或屏幕中心，+Y 向上
# 目标: 原点在屏幕左上，+Y 向下（匹配 Godot Canvas）
DESIGN_W = 1280.0
DESIGN_H = 720.0

for node in node_records.values():
    cocos_x = node["global_position"][0]
    cocos_y = node["global_position"][1]
    anchor_x = node["anchor"][0]
    anchor_y = node["anchor"][1]
    w = node["size"][0]
    h = node["size"][1]

    # 判断原点模式：如果存在全屏 root 节点，使用左下原点
    # 否则假定为屏幕中心原点
    origin_mode = _detect_origin_mode(node_records)

    if origin_mode == "bottom_left":
        # 左下原点 -> 左上原点转换
        screen_x = cocos_x - w * anchor_x
        screen_y = DESIGN_H - cocos_y - h * (1.0 - anchor_y)
    else:
        # 中心原点 -> 左上原点转换
        screen_x = DESIGN_W * 0.5 + cocos_x - w * anchor_x
        screen_y = DESIGN_H * 0.5 - cocos_y - h * (1.0 - anchor_y)

    node["screen_position"] = [screen_x, screen_y]
    node["screen_rect"] = [screen_x, screen_y, w, h]
```

#### 步骤 2：统一 Godot 侧为单一渲染函数

所有 Godot 脚本统一使用 `screen_position` 或 `screen_rect`：

```gdscript
func _add_node_rect(node: Dictionary) -> void:
    var rect := node.get("screen_rect", [])
    var pos := Vector2(float(rect[0]), float(rect[1]))
    var size := Vector2(float(rect[2]), float(rect[3]))
    # 直接使用，不需要任何转换
    control.position = pos
    control.size = size
```

#### 步骤 3：统一 origin mode 检测逻辑

```python
def _detect_origin_mode(node_records: dict) -> str:
    """检测 Cocos prefab 使用的坐标原点。
    
    启发式规则：
    - 如果有节点覆盖全屏且位置在屏幕边缘，用 bottom_left
    - 否则默认 center
    """
    for node in node_records.values():
        name = str(node.get("name", ""))
        size = node.get("size", [0, 0])
        pos = node.get("global_position", [0, 0])
        w, h = size[0], size[1]
        x, y = pos[0], pos[1]
        
        # 全屏背景节点 + 位置在角落 = 左下原点模式
        if w >= 1200 and h >= 700:
            if abs(x - w * 0.5) < 5 and abs(y - h * 0.5) < 5:
                return "bottom_left"
    
    return "center"
```

---

## 问题 2：主城硬编码坐标与导出数据割裂（严重程度：高）

### 现状

`original_home_screen.gd` 中右侧 ribbon、事件网格、底部导航等所有 UI 元素位置均为手工硬编码：

```gdscript
{"label": "通行证", "pos": Vector2(429.983, 220.949), ...}
{"label": "仓库",   "pos": Vector2(447.809, 171.94),  ...}
```

### 影响

1. 每次 UI 调整需要人工重新测量所有坐标
2. 容易出现输入错误（如 429.983 是否应该是 429.938?）
3. 与 `prefab_layouts/MainPre.json` 导出的数据不同步
4. 新增功能需要重新手工定位

### 修复方案

**从导出的 JSON 自动提取节点位置：**

```gdscript
# 加载 MainPre.json 的节点索引
var main_pref_nodes: Dictionary = {}

func _ready() -> void:
    _load_main_pref_nodes()
    _build_ui()

func _load_main_pref_nodes() -> void:
    var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/prefab_layouts/MainPre.json"))
    for node in data.get("nodes", []):
        main_pref_nodes[str(node.name)] = node

func _node_screen_pos(name: String) -> Vector2:
    var node = main_pref_nodes.get(name, {})
    var rect = node.get("screen_rect", [0, 0, 0, 0])
    return Vector2(float(rect[0]), float(rect[1]))

func _add_right_ribbons() -> void:
    # 从导出的 JSON 自动获取位置，不再硬编码
    var ribbon_names := [
        "zjm_btn_tongxingzheng",  # 通行证
        "zjm_btn_cangku",         # 仓库
        "zjm_btn_jingji",         # 竞技
        # ...
    ]
    for name in ribbon_names:
        var rect := _node_screen_rect(name)
        _add_ribbon_at(rect)
```

---

## 问题 3：`cocos_prefab_layer.gd` 忽略 anchor 属性（严重程度：中）

### 现状

`_cocos_to_screen()` 始终 `- size * 0.5`，相当于假定所有节点 anchor = (0.5, 0.5)。导出的 anchor 字段完全未使用。

### 影响

对于 anchor ≠ (0.5, 0.5) 的节点（如左对齐的标签、底部对齐的按钮），位置会有偏移。

### 修复方案

已在问题 1 的修复中解决——在导出时使用 anchor 计算 screen_position，Godot 侧直接使用。

---

## 问题 4：global_position 忽略父节点 Scale/Rotation（严重程度：中）

### 现状

`export_cocos_prefab_layout.py` line 255-268：

```python
def global_position(index, node_records, cache):
    x = float(local[0])
    y = float(local[1])
    if parent_index in node_records:
        parent = global_position(parent_index, node_records, cache)
        x += float(parent[0])
        y += float(parent[1])
```

直接简单相加，未考虑父节点的 scale 和 rotation。

### 影响

对于大部分 UI 节点（父节点 scale=1, rotation=0）没有影响。但当父节点有缩放（如 Spine 容器）或旋转时，子节点位置错误。

### 修复方案

如果需要精确处理，改为矩阵累积：

```python
def global_position(index, node_records, cache):
    if index in cache:
        return cache[index]
    node = node_records[index]
    local_x = float(node.get("position", [0, 0])[0])
    local_y = float(node.get("position", [0, 0])[1])
    scale_x = float(node.get("scale", [1, 1])[0])
    scale_y = float(node.get("scale", [1, 1])[1])
    rotation = float(node.get("rotation_z", 0))
    parent_index = node.get("parent_index")
    
    if isinstance(parent_index, int) and parent_index in node_records and parent_index != index:
        parent_x, parent_y = global_position(parent_index, node_records, cache)
        # 父节点旋转和缩放（简化：只处理 2D）
        import math
        cos_r = math.cos(math.radians(rotation))
        sin_r = math.sin(math.radians(rotation))
        fx = local_x * cos_r - local_y * sin_r
        fy = local_x * sin_r + local_y * cos_r
        cache[index] = [parent_x + fx * scale_x, parent_y + fy * scale_y]
    else:
        cache[index] = [local_x, local_y]
    return cache[index]
```

---

## 问题 5：Widget Layout 迭代无收敛保证（严重程度：低）

### 现状

```python
def apply_widget_layout(node_records):
    for _ in range(3):  # 固定 3 轮
```

### 影响

深层嵌套 widget（>3 层级联依赖）可能未收敛。

### 修复方案

改为收敛检测：

```python
def apply_widget_layout(node_records):
    for iteration in range(10):  # 安全上限
        changed = False
        for node in node_records.values():
            widget = node.get("widget") or {}
            if not widget:
                continue
            old_size = list(node.get("size", [0, 0]))
            old_pos = list(node.get("position", [0, 0]))
            parent = node_records.get(node.get("parent_index"))
            if parent:
                apply_widget_to_node(node, parent, widget)
            if node["size"] != old_size or node["position"] != old_pos:
                changed = True
        if not changed:
            break
```

---

## 问题 6：Origin Mode 检测逻辑脆弱（严重程度：低）

### 现状

```python
def _origin_mode(nodes):
    for node in nodes:
        if name in ["root", "Canvas"] and \
           size.distance_to(DESIGN_SIZE) < 2.0 and \
           pos.distance_to(DESIGN_SIZE * 0.5) < 2.0:
            return "bottom_left"
    return "center"
```

### 影响

- 依赖特定命名 "root" / "Canvas"
- 依赖精确的坐标匹配（容差 2px）
- 如果导出的 global_position 有偏差，误判

### 修复方案

增强为多策略检测（已在问题 1 的 `_detect_origin_mode` 中给出）。

---

## 问题 7：TRS 数组索引需验证（严重程度：低）

### 现状

```python
"position": [float(trs[0]), float(trs[1])],      # tx, ty
"scale": [float(trs[6]), float(trs[7])],          # sx, sy ?
"rotation_z": float(trs[9]),                       # rz ?
```

Cocos TRS 序列化格式为 `[tx, ty, tz, qx, qy, qz, qw, sx, sy, sz]`（10 元素）。
取 `trs[6], trs[7]` 作为 scale，`trs[9]` 作为 rotation_z（即 sz?）。

### 修复方案

添加防御性检查：

```python
def extract_trs(trs_array):
    """从 Cocos TRS 数组提取 2D 变换。
    
    格式: [tx, ty, tz, qx, qy, qz, qw, sx, sy, sz]
    """
    if len(trs_array) < 10:
        return {"position": [0, 0], "scale": [1, 1], "rotation_z": 0}
    
    # 位置
    tx, ty = float(trs_array[0]), float(trs_array[1])
    
    # 四元数转欧拉角 (Z)
    qx, qy, qz, qw = [float(trs_array[i]) for i in range(3, 7)]
    rotation_z = quat_to_euler_z(qx, qy, qz, qw)
    
    # 缩放
    sx, sy = float(trs_array[7]), float(trs_array[8])
    
    return {
        "position": [tx, ty],
        "scale": [sx, sy],
        "rotation_z": rotation_z,
    }
```

---

## 实施优先级建议

| 优先级 | 问题 | 预计工作量 | 风险 |
|--------|------|-----------|------|
| P0 | 统一坐标转换公式 | 2-3h | 需要重跑所有导出，验证所有界面 |
| P1 | 主城硬编码改为 JSON 驱动 | 3-4h | 需要精确匹配节点名称 |
| P2 | 导出时考虑 anchor | 含在 P0 | - |
| P3 | global_position 矩阵累积 | 1h | 现有数据需验证 |
| P4 | widget 迭代收敛 | 0.5h | 低 |
| P5 | origin mode 增强 | 0.5h | 低 |
| P6 | TRS 索引验证 | 0.5h | 需确认 Cocos 实际序列化格式 |

建议 **先做 P0+P2**（统一坐标），因为它会影响所有其他修复的验证基准。