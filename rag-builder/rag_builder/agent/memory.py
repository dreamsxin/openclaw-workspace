"""Agent memory — conversation history management."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Message:
    role: str  # "system", "user", "assistant", "tool"
    content: str
    tool_call_id: str | None = None
    name: str | None = None


@dataclass
class ConversationMemory:
    """Manages conversation history with token budget."""

    max_messages: int = 50
    messages: list[Message] = field(default_factory=list)

    def add(self, message: Message) -> None:
        self.messages.append(message)
        # Trim if too long (keep system message + recent)
        if len(self.messages) > self.max_messages:
            system_msgs = [m for m in self.messages if m.role == "system"]
            recent = [m for m in self.messages if m.role != "system"][-self.max_messages :]
            self.messages = system_msgs + recent

    def add_user(self, content: str) -> None:
        self.add(Message(role="user", content=content))

    def add_assistant(self, content: str) -> None:
        self.add(Message(role="assistant", content=content))

    def add_tool_result(self, tool_call_id: str, name: str, content: str) -> None:
        self.add(Message(role="tool", content=content, tool_call_id=tool_call_id, name=name))

    def to_openai_messages(self) -> list[dict]:
        """Convert to OpenAI API format."""
        msgs = []
        for m in self.messages:
            msg: dict = {"role": m.role, "content": m.content}
            if m.tool_call_id:
                msg["tool_call_id"] = m.tool_call_id
            if m.name:
                msg["name"] = m.name
            msgs.append(msg)
        return msgs

    def clear(self) -> None:
        """Remove ALL messages including system."""
        self.messages.clear()
