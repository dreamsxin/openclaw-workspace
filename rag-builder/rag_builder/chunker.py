"""Smart text chunking with CJK-aware strategies."""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from rag_builder.config import ChunkConfig
from rag_builder.parsers import ParsedDocument


@dataclass
class Chunk:
    """A single text chunk with metadata."""

    content: str
    index: int
    source: str
    metadata: dict = field(default_factory=dict)
    token_count: int = 0


# ── CJK detection ───────────────────────────────────────────────────

_CJK_RANGES = (
    r"\u4e00-\u9fff"  # CJK Unified Ideographs
    r"\u3400-\u4dbf"  # CJK Extension A
    r"\uf900-\ufaff"  # CJK Compat Ideographs
    r"\u3000-\u303f"  # CJK Symbols & Punctuation
    r"\uff00-\uffef"  # Fullwidth Forms
    r"\u3040-\u309f"  # Hiragana
    r"\u30a0-\u30ff"  # Katakana
)
_CJK_CHAR_RE = re.compile(f"[{_CJK_RANGES}]")
_CJK_OR_LATIN_RE = re.compile(
    f"[{_CJK_RANGES}]|[a-zA-Z0-9]"
)

# Chinese sentence-ending punctuation
_CJK_SENT_END = re.compile(r"[。！？；\n]")
# Chinese clause-level break points
_CJK_CLAUSE_END = re.compile(r"[，、：\u201c\u201d\u2018\u2019「」『』（）\(\)]")
# Latin sentence endings
_LATIN_SENT_END = re.compile(r"[.!?\n]")


def is_cjk_heavy(text: str) -> bool:
    """Check if text is predominantly CJK (>30% CJK chars)."""
    if not text:
        return False
    cjk_count = len(_CJK_CHAR_RE.findall(text))
    alnum_count = len(_CJK_OR_LATIN_RE.findall(text))
    return alnum_count > 0 and (cjk_count / alnum_count) > 0.3


def estimate_tokens(text: str) -> int:
    """Estimate token count.

    CJK characters: ~1.5 tokens each (BPE typically splits into 2-3 pieces)
    Latin words: ~1.3 tokens each (avg 4-5 chars per token)
    Punctuation/whitespace: ~0.3 tokens each
    """
    if not text:
        return 0

    cjk_chars = len(_CJK_CHAR_RE.findall(text))
    # Latin words (sequences of alphanumeric)
    latin_words = len(re.findall(r"[a-zA-Z0-9]+", text))
    # Everything else (punctuation, whitespace, etc.)
    remaining = max(0, len(text) - cjk_chars - sum(len(w) for w in re.findall(r"[a-zA-Z0-9]+", text)))

    return int(cjk_chars * 1.5 + latin_words * 1.3 + remaining * 0.3)


def chunk_document(doc: ParsedDocument, config: ChunkConfig | None = None) -> list[Chunk]:
    """Split a parsed document into chunks."""
    config = config or ChunkConfig()

    # Try structure-aware chunking first (headings, paragraphs)
    if doc.file_type in ("markdown", "docx"):
        chunks = _chunk_by_structure(doc, config)
    else:
        chunks = _chunk_by_paragraph(doc, config)

    # Filter small chunks
    chunks = [c for c in chunks if estimate_tokens(c.content) >= config.min_chunk_size]

    # Re-index
    for i, chunk in enumerate(chunks):
        chunk.index = i

    return chunks


def _chunk_by_structure(doc: ParsedDocument, config: ChunkConfig) -> list[Chunk]:
    """Chunk by headings and paragraphs — preserves semantic boundaries."""
    lines = doc.content.split("\n")
    sections: list[str] = []
    current_section: list[str] = []

    heading_pattern = re.compile(r"^#{1,6}\s+")

    for line in lines:
        if heading_pattern.match(line) and current_section:
            sections.append("\n".join(current_section))
            current_section = [line]
        else:
            current_section.append(line)

    if current_section:
        sections.append("\n".join(current_section))

    # Now split large sections
    chunks: list[Chunk] = []
    for section in sections:
        section = section.strip()
        if not section:
            continue

        if estimate_tokens(section) <= config.chunk_size:
            chunks.append(_make_chunk(section, doc))
        else:
            # Fall back to paragraph/sentence splitting
            sub_chunks = _split_text(section, config, is_cjk_heavy(section))
            for sc in sub_chunks:
                chunks.append(_make_chunk(sc, doc))

    return chunks


def _chunk_by_paragraph(doc: ParsedDocument, config: ChunkConfig) -> list[Chunk]:
    """Paragraph-aware chunking (for plain text, PDF, etc.)."""
    is_cjk = is_cjk_heavy(doc.content)
    texts = _split_text(doc.content, config, is_cjk)
    return [_make_chunk(t, doc) for t in texts]


def _split_text(text: str, config: ChunkConfig, cjk: bool) -> list[str]:
    """Split text into chunks respecting token limits with overlap.

    For CJK text: split on sentence boundaries (。！？) first,
    then clause boundaries (，、) if needed.
    For Latin text: split on paragraph boundaries first,
    then sentence boundaries if needed.
    """
    if cjk:
        return _split_cjk(text, config)
    else:
        return _split_latin(text, config)


