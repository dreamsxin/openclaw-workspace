"""Embedding service abstraction."""

from __future__ import annotations

from abc import ABC, abstractmethod

from rag_builder.config import EmbedderConfig, EmbedderType


class BaseEmbedder(ABC):
    """Abstract base for embedding models."""

    @abstractmethod
    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        """Embed a batch of texts."""
        ...

    @abstractmethod
    def embed_query(self, query: str) -> list[float]:
        """Embed a single query."""
        ...

    @property
    @abstractmethod
    def dimensions(self) -> int: ...


class OpenAIEmbedder(BaseEmbedder):
    """OpenAI-compatible embedding API."""

    def __init__(self, config: EmbedderConfig):
        self.config = config
        self._client = None

    @property
    def _get_client(self):
        if self._client is None:
            from openai import OpenAI

            self._client = OpenAI(
                api_key=self.config.api_key,
                base_url=self.config.base_url,
            )
        return self._client

    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        # Batch in groups of 100
        all_embeddings = []
        for i in range(0, len(texts), 100):
            batch = texts[i : i + 100]
            resp = self._get_client.embeddings.create(
                model=self.config.model,
                input=batch,
            )
            all_embeddings.extend([d.embedding for d in resp.data])
        return all_embeddings

    def embed_query(self, query: str) -> list[float]:
        resp = self._get_client.embeddings.create(
            model=self.config.model,
            input=[query],
        )
        return resp.data[0].embedding

    @property
    def dimensions(self) -> int:
        return self.config.dimensions


class SentenceTransformerEmbedder(BaseEmbedder):
    """Local embedding via sentence-transformers."""

    def __init__(self, config: EmbedderConfig):
        self.config = config
        self._model = None

    @property
    def _get_model(self):
        if self._model is None:
            from sentence_transformers import SentenceTransformer

            self._model = SentenceTransformer(self.config.model)
        return self._model

    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        embeddings = self._get_model.encode(texts, show_progress_bar=False)
        return embeddings.tolist()

    def embed_query(self, query: str) -> list[float]:
        embedding = self._get_model.encode([query], show_progress_bar=False)
        return embedding[0].tolist()

    @property
    def dimensions(self) -> int:
        return self._get_model.get_sentence_embedding_dimension()


def create_embedder(config: EmbedderConfig) -> BaseEmbedder:
    """Factory: create the right embedder from config."""
    if config.provider in (EmbedderType.OPENAI, EmbedderType.JINA):
        return OpenAIEmbedder(config)
    elif config.provider == EmbedderType.BGE:
        # BGE can use sentence-transformers locally or API
        if config.base_url:
            return OpenAIEmbedder(config)  # BGE API is OpenAI-compatible
        return SentenceTransformerEmbedder(config)
    else:
        raise ValueError(f"Unknown embedder provider: {config.provider}")
