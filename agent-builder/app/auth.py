"""
Authentication middleware — Bearer token / API Key.
"""

from __future__ import annotations
import os, hashlib, secrets, time
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware


# ── API Keys storage ───────────────────────────
# Keys stored as sha256 hashes in memory. Plaintext never logged.
_keys: set[str] = set()
# Rate limit: {key_hash: [timestamps]}
_rate: dict[str, list[float]] = {}
RATE_LIMIT = 60        # requests per window
RATE_WINDOW = 60.0     # seconds


def _hash(key: str) -> str:
    return hashlib.sha256(key.encode()).hexdigest()


def init_keys():
    """Load API keys from env on startup."""
    raw = os.getenv("API_KEYS", "")
    if raw:
        for k in raw.split(","):
            k = k.strip()
            if k:
                _keys.add(_hash(k))

    # Also accept single key
    single = os.getenv("API_KEY", "")
    if single:
        _keys.add(_hash(single))

    if not _keys:
        # Auto-generate one for dev convenience
        auto = secrets.token_urlsafe(32)
        _keys.add(_hash(auto))
        print(f"⚠️  No API_KEYS set. Auto-generated key:")
        print(f"   API_KEY={auto}")
        print(f"   (Set API_KEYS env var for production)")


def verify_key(key: str) -> bool:
    return _hash(key) in _keys


def check_rate(key: str) -> bool:
    """Return True if under rate limit."""
    h = _hash(key)
    now = time.time()
    bucket = _rate.setdefault(h, [])
    # Prune old entries
    bucket[:] = [t for t in bucket if now - t < RATE_WINDOW]
    if len(bucket) >= RATE_LIMIT:
        return False
    bucket.append(now)
    return True


# ── Middleware ──────────────────────────────────
EXEMPT_PATHS = {"/", "/health", "/ready", "/docs", "/openapi.json", "/favicon.ico"}


class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        path = request.url.path

        # Exempt public paths
        if path in EXEMPT_PATHS or path.startswith("/static"):
            return await call_next(request)

        # Extract Bearer token
        auth = request.headers.get("Authorization", "")
        token = None
        if auth.startswith("Bearer "):
            token = auth[7:]
        elif "x-api-key" in request.headers:
            token = request.headers["x-api-key"]
        # Also check query param for WebSocket
        elif "key" in request.query_params:
            token = request.query_params["key"]

        if not token:
            return JSONResponse(
                {"error": "Missing API key. Use Authorization: Bearer <key> or x-api-key header."},
                status_code=401)

        if not verify_key(token):
            return JSONResponse(
                {"error": "Invalid API key."},
                status_code=403)

        if not check_rate(token):
            return JSONResponse(
                {"error": f"Rate limit exceeded. {RATE_LIMIT} req/{RATE_WINDOW}s."},
                status_code=429)

        return await call_next(request)
