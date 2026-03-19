// 元素卡片记忆游戏
import { storage } from './utils.js';

document.addEventListener('DOMContentLoaded', () => {
  let elements = [];
  let cards = [];
  let flippedCards = [];
  let matchedPairs = 0;
  let score = 0;
  let moves = 0;
  let timer = 0;
  let timerInterval = null;
  let currentMode = '';
  let currentGridSize = 4; // 默认 4x4
  let gameActive = false;

  // DOM 元素
  const gameModeSelect = document.getElementById('gameModeSelect');
  const gameBoard = document.getElementById('gameBoard');
  const scoreValue = document.getElementById('scoreValue');
  const movesValue = document.getElementById('movesValue');
  const timerValue = document.getElementById('timerValue');
  const gameOverModal = document.getElementById('gameOver');
  const finalScore = document.getElementById('finalScore');
  const finalMoves = document.getElementById('finalMoves');
  const finalTime = document.getElementById('finalTime');
  const starsDisplay = document.getElementById('starsDisplay');
  const playAgainBtn = document.getElementById('playAgain');
  const backToMenuBtn = document.getElementById('backToMenu');

  // 加载元素数据
  fetch('/api/elements')
    .then(res => res.json())
    .then(data => {
      elements = data.elements;
      console.log(`加载了 ${elements.length} 个元素`);
    })
    .catch(err => console.error('加载元素数据失败:', err));

  // 模式选择
  document.querySelectorAll('.mode-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      // 移除其他按钮的选中状态
      document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('selected'));
      // 添加当前按钮选中状态
      btn.classList.add('selected');
      
      currentMode = btn.dataset.mode;
      // 开始游戏
      startGame(currentMode);
    });
  });

  // 卡片数量选择
  document.querySelectorAll('.grid-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const newGridSize = parseInt(btn.dataset.grid);
      
      // 如果难度没有变化，不处理
      if (newGridSize === currentGridSize) return;
      
      // 移除其他按钮的选中状态
      document.querySelectorAll('.grid-btn').forEach(b => b.classList.remove('selected'));
      // 添加当前按钮选中状态
      btn.classList.add('selected');
      
      currentGridSize = newGridSize;
      console.log(`选择难度：${currentGridSize}x${currentGridSize}`);
      
      // 如果游戏正在进行中，自动重新开始
      if (gameActive && !gameBoard.classList.contains('hidden')) {
        // 显示提示信息
        const toast = document.createElement('div');
        toast.className = 'difficulty-change-toast';
        toast.textContent = `🔄 难度已更改为 ${currentGridSize}×${currentGridSize}，游戏重新开始`;
        document.body.appendChild(toast);
        
        setTimeout(() => toast.remove(), 3000);
        
        // 重新开始游戏
        setTimeout(() => {
          startGame(currentMode);
        }, 500);
      }
    });
  });

  // 开始游戏
  function startGame(mode) {
    gameModeSelect.classList.add('hidden');
    gameBoard.classList.remove('hidden');
    
    // 设置网格大小属性
    gameBoard.dataset.grid = currentGridSize;
    
    resetGame();
    generateCards(mode);
    startTimer();
    gameActive = true;
  }

  // 重置游戏
  function resetGame() {
    score = 0;
    moves = 0;
    timer = 0;
    matchedPairs = 0;
    flippedCards = [];
    cards = [];
    scoreValue.textContent = '0';
    movesValue.textContent = '0';
    timerValue.textContent = '00:00';
    clearInterval(timerInterval);
  }

  // 生成卡片
  function generateCards(mode) {
    gameBoard.innerHTML = '';
    
    // 根据网格大小计算卡片数量
    const totalCards = currentGridSize * currentGridSize;
    const elementCount = totalCards / 2; // 每个元素 2 张卡片
    
    // 随机选择元素
    const shuffledElements = [...elements].sort(() => Math.random() - 0.5);
    const gameElements = shuffledElements.slice(0, elementCount);
    
    let cardPairs = [];
    
    gameElements.forEach((element, index) => {
      // 卡片 A - 元素符号
      cardPairs.push({
        id: index,
        type: 'symbol',
        symbol: element.symbol,
        element: element
      });
      
      // 卡片 B - 对应内容
      let content, label;
      switch(mode) {
        case 'symbol-name':
          content = element.name;
          label = '元素名称';
          break;
        case 'symbol-config':
          content = renderMiniElectronShells(element.electronConfig, element.symbol);
          // 电子排布数字显示在 label 中
          label = element.electronConfig.join(',');
          break;
        case 'symbol-valence':
          content = element.valence.map(v => v > 0 ? `+${v}` : v).join(', ');
          label = '化合价';
          break;
      }
      
      cardPairs.push({
        id: index,
        type: mode === 'symbol-name' ? 'name' : mode === 'symbol-config' ? 'config' : 'valence',
        content: content,
        label: label,
        element: element
      });
    });
    
    // 洗牌
    cardPairs.sort(() => Math.random() - 0.5);
    
    // 创建卡片 DOM
    cardPairs.forEach((card, index) => {
      const cardEl = document.createElement('div');
      cardEl.className = 'card';
      cardEl.dataset.index = index;
      cardEl.dataset.id = card.id;
      cardEl.dataset.type = card.type;
      
      cardEl.innerHTML = `
        <div class="card-inner">
          <div class="card-back">❓</div>
          <div class="card-front">
            ${card.type === 'symbol' ? 
              `<div class="card-symbol">${card.symbol}</div>
               <div class="card-label">元素符号</div>` :
              `<div class="card-content">${card.content}</div>
               <div class="card-label">${card.label || ''}</div>`
            }
          </div>
        </div>
      `;
      
      cardEl.addEventListener('click', () => flipCard(cardEl, card));
      gameBoard.appendChild(cardEl);
      cards.push(cardEl);
    });
  }

  // 渲染迷你电子壳层（卡片内）- 原子结构示意图（电子点，最外层颜色区分）
  function renderMiniElectronShells(config, symbol) {
    const maxShell = config.length;
    // 轨道间隔 20px
    const shellSizes = [40, 60, 80, 100];
    const size = shellSizes[maxShell - 1] || 100;
    
    // 判断最外层电子是否容易丢失
    const outerElectrons = config[config.length - 1];
    const isUnstable = outerElectrons <= 3; // 1-3 个电子容易失去（金属）
    const outerShellClass = isUnstable ? 'electron-lose' : 'electron-stable';
    
    let html = `<div class="card-electron-shells" style="width: ${size}px; height: ${size}px;">`;
    // 中间不显示元素符号，只显示原子核圆点
    html += `<div class="nucleus"></div>`;
    
    config.forEach((electrons, shellIndex) => {
      const radius = shellSizes[shellIndex] / 2;
      const angleStep = (2 * Math.PI) / electrons;
      const isOuterShell = shellIndex === config.length - 1;
      
      // 绘制轨道（圆形）
      html += `<div class="shell shell-${shellIndex + 1}" style="width: ${shellSizes[shellIndex]}px; height: ${shellSizes[shellIndex]}px;"></div>`;
      
      // 绘制电子小圆点
      for (let i = 0; i < electrons; i++) {
        const angle = angleStep * i - Math.PI / 2;
        const x = Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        const electronClass = isOuterShell ? outerShellClass : 'electron';
        html += `<div class="electron ${electronClass}" style="left: calc(50% + ${x}px); top: calc(50% + ${y}px);"></div>`;
      }
    });
    
    html += '</div>';
    return html;
  }

  // 渲染完整电子壳层（匹配成功后）- 课本风格（无原子核符号）
  function renderFullElectronShells(config, symbol) {
    const maxShell = config.length;
    const shellSizes = [50, 76, 102, 128];
    const size = shellSizes[maxShell - 1] || 128;
    
    let html = `<div class="card-electron-shells" style="width: ${size}px; height: ${size}px;">`;
    // 不显示原子核符号，只显示小圆点
    html += `<div class="nucleus"></div>`;
    
    config.forEach((electrons, shellIndex) => {
      const radius = shellSizes[shellIndex] / 2;
      const angleStep = (2 * Math.PI) / electrons;
      
      // 绘制轨道（圆形）
      html += `<div class="shell shell-${shellIndex + 1}" style="width: ${shellSizes[shellIndex]}px; height: ${shellSizes[shellIndex]}px;"></div>`;
      
      // 绘制电子小圆点
      for (let i = 0; i < electrons; i++) {
        const angle = angleStep * i - Math.PI / 2;
        const x = Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        html += `<div class="electron" style="left: calc(50% + ${x}px); top: calc(50% + ${y}px);"></div>`;
      }
    });
    
    html += '</div>';
    return html;
  }

  // 翻牌
  function flipCard(cardEl, card) {
    if (!gameActive) return;
    if (cardEl.classList.contains('flipped')) return;
    if (flippedCards.length >= 2) return;
    
    cardEl.classList.add('flipped');
    flippedCards.push({ el: cardEl, card: card });
    
    if (flippedCards.length === 2) {
      moves++;
      movesValue.textContent = moves;
      checkMatch();
    }
  }

  // 检查匹配
  function checkMatch() {
    const [card1, card2] = flippedCards;
    const isMatch = card1.card.id === card2.card.id && card1.card.type !== card2.card.type;
    
    if (isMatch) {
      // 匹配成功 - 更新为完整形态
      setTimeout(() => {
        const element = card1.card.element;
        
        // 更新两张卡片为完整形态
        updateMatchedCard(card1.el, element);
        updateMatchedCard(card2.el, element);
        
        card1.el.classList.add('matched');
        card2.el.classList.add('matched');
        score += 20;
        scoreValue.textContent = score;
        matchedPairs++;
        flippedCards = [];
        
        // 检查游戏结束
        if (matchedPairs >= cards.length / 2) {
          endGame();
        }
      }, 500);
    } else {
      // 匹配失败
      setTimeout(() => {
        card1.el.classList.remove('flipped');
        card2.el.classList.remove('flipped');
        flippedCards = [];
      }, 1000);
    }
  }

  // 更新匹配成功的卡片为完整形态
  function updateMatchedCard(cardEl, element) {
    const configHtml = renderFullElectronShells(element.electronConfig, element.symbol);
    
    cardEl.querySelector('.card-front').innerHTML = `
      <div class="matched-content">
        <div class="matched-atomic">#${element.atomicNumber}</div>
        <div class="matched-symbol">${element.symbol}</div>
        <div class="matched-name">${element.name}</div>
        ${configHtml}
        <div class="matched-config">${element.electronConfig.join(') (')}))</div>
      </div>
    `;
  }

  // 计时器
  function startTimer() {
    timerInterval = setInterval(() => {
      timer++;
      const minutes = Math.floor(timer / 60).toString().padStart(2, '0');
      const seconds = (timer % 60).toString().padStart(2, '0');
      timerValue.textContent = `${minutes}:${seconds}`;
    }, 1000);
  }

  // 游戏结束
  function endGame() {
    gameActive = false;
    clearInterval(timerInterval);
    
    // 计算星级
    let stars = 1;
    if (moves <= currentGridSize * 2) stars = 3;
    else if (moves <= currentGridSize * 3) stars = 2;
    
    finalScore.textContent = score;
    finalMoves.textContent = moves;
    finalTime.textContent = timerValue.textContent;
    starsDisplay.innerHTML = '⭐'.repeat(stars) + '☆'.repeat(3 - stars);
    
    gameOverModal.classList.remove('hidden');
  }

  // 再玩一次
  playAgainBtn.addEventListener('click', () => {
    gameOverModal.classList.add('hidden');
    startGame(currentMode);
  });

  // 返回菜单
  backToMenuBtn.addEventListener('click', () => {
    gameOverModal.classList.add('hidden');
    gameModeSelect.classList.remove('hidden');
    gameBoard.classList.add('hidden');
  });
});
