/**
 * 简单测试脚本 - 快速验证 MCP 连接
 * 截图将保存到本地 output 目录
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// 获取当前文件目录
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 输出目录
const OUTPUT_DIR = path.join(__dirname, 'output');

/**
 * 保存截图到本地
 * @param {object} screenshot - 截图响应对象
 * @param {string} filename - 文件名
 * @returns {string|null} 保存的文件路径
 */
function saveScreenshot(screenshot, filename) {
  // MCP 截图返回两个 content 元素：[0] 是 text 说明，[1] 是 image 数据
  let imageData = null;
  let dataType = 'unknown';
  
  // 查找 image 类型的 content 元素
  if (Array.isArray(screenshot.content)) {
    for (const item of screenshot.content) {
      if (item.type === 'image' && item.data) {
        imageData = item.data;
        dataType = 'content[].data (image)';
        break;
      }
    }
  }
  
  if (!imageData) {
    const contentKeys = screenshot.content?.[0] ? Object.keys(screenshot.content[0]) : [];
    console.log(`   ⚠️  截图数据为空 (content keys: ${contentKeys.join(', ')})`);
    return null;
  }
  
  const filepath = path.join(OUTPUT_DIR, filename);
  fs.writeFileSync(filepath, imageData, 'base64');
  console.log(`   💾 已保存：${filepath} (数据源：${dataType})`);
  return filepath;
}

async function test() {
  console.log('🧪 Chrome MCP 连接测试\n');
  console.log(`📁 输出目录：${OUTPUT_DIR}\n`);

  // 创建输出目录
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    console.log(`✅ 创建输出目录成功\n`);
  }

  const transport = new StdioClientTransport({
    command: 'npx',
    args: ['-y', 'chrome-devtools-mcp@latest', '--browser-url=http://127.0.0.1:9222']
  });

  const client = new Client({
    name: 'test-client',
    version: '1.0.0'
  });

  try {
    // 1. 连接 MCP 服务器
    console.log('1️⃣  连接 MCP 服务器...');
    await client.connect(transport);
    console.log('   ✅ 连接成功\n');

    // 2. 获取可用工具
    console.log('2️⃣  获取可用工具...');
    const tools = await client.listTools();
    console.log(`   ✅ 找到 ${tools.tools.length} 个工具\n`);

    // 3. 导航到百度
    console.log('3️⃣  导航测试 (https://www.baidu.com)...');
    const navResult = await client.callTool({
      name: 'navigate_page',
      arguments: { url: 'https://www.baidu.com' }
    });
    console.log('   ✅ 导航成功\n');
    
    // 保存导航后的截图
    console.log('   📸 保存导航截图...');
    const navScreenshot = await client.callTool({
      name: 'take_screenshot',
      arguments: {}
    });
    saveScreenshot(navScreenshot, 'baidu-homepage.png');
    console.log();

    // 4. 执行 JavaScript 获取标题
    console.log('4️⃣  执行 JavaScript 获取标题...');
    const title = await client.callTool({
      name: 'evaluate_script',
      arguments: { function: '() => document.title' }
    });
    const pageTitle = title.content?.[0]?.text || title.result;
    console.log(`   ✅ 页面标题：${pageTitle}\n`);

    // 5. 搜索测试
    console.log('5️⃣  搜索测试 (Chrome DevTools MCP)...');
    await client.callTool({
      name: 'fill',
      arguments: { 
        selector: '#kw', 
        text: 'Chrome DevTools MCP' 
      }
    });
    console.log('   ✅ 填充搜索框');
    
    await client.callTool({
      name: 'press_key',
      arguments: { key: 'Enter' }
    });
    console.log('   ✅ 按下 Enter 键\n');
    
    // 等待搜索结果加载
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // 保存搜索结果截图
    console.log('   📸 保存搜索结果截图...');
    const searchScreenshot = await client.callTool({
      name: 'take_screenshot',
      arguments: {}
    });
    saveScreenshot(searchScreenshot, 'baidu-search-results.png');
    console.log();

    // 6. 获取页面信息
    console.log('6️⃣  获取页面信息...');
    const pageInfo = await client.callTool({
      name: 'evaluate_script',
      arguments: { 
        function: '() => ({ title: document.title, url: window.location.href })' 
      }
    });
    const info = pageInfo.content?.[0]?.text;
    console.log(`   ✅ 页面信息：${info}\n`);

    // 7. 获取网络请求
    console.log('7️⃣  获取网络请求...');
    const networkRequests = await client.callTool({
      name: 'list_network_requests',
      arguments: {}
    });
    const requestCount = networkRequests.requests?.length || 0;
    console.log(`   ✅ 网络请求数量：${requestCount}\n`);

    console.log('🎉 所有测试通过!\n');
    console.log('📂 截图文件:');
    console.log(`   - ${path.join(OUTPUT_DIR, 'baidu-homepage.png')}`);
    console.log(`   - ${path.join(OUTPUT_DIR, 'baidu-search-results.png')}`);

  } catch (error) {
    console.error('❌ 测试失败:', error.message);
    console.error('\n请确保:');
    console.error('  1. Chrome 已启动：chrome.exe --remote-debugging-port=9222');
    console.error('  2. 网络连接正常');
    process.exit(1);
  } finally {
    await client.close();
    console.log('\n👋 已断开连接');
  }
}

test();
