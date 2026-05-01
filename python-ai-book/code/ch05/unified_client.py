"""第5章 统一 AI 客户端 — 写一次代码，云端和本地都能跑"""

from openai import OpenAI
from dataclasses import dataclass
from enum import Enum


class Backend(Enum):
    OPENAI = "openai"
    OLLAMA = "ollama"
    VLLM = "vllm"


@dataclass
class AIConfig:
    backend: Backend
    model: str
    base_url: str | None = None
    api_key: str | None = None


class UnifiedAI:
    """统一的 AI 客户端，支持多种后端"""

    def __init__(self, config: AIConfig):
        self.config = config

        if config.backend == Backend.OPENAI:
            self.client = OpenAI(api_key=config.api_key)
        elif config.backend == Backend.OLLAMA:
            self.client = OpenAI(
                base_url="http://localhost:11434/v1",
                api_key="ollama"
            )
        elif config.backend == Backend.VLLM:
            self.client = OpenAI(
                base_url=config.base_url or "http://localhost:8000/v1",
                api_key="not-needed"
            )
        else:
            raise ValueError(f"Unknown backend: {config.backend}")

    def chat(self, message: str, system: str = "", **kwargs) -> str:
        """发送消息并返回回复"""
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": message})

        response = self.client.chat.completions.create(
            model=self.config.model,
            messages=messages,
            **kwargs
        )
        return response.choices[0].message.content

    def stream_chat(self, message: str, system: str = "", **kwargs):
        """流式输出"""
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": message})

        stream = self.client.chat.completions.create(
            model=self.config.model,
            messages=messages,
            stream=True,
            **kwargs
        )

        for chunk in stream:
            content = chunk.choices[0].delta.content
            if content:
                yield content


if __name__ == "__main__":
    # 切换后端只需要改这里
    config = AIConfig(
        backend=Backend.OLLAMA,
        model="qwen2.5:7b"
    )

    ai = UnifiedAI(config)

    # 普通调用
    print("=== 普通调用 ===")
    print(ai.chat("用一句话介绍Python"))

    # 流式调用
    print("\n=== 流式调用 ===")
    for chunk in ai.stream_chat("写一首关于代码的短诗"):
        print(chunk, end="", flush=True)
    print()
