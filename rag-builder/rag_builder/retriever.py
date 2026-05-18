"""Retriever — orchestrates embedding + vector search + optional reranking."""

from __future__ import annotations

from rag_builder.config import ProjectConfig, RetrieverConfig, VectorStoreType
from rag_builder.embedder import BaseEmbedder, create_embedder
from rag_builder.vectorstore import BaseVectorStore, SearchResult
from rag_builder.vectorstore.chroma_store import ChromaVectorStore
from rag_builder.vectorstore.faiss_store import FaissVectorStore


class Retriever:
    """High-level retrieval: embed query → search → optional rerank."""

    def __init__(
        self,
        vectorstore: BaseVectorStore,
        embedder: BaseEmbedder,
        config: RetrieverConfig | None = None,
    ):
        self.vectorstore = vectorstore
        self.embedder = embedder
        self.config = config or RetrieverConfig()

    def retrieve(self, query: str, top_k: int | None = None) -> list[SearchResult]:
        """Retrieve relevant chunks for a query."""
        k = top_k or self.config.top_k
        query_embedding = self.embedder.embed_query(query)
        results = self.vectorstore.search(query_embedding, top_k=k * 2)  # over-fetch for rerank

        if self.config.use_reranker and results:
            results = self._rerank(query, results)[:k]

        # Apply score threshold
        if self.config.score_threshold > 0:
            results = [r for r in results if r.score >= self.config.score_threshold]

        return results[:k]

    def _rerank(self, query: str, results: list[SearchResult]) -> list[SearchResult]:
        """Cross-encoder reranking."""
        try:
            from sentence_transformers import CrossEncoder

            model = CrossEncoder(self.config.reranker_model)
            pairs = [(query, r.chunk.content) for r in results]
            scores = model.predict(pairs)

            for result, score in zip(results, scores):
                result.score = float(score)

            results.sort(key=lambda r: r.score, reverse=True)
        except ImportError:
            pass  # sentence-transformers not installed, skip rerank

        return results

    @classmethod
    def from_config(cls, config: ProjectConfig) -> Retriever:
        """Create retriever from project config."""
        embedder = create_embedder(config.embedder)

        if config.vectorstore.store_type == VectorStoreType.CHROMA:
            vs = ChromaVectorStore(config.vectorstore, embedder.dimensions)
        else:
            vs = FaissVectorStore(config.vectorstore, embedder.dimensions)

        return cls(vectorstore=vs, embedder=embedder, config=config.retriever)
