"""
Memory Manager — short-term session buffer + optional long-term file persistence.
"""

from __future__ import annotations
import json, time
from pathlib import Path


class MemoryManager:
    def __init__(self, short_term: str = "sliding-window",
                 long_term: str = "file-based",
                 window_size: int = 20,
                 storage_dir: str = ".agent_memory"):
        self.lt_strategy = long_term
        self.window_size = window_size
        self.dir = Path(storage_dir)
        self.dir.mkdir(parents=True, exist_ok=True)
        self._msgs: list[dict] = []
        self._sid = str(int(time.time()))

    # ── short-term ────────────────────────────
    def add(self, msg: dict):
        self._msgs.append(msg)

    def get_all(self) -> list[dict]:
        return list(self._msgs)

    def clear(self):
        self._msgs.clear()
        self._sid = str(int(time.time()))

    # ── long-term ─────────────────────────────
    def save(self, key: str, data: dict):
        if self.lt_strategy == "none":
            return
        p = self.dir / f"{key}.json"
        existing = []
        if p.exists():
            try: existing = json.loads(p.read_text())
            except Exception: pass
        existing.append({"ts": time.time(), "data": data})
        p.write_text(json.dumps(existing, ensure_ascii=False, indent=2))

    def recall(self, key: str, limit: int = 5) -> list[dict]:
        if self.lt_strategy == "none":
            return []
        results = []
        for f in self.dir.glob(f"*{key}*.json"):
            try: results.extend(json.loads(f.read_text())[-limit:])
            except Exception: pass
        return sorted(results, key=lambda x: x.get("ts", 0), reverse=True)[:limit]

    def end_session(self):
        summary = "\n".join(
            f"[{m.get('role','?')}] {m.get('content','')[:200]}"
            for m in self._msgs if m.get("content")
        )[-3000:]
        if summary:
            self.save(f"session_{self._sid}", {"summary": summary})
        self.clear()
