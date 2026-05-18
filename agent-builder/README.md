# ⚡ AI Agent Builder

**可视化构建 → 一键部署 → 立即运行** 的 AI Agent 框架。

## 架构

```
浏览器 (可视化构建器)
   │  勾选工具 / 配置模型 / 选压缩策略
   │  点击「🚀 一键部署」
   ▼
POST /api/config  →  热加载 Agent
   │
   ▼
FastAPI Server (单进程)
   ├── GET  /           →  构建器 UI
   ├── POST /api/chat   →  SSE 流式对话
   ├── WS   /api/ws     →  WebSocket 对话
   ├── GET  /api/health →  健康检查
   └── POST /api/config →  热更新配置
```

## 快速启动

```bash
# 1. 安装
pip install -r requirements.txt

# 2. 设置 API Key
cp .env.example .env
# 编辑 .env 填入 OPENAI_API_KEY

# 3. 启动
python main.py

# 浏览器打开 http://localhost:8080
```

## 使用流程

1. **打开浏览器** → `http://localhost:8080`
2. **左侧配置** → 选模型、勾选工具、选压缩策略、设安全等级
3. **画布预览** → 拖拽节点调整工作流拓扑
4. **点击「🚀 一键部署」** → 服务端立即热加载，Agent 上线
5. **右侧对话** → 直接测试 Agent
6. **迭代调整** → 随时改配置重新部署，无需重启服务

## Docker 部署

```bash
# 一键启动
docker compose up -d

# 或手动构建
docker build -t agent .
docker run -p 8080:8080 --env-file .env -v ./config.json:/app/config.json agent
```

## API 用法

```bash
# 流式对话 (SSE)
curl -N -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好"}'

# 非流式
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "1+1=?", "stream": false}'

# 热更新配置
curl -X POST http://localhost:8080/api/config \
  -H "Content-Type: application/json" \
  -d '{"config": {...}}'
```

## 内置工具

| 工具 | 说明 |
|------|------|
| `web_search` | DuckDuckGo 网络搜索 |
| `web_fetch` | 抓取网页文本内容 |
| `code_execution` | 沙箱执行 Python 代码 |
| `file_ops` | 读写本地文件 |
| `api_call` | HTTP 请求外部 API |

## 上下文压缩策略

| 策略 | 说明 |
|------|------|
| 不压缩 | 保留完整上下文 |
| 滑动窗口 | 保留最近 N 轮 |
| 摘要压缩 | LLM 生成历史摘要 |
| **分层压缩** | 近期详细 → 远期粗略（推荐） |
| 重要性过滤 | 按相关性评分保留 |
| Token 预算 | 严格控制 Token 数量 |

## 项目结构

```
agent-builder/
├── main.py              # 入口
├── config.json          # Agent 配置（构建器自动生成）
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── static/
│   └── index.html       # 可视化构建器（单文件，无依赖）
└── app/
    ├── server.py        # FastAPI 服务（UI + API）
    ├── agent.py         # Agent 核心（ReAct 循环）
    ├── tools.py         # 工具注册表
    ├── context.py       # 上下文压缩
    ├── memory.py        # 记忆管理
    └── config.py        # 配置模型
```
