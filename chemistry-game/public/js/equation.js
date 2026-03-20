// 方程式大爆炸 - Canvas 游戏
import { storage } from './utils.js';
import { equations, generateQuestion } from './equations-data.js';

document.addEventListener('DOMContentLoaded', () => {
  // Canvas 设置
  const bombCanvas = document.getElementById('bombCanvas');
  const bombCtx = bombCanvas.getContext('2d');
  const equationCanvas = document.getElementById('equationCanvas');
  const equationCtx = equationCanvas.getContext('2d');
  const optionsCanvas = document.getElementById('optionsCanvas');
  const optionsCtx = optionsCanvas.getContext('2d');
  
  // 游戏状态
  let score = 0;
  let combo = 0;
  let level = 1;
  let timeLeft = 30;
  let timerInterval = null;
  let currentQuestion = null;
  let isPlaying = false;
  let highScore = storage.get('equationHighScore') || 0;
  let selectedOptionIndex = -1; // 当前选中的选项
  
  // 炸弹动画
  let bombPhase = 0;
  let sparkParticles = [];
  
  // DOM 元素
  const scoreValue = document.getElementById('scoreValue');
  const comboValue = document.getElementById('comboValue');
  const levelValue = document.getElementById('levelValue');
  const timerValue = document.getElementById('timerValue');
  const gameOverModal = document.getElementById('gameOverModal');
  const finalScore = document.getElementById('finalScore');
  const playAgainBtn = document.getElementById('playAgainBtn');
  const startScreen = document.getElementById('startScreen');
  const startBtn = document.getElementById('startBtn');
  
  // 初始化 Canvas 尺寸
  function resizeCanvases() {
    bombCanvas.width = 100;
    bombCanvas.height = 100;
    
    // 方程式 Canvas 使用更大宽度
    equationCanvas.width = Math.min(800, window.innerWidth - 60);
    equationCanvas.height = 100;
    
    optionsCanvas.width = optionsCanvas.parentElement.clientWidth;
    optionsCanvas.height = optionsCanvas.parentElement.clientHeight;
  }
  
  // 开始游戏
  function startGame() {
    score = 0;
    combo = 0;
    level = 1;
    isPlaying = true;
    sparkParticles = [];
    
    updateUI();
    startScreen.classList.add('hidden');
    gameOverModal.classList.add('hidden');
    
    nextQuestion();
  }
  
  // 下一题
  function nextQuestion() {
    currentQuestion = generateQuestion();
    optionAreas = []; // 重置选项区域
    selectedOptionIndex = -1; // 重置选中
    timeLeft = Math.max(10, 30 - level * 2); // 随关卡减少时间，重新计时
    updateUI();
    startTimer(); // 重新开始计时
    renderAll();
  }
  
  // 启动计时器
  function startTimer() {
    if (timerInterval) clearInterval(timerInterval);
    
    timerInterval = setInterval(() => {
      timeLeft--;
      updateUI();
      
      if (timeLeft <= 10) {
        timerValue.classList.add('warning');
      }
      if (timeLeft <= 5) {
        timerValue.classList.add('critical');
      }
      if (timeLeft > 10) {
        timerValue.classList.remove('warning', 'critical');
      }
      
      if (timeLeft <= 0) {
        gameOver();
      }
    }, 1000);
  }
  
  // 更新 UI
  function updateUI() {
    scoreValue.textContent = score;
    comboValue.textContent = `x${combo}`;
    levelValue.textContent = level;
    timerValue.textContent = timeLeft;
  }
  
  // 渲染所有内容
  function renderAll() {
    drawBomb();
    drawEquation();
    drawOptions();
    requestAnimationFrame(animate);
  }
  
  // 动画循环
  function animate() {
    if (!isPlaying) return;
    
    bombPhase += 0.05;
    drawBomb();
    
    // 更新和绘制火花
    updateAndDrawSparks();
    
    requestAnimationFrame(animate);
  }
  
  // 绘制炸弹
  function drawBomb() {
    const ctx = bombCtx;
    const w = bombCanvas.width;
    const h = bombCanvas.height;
    const cx = w / 2;
    const cy = h / 2;
    
    ctx.clearRect(0, 0, w, h);
    
    // 炸弹主体（圆形）
    const bombRadius = 35 + Math.sin(bombPhase) * 2;
    
    // 渐变
    const gradient = ctx.createRadialGradient(cx - 10, cy - 10, 5, cx, cy, bombRadius);
    gradient.addColorStop(0, '#4a4a4a');
    gradient.addColorStop(1, '#1a1a1a');
    
    ctx.beginPath();
    ctx.arc(cx, cy, bombRadius, 0, Math.PI * 2);
    ctx.fillStyle = gradient;
    ctx.fill();
    
    // 高光
    ctx.beginPath();
    ctx.arc(cx - 12, cy - 12, 8, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
    ctx.fill();
    
    // 引信
    ctx.strokeStyle = '#8b7355';
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(cx + 15, cy - 30);
    ctx.quadraticCurveTo(cx + 25, cy - 45, cx + 30, cy - 50);
    ctx.stroke();
    
    // 火花（随时间增加）
    if (timeLeft <= 10) {
      const sparkCount = (10 - timeLeft) * 3;
      for (let i = 0; i < sparkCount; i++) {
        const angle = Math.random() * Math.PI * 2;
        const dist = 40 + Math.random() * 20;
        const sx = cx + Math.cos(angle) * dist;
        const sy = cy - 50 + Math.sin(angle) * dist;
        
        ctx.fillStyle = ['#ff0', '#f80', '#f00'][Math.floor(Math.random() * 3)];
        ctx.beginPath();
        ctx.arc(sx, sy, 2 + Math.random() * 3, 0, Math.PI * 2);
        ctx.fill();
      }
    }
    
    // 倒计时数字
    ctx.fillStyle = timeLeft <= 5 ? '#f00' : '#fff';
    ctx.font = 'bold 24px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(timeLeft, cx, cy + 5);
  }
  
  // 更新和绘制火花粒子
  function updateAndDrawSparks() {
    const ctx = bombCtx;
    const w = bombCanvas.width;
    const h = bombCanvas.height;
    
    // 添加新火花
    if (timeLeft <= 10 && Math.random() > 0.5) {
      const cx = w / 2;
      sparkParticles.push({
        x: cx + 15,
        y: h / 2 - 30,
        vx: (Math.random() - 0.5) * 4,
        vy: -2 - Math.random() * 3,
        life: 1,
        color: ['#ff0', '#f80', '#f00'][Math.floor(Math.random() * 3)]
      });
    }
    
    // 更新和绘制
    for (let i = sparkParticles.length - 1; i >= 0; i--) {
      const p = sparkParticles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.1;
      p.life -= 0.03;
      
      if (p.life <= 0) {
        sparkParticles.splice(i, 1);
        continue;
      }
      
      ctx.globalAlpha = p.life;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, 3, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }
  
  // 绘制方程式（Canvas 绘制，条件在箭头上方）
  function drawEquation() {
    const ctx = equationCtx;
    const w = equationCanvas.width;
    const h = equationCanvas.height;
    
    ctx.clearRect(0, 0, w, h);
    
    // 背景
    ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
    ctx.fillRect(0, 0, w, h);
    
    const eq = currentQuestion;
    const arrowX = w / 2;
    const arrowY = h / 2;
    
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    
    // 使用 generateQuestion 返回的 leftDisplay 和 rightDisplay
    const leftText = eq.leftDisplay || '___';
    const rightText = eq.rightDisplay || '___';
    const conditionText = eq.questionType === 'condition' ? '___' : eq.parts.condition;
    
    // 根据文字长度动态调整字体大小和位置
    let fontSize = 22;
    ctx.font = `bold ${fontSize}px Arial`;
    
    const leftWidth = ctx.measureText(leftText).width;
    const rightWidth = ctx.measureText(rightText).width;
    
    // 计算需要的总宽度
    const arrowWidth = 80;
    const padding = 30;
    const totalWidth = leftWidth + arrowWidth + rightWidth + padding * 2;
    
    // 如果文字太长，缩小字体
    if (totalWidth > w - 20) {
      fontSize = Math.floor(20 * (w - 20) / totalWidth);
      ctx.font = `bold ${fontSize}px Arial`;
    }
    
    // 重新计算宽度
    const adjustedLeftWidth = ctx.measureText(leftText).width;
    const adjustedRightWidth = ctx.measureText(rightText).width;
    
    // 计算左右位置，确保在 Canvas 内
    const leftX = arrowX - arrowWidth / 2 - adjustedLeftWidth / 2 - padding;
    const rightX = arrowX + arrowWidth / 2 + adjustedRightWidth / 2 + padding;
    
    // 绘制左边
    ctx.fillStyle = '#ffffff';
    ctx.fillText(leftText, leftX, arrowY);
    
    // 箭头
    ctx.strokeStyle = '#34d399';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(arrowX - 40, arrowY);
    ctx.lineTo(arrowX + 40, arrowY);
    ctx.lineTo(arrowX + 32, arrowY - 10);
    ctx.moveTo(arrowX + 40, arrowY);
    ctx.lineTo(arrowX + 32, arrowY + 10);
    ctx.stroke();
    
    // 条件（箭头上方）
    if (conditionText) {
      ctx.fillStyle = '#fbbf24';
      ctx.font = `${Math.max(12, fontSize - 8)}px Arial`;
      ctx.textAlign = 'center';
      ctx.fillText(conditionText, arrowX, arrowY - 22);
    }
    
    // 右边生成物
    ctx.fillStyle = '#ffffff';
    ctx.font = `bold ${fontSize}px Arial`;
    ctx.fillText(rightText, rightX, arrowY);
    
    // 题目类型标签
    ctx.fillStyle = '#34d399';
    ctx.font = '14px Arial';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    ctx.fillText(`${eq.equationName} · ${eq.equationType}`, 10, 5);
  }
  
  // 绘制选项
  function drawOptions() {
    const ctx = optionsCtx;
    const w = optionsCanvas.width;
    const h = optionsCanvas.height;
    
    ctx.clearRect(0, 0, w, h);
    
    const options = currentQuestion.options;
    const cols = 2;
    const rows = 2;
    const padding = 15;
    const optionWidth = (w - padding * (cols + 1)) / cols;
    const optionHeight = (h - padding * (rows + 1)) / rows;
    
    // 存储选项区域供点击检测
    optionAreas = [];
    
    options.forEach((opt, index) => {
      const col = index % cols;
      const row = Math.floor(index / cols);
      const x = padding + col * (optionWidth + padding);
      const y = padding + row * (optionHeight + padding);
      
      // 选项背景
      const gradient = ctx.createLinearGradient(x, y, x, y + optionHeight);
      
      // 选中效果
      if (index === selectedOptionIndex) {
        gradient.addColorStop(0, '#667eea');
        gradient.addColorStop(1, '#764ba2');
      } else {
        gradient.addColorStop(0, '#4a5568');
        gradient.addColorStop(1, '#2d3748');
      }
      
      ctx.fillStyle = gradient;
      roundRect(ctx, x, y, optionWidth, optionHeight, 10);
      ctx.fill();
      
      // 选中边框
      if (index === selectedOptionIndex) {
        ctx.strokeStyle = '#fbbf24';
        ctx.lineWidth = 3;
        ctx.stroke();
      }
      
      // 选项文字
      ctx.fillStyle = '#ffffff';
      ctx.font = 'bold 20px Arial';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(opt, x + optionWidth / 2, y + optionHeight / 2);
      
      // 存储点击区域
      optionAreas.push({ x, y, width: optionWidth, height: optionHeight, text: opt });
    });
  }
  
  // 选项点击区域
  let optionAreas = [];
  
  function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }
  
  // 处理选项点击
  optionsCanvas.addEventListener('click', (e) => {
    if (!isPlaying) return;
    
    const rect = optionsCanvas.getBoundingClientRect();
    const scaleX = optionsCanvas.width / rect.width;
    const scaleY = optionsCanvas.height / rect.height;
    const clickX = (e.clientX - rect.left) * scaleX;
    const clickY = (e.clientY - rect.top) * scaleY;
    
    optionAreas.forEach((area, index) => {
      if (clickX >= area.x && clickX <= area.x + area.width &&
          clickY >= area.y && clickY <= area.y + area.height) {
        // 选中选项
        selectedOptionIndex = index;
        renderAll();
        // 延迟检查答案
        setTimeout(() => checkAnswer(index), 200);
      }
    });
  });
  
  // 检查答案
  function checkAnswer(selectedIndex) {
    const selected = currentQuestion.options[selectedIndex];
    const isCorrect = selected === currentQuestion.correct;
    
    if (isCorrect) {
      // 正确
      combo++;
      level = Math.floor(combo / 5) + 1;
      const baseScore = 100;
      const comboBonus = Math.min(combo - 1, 10) * 20;
      const timeBonus = timeLeft * 5;
      score += baseScore + comboBonus + timeBonus;
      
      // 显示正确效果
      showFeedback(true);
      
      // 自动进入下一题，重新计时
      setTimeout(() => {
        selectedOptionIndex = -1;
        nextQuestion();
      }, 800);
    } else {
      // 错误 - 减 10 秒
      timeLeft = Math.max(0, timeLeft - 10);
      updateUI();
      combo = 0; // 重置连击
      
      // 显示错误效果
      showFeedback(false);
      
      // 如果时间归零则游戏结束
      if (timeLeft <= 0) {
        setTimeout(gameOver, 500);
      } else {
        selectedOptionIndex = -1;
        renderAll();
      }
    }
  }
  
  // 显示反馈
  function showFeedback(isCorrect) {
    const ctx = optionsCtx;
    const w = optionsCanvas.width;
    const h = optionsCanvas.height;
    
    ctx.fillStyle = isCorrect ? 'rgba(52, 211, 153, 0.3)' : 'rgba(239, 68, 68, 0.3)';
    ctx.fillRect(0, 0, w, h);
    
    ctx.fillStyle = isCorrect ? '#34d399' : '#ef4444';
    ctx.font = 'bold 48px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(isCorrect ? '✓ 正确!' : '✗ 错误!', w / 2, h / 2);
  }
  
  // 游戏结束
  function gameOver() {
    isPlaying = false;
    clearInterval(timerInterval);
    
    const isNewHighScore = score > highScore;
    if (isNewHighScore) {
      highScore = score;
      storage.save('equationHighScore', highScore);
    }
    
    finalScore.innerHTML = `
      <span class="score-number">${score}分</span>
      <span class="score-detail">连击 x${combo} · 关卡 ${level}</span>
      ${isNewHighScore ? '<span class="high-score-badge">🏆 新纪录！</span>' : ''}
    `;
    
    gameOverModal.classList.remove('hidden');
  }
  
  // 事件监听
  startBtn.addEventListener('click', startGame);
  playAgainBtn.addEventListener('click', startGame);
  window.addEventListener('resize', () => {
    resizeCanvases();
    if (isPlaying) renderAll();
  });
  
  // 初始化
  resizeCanvases();
});
