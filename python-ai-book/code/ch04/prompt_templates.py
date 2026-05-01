"""第4章 提示词模板化 — 用代码管理提示词"""

from string import Template
from dataclasses import dataclass


@dataclass
class PromptTemplates:
    """集中管理所有提示词模板"""

    # 代码审查
    CODE_REVIEW = Template("""
请审查以下 $language 代码，关注 $focus_area：

```$language
$code
```

输出格式：Markdown 列表，按严重程度排序。每个问题包含：
- 🔴/🟡/🟢 严重程度
- 问题描述
- 修复建议
""")

    # 代码翻译
    TRANSLATE = Template("""
将以下 $source_lang 代码翻译为 $target_lang：

```$source_lang
$code
```

要求：
- 保持相同的逻辑和功能
- 使用 $target_lang 的惯用写法
- 保留注释并翻译
""")

    # 文档生成
    DOCSTRING = Template("""
为以下 $language 函数生成文档：

```$language
$code
```

要求：
- 使用 $doc_style 风格
- 包含参数说明、返回值、异常
- 给出一个使用示例
""")

    # 代码解释
    EXPLAIN = Template("""
用 $level 级别解释以下代码：

```$language
$code
```

$level 要求：
- 初学者：用日常类比，避免术语
- 中级：解释设计模式和权衡
- 高级：分析复杂度和边界情况
""")


def review_code(code: str, language: str = "Python", focus: str = "性能和安全") -> str:
    """生成代码审查提示词"""
    return PromptTemplates.CODE_REVIEW.substitute(
        language=language,
        focus_area=focus,
        code=code
    )


def translate_code(code: str, source: str, target: str) -> str:
    """生成代码翻译提示词"""
    return PromptTemplates.TRANSLATE.substitute(
        source_lang=source,
        target_lang=target,
        code=code
    )


# 使用示例
if __name__ == "__main__":
    sample_code = """
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
"""

    print("=== 代码审查提示词 ===")
    print(review_code(sample_code, focus="性能"))

    print("\n=== 代码翻译提示词 ===")
    print(translate_code(sample_code, "Python", "Go"))
