"""
Context Manager — 6 compression strategies with precise token counting.
"""

from __future__ import annotations
from typing import Callable


def _default_counter(text: str) -> int:
    return len(text) // 3  # rough fallback


class ContextManager:
    def __init__(self, strategy: str = "hierarchical",
                 max_tokens: int = 128_000, window_size: int = 20,
                 counter: Callable[[str], int] | None = None):
        self.strategy = strategy
        self.max_tokens = max_tokens
        self.window_size = window_size
        self._count = counter or _default_counter

    def _msg_tokens(self, msg: dict) -> int:
        """Estimate tokens for a single message (content + overhead)."""
        content = msg.get("content", "") or ""
        # overhead: role label, separators, tool_call structure ≈ 10 tokens
        overhead = 10
        tc = msg.get("tool_calls")
        if tc:
            overhead += self._count(str(tc))
        return self._count(content) + overhead

    def _total_tokens(self, msgs: list[dict]) -> int:
        return sum(self._msg_tokens(m) for m in msgs)

    def compress(self, messages: list[dict]) -> list[dict]:
        fn = {
            "none":            self._passthrough,
            "sliding-window":  self._sliding_window,
            "summary":         self._summary,
            "hierarchical":    self._hierarchical,
            "importance":      self._importance,
            "token-budget":    self._token_budget,
        }.get(self.strategy, self._sliding_window)
        return fn(messages)

    # ── strategies ─────────────────────────────

    def _passthrough(self, m): return m

    def _sliding_window(self, msgs: list[dict]) -> list[dict]:
        sys = [m for m in msgs if m.get("role") == "system"]
        rest = [m for m in msgs if m.get("role") != "system"]
        return sys + rest[-self.window_size:]

    def _summary(self, msgs: list[dict]) -> list[dict]:
        sys = [m for m in msgs if m.get("role") == "system"]
        rest = [m for m in msgs if m.get("role") != "system"]
        if len(rest) <= self.window_size:
            return msgs
        old, recent = rest[: -self.window_size + 1], rest[-self.window_size + 1:]
        return sys + [{"role": "system",
                        "content": f"[Previous conversation summary]\n{self._brief(old)}"}] + recent

    def _hierarchical(self, msgs: list[dict]) -> list[dict]:
        sys = [m for m in msgs if m.get("role") == "system"]
        rest = [m for m in msgs if m.get("role") != "system"]
        n = len(rest)
        if n <= self.window_size:
            return msgs
        recent = rest[-self.window_size:]
        mid_s = max(0, n - self.window_size * 2)
        mid = rest[mid_s: -self.window_size]
        old = rest[:mid_s]
        parts = sys[:]
        if old:
            parts.append({"role": "system", "content": f"[Old context]\n{self._brief(old)}"})
        if mid:
            pts = [f"- {m.get('content', '').split(chr(10))[0][:120]}"
                   for m in mid[-20:] if m.get("content")]
            parts.append({"role": "system", "content": "[Key points]\n" + "\n".join(pts)})
        parts.extend(recent)

        # Final token safety check
        while self._total_tokens(parts) > self.max_tokens and len(parts) > 3:
            # Remove oldest non-system, non-recent message
            for i, m in enumerate(parts):
                if m.get("role") != "system" and i < len(parts) - self.window_size:
                    parts.pop(i)
                    break
            else:
                break

        return parts

    def _importance(self, msgs: list[dict]) -> list[dict]:
        sys = [m for m in msgs if m.get("role") == "system"]
        rest = [m for m in msgs if m.get("role") != "system"]
        if len(rest) <= self.window_size:
            return msgs
        scored = [(self._score(m), i, m) for i, m in enumerate(rest)]
        keep_recent = set(range(len(rest) - 4, len(rest)))
        scored.sort(key=lambda x: x[0], reverse=True)
        sel = set()
        for _, idx, _ in scored:
            if len(sel) >= self.window_size:
                break
            sel.add(idx)
        sel |= keep_recent
        return sys + [rest[i] for i in sorted(sel)]

    def _token_budget(self, msgs: list[dict]) -> list[dict]:
        sys = [m for m in msgs if m.get("role") == "system"]
        rest = [m for m in msgs if m.get("role") != "system"]
        budget = self.max_tokens - self._total_tokens(sys) - 500  # safety margin
        kept, total = [], 0
        for m in reversed(rest):
            cost = self._msg_tokens(m)
            if total + cost > budget:
                break
            kept.append(m)
            total += cost
        kept.reverse()
        return sys + kept

    # ── helpers ────────────────────────────────

    def _brief(self, msgs: list[dict]) -> str:
        t = "\n".join(f"{m.get('role', '?')}: {m.get('content', '')[:160]}" for m in msgs)
        return t[:2000] if len(t) > 2000 else t

    def _score(self, m: dict) -> float:
        c = m.get("content", "")
        s = 1.0 if m.get("role") == "assistant" else 2.0 if m.get("role") == "tool" else 0.0
        s += min(len(c) / 500, 3.0)
        if "```" in c:
            s += 1.5
        for kw in ("error", "decision", "important", "warning"):
            if kw in c.lower():
                s += 1.0
        return s
