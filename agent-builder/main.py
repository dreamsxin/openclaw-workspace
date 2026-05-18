#!/usr/bin/env python3
"""
AI Agent Builder — visual builder + deployable server in one.

Usage:
    python main.py                      # Start server (serves builder UI + agent API)
    python main.py --config my.json     # Load specific config
    python main.py --port 9000          # Custom port
"""

import argparse, os


def main():
    p = argparse.ArgumentParser(description="AI Agent Builder & Server")
    p.add_argument("--config", default="config.json")
    p.add_argument("--host", default=None)
    p.add_argument("--port", type=int, default=None)
    args = p.parse_args()

    os.environ["CONFIG_PATH"] = args.config
    if args.host:
        os.environ["HOST"] = args.host
    if args.port:
        os.environ["PORT"] = str(args.port)

    from app.server import main as serve
    serve()


if __name__ == "__main__":
    main()
