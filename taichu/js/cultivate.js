/**
 * 《太初演义》角色养成系统
 * 包含：升级、突破、技能升级、洗练
 */

// ============================================================
// 养成页面入口
// ============================================================
function renderCultivatePage() {
  const page = document.getElementById('page-cultivate');
  if (!page) return;

  const save = SaveSystem.get();
  const inventory = save.inventory;

  // 渲染英雄列表
  const listEl = document.getElementById('cultivate-hero-list');
  if (!listEl) return;

  listEl.innerHTML = inventory.map(item => {
    const hero = HERO_INDEX[item.heroId];
    if (!hero) return '';
    const training = SaveSystem.getHeroTraining(item.heroId);
    const elColor  = ELEMENT_COLORS[hero.element] || '#888';
    const rarInfo  = RARITY[hero.rarity?.toUpperCase()] || {};
    const maxLv    = TRAINING_CONFIG.maxLevelByStars[training.starLevel] || 20;

    return `
      <div class="cultivate-hero-card" onclick="openCultivateDetail('${hero.id}')">
        <div style="font-size:44px;line-height:1">${hero.portrait}</div>
        <div style="font-size:12px;color:${rarInfo.color};margin:4px 0 2px">${rarInfo.name}品</div>
        <div style="font-size:14px;color:#ddd;font-weight:700">${hero.name}</div>
        <div style="font-size:11px;color:${elColor}">${ELEMENT_ICONS[hero.element]} ${ELEMENT_NAMES[hero.element]}</div>
        <div style="font-size:11px;color:#888;margin-top:4px">Lv.${training.level}<span style="color:#555">/${maxLv}</span></div>
        <div style="display:flex;gap:2px;justify-content:center;margin-top:4px">
          ${Array.from({length:training.starLevel}).map(()=>'⭐').join('')}
        </div>
        ${item.quantity > 1 ? `<div style="font-size:9px;color:#c9a84c;margin-top:2px">碎片×${item.quantity}</div>` : ''}
      </div>
    `;
  }).join('') || '<div style="color:#555;padding:40px;text-align:center;letter-spacing:2px">尚无英雄，去神殿抽签吧</div>';
}

// ============================================================
// 养成详情弹窗
// ============================================================
let currentCultivateHeroId = null;

function openCultivateDetail(heroId) {
  currentCultivateHeroId = heroId;
  const overlay = document.getElementById('cultivate-detail-overlay');
  if (!overlay) return;
  renderCultivateDetail(heroId);
  overlay.classList.add('show');
}

function closeCultivateDetail() {
  document.getElementById('cultivate-detail-overlay')?.classList.remove('show');
  currentCultivateHeroId = null;
  renderCultivatePage(); // 刷新列表
}

