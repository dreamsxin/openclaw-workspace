"""Interactive configuration wizard with CJK-aware auto-detection."""

from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Any, Optional

from rich.console import Console
from rich.panel import Panel
from rich.prompt import Confirm, IntPrompt, Prompt
from rich.table import Table

from rag_builder.config import (
    ChunkConfig,
    EmbedderConfig,
    EmbedderType,
    LLMConfig,
    LLMProvider,
    ProjectConfig,
    RetrieverConfig,
    VectorStoreConfig,
    VectorStoreType,
)

console = Console()

# ── Preset definitions ──────────────────────────────────────────────

LLM_PRESETS: dict[str, dict[str, Any]] = {
    "openai": {
        "label": "OpenAI",
        "models": [
            ("gpt-4o-mini", "快速、便宜，适合大多数场景"),
            ("gpt-4o", "最强推理能力"),
            ("gpt-3.5-turbo", "最便宜，简单问答"),
        ],
        "needs_key": True,
        "key_env": "OPENAI_API_KEY",
    },
    "deepseek": {
        "label": "DeepSeek",
        "models": [
            ("deepseek-chat", "性价比高，中文优秀"),
            ("deepseek-reasoner", "推理能力强"),
        ],
        "needs_key": True,
        "key_env": "DEEPSEEK_API_KEY",
        "default_base_url": "https://api.deepseek.com/v1",
    },
    "ollama": {
        "label": "Ollama (本地)",
        "models": [
            ("qwen2.5:7b", "中文优秀，推荐"),
            ("qwen2.5:14b", "更强，需要更多显存"),
            ("llama3.1:8b", "英文通用"),
            ("deepseek-r1:7b", "推理能力强"),
        ],
        "needs_key": False,
        "key_env": None,
        "default_base_url": "http://localhost:11434/v1",
    },
}

EMBEDDER_PRESETS: dict[str, dict[str, Any]] = {
    "openai": {
        "label": "OpenAI",
        "models": [
            ("text-embedding-3-small", "快速便宜，英文为主"),
            ("text-embedding-3-large", "更高精度"),
        ],
        "needs_key": True,
        "dimensions": 1536,
    },
    "bge": {
        "label": "BGE (中文优化)",
        "models": [
            ("BAAI/bge-large-zh-v1.5", "中文高精度，推荐"),
            ("BAAI/bge-small-zh-v1.5", "中文轻量，速度快"),
            ("BAAI/bge-m3", "多语言，中英混合场景"),
        ],
        "needs_key": False,
        "dimensions": 1024,
    },
    "jina": {
        "label": "Jina",
        "models": [
            ("jina-embeddings-v3", "多语言高质量"),
        ],
        "needs_key": True,
        "dimensions": 1024,
    },
}

VECTORSTORE_PRESETS = [
    ("chroma", "ChromaDB", "零配置，自动持久化，推荐入门"),
    ("faiss", "FAISS", "纯本地，高性能，适合大数据量"),
]

# ── CJK detection ───────────────────────────────────────────────────

_CJK_RE = re.compile(r"[\u4e00-\u9fff\u3400-\u4dbf\u3040-\u309f\u30a0-\u30ff]")


def _detect_language(files: list[Path], sample_size: int = 10) -> str:
    """Detect predominant language by sampling files.

    Returns: 'zh', 'en', or 'mixed'
    """
    cjk_total = 0
    latin_total = 0

    for f in files[:sample_size]:
        try:
            text = f.read_text(encoding="utf-8", errors="ignore")[:5000]
            cjk_total += len(_CJK_RE.findall(text))
            latin_total += len(re.findall(r"[a-zA-Z]+", text))
        except Exception:
            continue

    if cjk_total == 0 and latin_total == 0:
        return "en"  # default

    cjk_ratio = cjk_total / (cjk_total + latin_total) if (cjk_total + latin_total) > 0 else 0

    if cjk_ratio > 0.4:
        return "zh"
    elif cjk_ratio > 0.1:
        return "mixed"
    else:
        return "en"


