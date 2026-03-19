/**
 * 元素周期表探索 - 主应用逻辑
 * @module app
 */

import { 
  storage, 
  elementUtils, 
  experimentUtils,
  debounce,
  keyboardUtils 
} from './utils.js';

/**
 * 应用状态管理
 */
const AppState = {
  elements: [],
  experiments: [],
  score: 0,
  currentAnswer: '',
  selectedElement: null
};

/**
 * DOM 元素引用
 */
const DOM = {
  elementCells: null,
  elementDetailPanel: null,
  defaultInfoPanel: null,
  detailContent: null,
  quizBtn: null,
  quizModal: null,
  closeQuiz: null,
  submitAnswer: null,
  quizAnswer: null,
  quizQuestion: null,
  quizResult: null,
  scoreEl: null,
  resetBtn: null,
  periodicTable: null
};

/**
 * 初始化应用
 */
function init() {
  cacheDOM();
  loadData();
  bindEvents();
  setupKeyboardShortcuts();
  restoreState();
}

/**
 * 缓存 DOM 引用
 */
function cacheDOM() {
  DOM.elementCells = document.querySelectorAll('.element-cell');
  DOM.elementDetailPanel = document.getElementById('elementDetailPanel');
  DOM.defaultInfoPanel = document.getElementById('defaultInfoPanel');
  DOM.detailContent = document.getElementById('detailContent');
  DOM.quizBtn = document.getElementById('quizBtn');
  DOM.quizModal = document.getElementById('quizModal');
  DOM.closeQuiz = document.getElementById('closeQuiz');
  DOM.submitAnswer = document.getElementById('submitAnswer');
  DOM.quizAnswer = document.getElementById('quizAnswer');
  DOM.quizQuestion = document.getElementById('quizQuestion');
  DOM.quizResult = document.getElementById('quizResult');
  DOM.scoreEl = document.getElementById('score');
  DOM.resetBtn = document.getElementById('resetBtn');
  DOM.periodicTable = document.querySelector('.periodic-table');
}

/**
 * 加载数据
 */
async function loadData() {
  try {
    const [elementsRes, experimentsRes] = await Promise.all([
      fetch('/api/elements'),
      fetch('/api/experiments')
    ]);
    
    const elementsData = await elementsRes.json();
    AppState.elements = elementsData.elements;  // 提取 elements 数组
    AppState.experiments = (await experimentsRes.json()).experiments;
    
    console.log(`✅ 加载了 ${AppState.elements.length} 个元素`);
    console.log(`✅ 加载了 ${AppState.experiments.length} 个实验`);
  } catch (error) {
    console.error('❌ 加载数据失败:', error);
  }
}

/**
 * 绑定事件
 */
function bindEvents() {
  // 元素点击事件 - 直接绑定到每个元素
  DOM.elementCells.forEach(cell => {
    cell.addEventListener('click', handleElementClickDirect);
  });
  
  // 测验相关事件
  DOM.quizBtn.addEventListener('click', startQuiz);
  DOM.closeQuiz.addEventListener('click', () => DOM.quizModal.classList.add('hidden'));
  DOM.submitAnswer.addEventListener('click', submitQuizAnswer);
  DOM.quizAnswer.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') submitQuizAnswer();
  });
  
  // 重置按钮
  DOM.resetBtn.addEventListener('click', handleReset);
  
  // 点击背景关闭弹窗
  DOM.quizModal.addEventListener('click', (e) => {
    if (e.target === DOM.quizModal) {
      DOM.quizModal.classList.add('hidden');
    }
  });
  
  // 关联实验点击（事件委托）
  DOM.detailContent.addEventListener('click', (e) => {
    const expLink = e.target.closest('.experiment-link');
    if (expLink) {
      e.preventDefault();
      const expId = parseInt(expLink.dataset.id);
      const experiment = AppState.experiments.find(exp => exp.id === expId);
      if (experiment) {
        showExperimentDetail(experiment);
      }
    }
  });
}

/**
 * 处理元素点击（直接绑定）
 * @param {Event} e - 点击事件
 */
function handleElementClickDirect(e) {
  const cell = e.currentTarget;
  const symbol = cell.dataset.symbol;
  const element = AppState.elements.find(el => el.symbol === symbol);
  
  if (element) {
    AppState.selectedElement = element;
    showElementDetail(element);
  }
}

/**
 * 设置键盘快捷键
 */
function setupKeyboardShortcuts() {
  keyboardUtils.register({
    ' ': (e) => {
      e.preventDefault();
      startQuiz();
    },
    'escape': () => {
      DOM.quizModal.classList.add('hidden');
      showDefaultPanel();
    }
  });
}

/**
 * 恢复保存的状态
 */
function restoreState() {
  const savedScore = storage.get('quizScore');
  if (savedScore !== null) {
    AppState.score = savedScore;
    DOM.scoreEl.textContent = `得分：${AppState.score}`;
  }
}

/**
 * 处理元素点击
 * @param {Event} e - 点击事件
 */
