"""
FastAPI Server — serves the visual builder at / and the agent API at /api/*.
Includes: auth, rate limiting, structured logging, health checks, WS heartbeat.
"""

from __future__ import annotations
import json, os, logging, time, asyncio
from pathlib import Path
from contextlib import asynccontextmanager
from typing import Optional

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Request
from fastapi.responses import StreamingResponse, FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from .config import AgentConfig, load_config, validate_llm
from .agent import Agent
from .auth import AuthMiddleware, init_keys

# ── Logging ────────────────────────────────────
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "info").upper(),
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("agent")

BASE = Path(__file__).resolve().parent.parent
agent: Optional[Agent] = None
CONFIG_PATH = os.getenv("CONFIG_PATH", str(BASE / "config.json"))
START_TIME = time.time()


@asynccontextmanager
async def lifespan(app: FastAPI):
    global agent
    # Init auth keys
    init_keys()

    # Load config
    cfg = load_config(CONFIG_PATH if Path(CONFIG_PATH).exists() else None)

    # Validate LLM connectivity
    ok, msg = await validate_llm(cfg)
    if not ok:
        logger.warning(f"LLM validation: {msg} (continuing anyway)")
    else:
        logger.info(f"LLM connectivity: OK")

    agent = Agent(cfg)
    logger.info(f"Agent [{cfg.name}] ready — model={cfg.model.name} tools={agent.tools.names()} compress={cfg.context.compression} mode={cfg.orchestration.mode}")
    yield
    logger.info("Agent shutting down")


app = FastAPI(title="AI Agent Builder", version="1.0.0", lifespan=lifespan)

# ── Middleware ──────────────────────────────────
app.add_middleware(AuthMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Request logging middleware ──────────────────
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    elapsed = time.time() - start
    if not request.url.path.startswith("/static"):
        logger.info(f"{request.method} {request.url.path} → {response.status_code} ({elapsed:.3f}s)")
    return response


# ── Models ─────────────────────────────────────
class ChatReq(BaseModel):
    message: str
    stream: bool = True

class ConfigReq(BaseModel):
    config: dict


# ── Public endpoints (exempt from auth) ────────
@app.get("/")
async def index():
    return FileResponse(BASE / "static" / "index.html")

@app.get("/health")
async def health():
    """Liveness probe — always returns 200 if process is up."""
    return {"status": "ok", "uptime": int(time.time() - START_TIME)}

@app.get("/ready")
async def ready():
    """Readiness probe — checks agent + LLM connectivity."""
    if not agent:
        return JSONResponse({"status": "not_ready", "reason": "Agent not initialized"}, status_code=503)
    ok, msg = await validate_llm(agent.config)
    if not ok:
        return JSONResponse({"status": "not_ready", "reason": msg}, status_code=503)
    return {"status": "ready", "model": agent.config.model.name,
            "tools": agent.tools.names(), "usage": agent.usage}


# ── Protected endpoints (require auth) ─────────
@app.get("/api/config")
async def get_config():
    if not agent:
        raise HTTPException(503, "Agent not initialized")
    cfg = agent.config.model_dump()
    # Redact API key
    cfg["model"]["api_key"] = "***" if cfg["model"]["api_key"] else ""
    return cfg


@app.post("/api/config")
async def update_config(req: ConfigReq):
    """Hot-reload config. API key is NOT accepted from request body."""
    global agent
    try:
        cfg = AgentConfig(**req.config)
        # Validate LLM before switching
        ok, msg = await validate_llm(cfg)
        if not ok:
            raise HTTPException(400, f"LLM validation failed: {msg}")

        new_agent = Agent(cfg)
        # Atomic swap
        agent = new_agent

        # Persist config (without API key)
        safe_cfg = req.config.copy()
        if "model" in safe_cfg:
            safe_cfg["model"].pop("api_key", None)
        tmp = CONFIG_PATH + ".tmp"
        Path(tmp).write_text(json.dumps(safe_cfg, ensure_ascii=False, indent=2))
        Path(tmp).rename(CONFIG_PATH)

        logger.info(f"Config reloaded — model={cfg.model.name} tools={new_agent.tools.names()}")
        return {"status": "ok", "message": "Agent reloaded",
                "tools": new_agent.tools.names(), "model": cfg.model.name}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Config reload failed: {e}")
        raise HTTPException(400, str(e))


@app.post("/api/chat")
async def chat(req: ChatReq):
    if not agent:
        raise HTTPException(503, "Agent not initialized")
    if req.stream:
        async def sse():
            async for ev in agent.run(req.message):
                yield f"data: {json.dumps(ev, ensure_ascii=False)}\n\n"
            yield "data: [DONE]\n\n"
        return StreamingResponse(sse(), media_type="text/event-stream")
    result = await agent.run_sync(req.message)
    return {"response": result, "usage": agent.usage}


@app.websocket("/api/ws")
async def ws_chat(ws: WebSocket):
    # Auth via query param
    key = ws.query_params.get("key", "")
    from .auth import verify_key
    if not verify_key(key):
        await ws.close(code=4003, reason="Invalid API key")
        return

    await ws.accept()
    if not agent:
        await ws.send_json({"type": "error", "content": "Agent not ready"})
        await ws.close()
        return

    # Start heartbeat
    heartbeat_task = asyncio.create_task(_ws_heartbeat(ws))

    try:
        while True:
            raw = await ws.receive_text()
            try:
                msg = json.loads(raw).get("message", raw)
            except json.JSONDecodeError:
                msg = raw

            logger.info(f"WS message: {msg[:100]}")
            async for ev in agent.run(msg):
                await ws.send_json(ev)
            await ws.send_json({"type": "turn_end", "usage": agent.usage})

    except WebSocketDisconnect:
        logger.info("WS client disconnected")
    except Exception as e:
        logger.error(f"WS error: {e}")
        try:
            await ws.send_json({"type": "error", "content": str(e)})
        except Exception:
            pass
    finally:
        heartbeat_task.cancel()


async def _ws_heartbeat(ws: WebSocket):
    """Send ping every 30s to keep connection alive through proxies."""
    while True:
        await asyncio.sleep(30)
        try:
            await ws.send_json({"type": "ping"})
        except Exception:
            break


@app.post("/api/session/reset")
async def reset():
    if agent:
        agent.memory.clear()
    return {"status": "ok"}


@app.get("/api/session/history")
async def history():
    if not agent:
        raise HTTPException(503)
    return {"messages": agent.memory.get_all()}


# ── Entrypoint ─────────────────────────────────
def main():
    import uvicorn
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8080"))
    logger.info(f"AI Agent Builder → http://{host}:{port}")
    logger.info(f"API docs → http://{host}:{port}/docs")
    logger.info(f"WebSocket → ws://{host}:{port}/api/ws?key=<your-api-key>")
    uvicorn.run(app, host=host, port=port, log_level=os.getenv("LOG_LEVEL", "info"))


if __name__ == "__main__":
    main()
