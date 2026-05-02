"""Tests for the generator module."""

from __future__ import annotations

from pathlib import Path

from rag_builder.config import (
    ChunkConfig,
    EmbedderConfig,
    EmbedderType,
    LLMConfig,
    LLMProvider,
    ProjectConfig,
    VectorStoreConfig,
    VectorStoreType,
)
from rag_builder.generator import ProjectGenerator


class TestProjectGenerator:
    def _config(self, tmp_dir, **overrides) -> ProjectConfig:
        base = dict(
            project_name="test-proj",
            source_dir=str(tmp_dir / "docs"),
            output_dir=str(tmp_dir / "output"),
            llm=LLMConfig(provider=LLMProvider.OPENAI, model="gpt-4o-mini"),
            embedder=EmbedderConfig(provider=EmbedderType.OPENAI, model="text-embedding-3-small"),
            vectorstore=VectorStoreConfig(store_type=VectorStoreType.CHROMA),
            with_agent=True,
            with_frontend=True,
        )
        base.update(overrides)
        return ProjectConfig(**base)

    def _generator(self, config):
        """Create generator with template dir explicitly set to source tree."""
        from rag_builder.generator import ProjectGenerator
        gen = ProjectGenerator(config)
        # Ensure template_dir points to the source tree
        import rag_builder.generator as gen_mod
        src_templates = Path(gen_mod.__file__).parent.parent / "templates"
        if src_templates.exists():
            gen.template_dir = src_templates
        return gen

    def test_generate_basic_structure(self, tmp_dir):
        config = self._config(tmp_dir, with_agent=False, with_frontend=False)
        gen = self._generator(config)
        project_path = gen.generate()

        assert project_path.exists()
        assert (project_path / "main.py").exists()
        assert (project_path / ".env").exists()
        assert (project_path / "requirements.txt").exists()

    def test_generate_advanced_structure(self, tmp_dir):
        config = self._config(tmp_dir, with_agent=True, with_frontend=True)
        gen = self._generator(config)
        project_path = gen.generate()

        assert (project_path / "main.py").exists()
        assert (project_path / "index_docs.py").exists()
        assert (project_path / "app.py").exists()
        assert (project_path / "README.md").exists()

    def test_env_file_content(self, tmp_dir):
        config = self._config(
            tmp_dir,
            llm=LLMConfig(provider=LLMProvider.DEEPSEEK, model="deepseek-chat"),
        )
        gen = self._generator(config)
        project_path = gen.generate()

        env_content = (project_path / ".env").read_text()
        assert "deepseek" in env_content.lower()
        assert "LLM_MODEL=deepseek-chat" in env_content

    def test_requirements_include_streamlit(self, tmp_dir):
        config = self._config(tmp_dir, with_frontend=True)
        gen = self._generator(config)
        project_path = gen.generate()

        req = (project_path / "requirements.txt").read_text()
        assert "streamlit" in req

    def test_requirements_no_streamlit(self, tmp_dir):
        config = self._config(tmp_dir, with_frontend=False)
        gen = self._generator(config)
        project_path = gen.generate()

        req = (project_path / "requirements.txt").read_text()
        assert "streamlit" not in req

    def test_project_name_in_main(self, tmp_dir):
        config = self._config(tmp_dir, project_name="my-awesome-kb")
        gen = self._generator(config)
        project_path = gen.generate()

        main_content = (project_path / "main.py").read_text()
        assert "my-awesome-kb" in main_content
