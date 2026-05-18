"""Tests for agent module (mock-based)."""

from __future__ import annotations

from unittest.mock import MagicMock, patch

from rag_builder.agent.memory import ConversationMemory, Message
from rag_builder.agent.tools import get_tool_definitions, search_knowledge_base
from rag_builder.config import LLMConfig, LLMProvider


class TestConversationMemory:
    def test_empty(self):
        mem = ConversationMemory()
        assert mem.messages == []
        assert mem.to_openai_messages() == []

    def test_add_messages(self):
        mem = ConversationMemory()
        mem.add_user("Hello")
        mem.add_assistant("Hi there!")

        assert len(mem.messages) == 2
        assert mem.messages[0].role == "user"
        assert mem.messages[1].role == "assistant"

    def test_to_openai_format(self):
        mem = ConversationMemory()
        mem.add(Message(role="system", content="You are helpful."))
        mem.add_user("Hello")

        msgs = mem.to_openai_messages()
        assert len(msgs) == 2
        assert msgs[0] == {"role": "system", "content": "You are helpful."}
        assert msgs[1] == {"role": "user", "content": "Hello"}

    def test_tool_message_format(self):
        mem = ConversationMemory()
        mem.add_tool_result("call_123", "search", "result text")

        msgs = mem.to_openai_messages()
        assert len(msgs) == 1
        assert msgs[0]["tool_call_id"] == "call_123"
        assert msgs[0]["name"] == "search"

    def test_max_messages_trim(self):
        mem = ConversationMemory(max_messages=5)
        mem.add(Message(role="system", content="System"))

        for i in range(10):
            mem.add_user(f"msg {i}")
            mem.add_assistant(f"reply {i}")

        # Should keep system + last 5 non-system messages
        non_system = [m for m in mem.messages if m.role != "system"]
        assert len(non_system) <= 5

    def test_clear(self):
        mem = ConversationMemory()
        mem.add(Message(role="system", content="System"))
        mem.add_user("Hello")
        mem.add_assistant("Hi")

        mem.clear()
        # clear() removes ALL messages
        assert len(mem.messages) == 0


class TestTools:
    def test_tool_definitions(self):
        tools = get_tool_definitions()
        assert len(tools) == 1
        assert tools[0]["type"] == "function"
        assert tools[0]["function"]["name"] == "search_knowledge_base"
        assert "query" in tools[0]["function"]["parameters"]["properties"]

    def test_search_knowledge_base_no_results(self):
        mock_retriever = MagicMock()
        mock_retriever.retrieve.return_value = []

        result = search_knowledge_base(mock_retriever, "test query")
        assert "未" in result and "找到" in result

    def test_search_knowledge_base_with_results(self):
        from rag_builder.chunker import Chunk
        from rag_builder.vectorstore import SearchResult

        mock_retriever = MagicMock()
        mock_retriever.retrieve.return_value = [
            SearchResult(
                chunk=Chunk(
                    content="AI is artificial intelligence.",
                    index=0,
                    source="ai.txt",
                    metadata={"file_type": "text"},
                    token_count=5,
                ),
                score=0.95,
            ),
        ]

        result = search_knowledge_base(mock_retriever, "what is AI")
        assert "AI" in result
        assert "0.95" in result
        assert "ai.txt" in result


class TestRAGAgent:
    @patch("rag_builder.agent.builder._build_client")
    def test_chat_simple(self, mock_build_client):
        """Agent should return response when no tool calls."""
        mock_client = MagicMock()
        mock_build_client.return_value = mock_client

        # Mock LLM response (no tool calls)
        mock_message = MagicMock()
        mock_message.content = "Hello! How can I help?"
        mock_message.tool_calls = None
        mock_response = MagicMock()
        mock_response.choices = [MagicMock(message=mock_message)]
        mock_client.chat.completions.create.return_value = mock_response

        from rag_builder.agent.builder import RAGAgent

        agent = RAGAgent(
            retriever=MagicMock(),
            llm_config=LLMConfig(provider=LLMProvider.OPENAI),
        )
        result = agent.chat("Hi")

        assert result == "Hello! How can I help?"

    @patch("rag_builder.agent.builder._build_client")
    def test_chat_with_tool_call(self, mock_build_client):
        """Agent should execute tools and continue conversation."""
        mock_client = MagicMock()
        mock_build_client.return_value = mock_client

        # First response: tool call
        tool_call = MagicMock()
        tool_call.id = "call_123"
        tool_call.function.name = "search_knowledge_base"
        tool_call.function.arguments = '{"query": "AI"}'

        msg_with_tool = MagicMock()
        msg_with_tool.content = ""
        msg_with_tool.tool_calls = [tool_call]

        # Second response: final answer
        msg_final = MagicMock()
        msg_final.content = "AI stands for artificial intelligence."
        msg_final.tool_calls = None

        mock_client.chat.completions.create.side_effect = [
            MagicMock(choices=[MagicMock(message=msg_with_tool)]),
            MagicMock(choices=[MagicMock(message=msg_final)]),
        ]

        from rag_builder.agent.builder import RAGAgent

        mock_retriever = MagicMock()
        mock_retriever.retrieve.return_value = []

        agent = RAGAgent(
            retriever=mock_retriever,
            llm_config=LLMConfig(provider=LLMProvider.OPENAI),
        )
        result = agent.chat("What is AI?")

        assert "artificial intelligence" in result.lower()
        # LLM should have been called twice (tool call + final)
        assert mock_client.chat.completions.create.call_count == 2

    @patch("rag_builder.agent.builder._build_client")
    def test_reset(self, mock_build_client):
        mock_client = MagicMock()
        mock_build_client.return_value = mock_client

        from rag_builder.agent.builder import RAGAgent

        agent = RAGAgent(
            retriever=MagicMock(),
            llm_config=LLMConfig(provider=LLMProvider.OPENAI),
        )
        # __init__ adds 1 system message
        assert len(agent.memory.messages) == 1

        agent.memory.add_user("test")
        agent.memory.add_assistant("reply")
        assert len(agent.memory.messages) == 3

        agent.reset()
        # Should only have 1 system message after reset
        assert len(agent.memory.messages) == 1
        assert agent.memory.messages[0].role == "system"
