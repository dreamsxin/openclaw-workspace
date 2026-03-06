# 🔍 浏览器调试工具

基于 Node.js + Playwright 的可视化远程浏览器调试工具。

## 功能特性

- 🚀 **多浏览器支持** - Chromium, Firefox, WebKit
- 🖥️ **可视化界面** - 实时查看浏览器截图
- 🌐 **远程导航** - 访问任意网址
- 📸 **截图功能** - 一键捕获页面截图
- ⚡ **脚本执行** - 在浏览器中执行自定义 JavaScript
- 📝 **控制台日志** - 实时查看页面 console 输出和错误
- 🔌 **WebSocket 连接** - 实时双向通信

## 快速开始

### 1. 安装依赖

```bash
cd browser-debug-tool
npm install
```

### 2. 启动服务器

```bash
npm start
```

### 3. 访问界面

打开浏览器访问：http://localhost:3000

## 使用说明

### 启动浏览器

1. 点击顶部按钮选择浏览器类型（Chromium/Firefox/WebKit）
2. 浏览器实例会出现在左侧列表

### 浏览网页

1. 从左侧列表选择一个浏览器实例
2. 在地址栏输入网址
3. 点击"访问"按钮

### 截图

- 选择浏览器后自动捕获截图
- 或点击"截图"按钮手动捕获

### 执行脚本

1. 在底部文本框中输入 JavaScript 代码
2. 点击"执行脚本"按钮
3. 查看右侧控制台的执行结果

### 查看日志

- 右侧面板实时显示 console.log、console.error 等输出
- 点击"清空日志"清除所有记录

## API 接口

### 启动浏览器
```
POST /api/browser/launch
Body: { "browserType": "chromium", "headless": true }
```

### 关闭浏览器
```
POST /api/browser/:browserId/close
```

### 获取浏览器列表
```
GET /api/browsers
```

### 导航到 URL
```
POST /api/browser/:browserId/navigate
Body: { "url": "https://example.com" }
```

### 截图
```
POST /api/browser/:browserId/screenshot
```

### 执行 JavaScript
```
POST /api/browser/:browserId/evaluate
Body: { "script": "document.title" }
```

## 配置

通过环境变量配置：

- `PORT` - 服务器端口（默认：3000）

## 技术栈

- **后端**: Node.js, Express, Socket.IO, Playwright
- **前端**: HTML5, CSS3, Vanilla JavaScript
- **浏览器自动化**: Playwright

## 注意事项

- 首次运行会自动下载浏览器内核（约 200MB）
- 建议使用 Node.js 18+ 版本
- 生产环境请配置适当的 CORS 策略

## 许可证

MIT
