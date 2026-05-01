"""第16章 滑动窗口压缩器"""

from dataclasses import dataclass


@dataclass
class SlidingWindowCompressor:
    """滑动窗口：只保留最近 N 轮对话"""

    max_turns: int = 10
    system_prompt: str = ""

    def compress(self, messages: list[dict]) -> list[dict]:
        result = []
        if self.system_prompt:
            result.append({"role": "system", "content": self.system_prompt})

        conversation = [m for m in messages if m["role"] != "system"]
        max_messages = self.max_turns * 2

        if len(conversation) > max_messages:
            dropped = len(conversation) - max_messages
            result.append({
                "role": "system",
                "content": f"（前 {dropped // 2} 轮对话已省略）",
            })
            conversation = conversation[-max_messages:]

        result.extend(conversation)
        return result


if __name__ == "__main__":
    compressor = SlidingWindowCompressor(max_turns=3)

    messages = [{"role": "system", "content": "你是助手"}]
    for i in range(10):
        messages.append({"role": "user", "content": f"消息 {i+1}"})
        messages.append({"role": "assistant", "content": f"回复 {i+1}"})

    print(f"压缩前: {len(messages)} 条")
    compressed = compressor.compress(messages)
    print(f"压缩后: {len(compressed)} 条")
    for m in compressed:
        print(f"  [{m['role']}] {m['content'][:40]}")
