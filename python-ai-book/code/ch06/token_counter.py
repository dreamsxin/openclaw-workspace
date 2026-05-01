"""第6章 Token 计数器 — 知道用了多少 Token"""

import tiktoken


class TokenCounter:
    """Token 计数器"""

    def __init__(self, model: str = "gpt-4"):
        self.encoder = tiktoken.encoding_for_model(model)

    def count(self, text: str) -> int:
        """计算文本的 Token 数"""
        return len(self.encoder.encode(text))

    def count_messages(self, messages: list) -> int:
        """计算消息列表的总 Token 数"""
        total = 0
        for msg in messages:
            total += 4  # 每条消息的固定开销
            total += self.count(msg.get("content", ""))
        return total

    def truncate(self, text: str, max_tokens: int) -> str:
        """截断文本到指定 Token 数"""
        tokens = self.encoder.encode(text)
        if len(tokens) <= max_tokens:
            return text
        return self.encoder.decode(tokens[:max_tokens])

    def remaining_budget(self, messages: list, max_context: int = 8192) -> int:
        """计算剩余可用 Token 数"""
        used = self.count_messages(messages)
        return max(0, max_context - used)


if __name__ == "__main__":
    counter = TokenCounter()

    texts = [
        "Hello, world!",
        "这是一段中文测试文本",
        "def fibonacci(n): return n if n <= 1 else fibonacci(n-1) + fibonacci(n-2)",
    ]

    for text in texts:
        print(f"{text[:30]:30s} → {counter.count(text)} tokens")
