"""Plain text parser."""

from __future__ import annotations

from pathlib import Path

import chardet

from rag_builder.parsers import ParsedDocument


class TextParser:
    """Parse plain text files (.txt, .rst, etc.)."""

    def parse(self, file_path: Path) -> ParsedDocument:
        raw_bytes = file_path.read_bytes()
        detected = chardet.detect(raw_bytes)
        encoding = detected.get("encoding") or "utf-8"

        try:
            content = raw_bytes.decode(encoding, errors="replace")
        except (UnicodeDecodeError, LookupError):
            content = raw_bytes.decode("utf-8", errors="replace")

        return ParsedDocument(
            source=str(file_path),
            content=content,
            metadata={
                "file_size": file_path.stat().st_size,
                "encoding": encoding,
            },
            file_type="text",
        )
