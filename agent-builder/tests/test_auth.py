"""Tests for authentication middleware."""

import pytest
import os
from app.auth import verify_key, check_rate, _hash, init_keys, RATE_LIMIT


class TestKeyVerification:
    def test_valid_key(self, monkeypatch):
        monkeypatch.setenv("API_KEY", "test-secret-key-123")
        from app.auth import _keys
        _keys.clear()
        _keys.add(_hash("test-secret-key-123"))
        assert verify_key("test-secret-key-123")

    def test_invalid_key(self, monkeypatch):
        from app.auth import _keys
        _keys.clear()
        _keys.add(_hash("real-key"))
        assert not verify_key("wrong-key")

    def test_empty_key(self):
        from app.auth import _keys
        _keys.clear()
        _keys.add(_hash("real-key"))
        assert not verify_key("")


class TestRateLimit:
    def test_under_limit(self, monkeypatch):
        from app.auth import _rate
        _rate.clear()
        monkeypatch.setenv("API_KEY", "rate-test")
        from app.auth import _keys
        _keys.clear()
        _keys.add(_hash("rate-test"))
        for _ in range(5):
            assert check_rate("rate-test")

    def test_over_limit(self, monkeypatch):
        from app.auth import _rate, _keys
        _rate.clear()
        _keys.clear()
        _keys.add(_hash("rate-test-2"))
        # Exhaust rate limit
        for _ in range(RATE_LIMIT):
            check_rate("rate-test-2")
        # Next one should fail
        assert not check_rate("rate-test-2")


class TestInitKeys:
    def test_auto_generates_key(self, monkeypatch):
        monkeypatch.delenv("API_KEY", raising=False)
        monkeypatch.delenv("API_KEYS", raising=False)
        from app.auth import _keys
        _keys.clear()
        init_keys()
        assert len(_keys) == 1

    def test_loads_from_env(self, monkeypatch):
        monkeypatch.setenv("API_KEYS", "key1,key2,key3")
        monkeypatch.delenv("API_KEY", raising=False)
        from app.auth import _keys
        _keys.clear()
        init_keys()
        assert len(_keys) == 3

    def test_loads_single_key(self, monkeypatch):
        monkeypatch.setenv("API_KEY", "single-key")
        monkeypatch.delenv("API_KEYS", raising=False)
        from app.auth import _keys
        _keys.clear()
        init_keys()
        assert len(_keys) == 1
        assert verify_key("single-key")
