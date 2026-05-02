"""Tests for context compression strategies."""

import pytest
from app.context import ContextManager


def make_msgs(n: int) -> list[dict]:
    """Generate n alternating user/assistant messages."""
    msgs = []
    for i in range(n):
        role = "user" if i % 2 == 0 else "assistant"
        msgs.append({"role": role, "content": f"Message {i}: " + "x" * 100})
    return msgs


def make_system_msgs(n: int) -> list[dict]:
    msgs = [{"role": "system", "content": "You are helpful."}]
    msgs.extend(make_msgs(n))
    return msgs


class TestSlidingWindow:
    def test_short_history_unchanged(self):
        cm = ContextManager(strategy="sliding-window", window_size=10)
        msgs = make_system_msgs(5)
        result = cm.compress(msgs)
        assert len(result) == len(msgs)

    def test_long_history_truncated(self):
        cm = ContextManager(strategy="sliding-window", window_size=4)
        msgs = make_system_msgs(20)
        result = cm.compress(msgs)
        # system + 4 recent
        assert len(result) == 5
        assert result[0]["role"] == "system"

    def test_preserves_system_messages(self):
        cm = ContextManager(strategy="sliding-window", window_size=2)
        msgs = [{"role": "system", "content": "sys1"},
                {"role": "system", "content": "sys2"},
                {"role": "user", "content": "a"},
                {"role": "assistant", "content": "b"},
                {"role": "user", "content": "c"}]
        result = cm.compress(msgs)
        sys_count = sum(1 for m in result if m["role"] == "system")
        assert sys_count == 2


class TestTokenBudget:
    def test_respects_budget(self):
        cm = ContextManager(strategy="token-budget", max_tokens=100, window_size=20)
        msgs = make_system_msgs(50)
        result = cm.compress(msgs)
        # Should be significantly shorter
        assert len(result) < len(msgs)

    def test_preserves_system(self):
        cm = ContextManager(strategy="token-budget", max_tokens=50, window_size=5)
        msgs = make_system_msgs(20)
        result = cm.compress(msgs)
        assert result[0]["role"] == "system"


class TestHierarchical:
    def test_short_unchanged(self):
        cm = ContextManager(strategy="hierarchical", window_size=10)
        msgs = make_system_msgs(5)
        result = cm.compress(msgs)
        assert len(result) == len(msgs)

    def test_long_adds_summaries(self):
        cm = ContextManager(strategy="hierarchical", window_size=4)
        msgs = make_system_msgs(20)
        result = cm.compress(msgs)
        # Should have system + old summary + key points + recent
        roles = [m["role"] for m in result]
        assert roles[0] == "system"
        assert len(result) < len(msgs)


class TestImportance:
    def test_preserves_recent(self):
        cm = ContextManager(strategy="importance", window_size=6)
        msgs = make_system_msgs(20)
        result = cm.compress(msgs)
        # Should compress: system + importance-selected messages (includes keep_recent)
        non_system = [m for m in result if m["role"] != "system"]
        assert len(non_system) <= 8  # 4 recent + up to 4 scored


class TestNone:
    def test_passthrough(self):
        cm = ContextManager(strategy="none")
        msgs = make_system_msgs(100)
        result = cm.compress(msgs)
        assert len(result) == len(msgs)


class TestCustomCounter:
    def test_uses_custom_counter(self):
        counter_calls = []
        def fake_counter(text):
            counter_calls.append(text)
            return len(text)
        cm = ContextManager(strategy="token-budget", max_tokens=500, counter=fake_counter)
        msgs = make_system_msgs(10)
        cm.compress(msgs)
        assert len(counter_calls) > 0
