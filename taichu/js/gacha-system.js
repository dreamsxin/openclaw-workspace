/**
 * 《太初演义》抽卡系统
 * 实现卡池管理、保底机制、心愿单
 */

// 稀有度抽取概率
const RARITY_RATES = {
  standard: {
    white:  0.40,  // 40% 凡
    green:  0.30,  // 30% 精
    blue:   0.18,  // 18% 灵
    purple: 0.09,  // 9%  仙
    orange: 0.03,  // 3%  圣
    red:    0.00,  // 0%  神话（无法直接抽取）
  },
  up_pool: {
    white:  0.30,
    green:  0.25,
    blue:   0.20,
    purple: 0.14,
    orange: 0.11,
    red:    0.00,
  }
};

// 卡池定义
const CARD_POOLS = [
  {
    id: 'standard',
    name: '洪荒长河',
    type: 'standard',
    desc: '标准卡池，包含五行及部分阴阳角色，常驻开放。',
    icon: '🌊',
    banner: '#1a3a5c',
    available: true,
    heroes: ['zhurong', 'gonggong', 'rushou', 'shennong', 'houtu', 'change', 'donghuang', 'dijun', 'luya', 'xuanming', 'taibai', 'goumang', 'huangdi', 'jinwu', 'mengpo', 'jiutian'],
    upHeroes: [],
    rates: RARITY_RATES.standard,
    costStandard: 160,  // 灵石
    costPremium: 1,     // 补天石
  },
  {
    id: 'fire_event',
    name: '火神降临',
    type: 'up',
    desc: '限时UP池，祝融概率大幅提升！圣级保底出祝融。',
    icon: '🔥',
    banner: '#5c1a1a',
    available: true,
    heroes: ['zhurong', 'gonggong', 'rushou', 'shennong', 'houtu', 'change', 'donghuang', 'dijun', 'luya', 'xuanming', 'taibai', 'goumang', 'huangdi', 'jinwu', 'mengpo', 'jiutian'],
    upHeroes: ['zhurong'],
    upHeroName: '祝融',
    rates: RARITY_RATES.up_pool,
    costStandard: 160,
    costPremium: 1,
    endTime: Date.now() + 14 * 24 * 3600 * 1000,
  },
  {
    id: 'chaos_relic',
    name: '混沌遗迹',
    type: 'special',
    desc: '特殊活动池，获取先天神话级碎片。消耗活动专属"混沌晶"参与。',
    icon: '🌌',
    banner: '#2a1a5c',
    available: true,
    heroes: [],
    upHeroes: ['hongjun', 'pangu', 'nvwa'],
    specialDrop: true,
    costSpecial: 1, // 混沌晶
  },
];

// ============================================================
// 玩家抽卡状态管理
// ============================================================
class GachaSystem {
  constructor() {
    this.saveKey = 'taichu_gacha_state';
    this.state = this.loadState();
  }

  loadState() {
    try {
      const saved = localStorage.getItem(this.saveKey);
      if (saved) return JSON.parse(saved);
    } catch (e) {}
    return this.defaultState();
  }

  defaultState() {
    return {
      currency: {
        lingshi: 3000,    // 灵石
        bututianshi: 30,  // 补天石
        hundunJing: 5,    // 混沌晶
      },
      poolState: {
        standard: { totalPulls: 0, pullsSinceOrange: 0, pullsSinceUP: 0, wishHero: null },
        fire_event: { totalPulls: 0, pullsSinceOrange: 0, pullsSinceUP: 0, wishHero: null },
        chaos_relic: { totalPulls: 0 },
      },
      inventory: this.buildStarterInventory(),
      history: [],
    };
  }

  buildStarterInventory() {
    // 赠送新手卡
    return [
      { heroId: 'gonggong',  quantity: 1, obtained: Date.now() },
      { heroId: 'zhurong',   quantity: 1, obtained: Date.now() },
      { heroId: 'shennong',  quantity: 1, obtained: Date.now() },
    ];
  }

  saveState() {
    localStorage.setItem(this.saveKey, JSON.stringify(this.state));
  }

