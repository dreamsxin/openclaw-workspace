"""Pytest configuration."""

import os
import sys

# Ensure app is importable
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Set test env defaults
os.environ.setdefault("OPENAI_API_KEY", "sk-test-dummy")
os.environ.setdefault("API_KEY", "test-api-key")
os.environ.setdefault("ALLOWED_PATHS", "/tmp/agent_test")
