/**
 * 《太初演义》主游戏控制器
 * 整合所有系统，管理UI状态
 */

// ============================================================
// 全局游戏状态
// ============================================================
const GameState = {
  currentPage: 'home',
  selectedTeam: [],      // 玩家当前队伍 (hero instances)
  selectedHeroIndex: -1, // 当前选中的英雄下标（战斗中）
  battle: null,          // 当前战斗实例
  gacha: null,           // 抽卡系统实例
  codexFilter: 'all',
  teamSlots: 5,
};

// ============================================================
// 工具函数
// ============================================================
function showToast(msg, duration = 2000) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add('show');
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => toast.classList.remove('show'), duration);
}

function navigateTo(pageId) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
  const pg = document.getElementById('page-' + pageId);
  const tab = document.querySelector(`.nav-tab[data-page="${pageId}"]`);
  if (pg) pg.classList.add('active');
  if (tab) tab.classList.add('active');
  GameState.currentPage = pageId;

  if (pageId === 'gacha')     renderGachaPage();
  if (pageId === 'team')      renderTeamPage();
  if (pageId === 'codex')     renderCodexPage();
  if (pageId === 'battle')    showBattleSetup();
  if (pageId === 'cultivate') renderCultivatePage();
  if (pageId === 'home')      refreshHomePlayerInfo();
}

function updateCurrencyDisplay() {
  const save = SaveSystem.get();
  if (!save) return;
  const cur = save.currency;
  // 同步 gacha 系统的货币到存档
  if (GameState.gacha) {
    const gachaCur = GameState.gacha.getCurrency();
    cur.lingshi      = gachaCur.lingshi;
    cur.bututianshi  = gachaCur.bututianshi;
    cur.hundunJing   = gachaCur.hundunJing;
    SaveSystem.updateCurrency(cur);
  }
  document.getElementById('currency-lingshi').textContent       = cur.lingshi       ?? 0;
  document.getElementById('currency-bututian').textContent      = cur.bututianshi   ?? 0;
  document.getElementById('currency-cultivate-soul').textContent = cur.cultivateSoul ?? 0;
  const hdr = document.getElementById('cultivate-soul-header');
  if (hdr) hdr.textContent = cur.cultivateSoul ?? 0;
}

// ============================================================
// ── 主页 ──
// ============================================================
function renderHomePage() {
  // 首页逻辑：已在HTML内嵌
}

// ============================================================
// ── 战斗系统 ──
// ============================================================
class BattleInstance {
  constructor(playerTeam, enemyTeam) {
    this.playerTeam = playerTeam.filter(Boolean).map(h => ({ ...h }));
    this.enemyTeam  = enemyTeam.map(h => ({ ...h, isPlayer: false }));
    this.allUnits   = [...this.playerTeam, ...this.enemyTeam];
    this.round      = 1;
    this.phase      = 'player'; // 'player' | 'enemy' | 'result'
    this.log        = new BattleLog();
    this.selectedPlayerIdx = -1;
    this.selectedTargetIdx = -1;
    this.isAnimating = false;
    this.pendingSkillId = null; // 等待玩家选择目标的单体技能

    // 检查连携
    const combos = checkCombos(this.playerTeam);
    combos.forEach(combo => {
      combo.apply(this.playerTeam, applyStatusEffect);
      this.log.add(`✨ 连携技【${combo.name}】触发！${combo.desc}`, 'combo', combo.icon);
    });

    // 速度排序行动队列
    this.buildActionQueue();
  }

  buildActionQueue() {
    this.actionQueue = [...this.playerTeam, ...this.enemyTeam]
      .filter(u => !u.isDead)
      .sort((a, b) => b.spd - a.spd);
    this.queueIdx = 0;
  }

  get currentActor() {
    return this.actionQueue[this.queueIdx];
  }

  getLivePlayerTeam()  { return this.playerTeam.filter(u => !u.isDead); }
  getLiveEnemyTeam()   { return this.enemyTeam.filter(u => !u.isDead); }
  isPlayerTurn()       { return this.currentActor && this.currentActor.isPlayer; }

  // 执行攻击
  executeAttack(attacker, target, skill = null) {
    if (target.isDead) return;

    // 检查无敌
    const invincible = target.statusEffects?.find(e => e.id === 'invincible');
    if (invincible) {
      this.log.add(`${target.name} 处于【无敌】状态，抵挡了攻击！`, 'buff', '✨');
      return;
    }

    // 检查攻击方是否被眩晕/冰冻
    const stunned = attacker.statusEffects?.find(e => e.id === 'stun' || e.id === 'freeze');
    if (stunned) {
      this.log.add(`${attacker.name} 处于【${stunned.name}】状态，无法行动！`, 'system');
      return;
    }

    const result = calculateDamage(attacker, target, skill);

    // 执行伤害
    target.hp = Math.max(0, target.hp - result.totalDmg);

    // 日志
    let logMsg = `${attacker.name} → ${target.name}`;
    if (skill) logMsg += ` 【${skill.name}】`;
    logMsg += ` 造成 ${result.dmg} 点伤害`;
    if (result.isCrit) logMsg += ` 💥暴击！`;
    if (result.trueDmg > 0) logMsg += ` + ${result.trueDmg} 点真实伤害`;
    if (result.relation.type !== 'neutral') logMsg += ` (${result.relation.desc})`;

    const logType = result.isCrit ? 'special' : 'damage';
    this.log.add(logMsg, logType);

    // 特殊效果
    if (result.appliedEffect && result.appliedEffect !== 'none' && result.appliedEffect !== 'guaranteed_hit') {
      if (['silence','stun','burn','freeze','amnesia'].includes(result.appliedEffect)) {
        applyStatusEffect(target, result.appliedEffect);
        const eff = STATUS_EFFECTS[result.appliedEffect];
        this.log.add(`   ⚡ 触发【${eff.name}】效果！`, 'special');
      }
      if (result.appliedEffect === 'dispel') {
        if (target.statusEffects?.length > 0) {
          const removed = target.statusEffects.find(e => ['shield','invincible','regen'].includes(e.id));
          if (removed) {
            target.statusEffects = target.statusEffects.filter(e => e !== removed);
            this.log.add(`   🌀 驱散目标【${removed.name}】增益！`, 'special');
          }
        }
      }
    }

    // 技能特殊效果
    if (skill) {
      if (skill.executeThreshold && target.hp / target.maxHp < skill.executeThreshold && target.hp > 0) {
        target.hp = 0;
        this.log.add(`   ⚔️ 斩杀触发！${target.name} 被直接斩杀！`, 'special');
      }
      if (skill.statusEffect && ['shield','invincible','regen'].includes(skill.statusEffect)) {
        const sTargets = skill.statusTarget === 'all_allies'
          ? (attacker.isPlayer ? this.playerTeam : this.enemyTeam).filter(u => !u.isDead)
          : [attacker];
        const shieldVal = skill.shieldRatio ? Math.floor(attacker.maxHp * skill.shieldRatio) : 0;
        sTargets.forEach(t => {
          applyStatusEffect(t, skill.statusEffect, shieldVal);
          this.log.add(`   🛡️ 为 ${t.name} 施加【${STATUS_EFFECTS[skill.statusEffect].name}】！`, 'buff');
        });
      }
      if (skill.clearAllStatus) {
        [...this.playerTeam, ...this.enemyTeam].forEach(u => { u.statusEffects = []; });
        this.log.add(`   🌌 大道之音！清除双方所有增减益效果！`, 'special');
      }
    }

    // 死亡判定
    if (target.hp <= 0) {
      target.hp = 0;
      target.isDead = true;
      this.log.add(`${target.name} 已陨落...`, 'system');
    }

    // 怒气增加
    if (attacker.isPlayer) {
      attacker.rage = Math.min(attacker.maxRage, (attacker.rage || 0) + 1);
    }
  }

  // 敌方AI行动
  enemyTurn(enemyUnit) {
    if (enemyUnit.isDead) return;
    const players = this.getLivePlayerTeam();
    if (players.length === 0) return;

    // AI逻辑：优先攻击克制目标，否则攻击最低血量
    let target = players.reduce((a, b) => (a.hp < b.hp ? a : b));
    
    // 简单AI：看克制
    const betterTarget = players.find(p => {
      const rel = getRelation(enemyUnit.element, p.element);
      return rel.type === 'counter' || rel.type === 'high_counter';
    });
    if (betterTarget) target = betterTarget;

    // 随机选技能（如果有怒气）
    let skill = null;
    if ((enemyUnit.rage || 0) >= 3 && enemyUnit.skills?.length > 0) {
      const sid = enemyUnit.skills[0];
      skill = SKILLS[sid] || null;
      if (skill) enemyUnit.rage = Math.max(0, (enemyUnit.rage || 0) - skill.cost);
    }
    enemyUnit.rage = Math.min(enemyUnit.maxRage, (enemyUnit.rage || 0) + 1);

    this.executeAttack(enemyUnit, target, skill);
  }

  // 回合tick
  tickRound() {
    this.buildActionQueue();
    this.log.add(`── 第 ${this.round} 回合 ──`, 'system');
    
    // 处理所有单位的回合tick（DOT、HOT等）
    [...this.playerTeam, ...this.enemyTeam].forEach(u => {
      if (!u.isDead) {
        const tickResult = tickStatusEffects(u);
        if (tickResult.hpChange !== 0) {
          if (tickResult.hpChange < 0) {
            this.log.add(`🔥 ${u.name} 受到灼烧，损失 ${-tickResult.hpChange} 点生命值`, 'damage');
          } else {
            this.log.add(`💚 ${u.name} 恢复 ${tickResult.hpChange} 点生命值`, 'heal');
          }
          if (u.hp <= 0) {
            u.isDead = true;
            this.log.add(`${u.name} 已陨落...（灼烧）`, 'system');
          }
        }
      }
    });
  }

  checkWinLose() {
    const playerAlive = this.getLivePlayerTeam().length > 0;
    const enemyAlive = this.getLiveEnemyTeam().length > 0;
    if (!playerAlive) return 'lose';
    if (!enemyAlive) return 'win';
    return null;
  }
}

// ============================================================
// ── 战斗UI渲染 ──
// ============================================================
let battle = null;

function showBattleSetup() {
  // 如果已有进行中的战斗，直接渲染即可，不重置
  if (GameState.battle && GameState.battle.checkWinLose() === null) {
    renderBattleUI();
    return;
  }

  // 过滤掉空槽，取有效英雄
  const validTeam = GameState.selectedTeam.filter(Boolean);
  // 若无有效英雄，使用默认队伍
  if (validTeam.length === 0) {
    GameState.selectedTeam = new Array(GameState.teamSlots).fill(null);
    ['gonggong','zhurong','shennong'].forEach((id, i) => {
      GameState.selectedTeam[i] = createHeroInstance(id, 20, 3);
    });
  }
  startBattle();
}

