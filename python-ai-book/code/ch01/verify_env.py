"""环境验证脚本 — 运行此脚本确认开发环境正常"""

import sys
import importlib


def check_package(name):
    try:
        mod = importlib.import_module(name)
        version = getattr(mod, "__version__", "unknown")
        print(f"  ✅ {name} ({version})")
        return True
    except ImportError:
        print(f"  ❌ {name} — 未安装")
        return False


def main():
    print(f"Python {sys.version}\n")

    packages = [
        "anthropic",
        "openai",
        "httpx",
        "ollama",
        "rich",
        "pydantic",
        "dotenv",
    ]

    print("核心依赖检查：")
    results = [check_package(p) for p in packages]

    print(f"\n{'全部通过 ✅' if all(results) else '部分依赖缺失 ❌'}")
    if not all(results):
        print("请运行: pip install -r requirements.txt")


if __name__ == "__main__":
    main()