  // 单抽
  pullOnce(poolId) {
    const pool = CARD_POOLS.find(p => p.id === poolId);
    if (!pool) return null;
    const pstate = this.state.poolState[poolId] || { totalPulls: 0, pullsSinceOrange: 0, pullsSinceUP: 0 };

    // 扣除货币
    if (pool.type !== 'special') {
      if (this.state.currency.bututianshi >= pool.costPremium) {
        this.state.currency.bututianshi -= pool.costPremium;
      } else if (this.state.currency.lingshi >= pool.costStandard) {
        this.state.currency.lingshi -= pool.costStandard;
      } else {
        return { error: '灵石或补天石不足！' };
      }
    }

    pstate.totalPulls++;
    pstate.pullsSinceOrange++;

    // 决定稀有度（含保底）
    const rarity = this.determineRarity(pstate, pool);
    // 从对应稀有度中选取英雄
    const hero = this.selectHero(rarity, pool, pstate);
    
    pstate.pullsSinceOrange = (rarity === 'orange' || rarity === 'red') ? 0 : pstate.pullsSinceOrange;
    if (rarity === 'orange' && pool.upHeroes && pool.upHeroes.includes(hero.id)) {
      pstate.pullsSinceUP = 0;
    } else if (rarity === 'orange') {
      pstate.pullsSinceUP = (pstate.pullsSinceUP || 0) + 1;
    }

    this.state.poolState[poolId] = pstate;

    // 加入背包
    this.addToInventory(hero.id);
    
    const result = {
      heroId: hero.id,
      hero: hero,
      rarity,
      isNew: this.isNewHero(hero.id),
      pullNumber: pstate.totalPulls,
    };
    this.state.history.unshift({ ...result, time: Date.now() });
    if (this.state.history.length > 100) this.state.history = this.state.history.slice(0, 100);
    this.saveState();
    return result;
  }

  // 十连抽
  pullTen(poolId) {
    const pool = CARD_POOLS.find(p => p.id === poolId);
    if (!pool) return null;

    // 检查货币（十连有折扣：10补天石或1500灵石）
    const cost10 = 10 * pool.costPremium;
    const costLingshi10 = 1500;
    if (this.state.currency.bututianshi >= cost10) {
      this.state.currency.bututianshi -= cost10;
    } else if (this.state.currency.lingshi >= costLingshi10) {
      this.state.currency.lingshi -= costLingshi10;
    } else {
      return { error: '资源不足，无法十连抽！' };
    }

    // 临时存备：恢复抽单次逻辑但不扣费
    const origState = JSON.parse(JSON.stringify(this.state));
    // 添加上面扣除的货币以便pullOnce内部扣费
    this.state.currency.bututianshi += cost10;
    
    const results = [];
    // 先临时改为不扣费模式
    for (let i = 0; i < 10; i++) {
      const pstate = this.state.poolState[poolId] || { totalPulls: 0, pullsSinceOrange: 0, pullsSinceUP: 0 };
      pstate.totalPulls++;
      pstate.pullsSinceOrange++;
      // 第10抽保底至少紫色
      const rarity = (i === 9 && !results.some(r => ['purple','orange','red'].includes(r.rarity)))
        ? this.determineRarityMin(pstate, pool, 'purple')
        : this.determineRarity(pstate, pool);
      const hero = this.selectHero(rarity, pool, pstate);
      pstate.pullsSinceOrange = (rarity === 'orange' || rarity === 'red') ? 0 : pstate.pullsSinceOrange;
      this.state.poolState[poolId] = pstate;
      this.addToInventory(hero.id);
      results.push({ heroId: hero.id, hero, rarity, pullNumber: pstate.totalPulls });
    }

    // 扣除实际费用（修正）
    this.state.currency.bututianshi -= cost10;
    // 最终再从1500灵石扣除（因为我们之前恢复了补天石后立即减了）
    // 简化：直接根据剩余来判断
    this.saveState();
    return results;
  }

