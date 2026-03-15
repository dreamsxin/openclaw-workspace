"""
builder.py — HTML 演示页面生成器
职责：
  - 接收一个或多个 SpriteSheetInfo，将帧数据嵌入为 base64
  - 渲染自包含的单文件 HTML（无外部依赖）
"""
from __future__ import annotations

import base64
import json
import os
from io import BytesIO
from typing import List, Optional

from PIL import Image

from .analyzer import SpriteSheetInfo


# ── 编码工具 ──────────────────────────────────────────────────────────────────

def _img_to_b64(img: Image.Image) -> str:
    buf = BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _group_name(filename: str) -> str:
    """从 'foxfairy_01.png' 提取组名 'foxfairy'。"""
    base = os.path.splitext(filename)[0]
    parts = base.rsplit("_", 1)
    if len(parts) == 2 and parts[1].isdigit():
        return parts[0]
    return base


# ── 公开接口 ──────────────────────────────────────────────────────────────────

def build_html(
    sheets: List[SpriteSheetInfo],
    output_path: str,
    title: str = "Sprite Sheet 动画演示",
    sheet_preview_max_w: int = 1200,
    default_fps: int = 8,
) -> str:
    """
    将多个 SpriteSheetInfo 渲染成一个自包含 HTML 文件。

    参数
    ----
    sheets              : analyze_sprite() 返回值列表
    output_path         : 输出 HTML 文件路径
    title               : 页面标题
    sheet_preview_max_w : Sprite Sheet 缩略图最大宽度（px），控制文件体积
    default_fps         : 默认播放帧率（帧/秒）

    返回
    ----
    实际写入的文件路径（== output_path）
    """
    chars_json: list = []
    for sheet in sheets:
        # 缩略原图嵌入
        src_img = Image.open(sheet.path)
        if src_img.width > sheet_preview_max_w:
            ratio = sheet_preview_max_w / src_img.width
            src_img = src_img.resize(
                (sheet_preview_max_w, int(src_img.height * ratio)), Image.NEAREST
            )
        sheet_b64 = _img_to_b64(src_img)

        # 编码各行帧
        encoded_rows = []
        for row in sheet.rows:
            encoded_frames = [
                {"col": f.col, "w": f.w, "h": f.h, "data": _img_to_b64(f.img)}
                for f in row.frames
            ]
            encoded_rows.append({
                "row_idx": row.row_idx,
                "label": row.label,
                "frames": encoded_frames,
            })

        chars_json.append({
            "name": sheet.name,
            "group": _group_name(sheet.name),
            "width": sheet.width,
            "height": sheet.height,
            "num_cols": sheet.num_cols,
            "sheet": sheet_b64,
            "rows": encoded_rows,
        })

    chars_data = json.dumps(chars_json, ensure_ascii=False)
    default_interval = max(16, round(1000 / default_fps))

    html = _render_html(title, len(sheets), chars_data, default_interval)
    with open(output_path, "w", encoding="utf-8") as fh:
        fh.write(html)
    return output_path


# ── HTML 模板 ─────────────────────────────────────────────────────────────────

def _render_html(title: str, total: int, chars_data: str, default_interval: int) -> str:
    return f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:#0d1117;color:#c9d1d9;font-family:'Segoe UI','Microsoft YaHei',sans-serif}}
