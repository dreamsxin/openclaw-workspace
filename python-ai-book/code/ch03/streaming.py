"""第3章 流式输出 — 逐字输出体验更好"""

from openai import OpenAI

client = OpenAI()


def stream_chat(prompt: str):
    """流式输出 AI 回复"""
    stream = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        stream=True
    )

    for chunk in stream:
        content = chunk.choices[0].delta.content
        if content:
            print(content, end="", flush=True)

    print()  # 换行


if __name__ == "__main__":
    print("流式输出示例\n")
    stream_chat("写一首关于Python的短诗，四句即可")
