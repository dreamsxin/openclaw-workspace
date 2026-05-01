"""第10章 AI 代码审查器"""

import anthropic


class CodeReviewer:
    """AI 代码审查器"""

    def __init__(self, model: str = "claude-sonnet-4-20250514"):
        self.client = anthropic.Anthropic()
        self.model = model

    def review(self, code: str, language: str = "Python") -> str:
        """审查代码"""
        prompt = f"""请审查以下 {language} 代码，按以下维度分析：

1. 🔴 **严重问题**（会导致崩溃或安全漏洞）
2. 🟡 **改进建议**（性能、可读性、最佳实践）
3. 🟢 **优点**（做得好的地方）

代码：
```{language}
{code}
```

请用 Markdown 格式输出审查结果。"""

        response = self.client.messages.create(
            model=self.model,
            max_tokens=2000,
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text

    def suggest_fix(self, code: str, issue: str) -> str:
        """针对特定问题建议修复"""
        prompt = f"""代码：
```python
{code}
```

问题：{issue}

请提供修复后的完整代码，只输出代码，不要解释。"""

        response = self.client.messages.create(
            model=self.model,
            max_tokens=1000,
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text


if __name__ == "__main__":
    reviewer = CodeReviewer()

    sample_code = """
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.execute(query)
    return result
"""

    print(reviewer.review(sample_code))
