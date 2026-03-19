const express = require('express');
const path = require('path');
const elementsData = require('./data/elements.json');
const experimentsData = require('./data/experiments.json');
const moleculesData = require('./data/molecules.json');

const app = express();
const PORT = process.env.PORT || 3000;

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));
app.use(express.static(path.join(__dirname, '../public'), {
  setHeaders: (res, path) => {
    // 为 JS 文件设置正确的 MIME 类型
    if (path.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript');
    }
  }
}));
app.use(express.json());

// 主页 - 周期表探索
app.get('/', (req, res) => {
  res.render('index', {
    elements: elementsData.elements,
    categories: elementsData.categories
  });
});

// 卡片记忆游戏
app.get('/cards', (req, res) => {
  res.render('cards', {});
});

// 化学实验
app.get('/experiments', (req, res) => {
  res.render('experiments', {});
});

// 分子消消乐
app.get('/molecule', (req, res) => {
  res.render('molecule', {});
});

// API: 获取实验数据
app.get('/api/experiments', (req, res) => {
  res.json(experimentsData);
});

// API: 获取分子数据
app.get('/api/molecules', (req, res) => {
  res.json(moleculesData);
});

// API: 获取所有元素
app.get('/api/elements', (req, res) => {
  res.json(elementsData);
});

// API: 获取单个元素
app.get('/api/elements/:symbol', (req, res) => {
  const element = elementsData.elements.find(e => e.symbol === req.params.symbol.toUpperCase());
  if (element) {
    res.json({ success: true, data: element });
  } else {
    res.status(404).json({ success: false, message: '元素未找到' });
  }
});

// API: 随机测验
app.get('/api/quiz/random', (req, res) => {
  const randomElement = elementsData.elements[Math.floor(Math.random() * elementsData.elements.length)];
  const questionTypes = ['symbol', 'name', 'atomicNumber'];
  const questionType = questionTypes[Math.floor(Math.random() * questionTypes.length)];
  
  let question, answer;
  switch(questionType) {
    case 'symbol':
      question = `元素"${randomElement.name}"的符号是什么？`;
      answer = randomElement.symbol;
      break;
    case 'name':
      question = `符号"${randomElement.symbol}"代表什么元素？`;
      answer = randomElement.name;
      break;
    case 'atomicNumber':
      question = `元素"${randomElement.name}"的原子序数是多少？`;
      answer = randomElement.atomicNumber.toString();
      break;
  }
  
  res.json({
    success: true,
    question,
    answer,
    hint: `提示：${randomElement.category}，原子量 ${randomElement.atomicMass}`
  });
});

// API: 提交测验答案
app.post('/api/quiz/submit', (req, res) => {
  const { answer, expected } = req.body;
  const isCorrect = answer.trim().toLowerCase() === expected.toString().toLowerCase();
  res.json({
    success: true,
    correct: isCorrect,
    message: isCorrect ? '🎉 正确！' : `❌ 错误，正确答案是：${expected}`
  });
});

app.listen(PORT, () => {
  console.log(`🧪 化学周期表游戏运行在 http://localhost:${PORT}`);
  console.log(`📚 共加载 ${elementsData.elements.length} 个元素`);
});
