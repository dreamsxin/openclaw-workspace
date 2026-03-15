"""
Sprite Sheet 动画演示生成器
- 标准4行sprite sheet，每行代表不同站位方向
- 根据透明列检测每行的帧数（可变列数）
- 生成单个HTML展示所有角色的动画演示
"""
from PIL import Image
import numpy as np
import os
import base64
import json
from io import BytesIO

CHAR_DIR = 'D:/work/workbuddy/arpg/assets/character'
OUTPUT_HTML = 'c:/Users/Administrator/WorkBuddy/20260315090340/character_animations.html'

NUM_ROWS = 4
ROW_LABELS = ['向下', '向左', '向右', '向上']

def image_to_base64(img: Image.Image, fmt='PNG') -> str:
    buf = BytesIO()
    img.save(buf, format=fmt)
    return base64.b64encode(buf.getvalue()).decode('utf-8')

def group_consecutive(indices):
    if len(indices) == 0:
        return []
    groups = []
    start = int(indices[0]); prev = int(indices[0])
    for v in indices[1:]:
        v = int(v)
        if v == prev + 1:
            prev = v
        else:
            groups.append((start, prev))
            start = v; prev = v
    groups.append((start, prev))
    return groups

def detect_num_cols(content_mask_full, width, height, gap_threshold=2, min_gap_width=1):
    """
    用全图列密度检测帧数（列数）。
    策略：
    1. 用列密度找透明列间隔，取中心坐标
    2. 过滤掉噪声假分割（间距小于中位数40%的）
    3. 用过滤后的有效间隔数+1得到列数，再用 round(width/median_gap) 验证
    4. 若估算帧宽过小（<图宽/60），提升阈值重试，去除噪声
    """
    def _detect(mask, thresh, min_gap_w):
        col_density = mask.sum(axis=0).astype(float)
        low_cols = np.where(col_density <= thresh)[0]
        v_gaps = group_consecutive(low_cols)
        v_gaps_mid = [(s, e) for (s, e) in v_gaps
                      if s > 2 and e < width - 3 and (e - s + 1) >= min_gap_w]
        return v_gaps_mid

    for threshold in [2, 5, 10, 20]:
        v_gaps_mid = _detect(content_mask_full, threshold, min_gap_width)
        if len(v_gaps_mid) == 0:
            continue

        centers = sorted((s + e) // 2 for (s, e) in v_gaps_mid)
        gaps_between = [centers[i+1] - centers[i] for i in range(len(centers)-1)]

        if len(gaps_between) == 0:
            est_frame_w = centers[0]  # only one gap => 2 cols
        else:
            gaps_arr = np.array(gaps_between)
            median_gap = float(np.median(gaps_arr))
            # 过滤明显偏小的假分割
            valid_gaps = gaps_arr[gaps_arr >= median_gap * 0.4]
            if len(valid_gaps) == 0:
                valid_gaps = gaps_arr
            est_frame_w = float(np.median(valid_gaps))

        # 若估算帧宽太小（小于图宽/60），说明还有太多噪声，提升阈值重试
        if est_frame_w < width / 60:
            continue

        num_cols = max(1, round(width / est_frame_w))

        # 微调：尝试 ±1
        best = num_cols
        best_err = abs(width / num_cols - est_frame_w)
        for candidate in [num_cols - 1, num_cols + 1]:
            if candidate > 0:
                err = abs(width / candidate - est_frame_w)
                if err < best_err:
                    best_err = err
                    best = candidate

        return best, v_gaps_mid

    # 完全兜底：1列
    return 1, []

def detect_row_bands(img_arr, alpha, height, num_rows=4):
    """
    检测水平行分割，把sprite sheet分成num_rows行。
    通过寻找透明行区间来确定分割点。
    """
    row_density = (alpha > 10).sum(axis=1).astype(float)
    # 找透明行（密度为0）
    transparent_rows = np.where(row_density <= 2)[0]
    h_gaps = group_consecutive(transparent_rows)
    # 内部间隔（排除顶底边缘）
    h_gaps_mid = [(s, e) for (s, e) in h_gaps if s > 2 and e < height - 3]
    
    # 期望找到 num_rows-1 个分割
    if len(h_gaps_mid) >= num_rows - 1:
        # 按位置排序，取前num_rows-1个间隔的中心作为分割点
        split_ys = sorted((s + e) // 2 for (s, e) in h_gaps_mid[:num_rows - 1])
        # 构建行范围
        row_ranges = []
        prev_y = 0
        for sy in split_ys:
            row_ranges.append((prev_y, sy))
            prev_y = sy + 1
        row_ranges.append((prev_y, height - 1))
        return row_ranges
    else:
        # 回退：平均分割
        row_h = height // num_rows
        return [(i * row_h, (i + 1) * row_h - 1) for i in range(num_rows)]

def extract_frames_from_row(img, ry0, ry1, width, num_cols):
    """
    按等宽均分从一行中提取所有帧。
    frame_w = width / num_cols，严格等分，不依赖透明间隙。
    """
    if num_cols <= 0:
        return []

    frame_w = width / num_cols
    frame_h = ry1 - ry0 + 1

    frames = []
    for col_idx in range(num_cols):
        cx0 = round(col_idx * frame_w)
        cx1 = round((col_idx + 1) * frame_w)
        cell_w = cx1 - cx0
        cropped = img.crop((cx0, ry0, cx1, ry1 + 1))
        frames.append({
            'col': col_idx,
            'x': cx0, 'y': ry0,
            'w': cell_w, 'h': frame_h,
            'img': cropped
        })

    return frames

def analyze_sprite(img_path):
    """分析sprite sheet，提取各行各帧"""
    img = Image.open(img_path).convert('RGBA')
    width, height = img.size
    arr = np.array(img)
    alpha = arr[:, :, 3]
    content_mask = (alpha > 10).astype(np.uint8)
    
    print(f'  Image: {width}x{height}')

    # 1. 全图检测列数（帧数），所有行共享同一列数
    num_cols, v_gaps = detect_num_cols(content_mask, width, height)
    print(f'  Detected cols: {num_cols}  (gaps: {len(v_gaps)})')

    # 2. 检测水平行分割
    row_ranges = detect_row_bands(arr, alpha, height, NUM_ROWS)
    print(f'  Row ranges: {row_ranges}')

    rows_data = []
    for row_idx, (ry0, ry1) in enumerate(row_ranges):
        # 3. 等宽均分提取帧
        frames = extract_frames_from_row(img, ry0, ry1, width, num_cols)
        print(f'  Row {row_idx} ({ROW_LABELS[row_idx]}): {len(frames)} frames  frame_w={width/num_cols:.1f}')
        rows_data.append({
            'row_idx': row_idx,
            'label': ROW_LABELS[row_idx],
            'ry0': ry0,
            'ry1': ry1,
            'frames': frames
        })
    
    return {
        'path': img_path,
        'name': os.path.basename(img_path),
        'width': width,
        'height': height,
        'rows': rows_data
    }

def encode_frames(rows_data):
    """将帧图像编码为base64"""
    result = []
    for row in rows_data:
        encoded_frames = []
        for f in row['frames']:
            b64 = image_to_base64(f['img'])
            encoded_frames.append({
                'col': f['col'],
                'w': f['w'],
                'h': f['h'],
                'data': b64
            })
        result.append({
            'row_idx': row['row_idx'],
            'label': row['label'],
            'frames': encoded_frames
        })
    return result

def get_char_group(name):
    """根据文件名提取角色组名"""
    # 去掉 _01, _02 等后缀
    base = os.path.splitext(name)[0]
    parts = base.rsplit('_', 1)
    if len(parts) == 2 and parts[1].isdigit():
        return parts[0]
    return base

def main():
    png_files = sorted([f for f in os.listdir(CHAR_DIR) if f.lower().endswith('.png')])
    print(f'Found {len(png_files)} PNG files')
    
    all_chars = []
    for fname in png_files:
        fpath = os.path.join(CHAR_DIR, fname)
        print(f'\nAnalyzing: {fname}')
        try:
            sprite_data = analyze_sprite(fpath)
            encoded = encode_frames(sprite_data['rows'])
            sprite_data['encoded_rows'] = encoded
            # 移除PIL Image对象（不能序列化）
            for row in sprite_data['rows']:
                del row['frames']
            all_chars.append(sprite_data)
        except Exception as e:
            print(f'  ERROR: {e}')
            import traceback
            traceback.print_exc()
    
    print(f'\nTotal characters processed: {len(all_chars)}')
    
    # 按角色组分组
    groups = {}
    for char in all_chars:
        grp = get_char_group(char['name'])
        if grp not in groups:
            groups[grp] = []
        groups[grp].append(char)
    
    # 生成HTML
    html = generate_html(all_chars, groups)
    with open(OUTPUT_HTML, 'w', encoding='utf-8') as f:
        f.write(html)
    print(f'\nHTML saved to: {OUTPUT_HTML}')

def generate_html(all_chars, groups):
    # 序列化帧数据为JSON
    chars_json = []
    for char in all_chars:
        # 嵌入原始sprite sheet（缩略）
        src_img = Image.open(char['path'])
        # 限制最大宽度1200px以控制文件大小
        max_w = 1200
        if src_img.width > max_w:
            ratio = max_w / src_img.width
            src_img = src_img.resize((max_w, int(src_img.height * ratio)), Image.NEAREST)
        sheet_b64 = image_to_base64(src_img)
        
        char_entry = {
            'name': char['name'],
            'group': get_char_group(char['name']),
            'width': char['width'],
            'height': char['height'],
            'sheet': sheet_b64,
            'rows': char['encoded_rows']
        }
        chars_json.append(char_entry)
    
    chars_data = json.dumps(chars_json, ensure_ascii=False)
    
    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>角色 Sprite 动画演示</title>
<style>
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
body {{ background: #0d1117; color: #c9d1d9; font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif; padding: 0; }}

/* Header */
.header {{ background: linear-gradient(135deg, #161b22, #21262d); padding: 20px 30px; border-bottom: 1px solid #30363d; position: sticky; top: 0; z-index: 100; }}
.header h1 {{ color: #58a6ff; font-size: 1.4em; font-weight: 600; }}
.header .subtitle {{ color: #8b949e; font-size: 0.85em; margin-top: 4px; }}

/* Layout */
.container {{ display: flex; height: calc(100vh - 73px); }}

/* Sidebar - character list */
.sidebar {{ width: 220px; min-width: 220px; background: #161b22; border-right: 1px solid #30363d; overflow-y: auto; padding: 10px 0; }}
.sidebar-group {{ margin-bottom: 4px; }}
.sidebar-group-title {{ padding: 6px 14px; font-size: 0.72em; color: #8b949e; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; }}
.sidebar-item {{ padding: 7px 14px; cursor: pointer; font-size: 0.82em; border-left: 3px solid transparent; transition: all 0.15s; color: #c9d1d9; display: flex; align-items: center; gap: 8px; }}
.sidebar-item:hover {{ background: #21262d; color: #58a6ff; }}
.sidebar-item.active {{ background: #1f3555; border-left-color: #58a6ff; color: #58a6ff; }}
.sidebar-item .idx {{ color: #6e7681; font-size: 0.75em; min-width: 20px; }}
.sidebar-thumb {{ width: 32px; height: 32px; background: repeating-conic-gradient(#1a1f27 0% 25%, #0d1117 0% 50%) 0 0/8px 8px; border-radius: 4px; overflow: hidden; display: flex; align-items: center; justify-content: center; }}
.sidebar-thumb img {{ max-width: 32px; max-height: 32px; image-rendering: pixelated; }}

/* Main content */
.main {{ flex: 1; overflow-y: auto; padding: 24px; }}

/* Character card */
.char-card {{ display: none; }}
.char-card.visible {{ display: block; }}
.char-title {{ font-size: 1.3em; font-weight: 600; color: #e6edf3; margin-bottom: 6px; }}
.char-meta {{ color: #8b949e; font-size: 0.82em; margin-bottom: 20px; }}
.char-meta span {{ margin-right: 16px; }}

/* Row animations grid */
.rows-grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; margin-bottom: 24px; }}
.row-card {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; padding: 16px; }}
.row-card-title {{ font-size: 0.85em; color: #8b949e; margin-bottom: 10px; display: flex; align-items: center; gap: 8px; }}
.row-card-title .dot {{ width: 8px; height: 8px; border-radius: 50%; }}
.row-canvas-wrap {{ display: flex; justify-content: center; background: repeating-conic-gradient(#1e2330 0% 25%, #161b22 0% 50%) 0 0/16px 16px; border-radius: 6px; min-height: 80px; align-items: center; overflow: hidden; }}
.row-canvas-wrap canvas {{ image-rendering: pixelated; }}
.row-info {{ margin-top: 8px; font-size: 0.72em; color: #6e7681; display: flex; justify-content: space-between; }}

/* Sprite sheet preview */
.sheet-section {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; padding: 16px; margin-bottom: 16px; }}
.sheet-section h3 {{ font-size: 0.9em; color: #8b949e; margin-bottom: 10px; }}
.sheet-wrap {{ overflow: auto; background: repeating-conic-gradient(#1e2330 0% 25%, #161b22 0% 50%) 0 0/16px 16px; border-radius: 6px; padding: 8px; text-align: center; }}
.sheet-wrap img {{ image-rendering: pixelated; max-width: 100%; }}

/* Controls */
.controls {{ display: flex; gap: 10px; align-items: center; margin-bottom: 20px; flex-wrap: wrap; }}
.speed-control {{ display: flex; align-items: center; gap: 8px; font-size: 0.82em; color: #8b949e; }}
.speed-control input {{ width: 100px; accent-color: #58a6ff; }}
.speed-val {{ color: #58a6ff; min-width: 40px; }}
.btn {{ background: #21262d; color: #c9d1d9; border: 1px solid #30363d; border-radius: 6px; padding: 6px 14px; cursor: pointer; font-size: 0.82em; transition: all 0.15s; }}
.btn:hover {{ background: #30363d; color: #e6edf3; }}
.btn.primary {{ background: #1f6feb; border-color: #1f6feb; color: white; }}
.btn.primary:hover {{ background: #388bfd; }}

/* Frame strip */
.frames-section {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; padding: 16px; }}
.frames-section h3 {{ font-size: 0.9em; color: #8b949e; margin-bottom: 12px; }}
.row-tabs {{ display: flex; gap: 6px; margin-bottom: 12px; flex-wrap: wrap; }}
.row-tab {{ padding: 5px 12px; border-radius: 20px; font-size: 0.78em; cursor: pointer; background: #21262d; border: 1px solid #30363d; color: #8b949e; transition: all 0.15s; }}
.row-tab:hover {{ color: #c9d1d9; }}
.row-tab.active {{ background: #1f3555; border-color: #58a6ff; color: #58a6ff; }}
.frame-strip {{ display: flex; gap: 8px; flex-wrap: wrap; }}
.frame-thumb {{ background: repeating-conic-gradient(#1e2330 0% 25%, #161b22 0% 50%) 0 0/8px 8px; border-radius: 6px; padding: 4px; border: 2px solid #30363d; transition: all 0.15s; cursor: pointer; }}
.frame-thumb:hover {{ border-color: #58a6ff; }}
.frame-thumb img {{ image-rendering: pixelated; display: block; max-width: 60px; max-height: 60px; }}
.frame-num {{ font-size: 0.65em; color: #6e7681; text-align: center; margin-top: 2px; }}

/* Row dot colors */
.dot-0 {{ background: #58a6ff; }}
.dot-1 {{ background: #3fb950; }}
.dot-2 {{ background: #f85149; }}
.dot-3 {{ background: #d29922; }}

/* Scrollbar */
::-webkit-scrollbar {{ width: 6px; height: 6px; }}
::-webkit-scrollbar-track {{ background: #0d1117; }}
::-webkit-scrollbar-thumb {{ background: #30363d; border-radius: 3px; }}
::-webkit-scrollbar-thumb:hover {{ background: #484f58; }}

/* Empty state */
.empty {{ text-align: center; padding: 60px; color: #6e7681; }}
.empty .icon {{ font-size: 3em; margin-bottom: 10px; }}
</style>
</head>
<body>

<div class="header">
  <h1>⚔️ 角色 Sprite 动画演示</h1>
  <div class="subtitle">共 {len(all_chars)} 个 Sprite Sheet · 4行标准布局 · 自动帧检测</div>
</div>

<div class="container">
  <div class="sidebar" id="sidebar"></div>
  <div class="main" id="main">
    <div class="empty"><div class="icon">👈</div><div>从左侧选择角色查看动画</div></div>
  </div>
</div>

<script>
const CHARS = {chars_data};
const ROW_COLORS = ['#58a6ff','#3fb950','#f85149','#d29922'];
const ROW_LABELS = ['向下','向左','向右','向上'];

let currentChar = null;
let animTimers = [];
let currentFrameSpeed = 150; // ms per frame
let selectedRowTab = 0;

// Build sidebar
function buildSidebar() {{
  const sidebar = document.getElementById('sidebar');
  const groups = {{}};
  CHARS.forEach((c, i) => {{
    if (!groups[c.group]) groups[c.group] = [];
    groups[c.group].push({{...c, globalIdx: i}});
  }});
  
  Object.entries(groups).forEach(([grp, chars]) => {{
    const gDiv = document.createElement('div');
    gDiv.className = 'sidebar-group';
    const title = document.createElement('div');
    title.className = 'sidebar-group-title';
    title.textContent = grp;
    gDiv.appendChild(title);
    
    chars.forEach((c, j) => {{
      const item = document.createElement('div');
      item.className = 'sidebar-item';
      item.dataset.idx = c.globalIdx;
      
      // Thumbnail from first frame of first row
      let thumbHtml = '';
      if (c.rows.length > 0 && c.rows[0].frames.length > 0) {{
        thumbHtml = `<div class="sidebar-thumb"><img src="data:image/png;base64,${{c.rows[0].frames[0].data}}" /></div>`;
      }} else {{
        thumbHtml = `<div class="sidebar-thumb"></div>`;
      }}
      
      item.innerHTML = `${{thumbHtml}}<span>${{c.name}}</span>`;
      item.addEventListener('click', () => selectChar(c.globalIdx));
      gDiv.appendChild(item);
    }});
    
    sidebar.appendChild(gDiv);
  }});
}}

function selectChar(idx) {{
  currentChar = CHARS[idx];
  selectedRowTab = 0;
  
  // Update sidebar active
  document.querySelectorAll('.sidebar-item').forEach(el => {{
    el.classList.toggle('active', parseInt(el.dataset.idx) === idx);
  }});
  
  renderCharCard(currentChar);
}}

function renderCharCard(char) {{
  // Stop existing animations
  stopAllAnimations();
  
  const main = document.getElementById('main');
  
  // Calculate total frames
  let totalFrames = 0;
  char.rows.forEach(r => totalFrames += r.frames.length);
  
  const rowCount = char.rows.reduce((s, r) => s + (r.frames.length > 0 ? 1 : 0), 0);
  
  main.innerHTML = `
    <div class="char-card visible" id="charCard">
      <div class="char-title">${{char.name}}</div>
      <div class="char-meta">
        <span>📐 ${{char.width}} × ${{char.height}} px</span>
        <span>🎞️ ${{totalFrames}} 帧</span>
        <span>📋 ${{rowCount}} 行有效动画</span>
      </div>
      
      <div class="controls">
        <div class="speed-control">
          <span>速度:</span>
          <input type="range" id="speedSlider" min="50" max="800" value="${{currentFrameSpeed}}" step="10">
          <span class="speed-val" id="speedVal">${{currentFrameSpeed}}ms</span>
        </div>
        <button class="btn primary" onclick="restartAllAnimations()">▶ 重启动画</button>
        <button class="btn" onclick="stopAllAnimations()">⏹ 停止</button>
      </div>
      
      <div class="rows-grid" id="rowsGrid"></div>
      
      <div class="sheet-section">
        <h3>📄 原始 Sprite Sheet</h3>
        <div class="sheet-wrap">
          <img src="${{getSourceBase64(char)}}" />
        </div>
      </div>
      
      <div class="frames-section">
        <h3>🖼️ 帧详情</h3>
        <div class="row-tabs" id="rowTabs"></div>
        <div class="frame-strip" id="frameStrip"></div>
      </div>
    </div>
  `;
  
  // Speed slider
  const slider = document.getElementById('speedSlider');
  slider.addEventListener('input', e => {{
    currentFrameSpeed = parseInt(e.target.value);
    document.getElementById('speedVal').textContent = currentFrameSpeed + 'ms';
    restartAllAnimations();
  }});
  
  // Build row animation cards
  buildRowCards(char);
  buildFrameTabs(char);
}}

function getSourceBase64(char) {{
  return char.sheet ? 'data:image/png;base64,' + char.sheet : '';
}}

function buildRowCards(char) {{
  const grid = document.getElementById('rowsGrid');
  animTimers = [];
  
  char.rows.forEach((row, ri) => {{
    if (row.frames.length === 0) return;
    
    const card = document.createElement('div');
    card.className = 'row-card';
    
    const fw = row.frames[0].w;
    const fh = row.frames[0].h;
    const scale = Math.min(2, Math.max(1, Math.floor(160 / Math.max(fw, fh))));
    const cw = fw * scale;
    const ch = fh * scale;
    
    card.innerHTML = `
      <div class="row-card-title">
        <div class="dot dot-${{ri}}"></div>
        <span>行 ${{ri}} · ${{row.label}}</span>
        <span style="margin-left:auto;color:#6e7681;font-size:0.85em">${{row.frames.length}} 帧</span>
      </div>
      <div class="row-canvas-wrap">
        <canvas id="canvas_${{ri}}" width="${{cw}}" height="${{ch}}"></canvas>
      </div>
      <div class="row-info">
        <span>帧尺寸: ${{fw}}×${{fh}}</span>
        <span>缩放: ${{scale}}x</span>
      </div>
    `;
    grid.appendChild(card);
    
    // Start animation for this row
    startRowAnimation(row, ri, scale);
  }});
}}

function startRowAnimation(row, ri, scale) {{
  if (row.frames.length === 0) return;
  
  const canvas = document.getElementById('canvas_' + ri);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  
  let frameIdx = ri % row.frames.length; // Offset start for visual variety
  
  const imgs = row.frames.map(f => {{
    const im = new Image();
    im.src = 'data:image/png;base64,' + f.data;
    return im;
  }});
  
  function draw() {{
    const f = row.frames[frameIdx];
    const im = imgs[frameIdx];
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    if (im.complete) {{
      ctx.imageSmoothingEnabled = false;
      ctx.drawImage(im, 0, 0, f.w * scale, f.h * scale);
    }}
    frameIdx = (frameIdx + 1) % row.frames.length;
  }}
  
  // Wait for images to load
  let loaded = 0;
  imgs.forEach(im => {{
    if (im.complete) {{ loaded++; }}
    else {{ im.onload = () => {{ loaded++; }}; }}
  }});
  
  const timer = setInterval(draw, currentFrameSpeed);
  animTimers.push(timer);
  draw();
}}

function stopAllAnimations() {{
  animTimers.forEach(t => clearInterval(t));
  animTimers = [];
}}

function restartAllAnimations() {{
  stopAllAnimations();
  if (!currentChar) return;
  
  const grid = document.getElementById('rowsGrid');
  if (!grid) return;
  
  currentChar.rows.forEach((row, ri) => {{
    if (row.frames.length === 0) return;
    const fw = row.frames[0].w;
    const fh = row.frames[0].h;
    const scale = Math.min(2, Math.max(1, Math.floor(160 / Math.max(fw, fh))));
    startRowAnimation(row, ri, scale);
  }});
}}

function buildFrameTabs(char) {{
  const tabs = document.getElementById('rowTabs');
  char.rows.forEach((row, ri) => {{
    if (row.frames.length === 0) return;
    const tab = document.createElement('div');
    tab.className = 'row-tab' + (ri === selectedRowTab ? ' active' : '');
    tab.textContent = `行${{ri}} ${{row.label}} (${{row.frames.length}}帧)`;
    tab.style.color = ri === selectedRowTab ? ROW_COLORS[ri] : '';
    tab.style.borderColor = ri === selectedRowTab ? ROW_COLORS[ri] : '';
    tab.addEventListener('click', () => {{
      selectedRowTab = ri;
      buildFrameTabs(char);
      renderFrameStrip(char, ri);
    }});
    tabs.appendChild(tab);
  }});
  renderFrameStrip(char, selectedRowTab);
}}

function renderFrameStrip(char, rowIdx) {{
  const strip = document.getElementById('frameStrip');
  strip.innerHTML = '';
  
  const row = char.rows[rowIdx];
  if (!row || row.frames.length === 0) {{
    strip.innerHTML = '<div style="color:#6e7681;font-size:0.82em">此行无帧</div>';
    return;
  }}
  
  row.frames.forEach((f, fi) => {{
    const div = document.createElement('div');
    div.className = 'frame-thumb';
    const img = document.createElement('img');
    img.src = 'data:image/png;base64,' + f.data;
    img.style.maxWidth = '64px';
    img.style.maxHeight = '64px';
    const num = document.createElement('div');
    num.className = 'frame-num';
    num.textContent = '#' + fi;
    div.appendChild(img);
    div.appendChild(num);
    strip.appendChild(div);
  }});
}}

// Init
buildSidebar();

// Auto-select first character
if (CHARS.length > 0) {{
  selectChar(0);
}}
</script>
</body>
</html>'''
    
    return html

if __name__ == '__main__':
    main()
