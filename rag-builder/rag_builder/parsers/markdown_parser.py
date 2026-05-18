"""Markdown parser with structure preservation."""

from __future__ import annotations

from pathlib import Path

from rag_builder.parsers import ParsedDocument


class MarkdownParser:
    """Parse Markdown files, preserving structure."""

    def parse(self, file_path: Path) -> ParsedDocument:
        raw = file_path.read_text(encoding="utf-8", errors="replace")

        # Extract frontmatter if present
        metadata = {"file_size": file_path.stat().st_size}
        content = raw

        if raw.startswith("---"):
            parts = raw.split("---", 2)
            if len(parts) >= 3:
                frontmatter = parts[1].strip()
                content = parts[2].strip()
                for line in frontmatter.split("\n"):
                    if ":" in line:
                        key, val = line.split(":", 1)
                        metadata[f"fm_{key.strip()}"] = val.strip()

        # Extract headings for structure
        headings = []
        for line in content.split("\n"):
            if line.startswith("#"):
                level = len(line) - len(line.lstrip("#"))
                headings.append({"level": level, "text": line.lstrip("# ").strip()})
        metadata["headings"] = headings[:20]  # cap at 20

        return ParsedDocument(
            source=str(file_path),
            content=content,
            metadata=metadata,
            file_type="markdown",
        )
