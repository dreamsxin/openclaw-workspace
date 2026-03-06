const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { chromium, firefox, webkit } = require('playwright');
const path = require('path');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

const PORT = process.env.PORT || 3000;

// 存储浏览器实例
const browsers = new Map();
let browserCounter = 0;

// 实时画面更新定时器
const streamIntervals = new Map();

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

    // 创建一个初始空白页面
    const initialPage = await context.newPage();
    await initialPage.setContent(`
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

    const browserData = { browser, context, type: browserType };
    browsers.set(browserId, browserData);

    // 监听浏览器关闭
    browser.on('disconnected', () => {
      browsers.delete(browserId);
      io.emit('browser-closed', { browserId });
      console.log(`[${browserId}] 浏览器已断开连接`);
    });

    console.log(`[${browserId}] 浏览器已启动：${browserType} (已有 1 个页面)`);
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
    connected: true
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

    const page = await browserData.context.newPage();
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    
    const screenshotBuffer = await page.screenshot({ type: 'png' });
    const screenshot = screenshotBuffer.toString('base64');
    
    page.on('console', msg => {
      io.to(browserId).emit('console-log', {
        browserId,
        type: msg.type(),
        text: msg.text()
      });
    });

    page.on('pageerror', error => {
      io.to(browserId).emit('page-error', {
        browserId,
        message: error.message
      });
    });

    res.json({ 
      success: true, 
      screenshot,
      url: page.url(),
      title: await page.title()
    });
  } catch (error) {
    console.error('导航失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 截图（高质量 PNG）
app.post('/api/browser/:browserId/screenshot', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    let pages = browserData.context.pages();
    
    if (pages.length === 0) {
      const page = await browserData.context.newPage();
      await page.setContent(`
        <html>
          <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f0f0f0;font-family:sans-serif;">
            <div style="text-align:center;color:#666;">
              <h1>🌐 浏览器已就绪</h1>
              <p>请在上方地址栏输入网址开始浏览</p>
            </div>
          </body>
        </html>
      `);
      pages = browserData.context.pages();
    }

    const page = pages[pages.length - 1];
    const screenshotBuffer = await page.screenshot({ type: 'png', fullPage: false });
    const screenshot = screenshotBuffer.toString('base64');
    
    console.log(`[${browserId}] 高清截图成功，大小：${(screenshot.length / 1024).toFixed(1)} KB`);
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

    const pages = browserData.context.pages();
    if (pages.length === 0) {
      return res.status(400).json({ success: false, error: '没有打开的页面' });
    }

    const page = pages[pages.length - 1];
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

    const pages = browserData.context.pages();
    if (pages.length === 0) {
      return res.status(400).json({ success: false, error: '没有打开的页面' });
    }

    const page = pages[pages.length - 1];
    await page.mouse.click(x, y, { button, clickCount });
    
    await page.waitForLoadState('networkidle', { timeout: 5000 }).catch(() => {});
    const screenshotBuffer = await page.screenshot({ type: 'png' });
    const screenshot = screenshotBuffer.toString('base64');
    
    res.json({ success: true, screenshot });
  } catch (error) {
    console.error('点击失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 鼠标移动
app.post('/api/browser/:browserId/mousemove', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { x, y } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const pages = browserData.context.pages();
    if (pages.length === 0) {
      return res.status(400).json({ success: false, error: '没有打开的页面' });
    }

    const page = pages[pages.length - 1];
    await page.mouse.move(x, y);
    
    res.json({ success: true });
  } catch (error) {
    console.error('鼠标移动失败:', error);
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

    const pages = browserData.context.pages();
    if (pages.length === 0) {
      return res.status(400).json({ success: false, error: '没有打开的页面' });
    }

    const page = pages[pages.length - 1];
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

// API: 按键按下
app.post('/api/browser/:browserId/keypress', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { key } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const pages = browserData.context.pages();
    if (pages.length === 0) {
      return res.status(400).json({ success: false, error: '没有打开的页面' });
    }

    const page = pages[pages.length - 1];
    await page.keyboard.press(key);
    
    await page.waitForLoadState('networkidle', { timeout: 5000 }).catch(() => {});
    const screenshotBuffer = await page.screenshot({ type: 'png' });
    const screenshot = screenshotBuffer.toString('base64');
    
    res.json({ success: true, screenshot });
  } catch (error) {
    console.error('按键失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Socket.IO 连接
io.on('connection', (socket) => {
  console.log('客户端已连接:', socket.id);

  socket.on('join-browser', async (browserId) => {
    socket.join(browserId);
    console.log(`客户端 ${socket.id} 加入浏览器 ${browserId}`);
    
    // 启动实时画面流
    const browserData = browsers.get(browserId);
    if (browserData && !streamIntervals.has(browserId)) {
      console.log(`[${browserId}] 启动实时画面流`);
      
      const intervalId = setInterval(async () => {
        try {
          const pages = browserData.context.pages();
          if (pages.length === 0) {
            console.log(`[${browserId}] 暂无页面，跳过帧捕获`);
            return;
          }
          
          const page = pages[pages.length - 1];
          const screenshotBuffer = await page.screenshot({ type: 'jpeg', quality: 80 });
          const screenshot = screenshotBuffer.toString('base64');
          
          io.to(browserId).emit('frame', {
            browserId,
            frame: screenshot,
            timestamp: Date.now()
          });
          console.log(`[${browserId}] 发送帧：${(screenshot.length / 1024).toFixed(1)} KB`);
        } catch (error) {
          console.error(`[${browserId}] 获取画面失败:`, error.message);
        }
      }, 500);
      
      streamIntervals.set(browserId, intervalId);
    }
  });

  socket.on('leave-browser', (browserId) => {
    socket.leave(browserId);
    console.log(`客户端 ${socket.id} 离开浏览器 ${browserId}`);
    
    const room = io.sockets.adapter.rooms.get(browserId);
    if (!room || room.size === 0) {
      const intervalId = streamIntervals.get(browserId);
      if (intervalId) {
        clearInterval(intervalId);
        streamIntervals.delete(browserId);
        console.log(`[${browserId}] 停止实时画面流`);
      }
    }
  });

  socket.on('disconnect', () => {
    console.log('客户端已断开:', socket.id);
    
    streamIntervals.forEach((intervalId, browserId) => {
      const room = io.sockets.adapter.rooms.get(browserId);
      if (!room || room.size === 0) {
        clearInterval(intervalId);
        streamIntervals.delete(browserId);
        console.log(`[${browserId}] 停止实时画面流`);
      }
    });
  });
});

// 启动服务器
server.listen(PORT, () => {
  console.log(`🚀 浏览器调试工具已启动`);
  console.log(`📍 访问地址：http://localhost:${PORT}`);
  console.log(`🔧 支持浏览器：Chromium, Firefox, WebKit`);
});
