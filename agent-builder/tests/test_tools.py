"""Tests for tool registry and security restrictions."""

import pytest
from app.tools import (
    ToolRegistry, WebSearchTool, WebFetchTool, CodeExecTool,
    FileOpsTool, APICallTool, _check_path, ALLOWED_PATHS,
)


class TestToolRegistry:
    def test_from_config(self):
        from app.config import ToolConfig
        configs = [ToolConfig(id="web_search"), ToolConfig(id="file_ops")]
        reg = ToolRegistry.from_config(configs)
        assert "web_search" in reg.names()
        assert "file_ops" in reg.names()
        assert "code_exec" not in reg.names()

    def test_empty_config(self):
        reg = ToolRegistry.from_config([])
        assert reg.names() == []

    def test_schema_format(self):
        reg = ToolRegistry()
        reg.register(WebSearchTool())
        schemas = reg.schemas()
        assert len(schemas) == 1
        assert schemas[0]["type"] == "function"
        assert schemas[0]["function"]["name"] == "web_search"


class TestPathSecurity:
    def test_blocked_paths(self):
        for p in ["/etc/passwd", "/root/.ssh/id_rsa", "/proc/self/environ"]:
            ok, msg = _check_path(type("P", (), {"resolve": lambda s: type("R", (), {"__str__": lambda s: p})()})())
            assert not ok, f"Should block {p}"

    def test_allowed_paths(self, tmp_path, monkeypatch):
        import app.tools as tools_mod
        monkeypatch.setattr(tools_mod, "ALLOWED_PATHS", [str(tmp_path)])
        from pathlib import Path
        ok, _ = _check_path(Path(str(tmp_path)) / "test.txt")
        assert ok


class TestWebFetchSecurity:
    @pytest.mark.asyncio
    async def test_blocks_internal_ips(self):
        tool = WebFetchTool()
        for url in ["http://127.0.0.1/", "http://10.0.0.1/", "http://192.168.1.1/",
                     "http://localhost/"]:
            result = await tool.run(url=url)
            assert "blocked" in result.lower() or "error" in result.lower()


class TestCodeExecSecurity:
    @pytest.mark.asyncio
    async def test_blocks_subprocess_import(self):
        tool = CodeExecTool()
        result = await tool.run(code="import subprocess; subprocess.run(['ls'])", timeout=10)
        assert "blocked" in result.lower() or "error" in result.lower() or "ImportError" in result

    @pytest.mark.asyncio
    async def test_blocks_socket(self):
        tool = CodeExecTool()
        result = await tool.run(code="import socket", timeout=10)
        assert "blocked" in result.lower() or "error" in result.lower() or "ImportError" in result

    @pytest.mark.asyncio
    async def test_normal_code_works(self):
        tool = CodeExecTool()
        result = await tool.run(code="print(2+3)", timeout=10)
        assert "5" in result

    @pytest.mark.asyncio
    async def test_timeout_enforced(self):
        tool = CodeExecTool()
        result = await tool.run(code="import time; time.sleep(100)", timeout=2)
        assert "timed out" in result.lower() or "error" in result.lower()


class TestFileOpsSecurity:
    @pytest.mark.asyncio
    async def test_blocks_etc(self):
        tool = FileOpsTool()
        result = await tool.run(action="read", path="/etc/passwd")
        assert "denied" in result.lower() or "error" in result.lower()

    @pytest.mark.asyncio
    async def test_blocks_ssh(self):
        tool = FileOpsTool()
        result = await tool.run(action="read", path="/root/.ssh/id_rsa")
        assert "denied" in result.lower() or "error" in result.lower()

    @pytest.mark.asyncio
    async def test_blocks_write_to_system(self):
        tool = FileOpsTool()
        result = await tool.run(action="write", path="/etc/test", content="hack")
        assert "denied" in result.lower() or "error" in result.lower()


class TestWebSearch:
    @pytest.mark.asyncio
    @pytest.mark.skipif(True, reason="Network-dependent, skip in CI")
    async def test_search_returns_results(self):
        tool = WebSearchTool()
        result = await tool.run(query="python programming", max_results=3)
        assert isinstance(result, str)
        import json
        data = json.loads(result)
        assert isinstance(data, list)
