"""PDF parser using pypdf."""

from __future__ import annotations

from pathlib import Path

from rag_builder.parsers import ParsedDocument


class PdfParser:
    """Extract text from PDF files."""

    def parse(self, file_path: Path) -> ParsedDocument:
        from pypdf import PdfReader

        reader = PdfReader(str(file_path))
        pages = []
        for i, page in enumerate(reader.pages):
            text = page.extract_text()
            if text and text.strip():
                pages.append(f"[Page {i + 1}]\n{text}")

        return ParsedDocument(
            source=str(file_path),
            content="\n\n".join(pages),
            metadata={
                "page_count": len(reader.pages),
                "file_size": file_path.stat().st_size,
            },
            file_type="pdf",
        )
