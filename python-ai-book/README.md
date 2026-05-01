# Python AI 绑定

> 从零到一掌握 AI 驱动的 Python 开发 —— Claude Code & OpenClaw 实战指南

**作者：Dreamszhu**

---

## 📖 目录

### 第1部分：基础入门

| 章节 | 标题 | 核心内容 |
|------|------|----------|
| [第1章](chapters/ch01.md) | 环境搭建 | Python 环境、依赖库、本地模型配置 |
| [第2章](chapters/ch02.md) | AI 绑定概念 | 什么是 Python ↔ AI 的绑定，核心原理 |
| [第3章](chapters/ch03.md) | 第一次 AI 交互 | Hello World 级别的 AI 调用 |

### 第2部分：核心技能

| 章节 | 标题 | 核心内容 |
|------|------|----------|
| [第4章](chapters/ch04.md) | Prompt 工程基础 | 提示词设计、模板、链式调用 |
| [第5章](chapters/ch05.md) | API 调用与本地推理 | 云端 API vs 本地模型，Ollama/vLLM |
| [第6章](chapters/ch06.md) | 上下文管理 | 对话状态、记忆窗口、Token 管理 |

### 第3部分：Agent 开发

| 章节 | 标题 | 核心内容 |
|------|------|----------|
| [第7章](chapters/ch07.md) | 构建第一个 AI Agent | Agent 架构、ReAct 模式 |
| [第8章](chapters/ch08.md) | 工具调用 | Function Calling、工具注册与执行 |
| [第9章](chapters/ch09.md) | 记忆系统 | 短期/长期记忆、向量存储、RAG |

### 第4部分：实战进阶

| 章节 | 标题 | 核心内容 |
|------|------|----------|
| [第10章](chapters/ch10.md) | Claude Code 集成实战 | Claude API、代码生成、项目级应用 |
| [第11章](chapters/ch11.md) | OpenClaw Agent 框架 | OpenClaw 架构、配置、技能开发 |
| [第12章](chapters/ch12.md) | 自动化工作流 | 多步骤任务、调度、错误处理 |

### 第5部分：项目实战

| 章节 | 标题 | 核心内容 |
|------|------|----------|
| [第13章](chapters/ch13.md) | 项目：智能代码助手 | 完整的 AI 编程助手 |
| [第14章](chapters/ch14.md) | 项目：自动化数据分析师 | 数据处理 + AI 分析 |
| [第15章](chapters/ch15.md) | 项目：多 Agent 协作系统 | 多个 Agent 协同完成复杂任务 |

### 第6部分：高级主题

| 章节 | 标题 | 核心内容 |
|------|------|----------|
| [第16章](chapters/ch16.md) | 上下文压缩 | 滑动窗口、摘要压缩、Token预算、混合策略 |
| [第17章](chapters/ch17.md) | Function Calling 深入 | 工具调用原理、并行调用、流式FC、结构化输出 |

---

## 🚀 快速开始

```bash
# 克隆项目
git clone <repo-url>
cd python-ai-book

# 安装依赖
pip install -r requirements.txt

# 运行第一个示例
python code/ch01/hello_ai.py
```

## 📋 环境要求

- Python 3.10+
- 8GB+ RAM（本地模型需要 16GB+）
- 可选：NVIDIA GPU（加速本地推理）

## 📝 许可

CC BY-NC-SA 4.0