function renderCultivateDetail(heroId) {
  const hero     = HERO_INDEX[heroId];
  const training = SaveSystem.getHeroTraining(heroId);
  const save     = SaveSystem.get();
  const currency = save.currency;
  if (!hero) return;

  const panel   = document.getElementById('cultivate-detail-panel');
  const elColor = ELEMENT_COLORS[hero.element] || '#888';
  const rarInfo = RARITY[hero.rarity?.toUpperCase()] || {};
  const maxLv   = TRAINING_CONFIG.maxLevelByStars[training.starLevel] || 20;
  const skills  = getHeroSkills(heroId);

  // 计算当前实际属性（含养成加成）
  const t = training;
  const lvlMul  = 1 + (t.level - 1) * 0.08;
  const starMul = 1 + (t.starLevel - 1) * 0.15;
  const extra   = t.extraStats;
  const stats = {
    hp:   Math.floor(hero.baseStats.hp  * lvlMul * starMul * (1 + extra.hpBonus)),
    atk:  Math.floor(hero.baseStats.atk * lvlMul * starMul * (1 + extra.atkBonus)),
    def:  Math.floor(hero.baseStats.def * lvlMul * starMul * (1 + extra.defBonus)),
    spd:  Math.floor(hero.baseStats.spd * (1 + extra.spdBonus)),
    crit: ((hero.baseStats.critRate + extra.critBonus) * 100).toFixed(1),
  };

  const expPct = Math.floor(t.exp / t.expToNext * 100);
  const canLevelUp = t.level < maxLv && currency.cultivateSoul >= TRAINING_CONFIG.levelUpCost(t.level);
  const canBreak   = t.starLevel < 6 && t.level >= maxLv;
  const nextBreakCost = TRAINING_CONFIG.breakthroughCost[t.starLevel];

  panel.innerHTML = `
    <button class="detail-close" onclick="closeCultivateDetail()">✕</button>

    <!-- 顶部：英雄信息 -->
    <div style="display:flex;gap:20px;align-items:flex-start;margin-bottom:20px">
      <div style="width:100px;height:120px;background:linear-gradient(135deg,${elColor}22,${elColor}11);border:2px solid ${elColor}44;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:56px;flex-shrink:0;position:relative">
        ${hero.portrait}
        <div style="position:absolute;bottom:4px;right:6px;font-size:9px;color:${rarInfo.color}">${rarInfo.name}</div>
      </div>
      <div style="flex:1">
        <div style="font-size:22px;font-weight:900;color:${rarInfo.color};letter-spacing:3px">${hero.name}</div>
        <div style="font-size:12px;color:#888;margin:2px 0 6px">${hero.title || ''}</div>
        <div style="display:flex;gap:4px;margin-bottom:8px">
          ${Array.from({length:t.starLevel}).map(()=>'⭐').join('')}
          ${Array.from({length:6-t.starLevel}).map(()=>'<span style="color:#333">★</span>').join('')}
        </div>
        <div style="font-size:13px;color:#ccc">Lv.<span style="font-size:20px;font-weight:700;color:#f0c040">${t.level}</span><span style="color:#555"> / ${maxLv}</span></div>
        <!-- 经验条 -->
        <div style="margin-top:6px;background:#111;border-radius:4px;height:6px;overflow:hidden;width:200px">
          <div style="height:100%;width:${expPct}%;background:linear-gradient(90deg,#c9a84c,#f0c040);transition:width 0.4s"></div>
        </div>
        <div style="font-size:10px;color:#555;margin-top:2px">修炼经验 ${t.exp} / ${t.expToNext}</div>
      </div>
    </div>

    <!-- 标签页 -->
    <div class="cultivate-tabs" id="cultivate-tabs">
      <button class="cultivate-tab active" onclick="switchCultivateTab('stats')">属性强化</button>
      <button class="cultivate-tab" onclick="switchCultivateTab('skills')">技能修炼</button>
      <button class="cultivate-tab" onclick="switchCultivateTab('reforge')">洗练重塑</button>
    </div>

    <!-- tab内容 -->
    <div id="cultivate-tab-content" style="margin-top:16px">
      ${renderCultivateTabStats(hero, t, stats, maxLv, canLevelUp, canBreak, nextBreakCost, currency)}
    </div>
  `;
}

function switchCultivateTab(tab) {
  document.querySelectorAll('.cultivate-tab').forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');

  const heroId   = currentCultivateHeroId;
  const hero     = HERO_INDEX[heroId];
  const training = SaveSystem.getHeroTraining(heroId);
  const save     = SaveSystem.get();
  const currency = save.currency;
  const maxLv    = TRAINING_CONFIG.maxLevelByStars[training.starLevel] || 20;
  const canLevelUp = training.level < maxLv && currency.cultivateSoul >= TRAINING_CONFIG.levelUpCost(training.level);
  const canBreak   = training.starLevel < 6 && training.level >= maxLv;
  const nextBreakCost = TRAINING_CONFIG.breakthroughCost[training.starLevel];

  const lvlMul  = 1 + (training.level - 1) * 0.08;
  const starMul = 1 + (training.starLevel - 1) * 0.15;
  const extra   = training.extraStats;
  const stats = {
    hp:   Math.floor(hero.baseStats.hp  * lvlMul * starMul * (1 + extra.hpBonus)),
    atk:  Math.floor(hero.baseStats.atk * lvlMul * starMul * (1 + extra.atkBonus)),
    def:  Math.floor(hero.baseStats.def * lvlMul * starMul * (1 + extra.defBonus)),
    spd:  Math.floor(hero.baseStats.spd * (1 + extra.spdBonus)),
    crit: ((hero.baseStats.critRate + extra.critBonus) * 100).toFixed(1),
  };

  const content = document.getElementById('cultivate-tab-content');
  if (!content) return;

  if (tab === 'stats') {
    content.innerHTML = renderCultivateTabStats(hero, training, stats, maxLv, canLevelUp, canBreak, nextBreakCost, currency);
  } else if (tab === 'skills') {
    content.innerHTML = renderCultivateTabSkills(hero, training, currency);
  } else if (tab === 'reforge') {
    content.innerHTML = renderCultivateTabReforge(hero, training, stats, currency);
  }
}

