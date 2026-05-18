"""Tests for config module."""

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


class TestLLMConfig:
    def test_defaults(self):
        cfg = LLMConfig()
        assert cfg.provider == LLMProvider.OPENAI
        assert cfg.model == "gpt-4o-mini"
        assert cfg.temperature == 0.1
        assert cfg.max_tokens == 4096

    def test_custom_values(self):
        cfg = LLMConfig(
            provider=LLMProvider.DEEPSEEK,
            model="deepseek-chat",
            base_url="https://api.deepseek.com/v1",
            temperature=0.5,
        )
        assert cfg.provider == LLMProvider.DEEPSEEK
        assert cfg.model == "deepseek-chat"
        assert cfg.base_url == "https://api.deepseek.com/v1"
        assert cfg.temperature == 0.5

    def test_ollama_provider(self):
        cfg = LLMConfig(
            provider=LLMProvider.OLLAMA,
            model="qwen2.5:7b",
            base_url="http://localhost:11434/v1",
        )
        assert cfg.provider == LLMProvider.OLLAMA
        assert cfg.api_key is None  # Ollama doesn't need key


class TestEmbedderConfig:
    def test_defaults(self):
        cfg = EmbedderConfig()
        assert cfg.provider == EmbedderType.OPENAI
        assert cfg.model == "text-embedding-3-small"
        assert cfg.dimensions == 1536

    def test_bge_config(self):
        cfg = EmbedderConfig(
            provider=EmbedderType.BGE,
            model="BAAI/bge-large-zh-v1.5",
            dimensions=1024,
        )
        assert cfg.provider == EmbedderType.BGE
        assert cfg.dimensions == 1024


class TestVectorStoreConfig:
    def test_defaults(self):
        cfg = VectorStoreConfig()
        assert cfg.store_type == VectorStoreType.CHROMA
        assert cfg.collection_name == "rag_builder"
        assert cfg.persist_dir == "./vectorstore"


class TestChunkConfig:
    def test_defaults(self):
        cfg = ChunkConfig()
        assert cfg.chunk_size == 512
        assert cfg.chunk_overlap == 64
        assert cfg.min_chunk_size == 50

    def test_custom(self):
        cfg = ChunkConfig(chunk_size=256, chunk_overlap=32, min_chunk_size=20)
        assert cfg.chunk_size == 256


class TestRetrieverConfig:
    def test_defaults(self):
        cfg = RetrieverConfig()
        assert cfg.top_k == 5
        assert cfg.use_reranker is False
        assert cfg.score_threshold == 0.0


class TestProjectConfig:
    def test_defaults(self):
        cfg = ProjectConfig()
        assert cfg.project_name == "my-rag-project"
        assert cfg.with_agent is True
        assert cfg.with_frontend is True
        assert ".pdf" in cfg.supported_extensions
        assert ".md" in cfg.supported_extensions

    def test_enum_serialization(self):
        """Ensure enums serialize to their string values."""
        cfg = ProjectConfig()
        assert cfg.llm.provider.value == "openai"
        assert cfg.vectorstore.store_type.value == "chroma"
        assert cfg.embedder.provider.value == "openai"

    def test_full_config(self):
        cfg = ProjectConfig(
            project_name="my-kb",
            source_dir="/tmp/docs",
            llm=LLMConfig(provider=LLMProvider.OLLAMA, model="llama3"),
            with_agent=False,
        )
        assert cfg.project_name == "my-kb"
        assert cfg.llm.provider == LLMProvider.OLLAMA
        assert cfg.with_agent is False
