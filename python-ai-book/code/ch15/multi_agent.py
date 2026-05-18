"""第15章 多 Agent 协作系统"""

import anthropic
from dataclasses import dataclass, field
from concurrent.futures import ThreadPoolExecutor


@dataclass
class Agent:
    """AI Agent 定义"""

    name: str
    role: str
    system_prompt: str
    model: str = "claude-sonnet-4-20250514"

    def __post_init__(self):
        self.client = anthropic.Anthropic()
        self.history = []

    def think(self, message: str, context: str = "") -> str:
        prompt = message
        if context:
            prompt = f"上下文：\n{context}\n\n任务：{message}"

        self.history.append({"role": "user", "content": prompt})

        response = self.client.messages.create(
            model=self.model,
            max_tokens=2000,
            system=self.system_prompt,
            messages=self.history,
        )

        answer = response.content[0].text
        self.history.append({"role": "assistant", "content": answer})
        return answer


@dataclass
class Team:
    name: str
    agents: list[Agent] = field(default_factory=list)

    def add_agent(self, agent: Agent):
        self.agents.append(agent)


class MultiAgentSystem:
    """多 Agent 协作系统"""

    def __init__(self):
        self.teams: dict[str, Team] = {}
        self.results: dict[str, str] = {}

    def create_team(self, name: str) -> Team:
        team = Team(name)
        self.teams[name] = team
        return team

    def pipeline(self, agents: list[Agent], task: str) -> str:
        """管道模式：顺序执行"""
        current = task
        for agent in agents:
            print(f"  🔄 {agent.name} 处理中...")
            current = agent.think(current)
            self.results[agent.name] = current
            print(f"  ✅ {agent.name} 完成")
        return current

    def debate(self, agents: list[Agent], topic: str, rounds: int = 3) -> str:
        """辩论模式：多轮讨论"""
        discussion = [f"议题：{topic}"]

        for round_num in range(rounds):
            print(f"\n  📢 第 {round_num + 1} 轮辩论")
            for agent in agents:
                context = "\n".join(discussion)
                response = agent.think(
                    f"请从你的专业角度发表看法（第{round_num+1}轮）", context
                )
                discussion.append(f"[{agent.name}]：{response}")
                print(f"    💬 {agent.name} 发言")

        synthesizer = Agent(
            name="综合者",
            role="综合各方观点",
            system_prompt="你是一个善于总结的专家，综合各方观点给出最终建议。",
        )
        return synthesizer.think("综合以上讨论，给出最终结论", "\n".join(discussion))

    def expert_panel(self, experts: list[Agent], question: str) -> str:
        """专家团模式：并行分析，综合结论"""
        print(f"\n  🎯 启动专家团（{len(experts)} 位专家）")

        with ThreadPoolExecutor(max_workers=len(experts)) as executor:
            futures = {
                executor.submit(agent.think, question): agent.name
                for agent in experts
            }
            opinions = {}
            for future in futures:
                name = futures[future]
                opinions[name] = future.result()
                print(f"    📝 {name} 提交意见")

        context = "\n\n".join(
            f"【{name}的意见】\n{opinion}" for name, opinion in opinions.items()
        )

        synthesizer = Agent(
            name="决策者",
            role="综合专家意见做出决策",
            system_prompt="你是一个项目负责人，综合各专家意见，做出最终决策。",
        )
        return synthesizer.think("综合各专家意见，给出最终方案", context)


if __name__ == "__main__":
    system = MultiAgentSystem()

    experts = [
        Agent(
            name="架构师",
            role="系统架构",
            system_prompt="你是资深架构师，关注系统架构、可扩展性、技术选型。",
        ),
        Agent(
            name="安全专家",
            role="安全审计",
            system_prompt="你是安全专家，关注数据安全、认证授权、常见漏洞。",
        ),
        Agent(
            name="产品经理",
            role="用户体验",
            system_prompt="你是产品经理，关注用户需求、功能完整性、MVP定义。",
        ),
    ]

    result = system.expert_panel(
        experts, "评审一个实时协作文档编辑器的技术方案"
    )
    print("\n" + "=" * 60)
    print(result)