/* ── Header ── */
.hdr{{background:linear-gradient(135deg,#161b22,#21262d);padding:16px 28px;border-bottom:1px solid #30363d;position:sticky;top:0;z-index:100;display:flex;align-items:center;gap:16px}}
.hdr h1{{color:#58a6ff;font-size:1.25em;font-weight:600;flex:1}}
.hdr .meta{{color:#8b949e;font-size:0.8em}}
/* ── Layout ── */
.wrap{{display:flex;height:calc(100vh - 57px)}}
/* ── Sidebar ── */
.sb{{width:210px;min-width:210px;background:#161b22;border-right:1px solid #30363d;overflow-y:auto;padding:8px 0}}
.sb-grp-title{{padding:6px 12px;font-size:.7em;color:#8b949e;text-transform:uppercase;letter-spacing:.05em;font-weight:600}}
.sb-item{{padding:6px 12px;cursor:pointer;font-size:.8em;border-left:3px solid transparent;transition:all .15s;color:#c9d1d9;display:flex;align-items:center;gap:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.sb-item:hover{{background:#21262d;color:#58a6ff}}
.sb-item.active{{background:#1f3555;border-left-color:#58a6ff;color:#58a6ff}}
.sb-thumb{{width:30px;height:30px;flex-shrink:0;background:repeating-conic-gradient(#1a1f27 0% 25%,#0d1117 0% 50%) 0 0/8px 8px;border-radius:3px;overflow:hidden;display:flex;align-items:center;justify-content:center}}
.sb-thumb img{{max-width:30px;max-height:30px;image-rendering:pixelated}}
/* ── Main ── */
.main{{flex:1;overflow-y:auto;padding:22px}}
/* ── Card ── */
.card{{display:none}}.card.on{{display:block}}
.card-title{{font-size:1.2em;font-weight:600;color:#e6edf3;margin-bottom:4px}}
.card-meta{{color:#8b949e;font-size:.8em;margin-bottom:18px}}
.card-meta span{{margin-right:14px}}
/* ── Controls ── */
.ctrl{{display:flex;gap:10px;align-items:center;margin-bottom:18px;flex-wrap:wrap}}
.ctrl label{{font-size:.78em;color:#8b949e}}
.ctrl input[type=range]{{width:110px;accent-color:#58a6ff}}
.speed-val{{color:#58a6ff;font-size:.78em;min-width:52px}}
.btn{{background:#21262d;color:#c9d1d9;border:1px solid #30363d;border-radius:6px;padding:5px 13px;cursor:pointer;font-size:.78em;transition:all .15s}}
.btn:hover{{background:#30363d}}
.btn.pri{{background:#1f6feb;border-color:#1f6feb;color:#fff}}
.btn.pri:hover{{background:#388bfd}}
/* ── Row grid ── */
.rows-grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:14px;margin-bottom:20px}}
.row-card{{background:#161b22;border:1px solid #30363d;border-radius:10px;padding:14px}}
.row-card-hd{{font-size:.82em;color:#8b949e;margin-bottom:8px;display:flex;align-items:center;gap:6px}}
.dot{{width:7px;height:7px;border-radius:50%}}
.dot-0{{background:#58a6ff}}.dot-1{{background:#3fb950}}.dot-2{{background:#f85149}}.dot-3{{background:#d29922}}
.canvas-wrap{{display:flex;justify-content:center;background:repeating-conic-gradient(#1e2330 0% 25%,#161b22 0% 50%) 0 0/14px 14px;border-radius:6px;min-height:70px;align-items:center;overflow:hidden}}
.canvas-wrap canvas{{image-rendering:pixelated}}
.row-info{{margin-top:6px;font-size:.68em;color:#6e7681;display:flex;justify-content:space-between}}
/* ── Sheet preview ── */
.sheet-sec{{background:#161b22;border:1px solid #30363d;border-radius:10px;padding:14px;margin-bottom:14px}}
.sheet-sec h3{{font-size:.85em;color:#8b949e;margin-bottom:8px}}
.sheet-wrap{{overflow:auto;background:repeating-conic-gradient(#1e2330 0% 25%,#161b22 0% 50%) 0 0/14px 14px;border-radius:6px;padding:8px;text-align:center}}
.sheet-wrap img{{image-rendering:pixelated;max-width:100%}}
/* ── Frame strip ── */
.frames-sec{{background:#161b22;border:1px solid #30363d;border-radius:10px;padding:14px}}
.frames-sec h3{{font-size:.85em;color:#8b949e;margin-bottom:10px}}
.row-tabs{{display:flex;gap:6px;margin-bottom:10px;flex-wrap:wrap}}
.row-tab{{padding:4px 11px;border-radius:20px;font-size:.75em;cursor:pointer;background:#21262d;border:1px solid #30363d;color:#8b949e;transition:all .15s}}
.row-tab:hover{{color:#c9d1d9}}
.row-tab.active{{background:#1f3555;border-color:#58a6ff;color:#58a6ff}}
.frame-strip{{display:flex;gap:6px;flex-wrap:wrap}}
.f-thumb{{background:repeating-conic-gradient(#1e2330 0% 25%,#161b22 0% 50%) 0 0/8px 8px;border-radius:5px;padding:3px;border:2px solid #30363d;cursor:pointer;transition:border-color .15s}}
.f-thumb:hover{{border-color:#58a6ff}}
.f-thumb img{{image-rendering:pixelated;display:block;max-width:56px;max-height:56px}}
.f-num{{font-size:.62em;color:#6e7681;text-align:center;margin-top:2px}}
/* ── Empty ── */
.empty{{text-align:center;padding:60px;color:#6e7681;font-size:.9em}}
/* ── Scrollbar ── */
::-webkit-scrollbar{{width:5px;height:5px}}
::-webkit-scrollbar-track{{background:#0d1117}}
::-webkit-scrollbar-thumb{{background:#30363d;border-radius:3px}}
::-webkit-scrollbar-thumb:hover{{background:#484f58}}
</style>
</head>
<body>
<div class="hdr">
  <h1>🎮 {title}</h1>
  <div class="meta">{total} 个 Sprite Sheet &nbsp;·&nbsp; 自动帧检测 &nbsp;·&nbsp; 等宽均分</div>
</div>
<div class="wrap">
  <div class="sb" id="sb"></div>
  <div class="main" id="main">
    <div class="empty">← 从左侧选择 Sprite Sheet 查看动画</div>
  </div>
</div>
<script>
const CHARS={chars_data};
const ROW_COLORS=['#58a6ff','#3fb950','#f85149','#d29922'];
let curChar=null,timers=[],curInterval={default_interval},curRowTab=0;

/* ── Sidebar ── */
(function buildSb(){{
  const sb=document.getElementById('sb');
  const grps={{}};
  CHARS.forEach((c,i)=>{{(grps[c.group]=grps[c.group]||[]).push({{...c,gi:i}});}});
  Object.entries(grps).forEach(([g,cs])=>{{
    const gd=document.createElement('div');
    const gt=document.createElement('div');gt.className='sb-grp-title';gt.textContent=g;gd.appendChild(gt);
    cs.forEach(c=>{{
      const it=document.createElement('div');it.className='sb-item';it.dataset.i=c.gi;
      const thumb=c.rows.length&&c.rows[0].frames.length
        ?`<div class="sb-thumb"><img src="data:image/png;base64,${{c.rows[0].frames[0].data}}"/></div>`
        :`<div class="sb-thumb"></div>`;
      it.innerHTML=thumb+`<span>${{c.name}}</span>`;
      it.addEventListener('click',()=>selectChar(c.gi));
      gd.appendChild(it);
    }});
    sb.appendChild(gd);
  }});
}})();

function selectChar(i){{
  curChar=CHARS[i];curRowTab=0;
  document.querySelectorAll('.sb-item').forEach(el=>el.classList.toggle('active',+el.dataset.i===i));
  renderCard(curChar);
}}

/* ── Card ── */
function renderCard(c){{
  stopAll();
  const main=document.getElementById('main');
  const total=c.rows.reduce((s,r)=>s+r.frames.length,0);
  const rowCnt=c.rows.filter(r=>r.frames.length>0).length;
  main.innerHTML=`
    <div class="card on" id="card">
      <div class="card-title">${{c.name}}</div>
      <div class="card-meta">
        <span>📐 ${{c.width}} × ${{c.height}} px</span>
        <span>🔢 ${{c.num_cols}} 列</span>
        <span>🎞️ ${{total}} 帧</span>
        <span>📋 ${{rowCnt}} 行</span>
      </div>
      <div class="ctrl">
        <label>速度:</label>
        <input type="range" id="spd" min="50" max="1000" step="10" value="${{curInterval}}">
        <span class="speed-val" id="spdVal">${{Math.round(1000/curInterval)}} fps</span>
        <button class="btn pri" onclick="restartAll()">▶ 播放</button>
        <button class="btn" onclick="stopAll()">⏹ 停止</button>
      </div>
      <div class="rows-grid" id="rowsGrid"></div>
      <div class="sheet-sec">
        <h3>📄 原始 Sprite Sheet</h3>
        <div class="sheet-wrap"><img src="data:image/png;base64,${{c.sheet}}"/></div>
      </div>
      <div class="frames-sec">
        <h3>🖼️ 帧详情</h3>
        <div class="row-tabs" id="rowTabs"></div>
        <div class="frame-strip" id="fstrip"></div>
      </div>
    </div>`;
  document.getElementById('spd').addEventListener('input',e=>{{
    curInterval=+e.target.value;
    document.getElementById('spdVal').textContent=Math.round(1000/curInterval)+' fps';
    restartAll();
  }});
  buildRowCards(c);buildTabs(c);
}}

/* ── Row animation cards ── */
function buildRowCards(c){{
  const grid=document.getElementById('rowsGrid');timers=[];
  c.rows.forEach((row,ri)=>{{
    if(!row.frames.length)return;
    const fw=row.frames[0].w,fh=row.frames[0].h;
    const scale=Math.min(3,Math.max(1,Math.floor(180/Math.max(fw,fh))));
    const card=document.createElement('div');card.className='row-card';
    card.innerHTML=`
      <div class="row-card-hd">
        <div class="dot dot-${{ri}}"></div>
        <span>行 ${{ri}} &nbsp;${{row.label}}</span>
        <span style="margin-left:auto;color:#6e7681;font-size:.85em">${{row.frames.length}} 帧</span>
      </div>
      <div class="canvas-wrap">
        <canvas id="cv${{ri}}" width="${{fw*scale}}" height="${{fh*scale}}"></canvas>
      </div>
      <div class="row-info">
        <span>帧尺寸 ${{fw}}×${{fh}}</span><span>缩放 ${{scale}}×</span>
      </div>`;
    grid.appendChild(card);
    startAnim(row,ri,scale);
  }});
}}

function startAnim(row,ri,scale){{
  const cv=document.getElementById('cv'+ri);if(!cv)return;
  const ctx=cv.getContext('2d');ctx.imageSmoothingEnabled=false;
  const imgs=row.frames.map(f=>{{const im=new Image();im.src='data:image/png;base64,'+f.data;return im;}});
  let fi=ri%row.frames.length;
  function draw(){{
    ctx.clearRect(0,0,cv.width,cv.height);
    const im=imgs[fi],f=row.frames[fi];
    if(im.complete&&im.naturalWidth)ctx.drawImage(im,0,0,f.w*scale,f.h*scale);
    fi=(fi+1)%row.frames.length;
  }}
  timers.push(setInterval(draw,curInterval));draw();
}}

function stopAll(){{timers.forEach(t=>clearInterval(t));timers=[];}}
function restartAll(){{
  stopAll();if(!curChar)return;
  const grid=document.getElementById('rowsGrid');if(!grid)return;
  curChar.rows.forEach((row,ri)=>{{
    if(!row.frames.length)return;
    const fw=row.frames[0].w,fh=row.frames[0].h;
    const scale=Math.min(3,Math.max(1,Math.floor(180/Math.max(fw,fh))));
    startAnim(row,ri,scale);
  }});
}}

/* ── Frame strip tabs ── */
function buildTabs(c){{
  const tabs=document.getElementById('rowTabs');tabs.innerHTML='';
  c.rows.forEach((row,ri)=>{{
    if(!row.frames.length)return;
    const tab=document.createElement('div');tab.className='row-tab'+(ri===curRowTab?' active':'');
    tab.textContent=`行${{ri}} ${{row.label}} (${{row.frames.length}}帧)`;
    if(ri===curRowTab){{tab.style.color=ROW_COLORS[ri];tab.style.borderColor=ROW_COLORS[ri];}}
    tab.addEventListener('click',()=>{{curRowTab=ri;buildTabs(c);renderStrip(c,ri);}});
    tabs.appendChild(tab);
  }});
  renderStrip(c,curRowTab);
}}

function renderStrip(c,ri){{
  const strip=document.getElementById('fstrip');strip.innerHTML='';
  const row=c.rows[ri];
  if(!row||!row.frames.length){{strip.innerHTML='<span style="color:#6e7681;font-size:.78em">此行无帧</span>';return;}}
  row.frames.forEach((f,fi)=>{{
    const d=document.createElement('div');d.className='f-thumb';
    const im=document.createElement('img');im.src='data:image/png;base64,'+f.data;im.style.cssText='max-width:56px;max-height:56px';
    const n=document.createElement('div');n.className='f-num';n.textContent='#'+fi;
    d.appendChild(im);d.appendChild(n);strip.appendChild(d);
  }});
}}

/* Auto-select first */
if(CHARS.length)selectChar(0);
</script>
</body>
</html>"""