def _split_cjk(text: str, config: ChunkConfig) -> list[str]:
    """CJK-aware splitting: paragraph → sentence → clause."""
    # Level 1: split on double newline (paragraphs)
    paragraphs = re.split(r"\n\s*\n", text)

    # Level 2: split long paragraphs on sentence endings
    sentences: list[str] = []
    for para in paragraphs:
        para = para.strip()
        if not para:
            continue
        if estimate_tokens(para) <= config.chunk_size:
            sentences.append(para)
        else:
            # Split on Chinese sentence endings
            parts = _split_on_pattern(para, _CJK_SENT_END)
            sentences.extend(parts)

    return _merge_chunks(sentences, config)


def _split_latin(text: str, config: ChunkConfig) -> list[str]:
    """Latin text splitting: paragraph → sentence."""
    paragraphs = re.split(r"\n\s*\n", text)

    sentences: list[str] = []
    for para in paragraphs:
        para = para.strip()
        if not para:
            continue
        if estimate_tokens(para) <= config.chunk_size:
            sentences.append(para)
        else:
            parts = _split_on_pattern(para, _LATIN_SENT_END)
            sentences.extend(parts)

    return _merge_chunks(sentences, config)


def _split_on_pattern(text: str, pattern: re.Pattern) -> list[str]:
    """Split text on regex pattern boundaries, keeping the delimiter with the preceding chunk."""
    parts: list[str] = []
    last_end = 0

    for m in pattern.finditer(text):
        end = m.end()
        segment = text[last_end:end].strip()
        if segment:
            parts.append(segment)
        last_end = end

    # Remaining text after last match
    remaining = text[last_end:].strip()
    if remaining:
        if parts:
            # Attach to last part to avoid tiny fragments
            parts[-1] = parts[-1] + remaining
        else:
            parts.append(remaining)

    # If any part is still too long, do hard character-level split
    result: list[str] = []
    for part in parts:
        if len(part) > 2000:  # Very long sentence without punctuation
            result.extend(_hard_split(part, max_chars=1500))
        else:
            result.append(part)

    return result


def _hard_split(text: str, max_chars: int = 1500) -> list[str]:
    """Last resort: split by character count at word/char boundaries."""
    chunks: list[str] = []
    while len(text) > max_chars:
        # Try to break at a space or CJK char boundary
        break_at = max_chars
        # Look for a space near the end
        space_idx = text.rfind(" ", max_chars - 100, max_chars)
        if space_idx > max_chars // 2:
            break_at = space_idx
        chunks.append(text[:break_at])
        text = text[break_at:]
    if text.strip():
        chunks.append(text)
    return chunks


def _merge_chunks(parts: list[str], config: ChunkConfig) -> list[str]:
    """Merge small parts into chunk_size-sized chunks with overlap."""
    chunks: list[str] = []
    current: list[str] = []
    current_tokens = 0

    for part in parts:
        part_tokens = estimate_tokens(part)

        # If single part exceeds chunk_size, it becomes its own chunk
        if part_tokens > config.chunk_size:
            if current:
                chunks.append(_join_parts(current))
                current = []
                current_tokens = 0
            chunks.append(part)
            continue

        if current_tokens + part_tokens > config.chunk_size and current:
            chunks.append(_join_parts(current))
            # Overlap: keep tail that fits in overlap budget
            overlap_tokens = 0
            overlap_start = len(current)
            for i in range(len(current) - 1, -1, -1):
                t = estimate_tokens(current[i])
                if overlap_tokens + t > config.chunk_overlap:
                    break
                overlap_tokens += t
                overlap_start = i
            current = current[overlap_start:]
            current_tokens = overlap_tokens

        current.append(part)
        current_tokens += part_tokens

    if current:
        chunks.append(_join_parts(current))

    return chunks


def _join_parts(parts: list[str]) -> str:
    """Join parts with appropriate separator."""
    # Detect if parts are mostly CJK
    combined = " ".join(parts)
    if is_cjk_heavy(combined):
        # CJK: join without extra spacing (Chinese doesn't need spaces)
        # But preserve paragraph breaks
        return "\n".join(p if p.endswith("\n") else p for p in parts)
    else:
        return "\n\n".join(parts)


def _make_chunk(content: str, doc: ParsedDocument) -> Chunk:
    """Create a Chunk from content and source document."""
    return Chunk(
        content=content.strip(),
        index=0,
        source=doc.source,
        metadata={**doc.metadata, "file_type": doc.file_type},
        token_count=estimate_tokens(content),
    )


def chunk_documents(docs: list[ParsedDocument], config: ChunkConfig | None = None) -> list[Chunk]:
    """Chunk multiple documents."""
    all_chunks: list[Chunk] = []
    for doc in docs:
        all_chunks.extend(chunk_document(doc, config))
    return all_chunks
