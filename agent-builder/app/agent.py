"""
Agent Core — ReAct orchestration loop with streaming, retry, and token counting.
"""

from __future__ import annotations
import json, time, asyncio
from typing import AsyncGenerator
from openai import AsyncOpenAI
from .config import AgentConfig
from .tools import ToolRegistry
from .context import ContextManager
from .memory import MemoryManager


# ── Token counting ─────────────────────────────
try:
    import tiktoken
    _enc = tiktoken.get_encoding("cl100k_base")
    def count_tokens(text: str) -> int:
        return len(_enc.encode(text))
except ImportError:
    def count_tokens(text: str) -> int:
        return len(text) // 3  # rough fallback


# ── Retry helper ───────────────────────────────
async def retry_call(coro_factory, max_retries=3, base_delay=1.0):
    """Exponential backoff retry for transient errors."""
    last_err = None
    for attempt in range(max_retries + 1):
        try:
            return await coro_factory()
        except Exception as e:
            last_err = e
            err_str = str(e).lower()
            # Only retry on transient errors
            is_transient = any(k in err_str for k in (
                "429", "500", "502", "503", "rate limit",
                "timeout", "connection", "overloaded"))
            if not is_transient or attempt == max_retries:
                raise
            delay = base_delay * (2 ** attempt) + (0.1 * attempt)
            await asyncio.sleep(delay)
    raise last_err


class Agent:
    def __init__(self, config: AgentConfig):
        self.config = config
        self.client = AsyncOpenAI(api_key=config.model.api_key,
                                  base_url=config.model.base_url)
        self.tools   = ToolRegistry.from_config(config.tools)
        self.context = ContextManager(strategy=config.context.compression,
                                      max_tokens=config.context.max_context_tokens,
                                      window_size=config.context.window_size,
                                      counter=count_tokens)
        self.memory  = MemoryManager(short_term=config.memory.short_term,
                                     long_term=config.memory.long_term,
                                     window_size=config.memory.window_size)
        self._sys = self._build_system()
        self._usage = {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0}

    def _build_system(self) -> str:
        s = self.config.safety
        parts = [s.system_prompt or "You are a helpful AI assistant with tools.",
                 f"\nAvailable tools: {', '.join(self.tools.names()) or 'none'}"]
        if s.level == "strict":
            parts.append("SAFETY: STRICT. Never run destructive commands. Confirm before external actions.")
        elif s.level == "balanced":
            parts.append("SAFETY: BALANCED. Be cautious. Ask before destructive ops.")
        parts.append("Use tools when needed. When done, give a final answer.")
        return "\n".join(parts)

    @property
    def usage(self) -> dict:
        return dict(self._usage)

    # ── main loop ──────────────────────────────
    async def run(self, user_input: str) -> AsyncGenerator[dict, None]:
        self.memory.add({"role": "user", "content": user_input})
        max_iter = self.config.orchestration.max_iterations
        timeout  = self.config.orchestration.timeout
        t0 = time.time()

        for iteration in range(max_iter):
            if time.time() - t0 > timeout:
                yield {"type": "error", "content": f"Timeout ({timeout}s)"}
                return

            msgs = self._build_messages()

            try:
                resp = await retry_call(
                    lambda: self.client.chat.completions.create(
                        model=self.config.model.name, messages=msgs,
                        tools=self.tools.schemas() or None,
                        tool_choice="auto" if self.tools.names() else None,
                        temperature=self.config.model.temperature,
                        max_tokens=self.config.model.max_tokens,
                        top_p=self.config.model.top_p, stream=True),
                    max_retries=3)

                full, calls = "", []
                async for chunk in resp:
                    d = chunk.choices[0].delta if chunk.choices else None
                    if not d:
                        continue
                    if d.content:
                        full += d.content
                        yield {"type": "token", "content": d.content}
                    if d.tool_calls:
                        for tc in d.tool_calls:
                            i = tc.index or 0
                            while len(calls) <= i:
                                calls.append({"id": "", "name": "", "args": ""})
                            if tc.id:
                                calls[i]["id"] = tc.id
                            if tc.function:
                                if tc.function.name:
                                    calls[i]["name"] = tc.function.name
                                if tc.function.arguments:
                                    calls[i]["args"] += tc.function.arguments

                # Update token usage estimate
                prompt_toks = sum(count_tokens(m.get("content", "")) for m in msgs)
                compl_toks = count_tokens(full)
                self._usage["prompt_tokens"] += prompt_toks
                self._usage["completion_tokens"] += compl_toks
                self._usage["total_tokens"] += prompt_toks + compl_toks

                am: dict = {"role": "assistant", "content": full or None}
                if calls:
                    am["tool_calls"] = [
                        {"id": c["id"], "type": "function",
                         "function": {"name": c["name"], "arguments": c["args"]}}
                        for c in calls]
                self.memory.add(am)

                if calls:
                    for c in calls:
                        try:
                            args = json.loads(c["args"]) if c["args"] else {}
                        except json.JSONDecodeError:
                            args = {}
                        yield {"type": "tool_call", "name": c["name"], "args": args}

                        tool = self.tools.get(c["name"])
                        if tool:
                            try:
                                result = await asyncio.wait_for(
                                    tool.run(**args), timeout=tool.timeout)
                            except asyncio.TimeoutError:
                                result = f"[Error] {c['name']} timed out ({tool.timeout}s)"
                            except Exception as e:
                                result = f"[Error] {type(e).__name__}: {e}"
                        else:
                            result = f"[Error] Unknown tool: {c['name']}"

                        yield {"type": "tool_result",
                               "name": c["name"], "content": result[:4000]}
                        self.memory.add({"role": "tool",
                                         "tool_call_id": c["id"],
                                         "content": result[:4000]})
                    continue
                else:
                    yield {"type": "done", "content": full,
                           "usage": self._usage}
                    return

            except Exception as e:
                yield {"type": "error", "content": f"{type(e).__name__}: {e}"}
                return

        yield {"type": "error", "content": "Max iterations reached"}

    def _build_messages(self) -> list[dict]:
        raw = [{"role": "system", "content": self._sys}]
        raw.extend(self.memory.get_all())
        return self.context.compress(raw)

    # ── convenience ────────────────────────────
    async def run_sync(self, text: str) -> str:
        out = []
        async for ev in self.run(text):
            if ev["type"] == "token":
                out.append(ev["content"])
            elif ev["type"] == "done":
                return ev["content"]
            elif ev["type"] == "error":
                return f"[Error] {ev['content']}"
        return "".join(out)