def _get_defaults_for_lang(lang: str) -> dict[str, str]:
    """Get recommended defaults based on detected language."""
    if lang == "zh":
        return {
            "llm": "deepseek",
            "llm_model": "deepseek-chat",
            "embedder": "bge",
            "embedder_model": "BAAI/bge-large-zh-v1.5",
            "chunk_size": "384",  # Chinese text is denser, smaller chunks work better
            "chunk_overlap": "48",
        }
    elif lang == "mixed":
        return {
            "llm": "openai",
            "llm_model": "gpt-4o-mini",
            "embedder": "bge",
            "embedder_model": "BAAI/bge-m3",
            "chunk_size": "448",
            "chunk_overlap": "56",
        }
    else:
        return {
            "llm": "openai",
            "llm_model": "gpt-4o-mini",
            "embedder": "openai",
            "embedder_model": "text-embedding-3-small",
            "chunk_size": "512",
            "chunk_overlap": "64",
        }


# ── Selection helpers ────────────────────────────────────────────────


def _select_menu(prompt: str, options: list[tuple[str, str]], default: str = "") -> str:
    """Show a numbered menu and return selected key."""
    console.print(f"\n[bold cyan]{prompt}[/]")
    for i, (key, label) in enumerate(options, 1):
        marker = "●" if key == default else "○"
        console.print(f"  [dim]{i}.[/] {marker} [bold]{key}[/] — {label}")

    while True:
        raw = Prompt.ask(
            "选择",
            default=str(next((i + 1 for i, (k, _) in enumerate(options) if k == default), 1)),
            console=console,
        )
        try:
            idx = int(raw) - 1
            if 0 <= idx < len(options):
                return options[idx][0]
        except ValueError:
            for key, _ in options:
                if raw.lower() == key.lower():
                    return key
        console.print("[red]无效选择，请重试[/]")


def _ask_api_key(provider: str, env_var: str) -> Optional[str]:
    """Ask for API key, checking env first."""
    existing = os.environ.get(env_var)
    if existing:
        console.print(f"  [dim]检测到 {env_var} = {existing[:8]}...[/]")
        if Confirm.ask("  使用此 key?", default=True):
            return None

    key = Prompt.ask(f"  输入 {provider} API Key", password=True, console=console)
    return key if key else None


# ── Main wizard ──────────────────────────────────────────────────────