// ── Tab1：属性强化（升级 + 突破）──
function renderCultivateTabStats(hero, t, stats, maxLv, canLevelUp, canBreak, nextBreakCost, currency) {
  const costNow = TRAINING_CONFIG.levelUpCost(t.level);
  return `
    <!-- 当前属性 -->
    <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:8px;margin-bottom:16px">
      ${[
        ['生命', stats.hp,   '#27ae60'],
        ['攻击', stats.atk,  '#e74c3c'],
        ['防御', stats.def,  '#3498db'],
        ['速度', stats.spd,  '#f39c12'],
        ['暴击', stats.crit+'%', '#9b59b6'],
      ].map(([n,v,c]) => `
        <div style="background:rgba(0,0,0,0.5);border:1px solid ${c}33;border-radius:8px;padding:8px;text-align:center">
          <div style="font-size:9px;color:#555;letter-spacing:2px">${n}</div>
          <div style="font-size:16px;font-weight:700;color:${c}">${v}</div>
        </div>
      `).join('')}
    </div>

    <!-- 升级区域 -->
    <div style="background:rgba(201,168,76,0.06);border:1px solid rgba(201,168,76,0.2);border-radius:10px;padding:16px;margin-bottom:12px">
      <div style="font-size:13px;color:#c9a84c;letter-spacing:3px;margin-bottom:10px">⬆ 升级修炼</div>
      ${t.level >= maxLv ? `
        <div style="color:#888;font-size:12px;text-align:center;padding:8px">
          已达当前阶段满级 (Lv.${maxLv})${t.starLevel < 6 ? '，可进行突破' : '，已达最高等级'}
        </div>
      ` : `
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap">
          <div style="font-size:12px;color:#888">消耗：<span style="color:#c9a84c">修炼魂 ${costNow}</span></div>
          <div style="font-size:12px;color:#888">持有：<span style="color:${currency.cultivateSoul >= costNow ? '#2ecc71' : '#e74c3c'}">${currency.cultivateSoul}</span></div>
          <button class="btn-cultivate${canLevelUp ? '' : ' disabled'}"
            onclick="${canLevelUp ? 'doLevelUp()' : 'showToast(\"修炼魂不足或已满级\")'}"
            style="margin-left:auto">
            升一级
          </button>
          <button class="btn-cultivate${currency.cultivateSoul >= costNow * 5 && t.level < maxLv ? '' : ' disabled'}"
            onclick="${t.level < maxLv ? 'doLevelUp5()' : ''}">
            升五级
          </button>
        </div>
      `}
    </div>

    <!-- 突破区域 -->
    ${t.starLevel < 6 ? `
    <div style="background:rgba(255,180,0,0.05);border:1px solid rgba(255,180,0,0.25);border-radius:10px;padding:16px">
      <div style="font-size:13px;color:#f0c040;letter-spacing:3px;margin-bottom:10px">✦ 境界突破</div>
      ${!canBreak ? `
        <div style="color:#666;font-size:12px">需达到 Lv.${maxLv} 满级方可突破（当前 Lv.${t.level}）</div>
      ` : `
        <div style="font-size:12px;color:#aaa;margin-bottom:12px">突破至 <span style="color:#f0c040">${t.starLevel + 1} 阶境界</span>，解锁更高等级上限与属性加成</div>
        <div style="display:flex;gap:16px;flex-wrap:wrap;margin-bottom:12px">
          ${nextBreakCost ? [
            ['修炼魂', nextBreakCost.cultivateSoul, currency.cultivateSoul],
            ['碎片',   nextBreakCost.fragments,     SaveSystem.get().inventory.find(i=>i.heroId===hero.id)?.quantity || 0],
            ['灵石',   nextBreakCost.lingshi,        currency.lingshi],
          ].map(([n,need,have]) => `
            <div style="font-size:11px;background:rgba(0,0,0,0.4);border-radius:6px;padding:6px 10px">
              <span style="color:#888">${n}：</span>
              <span style="color:${have >= need ? '#2ecc71' : '#e74c3c'}">${have}</span>
              <span style="color:#555"> / ${need}</span>
            </div>
          `).join('') : ''}
        </div>
        <button class="btn-cultivate gold" onclick="doBreakthrough()" style="width:100%">
          ✦ 突破境界
        </button>
      `}
    </div>
    ` : '<div style="text-align:center;color:#c9a84c;font-size:13px;padding:12px;letter-spacing:3px">✦ 已达最高境界 ✦</div>'}
  `;
}

