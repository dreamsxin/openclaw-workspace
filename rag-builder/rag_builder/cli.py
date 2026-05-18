"""CLI entry point — the main command-line interface."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional

import typer
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Confirm
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

app = typer.Typer(
    name="rag-builder",
    help="🚀 One-click RAG + Agent knowledge base generator",
    no_args_is_help=True,
)
console = Console()


# ──────────────────────────────────────────────────────────────
# init — full generation pipeline
# ──────────────────────────────────────────────────────────────


@app.command()
def init(
    source_dir: Optional[Path] = typer.Argument(
        None, help="文档目录 (省略则启动交互式向导)"
    ),
    output: Path = typer.Option("./output", "-o", "--output", help="输出目录"),
    project_name: str = typer.Option("my-rag-project", "-n", "--name", help="项目名称"),
    # LLM
    llm: str = typer.Option("openai", help="LLM: openai, ollama"),
    llm_model: str = typer.Option("gpt-4o-mini", help="LLM 模型"),
    llm_base_url: Optional[str] = typer.Option(None, help="LLM API 地址"),
    llm_api_key: Optional[str] = typer.Option(None, help="LLM API Key", envvar="LLM_API_KEY"),
    # Embedder
    embedder: str = typer.Option("openai", help="Embedder: openai, bge, jina"),
    embedder_model: str = typer.Option("text-embedding-3-small", help="Embedding 模型"),
    # Vector store
    vectorstore: str = typer.Option("chroma", help="向量数据库: chroma, faiss"),
    # Toggles
    with_agent: bool = typer.Option(True, help="启用 Agent"),
    with_frontend: bool = typer.Option(True, help="生成 Streamlit UI"),
    # Chunking
    chunk_size: int = typer.Option(512, help="分块大小 (tokens)"),
    chunk_overlap: int = typer.Option(64, help="分块重叠 (tokens)"),
    # Retrieval
    top_k: int = typer.Option(5, help="检索 top_k"),
    # Modes
    interactive: bool = typer.Option(False, "-i", "--interactive", help="启动交互式向导"),
    dry_run: bool = typer.Option(False, "--dry-run", help="仅预览，不生成"),
):
    """从文档目录生成 RAG + Agent 项目。

    不带参数运行则自动启动交互式向导：
      rag-builder init

    指定目录快速生成：
      rag-builder init ./docs -n my-kb
    """

    # Decide: wizard or direct
    use_wizard = interactive or source_dir is None

    if use_wizard:
        from rag_builder.wizard import run_wizard

        config, files = run_wizard(
            source_dir=source_dir,
            output=output if str(output) != "./output" else None,
            project_name=project_name if project_name != "my-rag-project" else None,
        )

        # Show summary and confirm
        _show_summary(config, files)

        if dry_run:
            console.print("\n[dim]Dry run — 不生成文件。[/]")
            return

        if not Confirm.ask("\n[bold]确认生成?[/]", default=True, console=console):
            console.print("[dim]已取消。[/]")
            raise typer.Exit(0)

    else:
        # ── Direct mode (non-interactive) ──
        if source_dir and not source_dir.exists():
            console.print(f"[red]✗ 目录不存在: {source_dir}[/]")
            raise typer.Exit(1)

        config = ProjectConfig(
            project_name=project_name,
            source_dir=str(source_dir),
            output_dir=str(output),
            llm=LLMConfig(
                provider=LLMProvider(llm),
                model=llm_model,
                api_key=llm_api_key,
                base_url=llm_base_url,
            ),
            embedder=EmbedderConfig(
                provider=EmbedderType(embedder),
                model=embedder_model,
            ),
            vectorstore=VectorStoreConfig(store_type=VectorStoreType(vectorstore)),
            chunk=ChunkConfig(chunk_size=chunk_size, chunk_overlap=chunk_overlap),
            retriever=RetrieverConfig(top_k=top_k),
            with_agent=with_agent,
            with_frontend=with_frontend,
        )

        files = _scan_documents(source_dir, config.supported_extensions)
        if not files:
            console.print(f"[yellow]⚠ 在 {source_dir} 中未找到支持的文档[/]")
            raise typer.Exit(1)

        _show_summary(config, files)

        if dry_run:
            console.print("\n[dim]Dry run — 不生成文件。[/]")
            return

    # ── Pipeline ──
    console.print("\n[bold]Step 1/3:[/] 解析文档...")
    chunks = _parse_and_chunk(files, config)

    console.print("[bold]Step 2/3:[/] 构建向量索引...")
    _build_index(chunks, config)

    console.print("[bold]Step 3/3:[/] 生成项目...")
    from rag_builder.generator import ProjectGenerator

    gen = ProjectGenerator(config)
    project_path = gen.generate()

    # Done
    console.print(
        Panel(
            f"[green]✓ 项目已生成:[/] {project_path}\n\n"
            f"  [bold]cd {project_path}[/]\n"
            f"  pip install -r requirements.txt\n"
            f"  # 编辑 .env 填入 API Key\n"
            f"  python main.py"
            + (f"\n  streamlit run app.py" if config.with_frontend else ""),
            title="[bold green]🎉 完成![/]",
            border_style="green",
        )
    )


# ──────────────────────────────────────────────────────────────
# index — incremental indexing for existing projects
# ──────────────────────────────────────────────────────────────


@app.command()
def index(
    source_dir: Path = typer.Argument(..., help="文档目录"),
    vectorstore_dir: str = typer.Option(
        "./vectorstore", "-d", "--dir", help="向量库存储目录"
    ),
    vectorstore: str = typer.Option("chroma", help="向量数据库: chroma, faiss"),
    embedder: str = typer.Option("openai", help="Embedder: openai, bge, jina"),
    embedder_model: str = typer.Option("text-embedding-3-small", help="Embedding 模型"),
    embedder_api_key: Optional[str] = typer.Option(
        None, help="Embedder API Key", envvar="EMBEDDER_API_KEY"
    ),
    chunk_size: int = typer.Option(512, help="分块大小"),
    chunk_overlap: int = typer.Option(64, help="分块重叠"),
    rebuild: bool = typer.Option(False, "--rebuild", help="全量重建索引（忽略增量）"),
):
    """索引文档到向量库。支持增量更新（只处理新增/修改/删除的文件）。

    \b
    增量模式（默认）:
      rag-builder index ./docs
      # 第一次：全量索引
      # 之后：只处理变化的文件

    全量重建:
      rag-builder index ./docs --rebuild
    """
    if not source_dir.exists():
        console.print(f"[red]✗ 目录不存在: {source_dir}[/]")
        raise typer.Exit(1)

    from rag_builder.indexer import full_index, incremental_index

    config = ProjectConfig(
        source_dir=str(source_dir),
        llm=LLMConfig(),  # Not needed for indexing
        embedder=EmbedderConfig(
            provider=EmbedderType(embedder),
            model=embedder_model,
            api_key=embedder_api_key,
        ),
        vectorstore=VectorStoreConfig(
            store_type=VectorStoreType(vectorstore),
            persist_dir=vectorstore_dir,
        ),
        chunk=ChunkConfig(chunk_size=chunk_size, chunk_overlap=chunk_overlap),
    )

    files = _scan_documents(source_dir, config.supported_extensions)
    if not files:
        console.print(f"[yellow]⚠ 在 {source_dir} 中未找到支持的文档[/]")
        raise typer.Exit(1)

    console.print(f"[dim]扫描到 {len(files)} 个文档[/]")

    if rebuild:
        full_index(config, files)
    else:
        incremental_index(config, files)


# ──────────────────────────────────────────────────────────────
# status — show index manifest
# ──────────────────────────────────────────────────────────────


@app.command()
def status(
    vectorstore_dir: str = typer.Argument("./vectorstore", help="向量库目录"),
):
    """查看索引状态。"""
    from rag_builder.indexer import IndexManifest

    manifest_path = Path(vectorstore_dir) / "index_manifest.json"
    manifest = IndexManifest.load(manifest_path)

    if not manifest.files:
        console.print("[yellow]⚠ 未找到索引记录[/]")
        console.print("[dim]运行 rag-builder index <文档目录> 创建索引[/]")
        return

    table = Table(title="📊 索引状态", show_lines=False)
    table.add_column("统计", style="cyan")
    table.add_column("值")

    table.add_row("文件总数", str(len(manifest.files)))
    table.add_row("分块总数", str(manifest.total_chunks))

    from datetime import datetime

    if manifest.last_updated:
        ts = datetime.fromtimestamp(manifest.last_updated).strftime("%Y-%m-%d %H:%M:%S")
        table.add_row("最后更新", ts)

    # File type breakdown
    type_counts: dict[str, int] = {}
    total_size = 0
    for rec in manifest.files.values():
        ext = Path(rec.path).suffix.lower()
        type_counts[ext] = type_counts.get(ext, 0) + 1
        total_size += rec.file_size

    table.add_row("文件类型", ", ".join(f"{k}: {v}" for k, v in sorted(type_counts.items())))
    table.add_row("总大小", f"{total_size / 1024 / 1024:.1f} MB")

    console.print(table)

    # Show file list
    console.print(f"\n[bold]已索引文件:[/]")
    for path_str, rec in sorted(manifest.files.items()):
        name = Path(path_str).name
        from datetime import datetime

        ts = datetime.fromtimestamp(rec.indexed_at).strftime("%m-%d %H:%M")
        console.print(f"  [dim]{ts}[/] {name} [dim]({rec.chunk_count} 块)[/]")


# ──────────────────────────────────────────────────────────────
# quick — one-liner presets
# ──────────────────────────────────────────────────────────────


@app.command()
def quick(
    source_dir: Path = typer.Argument(..., help="文档目录"),
    preset: str = typer.Option(
        "openai",
        "-p",
        "--preset",
        help="预设: openai, deepseek-zh, ollama-local, openai-faiss",
    ),
    output: Path = typer.Option("./output", "-o", "--output"),
    name: str = typer.Option("my-rag-project", "-n", "--name"),
):
    """用预设快速生成，无需交互。

    预设:
      openai       — OpenAI 全家桶 (默认)
      deepseek-zh  — DeepSeek + BGE 中文优化
      ollama-local — Ollama + BGE 本地模型
      openai-faiss — OpenAI + FAISS
    """
    presets = {
        "openai": ProjectConfig(
            project_name=name,
            source_dir=str(source_dir),
            output_dir=str(output),
            llm=LLMConfig(provider=LLMProvider.OPENAI, model="gpt-4o-mini"),
            embedder=EmbedderConfig(provider=EmbedderType.OPENAI, model="text-embedding-3-small"),
            vectorstore=VectorStoreConfig(store_type=VectorStoreType.CHROMA),
            with_agent=True,
            with_frontend=True,
        ),
        "deepseek-zh": ProjectConfig(
            project_name=name,
            source_dir=str(source_dir),
            output_dir=str(output),
            llm=LLMConfig(
                provider=LLMProvider.DEEPSEEK,
                model="deepseek-chat",
                base_url="https://api.deepseek.com/v1",
            ),
            embedder=EmbedderConfig(
                provider=EmbedderType.BGE,
                model="BAAI/bge-large-zh-v1.5",
                dimensions=1024,
            ),
            vectorstore=VectorStoreConfig(store_type=VectorStoreType.CHROMA),
            chunk=ChunkConfig(chunk_size=384, chunk_overlap=48),
            with_agent=True,
            with_frontend=True,
        ),
        "ollama-local": ProjectConfig(
            project_name=name,
            source_dir=str(source_dir),
            output_dir=str(output),
            llm=LLMConfig(
                provider=LLMProvider.OLLAMA,
                model="qwen2.5:7b",
                base_url="http://localhost:11434/v1",
            ),
            embedder=EmbedderConfig(
                provider=EmbedderType.BGE,
                model="BAAI/bge-large-zh-v1.5",
                dimensions=1024,
            ),
            vectorstore=VectorStoreConfig(store_type=VectorStoreType.CHROMA),
            chunk=ChunkConfig(chunk_size=384, chunk_overlap=48),
            with_agent=True,
            with_frontend=True,
        ),
        "openai-faiss": ProjectConfig(
            project_name=name,
            source_dir=str(source_dir),
            output_dir=str(output),
            llm=LLMConfig(provider=LLMProvider.OPENAI, model="gpt-4o-mini"),
            embedder=EmbedderConfig(provider=EmbedderType.OPENAI, model="text-embedding-3-small"),
            vectorstore=VectorStoreConfig(store_type=VectorStoreType.FAISS),
            with_agent=True,
            with_frontend=True,
        ),
    }

    if preset not in presets:
        console.print(f"[red]✗ 未知预设: {preset}[/]")
        console.print(f"  可用预设: {', '.join(presets.keys())}")
        raise typer.Exit(1)

    config = presets[preset]

    if not source_dir.exists():
        console.print(f"[red]✗ 目录不存在: {source_dir}[/]")
        raise typer.Exit(1)

    files = _scan_documents(source_dir, config.supported_extensions)
    if not files:
        console.print(f"[yellow]⚠ 在 {source_dir} 中未找到支持的文档[/]")
        raise typer.Exit(1)

    _show_summary(config, files)

    console.print("\n[bold]Step 1/3:[/] 解析文档...")
    chunks = _parse_and_chunk(files, config)
    console.print("[bold]Step 2/3:[/] 构建向量索引...")
    _build_index(chunks, config)
    console.print("[bold]Step 3/3:[/] 生成项目...")

    from rag_builder.generator import ProjectGenerator

    gen = ProjectGenerator(config)
    project_path = gen.generate()

    console.print(
        Panel(
            f"[green]✓[/] {project_path}\n\n  cd {project_path} && pip install -r requirements.txt",
            title="[bold green]🎉 Done![/]",
            border_style="green",
        )
    )


# ──────────────────────────────────────────────────────────────
# chat — interactive conversation
# ──────────────────────────────────────────────────────────────


@app.command()
def chat(
    project_dir: Path = typer.Argument(..., help="已生成的 RAG 项目路径"),
):
    """与知识库对话。"""
    if not project_dir.exists():
        console.print(f"[red]✗ 项目不存在: {project_dir}[/]")
        raise typer.Exit(1)

    console.print("[dim]加载知识库...[/]")

    try:
        sys.path.insert(0, str(project_dir))
        from main import build_agent  # type: ignore

        agent = build_agent()
    except Exception as e:
        console.print(f"[red]✗ 加载失败: {e}[/]")
        raise typer.Exit(1)

    console.print(
        Panel(
            "输入问题开始对话  [dim]命令: /reset /quit[/]",
            title="💬 RAG Chat",
        )
    )

    while True:
        try:
            user_input = console.input("\n[bold blue]You:[/] ")
        except (EOFError, KeyboardInterrupt):
            break

        cmd = user_input.strip().lower()
        if cmd in ("/quit", "/exit", "/q"):
            break
        if cmd == "/reset":
            agent.reset()
            console.print("[dim]已重置对话[/]")
            continue
        if not cmd:
            continue

        with console.status("[dim]思考中...[/]"):
            response = agent.chat(user_input.strip())

        console.print(f"\n[bold green]Assistant:[/] {response}")


# ──────────────────────────────────────────────────────────────
# Shared helpers
# ──────────────────────────────────────────────────────────────


def _scan_documents(source_dir: Path, extensions: list[str]) -> list[Path]:
    files = []
    for ext in extensions:
        files.extend(source_dir.rglob(f"*{ext}"))
    files.sort()
    return files


def _show_summary(config: ProjectConfig, files: list[Path]) -> None:
    table = Table(title="📋 配置摘要", show_lines=False, title_style="bold")
    table.add_column("配置项", style="cyan", min_width=14)
    table.add_column("值")

    table.add_row("文档目录", config.source_dir)
    table.add_row("输出路径", f"{config.output_dir}/{config.project_name}")
    table.add_row("文档数量", str(len(files)))
    table.add_row("LLM", f"{config.llm.provider.value} / {config.llm.model}")
    table.add_row("Embedder", f"{config.embedder.provider.value} / {config.embedder.model}")
    table.add_row("向量数据库", config.vectorstore.store_type.value)
    table.add_row("分块大小", f"{config.chunk.chunk_size} tokens (重叠 {config.chunk.chunk_overlap})")
    table.add_row("检索 top_k", str(config.retriever.top_k))
    table.add_row("Agent", "✓" if config.with_agent else "✗")
    table.add_row("Web UI", "✓" if config.with_frontend else "✗")

    type_counts: dict[str, int] = {}
    for f in files:
        ext = f.suffix.lower()
        type_counts[ext] = type_counts.get(ext, 0) + 1
    table.add_row("文件类型", ", ".join(f"{k}: {v}" for k, v in sorted(type_counts.items())))

    console.print(table)


def _parse_and_chunk(files: list[Path], config: ProjectConfig):
    from rich.progress import BarColumn, MofNCompleteColumn, TimeElapsedColumn

    from rag_builder.chunker import chunk_documents
    from rag_builder.parsers import parse_file

    parsed = []
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        MofNCompleteColumn(),
        TimeElapsedColumn(),
        console=console,
    ) as progress:
        task = progress.add_task("解析文件...", total=len(files))
        for f in files:
            doc = parse_file(f)
            if doc:
                parsed.append(doc)
            progress.advance(task)

    chunks = chunk_documents(parsed, config.chunk)
    console.print(f"  → {len(parsed)} 文件, {len(chunks)} 分块")
    return chunks


def _build_index(chunks, config: ProjectConfig) -> None:
    if not chunks:
        return

    from rag_builder.embedder import create_embedder
    from rag_builder.vectorstore.chroma_store import ChromaVectorStore
    from rag_builder.vectorstore.faiss_store import FaissVectorStore

    embedder = create_embedder(config.embedder)

    if config.vectorstore.store_type == VectorStoreType.CHROMA:
        vs = ChromaVectorStore(config.vectorstore, embedder.dimensions)
    else:
        vs = FaissVectorStore(config.vectorstore, embedder.dimensions)

    texts = [c.content for c in chunks]
    with console.status(f"正在嵌入 {len(texts)} 个分块..."):
        embeddings = embedder.embed_texts(texts)

    vs.add(chunks, embeddings)
    vs.persist()
    console.print(f"  → {vs.count()} 向量已索引")


if __name__ == "__main__":
    app()
