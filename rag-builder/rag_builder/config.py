"""Configuration management for rag-builder."""

from __future__ import annotations

from enum import Enum
from pathlib import Path
from typing import Optional

from pydantic import BaseModel, Field


class LLMProvider(str, Enum):
    OPENAI = "openai"
    DEEPSEEK = "deepseek"
    OLLAMA = "ollama"


class VectorStoreType(str, Enum):
    CHROMA = "chroma"
    FAISS = "faiss"


class EmbedderType(str, Enum):
    OPENAI = "openai"
    BGE = "bge"
    JINA = "jina"


class ChunkConfig(BaseModel):
    """Chunking strategy configuration."""

    chunk_size: int = Field(default=512, description="Max tokens per chunk")
    chunk_overlap: int = Field(default=64, description="Overlap tokens between chunks")
    min_chunk_size: int = Field(default=50, description="Discard chunks smaller than this")


class LLMConfig(BaseModel):
    """LLM backend configuration."""

    provider: LLMProvider = LLMProvider.OPENAI
    model: str = "gpt-4o-mini"
    api_key: Optional[str] = None
    base_url: Optional[str] = None
    temperature: float = 0.1
    max_tokens: int = 4096


class EmbedderConfig(BaseModel):
    """Embedding model configuration."""

    provider: EmbedderType = EmbedderType.OPENAI
    model: str = "text-embedding-3-small"
    api_key: Optional[str] = None
    base_url: Optional[str] = None
    dimensions: int = 1536


class VectorStoreConfig(BaseModel):
    """Vector store configuration."""

    store_type: VectorStoreType = VectorStoreType.CHROMA
    collection_name: str = "rag_builder"
    persist_dir: str = "./vectorstore"


class RetrieverConfig(BaseModel):
    """Retrieval configuration."""

    top_k: int = 5
    use_reranker: bool = False
    reranker_model: str = "cross-encoder/ms-marco-MiniLM-L-6-v2"
    score_threshold: float = 0.0


class ProjectConfig(BaseModel):
    """Full project configuration."""

    project_name: str = "my-rag-project"
    source_dir: str = ""
    output_dir: str = "./output"
    llm: LLMConfig = LLMConfig()
    embedder: EmbedderConfig = EmbedderConfig()
    vectorstore: VectorStoreConfig = VectorStoreConfig()
    retriever: RetrieverConfig = RetrieverConfig()
    chunk: ChunkConfig = ChunkConfig()
    with_agent: bool = True
    with_frontend: bool = True
    supported_extensions: list[str] = Field(
        default=[".pdf", ".md", ".txt", ".docx", ".rst", ".html"]
    )
