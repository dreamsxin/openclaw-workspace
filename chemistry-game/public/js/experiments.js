// 化学实验页面逻辑
document.addEventListener('DOMContentLoaded', () => {
  let experiments = [];
  let safetyRules = [];

  const experimentList = document.getElementById('experimentList');
  const experimentModal = document.getElementById('experimentModal');
  const modalBody = document.getElementById('modalBody');
  const closeModal = document.getElementById('closeModal');
  const safetyRulesContainer = document.getElementById('safetyRules');

  // 加载实验数据
  fetch('/api/experiments')
    .then(res => res.json())
    .then(data => {
      experiments = data.experiments;
      safetyRules = data.generalSafety;
      renderExperimentList();
      renderSafetyRules();
    })
    .catch(err => console.error('加载实验数据失败:', err));

  // 渲染实验列表
  function renderExperimentList() {
    experimentList.innerHTML = experiments.map(exp => `
      <div class="experiment-card" data-id="${exp.id}">
        <h3>${exp.name}</h3>
        <div class="experiment-meta">
          <span class="category">${exp.category}</span>
          <span class="difficulty">${exp.difficulty}</span>
          <span>⏱️ ${exp.time}</span>
        </div>
        <p class="experiment-objective">${exp.objective}</p>
        <div class="experiment-equation">${exp.equation}</div>
        <button class="view-detail-btn">查看详情</button>
      </div>
    `).join('');

    // 添加点击事件
    document.querySelectorAll('.experiment-card').forEach(card => {
      card.addEventListener('click', (e) => {
        if (!e.target.classList.contains('view-detail-btn')) {
          const id = parseInt(card.dataset.id);
          showExperimentDetail(id);
        }
      });
    });

    document.querySelectorAll('.view-detail-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const card = btn.closest('.experiment-card');
        const id = parseInt(card.dataset.id);
        showExperimentDetail(id);
      });
    });
  }

  // 显示实验详情
  function showExperimentDetail(id) {
    const exp = experiments.find(e => e.id === id);
    if (!exp) return;

    modalBody.innerHTML = `
      <div class="modal-header">
        <h2>${exp.name}</h2>
        <div class="experiment-meta">
          <span class="category">${exp.category}</span>
          <span class="difficulty">${exp.difficulty}</span>
          <span>⏱️ ${exp.time}</span>
        </div>
      </div>

      <div class="modal-section">
        <h3>🎯 实验目的</h3>
        <p>${exp.objective}</p>
      </div>

      <div class="modal-section">
        <h3>🧪 实验用品</h3>
        <ul class="materials-list">
          ${exp.materials.map(m => `<li>${m}</li>`).join('')}
        </ul>
      </div>

      <div class="modal-section">
        <h3>📋 实验步骤</h3>
        <ol class="steps-list">
          ${exp.steps.map((s, i) => `<li data-step="${i+1}">${s}</li>`).join('')}
        </ol>
      </div>

      <div class="modal-section">
        <h3>⚗️ 化学方程式</h3>
        <div class="experiment-equation">${exp.equation}</div>
      </div>

      <div class="modal-section">
        <h3>👀 实验现象</h3>
        <div class="phenomenon-box">
          <p>${exp.phenomenon}</p>
        </div>
      </div>

      <div class="modal-section">
        <h3>⚠️ 注意事项</h3>
        <ul class="warnings-list">
          ${exp.warnings.map(w => `<li>${w}</li>`).join('')}
        </ul>
      </div>
    `;

    experimentModal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

  // 关闭弹窗
  closeModal.addEventListener('click', () => {
    experimentModal.classList.add('hidden');
    document.body.style.overflow = '';
  });

  experimentModal.addEventListener('click', (e) => {
    if (e.target === experimentModal) {
      experimentModal.classList.add('hidden');
      document.body.style.overflow = '';
    }
  });

  // 渲染安全规范
  function renderSafetyRules() {
    safetyRulesContainer.innerHTML = safetyRules.map(rule => `
      <div class="safety-card">
        <h3>${rule.title}</h3>
        <ul>
          ${rule.rules.map(r => `<li>${r}</li>`).join('')}
        </ul>
      </div>
    `).join('');
  }

  // ESC 键关闭弹窗
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !experimentModal.classList.contains('hidden')) {
      experimentModal.classList.add('hidden');
      document.body.style.overflow = '';
    }
  });
});
