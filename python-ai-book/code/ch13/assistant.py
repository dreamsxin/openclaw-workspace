"""第13章 智能代码助手 — 完整实现（含本地文件读写）

功能：
- 读取本地文件进行分析/重构/测试生成
- 将 AI 生成的代码写回文件
- 项目级扫描与分析
- 代码差异对比
"""

import anthropic
from pathlib import Path
from dataclasses import dataclass, field
from enum import Enum
import difflib
import json
import shutil
from datetime import datetime


class TaskType(Enum):
    ANALYZE = "analyze"
    GENERATE = "generate"
    REFACTOR = "refactor"
    TEST = "test"
    EXPLAIN = "explain"
    FIX = "fix"


# ── 语言检测 ──────────────────────────────────────────────

LANG_MAP = {
    ".py": "Python", ".js": "JavaScript", ".ts": "TypeScript",
    ".java": "Java", ".go": "Go", ".rs": "Rust",
    ".c": "C", ".cpp": "C++", ".h": "C/C++ Header",
    ".rb": "Ruby", ".php": "PHP", ".sh": "Shell",
    ".html": "HTML", ".css": "CSS", ".sql": "SQL",
    ".md": "Markdown", ".json": "JSON", ".yaml": "YAML",
    ".yml": "YAML", ".toml": "TOML", ".xml": "XML",
}


def detect_language(file_path: str) -> str:
    """根据扩展名检测语言"""
    return LANG_MAP.get(Path(file_path).suffix.lower(), "text")


# ── 文件管理器 ─────────────────────────────────────────────

class FileManager:
    """本地文件读写管理"""

    def __init__(self, work_dir: str = "."):
        self.work_dir = Path(work_dir).resolve()
        self.work_dir.mkdir(parents=True, exist_ok=True)

    def read(self, file_path: str) -> str:
        """读取文件内容"""
        path = self._resolve(file_path)
        if not path.exists():
            raise FileNotFoundError(f"文件不存在: {path}")
        if not path.is_file():
            raise IsADirectoryError(f"不是文件: {path}")
        # 安全检查：不超过 1MB
        if path.stat().st_size > 1_000_000:
            raise ValueError(f"文件过大 ({path.stat().st_size} bytes)，限制 1MB")
        return path.read_text(encoding="utf-8")

    def write(self, file_path: str, content: str, backup: bool = True) -> str:
        """写入文件，自动备份旧文件"""
        path = self._resolve(file_path)
        path.parent.mkdir(parents=True, exist_ok=True)

        # 备份已有文件
        if backup and path.exists():
            backup_path = path.with_suffix(f".bak.{datetime.now():%Y%m%d%H%M%S}")
            shutil.copy2(path, backup_path)

        path.write_text(content, encoding="utf-8")
        return str(path)

    def list_dir(self, dir_path: str = ".", pattern: str = "*") -> list[dict]:
        """列出目录内容"""
        path = self._resolve(dir_path)
        if not path.is_dir():
            raise NotADirectoryError(f"不是目录: {path}")

        entries = []
        for item in sorted(path.glob(pattern)):
            entries.append({
                "name": item.name,
                "path": str(item.relative_to(self.work_dir)),
                "type": "dir" if item.is_dir() else "file",
                "size": item.stat().st_size if item.is_file() else None,
            })
        return entries

    def scan_project(self, dir_path: str = ".", extensions: list[str] | None = None) -> dict:
        """扫描项目结构"""
        path = self._resolve(dir_path)
        if extensions is None:
            extensions = [".py", ".js", ".ts", ".java", ".go", ".rs"]

        files = []
        total_lines = 0

        for ext in extensions:
            for f in path.rglob(f"*{ext}"):
                # 跳过常见的非源码目录
                if any(skip in str(f) for skip in [
                    ".venv", "node_modules", "__pycache__", ".git",
                    ".tox", "dist", "build", ".mypy_cache"
                ]):
                    continue
                try:
                    content = f.read_text(encoding="utf-8")
                    lines = len(content.splitlines())
                    total_lines += lines
                    files.append({
                        "path": str(f.relative_to(self.work_dir)),
                        "language": detect_language(str(f)),
                        "lines": lines,
                    })
                except Exception:
                    pass

        return {
            "directory": str(path.relative_to(self.work_dir)),
            "total_files": len(files),
            "total_lines": total_lines,
            "files": sorted(files, key=lambda x: x["path"]),
        }

    def diff(self, file_path: str, new_content: str) -> str:
        """对比文件变更"""
        path = self._resolve(file_path)
        if path.exists():
            old_lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
        else:
            old_lines = []

        new_lines = new_content.splitlines(keepends=True)

        diff = difflib.unified_diff(
            old_lines, new_lines,
            fromfile=f"a/{file_path}",
            tofile=f"b/{file_path}",
        )
        return "".join(diff) or "(无变更)"

    def _resolve(self, file_path: str) -> Path:
        """解析路径（支持相对/绝对）"""
        p = Path(file_path)
        if p.is_absolute():
            return p
        return (self.work_dir / p).resolve()


