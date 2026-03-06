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

// 存储 CDP 会话
const cdpSessions = new Map();

// 存储 screenshot 模式的定时器
const screenshotIntervals = new Map();

app.use(express.json());
app.use(express.static('public'));

// API: 启动新浏览器
app.post('/api/browser/launch', async (req, res) => {
  try {
    const { browserType = 'chromium', headless = true, screencast = true, args = [] } = req.body;
    
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

    // 监听页面事件
    context.on('page', (newPage) => {
      console.log(`[${browserId}] 📑 新标签页打开：${newPage.url()}`);
      
      // 监听新页面的 load 事件
      newPage.on('load', () => {
        console.log(`[${browserId}] 📄 标签页加载完成：${newPage.url()}`);
        io.to(browserId).emit('page-event', {
          browserId,
          type: 'load',
          url: newPage.url(),
          title: newPage.title().catch(() => 'Untitled'),
          timestamp: Date.now()
        });
      });
      
      newPage.on('close', () => {
        console.log(`[${browserId}] ❌ 标签页关闭：${newPage.url()}`);
        io.to(browserId).emit('page-event', {
          browserId,
          type: 'close',
          url: newPage.url(),
          timestamp: Date.now()
        });
      });
      
      // 通知客户端更新标签页列表
      io.to(browserId).emit('tabs-updated', { browserId });
    });
    
    // 监听初始页面的 load 事件
    page.on('load', () => {
      console.log(`[${browserId}] 📄 初始页面加载完成：${page.url()}`);
    });

    // Chromium 支持 CDP screencast
    let useScreencast = false;
    if (browserType === 'chromium' && screencast) {
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

        console.log(`[${browserId}] ✅ CDP screencast 已启用 (10 FPS)`);

        // 监听帧事件
        client.on('Page.screencastFrame', async (event) => {
          // 立即确认收到帧
          await client.send('Page.screencastFrameAck', { 
            sessionId: event.sessionId 
          }).catch(() => {});

          // 广播帧到所有连接的客户端
          io.to(browserId).emit('frame', {
            browserId,
            frame: event.data,
            timestamp: Date.now(),
            deviceWidth: event.deviceWidth,
            deviceHeight: event.deviceHeight,
            mode: 'screencast'
          });
        });

        cdpSessions.set(browserId, { client, page });
        useScreencast = true;

      } catch (error) {
        console.error(`[${browserId}] 启用 CDP screencast 失败:`, error.message);
        console.log(`[${browserId}] 回退到 screenshot 模式`);
      }
    }

    // 非 Chromium 或 screencast 禁用时，使用 screenshot 模式
    if (!useScreencast) {
      console.log(`[${browserId}] 📸 使用 screenshot 模式 (兼容模式)`);
    }

    // 监听浏览器关闭
    browser.on('disconnected', () => {
      console.log(`[${browserId}] 🛑 浏览器已停止`);
      io.emit('browser-stopped', { browserId });
      cleanupBrowser(browserId);
    });

    console.log(`[${browserId}] 🚀 浏览器已启动：${browserType} ${useScreencast ? '(CDP)' : '(Screenshot)'}`);
    
    // 发送启动事件到所有客户端（不只是浏览器房间）
    io.emit('browser-event', {
      browserId,
      type: 'start',
      browserType,
      screencast: useScreencast,
      timestamp: Date.now()
    });
    
    res.json({ 
      success: true, 
      browserId, 
      browserType,
      screencast: useScreencast 
    });
  } catch (error) {
    console.error('启动浏览器失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 清理浏览器资源
function cleanupBrowser(browserId) {
  // 停止 CDP screencast
  const cdpData = cdpSessions.get(browserId);
  if (cdpData) {
    cdpData.client.send('Page.stopScreencast').catch(() => {});
    cdpSessions.delete(browserId);
  }
  
  // 停止 screenshot 定时器
  const intervalId = screenshotIntervals.get(browserId);
  if (intervalId) {
    clearInterval(intervalId);
    screenshotIntervals.delete(browserId);
  }
  
  const browserData = browsers.get(browserId);
  const pageCount = browserData ? browserData.context.pages().length : 0;
  
  browsers.delete(browserId);
  
  console.log(`[${browserId}] 浏览器已清理 (关闭前共 ${pageCount} 个标签页)`);
}

// API: 关闭浏览器
app.post('/api/browser/:browserId/close', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);
    
    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const pageCount = browserData.context.pages().length;
    cleanupBrowser(browserId);
    await browserData.browser.close();
    
    console.log(`[${browserId}] 🛑 浏览器已关闭 (共关闭 ${pageCount} 个标签页)`);
    io.emit('browser-event', {
      browserId,
      type: 'stop',
      pageCount,
      timestamp: Date.now()
    });
    
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

// API: 获取标签页列表
app.get('/api/browser/:browserId/tabs', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const pages = browserData.context.pages();
    const tabs = await Promise.all(pages.map(async (page, index) => ({
      index,
      url: page.url(),
      title: await page.title().catch(() => 'Untitled'),
      isActive: page === browserData.page
    })));

    res.json({ success: true, tabs, activeTabIndex: pages.indexOf(browserData.page) });
  } catch (error) {
    console.error('获取标签页失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 切换标签页
app.post('/api/browser/:browserId/tabs/:tabIndex/switch', async (req, res) => {
  try {
    const { browserId, tabIndex } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const pages = browserData.context.pages();
    const index = parseInt(tabIndex);
    
    if (index < 0 || index >= pages.length) {
      return res.status(400).json({ success: false, error: '标签页索引无效' });
    }

    browserData.page = pages[index];
    
    // 获取当前标签页信息
    const page = pages[index];
    const screenshotBuffer = await page.screenshot({ type: 'jpeg', quality: 80 });
    const screenshot = screenshotBuffer.toString('base64');

    console.log(`[${browserId}] 切换到标签页 ${index}: ${page.url()}`);
    
    // 通知所有客户端更新画面
    io.to(browserId).emit('tab-switched', {
      browserId,
      tabIndex: index,
      url: page.url(),
      title: await page.title().catch(() => 'Untitled')
    });

    res.json({ 
      success: true, 
      tabIndex: index,
      url: page.url(),
      title: await page.title().catch(() => 'Untitled'),
      screenshot
    });
  } catch (error) {
    console.error('切换标签页失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 关闭标签页
app.post('/api/browser/:browserId/tabs/:tabIndex/close', async (req, res) => {
  try {
    const { browserId, tabIndex } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const pages = browserData.context.pages();
    const index = parseInt(tabIndex);
    
    if (index < 0 || index >= pages.length) {
      return res.status(400).json({ success: false, error: '标签页索引无效' });
    }

    const pageToClose = pages[index];
    const url = pageToClose.url();
    await pageToClose.close();
    
    // 如果关闭的是当前页面，切换到第一个可用页面
    if (browserData.page === pageToClose && browserData.context.pages().length > 0) {
      browserData.page = browserData.context.pages()[0];
    }

    console.log(`[${browserId}] ❌ 关闭标签页 ${index + 1}/${pages.length}: ${url}`);
    io.to(browserId).emit('page-event', {
      browserId,
      type: 'manual-close',
      url,
      tabIndex: index,
      timestamp: Date.now()
    });
    
    res.json({ success: true });
  } catch (error) {
    console.error('关闭标签页失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 新建标签页
app.post('/api/browser/:browserId/tabs/new', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { url } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const newPage = await browserData.context.newPage();
    if (url) {
      await newPage.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    }
    
    browserData.page = newPage;
    
    const screenshotBuffer = await newPage.screenshot({ type: 'jpeg', quality: 80 });
    const screenshot = screenshotBuffer.toString('base64');
    const pageTitle = await newPage.title().catch(() => 'New Tab');

    console.log(`[${browserId}] ➕ 新建标签页：${url || 'about:blank'} - ${pageTitle}`);
    io.to(browserId).emit('page-event', {
      browserId,
      type: 'new-tab',
      url: newPage.url(),
      title: pageTitle,
      timestamp: Date.now()
    });
    
    res.json({ 
      success: true,
      url: newPage.url(),
      title: pageTitle,
      screenshot
    });
  } catch (error) {
    console.error('新建标签页失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
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

    const page = browserData.page;
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    
    const title = await page.title();
    
    console.log(`[${browserId}] 🌐 导航到：${url} - ${title}`);
    
    // 发送页面事件
    io.to(browserId).emit('page-event', {
      browserId,
      type: 'navigate',
      url: page.url(),
      title,
      timestamp: Date.now()
    });
    
    // 通知标签页更新
    io.to(browserId).emit('tabs-updated', { browserId });
    
    res.json({ 
      success: true,
      url: page.url(),
      title
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

    const page = browserData.page;
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

    const page = browserData.page;
    const result = await page.evaluate(script);
    
    res.json({ success: true, result });
  } catch (error) {
    console.error('执行脚本失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 鼠标按下
app.post('/api/browser/:browserId/mousedown', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { x, y, button = 'left' } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page;
    await page.mouse.move(x, y);
    await page.mouse.down({ button });
    
    res.json({ success: true });
  } catch (error) {
    console.error('鼠标按下失败:', error);
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

    const page = browserData.page;
    await page.mouse.move(x, y);
    
    res.json({ success: true });
  } catch (error) {
    console.error('鼠标移动失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 鼠标抬起
app.post('/api/browser/:browserId/mouseup', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { x, y, button = 'left' } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page;
    
    // 先移动到终点位置
    await page.mouse.move(x, y);
    
    // 释放鼠标左键
    console.log(`[${browserId}] 执行 mouse.up(${button})`);
    await page.mouse.up({ button });
    
    // 等待一下让选择生效
    await page.waitForTimeout(100);
    
    // 获取选中的文本
    const selectedText = await page.evaluate(() => {
      const selection = window.getSelection();
      const text = selection ? selection.toString() : '';
      console.log('选中文本:', text);
      return text;
    });
    
    console.log(`[${browserId}] 鼠标抬起完成，选中 ${selectedText?.length || 0} 字符`);
    
    res.json({ 
      success: true,
      selectedText: selectedText || '',
      selectedLength: selectedText ? selectedText.length : 0
    });
  } catch (error) {
    console.error('鼠标抬起失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 鼠标点击（单次点击）
app.post('/api/browser/:browserId/click', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { x, y, button = 'left', clickCount = 1 } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page;
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

    const page = browserData.page;
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

// API: 复制选中文本
app.post('/api/browser/:browserId/copy', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page;
    
    // 执行复制操作（Ctrl+C）
    await page.keyboard.press('Control+c');
    await page.waitForTimeout(100);
    
    // 从浏览器上下文获取剪贴板内容
    const clipboardText = await page.evaluate(() => {
      return navigator.clipboard.readText();
    }).catch(() => null);
    
    // 如果 evaluate 失败，尝试通过 selection 获取
    const selectedText = clipboardText || await page.evaluate(() => {
      const selection = window.getSelection();
      return selection ? selection.toString() : '';
    });
    
    console.log(`[${browserId}] 复制内容：${selectedText?.substring(0, 100)}${selectedText?.length > 100 ? '...' : ''}`);
    res.json({ 
      success: true, 
      text: selectedText || '',
      length: selectedText ? selectedText.length : 0
    });
  } catch (error) {
    console.error('复制失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 粘贴文本到浏览器
app.post('/api/browser/:browserId/paste', async (req, res) => {
  try {
    const { browserId } = req.params;
    const { text } = req.body;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    if (!text) {
      return res.status(400).json({ success: false, error: '粘贴内容为空' });
    }

    const page = browserData.page;
    
    // 将文本写入浏览器剪贴板
    await page.evaluate((txt) => {
      return navigator.clipboard.writeText(txt);
    }, text);
    
    await page.waitForTimeout(100);
    
    // 执行粘贴操作（Ctrl+V）
    await page.keyboard.press('Control+v');
    
    await page.waitForLoadState('networkidle', { timeout: 3000 }).catch(() => {});
    
    const screenshotBuffer = await page.screenshot({ type: 'png' });
    const screenshot = screenshotBuffer.toString('base64');
    
    console.log(`[${browserId}] 粘贴内容：${text.substring(0, 100)}${text.length > 100 ? '...' : ''}`);
    res.json({ 
      success: true, 
      screenshot,
      length: text.length
    });
  } catch (error) {
    console.error('粘贴失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: 全选文本
app.post('/api/browser/:browserId/selectall', async (req, res) => {
  try {
    const { browserId } = req.params;
    const browserData = browsers.get(browserId);

    if (!browserData) {
      return res.status(404).json({ success: false, error: '浏览器不存在' });
    }

    const page = browserData.page;
    
    // 执行全选操作（Ctrl+A）
    await page.keyboard.press('Control+a');
    await page.waitForTimeout(100);
    
    // 获取选中的文本
    const selectedText = await page.evaluate(() => {
      const selection = window.getSelection();
      return selection ? selection.toString() : '';
    });
    
    res.json({ 
      success: true, 
      text: selectedText || '',
      length: selectedText ? selectedText.length : 0
    });
  } catch (error) {
    console.error('全选失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Socket.IO 连接
io.on('connection', (socket) => {
  console.log('客户端已连接:', socket.id);

  socket.on('join-browser', async (browserId) => {
    socket.join(browserId);
    console.log(`客户端 ${socket.id} 加入浏览器 ${browserId}`);
    
    const browserData = browsers.get(browserId);
    if (!browserData) return;
    
    // 检查是否已启用 screencast
    const cdpData = cdpSessions.get(browserId);
    if (cdpData) {
      console.log(`[${browserId}] 🎬 使用 CDP screencast 模式 (高性能 10 FPS)`);
      return;
    }
    
    // 如果没有启用 screencast，启动 screenshot 定时器
    if (!screenshotIntervals.has(browserId)) {
      console.log(`[${browserId}] 📸 启动 screenshot 模式 (2 FPS)`);
      
      const intervalId = setInterval(async () => {
        try {
          const page = browserData.page;
          const screenshotBuffer = await page.screenshot({ type: 'jpeg', quality: 80 });
          const screenshot = screenshotBuffer.toString('base64');
          
          io.to(browserId).emit('frame', {
            browserId,
            frame: screenshot,
            timestamp: Date.now(),
            mode: 'screenshot'
          });
        } catch (error) {
          console.error(`[${browserId}] 获取画面失败:`, error.message);
        }
      }, 500);
      
      screenshotIntervals.set(browserId, intervalId);
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
  console.log(`🚀 浏览器调试工具已启动`);
  console.log(`📍 访问地址：http://localhost:${PORT}`);
  console.log(`🔧 支持浏览器：Chromium (CDP+Screenshots), Firefox, WebKit`);
  console.log(`⚡ Chromium 默认使用 CDP Screencast (10 FPS)`);
});
