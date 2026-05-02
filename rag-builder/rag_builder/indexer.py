"""Incremental indexing — track changes and update vector store efficiently."""

from __future__ import annotations

import hashlib
import json
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path

from rag_builder.chunker import Chunk, chunk_documents
from rag_builder.config import ChunkConfig, ProjectConfig, VectorStoreType
from rag_builder.embedder import BaseEmbedder, create_embedder
from rag_builder.parsers import ParsedDocument, parse_file
from rag_builder.vectorstore import BaseVectorStore
from rag_builder.vectorstore.chroma_store import ChromaVectorStore
from rag_builder.vectorstore.faiss_store import FaissVectorStore


@dataclass
class FileRecord:
    """Record of a single indexed file."""

    path: str  # absolute path
    content_hash: str  # sha256 of file content
    mtime: float  # last modification time
    chunk_count: int  # number of chunks generated
    indexed_at: float  # timestamp of indexing
    file_size: int = 0


@dataclass
class IndexManifest:
    """Tracks which files have been indexed and their state."""

    version: int = 1
    files: dict[str, FileRecord] = field(default_factory=dict)  # path -> FileRecord
    total_chunks: int = 0
    last_updated: float = 0.0

    @classmethod
    def load(cls, path: Path) -> IndexManifest:
        """Load manifest from JSON file."""
        if not path.exists():
            return cls()
        try:
            data = json.loads(path.read_text())
            manifest = cls(
                version=data.get("version", 1),
                total_chunks=data.get("total_chunks", 0),
                last_updated=data.get("last_updated", 0.0),
            )
            for path_str, rec in data.get("files", {}).items():
                manifest.files[path_str] = FileRecord(**rec)
            return manifest
        except (json.JSONDecodeError, TypeError, KeyError):
            return cls()

    def save(self, path: Path) -> None:
        """Save manifest to JSON file."""
        path.parent.mkdir(parents=True, exist_ok=True)
        data = {
            "version": self.version,
            "total_chunks": self.total_chunks,
            "last_updated": self.last_updated,
            "files": {k: asdict(v) for k, v in self.files.items()},
        }
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2))

    def remove_file(self, file_path: str) -> int:
        """Remove a file record. Returns chunk count removed."""
        rec = self.files.pop(file_path, None)
        if rec:
            self.total_chunks -= rec.chunk_count
            return rec.chunk_count
        return 0

    def add_file(self, record: FileRecord) -> None:
        """Add or update a file record."""
        # If updating, subtract old chunk count first
        old = self.files.get(record.path)
        if old:
            self.total_chunks -= old.chunk_count
        self.files[record.path] = record
        self.total_chunks += record.chunk_count
        self.last_updated = time.time()


def file_content_hash(file_path: Path) -> str:
    """Compute SHA-256 hash of file content."""
    h = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


@dataclass
class IndexDiff:
    """Result of diffing current files against manifest."""

    new: list[Path] = field(default_factory=list)
    modified: list[Path] = field(default_factory=list)
    deleted: list[str] = field(default_factory=list)  # paths from manifest
    unchanged: list[str] = field(default_factory=list)

    @property
    def needs_update(self) -> bool:
        return bool(self.new or self.modified or self.deleted)

    def summary(self) -> str:
        parts = []
        if self.new:
            parts.append(f"新增 {len(self.new)}")
        if self.modified:
            parts.append(f"修改 {len(self.modified)}")
        if self.deleted:
            parts.append(f"删除 {len(self.deleted)}")
        if self.unchanged:
            parts.append(f"未变 {len(self.unchanged)}")
        return ", ".join(parts) if parts else "无变化"