  determineRarity(pstate, pool) {
    // 小保底：50抽必出橙
    if (pstate.pullsSinceOrange >= 50) return 'orange';
    // 大保底：80抽必出UP橙
    if (pool.upHeroes && pool.upHeroes.length > 0 && (pstate.pullsSinceUP || 0) >= 2) return 'orange';

    const r = Math.random();
    let acc = 0;
    const rates = pool.rates || RARITY_RATES.standard;
    for (const [rar, prob] of Object.entries(rates)) {
      acc += prob;
      if (r < acc) return rar;
    }
    return 'white';
  }

  determineRarityMin(pstate, pool, minRarity) {
    const rarityOrder = ['white','green','blue','purple','orange','red'];
    const minIdx = rarityOrder.indexOf(minRarity);
    const rarity = this.determineRarity(pstate, pool);
    const rarIdx = rarityOrder.indexOf(rarity);
    return rarIdx >= minIdx ? rarity : minRarity;
  }

  selectHero(rarity, pool, pstate) {
    let candidates = (pool.heroes || []).map(id => HERO_INDEX[id]).filter(h => h && h.rarity === rarity);
    
    // 如果是UP池且抽到橙色，80抽大保底强制出UP
    if (rarity === 'orange' && pool.upHeroes && pool.upHeroes.length > 0) {
      const isGuaranteedUP = (pstate.pullsSinceUP || 0) >= 2 || pstate.pullsSinceOrange >= 80;
      if (isGuaranteedUP) {
        const upCandidates = pool.upHeroes.map(id => HERO_INDEX[id]).filter(Boolean);
        if (upCandidates.length > 0) return upCandidates[Math.floor(Math.random() * upCandidates.length)];
      }
      // 50% 出UP
      if (Math.random() < 0.5 && pool.upHeroes.length > 0) {
        const upCandidates = pool.upHeroes.map(id => HERO_INDEX[id]).filter(Boolean);
        if (upCandidates.length > 0) return upCandidates[Math.floor(Math.random() * upCandidates.length)];
      }
    }

    if (candidates.length === 0) {
      // 降级处理
      const fallback = (pool.heroes || []).map(id => HERO_INDEX[id]).filter(Boolean);
      return fallback[Math.floor(Math.random() * fallback.length)] || HEROES[0];
    }
    return candidates[Math.floor(Math.random() * candidates.length)];
  }

  addToInventory(heroId) {
    const existing = this.state.inventory.find(i => i.heroId === heroId);
    if (existing) {
      existing.quantity++;
    } else {
      this.state.inventory.push({ heroId, quantity: 1, obtained: Date.now() });
    }
  }

  isNewHero(heroId) {
    const existing = this.state.inventory.find(i => i.heroId === heroId);
    return !existing || existing.quantity <= 1;
  }

  hasHero(heroId) {
    const inv = this.state.inventory.find(i => i.heroId === heroId);
    return inv && inv.quantity > 0;
  }

  // 设置心愿单（标准池和活动池可设置非无极角色）
  setWish(poolId, heroId) {
    if (!this.state.poolState[poolId]) this.state.poolState[poolId] = { totalPulls: 0, pullsSinceOrange: 0, wishHero: null };
    this.state.poolState[poolId].wishHero = heroId;
    this.saveState();
  }

  getWish(poolId) {
    return this.state.poolState[poolId]?.wishHero || null;
  }

  getPullCount(poolId) {
    return this.state.poolState[poolId]?.totalPulls || 0;
  }

  getPullsSinceOrange(poolId) {
    return this.state.poolState[poolId]?.pullsSinceOrange || 0;
  }

  getCurrency() {
    return { ...this.state.currency };
  }

  getInventory() {
    return this.state.inventory.map(item => ({
      ...item,
      hero: HERO_INDEX[item.heroId]
    })).filter(item => item.hero);
  }

  getHistory() {
    return this.state.history.slice(0, 50).map(h => ({
      ...h,
      hero: HERO_INDEX[h.heroId]
    }));
  }

  // 重置（调试用）
  reset() {
    this.state = this.defaultState();
    this.saveState();
  }
}
