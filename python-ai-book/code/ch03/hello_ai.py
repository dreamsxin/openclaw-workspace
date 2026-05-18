"""第3章 Hello AI — 最简单的 AI 调用"""

from openai import OpenAI

client = OpenAI()  # 自动读取 OPENAI_API_KEY 环境变量

response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "user", "content": "用一句话介绍Python"}
    ]
)

print(response.choices[0].message.content)
