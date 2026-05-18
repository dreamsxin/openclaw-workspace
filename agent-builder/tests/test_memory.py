"""Tests for memory manager."""

import pytest
import json
from app.memory import MemoryManager


class TestShortTerm:
    def test_add_and_get(self):
        mem = MemoryManager()
        mem.add({"role": "user", "content": "hello"})
        mem.add({"role": "assistant", "content": "hi"})
        assert len(mem.get_all()) == 2

    def test_clear(self):
        mem = MemoryManager()
        mem.add({"role": "user", "content": "hello"})
        mem.clear()
        assert len(mem.get_all()) == 0

    def test_get_all_returns_copy(self):
        mem = MemoryManager()
        mem.add({"role": "user", "content": "hello"})
        msgs = mem.get_all()
        msgs.clear()
        assert len(mem.get_all()) == 1


class TestLongTerm:
    def test_save_and_recall(self, tmp_path):
        mem = MemoryManager(long_term="file-based", storage_dir=str(tmp_path / "mem"))
        mem.save("test_key", {"info": "hello"})
        results = mem.recall("test_key")
        assert len(results) >= 1
        assert results[0]["data"]["info"] == "hello"

    def test_disabled_long_term(self, tmp_path):
        mem = MemoryManager(long_term="none", storage_dir=str(tmp_path / "mem2"))
        mem.save("test", {"x": 1})
        assert mem.recall("test") == []


class TestSession:
    def test_end_session_saves(self, tmp_path):
        mem = MemoryManager(storage_dir=str(tmp_path / "mem3"))
        mem.add({"role": "user", "content": "test message"})
        mem.end_session()
        # Session should be cleared
        assert len(mem.get_all()) == 0
        # Long-term should have the session
        results = mem.recall("session_")
        assert len(results) >= 1
