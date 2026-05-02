"""Tests for document parsers."""

import pytest

from rag_builder.parsers import ParsedDocument, get_parser, parse_file


class TestGetParser:
    def test_pdf_parser(self):
        parser = get_parser(".pdf")
        assert parser is not None

    def test_markdown_parser(self):
        parser = get_parser(".md")
        assert parser is not None

    def test_text_parser(self):
        parser = get_parser(".txt")
        assert parser is not None

    def test_docx_parser(self):
        parser = get_parser(".docx")
        assert parser is not None

    def test_html_parser(self):
        parser = get_parser(".html")
        assert parser is not None

    def test_unknown_extension(self):
        parser = get_parser(".xyz")
        assert parser is None

    def test_case_insensitive(self):
        parser = get_parser(".MD")
        assert parser is not None


class TestTextParser:
    def test_parse_utf8(self, tmp_dir):
        f = tmp_dir / "test.txt"
        f.write_text("Hello world!\nThis is a test.", encoding="utf-8")

        doc = parse_file(f)
        assert doc is not None
        assert doc.content == "Hello world!\nThis is a test."
        assert doc.file_type == "text"
        assert doc.source == str(f)

    def test_parse_chinese(self, tmp_dir):
        f = tmp_dir / "zh.txt"
        f.write_text("你好世界！这是一个测试。", encoding="utf-8")

        doc = parse_file(f)
        assert doc is not None
        assert "你好" in doc.content

    def test_parse_rst(self, tmp_dir):
        f = tmp_dir / "doc.rst"
        f.write_text("Title\n=====\n\nContent here.")

        doc = parse_file(f)
        assert doc is not None
        assert doc.file_type == "text"

    def test_metadata(self, tmp_dir):
        f = tmp_dir / "test.txt"
        f.write_text("Content")

        doc = parse_file(f)
        assert doc is not None
        assert "file_size" in doc.metadata
        assert doc.metadata["file_size"] > 0


class TestMarkdownParser:
    def test_basic(self, tmp_dir):
        f = tmp_dir / "test.md"
        f.write_text("# Title\n\nParagraph one.\n\nParagraph two.")

        doc = parse_file(f)
        assert doc is not None
        assert doc.file_type == "markdown"
        assert "# Title" in doc.content

    def test_frontmatter(self, tmp_dir):
        f = tmp_dir / "test.md"
        f.write_text("---\ntitle: My Doc\nauthor: Test\n---\n\nContent here.")

        doc = parse_file(f)
        assert doc is not None
        assert doc.metadata.get("fm_title") == "My Doc"
        assert doc.metadata.get("fm_author") == "Test"

    def test_headings_extracted(self, tmp_dir):
        f = tmp_dir / "test.md"
        f.write_text("# H1\n\n## H2\n\n### H3\n\nContent.")

        doc = parse_file(f)
        assert doc is not None
        headings = doc.metadata.get("headings", [])
        assert len(headings) >= 3
        assert headings[0]["level"] == 1
        assert headings[1]["level"] == 2

    def test_no_frontmatter(self, tmp_dir):
        f = tmp_dir / "test.md"
        f.write_text("# Just content\n\nNo frontmatter here.")

        doc = parse_file(f)
        assert doc is not None
        assert "fm_" not in "".join(doc.metadata.keys())


class TestHTMLParser:
    def test_basic(self, tmp_dir):
        f = tmp_dir / "test.html"
        f.write_text(
            "<html><head><title>Test</title></head>"
            "<body><h1>Hello</h1><p>World</p></body></html>"
        )

        doc = parse_file(f)
        assert doc is not None
        assert doc.file_type == "html"
        assert "Hello" in doc.content
        assert doc.metadata.get("title") == "Test"

    def test_scripts_removed(self, tmp_dir):
        f = tmp_dir / "test.html"
        f.write_text(
            "<html><body>"
            "<script>alert('xss')</script>"
            "<p>Real content</p>"
            "</body></html>"
        )

        doc = parse_file(f)
        assert doc is not None
        assert "alert" not in doc.content
        assert "Real content" in doc.content


class TestParseFile:
    def test_nonexistent_file(self, tmp_dir):
        f = tmp_dir / "nonexistent.txt"
        result = parse_file(f)
        assert result is None

    def test_unsupported_extension(self, tmp_dir):
        f = tmp_dir / "file.xyz"
        f.write_text("content")
        result = parse_file(f)
        assert result is None  # No parser available


class TestParsedDocument:
    def test_model(self):
        doc = ParsedDocument(
            source="test.txt",
            content="Hello",
            file_type="text",
            metadata={"key": "value"},
        )
        assert doc.source == "test.txt"
        assert doc.content == "Hello"
        assert doc.metadata["key"] == "value"
