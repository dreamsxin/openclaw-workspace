"""Tests for chunker module — the core text splitting logic."""

from rag_builder.chunker import (
    Chunk,
    ChunkConfig,
    chunk_document,
    chunk_documents,
    estimate_tokens,
    is_cjk_heavy,
)
from rag_builder.parsers import ParsedDocument


class TestEstimateTokens:
    def test_empty(self):
        assert estimate_tokens("") == 0

    def test_english(self):
        # "hello world" ≈ 2 words * 1.3 = ~3 tokens
        tokens = estimate_tokens("hello world")
        assert 2 <= tokens <= 5

    def test_chinese(self):
        # "你好世界" = 4 CJK chars * 1.5 = 6 tokens
        tokens = estimate_tokens("你好世界")
        assert 5 <= tokens <= 8

    def test_mixed(self):
        tokens = estimate_tokens("Hello 你好 World 世界")
        assert tokens > 0

    def test_punctuation(self):
        tokens = estimate_tokens("，。！？")
        assert tokens > 0

    def test_long_text(self):
        text = "这是一段中文文本。" * 100
        tokens = estimate_tokens(text)
        assert tokens > 100  # Should be substantial


class TestCJKDetection:
    def test_pure_chinese(self):
        assert is_cjk_heavy("这是一段中文文本，用于测试。") is True

    def test_pure_english(self):
        assert is_cjk_heavy("This is English text for testing.") is False

    def test_mixed_chinese_heavy(self):
        # 70% CJK
        text = "中文文本测试" * 7 + "hello" * 3
        assert is_cjk_heavy(text) is True

    def test_mixed_english_heavy(self):
        text = "hello world " * 10 + "中文"
        assert is_cjk_heavy(text) is False

    def test_empty(self):
        assert is_cjk_heavy("") is False


class TestChunkDocument:
    def test_basic_chunking(self):
        doc = ParsedDocument(
            source="test.txt",
            content="First paragraph about AI.\n\nSecond paragraph about ML.\n\nThird paragraph about DL.",
            file_type="text",
        )
        config = ChunkConfig(chunk_size=50, chunk_overlap=10, min_chunk_size=5)
        chunks = chunk_document(doc, config)

        assert len(chunks) >= 1
        assert all(isinstance(c, Chunk) for c in chunks)
        # Indices should be sequential
        for i, c in enumerate(chunks):
            assert c.index == i

    def test_source_preserved(self):
        doc = ParsedDocument(
            source="/path/to/file.md",
            content="# Title\n\nSome content here.",
            file_type="markdown",
        )
        chunks = chunk_document(doc, ChunkConfig(min_chunk_size=3))
        assert all(c.source == "/path/to/file.md" for c in chunks)

    def test_metadata_preserved(self):
        doc = ParsedDocument(
            source="test.md",
            content="# Test\n\nContent.",
            file_type="markdown",
            metadata={"title": "Test"},
        )
        chunks = chunk_document(doc, ChunkConfig(min_chunk_size=3))
        assert all(c.metadata.get("title") == "Test" for c in chunks)

    def test_structure_aware_markdown(self):
        """Markdown should split on headings."""
        doc = ParsedDocument(
            source="test.md",
            content=(
                "# Chapter 1\n\n"
                "Content of chapter 1. " * 10 + "\n\n"
                "# Chapter 2\n\n"
                "Content of chapter 2. " * 10
            ),
            file_type="markdown",
        )
        config = ChunkConfig(chunk_size=100, chunk_overlap=10, min_chunk_size=5)
        chunks = chunk_document(doc, config)

        # Should have at least 2 chunks (one per chapter)
        assert len(chunks) >= 2

    def test_chinese_chunking(self):
        """Chinese text should split on sentence boundaries."""
        doc = ParsedDocument(
            source="zh.txt",
            content=(
                "人工智能是计算机科学的重要分支。"
                "机器学习是人工智能的核心技术。"
                "深度学习利用多层神经网络。"
                "自然语言处理是AI的关键应用领域。"
            ),
            file_type="text",
        )
        config = ChunkConfig(chunk_size=30, chunk_overlap=5, min_chunk_size=5)
        chunks = chunk_document(doc, config)

        assert len(chunks) >= 2
        # Chunks should not be empty
        assert all(c.content.strip() for c in chunks)

    def test_min_chunk_size_filter(self):
        """Chunks smaller than min_chunk_size should be discarded."""
        doc = ParsedDocument(
            source="test.txt",
            content="Short.\n\n" + "Long content. " * 20,
            file_type="text",
        )
        config = ChunkConfig(chunk_size=200, min_chunk_size=20)
        chunks = chunk_document(doc, config)

        # "Short." should be filtered out
        assert all(estimate_tokens(c.content) >= 20 for c in chunks)

    def test_empty_document(self):
        doc = ParsedDocument(source="empty.txt", content="", file_type="text")
        chunks = chunk_document(doc)
        assert chunks == []

    def test_token_count_populated(self):
        doc = ParsedDocument(
            source="test.txt",
            content="This is a test document with enough content to be chunked properly.",
            file_type="text",
        )
        chunks = chunk_document(doc, ChunkConfig(min_chunk_size=3))
        assert all(c.token_count > 0 for c in chunks)


class TestChunkDocuments:
    def test_multiple_documents(self):
        docs = [
            ParsedDocument(source="a.txt", content="Document A content. " * 10, file_type="text"),
            ParsedDocument(source="b.txt", content="Document B content. " * 10, file_type="text"),
        ]
        config = ChunkConfig(chunk_size=50, min_chunk_size=5)
        chunks = chunk_documents(docs, config)

        sources = {c.source for c in chunks}
        assert "a.txt" in sources
        assert "b.txt" in sources

    def test_empty_list(self):
        assert chunk_documents([]) == []