// ── Tab2：技能修炼 ──
function renderCultivateTabSkills(hero, training, currency) {
  const skills = getHeroSkills(hero.id);
  if (!skills.length) return '<div style="color:#555;padding:20px;text-align:center">暂无可修炼技能</div>';

  return skills.map(skill => {
    const skLv   = training.skillLevels[skill.id] || 1;
    const maxSkLv = 5;
    const cost   = TRAINING_CONFIG.skillUpgradeCost(skLv + 1);
    const canUp  = skLv < maxSkLv
      && currency.cultivateSoul >= cost.cultivateSoul
      && currency.lingshi >= cost.lingshi;

    const bonuses = ['', '+10%伤害/效果', '+20%伤害/效果', '+35%伤害/效果', '+50%伤害/效果，冷却-1'];

    return `
      <div style="background:rgba(0,0,0,0.4);border:1px solid ${skill.color || '#333'}44;border-radius:10px;padding:14px;margin-bottom:10px">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px">
          <span style="font-size:24px">${skill.icon}</span>
          <div style="flex:1">
            <div style="display:flex;align-items:center;gap:8px">
              <span style="font-size:15px;color:${skill.color || '#ccc'};font-weight:700">${skill.name}</span>
              <span style="font-size:12px;color:#c9a84c;background:rgba(201,168,76,0.15);border-radius:4px;padding:1px 8px">Lv.${skLv}</span>
              <span style="font-size:11px;color:#555">最高Lv.${maxSkLv}</span>
            </div>
            <div style="font-size:11px;color:#666;margin-top:3px">${skill.desc}</div>
          </div>
        </div>
        <!-- 等级进度 -->
        <div style="display:flex;gap:4px;margin-bottom:10px">
          ${Array.from({length:maxSkLv}).map((_,i) => `
            <div style="flex:1;height:4px;border-radius:2px;background:${i < skLv ? skill.color || '#c9a84c' : '#222'}"></div>
          `).join('')}
        </div>
        ${skLv < maxSkLv ? `
          <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
            <div style="font-size:11px;color:#888">升至Lv.${skLv+1}效果：<span style="color:${skill.color || '#ccc'}">${bonuses[skLv]}</span></div>
            <div style="font-size:11px;color:#888;margin-left:auto">
              修炼魂<span style="color:${currency.cultivateSoul>=cost.cultivateSoul?'#2ecc71':'#e74c3c'}"> ${cost.cultivateSoul}</span>
              &nbsp; 灵石<span style="color:${currency.lingshi>=cost.lingshi?'#2ecc71':'#e74c3c'}"> ${cost.lingshi}</span>
            </div>
            <button class="btn-cultivate${canUp?'':' disabled'}" onclick="${canUp?`doSkillUpgrade('${skill.id}')`:`showToast('材料不足')`}">
              修炼
            </button>
          </div>
        ` : `<div style="font-size:12px;color:#c9a84c;text-align:center">✦ 已达最高等级</div>`}
      </div>
    `;
  }).join('');
}

