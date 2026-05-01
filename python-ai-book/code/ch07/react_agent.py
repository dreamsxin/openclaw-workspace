"""第7章 ReAct Agent — 思考→行动→观察循环"""

from openai import OpenAI
import json
import re


class SimpleAgent:
    """简单的 ReAct Agent"""

    def __init__(self, model: str = "gpt-4"):
        self.client = OpenAI()
        self.model = model
        self.tools = {}
        self.system_prompt = """你是一个能使用工具的AI助手。

可用工具：
{tool_descriptions}

使用工具时，请输出JSON格式：
{{"tool": "工具名", "args": {{"参数": "值"}}}}

如果不需要工具，直接回答用户问题。
如果任务完成，在回复末尾加上 [DONE]。"""

    def register(self, name: str, func, description: str):
        """注册工具"""
        self.tools[name] = {
            "func": func,
            "description": description,
        }

    def run(self, goal: str, max_steps: int = 10) -> str:
        """执行任务"""
        tool_desc = "\n".join(
            f"- {name}: {info['description']}"
            for name, info in self.tools.items()
        )

        messages = [
            {
                "role": "system",
                "content": self.system_prompt.format(tool_descriptions=tool_desc),
            },
            {"role": "user", "content": goal},
        ]

        for step in range(max_steps):
            response = self.client.chat.completions.create(
                model=self.model, messages=messages, temperature=0
            )

            reply = response.choices[0].message.content
            messages.append({"role": "assistant", "content": reply})

            if "[DONE]" in reply:
                return reply.replace("[DONE]", "").strip()

            try:
                tool_call = self._extract_tool_call(reply)
                if tool_call:
                    result = self._execute_tool(tool_call)
                    messages.append(
                        {"role": "user", "content": f"工具结果：{result}"}
                    )
                    continue
            except Exception as e:
                messages.append(
                    {"role": "user", "content": f"工具执行错误：{e}"}
                )
                continue

            break

        return reply

    def _extract_tool_call(self, text: str) -> dict | None:
        json_match = re.search(r"\{[\s\S]*\}", text)
        if json_match:
            data = json.loads(json_match.group())
            if "tool" in data:
                return data
        return None

    def _execute_tool(self, call: dict) -> str:
        name = call["tool"]
        args = call.get("args", {})

        if name not in self.tools:
            return f"未知工具：{name}"

        return self.tools[name]["func"](**args)


if __name__ == "__main__":
    agent = SimpleAgent()

    def calculate(expression: str) -> str:
        try:
            result = eval(expression, {"__builtins__": {}}, {})
            return str(result)
        except Exception as e:
            return f"计算错误：{e}"

    def get_time() -> str:
        from datetime import datetime

        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    agent.register("calculate", calculate, "计算数学表达式，如 '2+3*4'")
    agent.register("get_time", get_time, "获取当前时间")

    result = agent.run("现在几点了？3小时后是几点？")
    print(result)
