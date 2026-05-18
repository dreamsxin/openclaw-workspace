"""Shared test fixtures."""

from __future__ import annotations

import tempfile
from pathlib import Path

import pytest

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


@pytest.fixture
def tmp_dir():
    """Temporary directory that cleans up after test."""
    with tempfile.TemporaryDirectory() as d:
        yield Path(d)


@pytest.fixture
def sample_config(tmp_dir):
    """A basic project config for testing."""
    return ProjectConfig(
        project_name="test-project",
        source_dir=str(tmp_dir / "docs"),
        output_dir=str(tmp_dir / "output"),
        llm=LLMConfig(provider=LLMProvider.OPENAI, model="gpt-4o-mini"),
        embedder=EmbedderConfig(
            provider=EmbedderType.OPENAI,
            model="text-embedding-3-small",
            dimensions=1536,
        ),
        vectorstore=VectorStoreConfig(
            store_type=VectorStoreType.CHROMA,
            persist_dir=str(tmp_dir / "vectorstore"),
        ),
        chunk=ChunkConfig(chunk_size=256, chunk_overlap=32),
        retriever=RetrieverConfig(top_k=3),
    )


@pytest.fixture
def sample_docs(tmp_dir):
    """Create sample document files for testing."""
    docs_dir = tmp_dir / "docs"
    docs_dir.mkdir()

    # English text
    (docs_dir / "readme.txt").write_text(
        "This is a test document.\n\n"
        "It contains multiple paragraphs about artificial intelligence. "
        "Machine learning is a subset of AI that focuses on data-driven approaches.\n\n"
        "Deep learning uses neural networks with many layers. "
        "It has revolutionized computer vision and natural language processing.\n\n"
        "Reinforcement learning is another important paradigm. "
        "It learns through trial and error interactions with an environment."
    )

    # Chinese text
    (docs_dir / "技术文档.md").write_text(
        "# 人工智能概述\n\n"
        "人工智能是计算机科学的一个重要分支。\n\n"
        "## 机器学习\n\n"
        "机器学习是人工智能的核心技术之一。它通过数据驱动的方法来解决复杂问题。"
        "监督学习、无监督学习和强化学习是三种主要的学习范式。\n\n"
        "## 深度学习\n\n"
        "深度学习利用多层神经网络进行特征提取和模式识别。"
        "它在计算机视觉、自然语言处理等领域取得了突破性进展。"
    )

    # Markdown with frontmatter
    (docs_dir / "guide.md").write_text(
        "---\ntitle: User Guide\nauthor: Test\n---\n\n"
        "# Getting Started\n\n"
        "Welcome to the application.\n\n"
        "## Installation\n\n"
        "Run `pip install myapp` to get started.\n\n"
        "## Configuration\n\n"
        "Edit the config.yaml file in your home directory."
    )

    # Short file (should be filtered by min_chunk_size)
    (docs_dir / "short.txt").write_text("Hi.")

    return docs_dir
