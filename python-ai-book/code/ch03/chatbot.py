"""第3章 命令行聊天机器人 — 本章知识的综合运用"""

from openai import OpenAI
from rich.console import Console

console = Console()
client = OpenAI()

messages = [
    {"role": "system", "content": "你是一个有帮助的助手，用简洁的中文回答。"}
]


def chat(user_input: str) -> str:
    """流式聊天，返回完整回复"""
    messages.append({"role": "user", "content": user_input})

    stream = client.chat.completions.create(
        model="gpt-4",
        messages=messages,
        stream=True
    )

    collected = []
    for chunk in stream:
        content = chunk.choices[0].delta.content
        if content:
            collected.append(content)
            print(content, end="", flush=True)

    answer = "".join(collected)
    messages.append({"role": "assistant", "content": answer})
    print()
    return answer


def main():
    console.print("[bold green]AI 聊天机器人[/bold green]")
    console.print("输入 'quit' 退出\n")

    while True:
        try:
            user_input = input("你: ").strip()
            if user_input.lower() in ("quit", "exit", "q"):
                break
            if not user_input:
                continue

            console.print("\n[bold blue]AI:[/bold blue] ", end="")
            chat(user_input)
            print()

        except KeyboardInterrupt:
            break

    console.print("\n再见！👋")


if __name__ == "__main__":
    main()
