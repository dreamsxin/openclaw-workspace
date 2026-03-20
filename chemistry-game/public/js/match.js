// 元素消消乐 - Canvas 版本（化合物配对）
import { storage } from './utils.js';
import { compounds, canFormCompound, getPossibleMatches } from './match-compounds.js';

document.addEventListener('DOMContentLoaded', () => {
  // 游戏配置
  const GRID_SIZE = 6;
  const TILE_COUNT = GRID_SIZE * GRID_SIZE;
  
  // Canvas 设置
  const canvas = document.getElementById('gameCanvas');
  const ctx = canvas.getContext('2d');
  
  // 游戏状态
  let tiles = [];
  let selectedTile = null;
  let score = 0;
  let moves = 0;
  let combo = 0;
  let isProcessing = false;
  let highScore = storage.get('matchHighScore') || 0;
  
  // 动画状态
  let animations = [];
  let particles = [];
  let floatingTexts = [];
  
  // 视觉配置
  let tileWidth = 60;
  let tileHeight = 60;
  let gap = 6;
  let offsetX = 0;
  let offsetY = 0;
  
  // DOM 元素
  const scoreValue = document.getElementById('scoreValue');
  const movesValue = document.getElementById('movesValue');
  const comboValue = document.getElementById('comboValue');
  const gameMessage = document.getElementById('gameMessage');
  const restartBtn = document.getElementById('restartBtn');
  const hintBtn = document.getElementById('hintBtn');
  const gameOverModal = document.getElementById('gameOverModal');
  const finalScore = document.getElementById('finalScore');
  const playAgainBtn = document.getElementById('playAgainBtn');
  
  // 元素数据
  const elements = [
    { symbol: 'H', name: '氢', valence: 1, category: '非金属', color: '#3b82f6' },
    { symbol: 'C', name: '碳', valence: 4, category: '非金属', color: '#3b82f6' },
    { symbol: 'N', name: '氮', valence: -3, category: '非金属', color: '#3b82f6' },
    { symbol: 'O', name: '氧', valence: -2, category: '非金属', color: '#3b82f6' },
    { symbol: 'Na', name: '钠', valence: 1, category: '碱金属', color: '#ef4444' },
    { symbol: 'Mg', name: '镁', valence: 2, category: '碱土金属', color: '#f97316' },
    { symbol: 'Al', name: '铝', valence: 3, category: '贫金属', color: '#84cc16' },
    { symbol: 'Si', name: '硅', valence: 4, category: '类金属', color: '#10b981' },
    { symbol: 'P', name: '磷', valence: 5, category: '非金属', color: '#3b82f6' },
    { symbol: 'S', name: '硫', valence: -2, category: '非金属', color: '#3b82f6' },
    { symbol: 'Cl', name: '氯', valence: -1, category: '卤素', color: '#8b5cf6' },
    { symbol: 'K', name: '钾', valence: 1, category: '碱金属', color: '#ef4444' },
    { symbol: 'Ca', name: '钙', valence: 2, category: '碱土金属', color: '#f97316' },
    { symbol: 'Fe', name: '铁', valence: 2, category: '过渡金属', color: '#64748b' },
    { symbol: 'Cu', name: '铜', valence: 2, category: '过渡金属', color: '#64748b' },
    { symbol: 'Zn', name: '锌', valence: 2, category: '过渡金属', color: '#64748b' },
    { symbol: 'Ag', name: '银', valence: 1, category: '过渡金属', color: '#64748b' },
    { symbol: 'F', name: '氟', valence: -1, category: '卤素', color: '#8b5cf6' }
  ];
  
  // 初始化 Canvas 尺寸
  function resizeCanvas() {
    const wrapper = document.querySelector('.canvas-wrapper');
    const maxSize = Math.min(wrapper.clientWidth, wrapper.clientHeight) - 20;
    const totalWidth = GRID_SIZE * tileWidth + (GRID_SIZE - 1) * gap;
    const scale = Math.min(maxSize / totalWidth, 1);
    
    canvas.width = totalWidth * scale;
    canvas.height = totalWidth * scale;
    
    tileWidth = (canvas.width - (GRID_SIZE - 1) * gap) / GRID_SIZE;
    tileHeight = tileWidth;
    offsetX = gap / 2;
    offsetY = gap / 2;
    
    render();
  }
  
  // 初始化游戏
  function initGame() {
    tiles = [];
    selectedTile = null;
    score = 0;
    moves = 0;
    combo = 0;
    isProcessing = false;
    animations = [];
    particles = [];
    floatingTexts = [];
    
    updateUI();
    showMessage('🧪 选择两个能组成化合物的元素进行消除');
    
    generateTiles();
    resizeCanvas();
    render();
  }
  
  // 生成卡片 - 确保有可配对的化合物
  function generateTiles() {
    const tileList = [];
    
    // 生成 18 对可配对的元素（36 个格子）
    for (let i = 0; i < 18; i++) {
      // 随机选择一个化合物
      const compound = compounds[Math.floor(Math.random() * compounds.length)];
      if (compound.elements.length >= 2) {
        // 从化合物中选择两种元素
        const elem1 = compound.elements[0];
        const elem2 = compound.elements[1];
        
        const baseElem1 = elements.find(e => e.symbol === elem1.symbol);
        const baseElem2 = elements.find(e => e.symbol === elem2.symbol);
        
        if (baseElem1 && baseElem2) {
          tileList.push(createTileData(baseElem1));
          tileList.push(createTileData(baseElem2));
        }
      }
    }
    
    // 如果数量不够，用单质填充
    while (tileList.length < TILE_COUNT) {
      const randomElem = elements[Math.floor(Math.random() * elements.length)];
      tileList.push(createTileData(randomElem));
    }
    
    shuffleArray(tileList);
    
    tiles = [];
    for (let row = 0; row < GRID_SIZE; row++) {
      tiles[row] = [];
      for (let col = 0; col < GRID_SIZE; col++) {
        const index = row * GRID_SIZE + col;
        tiles[row][col] = {
          ...tileList[index],
          row,
          col,
          x: offsetX + col * (tileWidth + gap),
          y: offsetY + row * (tileHeight + gap),
          matched: false,
          scale: 1,
          alpha: 1
        };
      }
    }
  }
  
  function createTileData(element) {
    return {
      symbol: element.symbol,
      name: element.name,
      valence: element.valence,
      category: element.category,
      color: element.color,
      id: Math.random().toString(36).substr(2, 9)
    };
  }
  
  function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
  }
  
  // 渲染
  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawBackground();
    
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        const tile = tiles[row][col];
        if (!tile.matched) drawTile(tile);
      }
    }
    
    updateAndDrawAnimations();
    updateAndDrawParticles();
    updateAndDrawFloatingTexts();
    
    if (animations.length > 0 || particles.length > 0 || floatingTexts.length > 0) {
      requestAnimationFrame(render);
    }
  }
  
  function drawBackground() {
    const gradient = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
    gradient.addColorStop(0, '#1a1a2e');
    gradient.addColorStop(1, '#16213e');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
  }
  
  function drawTile(tile) {
    const x = tile.x, y = tile.y;
    const w = tileWidth * tile.scale, h = tileHeight * tile.scale;
    const offX = (tileWidth - w) / 2, offY = (tileHeight - h) / 2;
    
    ctx.save();
    ctx.globalAlpha = tile.alpha;
    
    const gradient = ctx.createLinearGradient(x, y, x + w, y + h);
    gradient.addColorStop(0, lightenColor(tile.color, 20));
    gradient.addColorStop(1, tile.color);
    
    ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
    ctx.shadowBlur = 10;
    ctx.shadowOffsetY = 4;
    
    roundRect(ctx, x + offX, y + offY, w, h, 8);
    ctx.fillStyle = gradient;
    ctx.fill();
    
    if (selectedTile && selectedTile.row === tile.row && selectedTile.col === tile.col) {
      ctx.shadowColor = '#fbbf24';
      ctx.shadowBlur = 20;
      ctx.strokeStyle = '#fbbf24';
      ctx.lineWidth = 3;
      ctx.stroke();
    }
    
    ctx.shadowColor = 'transparent';
    ctx.shadowBlur = 0;
    ctx.shadowOffsetY = 0;
    
    // 元素符号（中间偏左）
    ctx.fillStyle = '#ffffff';
    ctx.font = `bold ${tileWidth * 0.45}px Arial`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    const symbolX = x + offX + w / 2 - tileWidth * 0.1;
    const symbolY = y + offY + h / 2;
    ctx.fillText(tile.symbol, symbolX, symbolY);
    
    // 化合价（右上角）
    if (tile.valence !== 0) {
      const sign = tile.valence > 0 ? '+' : '-';
      const absVal = Math.abs(tile.valence);
      const valenceText = absVal > 1 ? absVal + sign : sign;
      
      ctx.font = `bold ${tileWidth * 0.22}px Arial`;
      ctx.fillStyle = '#fbbf24';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'top';
      ctx.fillText(valenceText, symbolX + tileWidth * 0.3, symbolY - tileHeight * 0.35);
    }
    
    // 个数（右下角）
    ctx.font = `bold ${tileWidth * 0.22}px Arial`;
    ctx.fillStyle = '#34d399';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'bottom';
    ctx.fillText('×1', symbolX + tileWidth * 0.3, symbolY + tileHeight * 0.35);
    
    ctx.restore();
  }
  
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
  
  function lightenColor(color, percent) {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = Math.min(255, (num >> 16) + amt);
    const G = Math.min(255, ((num >> 8) & 0x00FF) + amt);
    const B = Math.min(255, (num & 0x0000FF) + amt);
    return `#${(1 << 24 | R << 16 | G << 8 | B).toString(16).slice(1)}`;
  }
  
  function updateAndDrawAnimations() {
    for (let i = animations.length - 1; i >= 0; i--) {
      const anim = animations[i];
      anim.progress += anim.speed;
      if (anim.progress >= 1) { animations.splice(i, 1); continue; }
      const tile = anim.tile;
      if (anim.type === 'match') {
        tile.scale = 1 - anim.progress * 0.5;
        tile.alpha = 1 - anim.progress;
      }
    }
  }
  
  function updateAndDrawParticles() {
    for (let i = particles.length - 1; i >= 0; i--) {
      const p = particles[i];
      p.x += p.vx; p.y += p.vy; p.vy += 0.2; p.life -= 0.02;
      if (p.life <= 0) { particles.splice(i, 1); continue; }
      ctx.globalAlpha = p.life;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }
  
  function updateAndDrawFloatingTexts() {
    for (let i = floatingTexts.length - 1; i >= 0; i--) {
      const ft = floatingTexts[i];
      ft.y -= 2; ft.life -= 0.02;
      if (ft.life <= 0) { floatingTexts.splice(i, 1); continue; }
      ctx.globalAlpha = ft.life;
      ctx.fillStyle = ft.color;
      ctx.font = `bold ${ft.size}px Arial`;
      ctx.textAlign = 'center';
      ctx.fillText(ft.text, ft.x, ft.y);
    }
    ctx.globalAlpha = 1;
  }
  
  function createParticles(x, y, color) {
    for (let i = 0; i < 12; i++) {
      const angle = (Math.PI * 2 * i) / 12;
      const speed = 2 + Math.random() * 3;
      particles.push({ x, y, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed, size: 3 + Math.random() * 4, color, life: 1 });
    }
  }
  
  function showFloatingText(text, x, y, color = '#fbbf24', size = 24) {
    floatingTexts.push({ text, x, y, color, size, life: 1 });
  }
  
  // 处理点击
  canvas.addEventListener('click', (e) => {
    if (isProcessing) return;
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const clickX = (e.clientX - rect.left) * scaleX;
    const clickY = (e.clientY - rect.top) * scaleY;
    
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        const tile = tiles[row][col];
        if (tile.matched) continue;
        if (clickX >= tile.x && clickX <= tile.x + tileWidth &&
            clickY >= tile.y && clickY <= tile.y + tileHeight) {
          handleTileClick(row, col);
          return;
        }
      }
    }
  });
  
  function handleTileClick(row, col) {
    const tile = tiles[row][col];
    
    if (selectedTile) {
      if (selectedTile.row === row && selectedTile.col === col) {
        selectedTile = null;
        render();
        return;
      }
      
      const selectedGridTile = tiles[selectedTile.row][selectedTile.col];
      
      // 检查是否能组成化合物
      const result = canFormCompound(selectedGridTile, tile);
      
      if (result.valid) {
        handleMatch(selectedTile.row, selectedTile.col, row, col, result.compound);
      } else {
        selectedTile = { row, col };
        render();
      }
    } else {
      selectedTile = { row, col };
      render();
    }
  }
  
  async function handleMatch(row1, col1, row2, col2, compound) {
    isProcessing = true;
    moves++;
    combo++;
    
    const tile1 = tiles[row1][col1];
    const tile2 = tiles[row2][col2];
    
    // 计算得分
    const baseScore = 10 + compound.elements.length * 5;
    const comboBonus = Math.min(combo - 1, 5) * 5;
    const points = baseScore + comboBonus;
    score += points;
    
    updateUI();
    
    // 显示化合物信息
    showFloatingText(`${compound.formula} ${compound.name}`, canvas.width / 2, canvas.height / 2, '#34d399', 28);
    if (combo > 1) {
      showFloatingText(`🔥 连击 x${combo}!`, canvas.width / 2, canvas.height / 2 + 40, '#fbbf24', 24);
    }
    
    // 粒子效果
    createParticles(tile1.x + tileWidth / 2, tile1.y + tileHeight / 2, tile1.color);
    createParticles(tile2.x + tileWidth / 2, tile2.y + tileHeight / 2, tile2.color);
    
    // 消除动画
    animations.push({ type: 'match', tile: tile1, progress: 0, speed: 0.05 });
    animations.push({ type: 'match', tile: tile2, progress: 0, speed: 0.05 });
    
    tile1.matched = true;
    tile2.matched = true;
    selectedTile = null;
    
    const animate = () => {
      render();
      if (animations.length > 0) requestAnimationFrame(animate);
      else checkGameProgress();
    };
    animate();
  }
  
  function checkGameProgress() {
    const remaining = getRemainingTiles();
    
    if (remaining.length === 0) {
      showGameOver();
      return;
    }
    
    const remainingTiles = remaining.map(({ row, col }) => tiles[row][col]);
    const matches = getPossibleMatches(remainingTiles);
    
    if (matches.length === 0) {
      showMessage('没有可配对的元素，重新生成...');
      setTimeout(() => { regenerateRemaining(); isProcessing = false; }, 1000);
    } else {
      isProcessing = false;
      if (combo > 1) showMessage(`🔥 连击 x${combo}！继续加油！`);
      else showMessage('🧪 配对成功！继续消除~');
    }
  }
  
  function getRemainingTiles() {
    const remaining = [];
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        if (!tiles[row][col].matched) remaining.push({ row, col });
      }
    }
    return remaining;
  }
  
  function regenerateRemaining() {
    const remaining = getRemainingTiles();
    const pairsNeeded = Math.floor(remaining.length / 2);
    const newTiles = [];
    
    for (let i = 0; i < pairsNeeded; i++) {
      const compound = compounds[Math.floor(Math.random() * compounds.length)];
      if (compound.elements.length >= 2) {
        const elem1 = compound.elements[0];
        const elem2 = compound.elements[1];
        const baseElem1 = elements.find(e => e.symbol === elem1.symbol);
        const baseElem2 = elements.find(e => e.symbol === elem2.symbol);
        if (baseElem1 && baseElem2) {
          newTiles.push(createTileData(baseElem1));
          newTiles.push(createTileData(baseElem2));
        }
      }
    }
    
    shuffleArray(newTiles);
    
    let tileIndex = 0;
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        if (!tiles[row][col].matched && tileIndex < newTiles.length) {
          tiles[row][col] = {
            ...newTiles[tileIndex],
            row, col,
            x: offsetX + col * (tileWidth + gap),
            y: offsetY + row * (tileHeight + gap),
            matched: false, scale: 1, alpha: 1
          };
          tileIndex++;
        }
      }
    }
    
    combo = 0;
    updateUI();
    render();
    showMessage('🧪 新元素已生成，继续消除！');
  }
  
  function updateUI() {
    scoreValue.textContent = score;
    movesValue.textContent = moves;
    comboValue.textContent = `x${combo}`;
  }
  
  function showMessage(msg) {
    gameMessage.innerHTML = `<p>${msg}</p>`;
  }
  
  function showGameOver() {
    const isNewHighScore = score > highScore;
    if (isNewHighScore) {
      highScore = score;
      storage.save('matchHighScore', highScore);
    }
    
    finalScore.innerHTML = `
      <span class="score-number">${score}分</span>
      <span class="score-detail">用了 ${moves} 步</span>
      ${isNewHighScore ? '<span class="high-score-badge">🏆 新纪录！</span>' : ''}
    `;
    
    setTimeout(() => { gameOverModal.classList.remove('hidden'); }, 500);
  }
  
  // 提示功能
  function showHint() {
    if (isProcessing) return;
    
    const remaining = getRemainingTiles().map(({ row, col }) => tiles[row][col]);
    const matches = getPossibleMatches(remaining);
    
    if (matches.length > 0) {
      const match = matches[0];
      showFloatingText(`💡 ${match.compound.formula}`, match.tile1.x + tileWidth/2, match.tile1.y, '#34d399', 20);
      showFloatingText(`💡 ${match.compound.formula}`, match.tile2.x + tileWidth/2, match.tile2.y + tileHeight, '#34d399', 20);
      showMessage(`💡 提示：${match.compound.name} (${match.compound.formula})`);
      render();
    } else {
      showMessage('没有找到可配对的元素');
    }
  }
  
  // 事件监听
  restartBtn.addEventListener('click', () => { gameOverModal.classList.add('hidden'); initGame(); });
  hintBtn.addEventListener('click', showHint);
  playAgainBtn.addEventListener('click', () => { gameOverModal.classList.add('hidden'); initGame(); });
  window.addEventListener('resize', resizeCanvas);
  
  initGame();
});
