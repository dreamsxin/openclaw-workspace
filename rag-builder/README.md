# 🚀 rag-builder

**One-click RAG + Agent knowledge base generator.**

Point it at your documents → get a fully working RAG + Agent project.

## Features

- 📄 **Multi-format parsing** — PDF, Markdown, TXT, DOCX, HTML
- ✂️ **Smart chunking** — Structure-aware splitting (headings, paragraphs)
- 🧠 **Multiple embedders** — OpenAI, BGE, Jina (API or local)
- 💾 **Vector stores** — ChromaDB (default) or FAISS
- 🤖 **Agent with tools** — LLM-powered tool-calling loop with knowledge base search
- 🌐 **Web UI** — Streamlit frontend included
- ⚡ **Multi-LLM** — OpenAI API or Ollama (local models)

## Installation

```bash
# From source (development)
cd rag-builder
pip install -e .

# With FAISS support
pip install -e ".[faiss]"

# With local embedding models
pip install -e ".[local]"
```

## Quick Start

```bash
# Generate a project from your documents
rag-builder init ./my-docs -n my-kb -o ./output

# With specific options
rag-builder init ./docs \
  --llm openai \
  --llm-model gpt-4o-mini \
  --embedder openai \
  --vectorstore chroma \
  --with-agent \
  --with-frontend

# Preview without generating
rag-builder init ./docs --dry-run

# Standalone incremental indexing
rag-builder index ./docs
rag-builder index ./docs --rebuild    # full rebuild
rag-builder index --status            # show index status
```

## CLI Reference

### `rag-builder init`

Generate a RAG project from documents.

```
rag-builder init SOURCE_DIR [OPTIONS]

Arguments:
  SOURCE_DIR              Directory containing your documents

Options:
  -o, --output PATH       Output directory (default: ./output)
  -n, --name TEXT         Project name (default: my-rag-project)
  --llm TEXT              LLM provider: openai, ollama (default: openai)
  --llm-model TEXT        LLM model name (default: gpt-4o-mini)
  --llm-base-url TEXT     Custom LLM API base URL
  --embedder TEXT         Embedder: openai, bge, jina (default: openai)
  --embedder-model TEXT   Embedding model (default: text-embedding-3-small)
  --vectorstore TEXT      Vector store: chroma, faiss (default: chroma)
  --with-agent / --no-agent    Include agent (default: True)
  --with-frontend / --no-frontend  Include Streamlit UI (default: True)
  --chunk-size INT        Chunk size in tokens (default: 512)
  --chunk-overlap INT     Chunk overlap in tokens (default: 64)
  --top-k INT             Retrieval top-k (default: 5)
  --dry-run               Preview summary without generating
```

### `rag-builder chat`

Interactive chat with a generated project.

```bash
rag-builder chat ./output/my-kb
```

### `rag-builder index`

Incremental document indexing. Only processes new/modified files, removes deleted files.

```bash
# Incremental update (default)
rag-builder index ./docs

# Standalone with custom vector store dir
rag-builder index ./docs -d ./my-vectors --embedder bge --embedder-model BAAI/bge-large-zh-v1.5

# Full rebuild (clear and re-index everything)
rag-builder index ./docs --rebuild

# Show index status
rag-builder index --status   # or: rag-builder status ./vectorstore
```

### `rag-builder status`

Show current index manifest (file count, chunk count, last update).

```bash
rag-builder status ./vectorstore
```

## Generated Project Structure

```
my-kb/
├── main.py           # CLI chat interface
├── index_docs.py     # Index documents into vector store
├── app.py            # Streamlit web UI
├── .env              # Configuration
├── requirements.txt  # Dependencies
├── README.md         # Project documentation
└── vectorstore/      # Auto-created vector database
```

## Using with Ollama (Local)

```bash
rag-builder init ./docs \
  --llm ollama \
  --llm-model llama3 \
  --llm-base-url http://localhost:11434/v1 \
  --embedder bge \
  --embedder-model BAAI/bge-large-zh-v1.5
```

## Architecture

```
Documents → Parse → Chunk → Embed → Vector Store
                                          ↓
User Query → Embed → Search → Rerank → Context
                                          ↓
                            LLM + Tools → Answer
```

## Incremental Indexing

rag-builder tracks indexed files via a manifest (`index_manifest.json`):
- **Content hash** (SHA-256) detects actual content changes (not just mtime)
- **New files** → parsed, chunked, embedded, added
- **Modified files** → old vectors deleted, re-indexed
- **Deleted files** → vectors removed automatically

```bash
# First run: full index
rag-builder index ./docs
# → 25 files, 1200 chunks

# Add 2 new files, modify 1
rag-builder index ./docs
# → 新增 2, 修改 1, 未变 22
# → Only 3 files processed

# Remove a file
rm ./docs/old-report.pdf
rag-builder index ./docs
# → 删除 1, 未变 24
```

## License

MIT
