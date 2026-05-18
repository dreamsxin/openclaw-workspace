"""Document parsers — unified interface for all file formats."""

from __future__ import annotations

from pathlib import Path
from typing import Protocol

from pydantic import BaseModel


class ParsedDocument(BaseModel):
    """A parsed document with metadata."""

    source: str  # file path
    content: str  # extracted text
    metadata: dict = {}
    file_type: str = ""

    class Config:
        frozen = False


class BaseParser(Protocol):
    """Protocol all parsers must implement."""

    def parse(self, file_path: Path) -> ParsedDocument: ...


# Lazy-loaded parser registry
_PARSERS: dict[str, type] = {}


def get_parser(file_ext: str) -> BaseParser | None:
    """Get the appropriate parser for a file extension."""
    _load_parsers()
    cls = _PARSERS.get(file_ext.lower())
    return cls() if cls else None


def _load_parsers() -> None:
    if _PARSERS:
        return
    from rag_builder.parsers.docx_parser import DocxParser
    from rag_builder.parsers.html_parser import HtmlParser
    from rag_builder.parsers.markdown_parser import MarkdownParser
    from rag_builder.parsers.pdf_parser import PdfParser
    from rag_builder.parsers.text_parser import TextParser

    _PARSERS.update(
        {
            ".pdf": PdfParser,
            ".md": MarkdownParser,
            ".markdown": MarkdownParser,
            ".txt": TextParser,
            ".rst": TextParser,
            ".docx": DocxParser,
            ".html": HtmlParser,
            ".htm": HtmlParser,
        }
    )


def parse_file(file_path: Path) -> ParsedDocument | None:
    """Parse a single file. Returns None if no parser available."""
    parser = get_parser(file_path.suffix)
    if parser is None:
        return None
    try:
        doc = parser.parse(file_path)
        return doc
    except Exception as e:
        print(f"⚠ Failed to parse {file_path}: {e}")
        return None
