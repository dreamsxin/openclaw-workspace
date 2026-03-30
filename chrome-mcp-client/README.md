# Chrome MCP Client Demo

使用 Model Context Protocol (MCP) 连接和控制 Chrome 浏览器的示例客户端。

![Chrome](https://img.shields.io/badge/Chrome-146+-blue)
![Node](https://img.shields.io/badge/Node.js-20.19+-green)
![MCP](https://img.shields.io/badge/MCP-1.0-purple)

---

## 📖 目录

- [快速开始](#-快速开始)
- [项目结构](#-项目结构)
- [配置说明](#-配置说明)
- [使用示例](#-使用示例)
- [API 参考](#-api-参考)
- [可用工具](#-可用工具)
- [故障排查](#-故障排查)
- [安全提示](#-安全提示)

---

## 🚀 快速开始

### 1. 环境要求

- **Node.js** v20.19 或更高版本
- **Google Chrome** 浏览器（建议版本 144+）
- **npm** 包管理器

### 2. 安装依赖

```bash
cd D:\work\openclaw-workspace\chrome-mcp-client
npm install
```

### 3. 启动 Chrome（带远程调试）

**Windows PowerShell:**

```powershell
# 关闭所有 Chrome 实例
taskkill /F /IM chrome.exe

# 启动带远程调试端口
"C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="C:\chrome-debug-profile"
```

**验证 Chrome 已启动:**

```powershell
curl http://localhost:9222/json/version
```

应返回类似输出：
```json
{
  "Browser": "Chrome/146.0.7680.165",
  "webSocketDebuggerUrl": "ws://localhost:9222/devtools/browser/xxx"
}
```

### 4. 运行测试

```bash
# 快速测试（验证基本连接）
npm test

# 完整演示（导航、截图、搜索等）
npm start
```

---

## 📁 项目结构

```
chrome-mcp-client/
├── package.json          # 项目配置和依赖
├── index.js              # 完整演示程序
├── test.js               # 快速测试脚本
├── README.md             # 使用文档
└── node_modules/         # npm 依赖包
```

---

## ⚙️ 配置说明

### 修改 MCP 连接参数

编辑 `index.js` 或 `test.js` 中的配置：

```javascript
const MCP_CONFIG = {
  command: 'npx',
  args: [
    '-y',
    'chrome-devtools-mcp@latest',
    '--browser-url=http://127.0.0.1:9222'  // Chrome 远程调试地址
  ]
};
```

### 常用配置选项

| 参数 | 说明 | 示例 |
|------|------|------|
| `--browser-url` | 连接已运行的 Chrome | `http://127.0.0.1:9222` |
| `--wsEndpoint` | WebSocket 直连 | `ws://127.0.0.1:9222/devtools/browser/xxx` |
| `--headless` | 无头模式（无 UI） | `--headless` |
| `--viewport` | 初始视口大小 | `--viewport=1280x720` |
| `--isolated` | 临时用户目录（自动清理） | `--isolated` |
| `--channel` | Chrome 渠道 | `stable` / `canary` / `beta` / `dev` |

**示例配置:**

```javascript
const MCP_CONFIG = {
  command: 'npx',
  args: [
    '-y',
    'chrome-devtools-mcp@latest',
    '--browser-url=http://127.0.0.1:9222',
    '--headless',
    '--viewport=1280x720',
    '--isolated'
  ]
};
```

---

## 💡 使用示例

### 基本用法

```javascript
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

// 创建传输层
const transport = new StdioClientTransport({
  command: 'npx',
  args: ['-y', 'chrome-devtools-mcp@latest', '--browser-url=http://127.0.0.1:9222']
});

// 创建并连接客户端
const client = new Client({ name: 'my-client', version: '1.0.0' });
await client.connect(transport);

// 调用工具
await client.callTool({
  name: 'navigate_page',
  arguments: { url: 'https://example.com' }
});

// 完成后关闭
await client.close();
```

### 导航与截图

```javascript
// 导航到网页
await client.callTool({
  name: 'navigate_page',
  arguments: { url: 'https://www.google.com' }
});

// 等待加载
await new Promise(resolve => setTimeout(resolve, 2000));

// 截图
const screenshot = await client.callTool({
  name: 'take_screenshot',
  arguments: {}
});

// 保存截图（Base64）
const fs = require('fs');
const imageData = screenshot.content[0].image?.data || screenshot.content[0].data;
fs.writeFileSync('screenshot.png', imageData, 'base64');
```

### 表单操作

```javascript
// 填充输入框
await client.callTool({
  name: 'fill',
  arguments: { 
    selector: 'textarea[name="q"]', 
    text: 'Chrome DevTools MCP' 
  }
});

// 按键（如 Enter）
await client.callTool({
  name: 'press_key',
  arguments: { key: 'Enter' }
});

// 点击元素
await client.callTool({
  name: 'click',
  arguments: { selector: 'button[type="submit"]' }
});
```

### 执行 JavaScript

```javascript
// 获取页面标题
const title = await client.callTool({
  name: 'evaluate_script',
  arguments: { function: '() => document.title' }
});
console.log('页面标题:', title.result);

// 获取所有链接
const links = await client.callTool({
  name: 'evaluate_script',
  arguments: { 
    function: '() => Array.from(document.querySelectorAll("a")).map(a => a.href)' 
  }
});
```

### 性能分析

```javascript
// 开始性能追踪
await client.callTool({
  name: 'performance_start_trace',
  arguments: { url: 'https://example.com' }
});

// 等待页面加载和交互
await new Promise(resolve => setTimeout(resolve, 3000));

// 停止追踪并获取结果
const report = await client.callTool({
  name: 'performance_stop_trace',
  arguments: {}
});
console.log('性能报告:', report);
```

### Lighthouse 审计

```javascript
const audit = await client.callTool({
  name: 'lighthouse_audit',
  arguments: { url: 'https://example.com' }
});
console.log('Lighthouse 分数:', audit);
```

---

## 🛠️ API 参考

### ChromeMCPClient 类方法

| 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `connect()` | - | Promise | 连接 MCP 服务器 |
| `navigate(url)` | `url: string` | Promise | 导航到指定 URL |
| `screenshot()` | - | Promise | 截取当前页面 |
| `click(selector)` | `selector: string` | Promise | 点击元素 |
| `fill(selector, text)` | `selector: string`, `text: string` | Promise | 填充输入框 |
| `pressKey(key)` | `key: string` | Promise | 按键操作 |
| `evaluate(script)` | `script: string` | Promise | 执行 JavaScript |
| `getConsoleMessages()` | - | Promise | 获取控制台消息 |
| `getNetworkRequests()` | - | Promise | 获取网络请求 |
| `performanceAudit(url)` | `url: string` | Promise | 性能分析 |
| `disconnect()` | - | Promise | 断开连接 |

---

## 🔧 可用工具

### 输入自动化 (9 个)

| 工具 | 说明 | 参数 |
|------|------|------|
| `click` | 点击元素 | `{ selector: string }` |
| `drag` | 拖拽元素 | `{ from: string, to: string }` |
| `fill` | 填充输入框 | `{ selector: string, text: string }` |
| `fill_form` | 批量填充表单 | `{ fields: object }` |
| `handle_dialog` | 处理浏览器对话框 | `{ action: string, promptText?: string }` |
| `hover` | 悬停元素 | `{ selector: string }` |
| `press_key` | 按键 | `{ key: string }` |
| `type_text` | 键盘输入 | `{ text: string }` |
| `upload_file` | 上传文件 | `{ selector: string, path: string }` |

### 导航自动化 (6 个)

| 工具 | 说明 | 参数 |
|------|------|------|
| `close_page` | 关闭标签页 | `{ index?: number }` |
| `list_pages` | 列出所有标签页 | `{}` |
| `navigate_page` | 导航/前进/后退 | `{ url: string }` |
| `new_page` | 新建标签页 | `{ url?: string }` |
| `select_page` | 切换标签页 | `{ index: number }` |
| `wait_for` | 等待文本出现 | `{ text: string, timeout?: number }` |

### 调试工具 (6 个)

| 工具 | 说明 | 参数 |
|------|------|------|
| `evaluate_script` | 执行 JavaScript | `{ function: string }` |
| `get_console_message` | 获取单条控制台消息 | `{ id: string }` |
| `lighthouse_audit` | Lighthouse 审计 | `{ url: string }` |
| `list_console_messages` | 列出所有控制台消息 | `{}` |
| `take_screenshot` | 截图 | `{ selector?: string }` |
| `take_snapshot` | 页面文本快照 | `{}` |

### 性能工具 (4 个)

| 工具 | 说明 | 参数 |
|------|------|------|
| `performance_analyze_insight` | 分析性能洞察 | `{ insightId: string }` |
| `performance_start_trace` | 开始性能追踪 | `{ url: string }` |
| `performance_stop_trace` | 停止性能追踪 | `{}` |
| `take_memory_snapshot` | 内存堆快照 | `{}` |

### 网络工具 (2 个)

| 工具 | 说明 | 参数 |
|------|------|------|
| `get_network_request` | 获取单个网络请求 | `{ requestId?: string }` |
| `list_network_requests` | 列出所有网络请求 | `{}` |

### 仿真工具 (2 个)

| 工具 | 说明 | 参数 |
|------|------|------|
| `emulate` | 仿真设备/网络 | `{ device?: string, network?: string }` |
| `resize_page` | 调整窗口大小 | `{ width: number, height: number }` |

---

## 🐛 故障排查

### 连接失败

**问题**: `Error: connect ECONNREFUSED 127.0.0.1:9222`

**解决**:
```powershell
# 检查 Chrome 是否运行
tasklist | findstr chrome

# 检查端口是否开放
netstat -ano | findstr 9222

# 重新启动 Chrome
taskkill /F /IM chrome.exe
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\chrome-debug-profile"
```

### MCP 服务器启动失败

**问题**: `Error: Cannot find module 'chrome-devtools-mcp'`

**解决**:
```bash
# 清除 npm 缓存
npm cache clean --force

# 重新安装依赖
rm -rf node_modules package-lock.json
npm install
```

### 工具调用失败

**问题**: `Input validation error: Invalid arguments`

**解决**: 检查参数格式，确保使用正确的参数名：
```javascript
// ❌ 错误
{ script: 'document.title' }

// ✅ 正确
{ function: '() => document.title' }
```

### 查看详细日志

```bash
# 设置环境变量启用调试日志
$env:DEBUG="*"
npm start
```

### Chrome 版本检查

```powershell
# 查看 Chrome 版本
curl http://localhost:9222/json/version

# 建议：Chrome 144+ 以获得最佳兼容性
```

---

## ⚠️ 安全提示

### 远程调试风险

启用远程调试端口后，**任何本地应用程序都可以控制你的浏览器**：

- ❌ **不要**在调试模式下访问银行、邮箱等敏感网站
- ❌ **不要**在调试模式下登录重要账号
- ✅ **使用** `--user-data-dir` 创建独立的调试配置文件
- ✅ **完成后**及时关闭 Chrome 调试实例

### 推荐做法

```powershell
# 使用独立的用户数据目录
"C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="C:\chrome-debug-profile"

# 使用完毕后关闭
taskkill /F /IM chrome.exe

# 可选：清理调试配置文件
Remove-Item -Recurse -Force "C:\chrome-debug-profile"
```

### MCP 服务器注意事项

- MCP 服务器可以访问浏览器中的**所有内容**
- 避免与不受信任的 MCP 客户端共享调试端口
- 生产环境建议使用 `--isolated` 参数自动清理数据

---

## 📚 相关资源

- [chrome-devtools-mcp 官方仓库](https://github.com/ChromeDevTools/chrome-devtools-mcp)
- [MCP SDK 文档](https://github.com/modelcontextprotocol/sdk)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [Puppeteer 文档](https://pptr.dev/)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**Happy Automating! 🚀**
