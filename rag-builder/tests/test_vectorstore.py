"""Tests for vector store implementations.

Uses mock embedder to avoid real API calls.
"""

from __future__ import annotations

import pytest

from rag_builder.chunker import Chunk
from rag_builder.vectorstore import BaseVectorStore, SearchResult

try:
    import faiss

    HAS_FAISS = True
except ImportError:
    HAS_FAISS = False


# ── Shared test fixtures ────────────────────────────────────────────


def _make_chunks(n: int = 5, source: str = "test.txt") -> list[Chunk]:
    """Create n test chunks."""
    return [
        Chunk(
            content=f"Chunk {i} about artificial intelligence and machine learning.",
            index=i,
            source=source,
            metadata={"file_type": "text"},
            token_count=10 + i,
        )
        for i in range(n)
    ]


def _make_embeddings(n: int = 5, dim: int = 32) -> list[list[float]]:
    """Create n fake embeddings (random but deterministic)."""
    import random
    random.seed(42)
    return [[random.random() for _ in range(dim)] for _ in range(n)]


# ── ChromaDB Tests ──────────────────────────────────────────────────


class TestChromaVectorStore:
    @pytest.fixture
    def store(self, tmp_dir):
        """ChromaDB store backed by temp directory."""
        from rag_builder.config import VectorStoreConfig, VectorStoreType
        from rag_builder.vectorstore.chroma_store import ChromaVectorStore

        config = VectorStoreConfig(
            store_type=VectorStoreType.CHROMA,
            persist_dir=str(tmp_dir / "chroma"),
        )
        return ChromaVectorStore(config, embedding_dim=32)

    def test_add_and_count(self, store):
        chunks = _make_chunks(5)
        embeddings = _make_embeddings(5, 32)
        store.add(chunks, embeddings)
        assert store.count() == 5

    def test_search(self, store):
        chunks = _make_chunks(5)
        embeddings = _make_embeddings(5, 32)
        store.add(chunks, embeddings)

        # Search with first embedding should return itself as top result
        results = store.search(embeddings[0], top_k=3)
        assert len(results) <= 3
        assert len(results) > 0
        assert all(isinstance(r, SearchResult) for r in results)
        # Results should be sorted by score (highest first)
        for i in range(len(results) - 1):
            assert results[i].score >= results[i + 1].score

    def test_search_empty(self, store):
        results = store.search([0.1] * 32, top_k=5)
        assert results == []

    def test_delete_by_source(self, store):
        chunks_a = _make_chunks(3, source="a.txt")
        chunks_b = _make_chunks(2, source="b.txt")
        embeddings = _make_embeddings(5, 32)

        store.add(chunks_a + chunks_b, embeddings)
        assert store.count() == 5

        deleted = store.delete_by_source("a.txt")
        assert deleted == 3
        assert store.count() == 2

    def test_delete_nonexistent_source(self, store):
        chunks = _make_chunks(3)
        embeddings = _make_embeddings(3, 32)
        store.add(chunks, embeddings)

        deleted = store.delete_by_source("nonexistent.txt")
        assert deleted == 0
        assert store.count() == 3

    def test_clear(self, store):
        chunks = _make_chunks(3)
        embeddings = _make_embeddings(3, 32)
        store.add(chunks, embeddings)

        store.clear()
        assert store.count() == 0

    def test_persist_and_reload(self, tmp_dir):
        """Data should survive a reload."""
        from rag_builder.config import VectorStoreConfig, VectorStoreType
        from rag_builder.vectorstore.chroma_store import ChromaVectorStore

        config = VectorStoreConfig(
            store_type=VectorStoreType.CHROMA,
            persist_dir=str(tmp_dir / "chroma"),
        )

        # Write
        store1 = ChromaVectorStore(config, embedding_dim=32)
        chunks = _make_chunks(3)
        embeddings = _make_embeddings(3, 32)
        store1.add(chunks, embeddings)
        store1.persist()

        # Read in new instance
        store2 = ChromaVectorStore(config, embedding_dim=32)
        assert store2.count() == 3

    def test_batch_insert(self, store):
        """Large batch should be split automatically."""
        chunks = _make_chunks(1200)
        embeddings = _make_embeddings(1200, 32)
        store.add(chunks, embeddings)
        assert store.count() == 1200


# ── FAISS Tests ─────────────────────────────────────────────────────


@pytest.mark.skipif(not HAS_FAISS, reason="faiss not installed")
class TestFaissVectorStore:
    @pytest.fixture
    def store(self, tmp_dir):
        """FAISS store backed by temp directory."""
        from rag_builder.config import VectorStoreConfig, VectorStoreType
        from rag_builder.vectorstore.faiss_store import FaissVectorStore

        config = VectorStoreConfig(
            store_type=VectorStoreType.FAISS,
            persist_dir=str(tmp_dir / "faiss"),
        )
        return FaissVectorStore(config, embedding_dim=32)

    def test_add_and_count(self, store):
        chunks = _make_chunks(5)
        embeddings = _make_embeddings(5, 32)
        store.add(chunks, embeddings)
        assert store.count() == 5

    def test_search(self, store):
        chunks = _make_chunks(5)
        embeddings = _make_embeddings(5, 32)
        store.add(chunks, embeddings)

        results = store.search(embeddings[0], top_k=3)
        assert 0 < len(results) <= 3
        assert all(isinstance(r, SearchResult) for r in results)

    def test_search_empty(self, store):
        results = store.search([0.1] * 32, top_k=5)
        assert results == []

    def test_delete_by_source(self, store):
        chunks_a = _make_chunks(3, source="a.txt")
        chunks_b = _make_chunks(2, source="b.txt")
        embeddings = _make_embeddings(5, 32)

        store.add(chunks_a + chunks_b, embeddings)
        assert store.count() == 5

        deleted = store.delete_by_source("a.txt")
        assert deleted == 3
        assert store.count() == 2

        # Remaining chunks should be from b.txt
        remaining = store.search(embeddings[3], top_k=10)
        assert all(r.chunk.source == "b.txt" for r in remaining)

    def test_delete_all(self, store):
        chunks = _make_chunks(3, source="only.txt")
        embeddings = _make_embeddings(3, 32)
        store.add(chunks, embeddings)

        deleted = store.delete_by_source("only.txt")
        assert deleted == 3
        assert store.count() == 0

    def test_clear(self, store):
        store.add(_make_chunks(3), _make_embeddings(3, 32))
        store.clear()
        assert store.count() == 0

    def test_persist_and_reload(self, tmp_dir):
        from rag_builder.config import VectorStoreConfig, VectorStoreType
        from rag_builder.vectorstore.faiss_store import FaissVectorStore

        config = VectorStoreConfig(
            store_type=VectorStoreType.FAISS,
            persist_dir=str(tmp_dir / "faiss"),
        )

        # Write
        store1 = FaissVectorStore(config, embedding_dim=32)
        chunks = _make_chunks(3)
        embeddings = _make_embeddings(3, 32)
        store1.add(chunks, embeddings)
        store1.persist()

        # Read
        store2 = FaissVectorStore(config, embedding_dim=32)
        assert store2.count() == 3
        results = store2.search(embeddings[0], top_k=1)
        assert len(results) == 1