# ── 代码助手 ───────────────────────────────────────────────

class CodeAssistant:
    """智能代码助手（含文件操作）"""

    def __init__(self, work_dir: str = ".", model: str = "claude-sonnet-4-20250514"):
        self.client = anthropic.Anthropic()
        self.model = model
        self.history: list[dict] = []
        self.files = FileManager(work_dir)

    # ── 核心能力 ──

    def analyze(self, code: str, language: str = "Python") -> str:
        prompt = f"""分析以下 {language} 代码：

```{language}
{code}
```

提供：
1. 功能概述
2. 代码质量评估（1-10分）
3. 潜在问题
4. 改进建议"""
        return self._call(prompt)

    def generate(self, requirement: str, language: str = "Python") -> str:
        prompt = f"""根据以下需求生成 {language} 代码：

{requirement}

要求：使用类型注解、包含 docstring、遵循最佳实践、处理边界情况。
只输出代码，不要解释。"""
        return self._call(prompt)

    def refactor(self, code: str, language: str = "Python") -> str:
        prompt = f"""重构以下 {language} 代码，提升质量：

```{language}
{code}
```

重构方向：提高可读性、减少重复、改善命名、优化性能。
输出重构后的完整代码，只输出代码。"""
        return self._call(prompt)

    def generate_tests(self, code: str, language: str = "Python") -> str:
        prompt = f"""为以下 {language} 代码生成 pytest 测试：

```{language}
{code}
```

要求：覆盖正常情况和边界情况、使用 pytest fixtures、使用参数化测试。
只输出测试代码。"""
        return self._call(prompt)

    def explain_error(self, error: str, code: str = "") -> str:
        prompt = f"解释以下错误并给出修复方案：\n\n错误：{error}"
        if code:
            prompt += f"\n\n相关代码：\n```python\n{code}\n```"
        prompt += "\n\n请提供：1. 错误原因 2. 修复方案 3. 修复后的代码"
        return self._call(prompt)

    def fix(self, code: str, error: str, language: str = "Python") -> str:
        prompt = f"""以下 {language} 代码有错误：

```{language}
{code}
```

错误：{error}

输出修复后的完整代码，只输出代码。"""
        return self._call(prompt)

    # ── 文件操作 ──

    def open(self, file_path: str) -> str:
        """打开文件并返回内容（同时作为上下文记住）"""
        content = self.files.read(file_path)
        lang = detect_language(file_path)
        self._current_file = file_path
        self._current_lang = lang
        return f"已打开 {file_path} ({lang}, {len(content.splitlines())} 行)\n\n{content}"

    def save(self, file_path: str | None, content: str) -> str:
        """保存代码到文件"""
        target = file_path or getattr(self, "_current_file", None)
        if not target:
            raise ValueError("未指定文件路径，也没有当前打开的文件")

        diff_text = self.files.diff(target, content)
        path = self.files.write(target, content)
        return f"✅ 已保存到 {path}\n\n变更:\n{diff_text}"

    def analyze_file(self, file_path: str) -> str:
        """分析本地文件"""
        content = self.files.read(file_path)
        lang = detect_language(file_path)
        return self.analyze(content, lang)

    def refactor_file(self, file_path: str, save: bool = False) -> str:
        """重构本地文件"""
        content = self.files.read(file_path)
        lang = detect_language(file_path)
        result = self.refactor(content, lang)

        if save:
            self.save(file_path, result)

        return result

    def test_file(self, file_path: str, save: bool = False) -> str:
        """为本地文件生成测试"""
        content = self.files.read(file_path)
        lang = detect_language(file_path)
        result = self.generate_tests(content, lang)

        if save:
            # 测试文件保存到同目录
            p = Path(file_path)
            test_path = p.parent / f"test_{p.stem}.py"
            self.save(str(test_path), result)

        return result

    def fix_file(self, file_path: str, error: str, save: bool = False) -> str:
        """修复本地文件"""
        content = self.files.read(file_path)
        lang = detect_language(file_path)
        result = self.fix(content, error, lang)

        if save:
            self.save(file_path, result)

        return result

    def scan_project(self, dir_path: str = ".") -> dict:
        """扫描项目"""
        return self.files.scan_project(dir_path)

    def analyze_project(self, dir_path: str = ".") -> str:
        """分析整个项目"""
        info = self.scan_project(dir_path)

        file_list = "\n".join(
            f"- {f['path']} ({f['language']}, {f['lines']}行)"
            for f in info["files"][:50]  # 最多50个文件
        )

        prompt = f"""分析以下项目结构：

目录：{info['directory']}
文件数：{info['total_files']}
总行数：{info['total_lines']}

文件列表：
{file_list}

请提供：
1. 项目概述
2. 架构分析
3. 代码质量评估
4. 改进建议
"""
        return self._call(prompt)

    # ── 内部方法 ──

    def _call(self, prompt: str) -> str:
        self.history.append({"role": "user", "content": prompt})
        response = self.client.messages.create(
            model=self.model, max_tokens=4096, messages=self.history
        )
        answer = response.content[0].text
        self.history.append({"role": "assistant", "content": answer})
        return answer

    def clear_history(self):
        """清空对话历史"""
        self.history.clear()


