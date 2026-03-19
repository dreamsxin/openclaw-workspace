// 元素卡片记忆游戏
import { storage, elementUtils } from './utils.js';

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
  let studyIndex = 0;
  let gameActive = false;

  // DOM 元素
  const startGameBtn = document.getElementById('startGame');
  const studyModeBtn = document.getElementById('studyMode');
  const gameModeSelect = document.getElementById('gameModeSelect');
  const gameBoard = document.getElementById('gameBoard');
  const studyView = document.getElementById('studyView');
  const elementCard = document.getElementById('elementCard');
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
  const prevElementBtn = document.getElementById('prevElement');
  const nextElementBtn = document.getElementById('nextElement');
  const studyCounter = document.getElementById('studyCounter');
  const cardDetail = document.getElementById('cardDetail');
  const detailContent = document.getElementById('detailContent');
  const closeDetailBtn = document.getElementById('closeDetail');

  // 加载元素数据
  fetch('/api/elements')
    .then(res => res.json())
    .then(data => {
      elements = data.elements;
      console.log(`加载了 ${elements.length} 个元素`);
    })
    .catch(err => console.error('加载元素数据失败:', err));

  // 开始游戏按钮
  startGameBtn.addEventListener('click', () => {
    gameModeSelect.classList.remove('hidden');
    studyView.classList.add('hidden');
    gameBoard.classList.add('hidden');
  });

  // 学习模式按钮
  studyModeBtn.addEventListener('click', () => {
    gameModeSelect.classList.add('hidden');
    studyView.classList.remove('hidden');
    gameBoard.classList.add('hidden');
    gameOverModal.classList.add('hidden');
    showStudyCard(0);
  });

  // 模式选择
  document.querySelectorAll('.mode-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      // 移除其他按钮的选中状态
      document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('selected'));
      // 添加当前按钮选中状态
      btn.classList.add('selected');
      
      currentMode = btn.dataset.mode;
      if (currentMode === 'full-card') {
        // 学习模式 - 隐藏游戏面板
        studyView.classList.remove('hidden');
        gameBoard.classList.add('hidden');
        gameOverModal.classList.add('hidden');
        showStudyCard(0);
      } else {
        // 游戏模式 - 隐藏学习面板
        studyView.classList.add('hidden');
        startGame(currentMode);
      }
    });
  });

  // 开始游戏
  function startGame(mode) {
    gameModeSelect.classList.add('hidden');
    gameBoard.classList.remove('hidden');
    studyView.classList.add('hidden');
    
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
    const gameElements = elements.slice(0, 12); // 使用 12 个元素生成 24 张卡片
    
    let cardPairs = [];
    
    gameElements.forEach((element, index) => {
      // 卡片 A - 元素符号 + 中文名称
      cardPairs.push({
        id: index,
        type: 'symbol',
        symbol: element.symbol,
        name: element.name,
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
          content = renderMiniElectronShells(element.electronConfig, element.atomicNumber);
          label = '电子壳层';
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

  // 渲染迷你电子壳层（卡片内）- 课本风格原子结构示意图
  function renderMiniElectronShells(config, symbol) {
    const maxShell = config.length;
    const shellSizes = [50, 76, 102, 128];
    const size = shellSizes[maxShell - 1] || 128;
    
    let html = `<div class="card-electron-shells" style="width: ${size}px; height: ${size}px;">`;
    html += `<div class="nucleus">${symbol}</div>`;
    
    config.forEach((electrons, shellIndex) => {
      const radius = shellSizes[shellIndex] / 2;
      const angleStep = (2 * Math.PI) / electrons;
      
      html += `<div class="shell shell-${shellIndex + 1}" style="width: ${shellSizes[shellIndex]}px; height: ${shellSizes[shellIndex]}px;"></div>`;
      
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

  // 渲染完整电子壳层（匹配成功后）- 课本风格
  function renderFullElectronShells(config, symbol) {
    const maxShell = config.length;
    const shellSizes = [50, 76, 102, 128];
    const size = shellSizes[maxShell - 1] || 128;
    
    let html = `<div class="card-electron-shells" style="width: ${size}px; height: ${size}px;">`;
    html += `<div class="nucleus">${symbol}</div>`;
    
    config.forEach((electrons, shellIndex) => {
      const radius = shellSizes[shellIndex] / 2;
      const angleStep = (2 * Math.PI) / electrons;
      
      html += `<div class="shell shell-${shellIndex + 1}" style="width: ${shellSizes[shellIndex]}px; height: ${shellSizes[shellIndex]}px;"></div>`;
      
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
    if (moves <= 15) stars = 3;
    else if (moves <= 25) stars = 2;
    
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

  // 学习模式
  function showStudyCard(index) {
    studyIndex = index;
    const element = elements[index];
    const bgColor = getCategoryColor(element.category);
    
    elementCard.innerHTML = `
      <div class="card-header" style="background: ${bgColor}">
        <h2>${element.symbol}</h2>
        <h3>${element.name}</h3>
        <p>${element.nameEn} · 原子序数 ${element.atomicNumber}</p>
      </div>
      <div class="card-body">
        <div class="card-section">
          <h4>⚛️ 电子壳层结构</h4>
          <div class="electron-shells-viz">
            ${renderElectronShells(element.electronConfig, element.symbol)}
          </div>
          <div class="electron-config">
            ${element.electronConfig.map((e, i) => `
              <div class="shell-info">
                <div class="shell-num">第${i+1}层</div>
                <div class="shell-electrons">${e}e⁻</div>
              </div>
            `).join('')}
          </div>
        </div>
        
        <div class="card-section">
          <h4>💫 化合价</h4>
          <div class="valence-list">
            ${element.valence.map(v => `
              <div class="valence-item">${v > 0 ? '+' : ''}${v}</div>
            `).join('')}
          </div>
        </div>
        
        <div class="card-section">
          <h4>🧪 常见化合物</h4>
          <div class="compounds-list">
            ${element.compounds.map(c => {
              const formula = c.formula;
              const name = c.name;
              const elementValence = c.elementValence;
              
              // 生成化合价标签
              const valenceTags = Object.entries(elementValence).map(([elemSymbol, valence]) => {
                const valenceStr = valence > 0 ? `+${valence}` : valence.toString();
                return `<span class="valence-tag"><span class="element-symbol">${elemSymbol}</span>${valenceStr}</span>`;
              }).join('');
              
              return `
                <div class="compound-item">
                  <div class="compound-header">
                    <span class="compound-formula">${formula}</span>
                    <span class="compound-name">${name}</span>
                  </div>
                  <div class="element-valence-tags">${valenceTags}</div>
                </div>
              `;
            }).join('')}
          </div>
        </div>
        
        <div class="card-section">
          <h4>📊 基本信息</h4>
          <p><strong>原子量：</strong>${element.atomicMass}</p>
          <p><strong>类别：</strong>${element.category}</p>
          <p><strong>周期：</strong>第${element.period}周期</p>
          <p><strong>族：</strong>第${element.group}族</p>
        </div>
        
        ${element.equations && element.equations.length > 0 ? `
        <div class="card-section">
          <h4>⚗️ 常见化学方程式</h4>
          <div class="equations-list">
            ${element.equations.map(eq => `
              <div class="equation-item">
                <div class="equation-main">${eq.equation}</div>
                <div>
                  <span class="equation-name">${eq.name}</span>
                  ${eq.condition ? `<span class="equation-condition">${eq.condition}</span>` : ''}
                </div>
              </div>
            `).join('')}
          </div>
        </div>
        ` : ''}
      </div>
    `;
    
    studyCounter.textContent = `${index + 1} / ${elements.length}`;
  }

  // 渲染电子壳层可视化（学习模式用）- 课本风格
  function renderElectronShells(config, symbol) {
    const maxShell = config.length;
    const shellSizes = [60, 100, 140, 180, 220];
    
    let html = `<div class="electron-shells-viz" style="width: ${shellSizes[maxShell-1] || 220}px; height: ${shellSizes[maxShell-1] || 220}px;">`;
    html += `<div class="nucleus">${symbol}</div>`;
    
    config.forEach((electrons, shellIndex) => {
      const radius = shellSizes[shellIndex] / 2;
      const angleStep = (2 * Math.PI) / electrons;
      
      html += `<div class="shell shell-${shellIndex + 1}" style="width: ${shellSizes[shellIndex]}px; height: ${shellSizes[shellIndex]}px;"></div>`;
      
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

  // 获取类别颜色
  function getCategoryColor(category) {
    const colors = {
      '碱金属': '#ff6b6b',
      '碱土金属': '#ffd93d',
      '过渡金属': '#6bcb77',
      '贫金属': '#4d96ff',
      '类金属': '#9b59b6',
      '非金属': '#95a5a6',
      '卤素': '#e67e22',
      '稀有气体': '#00d2d3'
    };
    return colors[category] || '#667eea';
  }

  // 学习模式导航
  prevElementBtn.addEventListener('click', () => {
    if (studyIndex > 0) {
      showStudyCard(studyIndex - 1);
    }
  });

  nextElementBtn.addEventListener('click', () => {
    if (studyIndex < elements.length - 1) {
      showStudyCard(studyIndex + 1);
    }
  });

  // 关闭详情
  closeDetailBtn.addEventListener('click', () => {
    cardDetail.classList.add('hidden');
  });
});
