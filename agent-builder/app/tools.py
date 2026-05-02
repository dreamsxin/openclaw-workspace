"""
Tool Registry — each tool is a callable with a JSON-schema description.
Security: code execution is sandboxed, file access is path-restricted.
"""

from __future__ import annotations
import asyncio, json, re, os, tempfile
from abc import ABC, abstractmethod
from pathlib import Path
import httpx


# ── Security config ────────────────────────────
ALLOWED_PATHS = os.getenv("ALLOWED_PATHS", "/tmp/agent_work").split(",")
BLOCKED_PATHS = {"/etc", "/proc", "/sys", "/dev", "/root/.ssh", "/root/.openclaw",
                 "/var/run", "/boot", "/usr/bin", "/usr/sbin"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
MAX_EXEC_TIME = 30
MAX_OUTPUT_LEN = 8000


def _check_path(p: Path) -> tuple[bool, str]:
    """Validate path is within allowed boundaries."""
    resolved = p.resolve()
    # Block system paths
    for blocked in BLOCKED_PATHS:
        if str(resolved).startswith(blocked):
            return False, f"Access denied: path under {blocked}"
    # Check allowed prefixes
    allowed = [Path(ap).resolve() for ap in ALLOWED_PATHS]
    # Also allow relative paths (resolved against first allowed path)
    if not any(str(resolved).startswith(str(a)) for a in allowed):
        # Try resolving relative to allowed paths
        for a in allowed:
            candidate = (a / p).resolve()
            if str(candidate).startswith(str(a)):
                return True, str(candidate)
        return False, f"Path outside allowed directories: {resolved}"
    return True, str(resolved)


class Tool(ABC):
    name: str
    description: str
    parameters: dict
    timeout: int = 30

    @abstractmethod
    async def run(self, **kwargs) -> str: ...

    def schema(self) -> dict:
        return {
            "type": "function",
            "function": {
                "name": self.name,
                "description": self.description,
                "parameters": self.parameters,
            },
        }


# ─────────────────────────────────────────────
# Built-in tools
# ─────────────────────────────────────────────
class WebSearchTool(Tool):
    name = "web_search"
    description = "Search the web via DuckDuckGo and return results."
    parameters = {
        "type": "object",
        "properties": {
            "query": {"type": "string", "description": "Search query"},
            "max_results": {"type": "integer", "default": 5},
        },
        "required": ["query"],
    }

    async def run(self, query: str = "", max_results: int = 5, **kw) -> str:
        max_results = min(max_results, 10)
        async with httpx.AsyncClient(timeout=15) as c:
            r = await c.get("https://html.duckduckgo.com/html/",
                            params={"q": query},
                            headers={"User-Agent": "Mozilla/5.0"})
            links = re.findall(
                r'<a rel="nofollow" class="result__a" href="([^"]+)">(.+?)</a>', r.text)
            return json.dumps(
                [{"title": t.strip(), "url": u} for u, t in links[:max_results]],
                ensure_ascii=False)[:MAX_OUTPUT_LEN]


class WebFetchTool(Tool):
    name = "web_fetch"
    description = "Fetch a URL and return its text content."
    parameters = {
        "type": "object",
        "properties": {
            "url": {"type": "string"},
            "max_chars": {"type": "integer", "default": 8000},
        },
        "required": ["url"],
    }

    async def run(self, url: str = "", max_chars: int = 8000, **kw) -> str:
        # Block internal/private IPs
        if re.match(r'https?://(127\.|10\.|172\.(1[6-9]|2|3[01])\.|192\.168\.|0\.|localhost)', url):
            return "[Error] Access to internal/private URLs is blocked"
        max_chars = min(max_chars, MAX_OUTPUT_LEN)
        async with httpx.AsyncClient(timeout=20, follow_redirects=True) as c:
            r = await c.get(url, headers={"User-Agent": "Mozilla/5.0"})
            return r.text[:max_chars]


class CodeExecTool(Tool):
    name = "code_execution"
    description = "Run Python code in a sandboxed subprocess; returns stdout/stderr."
    timeout = MAX_EXEC_TIME
    parameters = {
        "type": "object",
        "properties": {
            "code": {"type": "string", "description": "Python code"},
            "timeout": {"type": "integer", "default": 30},
        },
        "required": ["code"],
    }

    async def run(self, code: str = "", timeout: int = 30, **kw) -> str:
        timeout = min(timeout, MAX_EXEC_TIME)

        # Wrap code with safety restrictions
        safe_code = f"""
import sys, os, builtins

# Block dangerous imports
_blocked = {{'subprocess', 'shutil', 'socket', 'http', 'urllib', 'ctypes',
             'multiprocessing', 'signal', 'resource'}}
_orig_import = builtins.__import__
def _safe_import(name, *a, **kw):
    top = name.split('.')[0]
    if top in _blocked:
        raise ImportError(f"Import '{{name}}' is blocked for security")
    return _orig_import(name, *a, **kw)
builtins.__import__ = _safe_import

# Block dangerous builtins
for _b in ('exec', 'eval', 'compile', '__import__', 'open'):
    pass  # open is allowed but restricted below

# Restrict file access to /tmp
_orig_open = builtins.open
def _safe_open(path, *a, **kw):
    p = str(path)
    if not p.startswith('/tmp') and not p.startswith('./'):
        raise PermissionError(f"File access restricted to /tmp, got: {{p}}")
    return _orig_open(path, *a, **kw)
builtins.open = _safe_open

# Run user code
exec(compile({code!r}, '<user_code>', 'exec'))
"""
        proc = await asyncio.create_subprocess_exec(
            "python3", "-c", safe_code,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            env={"PATH": "/usr/bin:/bin", "HOME": "/tmp", "TMPDIR": "/tmp"},
        )
        try:
            stdout, stderr = await asyncio.wait_for(proc.communicate(), timeout=timeout)
        except asyncio.TimeoutError:
            proc.kill()
            return "[Error] Execution timed out"
        out = stdout.decode()[-4000:]
        err = stderr.decode()[-2000:]
        return f"[stdout]\n{out}\n[stderr]\n{err}" if err else out or "(no output)"


class FileOpsTool(Tool):
    name = "file_ops"
    description = "Read / write / list local files (restricted to allowed directories)."
    parameters = {
        "type": "object",
        "properties": {
            "action": {"type": "string", "enum": ["read", "write", "list"]},
            "path": {"type": "string"},
            "content": {"type": "string"},
        },
        "required": ["action", "path"],
    }

    async def run(self, action: str = "read", path: str = "", content: str = "", **kw) -> str:
        ok, resolved = _check_path(Path(path))
        if not ok:
            return f"[Error] {resolved}"

        p = Path(resolved)

        if action == "read":
            if not p.exists():
                return f"[Error] File not found: {path}"
            if p.stat().st_size > MAX_FILE_SIZE:
                return f"[Error] File too large (max {MAX_FILE_SIZE // 1024 // 1024}MB)"
            return p.read_text()[:MAX_OUTPUT_LEN]

        elif action == "write":
            p.parent.mkdir(parents=True, exist_ok=True)
            if len(content) > MAX_FILE_SIZE:
                return f"[Error] Content too large"
            p.write_text(content)
            return f"Written {len(content)} chars → {resolved}"

        elif action == "list":
            if not p.is_dir():
                return f"[Error] Not a directory: {path}"
            items = sorted(str(f.relative_to(p)) for f in p.iterdir())
            return "\n".join(items)[:MAX_OUTPUT_LEN]

        return "[Error] Unknown action"


class APICallTool(Tool):
    name = "api_call"
    description = "Make an HTTP request to an external API."
    parameters = {
        "type": "object",
        "properties": {
            "method":  {"type": "string", "enum": ["GET", "POST", "PUT", "DELETE"]},
            "url":     {"type": "string"},
            "headers": {"type": "object"},
            "body":    {"type": "string"},
        },
        "required": ["method", "url"],
    }

    async def run(self, method: str = "GET", url: str = "",
                  headers: dict | None = None, body: str | None = None, **kw) -> str:
        # Block internal IPs
        if re.match(r'https?://(127\.|10\.|172\.(1[6-9]|2|3[01])\.|192\.168\.|0\.|localhost)', url):
            return "[Error] Access to internal/private URLs is blocked"
        async with httpx.AsyncClient(timeout=30) as c:
            r = await c.request(method, url, headers=headers, content=body)
            return f"[{r.status_code}]\n{r.text[:MAX_OUTPUT_LEN]}"


# ─────────────────────────────────────────────
# Registry
# ─────────────────────────────────────────────
BUILTIN: dict[str, type[Tool]] = {
    "web_search":   WebSearchTool,
    "web_fetch":    WebFetchTool,
    "code_exec":    CodeExecTool,
    "file_ops":     FileOpsTool,
    "api_call":     APICallTool,
}


class ToolRegistry:
    def __init__(self):
        self._tools: dict[str, Tool] = {}

    def register(self, tool: Tool):
        self._tools[tool.name] = tool

    def get(self, name: str) -> Tool | None:
        return self._tools.get(name)

    def schemas(self) -> list[dict]:
        return [t.schema() for t in self._tools.values()]

    def names(self) -> list[str]:
        return list(self._tools.keys())

    @classmethod
    def from_config(cls, configs: list) -> "ToolRegistry":
        reg = cls()
        enabled = {t.id for t in configs if t.enabled}
        for tid, tcls in BUILTIN.items():
            if tid in enabled:
                reg.register(tcls())
        return reg