def compute_diff(
    current_files: list[Path],
    manifest: IndexManifest,
) -> IndexDiff:
    """Compare current file list against the manifest.

    Returns IndexDiff describing what changed.
    """
    diff = IndexDiff()

    current_set: dict[str, Path] = {}
    for f in current_files:
        abs_path = str(f.resolve())
        current_set[abs_path] = f

    manifest_set = set(manifest.files.keys())

    # Check each current file
    for abs_path, file_path in current_set.items():
        if abs_path not in manifest_set:
            diff.new.append(file_path)
        else:
            rec = manifest.files[abs_path]
            # Check if modified (hash or mtime)
            current_mtime = file_path.stat().st_mtime
            if current_mtime > rec.mtime:
                # mtime changed — verify with content hash
                current_hash = file_content_hash(file_path)
                if current_hash != rec.content_hash:
                    diff.modified.append(file_path)
                else:
                    diff.unchanged.append(abs_path)
            else:
                diff.unchanged.append(abs_path)

    # Find deleted files (in manifest but not on disk)
    for abs_path in manifest_set:
        if abs_path not in current_set:
            diff.deleted.append(abs_path)

    return diff


def _build_vectorstore(config: ProjectConfig, embedder: BaseEmbedder) -> BaseVectorStore:
    """Create vector store from config."""
    if config.vectorstore.store_type == VectorStoreType.CHROMA:
        return ChromaVectorStore(config.vectorstore, embedder.dimensions)
    else:
        return FaissVectorStore(config.vectorstore, embedder.dimensions)


def incremental_index(
    config: ProjectConfig,
    files: list[Path],
    verbose: bool = True,
) -> IndexManifest:
    """Run incremental indexing: only process new/modified files, remove deleted.

    Returns the updated manifest.
    """
    from rich.console import Console
    from rich.progress import BarColumn, MofNCompleteColumn, SpinnerColumn, TextColumn, TimeElapsedColumn
    from rich.table import Table

    console = Console() if verbose else None
    manifest_path = Path(config.vectorstore.persist_dir) / "index_manifest.json"
    manifest = IndexManifest.load(manifest_path)

    # Compute diff
    diff = compute_diff(files, manifest)

    if not diff.needs_update:
        if console:
            console.print("[green]✓ 索引已是最新，无需更新[/]")
        return manifest

    if console:
        table = Table(title="📊 索引变更", show_lines=False)
        table.add_column("类型", style="cyan")
        table.add_column("数量", justify="right")
        table.add_column("说明")
        if diff.new:
            table.add_row("新增", str(len(diff.new)), "新发现的文档")
        if diff.modified:
            table.add_row("修改", str(len(diff.modified)), "内容已变化")
        if diff.deleted:
            table.add_row("删除", str(len(diff.deleted)), "文件已移除")
        table.add_row("未变", str(len(diff.unchanged)), "跳过")
        console.print(table)

    embedder = create_embedder(config.embedder)
    vs = _build_vectorstore(config, embedder)

    # ── Handle deletions ──
    if diff.deleted:
        if console:
            console.print(f"\n[bold]删除 {len(diff.deleted)} 个文件的向量...[/]")
        for file_path in diff.deleted:
            vs.delete_by_source(file_path)
            manifest.remove_file(file_path)
        if console:
            console.print(f"  → 已删除 {len(diff.deleted)} 个文件的旧向量")

    # ── Handle modifications (delete old + re-index) ──
    if diff.modified:
        if console:
            console.print(f"\n[bold]重新索引 {len(diff.modified)} 个修改文件...[/]")
        for file_path in diff.modified:
            vs.delete_by_source(str(file_path.resolve()))
            manifest.remove_file(str(file_path.resolve()))

    # ── Handle new + modified files ──
    to_index = diff.new + diff.modified
    if to_index:
        if console:
            console.print(f"\n[bold]索引 {len(to_index)} 个文件...[/]")

        # Parse
        parsed_docs: list[ParsedDocument] = []
        if console:
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                BarColumn(),
                MofNCompleteColumn(),
                TimeElapsedColumn(),
                console=console,
            ) as progress:
                task = progress.add_task("解析文件...", total=len(to_index))
                for f in to_index:
                    doc = parse_file(f)
                    if doc:
                        parsed_docs.append(doc)
                    progress.advance(task)
        else:
            for f in to_index:
                doc = parse_file(f)
                if doc:
                    parsed_docs.append(doc)

        # Chunk
        all_chunks = chunk_documents(parsed_docs, config.chunk)

        # Group chunks by source for manifest tracking
        chunks_by_source: dict[str, list[Chunk]] = {}
        for chunk in all_chunks:
            src = str(Path(chunk.source).resolve())
            chunks_by_source.setdefault(src, []).append(chunk)

        # Embed and add to vector store
        if all_chunks:
            texts = [c.content for c in all_chunks]
            if console:
                with console.status(f"正在嵌入 {len(texts)} 个分块..."):
                    embeddings = embedder.embed_texts(texts)
            else:
                embeddings = embedder.embed_texts(texts)

            vs.add(all_chunks, embeddings)

        # Update manifest
        for file_path in to_index:
            abs_path = str(file_path.resolve())
            file_chunks = chunks_by_source.get(abs_path, [])
            manifest.add_file(
                FileRecord(
                    path=abs_path,
                    content_hash=file_content_hash(file_path),
                    mtime=file_path.stat().st_mtime,
                    chunk_count=len(file_chunks),
                    indexed_at=time.time(),
                    file_size=file_path.stat().st_size,
                )
            )

        if console:
            console.print(f"  → 已索引 {len(to_index)} 个文件, {len(all_chunks)} 个分块")

    # Persist
    vs.persist()
    manifest.save(manifest_path)

    if console:
        console.print(
            f"[green]✓ 索引完成[/] — "
            f"总计 {len(manifest.files)} 个文件, {manifest.total_chunks} 个分块"
        )

    return manifest


