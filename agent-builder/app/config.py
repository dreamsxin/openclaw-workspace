"""
Configuration model + loader.
LLM API Key comes ONLY from env vars — never from JSON config.
Validates LLM connectivity on startup.
"""

from __future__ import annotations
import json, os, asyncio
from pathlib import Path
from pydantic import BaseModel, Field, field_validator
from typing import Optional
import httpx


class ModelConfig(BaseModel):
    provider: str = "openai"
    base_url: str = "https://api.openai.com/v1"
    api_key: str = ""          # injected from env, never from JSON
    name: str = "gpt-4o"
    reasoning_model: Optional[str] = None
    temperature: float = 0.7
    max_tokens: int = 4096
    top_p: float = 1.0

    @field_validator("temperature")
    @classmethod
    def temp_range(cls, v):
        if not 0 <= v <= 2:
            raise ValueError("temperature must be 0-2")
        return v

    @field_validator("max_tokens")
    @classmethod
    def max_tok_range(cls, v):
        if not 1 <= v <= 1_000_000:
            raise ValueError("max_tokens must be 1-1000000")
        return v


class ToolConfig(BaseModel):
    id: str
    name: str = ""
    enabled: bool = True
    retries: int = 3
    timeout: int = 30

    @field_validator("timeout")
    @classmethod
    def timeout_range(cls, v):
        if not 1 <= v <= 300:
            raise ValueError("timeout must be 1-300s")
        return v


class ContextConfig(BaseModel):
    compression: str = "hierarchical"
    window_size: int = 20
    max_context_tokens: int = 128000

    @field_validator("compression")
    @classmethod
    def valid_strategy(cls, v):
        valid = {"none", "sliding-window", "summary", "hierarchical", "importance", "token-budget"}
        if v not in valid:
            raise ValueError(f"compression must be one of {valid}")
        return v


class MemoryConfig(BaseModel):
    short_term: str = "sliding-window"
    long_term: str = "file-based"
    window_size: int = 20


class OrchestrationConfig(BaseModel):
    mode: str = "react"
    max_iterations: int = 10
    timeout: int = 300

    @field_validator("mode")
    @classmethod
    def valid_mode(cls, v):
        if v not in {"react", "plan-execute", "chain"}:
            raise ValueError(f"mode must be react|plan-execute|chain")
        return v

    @field_validator("max_iterations")
    @classmethod
    def iter_range(cls, v):
        if not 1 <= v <= 50:
            raise ValueError("max_iterations must be 1-50")
        return v


class SafetyConfig(BaseModel):
    level: str = "balanced"
    system_prompt: str = ""

    @field_validator("level")
    @classmethod
    def valid_level(cls, v):
        if v not in {"strict", "balanced", "relaxed"}:
            raise ValueError(f"level must be strict|balanced|relaxed")
        return v


class AgentConfig(BaseModel):
    name: str = "AI Agent"
    model: ModelConfig = Field(default_factory=ModelConfig)
    tools: list[ToolConfig] = Field(default_factory=list)
    context: ContextConfig = Field(default_factory=ContextConfig)
    memory: MemoryConfig = Field(default_factory=MemoryConfig)
    orchestration: OrchestrationConfig = Field(default_factory=OrchestrationConfig)
    safety: SafetyConfig = Field(default_factory=SafetyConfig)


# ── LLM connectivity check ─────────────────────

async def validate_llm(config: AgentConfig) -> tuple[bool, str]:
    """Ping the LLM endpoint to verify key + connectivity."""
    if not config.model.api_key:
        return False, "No LLM API key configured (set OPENAI_API_KEY env var)"

    try:
        async with httpx.AsyncClient(timeout=10) as c:
            r = await c.get(
                f"{config.model.base_url}/models",
                headers={"Authorization": f"Bearer {config.model.api_key}"},
            )
            if r.status_code == 401:
                return False, "LLM API key is invalid (401 Unauthorized)"
            if r.status_code == 403:
                return False, "LLM API key forbidden (403)"
            if r.status_code >= 500:
                return False, f"LLM endpoint error ({r.status_code})"
            return True, "OK"
    except httpx.ConnectError:
        return False, f"Cannot connect to {config.model.base_url}"
    except httpx.TimeoutException:
        return False, "LLM endpoint timeout"
    except Exception as e:
        return False, f"LLM check failed: {e}"


# ── Loaders ────────────────────────────────────

def load_config(path: str | Path | None = None) -> AgentConfig:
    if path and Path(path).exists():
        raw = json.loads(Path(path).read_text())
        return _parse_exported(raw)
    return _from_env()


def _from_env() -> AgentConfig:
    return AgentConfig(
        model=ModelConfig(
            api_key=os.getenv("OPENAI_API_KEY", ""),
            base_url=os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1"),
            name=os.getenv("MODEL_NAME", "gpt-4o"),
        ),
        safety=SafetyConfig(level=os.getenv("SAFETY_LEVEL", "balanced")),
    )


def _parse_exported(raw: dict) -> AgentConfig:
    """Parse JSON from the visual builder. API key is NOT read from JSON."""
    a = raw.get("agent", {})
    o = raw.get("orchestration", {})
    t = raw.get("tools", [])
    c = raw.get("context", {})
    m = c.get("memory", {})

    mp = {}
    for n in raw.get("workflow", {}).get("nodes", []):
        if n.get("type") == "llm":
            mp = n.get("config", {}).get("params", {})
            break

    return AgentConfig(
        name=a.get("name", "AI Agent"),
        model=ModelConfig(
            api_key=os.getenv("OPENAI_API_KEY", ""),       # env only!
            base_url=os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1"),
            name=a.get("model", "gpt-4o"),
            reasoning_model=a.get("reasoningModel"),
            temperature=mp.get("temperature", 0.7),
            max_tokens=mp.get("maxTokens", 4096),
            top_p=mp.get("topP", 1.0),
        ),
        tools=[ToolConfig(id=ti["id"], name=ti.get("name", ti["id"]),
                          retries=ti.get("retries", 3), timeout=ti.get("timeout", 30))
               for ti in t],
        context=ContextConfig(
            compression=c.get("compression", "hierarchical"),
            window_size=m.get("windowSize", 20),
        ),
        memory=MemoryConfig(
            short_term=m.get("shortTerm", "sliding-window"),
            long_term=m.get("longTerm", "file-based"),
            window_size=m.get("windowSize", 20),
        ),
        orchestration=OrchestrationConfig(
            mode=o.get("type", o.get("mode", "react")),
            max_iterations=o.get("maxIterations", 10),
            timeout=o.get("timeout", 300),
        ),
        safety=SafetyConfig(
            level=a.get("safetyLevel", "balanced"),
            system_prompt=a.get("systemPrompt", ""),
        ),
    )
