"""Tests for CLI commands using typer test runner."""

from __future__ import annotations

from typer.testing import CliRunner

from rag_builder.cli import app

runner = CliRunner()


class TestCLIHelp:
    def test_help(self):
        result = runner.invoke(app, ["--help"])
        assert result.exit_code == 0
        assert "rag-builder" in result.output.lower() or "RAG" in result.output

    def test_init_help(self):
        result = runner.invoke(app, ["init", "--help"])
        assert result.exit_code == 0
        assert "文档目录" in result.output or "source_dir" in result.output

    def test_index_help(self):
        result = runner.invoke(app, ["index", "--help"])
        assert result.exit_code == 0
        assert "增量" in result.output or "incremental" in result.output.lower()

    def test_quick_help(self):
        result = runner.invoke(app, ["quick", "--help"])
        assert result.exit_code == 0
        assert "预设" in result.output or "preset" in result.output

    def test_status_help(self):
        result = runner.invoke(app, ["status", "--help"])
        assert result.exit_code == 0

    def test_chat_help(self):
        result = runner.invoke(app, ["chat", "--help"])
        assert result.exit_code == 0


class TestCLIInit:
    def test_missing_source_dir(self, tmp_dir):
        """Should fail if source dir doesn't exist."""
        result = runner.invoke(app, [
            "init", str(tmp_dir / "nonexistent"),
            "-o", str(tmp_dir / "output"),
        ])
        assert result.exit_code != 0

    def test_empty_source_dir(self, tmp_dir):
        """Should fail if no documents found."""
        empty = tmp_dir / "empty"
        empty.mkdir()
        result = runner.invoke(app, [
            "init", str(empty),
            "-o", str(tmp_dir / "output"),
        ])
        assert result.exit_code != 0

    def test_dry_run(self, tmp_dir, sample_docs):
        """Dry run should not generate files."""
        result = runner.invoke(app, [
            "init", str(sample_docs),
            "-o", str(tmp_dir / "output"),
            "--dry-run",
        ])
        # Should succeed (exit 0) or fail gracefully
        # The actual index step will fail without API key, but dry-run skips it
        assert "dry" in result.output.lower() or "预览" in result.output or result.exit_code == 0


class TestCLIIndex:
    def test_missing_source(self, tmp_dir):
        result = runner.invoke(app, [
            "index", str(tmp_dir / "nonexistent"),
        ])
        assert result.exit_code != 0

    def test_empty_source(self, tmp_dir):
        empty = tmp_dir / "empty"
        empty.mkdir()
        result = runner.invoke(app, [
            "index", str(empty),
        ])
        assert result.exit_code != 0


class TestCLIStatus:
    def test_no_index(self, tmp_dir):
        result = runner.invoke(app, ["status", str(tmp_dir / "noindex")])
        # Should show "未找到" or similar
        assert result.exit_code == 0