// ── Tab3：洗练重塑 ──
function renderCultivateTabReforge(hero, training, stats, currency) {
  const cost = TRAINING_CONFIG.reforgeCost;
  const canReforge = currency.cultivateSoul >= cost.cultivateSoul && currency.lingshi >= cost.lingshi;
  const extra = training.extraStats;

  const bonusItems = [
    { key: 'hpBonus',   label: '生命加成', color: '#27ae60', val: (extra.hpBonus*100).toFixed(1) },
    { key: 'atkBonus',  label: '攻击加成', color: '#e74c3c', val: (extra.atkBonus*100).toFixed(1) },
    { key: 'defBonus',  label: '防御加成', color: '#3498db', val: (extra.defBonus*100).toFixed(1) },
    { key: 'spdBonus',  label: '速度加成', color: '#f39c12', val: (extra.spdBonus*100).toFixed(1) },
    { key: 'critBonus', label: '暴击加成', color: '#9b59b6', val: (extra.critBonus*100).toFixed(1) },
  ];

  return `
    <div style="font-size:12px;color:#888;margin-bottom:14px;line-height:1.8">
      洗练重塑将随机刷新英雄的<span style="color:#c9a84c">附加属性加成</span>，每次洗练均随机获得2~4条属性，范围 <span style="color:#c9a84c">0%~25%</span>。
      已洗练 <span style="color:#c9a84c">${training.reforgeCount}</span> 次。
    </div>

    <!-- 当前附加属性 -->
    <div style="background:rgba(0,0,0,0.4);border:1px solid rgba(201,168,76,0.2);border-radius:10px;padding:14px;margin-bottom:14px">
      <div style="font-size:12px;color:#c9a84c;letter-spacing:2px;margin-bottom:10px">当前附加属性</div>
      <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:8px">
        ${bonusItems.map(b => `
          <div style="text-align:center">
            <div style="font-size:9px;color:#555">${b.label}</div>
            <div style="font-size:15px;font-weight:700;color:${parseFloat(b.val) > 0 ? b.color : '#444'}">+${b.val}%</div>
          </div>
        `).join('')}
      </div>
    </div>

    <!-- 洗练操作 -->
    <div style="background:rgba(155,89,182,0.06);border:1px solid rgba(155,89,182,0.25);border-radius:10px;padding:14px">
      <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;margin-bottom:12px">
        <div style="font-size:12px;color:#888">消耗：
          <span style="color:${currency.cultivateSoul >= cost.cultivateSoul ? '#2ecc71' : '#e74c3c'}">修炼魂 ${cost.cultivateSoul}</span> &nbsp;
          <span style="color:${currency.lingshi >= cost.lingshi ? '#2ecc71' : '#e74c3c'}">灵石 ${cost.lingshi}</span>
        </div>
      </div>
      <button class="btn-cultivate${canReforge ? ' gold' : ' disabled'}" onclick="${canReforge ? 'doReforge()' : `showToast('材料不足')`}" style="width:100%">
        🔮 洗练重塑
      </button>
    </div>
  `;
}

// ============================================================
// 养成操作函数
// ============================================================

