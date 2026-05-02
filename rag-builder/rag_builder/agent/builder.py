"""Agent builder — assembles the RAG agent with tool-calling loop."""

from __future__ import annotations

import json
from typing import Any

from rag_builder.agent.memory import ConversationMemory, Message
from rag_builder.agent.tools import get_tool_definitions, search_knowledge_base
from rag_builder.config import LLMConfig, LLMProvider
from rag_builder.retriever import Retriever

SYSTEM_PROMPT = """你是一个知识库问答助手。根据检索到的知识库内容回答用户的问题。

规则：
1. 回答事实性问题前，必须先检索知识库。
2. 基于检索到的信息回答——不要编造内容。
3. 如果知识库中没有相关信息，如实说明。
4. 尽可能引用来源（提及文档名称）。
5. 简洁但完整地回答。"""


def _build_client(llm_config: LLMConfig):
    """Create an OpenAI-compatible client for any provider."""
    from openai import OpenAI

    if llm_config.provider == LLMProvider.OLLAMA:
        return OpenAI(
            base_url=llm_config.base_url or "http://localhost:11434/v1",
            api_key="ollama",
        )
    elif llm_config.provider == LLMProvider.DEEPSEEK:
        return OpenAI(
            api_key=llm_config.api_key,
            base_url=llm_config.base_url or "https://api.deepseek.com/v1",
        )
    else:
        return OpenAI(
            api_key=llm_config.api_key,
            base_url=llm_config.base_url,
        )


class RAGAgent:
    """RAG Agent with tool-calling loop."""

    def __init__(
        self,
        retriever: Retriever,
        llm_config: LLMConfig,
        system_prompt: str | None = None,
    ):
        self.retriever = retriever
        self.llm_config = llm_config
        self.memory = ConversationMemory()
        self.tools = get_tool_definitions()
        self._client = None

        # Set system prompt
        self.memory.add(Message(role="system", content=system_prompt or SYSTEM_PROMPT))

    @property
    def _get_client(self):
        if self._client is None:
            self._client = _build_client(self.llm_config)
        return self._client

    def chat(self, user_message: str) -> str:
        """Process a user message and return the assistant's response."""
        self.memory.add_user(user_message)

        # Tool-calling loop (max 3 iterations to prevent runaway)
        for _ in range(3):
            response = self._call_llm()
            message = response.choices[0].message

            if message.tool_calls:
                # Execute tools
                self.memory.messages.append(
                    Message(
                        role="assistant",
                        content=message.content or "",
                    )
                )

                for tool_call in message.tool_calls:
                    result = self._execute_tool(
                        tool_call.function.name,
                        tool_call.function.arguments,
                    )
                    self.memory.add_tool_result(
                        tool_call_id=tool_call.id,
                        name=tool_call.function.name,
                        content=result,
                    )
            else:
                # No tool calls — we have a final answer
                answer = message.content or ""
                self.memory.add_assistant(answer)
                return answer

        # Fallback
        answer = "抱歉，我无法找到完整的答案。请尝试换一种方式提问。"
        self.memory.add_assistant(answer)
        return answer

    def _call_llm(self) -> Any:
        """Call the LLM with current conversation + tools."""
        return self._get_client.chat.completions.create(
            model=self.llm_config.model,
            messages=self.memory.to_openai_messages(),
            tools=self.tools,
            tool_choice="auto",
            temperature=self.llm_config.temperature,
            max_tokens=self.llm_config.max_tokens,
        )

    def _execute_tool(self, name: str, arguments: str) -> str:
        """Execute a tool call."""
        args = json.loads(arguments)

        if name == "search_knowledge_base":
            return search_knowledge_base(self.retriever, args["query"])
        else:
            return f"Unknown tool: {name}"

    def reset(self) -> None:
        """Clear conversation (keep system prompt)."""
        self.memory.clear()
        self.memory.add(Message(role="system", content=SYSTEM_PROMPT))
        # Clear cached client to allow config changes
        self._client = None