# ── CLI 界面 ───────────────────────────────────────────────

def main():
    import sys
    from rich.console import Console
    from rich.markdown import Markdown
    from rich.syntax import Syntax
    from rich.table import Table

    console = Console()

    # 支持启动时指定工作目录
    work_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    assistant = CodeAssistant(work_dir=work_dir)

    console.print(f"[bold green]🤖 智能代码助手[/bold green]  工作目录: {work_dir}")
    console.print()

    # 命令帮助
    help_text = """
[bold]文件操作[/bold]
  open <文件>           打开文件
  save [文件]           保存当前文件（AI生成的内容）
  ls [目录]             列出目录内容
  scan [目录]           扫描项目结构

[bold]AI 能力[/bold]
  analyze [文件]        分析代码（从文件或手动输入）
  generate <需求>       生成代码
  refactor [文件]       重构代码
  test [文件]           生成测试
  fix <文件> <错误>     修复代码
  explain <错误>        解释错误
  project [目录]        分析整个项目

[bold]其他[/bold]
  help                  显示帮助
  clear                 清空对话历史
  quit                  退出
"""
    console.print(help_text)

    current_code = ""  # 当前缓存的代码

    while True:
        try:
            raw = input(">>> ").strip()
            if not raw:
                continue

            parts = raw.split(maxsplit=1)
            cmd = parts[0].lower()
            arg = parts[1] if len(parts) > 1 else ""

            if cmd in ("quit", "exit", "q"):
                break

            elif cmd == "help":
                console.print(help_text)

            elif cmd == "clear":
                assistant.clear_history()
                console.print("[dim]对话历史已清空[/dim]")

            # ── 文件操作 ──

            elif cmd == "open":
                if not arg:
                    console.print("[red]用法: open <文件路径>[/red]")
                    continue
                try:
                    result = assistant.open(arg.strip())
                    current_code = assistant.files.read(arg.strip())
                    console.print(Syntax(current_code, assistant._current_lang.lower()))
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "save":
                if not current_code:
                    console.print("[red]没有可保存的内容[/red]")
                    continue
                try:
                    target = arg.strip() if arg else None
                    result = assistant.save(target, current_code)
                    console.print(f"[green]{result}[/green]")
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "ls":
                try:
                    entries = assistant.files.list_dir(arg or ".")
                    table = Table(show_header=True)
                    table.add_column("类型", width=4)
                    table.add_column("名称")
                    table.add_column("大小", justify="right")
                    for e in entries:
                        icon = "📁" if e["type"] == "dir" else "📄"
                        size = f"{e['size']:,}" if e["size"] else ""
                        table.add_row(icon, e["name"], size)
                    console.print(table)
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "scan":
                try:
                    info = assistant.scan_project(arg or ".")
                    table = Table(title=f"项目扫描: {info['directory']}")
                    table.add_column("文件", style="cyan")
                    table.add_column("语言", style="green")
                    table.add_column("行数", justify="right")
                    for f in info["files"]:
                        table.add_row(f["path"], f["language"], str(f["lines"]))
                    console.print(table)
                    console.print(f"\n共 {info['total_files']} 个文件，{info['total_lines']} 行代码")
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            # ── AI 能力 ──

            elif cmd == "analyze":
                try:
                    if arg:
                        result = assistant.analyze_file(arg.strip())
                    elif current_code:
                        result = assistant.analyze(current_code, assistant._current_lang)
                    else:
                        current_code = _read_code_input()
                        result = assistant.analyze(current_code)
                    console.print(Markdown(result))
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "generate":
                if not arg:
                    console.print("[red]用法: generate <需求描述>[/red]")
                    continue
                result = assistant.generate(arg.strip())
                current_code = _extract_code(result)
                console.print(Syntax(current_code or result, "python"))

            elif cmd == "refactor":
                try:
                    if arg:
                        result = assistant.refactor_file(arg.strip())
                    elif current_code:
                        result = assistant.refactor(current_code, assistant._current_lang)
                    else:
                        current_code = _read_code_input()
                        result = assistant.refactor(current_code)
                    current_code = _extract_code(result) or result
                    console.print(Syntax(current_code, "python"))

                    # 询问是否保存
                    if arg or hasattr(assistant, "_current_file"):
                        confirm = input("保存到文件？(y/n): ").strip().lower()
                        if confirm == "y":
                            target = arg.strip() if arg else None
                            save_result = assistant.save(target, current_code)
                            console.print(f"[green]{save_result}[/green]")
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "test":
                try:
                    if arg:
                        result = assistant.test_file(arg.strip())
                    elif current_code:
                        result = assistant.generate_tests(current_code, assistant._current_lang)
                    else:
                        current_code = _read_code_input()
                        result = assistant.generate_tests(current_code)
                    current_code = _extract_code(result) or result
                    console.print(Syntax(current_code, "python"))

                    if arg:
                        confirm = input("保存测试文件？(y/n): ").strip().lower()
                        if confirm == "y":
                            p = Path(arg.strip())
                            test_path = str(p.parent / f"test_{p.stem}.py")
                            assistant.save(test_path, current_code)
                            console.print(f"[green]已保存到 {test_path}[/green]")
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "fix":
                if not arg:
                    console.print("[red]用法: fix <文件路径> <错误信息>[/red]")
                    continue
                fix_parts = arg.split(maxsplit=1)
                if len(fix_parts) < 2:
                    console.print("[red]用法: fix <文件路径> <错误信息>[/red]")
                    continue
                file_path, error = fix_parts
                try:
                    result = assistant.fix_file(file_path.strip(), error.strip())
                    current_code = _extract_code(result) or result
                    console.print(Syntax(current_code, "python"))

                    confirm = input("保存修复结果？(y/n): ").strip().lower()
                    if confirm == "y":
                        assistant.save(file_path.strip(), current_code)
                        console.print(f"[green]已保存到 {file_path.strip()}[/green]")
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            elif cmd == "explain":
                error = arg or input("错误信息：").strip()
                code_for_context = current_code if current_code else ""
                result = assistant.explain_error(error, code_for_context)
                console.print(Markdown(result))

            elif cmd == "project":
                try:
                    result = assistant.analyze_project(arg or ".")
                    console.print(Markdown(result))
                except Exception as e:
                    console.print(f"[red]错误: {e}[/red]")

            else:
                console.print(f"[red]未知命令: {cmd}，输入 help 查看帮助[/red]")

        except KeyboardInterrupt:
            break
        except Exception as e:
            console.print(f"[red]错误: {e}[/red]")

    console.print("\n再见！👋")


def _read_code_input() -> str:
    """手动输入代码"""
    print("输入代码（输入空行结束）：")
    lines = []
    while True:
        try:
            line = input()
        except EOFError:
            break
        if line == "":
            break
        lines.append(line)
    return "\n".join(lines)


def _extract_code(text: str) -> str | None:
    """从 AI 回复中提取代码块"""
    import re
    # 匹配 ```python ... ``` 或 ``` ... ```
    match = re.search(r"```(?:\w+)?\n(.*?)```", text, re.DOTALL)
    return match.group(1).strip() if match else None


if __name__ == "__main__":
    main()