function startBattle() {
  // 过滤空槽，只取有效英雄上场
  const validPlayerTeam = GameState.selectedTeam.filter(Boolean);

  // 创建敌方队伍（关卡敌方）
  const enemyTeam = [
    { ...createHeroInstance('rushou', 18, 2), isPlayer: false, name: '蓐收·守将' },
    { ...createHeroInstance('dijun', 22, 3),  isPlayer: false, name: '帝俊·天主' },
    { ...createHeroInstance('xuanming', 15, 2), isPlayer: false, name: '玄冥·幽将' },
  ];

  battle = new BattleInstance(validPlayerTeam, enemyTeam);
  GameState.battle = battle;

  renderBattleUI();
  setTimeout(() => {
    battle.log.add('天地初开，大战将至！', 'system');
    battle.log.add('——「混沌遗迹 · 第三层」——', 'system');
    renderBattleLog();
  }, 100);
}

function renderBattleUI() {
  const enemyZone  = document.getElementById('enemy-zone');
  const playerZone = document.getElementById('player-zone');
  if (!enemyZone || !playerZone || !battle) return;

  enemyZone.innerHTML  = '';
  playerZone.innerHTML = '';

  battle.enemyTeam.forEach((hero, idx) => {
    enemyZone.appendChild(createHeroCard(hero, idx, false));
  });
  battle.playerTeam.forEach((hero, idx) => {
    playerZone.appendChild(createHeroCard(hero, idx, true));
  });

  // 更新双方战力对比
  renderBattleStats();

  renderSkillBar();
  renderBattleLog();
  updateBattleButtons();
}

function renderBattleStats() {
  const el = document.getElementById('battle-stats-bar');
  if (!el || !battle) return;

  const livePlayer = battle.playerTeam.filter(u => !u.isDead);
  const liveEnemy  = battle.enemyTeam.filter(u => !u.isDead);

  const pAtk = livePlayer.reduce((s, u) => s + (u.atk || 0), 0);
  const pDef = livePlayer.reduce((s, u) => s + (u.def || 0), 0);
  const eAtk = liveEnemy.reduce((s,  u) => s + (u.atk || 0), 0);
  const eDef = liveEnemy.reduce((s,  u) => s + (u.def || 0), 0);

  const totalAtk = pAtk + eAtk || 1;
  const pAtkPct  = Math.round(pAtk / totalAtk * 100);

  el.innerHTML = `
    <div class="bstat-block enemy-stat">
      <span class="bstat-label">⚔️ ${eAtk}</span>
      <span class="bstat-sep">|</span>
      <span class="bstat-label">🛡️ ${eDef}</span>
    </div>
    <div class="bstat-vs-bar">
      <div style="height:100%;width:${100 - pAtkPct}%;background:rgba(200,60,60,0.55);transition:width 0.5s"></div>
      <div style="height:100%;width:${pAtkPct}%;background:rgba(60,180,100,0.55);transition:width 0.5s"></div>
    </div>
    <div class="bstat-block player-stat">
      <span class="bstat-label">⚔️ ${pAtk}</span>
      <span class="bstat-sep">|</span>
      <span class="bstat-label">🛡️ ${pDef}</span>
    </div>
  `;
}

function createHeroCard(hero, idx, isPlayer) {
  const el = ELEMENT_COLORS[hero.element] || '#888';
  const hpPct = hero.maxHp > 0 ? (hero.hp / hero.maxHp * 100).toFixed(1) : 0;
  const hpClass = hpPct > 60 ? '' : hpPct > 30 ? 'mid' : 'low';

  const div = document.createElement('div');
  const isTargetable = !isPlayer && !hero.isDead && battle && battle.pendingSkillId;
  div.className = `hero-card-battle${hero.isDead ? ' dead' : ''}${isTargetable ? ' targetable' : ''}`;
  div.dataset.idx = idx;
  div.dataset.isPlayer = isPlayer ? '1' : '0';
  div.id = `hero-card-${isPlayer ? 'p' : 'e'}-${idx}`;

  // 状态图标
  const statusHtml = (hero.statusEffects || []).map(s =>
    `<div class="status-icon" style="background:${s.color}22;border-color:${s.color}55" title="${s.name}">${s.icon}</div>`
  ).join('');

  // 怒气槽（仅玩家）
  const rageHtml = isPlayer ? `
    <div class="rage-bar-wrap">
      ${Array.from({length: hero.maxRage}, (_, i) =>
        `<div class="rage-pip${i < (hero.rage || 0) ? ' filled' : ''}"></div>`
      ).join('')}
    </div>` : '';

  div.innerHTML = `
    <div class="hero-portrait-battle" style="border-color:${el}55;${hero.isDead ? '' : `box-shadow:0 0 12px ${el}33`}">
      <div class="element-badge" style="background:${el}22;border-color:${el}55">
        ${ELEMENT_ICONS[hero.element] || ''}
      </div>
      <div class="status-icons">${statusHtml}</div>
      <div class="skeleton-anim idle" id="anim-${isPlayer ? 'p' : 'e'}-${idx}">
        <span class="hero-emoji">${hero.portrait}</span>
      </div>
    </div>
    <div class="hp-bar-wrap">
      <div class="hp-bar ${hpClass}" style="width:${hpPct}%"></div>
    </div>
    ${rageHtml}
    <div class="hero-name-battle" title="${hero.title || ''}">${hero.name}</div>
    <div style="text-align:center;font-size:10px;color:${el};margin-top:2px">${hpPct}%</div>
    <div class="hero-stats-mini">
      <span title="攻击力">⚔️<b>${hero.atk || 0}</b></span>
      <span title="防御力">🛡️<b>${hero.def || 0}</b></span>
    </div>
  `;

  if (isPlayer) {
    div.onclick = () => selectPlayerHero(idx);
  } else {
    div.onclick = () => selectTarget(idx);
  }
  return div;
}

function selectPlayerHero(idx) {
  if (!battle || battle.isAnimating) return;

  // 如果正在等待选目标，取消技能
  if (battle.pendingSkillId) {
    cancelPendingSkill();
    return;
  }

  const hero = battle.playerTeam[idx];
  if (!hero || hero.isDead) return;

  battle.selectedPlayerIdx = idx;
  document.querySelectorAll('.hero-card-battle[data-is-player="1"]').forEach((c, i) => {
    c.classList.toggle('selected', i === idx);
  });
  renderSkillBar();
}

function selectTarget(idx) {
  if (!battle || battle.isAnimating) return;
  if (battle.selectedPlayerIdx < 0) { showToast('请先选择己方英雄'); return; }

  const attacker = battle.playerTeam[battle.selectedPlayerIdx];
  const target   = battle.enemyTeam[idx];
  if (!attacker || attacker.isDead || !target || target.isDead) return;

  const stun = attacker.statusEffects?.find(e => e.id === 'stun' || e.id === 'freeze');
  if (stun) { showToast(`${attacker.name} 处于${stun.name}状态，无法行动！`); return; }

  // 如果有待释放的单体技能，带技能执行攻击
  if (battle.pendingSkillId) {
    const skillId = battle.pendingSkillId;
    const skill = SKILLS[skillId];
    battle.pendingSkillId = null;
    // 确认目标后才扣费
    attacker.rage -= skill.cost;
    if (!attacker.skillCooldowns) attacker.skillCooldowns = {};
    attacker.skillCooldowns[skillId] = skill.cooldown;
    renderBattleUI(); // 清除高亮
    doPlayerAttack(attacker, target, skill);
    return;
  }

  doPlayerAttack(attacker, target, null);
}

function doPlayerAttack(attacker, target, skill) {
  if (!battle || battle.isAnimating) return;
  battle.isAnimating = true;

  // 攻击动画
  const attackerCard = document.getElementById(`anim-p-${battle.selectedPlayerIdx}`);
  const targetCard   = document.getElementById(`anim-e-${battle.enemyTeam.indexOf(target)}`);
  if (attackerCard) { attackerCard.className = 'skeleton-anim attack'; }

  setTimeout(() => {
    battle.executeAttack(attacker, target, skill);

    if (targetCard) {
      targetCard.className = target.isDead ? 'skeleton-anim dead' : 'skeleton-anim hurt';
    }
    // 伤害数字
    showDamageText(target, battle.enemyTeam.indexOf(target), false);

    setTimeout(() => {
      if (attackerCard) attackerCard.className = 'skeleton-anim idle';
      if (targetCard)   targetCard.className   = target.isDead ? 'skeleton-anim dead' : 'skeleton-anim idle';

      renderBattleUI();
      checkAndHandleBattleEnd();
      battle.isAnimating = false;

      // 自动敌方回合
      if (!checkAndHandleBattleEnd()) {
        setTimeout(() => runEnemyTurn(), 600);
      }
    }, 500);
  }, 300);
}

function runEnemyTurn() {
  if (!battle) return;
  const liveEnemies = battle.getLiveEnemyTeam();
  let delay = 0;

  liveEnemies.forEach((enemy, i) => {
    setTimeout(() => {
      if (!battle || battle.checkWinLose() !== null) return;
      battle.enemyTurn(enemy);

      const ei = battle.enemyTeam.indexOf(enemy);
      const animEl = document.getElementById(`anim-e-${ei}`);
      if (animEl) { animEl.className = 'skeleton-anim attack'; }

      setTimeout(() => {
        if (animEl) animEl.className = 'skeleton-anim idle';
        renderBattleUI();
        if (i === liveEnemies.length - 1) {
          // 所有敌人行动完毕，进入下一回合
          battle.round++;
          battle.tickRound();
          renderBattleUI();
          checkAndHandleBattleEnd();
        }
      }, 400);
    }, delay);
    delay += 600;
  });
}

function showDamageText(target, idx, isPlayer) {
  const card = document.getElementById(`hero-card-${isPlayer ? 'p' : 'e'}-${idx}`);
  if (!card) return;
  const dmgEl = document.createElement('div');
  dmgEl.className = 'dmg-text';
  dmgEl.textContent = target.isDead ? '💀' : `${Math.floor(Math.random() * 50 + 80)}`;
  card.style.position = 'relative';
  card.appendChild(dmgEl);
  setTimeout(() => dmgEl.remove(), 1200);
}

function checkAndHandleBattleEnd() {
  if (!battle) return false;
  const result = battle.checkWinLose();
  if (result === 'win') {
    setTimeout(() => {
      // 战胜：发放奖励
      const save = SaveSystem.get();
      if (save) {
        save.currency.lingshi = (save.currency.lingshi || 0) + 200;
        save.currency.cultivateSoul = (save.currency.cultivateSoul || 0) + 100;
        SaveSystem.save(save);
        if (GameState.gacha) {
          GameState.gacha.state.currency.lingshi = save.currency.lingshi;
        }
        updateCurrencyDisplay();
      }
      showBattleResult(true);
    }, 500);
    return true;
  }
  if (result === 'lose') {
    setTimeout(() => showBattleResult(false), 500);
    return true;
  }
  return false;
}

