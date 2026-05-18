"""Python AI 绑定 — 交互式阅读与代码执行服务

启动: python server.py
访问: http://localhost:8765
"""

import json
import subprocess
import tempfile
import traceback
from pathlib import Path
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading
import webbrowser
import os

BOOK_DIR = Path(__file__).parent
CHAPTERS_DIR = BOOK_DIR / "chapters"
CODE_DIR = BOOK_DIR / "code"
PORT = 8765


# ── 代码执行引擎 ─────────────────────────────────────────

class CodeRunner:
    """安全执行 Python 代码"""

    ALLOWED_IMPORTS = {
        "json", "math", "datetime", "collections", "itertools",
        "functools", "pathlib", "dataclasses", "typing", "enum",
        "re", "hashlib", "base64", "io", "textwrap", "pprint",
    }

    def run(self, code: str, timeout: int = 15) -> dict:
        """执行代码并返回结果"""
        # 基本安全检查
        if self._has_dangerous_code(code):
            return {
                "success": False,
                "output": "",
                "error": "⚠️ 安全限制：代码包含不允许的操作",
            }

        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".py", delete=False, encoding="utf-8"
        ) as f:
            f.write(code)
            f.flush()
            tmp_path = f.name

        try:
            result = subprocess.run(
                ["python3", tmp_path],
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=str(BOOK_DIR),
            )
            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr if result.returncode != 0 else "",
            }
        except subprocess.TimeoutExpired:
            return {"success": False, "output": "", "error": f"⏱️ 执行超时（{timeout}秒）"}
        except Exception as e:
            return {"success": False, "output": "", "error": str(e)}
        finally:
            os.unlink(tmp_path)

    def _has_dangerous_code(self, code: str) -> bool:
        """检查危险代码"""
        dangerous = [
            "import os", "import sys", "import subprocess",
            "import shutil", "import socket", "import http",
            "__import__", "eval(", "exec(",
            "open(", "Path(", "rmdir", "unlink", "remove",
            "shutil", "wget", "curl", "requests.get",
        ]
        code_lower = code.lower()
        return any(d in code_lower for d in dangerous)


# ── 章节解析 ─────────────────────────────────────────────

def get_chapters() -> list[dict]:
    """获取所有章节信息"""
    chapters = []
    for md_file in sorted(CHAPTERS_DIR.glob("ch*.md")):
        name = md_file.stem
        # 读取第一行作为标题
        with open(md_file, encoding="utf-8") as f:
            first_line = f.readline().strip()
            title = first_line.lstrip("#").strip()
        chapters.append({"id": name, "title": title, "file": md_file.name})
    return chapters


def get_chapter_content(chapter_id: str) -> str | None:
    """获取章节 Markdown 内容"""
    md_file = CHAPTERS_DIR / f"{chapter_id}.md"
    if md_file.exists():
        return md_file.read_text(encoding="utf-8")
    return None


def get_code_examples(chapter_id: str) -> list[dict]:
    """获取章节的代码示例"""
    code_dir = CODE_DIR / chapter_id
    examples = []
    if code_dir.exists():
        for py_file in sorted(code_dir.glob("*.py")):
            examples.append({
                "name": py_file.stem,
                "file": py_file.name,
                "code": py_file.read_text(encoding="utf-8"),
            })
    return examples


def get_code_file(path: str) -> str | None:
    """读取代码文件"""
    full_path = BOOK_DIR / path
    if full_path.exists() and full_path.suffix == ".py":
        return full_path.read_text(encoding="utf-8")
    return None


# ── HTTP 处理器 ──────────────────────────────────────────

