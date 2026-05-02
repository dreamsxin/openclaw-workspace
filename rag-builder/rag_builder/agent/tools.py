"""Agent tools — tools the RAG agent can use."""

from __future__ import annotations

from typing import Any

from rag_builder.retriever import Retriever


def search_knowledge_base(retriever: Retriever, query: str) -> str:
    """Search the knowledge base for relevant information."""
    results = retriever.retrieve(query)
    if not results:
        return "未在知识库中找到相关信息。"

    output_parts = []
    for i, r in enumerate(results, 1):
        source = r.chunk.source.split("/")[-1]
        output_parts.append(
            f"[{i}] (相关度: {r.score:.3f}) 来源: {source}\n{r.chunk.content}"
        )

    return "\n\n".join(output_parts)


def get_tool_definitions() -> list[dict[str, Any]]:
    """Get OpenAI-compatible tool definitions for the agent."""
    return [
        {
            "type": "function",
            "function": {
                "name": "search_knowledge_base",
                "description": (
                    "检索知识库，查找与用户问题相关的信息。"
                    "当用户询问可能涉及已加载文档内容的问题时，必须先调用此工具检索。"
                    "在回答事实性问题前，始终先搜索知识库。"
                ),
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "搜索关键词——使用文档中的具体术语，提高检索精度",
                        }
                    },
                    "required": ["query"],
                },
            },
        }
    ]