function showBattleResult(isWin) {
  const overlay = document.getElementById('battle-result-overlay');
  if (!overlay) return;
  if (isWin) onBattleWin();
  else onTaskEvent('battle'); // 失败也计战斗次数
  overlay.innerHTML = `
    <div style="text-align:center;padding:40px">
      <div style="font-size:60px;margin-bottom:20px">${isWin ? '🏆' : '💀'}</div>
      <div style="font-size:28px;font-weight:900;letter-spacing:6px;color:${isWin ? '#f0c040' : '#888'};margin-bottom:12px">
        ${isWin ? '大获全胜' : '功亏一篑'}
      </div>
      <div style="font-size:14px;color:#8a7a60;letter-spacing:3px;margin-bottom:30px">
        ${isWin ? '获得灵石 ×200 · 修炼魂 ×100 · 执命经验 ×50' : '下次再战，必能得胜'}
      </div>
      ${isWin ? `<div style="margin-bottom:20px;font-size:13px;color:#aaa">奖励已发放至背包</div>` : ''}
      <div style="display:flex;gap:16px;justify-content:center">
        <button class="btn-battle" onclick="restartBattle()">再战</button>
        <button class="btn-battle blue" onclick="navigateTo('home')">返回</button>
      </div>
    </div>
  `;
  overlay.style.display = 'flex';
}

function restartBattle() {
  document.getElementById('battle-result-overlay').style.display = 'none';
  startBattle();
}

function renderSkillBar() {
  const bar = document.getElementById('skills-bar');
  if (!bar || !battle) return;
  const idx = battle.selectedPlayerIdx;
  if (idx < 0) { bar.innerHTML = '<div style="color:#555;font-size:13px;letter-spacing:2px">选择英雄后可使用技能</div>'; return; }

  const hero = battle.playerTeam[idx];
  if (!hero || hero.isDead) { bar.innerHTML = ''; return; }

  const pendingId = battle.pendingSkillId;

  let html = (hero.skills || []).map(sid => {
    const skill = SKILLS[sid];
    if (!skill) return '';
    const onCd = (hero.skillCooldowns?.[sid] || 0) > 0;
    const noRage = (hero.rage || 0) < (skill.cost || 0);
    const disabled = onCd || noRage;
    const cd = hero.skillCooldowns?.[sid] || 0;
    const isPending = pendingId === sid;
    return `
      <button class="skill-btn${isPending ? ' skill-pending' : ''}" ${disabled ? 'disabled' : ''} onclick="useSkill('${sid}')" title="${skill.name}：${skill.desc}">
        ${onCd ? `<div class="cd-overlay">${cd}</div>` : ''}
        <span>${skill.icon}</span>
        <span class="skill-name">${skill.name}</span>
        ${!onCd ? `<span style="font-size:8px;color:${noRage ? '#f55' : '#888'}">${hero.rage||0}/${skill.cost}怒</span>` : ''}
        ${isPending ? `<div class="pending-indicator">选目标</div>` : ''}
      </button>
    `;
  }).join('');

  if (pendingId) {
    html += `<button class="skill-btn cancel-skill-btn" onclick="cancelPendingSkill()" style="border-color:#e74c3c55;color:#e74c3c">
      <span>✕</span>
      <span class="skill-name">取消</span>
    </button>`;
  }

  bar.innerHTML = html;
}

function cancelPendingSkill() {
  if (!battle) return;
  battle.pendingSkillId = null;
  renderBattleUI();
  showToast('已取消技能选择');
}

function useSkill(skillId) {
  if (!battle || battle.isAnimating || battle.selectedPlayerIdx < 0) return;
  const hero  = battle.playerTeam[battle.selectedPlayerIdx];
  const skill = SKILLS[skillId];
  if (!hero || !skill) return;

  // 如果已在等待选目标，再次点相同技能则取消
  if (battle.pendingSkillId === skillId) {
    cancelPendingSkill();
    return;
  }

  const stun = hero.statusEffects?.find(e => e.id === 'stun' || e.id === 'freeze');
  if (stun) { showToast(`${hero.name} 处于${stun.name}状态，无法行动！`); return; }
  const silence = hero.statusEffects?.find(e => e.id === 'silence');
  if (silence) { showToast(`${hero.name} 被沉默，无法使用技能！`); return; }
  if ((hero.rage || 0) < (skill.cost || 0)) { showToast(`怒气不足！需要${skill.cost}怒气`); return; }
  if ((hero.skillCooldowns?.[skillId] || 0) > 0) { showToast('技能冷却中...'); return; }

  const isHeal = skill.type === 'heal' || skill.type === 'heal_single' || skill.type === 'buff' || skill.type === 'shield' || skill.type === 'shield_single';
  const isAoe  = skill.target === 'all_enemies' || skill.type === 'aoe' || skill.type === 'aoe_true';
  const isAllySkill = (skill.target === 'all_allies' && isHeal) || skill.target === 'strongest_ally';

  // 单体攻击技能：进入等待选目标模式，不立即执行，不扣费
  if (!isAoe && !isAllySkill && !isHeal) {
    battle.pendingSkillId = skillId;
    renderBattleUI(); // 高亮敌方可选目标
    showToast(`请选择目标释放【${skill.name}】`);
    return;
  }

  // 群体技能 / 治疗 / buff：立即执行，先扣费
  hero.rage -= skill.cost;
  if (!hero.skillCooldowns) hero.skillCooldowns = {};
  hero.skillCooldowns[skillId] = skill.cooldown;

  battle.isAnimating = true;
  const animEl = document.getElementById(`anim-p-${battle.selectedPlayerIdx}`);
  if (animEl) animEl.className = 'skeleton-anim skill';

  setTimeout(() => {
    if (isAoe) {
      battle.getLiveEnemyTeam().forEach(t => battle.executeAttack(hero, t, skill));
    } else if (skill.target === 'all_allies' && isHeal) {
      battle.getLivePlayerTeam().forEach(t => {
        if (skill.type === 'heal' || skill.type === 'heal_single') {
          const healAmt = Math.floor(hero.atk * (skill.baseDamage || 1));
          t.hp = Math.min(t.maxHp, t.hp + healAmt);
          battle.log.add(`💚 ${t.name} 恢复 ${healAmt} 点生命值`, 'heal');
        }
        if (skill.statusEffect && STATUS_EFFECTS[skill.statusEffect]) {
          const shieldVal = skill.shieldRatio ? Math.floor(hero.maxHp * skill.shieldRatio) : 0;
          applyStatusEffect(t, skill.statusEffect, shieldVal);
          battle.log.add(`🛡️ 为 ${t.name} 施加【${STATUS_EFFECTS[skill.statusEffect].name}】`, 'buff');
        }
      });
    } else if (skill.target === 'strongest_ally') {
      const strongest = battle.getLivePlayerTeam().reduce((a, b) => a.atk > b.atk ? a : b);
      const shieldVal = skill.shieldRatio ? Math.floor(hero.maxHp * skill.shieldRatio) : 0;
      applyStatusEffect(strongest, skill.statusEffect, shieldVal);
      battle.log.add(`✨ 为 ${strongest.name} 施加【${STATUS_EFFECTS[skill.statusEffect]?.name}】`, 'buff');
    }

    if (animEl) animEl.className = 'skeleton-anim idle';
    renderBattleUI();
    battle.isAnimating = false;
    if (!checkAndHandleBattleEnd()) {
      setTimeout(runEnemyTurn, 800);
    }
  }, 600);
}

function updateBattleButtons() {
  const btn = document.getElementById('btn-next-round');
  if (btn && battle) btn.disabled = battle.isAnimating;
}

function renderBattleLog() {
  const logArea = document.getElementById('battle-log');
  if (!logArea || !battle) return;
  logArea.innerHTML = battle.log.entries.slice(-30).reverse().map(e =>
    `<div class="log-entry ${e.type}">${e.icon ? e.icon + ' ' : ''}${e.text}</div>`
  ).join('');
}

// ============================================================
// ── 抽卡界面 ──
// ============================================================
function renderGachaPage() {
  const poolList = document.getElementById('pool-list');
  const mainArea = document.getElementById('gacha-main-area');
  if (!poolList || !GameState.gacha) return;

  poolList.innerHTML = CARD_POOLS.map((pool, i) => {
    const pulls = GameState.gacha.getPullsSinceOrange(pool.id);
    const pct   = Math.min(100, (pulls / 50 * 100));
    return `
      <div class="pool-card${i === 0 ? ' active' : ''}" onclick="selectPool('${pool.id}', this)">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px">
          <span style="font-size:20px">${pool.icon}</span>
          <span class="pool-name">${pool.name}</span>
        </div>
        <span class="pool-type-tag">${pool.type === 'standard' ? '常驻' : pool.type === 'up' ? '限时UP' : '特殊活动'}</span>
        <div class="pool-desc">${pool.desc}</div>
        <div class="pool-pity">
          <span>保底：${pulls}/50</span>
          <div class="pity-bar"><div class="pity-fill" style="width:${pct}%"></div></div>
        </div>
      </div>
    `;
  }).join('');

  renderGachaMainArea(CARD_POOLS[0]);
}

let currentPool = CARD_POOLS[0];

function selectPool(poolId, el) {
  currentPool = CARD_POOLS.find(p => p.id === poolId);
  document.querySelectorAll('.pool-card').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
  renderGachaMainArea(currentPool);
}

function renderGachaMainArea(pool) {
  const main = document.getElementById('gacha-main-area');
  if (!main) return;

  const upHeroesHtml = (pool.upHeroes || []).map(id => {
    const h = HERO_INDEX[id];
    if (!h) return '';
    const rarityInfo = RARITY[h.rarity?.toUpperCase()] || {};
    return `
      <div style="background:rgba(0,0,0,0.4);border:1px solid ${rarityInfo.color || '#888'}55;border-radius:8px;padding:8px 16px;text-align:center">
        <div style="font-size:28px">${h.portrait}</div>
        <div style="font-size:12px;color:${rarityInfo.color}">${h.name}</div>
        <div style="font-size:10px;color:#888">UP!</div>
      </div>
    `;
  }).join('');

  const cost1  = pool.costPremium  ? `${pool.costPremium}补天石` : '特殊货币';
  const cost10 = pool.costPremium  ? `10补天石(9折)` : '特殊货币×10';
  const cur = GameState.gacha.getCurrency();
  const pulls = GameState.gacha.getPullsSinceOrange(pool.id);

  main.innerHTML = `
    <div class="gacha-banner" style="background:linear-gradient(135deg, ${pool.banner}ee 0%, ${pool.banner}aa 100%)">
      <div class="banner-content">
        <div class="banner-title">${pool.name}</div>
        <div class="banner-subtitle">${pool.desc}</div>
        ${upHeroesHtml ? `<div class="banner-up-heroes">${upHeroesHtml}</div>` : ''}
      </div>
    </div>

    <div style="background:rgba(0,0,0,0.3);border:1px solid rgba(201,168,76,0.15);border-radius:8px;padding:12px 20px;display:flex;gap:30px;align-items:center">
      <div>
        <div style="font-size:11px;color:#666;letter-spacing:2px">已抽次数</div>
        <div style="font-size:22px;color:#f0d080;font-weight:700">${GameState.gacha.getPullCount(pool.id)}</div>
      </div>
      <div>
        <div style="font-size:11px;color:#666;letter-spacing:2px">距保底</div>
        <div style="font-size:22px;color:${50 - pulls < 10 ? '#e74c3c' : '#f0d080'};font-weight:700">${50 - pulls} 抽</div>
      </div>
      <div style="flex:1">
        <div style="font-size:11px;color:#666;margin-bottom:4px;letter-spacing:2px">橙卡保底进度</div>
        <div style="height:8px;background:rgba(255,255,255,0.1);border-radius:4px;overflow:hidden">
          <div style="height:100%;width:${Math.min(100, pulls / 50 * 100)}%;background:linear-gradient(90deg,#c9a84c,#f0d080);border-radius:4px;transition:width .3s"></div>
        </div>
      </div>
      <div style="margin-left:auto;font-size:12px;color:#666">
        💎 ${cur.lingshi} 灵石 · 🔮 ${cur.bututianshi} 补天石
      </div>
    </div>

    <div class="gacha-actions">
      <button class="btn-gacha single" onclick="doGacha('single')">
        单抽 × 1<span class="cost">${cost1}</span>
      </button>
      <button class="btn-gacha ten" onclick="doGacha('ten')">
        十连 × 10<span class="cost">${cost10}</span>
      </button>
    </div>

    <div style="background:rgba(0,0,0,0.25);border:1px solid rgba(255,255,255,0.05);border-radius:8px;padding:12px 16px">
      <div style="font-size:12px;color:#666;letter-spacing:3px;margin-bottom:8px">概率说明</div>
      <div style="display:flex;gap:16px;flex-wrap:wrap;font-size:12px">
        ${Object.entries(pool.rates || RARITY_RATES.standard).map(([r, p]) => {
          const info = RARITY[r.toUpperCase()];
          return info && p > 0 ? `<span style="color:${info.color}">${info.name} ${(p*100).toFixed(0)}%</span>` : '';
        }).join('')}
      </div>
      <div style="font-size:11px;color:#555;margin-top:6px">
        ✦ 50抽小保底必出橙卡 · 80抽大保底必出UP角色 · 每10连必含至少1张仙级或以上
      </div>
    </div>
  `;
}

