"""第3章 Hello Claude — 使用 Anthropic SDK"""

import anthropic

client = anthropic.Anthropic()  # 自动读取 ANTHROPIC_API_KEY

message = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "用一句话介绍Python"}
    ]
)

print(message.content[0].text)
