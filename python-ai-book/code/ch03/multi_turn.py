"""第3章 多轮对话 — 维护对话历史"""

from openai import OpenAI

client = OpenAI()

# 对话历史
messages = [
    {"role": "system", "content": "你是一个友好的Python导师"}
]


def chat(user_input: str) -> str:
    """发送消息并维护对话历史"""
    messages.append({"role": "user", "content": user_input})

    response = client.chat.completions.create(
        model="gpt-4",
        messages=messages
    )

    answer = response.choices[0].message.content
    messages.append({"role": "assistant", "content": answer})
    return answer


if __name__ == "__main__":
    print("Python 导师 (输入 quit 退出)\n")

    while True:
        user_input = input("你: ").strip()
        if user_input.lower() in ("quit", "exit", "q"):
            break
        if not user_input:
            continue

        answer = chat(user_input)
        print(f"导师: {answer}\n")