function doGacha(type) {
  if (!GameState.gacha || !currentPool) return;

  let results;
  if (type === 'single') {
    const r = GameState.gacha.pullOnce(currentPool.id);
    if (!r) return;
    if (r.error) { showToast(r.error); return; }
    results = [r];
  } else {
    const r = GameState.gacha.pullTen(currentPool.id);
    if (!r) return;
    if (r.error) { showToast(r.error); return; }
    results = r;
  }

  showGachaResult(results);
  updateCurrencyDisplay();
  renderGachaMainArea(currentPool);
  // 任务事件
  onTaskEvent('gacha', type === 'ten' ? 10 : 1);
}

function showGachaResult(results) {
  const overlay = document.getElementById('gacha-result-overlay');
  if (!overlay) return;

  const cardsHtml = results.map((r, i) => {
    const hero = r.hero;
    if (!hero) return '';
    const rInfo = RARITY[r.rarity?.toUpperCase()] || { color: '#888', name: '凡' };
    return `
      <div class="result-card rarity-${r.rarity}" style="animation-delay:${i * 0.08}s">
        <div class="card-portrait" style="background:linear-gradient(180deg, ${ELEMENT_COLORS[hero.element]}33 0%, transparent 100%)">
          <span class="card-shine"></span>
          <span style="font-size:44px;position:relative;z-index:1">${hero.portrait}</span>
          ${r.isNew ? '<span class="new-badge">新</span>' : ''}
          <span class="card-rarity-badge" style="background:${rInfo.color}33;color:${rInfo.color};border:1px solid ${rInfo.color}55">${rInfo.name}</span>
        </div>
        <div class="card-name" style="color:${ELEMENT_COLORS[hero.element]}">
          ${hero.name}
          <div style="font-size:10px;color:#666;margin-top:2px">${ELEMENT_ICONS[hero.element]} ${ELEMENT_NAMES[hero.element]}系</div>
        </div>
      </div>
    `;
  }).join('');

  overlay.querySelector('#gacha-result-cards').innerHTML = cardsHtml;
  overlay.classList.add('show');
}

function closeGachaResult() {
  const overlay = document.getElementById('gacha-result-overlay');
  if (overlay) overlay.classList.remove('show');
}

// ============================================================
// ── 队伍编成 ──
// ============================================================

// 当前正在"选英雄"的槽位，-1 表示无选中状态
let teamSelectingSlot = -1;

function renderTeamPage() {
  teamSelectingSlot = -1; // 进页面时重置选中槽
  renderTeamSlots();
  renderHeroSelectList();
}

function openHeroSelect(slotIdx) {
  // 切换：再次点同一个空槽则取消
  teamSelectingSlot = (teamSelectingSlot === slotIdx) ? -1 : slotIdx;
  renderTeamSlots();
  renderHeroSelectList();
}

function renderTeamSlots() {
  const slotsEl = document.getElementById('team-slot-list');
  if (!slotsEl) return;

  slotsEl.innerHTML = GameState.selectedTeam.map((hero, i) => {
    if (!hero) {
      const isSelecting = (teamSelectingSlot === i);
      return `
        <div class="team-slot${isSelecting ? ' slot-selecting' : ''}" onclick="openHeroSelect(${i})" style="${isSelecting ? 'border-color:#c9a84c;background:rgba(201,168,76,0.12);' : ''}">
          <div class="slot-num" style="${isSelecting ? 'background:rgba(201,168,76,0.25);color:#c9a84c' : ''}">${i+1}</div>
          <div style="font-size:22px;color:${isSelecting ? '#c9a84c' : '#444'}">${isSelecting ? '✦' : '＋'}</div>
          <div style="color:${isSelecting ? '#c9a84c' : '#555'};font-size:12px">${isSelecting ? '选择英雄→' : '点击添加'}</div>
        </div>`;
    }
    const elColor = ELEMENT_COLORS[hero.element] || '#888';
    const isSelecting = (teamSelectingSlot === i);
    return `
      <div class="team-slot filled" style="border-color:${isSelecting ? '#c9a84c' : elColor+'55'};${isSelecting ? 'background:rgba(201,168,76,0.08)' : ''}">
        <div class="slot-num" style="background:${elColor}22;color:${elColor}">${i+1}</div>
        <div class="slot-emoji">${hero.portrait}</div>
        <div class="slot-info">
          <div class="slot-hero-name">${hero.name}</div>
          <div class="slot-hero-sub">
            <span style="color:${elColor}">${ELEMENT_ICONS[hero.element]}${ELEMENT_NAMES[hero.element]}</span>
            <span>Lv.${hero.level || 1}</span>
            <span>HP ${hero.maxHp}</span>
          </div>
        </div>
        <div onclick="openHeroSelect(${i})" style="font-size:12px;color:#888;cursor:pointer;padding:4px;border:1px solid #333;border-radius:4px;line-height:1.4" title="换人">换</div>
        <div onclick="removeFromTeam(${i})" style="font-size:18px;color:#444;cursor:pointer;padding:4px;margin-left:4px" title="移除">✕</div>
      </div>`;
  }).join('');

  // Combo提示
  const combos = checkCombos(GameState.selectedTeam.filter(Boolean));
  const comboEl = document.getElementById('team-combo-tips');
  if (comboEl) {
    if (combos.length > 0) {
      comboEl.innerHTML = combos.map(c =>
        `<div class="combo-tip">${c.icon} 【${c.name}】已激活：${c.desc}</div>`
      ).join('');
      comboEl.style.display = 'block';
    } else {
      comboEl.style.display = 'none';
    }
  }

  // 更新提示文字
  const hint = document.getElementById('team-page-hint');
  if (hint) {
    if (teamSelectingSlot >= 0) {
      hint.textContent = `▶ 请从右侧选择要放入第 ${teamSelectingSlot + 1} 槽的英雄`;
      hint.style.color = '#c9a84c';
    } else {
      hint.textContent = '点击空槽或已有英雄旁的「换」按钮可更换阵容';
      hint.style.color = '#666';
    }
  }

  // 动态阵容分析
  renderTeamSynergyTips();
}

// 动态阵容分析（编队页左下角）
function renderTeamSynergyTips() {
  const el = document.getElementById('team-synergy-tips');
  if (!el) return;

  const team = GameState.selectedTeam.filter(Boolean);
  if (team.length === 0) {
    el.innerHTML = `<div style="font-size:12px;color:#c9a84c;letter-spacing:2px;margin-bottom:8px">📋 阵容分析</div>
      <div style="font-size:11px;color:#555;line-height:2.0">请先添加英雄到队伍...</div>`;
    return;
  }

  const wuxingCycle = ['metal', 'wood', 'earth', 'water', 'fire'];
  const wuxingNames = { metal:'金', wood:'木', earth:'土', water:'水', fire:'火' };
  const tips = [];

  // 统计属性分布
  const elCount = {};
  team.forEach(h => { elCount[h.element] = (elCount[h.element] || 0) + 1; });
  const elements = Object.keys(elCount);

  // 判断是否有阴/阳/无极
  const hasYin  = elements.includes('yin');
  const hasYang = elements.includes('yang');
  const hasWuji = elements.includes('wuji');

  // 连携激活提示
  const activeCombos = checkCombos(team);
  activeCombos.forEach(c => {
    tips.push({ color:'#cc99ff', icon:'⚡', text:`已激活连携技【${c.name}】：${c.desc}` });
  });

  // 检查可激活但未激活的连携
  const teamIds = team.map(h => h.id);
  COMBOS.filter(c => !activeCombos.includes(c)).forEach(c => {
    const missing = c.requiredHeroes.filter(id => !teamIds.includes(id));
    if (missing.length === 1) {
      const missingHero = HERO_INDEX[missing[0]];
      if (missingHero) {
        tips.push({ color:'#e67e22', icon:'💡', text:`差 ${missingHero.name} 可激活【${c.name}】：${c.desc}` });
      }
    }
  });

  // 五行克制分析
  const wuxingTeam = team.filter(h => wuxingCycle.includes(h.element));
  const strengthSet = new Set(wuxingTeam.map(h => h.element));
  if (strengthSet.size > 0) {
    const counterTargets = [];
    const weaknesses = [];
    strengthSet.forEach(elKey => {
      const idx = wuxingCycle.indexOf(elKey);
      counterTargets.push(wuxingNames[wuxingCycle[(idx + 1) % 5]]);
      weaknesses.push(wuxingNames[wuxingCycle[(idx + 4) % 5]]);
    });
    tips.push({ color:'#2ecc71', icon:'✅', text:`你的队伍克制：${[...new Set(counterTargets)].join('、')}系敌人` });
    const weakList = [...new Set(weaknesses)].filter(w => !counterTargets.includes(w));
    if (weakList.length > 0) {
      tips.push({ color:'#e74c3c', icon:'⚠️', text:`注意：${weakList.join('、')}系强敌会克制你的阵容` });
    }
  }

  // 阴阳压制提示
  if (hasYin || hasYang) {
    tips.push({ color:'#f39c12', icon:'☯️', text:'队伍含阴/阳系，可对五行属性实施高维压制（+15%伤害+真实伤害）' });
  }
  if (hasWuji) {
    tips.push({ color:'#9b59b6', icon:'🌌', text:'队伍含无极系，该英雄无视一切属性克制，是全能核心输出' });
  }

  // 阵容均衡性建议
  const hasHealer = team.some(h => h.tags?.some(t => ['治疗', '支援', '复活'].includes(t)));
  const hasTank   = team.some(h => h.tags?.some(t => ['坦克', '坚韧'].includes(t)));
  const hasControl = team.some(h => h.tags?.some(t => ['控制', '诅咒', '冰冻'].includes(t)));
  const hasOutput  = team.some(h => h.tags?.some(t => ['爆发', '速攻', '暴击', '斩杀'].includes(t)));

  if (!hasHealer) tips.push({ color:'#888', icon:'💡', text:'建议加入神农/女娲/句芒等治疗英雄，提升持久战能力' });
  if (!hasTank && team.length >= 2) tips.push({ color:'#888', icon:'💡', text:'缺乏坦克，可考虑加入后土/共工/盘古保护后排' });
  if (!hasOutput) tips.push({ color:'#888', icon:'💡', text:'缺少爆发输出，可加入祝融/蓐收/东皇太一提升进攻节奏' });

  // 渲染
  el.innerHTML = `
    <div style="font-size:12px;color:#c9a84c;letter-spacing:2px;margin-bottom:8px">📋 阵容分析 <span style="font-size:10px;color:#555;font-weight:400">${team.length}/${GameState.teamSlots}人</span></div>
    ${tips.length === 0 ? `<div style="font-size:11px;color:#555">阵容暂无特别提示，搭配均衡。</div>` :
      tips.map(t => `<div style="font-size:11px;color:${t.color};line-height:1.9">${t.icon} ${t.text}</div>`).join('')
    }
  `;
}

