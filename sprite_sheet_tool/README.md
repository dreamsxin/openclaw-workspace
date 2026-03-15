# sprite_sheet_tool

> 将标准 Sprite Sheet 图片一键生成自包含 HTML 动画演示页面。

---

## 功能特性

- **零配置检测**：自动分析透明间隙，推算每行帧数，所有列等宽均分裁切
- **4 行标准布局**：默认适配「向下 / 向左 / 向右 / 向上」四方向动画行
- **自包含 HTML**：所有帧数据以 base64 内嵌，单文件可直接用浏览器打开，无需服务器
- **批量处理**：支持单张图、多张图、整个目录，一次生成一个演示页
- **可调帧率**：页面内实时拖动速度滑块，随时调整播放节奏
- **完整信息**：展示原始 Sprite Sheet 预览、每帧缩略图、列数、尺寸等元数据

---

## 目录结构

```
sprite_sheet_tool/          ← 核心库
│  __init__.py
│  analyzer.py              ← Sprite Sheet 分析（帧检测、行分割）
│  builder.py               ← HTML 页面生成
│
sprite_preview.py           ← 命令行入口（CLI）
README.md
```

---

## 环境要求

| 依赖     | 版本    |
|----------|---------|
| Python   | ≥ 3.9   |
| Pillow   | ≥ 9.0   |
| numpy    | ≥ 1.21  |

一键安装：

```bash
pip install Pillow numpy
```

---

## 快速开始

### 处理单张图片

```bash
python sprite_preview.py hero.png
# 输出: hero_sprite_preview.html（同目录）
```

### 处理整个目录（最常用）

```bash
python sprite_preview.py assets/characters/
# 输出: assets/characters/sprite_preview.html
```

### 指定输出路径

```bash
python sprite_preview.py assets/characters/ -o docs/demo.html
```

### 同时处理多张图片

```bash
python sprite_preview.py hero.png enemy.png boss.png -o demo.html
```

---

## 完整参数说明

```
python sprite_preview.py [图片/目录 ...] [选项]
```

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `图片/目录` | — | 一个或多个图片路径 / 含图片的目录，支持 PNG、JPG、BMP、GIF、WebP |
| `-o OUTPUT` | 同输入目录下 `sprite_preview.html` | 输出 HTML 文件路径 |
| `--rows N` | `4` | 每张图的动画行数 |
| `--labels LABELS` | `向下,向左,向右,向上` | 各行名称，英文逗号分隔，数量须与 `--rows` 一致 |
| `--fps FPS` | `8` | 默认播放帧率（帧/秒），可在页面内实时调整 |
| `--title TITLE` | `Sprite Sheet 动画演示` | HTML 页面标题 |
| `--max-sheet-width PX` | `1200` | 原图缩略图最大宽度（px），值越小 HTML 文件越小） |
| `-v / --verbose` | 关 | 输出详细检测信息（列数、行分割坐标等） |

---

## 使用示例

### 自定义行数与标签（如 8 方向角色）

```bash
python sprite_preview.py sheet.png --rows 8 --labels "下,左下,左,左上,上,右上,右,右下"
```

### 提高帧率 + 详细模式

```bash
python sprite_preview.py sheet.png --fps 12 -v
```

### 控制输出文件大小

默认 `--max-sheet-width 1200` 已将原图缩略以控制体积。
若图片数量多、帧数大，可进一步缩小：

```bash
python sprite_preview.py assets/ --max-sheet-width 800
```

---

## Sprite Sheet 格式约定

本工具适配如下标准布局：

```
┌──────┬──────┬──────┬─ ─ ─ ┬──────┐
│  F0  │  F1  │  F2  │      │  Fn  │  ← 行 0（向下）
├──────┼──────┼──────┼─ ─ ─ ┼──────┤
│  F0  │  F1  │  F2  │      │  Fn  │  ← 行 1（向左）
├──────┼──────┼──────┼─ ─ ─ ┼──────┤
│  F0  │  F1  │  F2  │      │  Fn  │  ← 行 2（向右）
├──────┼──────┼──────┼─ ─ ─ ┼──────┤
│  F0  │  F1  │  F2  │      │  Fn  │  ← 行 3（向上）
└──────┴──────┴──────┴─ ─ ─ ┴──────┘
  每列等宽，透明背景（RGBA PNG 效果最佳）
```

**关键约束：**
- 同一张图内，**所有列等宽**（工具基于此假设做等分裁切）
- 行与行之间有透明像素行间隔（用于自动检测行边界）
- 建议使用 RGBA 模式的 PNG 图片（含透明通道）

---

## 作为 Python 库调用

除 CLI 外，也可在代码中直接调用：

```python
from sprite_sheet_tool import analyze_sprite, build_html

# 分析单张图
info = analyze_sprite("hero.png", num_rows=4, verbose=True)
print(f"检测到 {info.num_cols} 列，共 {sum(len(r.frames) for r in info.rows)} 帧")

# 访问具体帧（PIL Image 对象）
first_frame = info.rows[0].frames[0].img
first_frame.save("frame_0.png")

# 批量生成 HTML
sheets = [analyze_sprite(p) for p in ["hero.png", "enemy.png"]]
build_html(sheets, output_path="demo.html", default_fps=10)
```

### `analyze_sprite()` 返回值

| 属性 | 类型 | 说明 |
|------|------|------|
| `path` | `str` | 源文件路径 |
| `name` | `str` | 文件名 |
| `width / height` | `int` | 图片尺寸 |
| `num_cols` | `int` | 检测到的列数（即每行帧数） |
| `rows` | `List[RowData]` | 各行数据 |
| `rows[i].frames` | `List[FrameData]` | 该行所有帧 |
| `rows[i].frames[j].img` | `PIL.Image` | 第 j 帧图像 |

---

## 页面操作说明

生成的 HTML 页面功能：

| 区域 | 功能 |
|------|------|
| 左侧边栏 | 按角色名分组列表，点击切换；显示第一帧缩略图 |
| 速度滑块 | 实时调整帧间隔（50ms～1000ms），即 1～20 fps |
| 4 个动画窗口 | 每行独立循环播放，自动缩放至合适大小 |
| Sprite Sheet 预览 | 显示原始整张图 |
| 帧详情 | 按行 Tab 切换，展示每帧独立图像及编号 |

---

## 常见问题

**Q: 帧数检测不准确怎么办？**

用 `-v` 参数查看检测细节：
```bash
python sprite_preview.py sheet.png -v
```
若仍不准，检查图片是否符合「等宽列、透明间隙」约定，
或检查图片边缘是否有额外像素。

**Q: 输出 HTML 文件很大？**

减小 `--max-sheet-width` 或降低图片分辨率。
帧数多（如 90+ 帧）的大图建议 `--max-sheet-width 600`。

**Q: 非 4 行的 Sprite Sheet 怎么处理？**

使用 `--rows` 指定正确行数：
```bash
python sprite_preview.py sheet.png --rows 2 --labels "行走,攻击"
```
