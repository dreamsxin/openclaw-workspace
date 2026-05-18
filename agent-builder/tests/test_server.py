"""Integration tests for the API server."""

import pytest
import os
import json

os.environ.setdefault("OPENAI_API_KEY", "sk-test-dummy")
os.environ.setdefault("API_KEY", "test-api-key")

from app.auth import _keys, _hash
_keys.add(_hash("test-api-key"))

from fastapi.testclient import TestClient
from app.server import app


@pytest.fixture
def client():
    # Ensure init_keys runs (lifespan may not trigger in all test modes)
    from app.auth import init_keys
    init_keys()
    return TestClient(app, raise_server_exceptions=False)


@pytest.fixture
def auth_headers():
    return {"Authorization": "Bearer test-api-key"}


# In test env, agent may not initialize (no real LLM key).
# Auth tests check 401/403 vs "authenticated" (200 or 503).
AUTHENTICATED = (200, 503)


class TestPublicEndpoints:
    def test_health(self, client):
        r = client.get("/health")
        assert r.status_code == 200
        assert r.json()["status"] == "ok"

    def test_ready(self, client):
        r = client.get("/ready")
        assert r.status_code in (200, 503)
        assert "status" in r.json()

    def test_index(self, client):
        r = client.get("/")
        assert r.status_code == 200


class TestAuth:
    def test_no_key_returns_401(self, client):
        r = client.get("/api/config")
        assert r.status_code == 401

    def test_wrong_key_returns_403(self, client):
        r = client.get("/api/config", headers={"Authorization": "Bearer wrong-key"})
        assert r.status_code == 403

    def test_valid_key_passes_auth(self, client, auth_headers):
        r = client.get("/api/config", headers=auth_headers)
        assert r.status_code in AUTHENTICATED

    def test_x_api_key_header(self, client):
        r = client.get("/api/config", headers={"x-api-key": "test-api-key"})
        assert r.status_code in AUTHENTICATED

    def test_query_param_key(self, client):
        r = client.get("/api/config?key=test-api-key")
        assert r.status_code in AUTHENTICATED


class TestConfig:
    def test_get_config_redacts_key(self, client, auth_headers):
        r = client.get("/api/config", headers=auth_headers)
        if r.status_code == 200:
            data = r.json()
            assert data["model"]["api_key"] in ("***", "")

    def test_update_config_validates(self, client, auth_headers):
        bad_config = {"config": {"agent": {"model": "gpt-4o"}, "orchestration": {"maxIterations": -1}}}
        r = client.post("/api/config", json=bad_config, headers=auth_headers)
        assert r.status_code in (400, 503)


class TestChat:
    def test_chat_requires_auth(self, client):
        r = client.post("/api/chat", json={"message": "hello"})
        assert r.status_code == 401

    def test_chat_authenticated(self, client, auth_headers):
        r = client.post("/api/chat",
                        json={"message": "hello", "stream": False},
                        headers=auth_headers)
        assert r.status_code in AUTHENTICATED


class TestSession:
    def test_reset(self, client, auth_headers):
        r = client.post("/api/session/reset", headers=auth_headers)
        assert r.status_code in AUTHENTICATED

    def test_history(self, client, auth_headers):
        r = client.get("/api/session/history", headers=auth_headers)
        assert r.status_code in AUTHENTICATED
