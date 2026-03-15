/**
 * 《太初演义》核心战斗引擎
 * 实现属性克制、伤害计算、技能系统
 */

// ============================================================
// 属性体系定义
// ============================================================
const ELEMENTS = {
  WUJI: 'wuji',       // 无极
  YIN: 'yin',         // 阴
  YANG: 'yang',       // 阳
  METAL: 'metal',     // 金
  WOOD: 'wood',       // 木
  WATER: 'water',     // 水
  FIRE: 'fire',       // 火
  EARTH: 'earth',     // 土
};

const ELEMENT_NAMES = {
  wuji: '无极', yin: '阴', yang: '阳',
  metal: '金', wood: '木', water: '水', fire: '火', earth: '土'
};

const ELEMENT_COLORS = {
  wuji: '#9b59b6', yin: '#2c3e50', yang: '#f39c12',
  metal: '#bdc3c7', wood: '#27ae60', water: '#2980b9', fire: '#e74c3c', earth: '#d35400'
};

const ELEMENT_ICONS = {
  wuji: '🌌', yin: '🌑', yang: '☀️',
  metal: '⚡', wood: '🌿', water: '💧', fire: '🔥', earth: '🏔️'
};

// ============================================================
// 克制关系矩阵
// 返回：{ type, damageMulti, specialEffect }
// type: 'counter'=克制, 'high_counter'=高维压制, 'reverse'=逆克, 'chaos'=混沌无视, 'neutral'=无克制
// ============================================================
function getRelation(attackerEl, defenderEl) {
  // 无极 → 任何：混沌无视
  if (attackerEl === ELEMENTS.WUJI) {
    return { type: 'chaos', damageMulti: 1.0, desc: '混沌无视', effect: 'guaranteed_hit', effectDesc: '必然命中，无视克制' };
  }

  // 阴 ↔ 阳
  if (attackerEl === ELEMENTS.YIN && defenderEl === ELEMENTS.YANG) {
    return { type: 'counter', damageMulti: 1.3, desc: '阴克阳', effect: 'silence', effectDesc: '概率沉默（禁止技能）一回合', effectChance: 0.4 };
  }
  if (attackerEl === ELEMENTS.YANG && defenderEl === ELEMENTS.YIN) {
    return { type: 'counter', damageMulti: 1.3, desc: '阳克阴', effect: 'stun', effectDesc: '概率眩晕（禁止行动）一回合', effectChance: 0.4 };
  }

  // 阴阳 → 五行（高维压制）
  const wuxing = [ELEMENTS.METAL, ELEMENTS.WOOD, ELEMENTS.WATER, ELEMENTS.FIRE, ELEMENTS.EARTH];
  if ((attackerEl === ELEMENTS.YIN || attackerEl === ELEMENTS.YANG) && wuxing.includes(defenderEl)) {
    return { type: 'high_counter', damageMulti: 1.15, desc: '天地压制五行', effect: 'true_damage_pct', effectDesc: '额外造成目标最大生命值5%的真实伤害', trueDamagePct: 0.05 };
  }

  // 五行 → 阴阳（逆克）
  if (wuxing.includes(attackerEl) && (defenderEl === ELEMENTS.YIN || defenderEl === ELEMENTS.YANG)) {
    return { type: 'reverse', damageMulti: 0.85, desc: '五行难撼天地', effect: 'no_crit', effectDesc: '伤害降低15%，无法暴击' };
  }

  // 五行循环克制：金→木→土→水→火→金
  const wuxingCycle = [ELEMENTS.METAL, ELEMENTS.WOOD, ELEMENTS.EARTH, ELEMENTS.WATER, ELEMENTS.FIRE];
  const atkIdx = wuxingCycle.indexOf(attackerEl);
  const defIdx = wuxingCycle.indexOf(defenderEl);
  if (atkIdx !== -1 && defIdx !== -1) {
    // 顺序克制：atkIdx → (atkIdx+1)%5
    if ((atkIdx + 1) % 5 === defIdx) {
      const cycleEffects = {
        metal: { effect: 'dispel', effectDesc: '破甲驱散，移除目标一个增益', counter: '金克木' },
        wood:  { effect: 'dispel', effectDesc: '枝蔓缠绕，移除目标一个增益', counter: '木克土' },
        earth: { effect: 'dispel', effectDesc: '大地吞噬，移除目标一个增益', counter: '土克水' },
        water: { effect: 'dispel', effectDesc: '冰封驱散，移除目标一个增益', counter: '水克火' },
        fire:  { effect: 'dispel', effectDesc: '炎焰灼烧，移除目标一个增益', counter: '火克金' },
      };
      const info = cycleEffects[attackerEl];
      return { type: 'counter', damageMulti: 1.25, desc: info.counter, effect: 'dispel', effectDesc: info.effectDesc, effectChance: 1.0 };
    }
    // 反向（被克）：defIdx → atkIdx（即攻击方被克）
    if ((defIdx + 1) % 5 === atkIdx) {
      return { type: 'weak', damageMulti: 0.8, desc: '属性不利', effect: 'none', effectDesc: '' };
    }
  }

  return { type: 'neutral', damageMulti: 1.0, desc: '中性', effect: 'none', effectDesc: '' };
}

