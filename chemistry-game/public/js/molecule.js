// 分子消消乐游戏
import { storage } from './utils.js';

document.addEventListener('DOMContentLoaded', () => {
  let molecules = [];
  let currentLevel = 0;
  let score = 0;
  let selectedElements = [];

  // DOM 元素
  const targetMoleculeEl = document.getElementById('targetMolecule');
  const moleculeDescEl = document.getElementById('moleculeDescription');
  const elementCardsEl = document.getElementById('elementCards');
  const selectedElementsEl = document.getElementById('selectedElements');
  const scoreValue = document.getElementById('scoreValue');
  const levelValue = document.getElementById('levelValue');
  const clearBtn = document.getElementById('clearBtn');
  const submitBtn = document.getElementById('submitBtn');
  const successModal = document.getElementById('successModal');
  const failModal = document.getElementById('failModal');
  const successMessage = document.getElementById('successMessage');
  const successMolecule = document.getElementById('successMolecule');
  const failMessage = document.getElementById('failMessage');
  const nextLevelBtn = document.getElementById('nextLevelBtn');
  const tryAgainBtn = document.getElementById('tryAgainBtn');

  // 加载分子数据
  fetch('/api/molecules')
    .then(res => res.json())
    .then(data => {
      molecules = data.molecules;
      console.log(`加载了 ${molecules.length} 个分子`);
      startLevel(0);
    })
    .catch(err => console.error('加载分子数据失败:', err));

  // 开始关卡
  function startLevel(levelIndex) {
    currentLevel = levelIndex;
    const molecule = molecules[currentLevel];
    
    if (!molecule) {
      // 所有关卡完成
      showVictory();
      return;
    }
    
    // 更新显示
    targetMoleculeEl.textContent = molecule.formula;
    moleculeDescEl.textContent = molecule.description;
    levelValue.textContent = currentLevel + 1;
    
    // 清空选择
    selectedElements = [];
    renderSelectedElements();
    
    // 生成元素卡片
    generateElementCards(molecule);
  }

  // 生成元素卡片
  function generateElementCards(molecule) {
    elementCardsEl.innerHTML = '';
    
    // 为每个元素生成多个卡片（增加难度）
    const cards = [];
    molecule.elements.forEach(elem => {
      // 生成 2-3 张相同的卡片
      const cardCount = 2 + Math.floor(Math.random() * 2);
      for (let i = 0; i < cardCount; i++) {
        cards.push({
          symbol: elem.symbol,
          count: elem.count,
          valence: elem.valence
        });
      }
    });
    
    // 打乱顺序
    cards.sort(() => Math.random() - 0.5);
    
    // 渲染卡片
    cards.forEach((card, index) => {
      const cardEl = document.createElement('div');
      cardEl.className = 'element-card';
      cardEl.dataset.index = index;
      cardEl.innerHTML = `
        <span class="element-symbol">${card.symbol}</span>
        <span class="element-count">×${card.count}</span>
        <span class="element-valence">${card.valence}</span>
      `;
      
      cardEl.addEventListener('click', () => selectElement(card, cardEl));
      elementCardsEl.appendChild(cardEl);
    });
  }

  // 选择元素
  function selectElement(card, cardEl) {
    // 检查是否已选
    if (cardEl.classList.contains('selected')) return;
    
    // 添加到已选列表
    selectedElements.push({
      symbol: card.symbol,
      count: card.count,
      valence: card.valence,
      cardEl: cardEl
    });
    
    // 标记卡片
    cardEl.classList.add('selected');
    
    // 更新显示
    renderSelectedElements();
  }

  // 渲染已选元素
  function renderSelectedElements() {
    if (selectedElements.length === 0) {
      selectedElementsEl.innerHTML = '<p class="empty-hint">点击元素卡片添加到此处</p>';
      return;
    }
    
    selectedElementsEl.innerHTML = '';
    selectedElements.forEach((elem, index) => {
      const elemEl = document.createElement('div');
      elemEl.className = 'selected-element';
      elemEl.innerHTML = `
        <span class="symbol">${elem.symbol}</span>
        <span class="count">×${elem.count}</span>
        <span class="valence">${elem.valence}</span>
        <button class="remove" data-index="${index}">×</button>
      `;
      
      // 移除按钮事件
      elemEl.querySelector('.remove').addEventListener('click', (e) => {
        e.stopPropagation();
        removeElement(index);
      });
      
      selectedElementsEl.appendChild(elemEl);
    });
  }

  // 移除元素
  function removeElement(index) {
    const elem = selectedElements[index];
    if (elem && elem.cardEl) {
      elem.cardEl.classList.remove('selected');
    }
    selectedElements.splice(index, 1);
    renderSelectedElements();
  }

  // 清空选择
  clearBtn.addEventListener('click', () => {
    selectedElements.forEach(elem => {
      if (elem.cardEl) {
        elem.cardEl.classList.remove('selected');
      }
    });
    selectedElements = [];
    renderSelectedElements();
  });

  // 提交检查
  submitBtn.addEventListener('click', checkSolution);

  // 检查答案
  function checkSolution() {
    const molecule = molecules[currentLevel];
    
    // 检查元素数量是否匹配
    if (selectedElements.length !== molecule.elements.length) {
      showFail('元素数量不正确');
      return;
    }
    
    // 检查每个元素是否正确
    const selectedMap = {};
    selectedElements.forEach(elem => {
      if (!selectedMap[elem.symbol]) {
        selectedMap[elem.symbol] = elem;
      }
    });
    
    let allCorrect = true;
    molecule.elements.forEach(elem => {
      const selected = selectedMap[elem.symbol];
      if (!selected || selected.count !== elem.count || selected.valence !== elem.valence) {
        allCorrect = false;
      }
    });
    
    if (allCorrect) {
      showSuccess(molecule);
    } else {
      showFail('元素组合不正确');
    }
  }

  // 显示成功
  function showSuccess(molecule) {
    score += 10;
    scoreValue.textContent = score;
    storage.save('moleculeScore', score);
    
    successMessage.textContent = `你成功合成了${molecule.name}！`;
    successMolecule.textContent = molecule.formula;
    successModal.classList.remove('hidden');
  }

  // 显示失败
  function showFail(message) {
    failMessage.textContent = message;
    failModal.classList.remove('hidden');
  }

  // 下一关
  nextLevelBtn.addEventListener('click', () => {
    successModal.classList.add('hidden');
    startLevel(currentLevel + 1);
  });

  // 重试
  tryAgainBtn.addEventListener('click', () => {
    failModal.classList.add('hidden');
    clearBtn.click();
  });

  // 显示胜利
  function showVictory() {
    successMessage.textContent = '🎉 恭喜你完成所有关卡！';
    successMolecule.textContent = `🏆 最终得分：${score}`;
    nextLevelBtn.textContent = '返回首页';
    nextLevelBtn.onclick = () => {
      window.location.href = '/';
    };
    successModal.classList.remove('hidden');
  }

  // 加载保存的分数
  const savedScore = storage.get('moleculeScore');
  if (savedScore) {
    score = savedScore;
    scoreValue.textContent = score;
  }
});