function handleElementClick(e) {
  const cell = e.target.closest('.element-cell');
  if (!cell) return;
  
  const symbol = cell.dataset.symbol;
  const element = AppState.elements.find(el => el.symbol === symbol);
  
  if (element) {
    AppState.selectedElement = element;
    showElementDetail(element);
  }
}

/**
 * 显示元素详情
 * @param {Object} element - 元素对象
 */
function showElementDetail(element) {
  const categoryColor = getCategoryColor(element.category);
  const relatedExperiments = findRelatedExperiments(element);
  
  DOM.detailContent.innerHTML = buildElementDetailHTML(element, categoryColor, relatedExperiments);
  
  // 切换面板显示
  DOM.defaultInfoPanel.classList.add('hidden');
  DOM.elementDetailPanel.classList.remove('hidden');
}

/**
 * 构建元素详情 HTML
 * @param {Object} element - 元素对象
 * @param {string} categoryColor - 类别颜色
 * @param {Array} relatedExperiments - 关联实验
 * @returns {string} HTML 字符串
 */
function buildElementDetailHTML(element, categoryColor, relatedExperiments) {
  return `
    <div class="element-card" style="max-width: 100%; margin: 0; box-shadow: none;">
      <div class="card-header" style="background: ${categoryColor}">
        <h2 style="color: white; text-align: center; margin-bottom: 15px;">${element.symbol}</h2>
        <h3 style="color: white; text-align: center; margin-bottom: 5px;">${element.name}</h3>
        <p style="color: white; text-align: center; opacity: 0.9;">${element.nameEn} · 原子序数 ${element.atomicNumber}</p>
      </div>
      <div class="card-body">
        ${buildElectronSection(element)}
        ${buildValenceSection(element)}
        ${buildCompoundsSection(element)}
        ${buildBasicInfoSection(element)}
        ${buildEquationsSection(element)}
        ${buildRelatedExperimentsSection(relatedExperiments)}
      </div>
    </div>
  `;
}

/**
 * 构建电子结构部分
 */
function buildElectronSection(element) {
  return `
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
  `;
}

/**
 * 构建化合价部分
 */
function buildValenceSection(element) {
  return `
    <div class="card-section">
      <h4>💫 化合价</h4>
      <div class="valence-list">
        ${element.valence.map(v => `
          <div class="valence-item">${v > 0 ? '+' : ''}${v}</div>
        `).join('')}
      </div>
    </div>
  `;
}

/**
 * 构建化合物部分
 */
function buildCompoundsSection(element) {
  return `
    <div class="card-section">
      <h4>🧪 常见化合物</h4>
      <div class="compounds-list">
        ${element.compounds.map(c => {
          const valenceTags = Object.entries(c.elementValence)
            .map(([sym, val]) => {
              const valStr = val > 0 ? `+${val}` : val.toString();
              return `<span class="valence-tag"><span class="element-symbol">${sym}</span>${valStr}</span>`;
            }).join('');
          
          return `
            <div class="compound-item">
              <div class="compound-header">
                <span class="compound-formula">${c.formula}</span>
                <span class="compound-name">${c.name}</span>
              </div>
              <div class="element-valence-tags">${valenceTags}</div>
            </div>
          `;
        }).join('')}
      </div>
    </div>
  `;
}

/**
 * 构建基本信息部分
 */
function buildBasicInfoSection(element) {
  return `
    <div class="card-section">
      <h4>📊 基本信息</h4>
      <p><strong>原子量：</strong>${element.atomicMass}</p>
      <p><strong>类别：</strong>${element.category}</p>
      <p><strong>周期：</strong>第${element.period}周期</p>
      <p><strong>族：</strong>第${element.group}族</p>
    </div>
  `;
}

/**
 * 构建化学方程式部分
 */
function buildEquationsSection(element) {
  if (!element.equations || element.equations.length === 0) return '';
  
  return `
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
  `;
}

/**
 * 构建关联实验部分
 */
