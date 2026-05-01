"""第3章 Hello Local — 使用 Ollama 本地模型（无需 API 密钥）"""

from openai import OpenAI

# Ollama 兼容 OpenAI 接口
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"  # 随便填，Ollama 不验证
)

response = client.chat.completions.create(
    model="qwen2.5:7b",
    messages=[
        {"role": "user", "content": "用一句话介绍Python"}
    ]
)

print(response.choices[0].message.content)