/** 升1级 */
function doLevelUp() {
  const heroId   = currentCultivateHeroId;
  const training = SaveSystem.getHeroTraining(heroId);
  const save     = SaveSystem.get();
  const maxLv    = TRAINING_CONFIG.maxLevelByStars[training.starLevel];
  if (training.level >= maxLv) { showToast('已满级，请突破境界'); return; }

  const cost = TRAINING_CONFIG.levelUpCost(training.level);
  if (save.currency.cultivateSoul < cost) { showToast('修炼魂不足'); return; }

  save.currency.cultivateSoul -= cost;
  training.level += 1;
  training.exp    = 0;
  training.expToNext = Math.floor(100 * Math.pow(1.15, training.level - 1));

  SaveSystem.updateHeroTraining(heroId, training);
  SaveSystem.updateCurrency({ cultivateSoul: save.currency.cultivateSoul });
  updateCurrencyDisplay();
  renderCultivateDetail(heroId);
  showToast(`${HERO_INDEX[heroId]?.name} 升至 Lv.${training.level}！`);
  if (typeof onTaskEvent === 'function') onTaskEvent('cultivate');
}

/** 升5级 */
function doLevelUp5() {
  for (let i = 0; i < 5; i++) {
    const training = SaveSystem.getHeroTraining(currentCultivateHeroId);
    const save     = SaveSystem.get();
    const maxLv    = TRAINING_CONFIG.maxLevelByStars[training.starLevel];
    if (training.level >= maxLv) break;
    const cost = TRAINING_CONFIG.levelUpCost(training.level);
    if (save.currency.cultivateSoul < cost) { showToast('修炼魂不足，已停止升级'); break; }
    save.currency.cultivateSoul -= cost;
    training.level += 1;
    training.expToNext = Math.floor(100 * Math.pow(1.15, training.level - 1));
    SaveSystem.updateHeroTraining(currentCultivateHeroId, training);
    SaveSystem.updateCurrency({ cultivateSoul: save.currency.cultivateSoul });
  }
  updateCurrencyDisplay();
  renderCultivateDetail(currentCultivateHeroId);
  const t = SaveSystem.getHeroTraining(currentCultivateHeroId);
  showToast(`${HERO_INDEX[currentCultivateHeroId]?.name} 升至 Lv.${t.level}！`, 2500);
  if (typeof onTaskEvent === 'function') onTaskEvent('cultivate', 5);
}

/** 突破境界 */
function doBreakthrough() {
  const heroId   = currentCultivateHeroId;
  const training = SaveSystem.getHeroTraining(heroId);
  const save     = SaveSystem.get();
  const maxLv    = TRAINING_CONFIG.maxLevelByStars[training.starLevel];

  if (training.level < maxLv) { showToast(`需达到 Lv.${maxLv} 才能突破`); return; }
  if (training.starLevel >= 6) { showToast('已是最高境界'); return; }

  const cost   = TRAINING_CONFIG.breakthroughCost[training.starLevel];
  const invItem = save.inventory.find(i => i.heroId === heroId);
  const fragments = invItem ? invItem.quantity : 0;

  if (save.currency.cultivateSoul < cost.cultivateSoul) { showToast('修炼魂不足'); return; }
  if (fragments < cost.fragments) { showToast(`碎片不足（需要${cost.fragments}片，持有${fragments}片）`); return; }
  if (save.currency.lingshi < cost.lingshi) { showToast('灵石不足'); return; }

  // 扣除消耗
  save.currency.cultivateSoul -= cost.cultivateSoul;
  save.currency.lingshi       -= cost.lingshi;
  if (invItem) invItem.quantity -= cost.fragments;

  training.starLevel += 1;
  training.level     = training.level; // 保持当前等级，只是上限提升

  SaveSystem.updateHeroTraining(heroId, training);
  SaveSystem.updateCurrency({ cultivateSoul: save.currency.cultivateSoul, lingshi: save.currency.lingshi });
  SaveSystem.save(save);
  updateCurrencyDisplay();
  renderCultivateDetail(heroId);

  showToast(`✦ ${HERO_INDEX[heroId]?.name} 突破至 ${training.starLevel} 阶境界！`, 3000);
  // 播放突破特效
  showBreakthroughEffect();
}

