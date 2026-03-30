/**
 * Chrome MCP Client Demo
 * 连接到 chrome-devtools-mcp 服务器并操作浏览器
 * 
 * 使用前确保：
 * 1. Chrome 已启动并开启远程调试：chrome.exe --remote-debugging-port=9222
 * 2. chrome-devtools-mcp 服务器已运行
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

// MCP 服务器配置
const MCP_CONFIG = {
  command: 'npx',
  args: ['-y', 'chrome-devtools-mcp@latest', '--browser-url=http://127.0.0.1:9222'],
  cwd: undefined
};

class ChromeMCPClient {
  constructor() {
    this.client = null;
    this.transport = null;
  }

  // 连接到 MCP 服务器
  async connect() {
    console.log('🔌 正在连接 MCP 服务器...');
    
    this.transport = new StdioClientTransport({
      command: MCP_CONFIG.command,
      args: MCP_CONFIG.args,
      cwd: MCP_CONFIG.cwd
    });

    this.client = new Client({
      name: 'chrome-mcp-demo',
      version: '1.0.0'
    });

    await this.client.connect(this.transport);
    console.log('✅ 已连接到 MCP 服务器');

    // 列出可用工具
    const tools = await this.client.listTools();
    console.log('\n📦 可用工具:');
    tools.tools.forEach(tool => {
      console.log(`   - ${tool.name}: ${tool.description?.substring(0, 60) || ''}...`);
    });
    console.log();
  }

  // 导航到网页
  async navigate(url) {
    console.log(`🌐 导航到：${url}`);
    const result = await this.client.callTool({
      name: 'navigate_page',
      arguments: { url }
    });
    console.log('✅ 导航完成');
    return result;
  }

  // 截图
  async screenshot() {
    console.log('📸 正在截图...');
    const result = await this.client.callTool({
      name: 'take_screenshot',
      arguments: {}
    });
    console.log('✅ 截图完成');
    return result;
  }

  // 点击元素
  async click(selector) {
    console.log(`👆 点击：${selector}`);
    const result = await this.client.callTool({
      name: 'click',
      arguments: { selector }
    });
    console.log('✅ 点击完成');
    return result;
  }

  // 填充表单
  async fill(selector, text) {
    console.log(`⌨️  填充 ${selector}: ${text}`);
    const result = await this.client.callTool({
      name: 'fill',
      arguments: { selector, text }
    });
    console.log('✅ 填充完成');
    return result;
  }

  // 执行 JavaScript
  async evaluate(script) {
    console.log(`💻 执行脚本：${script.substring(0, 50)}...`);
    const result = await this.client.callTool({
      name: 'evaluate_script',
      arguments: { function: `() => ${script}` }
    });
    console.log('✅ 脚本执行完成');
    return result;
  }

  // 按键
  async pressKey(key) {
    console.log(`⌨️  按键：${key}`);
    const result = await this.client.callTool({
      name: 'press_key',
      arguments: { key }
    });
    console.log('✅ 按键完成');
    return result;
  }

  // 获取控制台消息
  async getConsoleMessages() {
    console.log('📋 获取控制台消息...');
    const result = await this.client.callTool({
      name: 'list_console_messages',
      arguments: {}
    });
    return result;
  }

  // 获取网络请求
  async getNetworkRequests() {
    console.log('🌐 获取网络请求...');
    const result = await this.client.callTool({
      name: 'list_network_requests',
      arguments: {}
    });
    return result;
  }

  // 性能分析
  async performanceAudit(url) {
    console.log(`⚡ 性能分析：${url}`);
    
    // 开始性能追踪
    await this.client.callTool({
      name: 'performance_start_trace',
      arguments: { url }
    });
    
    // 等待页面加载
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // 停止性能追踪
    const result = await this.client.callTool({
      name: 'performance_stop_trace',
      arguments: {}
    });
    
    console.log('✅ 性能分析完成');
    return result;
  }

  // 关闭连接
  async disconnect() {
    if (this.client) {
      await this.client.close();
      console.log('👋 已断开连接');
    }
  }
}

// 演示用例
async function runDemo() {
  const client = new ChromeMCPClient();

  try {
    // 1. 连接
    await client.connect();

    // 2. 导航到 Google
    await client.navigate('https://www.google.com');
    await new Promise(resolve => setTimeout(resolve, 2000));

    // 3. 截图
    const screenshot = await client.screenshot();
    const screenshotData = screenshot.content?.[0];
    if (screenshotData?.data) {
      console.log('截图数据:', `Base64 图片 (${screenshotData.data.length} 字节)`);
    } else if (screenshotData?.image?.data) {
      console.log('截图数据:', `Base64 图片 (${screenshotData.image.data.length} 字节)`);
    }

    // 4. 搜索（如果找到搜索框）
    try {
      await client.fill('textarea[name="q"]', 'Chrome DevTools MCP');
      await client.pressKey('Enter');
      await new Promise(resolve => setTimeout(resolve, 2000));
    } catch (e) {
      console.log('⚠️  搜索操作跳过:', e.message);
    }

    // 5. 执行脚本获取页面标题
    const titleResult = await client.evaluate('document.title');
    const titleText = titleResult.content?.[0]?.text || titleResult.result;
    console.log('页面标题:', titleText);

    // 6. 获取控制台消息
    const consoleMessages = await client.getConsoleMessages();
    console.log('控制台消息数量:', consoleMessages.messages?.length || 0);

    // 7. 获取网络请求
    const networkRequests = await client.getNetworkRequests();
    console.log('网络请求数量:', networkRequests.requests?.length || 0);

  } catch (error) {
    console.error('❌ 错误:', error);
  } finally {
    // 断开连接
    await client.disconnect();
  }
}

// 运行演示
runDemo().catch(console.error);
