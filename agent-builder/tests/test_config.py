"""Tests for config loading and validation."""

import pytest
import os
from app.config import AgentConfig, ModelConfig, load_config, _parse_exported


class TestModelConfig:
    def test_default_values(self):
        cfg = ModelConfig()
        assert cfg.name == "gpt-4o"
        assert cfg.temperature == 0.7
        assert cfg.max_tokens == 4096

    def test_temperature_range(self):
        ModelConfig(temperature=0)
        ModelConfig(temperature=2)
        with pytest.raises(Exception):
            ModelConfig(temperature=3)

    def test_max_tokens_range(self):
        ModelConfig(max_tokens=1)
        with pytest.raises(Exception):
            ModelConfig(max_tokens=0)


class TestAgentConfig:
    def test_default_config(self):
        cfg = AgentConfig()
        assert cfg.name == "AI Agent"
        assert cfg.orchestration.mode == "react"
        assert cfg.safety.level == "balanced"

    def test_parse_exported(self):
        raw = {
            "agent": {"name": "Test", "model": "gpt-4o", "safetyLevel": "strict"},
            "orchestration": {"type": "chain", "maxIterations": 5, "timeout": 60},
            "tools": [{"id": "web_search", "name": "Search"}],
            "context": {"compression": "summary", "memory": {"shortTerm": "token-budget", "windowSize": 10}},
        }
        cfg = _parse_exported(raw)
        assert cfg.name == "Test"
        assert cfg.orchestration.mode == "chain"
        assert cfg.orchestration.max_iterations == 5
        assert cfg.safety.level == "strict"
        assert len(cfg.tools) == 1
        assert cfg.context.compression == "summary"
        assert cfg.memory.window_size == 10


class TestLoadConfig:
    def test_from_env(self, monkeypatch):
        monkeypatch.setenv("OPENAI_API_KEY", "sk-test")
        monkeypatch.setenv("MODEL_NAME", "gpt-4o-mini")
        cfg = load_config()
        assert cfg.model.api_key == "sk-test"
        assert cfg.model.name == "gpt-4o-mini"

    def test_from_file(self, tmp_path):
        import json
        cfg_data = {
            "agent": {"name": "FileAgent", "model": "gpt-4o"},
            "orchestration": {"type": "react", "maxIterations": 10, "timeout": 300},
            "tools": [],
            "context": {"compression": "none", "memory": {}},
        }
        p = tmp_path / "config.json"
        p.write_text(json.dumps(cfg_data))
        cfg = load_config(str(p))
        assert cfg.name == "FileAgent"