class BookHandler(SimpleHTTPRequestHandler):
    """HTTP 请求处理器"""

    runner = CodeRunner()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        params = parse_qs(parsed.query)

        if path == "/" or path == "/index.html":
            self._serve_html(self._render_index())
        elif path == "/chapter":
            chapter_id = params.get("id", ["ch01"])[0]
            self._serve_html(self._render_chapter(chapter_id))
        elif path == "/api/chapters":
            self._serve_json(get_chapters())
        elif path == "/api/chapter":
            chapter_id = params.get("id", ["ch01"])[0]
            content = get_chapter_content(chapter_id)
            examples = get_code_examples(chapter_id)
            self._serve_json({"content": content, "examples": examples})
        elif path == "/api/code":
            code_path = params.get("path", [""])[0]
            content = get_code_file(code_path)
            if content:
                self._serve_json({"content": content})
            else:
                self._serve_json({"error": "File not found"}, 404)
        elif path.startswith("/static/"):
            self._serve_static(path[8:])
        else:
            self.send_error(404)

    def do_POST(self):
        parsed = urlparse(self.path)
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length).decode("utf-8")

        if parsed.path == "/api/run":
            data = json.loads(body)
            code = data.get("code", "")
            result = self.runner.run(code)
            self._serve_json(result)
        else:
            self.send_error(404)

    def _serve_json(self, data, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode("utf-8"))

    def _serve_html(self, html):
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(html.encode("utf-8"))

    def _serve_static(self, filename):
        static_dir = BOOK_DIR / "static"
        filepath = static_dir / filename
        if filepath.exists():
            content = filepath.read_bytes()
            self.send_response(200)
            if filename.endswith(".css"):
                self.send_header("Content-Type", "text/css")
            elif filename.endswith(".js"):
                self.send_header("Content-Type", "application/javascript")
            self.end_headers()
            self.wfile.write(content)
        else:
            self.send_error(404)

    # ── HTML 渲染 ──

    def _render_index(self) -> str:
        chapters = get_chapters()
        chapter_list = "\n".join(
            f'<a href="/chapter?id={c["id"]}" class="chapter-item">'
            f'<span class="chapter-num">{c["id"].replace("ch", "").zfill(2)}</span>'
            f'<span class="chapter-title">{c["title"]}</span></a>'
            for c in chapters
        )
        return self._page("目录", f"""
        <div class="hero">
            <h1>Python AI 绑定</h1>
            <p class="subtitle">从零到一掌握 AI 驱动的 Python 开发</p>
            <p class="author">Claude Code & OpenClaw 实战指南 · Dreamszhu 著</p>
        </div>
        <div class="toc">
            <h2>📖 目录</h2>
            {chapter_list}
        </div>
        """)

    def _render_chapter(self, chapter_id: str) -> str:
        content = get_chapter_content(chapter_id)
        examples = get_code_examples(chapter_id)

        if not content:
            return self._page("404", "<h1>章节不存在</h1>")

        # 简易 Markdown → HTML
        html_content = self._md_to_html(content)

        # 代码示例面板
        example_tabs = ""
        example_panels = ""
        for i, ex in enumerate(examples):
            active = "active" if i == 0 else ""
            example_tabs += f'<button class="tab {active}" onclick="switchTab({i})">{ex["file"]}</button>'
            example_panels += f"""
            <div class="code-panel {'active' if i == 0 else ''}" id="panel-{i}">
                <div class="code-header">
                    <span>{ex['file']}</span>
                    <div>
                        <button class="btn-run" onclick="runCode({i})">▶ 运行</button>
                        <button class="btn-copy" onclick="copyCode({i})">📋 复制</button>
                    </div>
                </div>
                <textarea class="code-editor" id="code-{i}" spellcheck="false">{self._escape(ex['code'])}</textarea>
                <div class="output" id="output-{i}">点击 "▶ 运行" 执行代码</div>
            </div>"""

        # 章节导航
        ch_num = int(chapter_id.replace("ch", ""))
        prev_link = f'<a href="/chapter?id=ch{str(ch_num-1).zfill(2)}" class="nav-prev">← 上一章</a>' if ch_num > 1 else ""
        next_link = f'<a href="/chapter?id=ch{str(ch_num+1).zfill(2)}" class="nav-next">下一章 →</a>' if ch_num < 17 else ""

        return self._page(f"第{ch_num}章", f"""
        <div class="chapter-layout">
            <div class="chapter-content">
                <a href="/" class="back-home">← 返回目录</a>
                {html_content}
                <div class="chapter-nav">{prev_link}{next_link}</div>
            </div>
            <div class="sidebar">
                <h3>💻 代码示例</h3>
                <div class="tabs">{example_tabs}</div>
                {example_panels}
                <div class="custom-code">
                    <h3>✏️ 自己试试</h3>
                    <textarea class="code-editor" id="custom-code" spellcheck="false"
                        placeholder="在这里写 Python 代码..."></textarea>
                    <button class="btn-run" onclick="runCustom()">▶ 运行</button>
                    <div class="output" id="custom-output">输出将显示在这里</div>
                </div>
            </div>
        </div>
        """)

    def _page(self, title, body) -> str:
        return f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} - Python AI 绑定</title>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
:root {{
    --bg: #0a0e1a; --bg2: #111827; --bg3: #1f2937;
    --text: #e5e7eb; --text2: #9ca3af; --accent: #60a5fa;
    --accent2: #a78bfa; --green: #34d399; --red: #f87171;
    --yellow: #fbbf24; --border: #374151; --code-bg: #0d1117;
}}
body {{ font-family: -apple-system, 'Noto Sans SC', sans-serif;
    background: var(--bg); color: var(--text); line-height: 1.7; }}
