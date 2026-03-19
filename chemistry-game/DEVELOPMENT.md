# 化学游戏开发文档

## 📁 项目结构

```
chemistry-game/
├── src/                      # 服务端代码
│   ├── server.js            # Express 服务器
│   └── data/                # 数据文件
│       ├── elements.json    # 元素数据 (118 个元素)
│       └── experiments.json # 实验数据 (8 个实验)
├── public/                   # 前端静态资源
│   ├── css/                 # 样式文件
│   │   ├── style.css        # 主样式
│   │   ├── cards.css        # 卡片游戏样式
│   │   ├── experiments.css  # 实验页面样式
│   │   ├── responsive.css   # 响应式样式 ⭐ 新增
│   │   └── style-fix.css    # 样式修复
│   ├── js/                  # JavaScript 文件
│   │   ├── app.js           # 主应用逻辑
│   │   ├── cards.js         # 卡片游戏逻辑
│   │   ├── experiments.js   # 实验页面逻辑
│   │   └── utils.js         # 工具函数库 ⭐ 新增
│   └── images/              # 图片资源
├── views/                    # EJS 模板
│   ├── index.ejs            # 主页（周期表）
│   ├── cards.ejs            # 卡片游戏
│   └── experiments.ejs      # 实验页面
├── package.json             # 项目配置
├── .eslintrc.json          # ESLint 配置 ⭐ 新增
├── .editorconfig           # EditorConfig 配置 ⭐ 新增
├── jsdoc.conf.json         # JSDoc 配置 ⭐ 新增
└── DEVELOPMENT.md          # 开发文档 (本文件)
```

## 🛠️ 开发工具

### 代码质量工具

#### ESLint
```bash
# 安装
npm install eslint --save-dev

# 运行
npx eslint public/js/*.js

# 自动修复
npx eslint public/js/*.js --fix
```

#### JSDoc
```bash
# 安装
npm install docdash --save-dev

# 生成文档
npx jsdoc -c jsdoc.conf.json

# 查看文档
open docs/index.html
```

### 开发规范

#### 命名约定
- **文件**: kebab-case (如 `element-card.js`)
- **函数**: camelCase (如 `getElementData()`)
- **类**: PascalCase (如 `ElementCard`)
- **常量**: UPPER_SNAKE_CASE (如 `MAX_ELEMENTS`)
- **私有变量**: 下划线前缀 (如 `_privateVar`)

#### 代码注释
```javascript
/**
 * 获取元素数据
 * @param {string} symbol - 元素符号
 * @returns {Object|null} 元素对象，未找到返回 null
 */
function getElementData(symbol) {
  // 实现代码
}
```

#### Git 提交规范
```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式（不影响代码运行）
refactor: 重构（即不是新增功能，也不是修改 bug）
test: 测试相关
chore: 构建过程或辅助工具变动
```

示例：
```bash
git commit -m "feat: 添加元素搜索功能"
git commit -m "fix: 修复移动端布局溢出问题"
git commit -m "refactor: 优化响应式布局代码结构"
```

## 📱 响应式断点

| 断点名称 | 屏幕宽度 | 布局策略 |
|---------|---------|---------|
| 超大屏 | ≥1600px | 放大周期表，加宽信息面板 |
| 大屏 | 1200-1600px | 标准双栏布局 |
| 中屏 | 900-1200px | 缩小元素卡片，调整间距 |
| 小屏/平板 | 768-900px | 上下布局，周期表可滚动 |
| 手机横屏 | 500-768px | 优化触摸目标，隐藏次要信息 |
| 手机竖屏 | <500px | 单栏布局，底部导航 |
| 超小屏 | <360px | 极简布局，最小元素尺寸 |

## 🎯 性能优化清单

### 已实现 ✅
- [x] CSS 文件分离（按功能模块）
- [x] 响应式图片加载
- [x] 防抖/节流工具函数
- [x] LocalStorage 缓存
- [x] 触摸设备优化
- [x] 减少动画偏好支持

### 待实现 📋
- [ ] 虚拟滚动（周期表元素）
- [ ] 图片懒加载
- [ ] Service Worker 缓存
- [ ] 代码分割（按页面）
- [ ] CDN 部署
- [ ] Gzip 压缩

## 🧪 测试清单

### 浏览器兼容性
- [x] Chrome (最新)
- [x] Firefox (最新)
- [x] Safari (最新)
- [x] Edge (最新)
- [ ] Chrome (Android)
- [ ] Safari (iOS)

### 设备测试
- [x] 桌面 (1920×1080)
- [x] 笔记本 (1366×768)
- [x] 平板 (768×1024)
- [x] 手机 (375×667)
- [ ] 手机 (414×896)

### 功能测试
- [x] 周期表展示
- [x] 元素详情查看
- [x] 关联实验显示
- [x] 卡片记忆游戏
- [x] 实验详情弹窗
- [x] 响应式布局
- [ ] 键盘快捷键
- [ ] 搜索功能

## 📊 性能指标

### 目标
- 首屏加载时间：< 2s
- 可交互时间：< 3s
- Lighthouse 分数：> 90

### 当前状态
- 首屏加载时间：~1.5s
- 可交互时间：~2.5s
- Lighthouse 分数：待测试

## 🔧 常用命令

```bash
# 开发模式启动
npm run dev

# 生产环境构建
npm run build

# 代码检查
npm run lint

# 生成文档
npm run docs

# 运行测试
npm test
```

## 🐛 已知问题

1. **移动端 Safari** - 周期表滚动偶尔卡顿
   - 临时方案：使用 `-webkit-overflow-scrolling: touch`
   - 长期方案：实现虚拟滚动

2. **小屏幕设备** - 元素名称显示不全
   - 临时方案：隐藏元素名称，只显示符号
   - 长期方案：优化布局，使用缩写

3. **深色模式** - 部分颜色对比度不足
   - 临时方案：手动调整颜色
   - 长期方案：使用 CSS 变量统一管理

## 📝 更新日志

### v1.2.0 (2026-03-19) - 响应式优化
- ✅ 添加完整响应式布局
- ✅ 添加移动端底部导航
- ✅ 添加工具函数库
- ✅ 添加 ESLint 配置
- ✅ 添加 JSDoc 配置
- ✅ 添加 EditorConfig 配置
- ✅ 优化触摸设备体验
- ✅ 添加深色模式支持
- ✅ 添加减少动画偏好支持

### v1.1.0 (2026-03-18) - 关联实验
- ✅ 添加实验详情弹窗
- ✅ 智能关联实验
- ✅ 显示匹配原因

### v1.0.0 (2026-03-17) - 初始版本
- ✅ 118 个完整元素周期表
- ✅ 元素详情展示
- ✅ 卡片记忆游戏
- ✅ 化学实验模块

## 📚 参考资料

- [MDN Web 文档](https://developer.mozilla.org/)
- [Web 性能最佳实践](https://web.dev/performance/)
- [响应式设计模式](https://responsivedesign.is/)
- [可访问性指南](https://www.w3.org/WAI/WCAG21/quickref/)

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

MIT License