/** 技能修炼 */
function doSkillUpgrade(skillId) {
  const heroId   = currentCultivateHeroId;
  const training = SaveSystem.getHeroTraining(heroId);
  const save     = SaveSystem.get();
  const skLv     = training.skillLevels[skillId] || 1;

  if (skLv >= 5) { showToast('技能已达最高等级'); return; }

  const cost = TRAINING_CONFIG.skillUpgradeCost(skLv + 1);
  if (save.currency.cultivateSoul < cost.cultivateSoul) { showToast('修炼魂不足'); return; }
  if (save.currency.lingshi < cost.lingshi) { showToast('灵石不足'); return; }

  save.currency.cultivateSoul -= cost.cultivateSoul;
  save.currency.lingshi       -= cost.lingshi;
  training.skillLevels[skillId] = skLv + 1;

  SaveSystem.updateHeroTraining(heroId, training);
  SaveSystem.updateCurrency({ cultivateSoul: save.currency.cultivateSoul, lingshi: save.currency.lingshi });
  updateCurrencyDisplay();

  // 切换回技能tab刷新
  document.getElementById('cultivate-tab-content').innerHTML =
    renderCultivateTabSkills(HERO_INDEX[heroId], training, save.currency);

  showToast(`【${SKILLS[skillId]?.name}】升至 Lv.${skLv + 1}！`);
}

/** 洗练重塑 */
function doReforge() {
  const heroId   = currentCultivateHeroId;
  const training = SaveSystem.getHeroTraining(heroId);
  const save     = SaveSystem.get();
  const cost     = TRAINING_CONFIG.reforgeCost;

  if (save.currency.cultivateSoul < cost.cultivateSoul) { showToast('修炼魂不足'); return; }
  if (save.currency.lingshi < cost.lingshi) { showToast('灵石不足'); return; }

  save.currency.cultivateSoul -= cost.cultivateSoul;
  save.currency.lingshi       -= cost.lingshi;

  // 随机生成2~4条附加属性
  const keys   = ['hpBonus','atkBonus','defBonus','spdBonus','critBonus'];
  const newExtra = { hpBonus:0, atkBonus:0, defBonus:0, spdBonus:0, critBonus:0 };
  const count  = 2 + Math.floor(Math.random() * 3);
  const chosen = [...keys].sort(() => Math.random() - 0.5).slice(0, count);
  chosen.forEach(k => {
    newExtra[k] = parseFloat((Math.random() * 0.25).toFixed(3));
  });

  training.extraStats   = newExtra;
  training.reforgeCount = (training.reforgeCount || 0) + 1;

  SaveSystem.updateHeroTraining(heroId, training);
  SaveSystem.updateCurrency({ cultivateSoul: save.currency.cultivateSoul, lingshi: save.currency.lingshi });
  updateCurrencyDisplay();

  // 更新tab内容
  const lvlMul  = 1 + (training.level - 1) * 0.08;
  const starMul = 1 + (training.starLevel - 1) * 0.15;
  const e = newExtra;
  const hero = HERO_INDEX[heroId];
  const stats = {
    hp:   Math.floor(hero.baseStats.hp  * lvlMul * starMul * (1 + e.hpBonus)),
    atk:  Math.floor(hero.baseStats.atk * lvlMul * starMul * (1 + e.atkBonus)),
    def:  Math.floor(hero.baseStats.def * lvlMul * starMul * (1 + e.defBonus)),
    spd:  Math.floor(hero.baseStats.spd * (1 + e.spdBonus)),
    crit: ((hero.baseStats.critRate + e.critBonus) * 100).toFixed(1),
  };
  document.getElementById('cultivate-tab-content').innerHTML =
    renderCultivateTabReforge(hero, training, stats, save.currency);

  showToast(`🔮 洗练完成！获得 ${count} 条附加属性`, 2500);
}

/** 突破特效 */
function showBreakthroughEffect() {
  const el = document.createElement('div');
  el.style.cssText = `
    position:fixed;inset:0;z-index:9999;pointer-events:none;
    background:radial-gradient(ellipse,rgba(255,215,0,0.35) 0%,transparent 70%);
    animation:breakthroughFlash 1.2s ease-out forwards;
  `;
  document.body.appendChild(el);
  setTimeout(() => el.remove(), 1200);
}
