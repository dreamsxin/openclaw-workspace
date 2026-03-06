const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { chromium, firefox, webkit } = require('playwright');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

const PORT = process.env.PORT || 3000;

// 存储浏览器实例
const browsers = new Map();
let browserCounter = 0;

// 存储 CDP 会话和帧流
const cdpSessions = new Map();

app.use(express.json());
app.use(express.static('public'));

// API: 启动新浏览器
app.post('/api/browser/launch', async (req, res) => {
  try {
    const { browserType = 'chromium', headless = true, args = [] } = req.body;
    
    const launchOptions = {
      headless,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        ...args
      ]
    };

    let browser;
    switch (browserType) {
      case 'firefox':
        browser = await firefox.launch(launchOptions);
        break;
      case 'webkit':
        browser = await webkit.launch(launchOptions);
        break;
      default:
        browser = await chromium.launch(launchOptions);
    }

    const browserId = `browser-${++browserCounter}`;
    const context = await browser.newContext({
      viewport: { width: 1280, height: 720 }
    });

    // 创建初始页面
    const page = await context.newPage();
    await page.setContent(`
      <html>
        <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:linear-gradient(135deg,#1a1a2e,#16213e);font-family:sans-serif;">
          <div style="text-align:center;color:#00d9ff;">
            <h1 style="font-size:3em;margin:0;">🌐</h1>
            <h2 style="color:#eee;">浏览器已就绪</h2>
            <p style="color:#888;">请在上方地址栏输入网址开始浏览</p>
          </div>
        </body>
      </html>
    `);

    const browserData = { browser, context, type: browserType, page };
    browsers.set(browserId, browserData);

    // 仅 Chromium 支持 CDP screencast
    if (browserType === 'chromium') {
      try {
        const client = await context.newCDPSession(page);
        
        // 启用 Page 域
        await client.send('Page.enable');
        
        // 启动帧流 - 每秒 10 帧
        await client.send('Page.startScreencast', {
          format: 'jpeg',
          quality: 80,
          maxWidth: 1280,
          maxHeight: 720
        });

        console.log(`[${browserId}] CDP screencast 已启用 (10 FPS)`);

        // 监听帧事件
        client.on('Page.screencastFrame', async (event) => {
          // 立即确认收到帧（重要！）
          await client.send('Page.screencastFrameAck', { 
            sessionId: event.sessionId 
          }).catch(() => {});

          // 广播帧到所有连接的客户端
          io.to(browserId).emit('frame', {
            browserId,
            frame: event.data,
            timestamp: Date.now(),
            deviceWidth: event.deviceWidth,
            deviceHeight: event.deviceHeight
          });
        });

        cdpSessions.set(browserId, { client, page });

        // 监听页面变化
        page.on('framenavigated', () => {
          console.log(`[${browserId}] 页面导航完成`);
        });

      } catch (error) {
        console.error(`[${browserId}] 启用 CDP screencast 失败:`, error.message);
        console.log(`[${browserId}] 回退到 screenshot 模式`);
      }
    }

    // 监听浏览器关闭
    browser.on('disconnected', () => {
      // 清理 CDP 会话
      const cdpData = cdpSessions.get(browserId);
      if (cdpData) {
        cdpData.client.send('Page.stopScreencast').catch(() => {});
        cdpSessions.delete(browserId);
      }
      
      browsers.delete(browserId);
      io.emit('browser-closed', { browserId });
      console.log(`[${browserId}] 浏览器已断开连接`);
    });

    console.log(`[${browserId}] 浏览器已启动：${browserType}`);
    res.json({ success: true, browserId, browserType });
  } catch (error) {
    console.error('启动浏览器失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 关闭浏览器
app.post('/api/browser/:browserId/close', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);
    
    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    // 停止 screencast
    const cdpData = cdpSessions.get(browserId);
    if (cdpData) {
      await cdpData.client.send('Page.stopScreencast').catch(() => {});
      cdpSessions.delete(browserId);
    }

    await browserData.browser.close();
    browsers.delete(browserId);
    io.emit('browser-closed', { browserId });
    
    console.log(`[${browserId}] 浏览器已关闭`);
    res.json({ success: true });
  } catch (error) {
    console.error('关闭浏览器失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 获取浏览器列表
app.get('/api/browsers', (req, res) => {
  const browserList = Array.from(browsers.entries()).map(([id, data]) => ({
    id,
    type: data.type,
    connected: true,
    screencast: cdpSessions.has(id)
  }));
  res.json({ browsers: browserList });
});

// API: 导航到 URL
app.post('/api/browser/:browserId/navigate', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { url } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page || browserData.context.pages()[0];
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    
    res.json({ 
      success: true,
      url: page.url(),
      title: await page.title()
    });
  } catch (error) {
    console.error('导航失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 截图（高质量 PNG，用于静态截图）
app.post('/api/browser/:browserId/screenshot', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page || browserData.context.pages()[0];
    const screenshotBuffer = await page.screenshot({ type: 'png', fullPage: false });
    const screenshot = screenshotBuffer.toString('base64');
    
    console.log(`[${browserId}] 高清截图：${(screenshot.length / 1024).toFixed(1)} KB`);
    res.json({ success: true, screenshot });
  } catch (error) {
    console.error('截图失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 执行 JavaScript
app.post('/api/browser/:browserId/evaluate', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { script } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page || browserData.context.pages()[0];
    const result = await page.evaluate(script);
    
    res.json({ success: true, result });
  } catch (error) {
    console.error('执行脚本失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 鼠标点击
app.post('/api/browser/:browserId/click', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { x, y, button = 'left', clickCount = 1 } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page || browserData.context.pages()[0];
    await page.mouse.click(x, y, { button, clickCount });
    
    await page.waitForLoadState('networkidle', { timeout: 5000 }).catch(() => {});
    
    // 返回高清截图
    const screenshotBuffer = await page.screenshot({ type: 'png' });
    const screenshot = screenshotBuffer.toString('base64');
    
    res.json({ success: true, screenshot });
  } catch (error) {
    console.error('点击失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 键盘输入
app.post('/api/browser/:browserId/type', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { text, delay = 50 } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page || browserData.context.pages()[0];
    await page.keyboard.type(text, { delay });
    
    await page.waitForLoadState('networkidle', { timeout: 3000 }).catch(() => {});
    
    const screenshotBuffer = await page.screenshot({ type: 'png' });
    const screenshot = screenshotBuffer.toString('base64');
    
    res.json({ success: true, screenshot });
  } catch (error) {
    console.error('键盘输入失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Socket.IO 连接
io.on('connection', (socket) => {
  console.log('客户端已连接:', socket.id);

  socket.on('join-browser', (browserId) => {
    socket.join(browserId);
    console.log(`客户端 ${socket.id} 加入浏览器 ${browserId}`);
    
    const cdpData = cdpSessions.get(browserId);
    if (cdpData) {
      console.log(`[${browserId}] 使用 CDP screencast 模式 (高性能)`);
    } else {
      console.log(`[${browserId}] 使用 screenshot 模式 (兼容模式)`);
    }
  });

  socket.on('leave-browser', (browserId) => {
    socket.leave(browserId);
    console.log(`客户端 ${socket.id} 离开浏览器 ${browserId}`);
  });

  socket.on('disconnect', () => {
    console.log('客户端已断开:', socket.id);
  });
});

// 启动服务器
server.listen(PORT, () => {
  console.log(`🚀 浏览器调试工具已启动 (CDP Screencast 优化版)`);
  console.log(`📍 访问地址：http://localhost:${PORT}`);
  console.log(`🔧 支持浏览器：Chromium (CDP), Firefox, WebKit`);
  console.log(`⚡ CDP Screencast: 10 FPS, 低延迟`);
});
