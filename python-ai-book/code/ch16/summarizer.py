"""第16章 摘要压缩器"""

import anthropic
from dataclasses import dataclass


@dataclass
class SummarizerCompressor:
    """用 AI 将早期对话压缩成摘要"""

    model: str = "claude-sonnet-4-20250514"
    max_recent_turns: int = 4
    summary_max_tokens: int = 300

    def __post_init__(self):
        self.client = anthropic.Anthropic()

    def compress(self, messages: list[dict]) -> list[dict]:
        system = [m for m in messages if m["role"] == "system"]
        conversation = [m for m in messages if m["role"] != "system"]

        if len(conversation) <= self.max_recent_turns * 2:
            return messages

        split_point = len(conversation) - self.max_recent_turns * 2
        to_summarize = conversation[:split_point]
        to_keep = conversation[split_point:]

        summary = self._generate_summary(to_summarize)

        result = system.copy()
        result.append({"role": "system", "content": f"以下是之前对话的摘要：\n\n{summary}"})
        result.extend(to_keep)
        return result

    def _generate_summary(self, messages: list[dict]) -> str:
        conversation_text = "\n".join(
            f"{'用户' if m['role'] == 'user' else 'AI'}: {m['content']}"
            for m in messages
        )

        response = self.client.messages.create(
            model=self.model,
            max_tokens=self.summary_max_tokens,
            messages=[{
                "role": "user",
                "content": f"""请将以下对话压缩为简短摘要。

要求：
- 保留关键信息（用户的需求、决策、结论）
- 保留重要的技术细节
- 丢弃闲聊和重复内容
- 控制在 200 字以内

对话内容：
{conversation_text}""",
            }],
        )
        return response.content[0].text


if __name__ == "__main__":
    compressor = SummarizerCompressor(max_recent_turns=2)

    messages = [
        {"role": "system", "content": "你是助手"},
        {"role": "user", "content": "我要写一个Web应用"},
        {"role": "assistant", "content": "好的，用FastAPI还是Flask？"},
        {"role": "user", "content": "FastAPI"},
        {"role": "assistant", "content": "推荐项目结构..."},
        {"role": "user", "content": "帮我实现用户认证"},
        {"role": "assistant", "content": "使用JWT方案..."},
        {"role": "user", "content": "数据库怎么选？"},
    ]

    compressed = compressor.compress(messages)
    print(f"压缩前: {len(messages)} 条 → 压缩后: {len(compressed)} 条")
    for m in compressed:
        print(f"  [{m['role']}] {m['content'][:60]}")