function buildRelatedExperimentsSection(relatedExperiments) {
  if (!relatedExperiments || relatedExperiments.length === 0) return '';
  
  return `
    <div class="related-experiments">
      <h3>🧪 关联实验 (${relatedExperiments.length})</h3>
      ${relatedExperiments.map(exp => `
        <div class="experiment-link" data-id="${exp.id}">
          <h4>${exp.name}</h4>
          <div class="exp-meta">
            <span>${exp.category}</span>
            <span>${exp.difficulty}</span>
            <span>⏱️ ${exp.time}</span>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

/**
 * 显示默认面板（口诀）
 */
function showDefaultPanel() {
  DOM.elementDetailPanel.classList.add('hidden');
  DOM.defaultInfoPanel.classList.remove('hidden');
  AppState.selectedElement = null;
}

/**
 * 查找关联实验
 */
function findRelatedExperiments(element) {
  return experimentUtils.findByElement(AppState.experiments, element)
    .slice(0, 8);
}

/**
 * 获取类别颜色
 */
function getCategoryColor(category) {
  const colors = {
    '碱金属': '#ff6b6b',
    '碱土金属': '#ffd93d',
    '过渡金属': '#6bcb77',
    '贫金属': '#4d96ff',
    '类金属': '#9b59b6',
    '非金属': '#95a5a6',
    '卤素': '#e67e22',
    '稀有气体': '#00d2d3',
    '镧系': '#ff9ff3',
    '锕系': '#feca57'
  };
  return colors[category] || '#667eea';
}

/**
 * 渲染电子壳层可视化
 */
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

/**
 * 开始测验
 */
function startQuiz() {
  if (AppState.elements.length === 0) return;
  
  const randomElement = AppState.elements[Math.floor(Math.random() * AppState.elements.length)];
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
  
  AppState.currentAnswer = answer;
  DOM.quizQuestion.textContent = question;
  DOM.quizAnswer.value = '';
  DOM.quizResult.textContent = '';
  DOM.quizModal.classList.remove('hidden');
  DOM.quizAnswer.focus();
}

/**
 * 提交测验答案
 */
async function submitQuizAnswer() {
  const answer = DOM.quizAnswer.value.trim();
  if (!answer) {
    DOM.quizResult.textContent = '⚠️ 请输入答案';
    return;
  }

  try {
    const res = await fetch('/api/quiz/submit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        answer, 
        expected: AppState.currentAnswer 
      })
    });
    
    const data = await res.json();
    DOM.quizResult.textContent = data.message;
    
    if (data.correct) {
      AppState.score += 10;
      DOM.scoreEl.textContent = `得分：${AppState.score}`;
      storage.save('quizScore', AppState.score);
    }
    
    setTimeout(() => {
      DOM.quizModal.classList.add('hidden');
    }, 1500);
  } catch (error) {
    console.error('提交失败:', error);
    DOM.quizResult.textContent = '❌ 提交失败，请重试';
  }
}

/**
 * 处理重置
 */
function handleReset() {
  AppState.score = 0;
  DOM.scoreEl.textContent = '得分：0';
  storage.save('quizScore', 0);
  showDefaultPanel();
  DOM.quizModal.classList.add('hidden');
}

/**
 * 解析实验用品，分离名称和化学式
 * @param {string} material - 实验用品字符串
 * @returns {Object} 包含 name 和 formula 的对象
 */
function parseMaterial(material) {
  const match = material.match(/^(.+?)\(([^)]+)\)$/);
  if (match) {
    return {
      name: match[1].trim(),
      formula: match[2].trim(),
      hasFormula: true
    };
  }
  return {
    name: material,
    formula: '',
    hasFormula: false
  };
}

/**
 * 显示实验详情弹窗
 * @param {Object} experiment - 实验对象
 */
function showExperimentDetail(experiment) {
  const modal = document.createElement('div');
  modal.id = 'experimentDetailModal';
  modal.className = 'modal';
  modal.innerHTML = `
    <div class="modal-content experiment-modal-content">
      <button class="close-btn" id="closeExperimentModal">&times;</button>
      <div class="modal-header">
        <h2>${experiment.name}</h2>
        <div class="experiment-meta">
          <span class="category">${experiment.category}</span>
          <span class="difficulty">${experiment.difficulty}</span>
          <span>⏱️ ${experiment.time}</span>
        </div>
      </div>

      <div class="modal-section">
        <h3>🎯 实验目的</h3>
        <p>${experiment.objective}</p>
      </div>

      <div class="modal-section">
        <h3>🧪 实验用品</h3>
        <ul class="materials-list">
          ${experiment.materials.map(m => {
            const parsed = parseMaterial(m);
            if (parsed.hasFormula) {
              return `<li>
                <span class="material-name">${parsed.name}</span>
                <span class="material-formula">${parsed.formula}</span>
              </li>`;
            } else {
              return `<li>${parsed.name}</li>`;
            }
          }).join('')}
        </ul>
      </div>

      <div class="modal-section">
        <h3>📋 实验步骤</h3>
        <ol class="steps-list">
          ${experiment.steps.map((s, i) => `<li data-step="${i+1}">${s}</li>`).join('')}
        </ol>
      </div>

      <div class="modal-section">
        <h3>⚗️ 化学方程式</h3>
        <div class="experiment-equation">${experiment.equation}</div>
      </div>

      <div class="modal-section">
        <h3>👀 实验现象</h3>
        <div class="phenomenon-box">
          <p>${experiment.phenomenon}</p>
        </div>
      </div>

      <div class="modal-section">
        <h3>⚠️ 注意事项</h3>
        <ul class="warnings-list">
          ${experiment.warnings.map(w => `<li>${w}</li>`).join('')}
        </ul>
      </div>
    </div>
  `;

  document.body.appendChild(modal);

  // 关闭按钮事件
  const closeBtn = document.getElementById('closeExperimentModal');
  if (closeBtn) {
    closeBtn.addEventListener('click', () => modal.remove());
  }

  // 点击背景关闭
  modal.addEventListener('click', (e) => {
    if (e.target === modal) {
      modal.remove();
    }
  });

  // ESC 键关闭
  const escHandler = (e) => {
    if (e.key === 'Escape') {
      modal.remove();
      document.removeEventListener('keydown', escHandler);
    }
  };
  document.addEventListener('keydown', escHandler);
}

// 启动应用
document.addEventListener('DOMContentLoaded', init);

// 导出供其他模块使用
export { AppState, DOM, init };
