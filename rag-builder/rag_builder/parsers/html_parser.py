"""HTML parser using BeautifulSoup."""

from __future__ import annotations

from pathlib import Path

from rag_builder.parsers import ParsedDocument


class HtmlParser:
    """Extract text from HTML files."""

    def parse(self, file_path: Path) -> ParsedDocument:
        from bs4 import BeautifulSoup

        raw = file_path.read_text(encoding="utf-8", errors="replace")
        soup = BeautifulSoup(raw, "html.parser")

        # Remove script and style elements
        for tag in soup(["script", "style", "nav", "footer", "header"]):
            tag.decompose()

        # Extract title
        title = soup.title.string.strip() if soup.title and soup.title.string else ""
        content = soup.get_text(separator="\n", strip=True)

        return ParsedDocument(
            source=str(file_path),
            content=content,
            metadata={
                "title": title,
                "file_size": file_path.stat().st_size,
            },
            file_type="html",
        )
