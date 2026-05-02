"""Tests for embedder module (mock-based, no real API calls)."""

from __future__ import annotations

from unittest.mock import MagicMock, patch

import pytest

from rag_builder.config import EmbedderConfig, EmbedderType
from rag_builder.embedder import OpenAIEmbedder, SentenceTransformerEmbedder, create_embedder


class TestCreateEmbedder:
    def test_openai(self):
        cfg = EmbedderConfig(provider=EmbedderType.OPENAI)
        embedder = create_embedder(cfg)
        assert isinstance(embedder, OpenAIEmbedder)

    def test_jina_uses_openai(self):
        """Jina uses OpenAI-compatible API."""
        cfg = EmbedderConfig(provider=EmbedderType.JINA)
        embedder = create_embedder(cfg)
        assert isinstance(embedder, OpenAIEmbedder)

    def test_bge_with_url(self):
        """BGE with base_url should use OpenAI-compatible client."""
        cfg = EmbedderConfig(
            provider=EmbedderType.BGE,
            base_url="http://localhost:11434/v1",
        )
        embedder = create_embedder(cfg)
        assert isinstance(embedder, OpenAIEmbedder)

    def test_unknown_provider(self):
        with pytest.raises(ValueError, match="Unknown"):
            cfg = EmbedderConfig()
            cfg.provider = "unknown"
            create_embedder(cfg)


class TestOpenAIEmbedder:
    @patch("openai.OpenAI")
    def test_embed_texts(self, mock_openai_cls):
        mock_client = MagicMock()
        mock_openai_cls.return_value = mock_client

        # Mock response
        mock_response = MagicMock()
        mock_response.data = [
            MagicMock(embedding=[0.1, 0.2, 0.3]),
            MagicMock(embedding=[0.4, 0.5, 0.6]),
        ]
        mock_client.embeddings.create.return_value = mock_response

        cfg = EmbedderConfig(provider=EmbedderType.OPENAI, dimensions=3)
        embedder = OpenAIEmbedder(cfg)
        result = embedder.embed_texts(["hello", "world"])

        assert len(result) == 2
        assert result[0] == [0.1, 0.2, 0.3]
        assert result[1] == [0.4, 0.5, 0.6]
        mock_client.embeddings.create.assert_called_once()

    @patch("openai.OpenAI")
    def test_embed_query(self, mock_openai_cls):
        mock_client = MagicMock()
        mock_openai_cls.return_value = mock_client

        mock_response = MagicMock()
        mock_response.data = [MagicMock(embedding=[0.1, 0.2, 0.3])]
        mock_client.embeddings.create.return_value = mock_response

        cfg = EmbedderConfig(provider=EmbedderType.OPENAI, dimensions=3)
        embedder = OpenAIEmbedder(cfg)
        result = embedder.embed_query("test query")

        assert result == [0.1, 0.2, 0.3]

    def test_dimensions(self):
        cfg = EmbedderConfig(provider=EmbedderType.OPENAI, dimensions=768)
        embedder = OpenAIEmbedder(cfg)
        assert embedder.dimensions == 768

    @patch("openai.OpenAI")
    def test_batch_size_100(self, mock_openai_cls):
        """Should batch in groups of 100."""
        mock_client = MagicMock()
        mock_openai_cls.return_value = mock_client

        mock_response = MagicMock()
        mock_response.data = [MagicMock(embedding=[0.1])] * 50
        mock_client.embeddings.create.return_value = mock_response

        cfg = EmbedderConfig(provider=EmbedderType.OPENAI, dimensions=1)
        embedder = OpenAIEmbedder(cfg)
        embedder.embed_texts(["text"] * 150)

        # Should be called twice (100 + 50)
        assert mock_client.embeddings.create.call_count == 2