a {{ color: var(--accent); text-decoration: none; }}
a:hover {{ text-decoration: underline; }}

/* 导航 */
.topbar {{ background: var(--bg2); border-bottom: 1px solid var(--border);
    padding: 12px 24px; position: sticky; top: 0; z-index: 100;
    display: flex; align-items: center; gap: 16px; }}
.topbar .logo {{ font-weight: 700; font-size: 18px; color: var(--accent); }}

/* 主页 */
.hero {{ text-align: center; padding: 80px 20px 40px;
    background: linear-gradient(135deg, #0a0e27 0%, #1a1a4e 50%, #2d1b69 100%); }}
.hero h1 {{ font-size: 48px; background: linear-gradient(90deg, #60a5fa, #a78bfa);
    -webkit-background-clip: text; -webkit-text-fill-color: transparent; }}
.hero .subtitle {{ color: var(--text2); font-size: 20px; margin-top: 12px; }}
.hero .author {{ color: var(--text2); font-size: 14px; margin-top: 8px; }}

.toc {{ max-width: 700px; margin: 40px auto; padding: 0 20px; }}
.toc h2 {{ margin-bottom: 20px; }}
.chapter-item {{ display: flex; align-items: center; gap: 16px;
    padding: 14px 20px; background: var(--bg2); border: 1px solid var(--border);
    border-radius: 8px; margin-bottom: 8px; transition: all 0.2s; }}
.chapter-item:hover {{ border-color: var(--accent); background: var(--bg3);
    text-decoration: none; transform: translateX(4px); }}
.chapter-num {{ color: var(--accent); font-weight: 700; font-size: 14px;
    min-width: 32px; }}
.chapter-title {{ color: var(--text); }}

/* 章节页 */
.chapter-layout {{ display: grid; grid-template-columns: 1fr 420px; gap: 0;
    min-height: calc(100vh - 50px); }}
.chapter-content {{ padding: 40px 60px; max-width: 800px; overflow-y: auto; }}
.back-home {{ display: inline-block; margin-bottom: 24px; color: var(--text2); font-size: 14px; }}

/* Markdown 内容 */
.chapter-content h1 {{ font-size: 32px; margin: 32px 0 16px; color: var(--accent); }}
.chapter-content h2 {{ font-size: 24px; margin: 40px 0 16px; padding-bottom: 8px;
    border-bottom: 1px solid var(--border); color: var(--text); }}
.chapter-content h3 {{ font-size: 20px; margin: 32px 0 12px; color: var(--accent2); }}
.chapter-content h4 {{ font-size: 16px; margin: 24px 0 8px; color: var(--text); }}
.chapter-content p {{ margin: 12px 0; }}
.chapter-content ul, .chapter-content ol {{ margin: 12px 0 12px 24px; }}
.chapter-content li {{ margin: 4px 0; }}
.chapter-content strong {{ color: var(--accent); }}
.chapter-content hr {{ border: none; border-top: 1px solid var(--border); margin: 32px 0; }}
.chapter-content blockquote {{ border-left: 3px solid var(--accent2); padding: 8px 16px;
    margin: 16px 0; background: var(--bg2); border-radius: 0 8px 8px 0; }}
.chapter-content table {{ width: 100%; border-collapse: collapse; margin: 16px 0; }}
.chapter-content th, .chapter-content td {{ border: 1px solid var(--border);
    padding: 10px 14px; text-align: left; }}
.chapter-content th {{ background: var(--bg3); color: var(--accent); font-weight: 600; }}
.chapter-content code {{ font-family: 'JetBrains Mono', 'Fira Code', monospace;
    background: var(--bg3); padding: 2px 6px; border-radius: 4px; font-size: 0.9em;
    color: var(--green); }}
.chapter-content pre {{ background: var(--code-bg); border: 1px solid var(--border);
    border-radius: 8px; padding: 16px; margin: 16px 0; overflow-x: auto; }}
.chapter-content pre code {{ background: none; padding: 0; color: var(--text); font-size: 14px; }}

/* 侧边栏 */
.sidebar {{ background: var(--bg2); border-left: 1px solid var(--border);
    padding: 24px 20px; overflow-y: auto; position: sticky; top: 50px;
    height: calc(100vh - 50px); }}
.sidebar h3 {{ font-size: 16px; margin-bottom: 12px; color: var(--accent); }}

/* 代码标签 */
.tabs {{ display: flex; gap: 4px; flex-wrap: wrap; margin-bottom: 12px; }}
.tab {{ background: var(--bg3); border: 1px solid var(--border); color: var(--text2);
    padding: 6px 14px; border-radius: 6px; cursor: pointer; font-size: 13px;
    font-family: monospace; transition: all 0.2s; }}
.tab:hover {{ border-color: var(--accent); }}
.tab.active {{ background: var(--accent); color: var(--bg); border-color: var(--accent); }}

/* 代码面板 */
.code-panel {{ display: none; }}
.code-panel.active {{ display: block; }}
.code-header {{ display: flex; justify-content: space-between; align-items: center;
    padding: 8px 12px; background: var(--bg3); border-radius: 8px 8px 0 0;
    font-size: 13px; color: var(--text2); }}
.code-editor {{ width: 100%; min-height: 200px; background: var(--code-bg);
    color: var(--text); border: 1px solid var(--border); border-top: none;
    border-radius: 0 0 8px 8px; padding: 12px; font-family: 'JetBrains Mono', monospace;
    font-size: 13px; line-height: 1.5; resize: vertical; tab-size: 4; outline: none; }}
.code-editor:focus {{ border-color: var(--accent); }}
.output {{ background: var(--code-bg); border: 1px solid var(--border);
    border-radius: 8px; padding: 12px; margin-top: 12px; font-family: monospace;
    font-size: 13px; white-space: pre-wrap; min-height: 60px; max-height: 300px;
    overflow-y: auto; color: var(--text2); }}
.output.success {{ border-color: var(--green); }}
.output.error {{ border-color: var(--red); color: var(--red); }}

/* 按钮 */
.btn-run {{ background: var(--green); color: var(--bg); border: none;
    padding: 6px 16px; border-radius: 6px; cursor: pointer; font-weight: 600;
    font-size: 13px; transition: all 0.2s; }}
.btn-run:hover {{ opacity: 0.85; transform: scale(1.02); }}
.btn-run:active {{ transform: scale(0.98); }}
.btn-copy {{ background: var(--bg3); color: var(--text2); border: 1px solid var(--border);
    padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 13px; }}
.btn-copy:hover {{ border-color: var(--accent); }}

/* 自定义代码区 */
.custom-code {{ margin-top: 24px; border-top: 1px solid var(--border); padding-top: 24px; }}
.custom-code .code-editor {{ min-height: 120px; }}
.custom-code .btn-run {{ margin-top: 8px; width: 100%; padding: 10px; }}

/* 章节导航 */
.chapter-nav {{ display: flex; justify-content: space-between; margin-top: 48px;
    padding-top: 24px; border-top: 1px solid var(--border); }}

/* 响应式 */
@media (max-width: 900px) {{
    .chapter-layout {{ grid-template-columns: 1fr; }}
    .sidebar {{ position: static; height: auto; border-left: none;
        border-top: 1px solid var(--border); }}
    .chapter-content {{ padding: 24px 20px; }}
    .hero h1 {{ font-size: 32px; }}
}}
</style>
</head>
<body>
<div class="topbar">
    <a href="/" class="logo">📘 Python AI 绑定</a>
    <span style="color:var(--text2);font-size:14px">交互式阅读 · 本地运行</span>
</div>
{body}
<script>
function switchTab(idx) {{
    document.querySelectorAll('.tab').forEach((t,i) => t.classList.toggle('active', i===idx));
    document.querySelectorAll('.code-panel').forEach((p,i) => p.classList.toggle('active', i===idx));
}}

function runCode(idx) {{
    const code = document.getElementById('code-'+idx).value;
    const output = document.getElementById('output-'+idx);
    executeCode(code, output);
}}

function runCustom() {{
    const code = document.getElementById('custom-code').value;
    const output = document.getElementById('custom-output');
    executeCode(code, output);
}}

function executeCode(code, outputEl) {{
    outputEl.textContent = '⏳ 执行中...';
    outputEl.className = 'output';
    fetch('/api/run', {{
        method: 'POST',
        headers: {{'Content-Type': 'application/json'}},
        body: JSON.stringify({{code}})
    }})
    .then(r => r.json())
    .then(data => {{
        if (data.success) {{
            outputEl.textContent = data.output || '(无输出)';
            outputEl.className = 'output success';
        }} else {{
            outputEl.textContent = data.error || '执行失败';
            outputEl.className = 'output error';
        }}
    }})
    .catch(err => {{
        outputEl.textContent = '请求失败: ' + err;
        outputEl.className = 'output error';
    }});
}}

function copyCode(idx) {{
    const code = document.getElementById('code-'+idx).value;
    navigator.clipboard.writeText(code).then(() => {{
        const btn = document.querySelectorAll('.btn-copy')[idx];
        btn.textContent = '✅ 已复制';
        setTimeout(() => btn.textContent = '📋 复制', 1500);
    }});
}}

// Tab 键支持
document.addEventListener('keydown', e => {{
    if (e.target.classList.contains('code-editor') && e.key === 'Tab') {{
        e.preventDefault();
        const start = e.target.selectionStart;
        const end = e.target.selectionEnd;
        e.target.value = e.target.value.substring(0, start) + '    ' + e.target.value.substring(end);
        e.target.selectionStart = e.target.selectionEnd = start + 4;
    }}
}});
</script>
</body>
</html>"""

    def _md_to_html(self, md: str) -> str:
        """简易 Markdown 转 HTML"""
        import re
        lines = md.split("\n")
        html = []
        in_code = False
        in_list = False
        code_lang = ""
        code_buf = []

        for line in lines:
            # 代码块
            if line.startswith("```"):
                if in_code:
                    code_text = "\n".join(code_buf)
                    html.append(f'<pre><code class="language-{code_lang}">{self._escape(code_text)}</code></pre>')
                    code_buf = []
                    in_code = False
                else:
                    in_code = True
                    code_lang = line[3:].strip()
                continue

            if in_code:
                code_buf.append(line)
                continue

            # 列表
            if line.startswith("- ") or line.startswith("* "):
                if not in_list:
                    html.append("<ul>")
                    in_list = True
                html.append(f"<li>{self._inline(line[2:])}</li>")
                continue
            elif in_list and not line.strip():
                html.append("</ul>")
                in_list = False

            # 有序列表
            if re.match(r"^\d+\.", line):
                if not in_list:
                    html.append("<ol>")
                    in_list = True
                html.append(f"<li>{self._inline(re.sub(r'^\d+\.\s*', '', line))}</li>")
                continue
            elif in_list and not line.strip():
                html.append("</ol>")
                in_list = False

            # 标题
            if line.startswith("####"):
                html.append(f"<h4>{self._inline(line[4:].strip())}</h4>")
            elif line.startswith("###"):
                html.append(f"<h3>{self._inline(line[3:].strip())}</h3>")
            elif line.startswith("##"):
                html.append(f"<h2>{self._inline(line[2:].strip())}</h2>")
            elif line.startswith("#"):
                html.append(f"<h1>{self._inline(line[1:].strip())}</h1>")
            elif line.startswith("---"):
                html.append("<hr>")
            elif line.startswith("> "):
                html.append(f"<blockquote>{self._inline(line[2:])}</blockquote>")
            elif line.startswith("|") and "---" in line:
                continue  # 表格分隔行
            elif line.startswith("|"):
                cells = [c.strip() for c in line.split("|")[1:-1]]
                if cells:
                    tag = "th" if all(c.replace("-","").replace(":","").strip()=="" for c in cells) else "td"
                    # 判断是否是表头（下一行是分隔符）
                    html.append("<tr>" + "".join(f"<{tag}>{self._inline(c)}</{tag}>" for c in cells) + "</tr>")
            elif line.strip():
                html.append(f"<p>{self._inline(line)}</p>")
            else:
                html.append("")

        if in_list:
            html.append("</ul>" if "<ul>" in html[-5:] else "</ol>")

        # 处理表格
        result = "\n".join(html)
        result = re.sub(r"(<tr>.*?</tr>\n?)+", lambda m: f"<table>{m.group()}</table>", result, flags=re.DOTALL)

        return result

    def _inline(self, text: str) -> str:
        """行内 Markdown"""
        import re
        text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
        text = re.sub(r"\*(.+?)\*", r"<em>\1</em>", text)
        text = re.sub(r"`(.+?)`", r"<code>\1</code>", text)
        text = re.sub(r"\[(.+?)\]\((.+?)\)", r'<a href="\2">\1</a>', text)
        return text

    def _escape(self, text: str) -> str:
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


# ── 启动 ─────────────────────────────────────────────────

def main():
    print(f"""
╔══════════════════════════════════════════════╗
║   📘 Python AI 绑定 — 交互式阅读服务       ║
╠══════════════════════════════════════════════╣
║   访问: http://localhost:{PORT}              ║
║   按 Ctrl+C 停止                            ║
╚══════════════════════════════════════════════╝
""")
    server = HTTPServer(("0.0.0.0", PORT), BookHandler)

    # 自动打开浏览器
    threading.Timer(0.5, lambda: webbrowser.open(f"http://localhost:{PORT}")).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 已停止")
        server.server_close()


if __name__ == "__main__":
    main()