def full_index(
    config: ProjectConfig,
    files: list[Path],
    verbose: bool = True,
) -> IndexManifest:
    """Full re-index: clear everything and rebuild from scratch."""
    from rich.console import Console
    from rich.progress import BarColumn, MofNCompleteColumn, SpinnerColumn, TextColumn, TimeElapsedColumn

    console = Console() if verbose else None
    manifest_path = Path(config.vectorstore.persist_dir) / "index_manifest.json"

    if console:
        console.print("[bold]全量重建索引...[/]")

    # Clear existing data
    embedder = create_embedder(config.embedder)
    vs = _build_vectorstore(config, embedder)
    vs.clear()

    # Parse all files
    parsed_docs: list[ParsedDocument] = []
    if console:
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
                    parsed_docs.append(doc)
                progress.advance(task)
    else:
        for f in files:
            doc = parse_file(f)
            if doc:
                parsed_docs.append(doc)

    # Chunk
    all_chunks = chunk_documents(parsed_docs, config.chunk)

    # Group by source
    chunks_by_source: dict[str, list[Chunk]] = {}
    for chunk in all_chunks:
        src = str(Path(chunk.source).resolve())
        chunks_by_source.setdefault(src, []).append(chunk)

    # Embed
    if all_chunks:
        texts = [c.content for c in all_chunks]
        if console:
            with console.status(f"正在嵌入 {len(texts)} 个分块..."):
                embeddings = embedder.embed_texts(texts)
        else:
            embeddings = embedder.embed_texts(texts)
        vs.add(all_chunks, embeddings)

    vs.persist()

    # Build manifest
    manifest = IndexManifest()
    for f in files:
        abs_path = str(f.resolve())
        file_chunks = chunks_by_source.get(abs_path, [])
        manifest.add_file(
            FileRecord(
                path=abs_path,
                content_hash=file_content_hash(f),
                mtime=f.stat().st_mtime,
                chunk_count=len(file_chunks),
                indexed_at=time.time(),
                file_size=f.stat().st_size,
            )
        )
    manifest.save(manifest_path)

    if console:
        console.print(
            f"[green]✓ 全量索引完成[/] — "
            f"{len(manifest.files)} 个文件, {manifest.total_chunks} 个分块"
        )

    return manifest