function renderHeroSelectList() {
  const listEl = document.getElementById('hero-select-list');
  if (!listEl || !GameState.gacha) return;

  const inventory = GameState.gacha.getInventory();
  const teamIds   = GameState.selectedTeam.filter(Boolean).map(h => h.id);

  // 排序：未在队中的排前面
  const sorted = [...inventory].sort((a, b) => {
    const aInTeam = teamIds.includes(a.heroId) ? 1 : 0;
    const bInTeam = teamIds.includes(b.heroId) ? 1 : 0;
    return aInTeam - bInTeam;
  });

  listEl.innerHTML = sorted.map(item => {
    const hero = item.hero;
    if (!hero) return '';
    const inTeam   = teamIds.includes(hero.id);
    const rarInfo  = RARITY[hero.rarity?.toUpperCase()] || {};
    const elColor  = ELEMENT_COLORS[hero.element] || '#888';
    // 选择模式下突出可点击
    const isSelectMode = teamSelectingSlot >= 0;
    const cardExtra = inTeam ? ' in-team' : (isSelectMode ? ' hero-card-selectable' : '');
    return `
      <div class="hero-select-card${cardExtra}"
           onclick="addToTeam('${hero.id}')"
           style="${isSelectMode && !inTeam ? 'outline:1px solid rgba(201,168,76,0.5);' : ''}">
        <div class="portrait" style="filter:${inTeam ? 'brightness(0.6)' : 'none'}">${hero.portrait}</div>
        <div style="font-size:10px;color:${rarInfo.color || '#888'}">${rarInfo.name || ''}</div>
        <div class="hname">${hero.name}</div>
        <div class="hel" style="color:${elColor}">${ELEMENT_ICONS[hero.element] || ''} ${ELEMENT_NAMES[hero.element] || ''}</div>
        ${inTeam ? '<div style="font-size:9px;color:#c9a84c;margin-top:2px">已在队中</div>' : ''}
        ${item.quantity > 1 ? `<div style="font-size:9px;color:#666">×${item.quantity}</div>` : ''}
      </div>
    `;
  }).join('');
}

function addToTeam(heroId) {
  const teamIds = GameState.selectedTeam.filter(Boolean).map(h => h.id);
  const inTeam = teamIds.includes(heroId);

  // 如果已在队中且不在换人模式，提示
  if (inTeam && teamSelectingSlot < 0) {
    showToast('该英雄已在队中，点击槽位旁「换」按钮可替换');
    return;
  }

  // 确定要填入的槽位
  let targetSlot = teamSelectingSlot;
  if (targetSlot < 0) {
    // 没有主动选槽：找第一个空槽
    targetSlot = GameState.selectedTeam.findIndex(h => !h);
    if (targetSlot === -1) {
      showToast(`队伍已满（最多${GameState.teamSlots}人），请先点击「换」替换英雄`);
      return;
    }
  }

  // 若目标槽已有英雄且该英雄与要放入的是同一个，取消
  const existingHero = GameState.selectedTeam[targetSlot];
  if (existingHero && existingHero.id === heroId) {
    teamSelectingSlot = -1;
    renderTeamSlots();
    renderHeroSelectList();
    return;
  }

  // 若要放入的英雄已在其他槽，先移除
  const existingIdx = GameState.selectedTeam.findIndex(h => h && h.id === heroId);
  if (existingIdx >= 0 && existingIdx !== targetSlot) {
    GameState.selectedTeam[existingIdx] = null;
  }

  // 从存档读取实际养成等级，而非硬编码
  const training = SaveSystem.getHeroTraining(heroId);
  GameState.selectedTeam[targetSlot] = createHeroInstance(heroId, training.level, training.starLevel);
  teamSelectingSlot = -1; // 填入后自动退出选择模式

  // 立即持久化存档
  SaveSystem.saveTeam(GameState.selectedTeam.map(h => h?.id || null));

  renderTeamSlots();
  renderHeroSelectList();
  showToast(`${GameState.selectedTeam[targetSlot].name} 加入第 ${targetSlot + 1} 槽`);
  // 检查满员成就
  checkTeamFullAchievement();
}

function removeFromTeam(idx) {
  const hero = GameState.selectedTeam[idx];
  GameState.selectedTeam[idx] = null;
  teamSelectingSlot = -1;

  // 立即持久化存档
  SaveSystem.saveTeam(GameState.selectedTeam.map(h => h?.id || null));

  renderTeamSlots();
  renderHeroSelectList();
  if (hero) showToast(`${hero.name} 已移出队伍`);
}

// ============================================================
// ── 图鉴界面 ──
// ============================================================
function renderCodexPage() {
  const grid = document.getElementById('codex-grid');
  if (!grid || !GameState.gacha) return;

  const filter = GameState.codexFilter;
  const inventory = GameState.gacha.getInventory();
  const ownedIds  = new Set(inventory.map(i => i.heroId));

  const filtered = HEROES.filter(h => {
    if (filter === 'all') return true;
    if (filter === 'owned') return ownedIds.has(h.id);
    return h.element === filter;
  });

  grid.innerHTML = filtered.map(hero => {
    const owned  = ownedIds.has(hero.id);
    const rInfo  = RARITY[hero.rarity?.toUpperCase()] || {};
    const elColor = ELEMENT_COLORS[hero.element] || '#888';
    return `
      <div class="codex-card${!owned ? ' locked' : ''} rarity-${hero.rarity}" onclick="showHeroDetail('${hero.id}')">
        <div class="codex-card-portrait" style="background:linear-gradient(180deg,${elColor}22 0%,transparent 100%)">
          <span style="font-size:52px">${hero.portrait}</span>
        </div>
        <div class="codex-card-info">
          <div class="codex-hero-name" style="color:${rInfo.color || '#ccc'}">${hero.name}</div>
          <div class="codex-hero-title">${hero.title || ''}</div>
          <div class="codex-rarity-stars" style="color:${rInfo.color}">${'★'.repeat(rInfo.stars || 1)}</div>
        </div>
      </div>
    `;
  }).join('');
}

function setCodexFilter(filter) {
  GameState.codexFilter = filter;
  document.querySelectorAll('.filter-btn').forEach(b => {
    b.classList.toggle('active', b.dataset.filter === filter);
  });
  renderCodexPage();
}

