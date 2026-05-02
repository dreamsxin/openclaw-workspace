"""Tests for the retriever module."""

from __future__ import annotations

from unittest.mock import MagicMock

from rag_builder.chunker import Chunk
from rag_builder.config import RetrieverConfig
from rag_builder.retriever import Retriever
from rag_builder.vectorstore import SearchResult


class TestRetriever:
    def _make_retriever(self, results: list[SearchResult], config=None) -> Retriever:
        """Create retriever with mocked dependencies."""
        mock_vs = MagicMock()
        mock_vs.search.return_value = results

        mock_embedder = MagicMock()
        mock_embedder.embed_query.return_value = [0.1] * 32

        return Retriever(
            vectorstore=mock_vs,
            embedder=mock_embedder,
            config=config or RetrieverConfig(top_k=3),
        )

    def test_basic_retrieve(self):
        results = [
            SearchResult(
                chunk=Chunk(content="AI content", index=0, source="ai.txt",
                            metadata={}, token_count=5),
                score=0.9,
            ),
        ]
        retriever = self._make_retriever(results)
        got = retriever.retrieve("what is AI")

        assert len(got) == 1
        assert got[0].score == 0.9
        retriever.embedder.embed_query.assert_called_once_with("what is AI")

    def test_empty_results(self):
        retriever = self._make_retriever([])
        got = retriever.retrieve("nothing")
        assert got == []

    def test_score_threshold(self):
        results = [
            SearchResult(
                chunk=Chunk(content="high", index=0, source="a.txt", metadata={}, token_count=5),
                score=0.8,
            ),
            SearchResult(
                chunk=Chunk(content="low", index=1, source="b.txt", metadata={}, token_count=5),
                score=0.2,
            ),
        ]
        config = RetrieverConfig(top_k=5, score_threshold=0.5)
        retriever = self._make_retriever(results, config)
        got = retriever.retrieve("test")

        # Only high-score result should pass threshold
        assert len(got) == 1
        assert got[0].score == 0.8

    def test_top_k_passed_to_vs(self):
        results = [
            SearchResult(
                chunk=Chunk(content=f"c{i}", index=i, source="a.txt", metadata={}, token_count=5),
                score=0.9 - i * 0.1,
            )
            for i in range(10)
        ]
        config = RetrieverConfig(top_k=3)
        retriever = self._make_retriever(results, config)
        retriever.retrieve("test")

        # Should request top_k * 2 for potential reranking
        retriever.vectorstore.search.assert_called_once()
        call_args = retriever.vectorstore.search.call_args
        assert call_args[1]["top_k"] == 6  # top_k * 2