def run_wizard(
    source_dir: Optional[Path] = None,
    output: Optional[Path] = None,
    project_name: Optional[str] = None,
) -> tuple[ProjectConfig, list[Path]]:
    """Run the interactive configuration wizard."""

    console.print(
        Panel(
            "[bold]🚀 rag-builder 配置向导[/]\n"
            "[dim]一步步引导你生成 RAG + Agent 知识库项目[/]",
            border_style="blue",
        )
    )

    # ── Step 1: Source directory ──
    if source_dir is None:
        while True:
            raw = Prompt.ask(
                "\n[bold cyan]📂 文档目录[/] (存放 PDF/MD/TXT/DOCX 的文件夹)",
                console=console,
            )
            source_dir = Path(raw).expanduser().resolve()
            if source_dir.exists() and source_dir.is_dir():
                break
            console.print(f"[red]✗ 目录不存在: {source_dir}[/]")

    # Scan files
    extensions = [".pdf", ".md", ".txt", ".docx", ".html", ".rst"]
    files = _scan(source_dir, extensions)

    if not files:
        console.print(f"[yellow]⚠ 在 {source_dir} 中未找到支持的文档[/]")
        raise SystemExit(1)

    # Show file breakdown
    type_counts: dict[str, int] = {}
    for f in files:
        ext = f.suffix.lower()
        type_counts[ext] = type_counts.get(ext, 0) + 1

    console.print(
        f"\n  [green]✓ 找到 {len(files)} 个文档[/] — "
        + ", ".join(f"{k}: {v}" for k, v in sorted(type_counts.items()))
    )

    for f in files[:8]:
        console.print(f"    [dim]• {f.relative_to(source_dir)}[/]")
    if len(files) > 8:
        console.print(f"    [dim]... 还有 {len(files) - 8} 个[/]")

    # ── Auto-detect language ──
    lang = _detect_language(files)
    defaults = _get_defaults_for_lang(lang)

    lang_labels = {"zh": "🇨🇳 中文为主", "en": "🇺🇸 英文为主", "mixed": "🌏 中英混合"}
    console.print(f"\n  [dim]语言检测: {lang_labels.get(lang, lang)} → 已调整默认配置[/]")

    # ── Step 2: Project name ──
    if project_name is None:
        default_name = source_dir.name.lower().replace(" ", "-")
        project_name = Prompt.ask(
            "\n[bold cyan]📝 项目名称[/]",
            default=default_name,
            console=console,
        )

    # ── Step 3: Output directory ──
    if output is None:
        output = Path(
            Prompt.ask(
                "[bold cyan]📁 输出目录[/]",
                default="./output",
                console=console,
            )
        )

    # ── Step 4: LLM provider ──
    llm_options = [(k, v["label"]) for k, v in LLM_PRESETS.items()]
    llm_choice = _select_menu(
        "🧠 LLM 大语言模型",
        llm_options,
        default=defaults["llm"],
    )
    llm_preset = LLM_PRESETS[llm_choice]

    # LLM model
    model_options = [(m[0], m[1]) for m in llm_preset["models"]]
    llm_model = _select_menu(
        "  选择模型",
        model_options,
        default=defaults["llm_model"],
    )

    # API key
    llm_api_key = None
    llm_base_url = None
    if llm_preset["needs_key"]:
        env_var = llm_preset.get("key_env", "OPENAI_API_KEY")
        llm_api_key = _ask_api_key(llm_preset["label"], env_var)
        if "default_base_url" in llm_preset:
            llm_base_url = llm_preset["default_base_url"]
    else:
        default_url = llm_preset.get("default_base_url", "")
        llm_base_url = Prompt.ask("  Ollama 地址", default=default_url, console=console)

    # ── Step 5: Embedder ──
    emb_options = [(k, v["label"]) for k, v in EMBEDDER_PRESETS.items()]
    emb_choice = _select_menu(
        "📐 Embedding 模型",
        emb_options,
        default=defaults["embedder"],
    )
    emb_preset = EMBEDDER_PRESETS[emb_choice]

    emb_model_options = [(m[0], m[1]) for m in emb_preset["models"]]
    emb_model = _select_menu(
        "  选择模型",
        emb_model_options,
        default=defaults["embedder_model"],
    )

    emb_api_key = None
    if emb_preset["needs_key"]:
        if llm_choice == "openai" and emb_choice == "openai" and llm_api_key is None:
            console.print("  [dim]复用 OpenAI LLM 的 key[/]")
        else:
            emb_api_key = _ask_api_key(emb_preset["label"], "OPENAI_API_KEY")

    # ── Step 6: Vector store ──
    vs_options = [(k, label) for k, label, _ in VECTORSTORE_PRESETS]
    vs_choice = _select_menu("💾 向量数据库", vs_options, default="chroma")
    vs_desc = next(d for k, _, d in VECTORSTORE_PRESETS if k == vs_choice)
    console.print(f"  [dim]{vs_desc}[/]")

    # ── Step 7: Agent & Frontend ──
    console.print("\n[bold cyan]🤖 功能模块[/]")
    with_agent = Confirm.ask("  启用 Agent (工具调用 + 多轮推理)?", default=True)
    with_frontend = Confirm.ask("  生成 Streamlit Web UI?", default=True)

    # ── Step 8: Advanced settings ──
    console.print(
        f"\n[bold cyan]⚙️  高级设置[/] [dim](回车使用默认值 — 已根据{lang_labels[lang][5:]}调整)[/]"
    )
    chunk_size = IntPrompt.ask(
        "  分块大小 (tokens)",
        default=int(defaults["chunk_size"]),
        console=console,
    )
    chunk_overlap = IntPrompt.ask(
        "  分块重叠 (tokens)",
        default=int(defaults["chunk_overlap"]),
        console=console,
    )
    top_k = IntPrompt.ask("  检索数量 (top_k)", default=5, console=console)

    # ── Build config ──
    config = ProjectConfig(
        project_name=project_name,
        source_dir=str(source_dir),
        output_dir=str(output),
        llm=LLMConfig(
            provider=LLMProvider(llm_choice),
            model=llm_model,
            api_key=llm_api_key,
            base_url=llm_base_url,
        ),
        embedder=EmbedderConfig(
            provider=EmbedderType(emb_choice),
            model=emb_model,
            api_key=emb_api_key or llm_api_key,
            dimensions=emb_preset["dimensions"],
        ),
        vectorstore=VectorStoreConfig(store_type=VectorStoreType(vs_choice)),
        chunk=ChunkConfig(chunk_size=chunk_size, chunk_overlap=chunk_overlap),
        retriever=RetrieverConfig(top_k=top_k),
        with_agent=with_agent,
        with_frontend=with_frontend,
    )

    return config, files


def _scan(source_dir: Path, extensions: list[str]) -> list[Path]:
    """Recursively find documents."""
    files = []
    for ext in extensions:
        files.extend(source_dir.rglob(f"*{ext}"))
    files.sort()
    return files