// ============================================================
// 伤害计算
// ============================================================
function calculateDamage(attacker, defender, skill = null, relationOverride = null) {
  const relation = relationOverride || getRelation(attacker.element, defender.element);

  let baseDmg = skill ? skill.baseDamage * attacker.atk : attacker.atk;
  const def = defender.def;
  let dmg = Math.max(1, baseDmg - def * 0.5);

  // 暴击判定（逆克无法暴击）
  let isCrit = false;
  if (relation.effect !== 'no_crit') {
    isCrit = Math.random() < (attacker.critRate || 0.15);
    if (isCrit) dmg *= (attacker.critDmg || 1.8);
  }

  // 属性克制加成
  dmg *= relation.damageMulti;

  // 真实伤害（高维压制）
  let trueDmg = 0;
  if (relation.effect === 'true_damage_pct') {
    trueDmg = Math.floor(defender.maxHp * relation.trueDamagePct);
  }

  dmg = Math.floor(dmg);

  // 特殊效果判定
  let appliedEffect = null;
  if (relation.effectChance && Math.random() < relation.effectChance) {
    appliedEffect = relation.effect;
  } else if (relation.effect === 'dispel' || relation.effect === 'guaranteed_hit' || relation.effect === 'true_damage_pct') {
    appliedEffect = relation.effect;
  }

  return { dmg, trueDmg, isCrit, relation, appliedEffect, totalDmg: dmg + trueDmg };
}

// ============================================================
// 状态效果系统
// ============================================================
const STATUS_EFFECTS = {
  silence:  { name: '沉默', icon: '🔇', desc: '无法使用技能', duration: 1, color: '#8e44ad' },
  stun:     { name: '眩晕', icon: '💫', desc: '无法行动',     duration: 1, color: '#f39c12' },
  burn:     { name: '灼烧', icon: '🔥', desc: '每回合损失生命', duration: 3, color: '#e74c3c' },
  freeze:   { name: '冰冻', icon: '❄️', desc: '无法行动',     duration: 1, color: '#3498db' },
  amnesia:  { name: '失忆', icon: '💭', desc: '技能冷却增加，命中率下降', duration: 2, color: '#95a5a6' },
  shield:   { name: '护盾', icon: '🛡️', desc: '减免伤害', duration: 2, color: '#2ecc71' },
  invincible:{ name: '无敌', icon: '✨', desc: '免疫伤害', duration: 1, color: '#f1c40f' },
  regen:    { name: '回血', icon: '💚', desc: '每回合恢复生命', duration: 3, color: '#27ae60' },
};

function applyStatusEffect(target, effectName, value = 0) {
  if (!target.statusEffects) target.statusEffects = [];
  const effect = { ...STATUS_EFFECTS[effectName], id: effectName, value, remainingDuration: STATUS_EFFECTS[effectName].duration };
  // 不叠加同类效果，刷新持续时间
  const existing = target.statusEffects.find(e => e.id === effectName);
  if (existing) {
    existing.remainingDuration = effect.remainingDuration;
    existing.value = value;
  } else {
    target.statusEffects.push(effect);
  }
}

function tickStatusEffects(unit) {
  if (!unit.statusEffects) unit.statusEffects = [];
  let hpChange = 0;
  const expired = [];

  unit.statusEffects.forEach(eff => {
    if (eff.id === 'burn') {
      const dmg = Math.floor(unit.maxHp * 0.05);
      unit.hp = Math.max(0, unit.hp - dmg);
      hpChange -= dmg;
    }
    if (eff.id === 'regen') {
      const heal = Math.floor(unit.maxHp * 0.08);
      unit.hp = Math.min(unit.maxHp, unit.hp + heal);
      hpChange += heal;
    }
    eff.remainingDuration--;
    if (eff.remainingDuration <= 0) expired.push(eff.id);
  });

  unit.statusEffects = unit.statusEffects.filter(e => !expired.includes(e.id));
  return { hpChange, expired };
}

// ============================================================
// 战斗日志生成器
// ============================================================
class BattleLog {
  constructor() { this.entries = []; }
  add(text, type = 'normal', icon = '') {
    this.entries.push({ text, type, icon, time: Date.now() });
  }
  clear() { this.entries = []; }
}

// ============================================================
// 连携技（Combo）系统
// ============================================================
const COMBOS = [
  {
    id: 'water_fire',
    name: '水火不容',
    icon: '⚡',
    requiredHeroes: ['gonggong', 'zhurong'],
    desc: '双方暴击率提升10%',
    apply(team) {
      team.forEach(u => { if (u.id === 'gonggong' || u.id === 'zhurong') u.critRate = (u.critRate || 0.15) + 0.1; });
    }
  },
  {
    id: 'yin_yang_harmony',
    name: '阴阳调和',
    icon: '☯️',
    requiredHeroes: ['donghuang', 'jiutian'],
    desc: '开场为全体施加一层护盾',
    apply(team, applyStatus) {
      team.forEach(u => applyStatus(u, 'shield', Math.floor(u.maxHp * 0.1)));
    }
  },
  {
    id: 'creation',
    name: '开天辟地',
    icon: '🌌',
    requiredHeroes: ['pangu', 'nvwa'],
    desc: '造化万千：全额恢复生命并复活一名阵亡队友',
    apply(team) {
      team.forEach(u => { u.hp = u.maxHp; });
    }
  }
];

function checkCombos(team) {
  const ids = team.map(u => u.id);
  return COMBOS.filter(combo => combo.requiredHeroes.every(h => ids.includes(h)));
}

// ============================================================
// 导出
// ============================================================
if (typeof module !== 'undefined') {
  module.exports = { ELEMENTS, ELEMENT_NAMES, ELEMENT_COLORS, ELEMENT_ICONS, getRelation, calculateDamage, applyStatusEffect, tickStatusEffects, STATUS_EFFECTS, BattleLog, COMBOS, checkCombos };
}