function showHeroDetail(heroId) {
  const hero = HERO_INDEX[heroId];
  if (!hero) return;
  const overlay = document.getElementById('hero-detail-overlay');
  const panel   = document.getElementById('hero-detail-panel');
  if (!overlay || !panel) return;

  const rInfo   = RARITY[hero.rarity?.toUpperCase()] || {};
  const elColor = ELEMENT_COLORS[hero.element] || '#888';
  const elName  = ELEMENT_NAMES[hero.element] || '';
  const skills  = getHeroSkills(heroId);

  // ---- 搭配建议生成 ----
  const synergySuggestions = getHeroSynergySuggestions(hero);

  panel.innerHTML = `
    <button class="detail-close" onclick="closeHeroDetail()">✕</button>

    <!-- 英雄头部 -->
    <div style="display:flex;gap:20px;align-items:flex-start;margin-bottom:20px">
      <div style="width:110px;height:130px;background:linear-gradient(135deg,${elColor}33,${elColor}11);border:2px solid ${elColor}66;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:60px;flex-shrink:0;box-shadow:0 0 18px ${elColor}44">
        ${hero.portrait}
      </div>
      <div style="flex:1;min-width:0">
        <div style="font-size:22px;font-weight:900;color:${rInfo.color || '#ccc'};letter-spacing:2px">${hero.name}</div>
        <div style="font-size:13px;color:#888;margin:3px 0 8px">${hero.title || ''}</div>
        <div style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:10px">
          <span class="tag" style="color:${elColor};border-color:${elColor}55;background:${elColor}11">${ELEMENT_ICONS[hero.element] || ''} ${elName}系</span>
          <span class="tag" style="color:${rInfo.color};border-color:${rInfo.color}55;background:${rInfo.color}11">${rInfo.name}品${'★'.repeat(rInfo.stars || 1)}</span>
          ${(hero.tags || []).map(t => `<span class="tag" style="color:#888;border-color:#33333388">${t}</span>`).join('')}
        </div>
        <div style="font-size:11px;color:#666;line-height:1.7">${hero.lore || ''}</div>
      </div>
    </div>

    <!-- 基础属性 -->
    <div class="section-title" style="margin-bottom:10px">⚔ 基础属性</div>
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:16px">
      ${[
        ['💚 生命',   hero.baseStats.hp,                    '#27ae60'],
        ['⚔️ 攻击',   hero.baseStats.atk,                   '#e74c3c'],
        ['🛡️ 防御',   hero.baseStats.def,                   '#3498db'],
        ['⚡ 速度',   hero.baseStats.spd,                   '#f39c12'],
        ['🎯 暴击率', (hero.baseStats.critRate * 100).toFixed(0) + '%', '#e67e22'],
        ['💥 暴击伤', (hero.baseStats.critDmg * 100).toFixed(0) + '%', '#c0392b'],
      ].map(([name, val, color]) => `
        <div style="background:rgba(0,0,0,0.45);border:1px solid ${color}33;border-radius:8px;padding:8px 10px;display:flex;justify-content:space-between;align-items:center">
          <span style="font-size:10px;color:#666">${name}</span>
          <span style="font-size:15px;font-weight:700;color:${color}">${val}</span>
        </div>
      `).join('')}
    </div>

    <!-- 技能 -->
    <div class="section-title" style="margin-bottom:10px">✦ 技能</div>
    <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:16px">
      ${skills.map(skill => `
        <div style="background:rgba(0,0,0,0.4);border:1px solid ${skill.color || '#333'}44;border-radius:8px;padding:10px 12px">
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px">
            <span style="font-size:18px">${skill.icon}</span>
            <span style="font-size:14px;color:${skill.color || '#ccc'};font-weight:700">${skill.name}</span>
            <span style="font-size:10px;color:#555;margin-left:auto;white-space:nowrap">冷却 ${skill.cooldown}回合 · ${skill.cost}怒</span>
          </div>
          <div style="font-size:11px;color:#aaa;line-height:1.6">${skill.desc}</div>
        </div>
      `).join('')}
    </div>

    <!-- 被动 -->
    <div class="section-title" style="margin-bottom:10px">☯ 被动</div>
    <div style="background:rgba(155,89,182,0.1);border:1px solid rgba(155,89,182,0.3);border-radius:8px;padding:10px 12px;font-size:11px;color:#cc99ff;line-height:1.7;margin-bottom:16px">
      ${hero.passiveDesc || '暂无被动'}
    </div>

    <!-- 搭配建议 -->
    <div class="section-title" style="margin-bottom:10px">🧩 搭配建议</div>
    <div style="display:flex;flex-direction:column;gap:8px">
      <!-- 属性克制 -->
      <div style="background:rgba(0,0,0,0.35);border:1px solid rgba(255,255,255,0.06);border-radius:8px;padding:10px 12px">
        <div style="font-size:11px;color:#888;margin-bottom:8px;letter-spacing:1px">⚔ 属性克制关系</div>
        <div style="display:flex;flex-direction:column;gap:5px">
          ${synergySuggestions.elementTips.map(tip => `
            <div style="font-size:11px;color:${tip.color};line-height:1.5">${tip.icon} ${tip.text}</div>
          `).join('')}
        </div>
      </div>
      <!-- 推荐搭档 -->
      <div style="background:rgba(0,0,0,0.35);border:1px solid rgba(201,168,76,0.15);border-radius:8px;padding:10px 12px">
        <div style="font-size:11px;color:#888;margin-bottom:8px;letter-spacing:1px">✦ 推荐搭档</div>
        <div style="display:flex;flex-direction:column;gap:5px">
          ${synergySuggestions.partners.map(p => `
            <div style="display:flex;align-items:center;gap:8px">
              <span style="font-size:18px">${p.portrait}</span>
              <div>
                <span style="font-size:12px;color:${p.color};font-weight:700">${p.name}</span>
                <span style="font-size:10px;color:#666"> · ${p.reason}</span>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
      <!-- 连携技 -->
      ${synergySuggestions.combos.length > 0 ? `
      <div style="background:rgba(155,89,182,0.08);border:1px solid rgba(155,89,182,0.25);border-radius:8px;padding:10px 12px">
        <div style="font-size:11px;color:#888;margin-bottom:8px;letter-spacing:1px">⚡ 可激活连携技</div>
        ${synergySuggestions.combos.map(c => `
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px">
            <span style="font-size:16px">${c.icon}</span>
            <div>
              <span style="font-size:12px;color:#cc99ff;font-weight:700">【${c.name}】</span>
              <span style="font-size:10px;color:#666"> 需要：${c.partners}</span>
            </div>
          </div>
          <div style="font-size:10px;color:#9b59b6;margin-left:24px;margin-bottom:2px">${c.desc}</div>
        `).join('')}
      </div>` : ''}
      <!-- 定位建议 -->
      <div style="background:rgba(0,0,0,0.3);border:1px solid rgba(255,255,255,0.06);border-radius:8px;padding:10px 12px">
        <div style="font-size:11px;color:#888;margin-bottom:6px;letter-spacing:1px">📋 使用建议</div>
        <div style="font-size:11px;color:#aaa;line-height:1.8">${synergySuggestions.usageTip}</div>
      </div>
    </div>
  `;

  overlay.classList.add('show');
}

// 生成英雄搭配建议
function getHeroSynergySuggestions(hero) {
  const el = hero.element;

  // ── 属性克制提示 ──
  // 五行循环：金→木→土→水→火→金
  const wuxingCycle = ['metal', 'wood', 'earth', 'water', 'fire'];
  const wuxingNames = { metal:'金', wood:'木', earth:'土', water:'水', fire:'火' };
  const elementTips = [];

  if (el === 'wuji') {
    elementTips.push({ icon: '🌌', color: '#9b59b6', text: '无极属性无视一切克制，攻击必然命中，是最顶级的输出属性。' });
  } else if (el === 'yin') {
    elementTips.push({ icon: '🌑', color: '#8e44ad', text: '阴克阳（+30%伤害），对阳系敌人有压制，并可概率沉默。' });
    elementTips.push({ icon: '⚠️', color: '#e67e22', text: '阴/阳属性被五行低维克制（受伤-15%），但仍可高维压制五行（+15%）。' });
  } else if (el === 'yang') {
    elementTips.push({ icon: '☀️', color: '#f39c12', text: '阳克阴（+30%伤害），对阴系敌人有眩晕效果。' });
    elementTips.push({ icon: '🏆', color: '#e67e22', text: '阳系高维压制五行所有属性（+15%伤害+真实伤害），全面碾压五行。' });
  } else {
    const idx = wuxingCycle.indexOf(el);
    const counterTarget = wuxingCycle[(idx + 1) % 5]; // 我克
    const weakTarget    = wuxingCycle[(idx + 4) % 5]; // 克我
    elementTips.push({ icon: '✅', color: '#2ecc71', text: `${wuxingNames[el]}克${wuxingNames[counterTarget]}（+25%伤害），优先对阵${wuxingNames[counterTarget]}系敌人。` });
    elementTips.push({ icon: '❌', color: '#e74c3c', text: `${wuxingNames[weakTarget]}克${wuxingNames[el]}（受伤+25%），避免正面对抗${wuxingNames[weakTarget]}系强敌。` });
    elementTips.push({ icon: '⚡', color: '#9b59b6', text: `遇到阴/阳属性时伤害-15%且无法暴击，需搭配阴/阳系英雄牵制。` });
  }

  // ── 推荐搭档 ──
  // 规则：治疗英雄适合所有输出；控制英雄 + 输出是好搭档；阴阳互补；连携伙伴最优先
  const partners = [];
  const allHeroes = HEROES;

  // 寻找连携搭档
  for (const combo of COMBOS) {
    if (combo.requiredHeroes.includes(hero.id)) {
      const allies = combo.requiredHeroes.filter(id => id !== hero.id);
      allies.forEach(allyId => {
        const allyHero = HERO_INDEX[allyId];
        if (allyHero) {
          partners.push({
            portrait: allyHero.portrait,
            name: allyHero.name,
            color: ELEMENT_COLORS[allyHero.element] || '#ccc',
            reason: `可触发连携技【${combo.name}】：${combo.desc}`
          });
        }
      });
    }
  }

  // 补充推荐：治疗系（如果当前英雄是输出/坦克）
  const outputTags = ['爆发', '速攻', '暴击', '单体', '斩杀', '火神', '金神', '水神'];
  const isOutput = hero.tags?.some(t => outputTags.includes(t));
  const isTank   = hero.tags?.some(t => ['坦克', '坚韧'].includes(t));
  const isHealer = hero.tags?.some(t => ['治疗', '复活', '支援'].includes(t));

  if (!isHealer && partners.length < 3) {
    const healers = allHeroes.filter(h => h.tags?.some(t => ['治疗', '支援', '复活'].includes(t)) && h.id !== hero.id);
    healers.slice(0, 1).forEach(h => {
      if (!partners.find(p => p.name === h.name)) {
        partners.push({
          portrait: h.portrait,
          name: h.name,
          color: ELEMENT_COLORS[h.element] || '#ccc',
          reason: '提供持续治疗或复活，保证阵容续航'
        });
      }
    });
  }

  // 推荐阴阳互补（五行英雄推荐阴/阳）
  if (['metal','wood','earth','water','fire'].includes(el) && partners.length < 3) {
    const yinYang = allHeroes.filter(h => (h.element === 'yin' || h.element === 'yang') && h.id !== hero.id);
    yinYang.slice(0, 1).forEach(h => {
      if (!partners.find(p => p.name === h.name)) {
        partners.push({
          portrait: h.portrait,
          name: h.name,
          color: ELEMENT_COLORS[h.element] || '#ccc',
          reason: `${ELEMENT_NAMES[h.element]}系高维压制五行，补强全队输出`
        });
      }
    });
  }

  // 推荐控制英雄（如果当前是高输出）
  if (isOutput && partners.length < 3) {
    const controllers = allHeroes.filter(h =>
      h.tags?.some(t => ['控制', '诅咒', '冰冻', '失忆'].includes(t)) && h.id !== hero.id
    );
    controllers.slice(0, 1).forEach(h => {
      if (!partners.find(p => p.name === h.name)) {
        partners.push({
          portrait: h.portrait,
          name: h.name,
          color: ELEMENT_COLORS[h.element] || '#ccc',
          reason: '控制敌方行动，为输出创造安全空间'
        });
      }
    });
  }

  // 推荐坦克（如果当前是脆皮输出）
  if (isOutput && !isTank && partners.length < 3) {
    const tanks = allHeroes.filter(h =>
      h.tags?.some(t => ['坦克', '坚韧', '护盾'].includes(t)) && h.id !== hero.id
    );
    tanks.slice(0, 1).forEach(h => {
      if (!partners.find(p => p.name === h.name)) {
        partners.push({
          portrait: h.portrait,
          name: h.name,
          color: ELEMENT_COLORS[h.element] || '#ccc',
          reason: '前排肉盾，为后排输出提供保护'
        });
      }
    });
  }

  // ── 可激活的连携技 ──
  const comboTips = COMBOS
    .filter(c => c.requiredHeroes.includes(hero.id))
    .map(c => {
      const partnerIds = c.requiredHeroes.filter(id => id !== hero.id);
      const partnerNames = partnerIds.map(id => HERO_INDEX[id]?.name || id).join(' + ');
      return {
        icon: c.icon,
        name: c.name,
        desc: c.desc,
        partners: partnerNames
      };
    });

  // ── 使用建议 ──
  let usageTip = '';
  if (el === 'wuji') {
    usageTip = `${hero.name}属无极系，技能无视属性克制，适合放在任意阵容中担当核心输出。建议搭配治疗英雄保证其存活。`;
  } else if (isHealer) {
    usageTip = `${hero.name}是优秀的支援角色，建议放在后排，搭配高攻击或高防御的前排英雄，让其专注治疗续航。`;
  } else if (isTank) {
    usageTip = `${hero.name}拥有超高生命值和防御力，是理想的前排肉盾。搭配高输出英雄可以做到"前排抗伤+后排爆发"。`;
  } else if (isOutput) {
    const idx = wuxingCycle.indexOf(el);
    const target = idx >= 0 ? wuxingNames[wuxingCycle[(idx + 1) % 5]] : '';
    usageTip = `${hero.name}定位输出${target ? `，专克${target}系敌人` : ''}。建议配置一名治疗和一名坦克/控制，打出稳定的"铁三角"阵容。`;
  } else {
    usageTip = `${hero.name}兼具控制与辅助能力，可以灵活搭配各类阵容。发挥其属性克制优势，针对性组队效果更佳。`;
  }

  return { elementTips, partners: partners.slice(0, 3), combos: comboTips, usageTip };
}

function closeHeroDetail() {
  document.getElementById('hero-detail-overlay')?.classList.remove('show');
}

// ============================================================
// ── 初始化 ──
// ============================================================
function initGame() {
  // 初始化抽卡系统
  GameState.gacha = new GachaSystem();

  // 检查是否首次进入
  if (SaveSystem.isFirstTime()) {
    showCreatePlayerOverlay();
    return;
  }

  // 读取存档
  const save = SaveSystem.load();

  // 把存档数据同步回 GachaSystem
  if (save) {
    GameState.gacha.state.inventory  = save.inventory;
    GameState.gacha.state.poolState  = save.gachaState;
    GameState.gacha.state.currency.lingshi      = save.currency.lingshi;
    GameState.gacha.state.currency.bututianshi  = save.currency.bututianshi;
    GameState.gacha.state.currency.hundunJing   = save.currency.hundunJing;
  }

  // 初始化队伍（从存档恢复，或取前3个）
  GameState.selectedTeam = new Array(GameState.teamSlots).fill(null);
  const teamCfg = save?.teamConfig || [];
  const inv     = GameState.gacha.getInventory();
  const ownedIds = inv.map(i => i.heroId);

  teamCfg.forEach((heroId, i) => {
    if (heroId && ownedIds.includes(heroId)) {
      const training = SaveSystem.getHeroTraining(heroId);
      GameState.selectedTeam[i] = createHeroInstance(heroId, training.level, training.starLevel);
    }
  });

  // 如果存档队伍为空，默认取前3个
  if (!GameState.selectedTeam.filter(Boolean).length) {
    inv.slice(0, 3).forEach((item, i) => {
      const training = SaveSystem.getHeroTraining(item.heroId);
      GameState.selectedTeam[i] = createHeroInstance(item.heroId, training.level, training.starLevel);
    });
  }

  updateCurrencyDisplay();
  refreshHomePlayerInfo();

  // 绑定导航
  document.querySelectorAll('.nav-tab').forEach(tab => {
    tab.addEventListener('click', () => navigateTo(tab.dataset.page));
  });
}

// ============================================================
// ── 首次创角色 ──
// ============================================================
let selectedGender = 'male';
let selectedTitleId = 'unnamed';

function showCreatePlayerOverlay() {
  const overlay = document.getElementById('create-player-overlay');
  if (!overlay) return;
  overlay.style.display = 'flex';

  // 渲染称号选择
  const grid = document.getElementById('title-select-grid');
  if (grid) {
    grid.innerHTML = PLAYER_TITLES.map((t, i) => `
      <div class="title-option${i === 0 ? ' active' : ''}" id="title-${t.id}"
        onclick="selectTitle('${t.id}')"
        style="border:1px solid rgba(201,168,76,${i===0?'0.5':'0.15'});border-radius:8px;padding:8px;text-align:center;cursor:pointer;background:rgba(201,168,76,${i===0?'0.12':'0.02'});transition:all 0.2s">
        <div style="font-size:12px;color:${i===0?'#c9a84c':'#777'};font-weight:700">${t.name}</div>
        <div style="font-size:9px;color:#555;margin-top:2px">${t.desc}</div>
      </div>
    `).join('');
  }

  // 绑导航（防止未绑定时进来）
  document.querySelectorAll('.nav-tab').forEach(tab => {
    tab.addEventListener('click', () => navigateTo(tab.dataset.page));
  });
}

function validatePlayerName(input) {
  const hint = document.getElementById('name-hint');
  const len = input.value.length;
  if (len === 0) {
    hint.textContent = '2~8个字符，中文英文均可';
    hint.style.color = '#555';
  } else if (len < 2) {
    hint.textContent = '名字至少需要2个字符';
    hint.style.color = '#e74c3c';
  } else {
    hint.textContent = `✓ ${len}/8`;
    hint.style.color = '#2ecc71';
  }
}

function selectGender(gender) {
  selectedGender = gender;
  document.getElementById('gender-male').style.background   = gender === 'male'   ? 'rgba(201,168,76,0.15)'   : 'rgba(0,0,0,0.2)';
  document.getElementById('gender-male').style.borderColor  = gender === 'male'   ? 'rgba(201,168,76,0.6)'    : 'rgba(201,168,76,0.2)';
  document.getElementById('gender-female').style.background = gender === 'female' ? 'rgba(155,89,182,0.15)'   : 'rgba(0,0,0,0.2)';
  document.getElementById('gender-female').style.borderColor= gender === 'female' ? 'rgba(155,89,182,0.6)'    : 'rgba(100,80,150,0.2)';
}

function selectTitle(titleId) {
  selectedTitleId = titleId;
  document.querySelectorAll('.title-option').forEach(el => {
    const isActive = el.id === 'title-' + titleId;
    el.style.background   = isActive ? 'rgba(201,168,76,0.12)' : 'rgba(201,168,76,0.02)';
    el.style.borderColor  = isActive ? 'rgba(201,168,76,0.5)'  : 'rgba(201,168,76,0.15)';
    el.querySelector('div').style.color = isActive ? '#c9a84c' : '#777';
  });
}

function confirmCreatePlayer() {
  const nameInput = document.getElementById('input-player-name');
  const name = nameInput?.value?.trim() || '';
  if (name.length < 2) {
    showToast('请输入至少2个字符的名字');
    nameInput?.focus();
    return;
  }

  // 创建存档
  const save = SaveSystem.createNewSave(name, selectedGender, selectedTitleId);

  // 把默认背包同步到 GachaSystem
  GameState.gacha.state.inventory = save.inventory;

  // 初始化队伍
  GameState.selectedTeam = new Array(GameState.teamSlots).fill(null);
  save.inventory.slice(0, 3).forEach((item, i) => {
    GameState.selectedTeam[i] = createHeroInstance(item.heroId, 1, 1);
  });

  // 隐藏弹窗，播放开场动画
  const overlay = document.getElementById('create-player-overlay');
  if (overlay) {
    overlay.style.transition = 'opacity 0.8s';
    overlay.style.opacity = '0';
    setTimeout(() => { overlay.style.display = 'none'; }, 800);
  }

  updateCurrencyDisplay();
  refreshHomePlayerInfo();
  showToast(`欢迎踏入洪荒，${name}！愿执命人一路长歌！`, 3500);
}

// ============================================================
// ── 主界面玩家信息 ──
// ============================================================
function refreshHomePlayerInfo() {
  const save = SaveSystem.get();
  if (!save) return;
  const p = save.player;

  const nameEl  = document.getElementById('player-name-display');
  const titleEl = document.getElementById('player-title-display');
  const lvEl    = document.getElementById('player-level-display');
  const expBar  = document.getElementById('player-exp-bar');
  const expText = document.getElementById('player-exp-text');
  const avatar  = document.getElementById('player-avatar');

  if (nameEl)  nameEl.textContent  = p.name  || '执命人';
  if (titleEl) titleEl.textContent = p.title || '无名执命人';
  if (lvEl)    lvEl.textContent    = 'Lv.' + (p.level || 1);
  if (avatar)  avatar.textContent  = p.gender === 'female' ? '🌙' : '⚔️';

  const pct = Math.min(100, Math.floor((p.exp / p.expToNext) * 100));
  if (expBar)  expBar.style.width  = pct + '%';
  if (expText) expText.textContent = `${p.exp} / ${p.expToNext}`;
}

// 战斗胜利后保存队伍并给玩家加经验
function onBattleWin() {
  // 保存当前队伍配置
  const teamIds = GameState.selectedTeam.map(h => h?.id || null);
  SaveSystem.saveTeam(teamIds);

  // 玩家获得经验
  const newPlayer = SaveSystem.addPlayerExp(50);
  refreshHomePlayerInfo();
  showToast(`战斗胜利！获得 50 执命经验（Lv.${newPlayer.level}）`, 2500);

  // 任务事件
  onTaskEvent('battle');
  onTaskEvent('win');
}

// ============================================================
// ── 任务系统 ──
// ============================================================

// 任务定义
const TASK_LIST = {
  daily: [
    {
      id: 'daily_battle_1', name: '初出茅庐', icon: '⚔️',
      desc: '完成1场战斗（胜负不限）', type: 'battle', target: 1,
      rewards: [{ type: 'cultivateSoul', amount: 100 }, { type: 'lingshi', amount: 50 }]
    },
    {
      id: 'daily_battle_3', name: '身经百战', icon: '🗡️',
      desc: '完成3场战斗（胜负不限）', type: 'battle', target: 3,
      rewards: [{ type: 'cultivateSoul', amount: 300 }, { type: 'lingshi', amount: 150 }]
    },
    {
      id: 'daily_win_1', name: '旗开得胜', icon: '🏆',
      desc: '赢得1场战斗', type: 'win', target: 1,
      rewards: [{ type: 'cultivateSoul', amount: 200 }, { type: 'lingshi', amount: 100 }]
    },
    {
      id: 'daily_gacha_1', name: '签语求道', icon: '🎴',
      desc: '进行1次神殿抽签', type: 'gacha', target: 1,
      rewards: [{ type: 'cultivateSoul', amount: 150 }, { type: 'lingshi', amount: 80 }]
    },
    {
      id: 'daily_cultivate_1', name: '勤修苦炼', icon: '✨',
      desc: '对任意英雄进行1次修炼升级', type: 'cultivate', target: 1,
      rewards: [{ type: 'cultivateSoul', amount: 200 }, { type: 'lingshi', amount: 60 }]
    },
    {
      id: 'daily_login', name: '每日登临', icon: '🌅',
      desc: '每日登入游戏', type: 'login', target: 1,
      rewards: [{ type: 'cultivateSoul', amount: 80 }, { type: 'lingshi', amount: 30 }]
    },
  ],
  weekly: [
    {
      id: 'weekly_battle_10', name: '铁甲雄师', icon: '🛡️',
      desc: '本周内完成10场战斗', type: 'battle', target: 10,
      rewards: [{ type: 'cultivateSoul', amount: 1000 }, { type: 'lingshi', amount: 500 }, { type: 'bututianshi', amount: 3 }]
    },
    {
      id: 'weekly_win_5', name: '连战连胜', icon: '🏅',
      desc: '本周内赢得5场战斗', type: 'win', target: 5,
      rewards: [{ type: 'cultivateSoul', amount: 1500 }, { type: 'lingshi', amount: 800 }, { type: 'bututianshi', amount: 5 }]
    },
    {
      id: 'weekly_gacha_5', name: '广结善缘', icon: '🌟',
      desc: '本周内进行5次神殿抽签', type: 'gacha', target: 5,
      rewards: [{ type: 'cultivateSoul', amount: 800 }, { type: 'lingshi', amount: 400 }, { type: 'bututianshi', amount: 2 }]
    },
    {
      id: 'weekly_cultivate_5', name: '道心精进', icon: '🔥',
      desc: '本周内进行5次修炼升级', type: 'cultivate', target: 5,
      rewards: [{ type: 'cultivateSoul', amount: 1200 }, { type: 'lingshi', amount: 600 }]
    },
  ],
  achievement: [
    {
      id: 'ach_first_win', name: '初战告捷', icon: '🥇',
      desc: '赢得人生第一场战斗', type: 'win_total', target: 1,
      rewards: [{ type: 'cultivateSoul', amount: 500 }, { type: 'bututianshi', amount: 5 }]
    },
    {
      id: 'ach_win_10', name: '百胜将军', icon: '👑',
      desc: '累计赢得10场战斗', type: 'win_total', target: 10,
      rewards: [{ type: 'cultivateSoul', amount: 2000 }, { type: 'bututianshi', amount: 10 }, { type: 'lingshi', amount: 1000 }]
    },
    {
      id: 'ach_gacha_10', name: '签运亨通', icon: '🎊',
      desc: '累计抽签10次', type: 'gacha_total', target: 10,
      rewards: [{ type: 'cultivateSoul', amount: 800 }, { type: 'bututianshi', amount: 5 }]
    },
    {
      id: 'ach_team_full', name: '五虎齐聚', icon: '👥',
      desc: '组建满员5人队伍', type: 'team_full', target: 5,
      rewards: [{ type: 'cultivateSoul', amount: 600 }, { type: 'lingshi', amount: 300 }]
    },
  ]
};

// 游戏内任务进度计数器（内存，不存盘，每次开局重新累计）
const TaskProgress = {
  battleCount: 0,
  winCount: 0,
  gachaCount: 0,
  cultivateCount: 0,
};

// 累计数据从存档读
function getAchievementProgress(type) {
  const save = SaveSystem.get();
  return save?.taskTotals?.[type] || 0;
}

function incrementTotal(type, amount = 1) {
  const data = SaveSystem.get();
  if (!data.taskTotals) data.taskTotals = {};
  data.taskTotals[type] = (data.taskTotals[type] || 0) + amount;
  SaveSystem.save(data);
  return data.taskTotals[type];
}

// 触发任务进度更新（在游戏各处调用）
function onTaskEvent(eventType, amount = 1) {
  const tasks = SaveSystem.getTasksData();
  const save = SaveSystem.get();

  // 更新内存计数
  if (eventType === 'battle') TaskProgress.battleCount += amount;
  if (eventType === 'win')    TaskProgress.winCount    += amount;
  if (eventType === 'gacha')  TaskProgress.gachaCount  += amount;
  if (eventType === 'cultivate') TaskProgress.cultivateCount += amount;

  // 同步到每日/每周任务进度
  ['daily', 'weekly'].forEach(tType => {
    const taskDefs = TASK_LIST[tType].filter(t => t.type === eventType);
    taskDefs.forEach(taskDef => {
      const cur = tasks[tType][taskDef.id] || { completed: false, claimed: false, progress: 0 };
      if (cur.completed) return;
      const newProgress = tType === 'daily' ? TaskProgress[eventType + 'Count'] : (tasks[tType][taskDef.id]?.progress || 0) + amount;
      SaveSystem.updateTaskProgress(tType, taskDef.id, newProgress);
      if (newProgress >= taskDef.target) {
        SaveSystem.completeTask(tType, taskDef.id);
        showToast(`📋 任务完成：${taskDef.name}，可前往任务界面领取奖励！`, 3000);
      }
    });
  });

  // 成就：累计数据
  const totalKey = eventType + '_total';
  const newTotal = incrementTotal(eventType + 'Total', amount);
  const achDefs = TASK_LIST.achievement.filter(t => t.type === totalKey);
  achDefs.forEach(taskDef => {
    const cur = tasks.achievement?.[taskDef.id] || { completed: false, claimed: false, progress: 0 };
    if (cur.completed) return;
    SaveSystem.updateTaskProgress('achievement', taskDef.id, newTotal);
    if (newTotal >= taskDef.target) {
      SaveSystem.completeTask('achievement', taskDef.id);
      showToast(`🏆 成就解锁：${taskDef.name}！`, 3000);
    }
  });

  // 登录任务：在showTaskPanel时自动完成
}

// 检查并完成"组队满员"成就
function checkTeamFullAchievement() {
  const fullTeam = GameState.selectedTeam.filter(Boolean).length;
  if (fullTeam >= 5) {
    const tasks = SaveSystem.getTasksData();
    const cur = tasks.achievement?.['ach_team_full'];
    if (!cur?.completed) {
      SaveSystem.updateTaskProgress('achievement', 'ach_team_full', fullTeam);
      SaveSystem.completeTask('achievement', 'ach_team_full');
      showToast('🏆 成就解锁：五虎齐聚！', 3000);
    }
  }
}

// 登录任务自动完成
function checkLoginTask() {
  const tasks = SaveSystem.getTasksData();
  const loginTask = tasks.daily?.['daily_login'];
  if (!loginTask?.completed) {
    SaveSystem.updateTaskProgress('daily', 'daily_login', 1);
    SaveSystem.completeTask('daily', 'daily_login');
  }
}

// 打开任务面板
function showTaskPanel() {
  checkLoginTask();
  renderTaskPanel();
  document.getElementById('task-panel-overlay').style.display = 'flex';
}

function closeTaskPanel() {
  document.getElementById('task-panel-overlay').style.display = 'none';
}

function renderTaskPanel() {
  const container = document.getElementById('task-panel-content');
  if (!container) return;

  const tasks = SaveSystem.getTasksData();

  const rewardIcons = { cultivateSoul: '✨', lingshi: '💎', bututianshi: '🔮' };
  const rewardNames = { cultivateSoul: '修炼魂', lingshi: '灵石', bututianshi: '补天石' };

  function renderTaskGroup(title, color, borderColor, taskType, taskDefs) {
    const rows = taskDefs.map(def => {
      const state = tasks[taskType]?.[def.id] || { completed: false, claimed: false, progress: 0 };
      const prog = Math.min(def.target, state.progress || 0);
      const pct = Math.floor(prog / def.target * 100);
      const isDone = state.completed;
      const isClaimed = state.claimed;

      // 成就用累计数据
      let displayProg = prog;
      let displayPct = pct;
      if (taskType === 'achievement') {
        const totalMap = { win_total: 'winTotal', gacha_total: 'gachaTotal', team_full: 'teamFullProgress' };
        const totalKey = totalMap[def.type];
        if (totalKey) {
          const tot = getAchievementProgress(totalKey === 'teamFullProgress'
            ? 'teamFull'
            : totalKey === 'winTotal' ? 'winTotal' : totalKey === 'gachaTotal' ? 'gachaTotal' : totalKey);
          displayProg = Math.min(def.target, tot);
          displayPct = Math.floor(displayProg / def.target * 100);
        }
      }

      const rewardHtml = def.rewards.map(r =>
        `<span style="font-size:11px;color:#aaa">${rewardIcons[r.type] || ''} ${r.amount}${rewardNames[r.type]}</span>`
      ).join(' &nbsp;');

      let btnHtml;
      if (isClaimed) {
        btnHtml = `<button disabled style="min-width:64px;padding:6px 14px;border-radius:6px;font-family:inherit;font-size:11px;cursor:not-allowed;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);color:#444">已领取</button>`;
      } else if (isDone) {
        btnHtml = `<button onclick="claimTask('${taskType}','${def.id}')" style="min-width:64px;padding:6px 14px;border-radius:6px;font-family:inherit;font-size:11px;cursor:pointer;background:linear-gradient(135deg,rgba(46,204,113,0.35),rgba(39,174,96,0.45));border:1px solid rgba(46,204,113,0.5);color:#a8f0c0;font-weight:700">领取</button>`;
      } else {
        btnHtml = `<button disabled style="min-width:64px;padding:6px 14px;border-radius:6px;font-family:inherit;font-size:11px;cursor:not-allowed;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);color:#555">进行中</button>`;
      }

      return `
        <div style="background:rgba(0,0,0,0.35);border:1px solid ${isDone && !isClaimed ? 'rgba(46,204,113,0.3)' : 'rgba(255,255,255,0.05)'};border-radius:10px;padding:12px 14px;display:flex;align-items:center;gap:12px;margin-bottom:8px">
          <div style="font-size:24px;flex-shrink:0">${def.icon}</div>
          <div style="flex:1;min-width:0">
            <div style="font-size:13px;color:${isDone ? (isClaimed ? '#555' : '#a8f0c0') : '#ccc'};font-weight:700;margin-bottom:2px">${def.name}</div>
            <div style="font-size:11px;color:#666;margin-bottom:6px">${def.desc}</div>
            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
              <div style="flex:1;min-width:80px;height:5px;background:rgba(255,255,255,0.08);border-radius:3px;overflow:hidden">
                <div style="height:100%;width:${isDone ? 100 : displayPct}%;background:${isDone ? 'rgba(46,204,113,0.7)' : 'rgba(201,168,76,0.6)'};border-radius:3px;transition:width 0.4s"></div>
              </div>
              <span style="font-size:10px;color:#555;white-space:nowrap">${isDone ? def.target : displayProg}/${def.target}</span>
              <span style="font-size:10px;color:#777">${rewardHtml}</span>
            </div>
          </div>
          <div style="flex-shrink:0">${btnHtml}</div>
        </div>
      `;
    }).join('');

    return `
      <div style="margin-bottom:20px">
        <div style="font-size:13px;color:${color};letter-spacing:3px;margin-bottom:10px;padding-bottom:6px;border-bottom:1px solid ${borderColor}">${title}</div>
        ${rows}
      </div>
    `;
  }

  container.innerHTML =
    renderTaskGroup('⏰ 每日任务', '#a8f0c0', 'rgba(46,204,113,0.2)', 'daily', TASK_LIST.daily) +
    renderTaskGroup('📅 每周任务', '#f0d080', 'rgba(201,168,76,0.2)', 'weekly', TASK_LIST.weekly) +
    renderTaskGroup('🏆 成就', '#cc99ff', 'rgba(155,89,182,0.2)', 'achievement', TASK_LIST.achievement);
}

function claimTask(taskType, taskId) {
  const def = [...TASK_LIST.daily, ...TASK_LIST.weekly, ...TASK_LIST.achievement].find(t => t.id === taskId);
  if (!def) return;

  const rewards = SaveSystem.claimTaskReward(taskType, taskId, def.rewards);
  if (!rewards) { showToast('无法领取，请确认任务已完成'); return; }

  const rewardNames = { cultivateSoul: '修炼魂', lingshi: '灵石', bututianshi: '补天石' };
  const rewardIcons = { cultivateSoul: '✨', lingshi: '💎', bututianshi: '🔮' };
  const rewardStr = rewards.map(r => `${rewardIcons[r.type]}${r.amount}${rewardNames[r.type]}`).join(' + ');
  showToast(`✅ 领取成功！获得：${rewardStr}`, 2500);

  updateCurrencyDisplay();
  renderTaskPanel();
}

// DOM 加载完成后初始化
document.addEventListener('DOMContentLoaded', initGame);
