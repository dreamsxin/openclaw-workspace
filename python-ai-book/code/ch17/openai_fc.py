"""第17章 OpenAI Function Calling 完整示例"""

from openai import OpenAI
import json

client = OpenAI()

# ── 工具定义 ──

tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "获取指定城市的当前天气",
            "parameters": {
                "type": "object",
                "properties": {
                    "city": {"type": "string", "description": "城市名称"},
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "description": "温度单位",
                    },
                },
                "required": ["city"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "calculate",
            "description": "计算数学表达式",
            "parameters": {
                "type": "object",
                "properties": {
                    "expression": {"type": "string", "description": "数学表达式，如 '2+3*4'"},
                },
                "required": ["expression"],
            },
        },
    },
]


# ── 函数实现 ──


def get_weather(city: str, unit: str = "celsius") -> dict:
    data = {"北京": {"temp": 25, "condition": "晴"}, "上海": {"temp": 22, "condition": "多云"}}
    weather = data.get(city, {"temp": 20, "condition": "未知"})
    return {"city": city, "unit": unit, **weather}


def calculate(expression: str) -> dict:
    try:
        result = eval(expression, {"__builtins__": {}}, {})
        return {"expression": expression, "result": result}
    except Exception as e:
        return {"expression": expression, "error": str(e)}


FUNCTIONS = {"get_weather": get_weather, "calculate": calculate}


# ── 调用流程 ──


def chat_with_tools(user_message: str) -> str:
    messages = [{"role": "user", "content": user_message}]

    response = client.chat.completions.create(
        model="gpt-4", messages=messages, tools=tools, tool_choice="auto"
    )

    msg = response.choices[0].message

    if msg.tool_calls:
        messages.append(msg)

        for tool_call in msg.tool_calls:
            func_name = tool_call.function.name
            func_args = json.loads(tool_call.function.arguments)
            func = FUNCTIONS.get(func_name)

            result = func(**func_args) if func else {"error": f"未知函数: {func_name}"}
            print(f"  🔧 {func_name}({func_args}) → {result}")

            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": json.dumps(result, ensure_ascii=False),
            })

        final = client.chat.completions.create(model="gpt-4", messages=messages)
        return final.choices[0].message.content

    return msg.content


if __name__ == "__main__":
    print(chat_with_tools("北京今天天气怎么样？"))
    print()
    print(chat_with_tools("帮我算一下 (25+17)*3"))
