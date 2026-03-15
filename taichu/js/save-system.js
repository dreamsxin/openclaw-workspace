/**
 * 《太初演义》存档系统
 * 负责 localStorage 读写、首次创号检测、玩家档案管理
 */

const SAVE_KEY = 'taichu_save_v1';

// ============================================================
// 默认存档结构
// ============================================================
function getDefaultSave() {
  return {
    version: 1,
    createTime: Date.now(),
    lastLogin: Date.now(),

    // 玩家信息
    player: {
      name: '',
      title: '无名执命人',
      gender: 'male',    // 'male' | 'female'
      level: 1,
      exp: 0,
      expToNext: 100,
      loginDays: 1,
    },

    // 货币（同步自 GachaSystem）
    currency: {
      lingshi: 3000,
      bututianshi: 30,
      hundunJing: 5,
      cultivateSoul: 500,  // 修炼魂 — 用于养成
    },

    // 背包（英雄库存）[{ heroId, quantity, obtained }]
    inventory: [
      { heroId: 'gonggong',  quantity: 1, obtained: Date.now() },
      { heroId: 'zhurong',   quantity: 1, obtained: Date.now() },
      { heroId: 'shennong',  quantity: 1, obtained: Date.now() },
    ],

    // 英雄养成数据 { heroId: { level, starLevel, skillLevels, extraStats } }
    heroTraining: {},

    // 上次的队伍配置（heroId数组，最多5个）
    teamConfig: ['gonggong', 'zhurong', 'shennong', null, null],

    // 抽卡保底进度
    gachaState: {
      standard:    { totalPulls: 0, pullsSinceOrange: 0, pullsSinceUP: 0, wishHero: null },
      fire_event:  { totalPulls: 0, pullsSinceOrange: 0, pullsSinceUP: 0, wishHero: null },
      chaos_relic: { totalPulls: 0 },
    },

    // 任务系统
    tasks: {
      lastResetDate: '',   // 上次每日重置日期 YYYY-MM-DD
      lastWeekReset: '',   // 上次每周重置 YYYY-WW
      daily: {},           // { taskId: { completed, claimed, progress } }
      weekly: {},          // { taskId: { completed, claimed, progress } }
      achievement: {},     // { taskId: { completed, claimed, progress } }
    },
  };
}

// ============================================================
// 存档操作
// ============================================================
const SaveSystem = {
  _data: null,

  /** 加载存档，无则返回 null */
  load() {
    try {
      const raw = localStorage.getItem(SAVE_KEY);
      if (!raw) return null;
      this._data = JSON.parse(raw);
      return this._data;
    } catch (e) {
      console.warn('存档读取失败', e);
      return null;
    }
  },

  /** 保存当前数据 */
  save(data) {
    try {
      this._data = data;
      localStorage.setItem(SAVE_KEY, JSON.stringify(data));
    } catch (e) {
      console.warn('存档写入失败', e);
    }
  },

  /** 首次进入游戏（无存档） */
  isFirstTime() {
    return !localStorage.getItem(SAVE_KEY);
  },

  /** 用玩家输入的信息创建新存档 */
  createNewSave(playerName, gender, titleId) {
    const save = getDefaultSave();
    save.player.name   = playerName.trim() || '无名执命人';
    save.player.gender = gender;
    save.player.title  = PLAYER_TITLES.find(t => t.id === titleId)?.name || '无名执命人';
    this.save(save);
    return save;
  },

  /** 获取当前存档（确保已加载） */
  get() {
    if (!this._data) this.load();
    return this._data;
  },

  /** 部分更新并保存 */
  update(patch) {
    const data = this.get();
    Object.assign(data, patch);
    this.save(data);
  },

  /** 更新玩家信息 */
  updatePlayer(patch) {
    const data = this.get();
    Object.assign(data.player, patch);
    this.save(data);
  },

  /** 更新货币 */
  updateCurrency(patch) {
    const data = this.get();
    Object.assign(data.currency, patch);
    this.save(data);
  },

  /** 同步背包（来自GachaSystem） */
  syncInventory(inventory, gachaState, currency) {
    const data = this.get();
    data.inventory  = inventory;
    data.gachaState = gachaState;
    Object.assign(data.currency, currency);
    this.save(data);
  },

  /** 保存队伍配置 */
  saveTeam(teamHeroIds) {
    const data = this.get();
    data.teamConfig = teamHeroIds;
    this.save(data);
  },

  /** 获取英雄养成数据，不存在时返回默认 */
  getHeroTraining(heroId) {
    const data = this.get();
    if (!data.heroTraining[heroId]) {
      data.heroTraining[heroId] = getDefaultHeroTraining(heroId);
      this.save(data);
    }
    return data.heroTraining[heroId];
  },

  /** 更新英雄养成数据 */
  updateHeroTraining(heroId, patch) {
    const data = this.get();
    if (!data.heroTraining[heroId]) {
      data.heroTraining[heroId] = getDefaultHeroTraining(heroId);
    }
    Object.assign(data.heroTraining[heroId], patch);
    this.save(data);
  },

  /** 玩家获得经验 */
  addPlayerExp(exp) {
    const data = this.get();
    const p = data.player;
    p.exp += exp;
    while (p.exp >= p.expToNext) {
      p.exp -= p.expToNext;
      p.level += 1;
      p.expToNext = Math.floor(100 * Math.pow(1.15, p.level - 1));
    }
    this.save(data);
    return p;
  },

  /** 删除存档（重置游戏）*/
  deleteSave() {
    localStorage.removeItem(SAVE_KEY);
    this._data = null;
  },

  /** 获取任务数据（自动重置每日/每周） */
  getTasksData() {
    const data = this.get();
    if (!data.tasks) {
      data.tasks = {
        lastResetDate: '', lastWeekReset: '',
        daily: {}, weekly: {}, achievement: {},
      };
    }
    const today = new Date();
    const dateStr = today.toISOString().slice(0, 10);
    // 计算当前周编号
    const startOfYear = new Date(today.getFullYear(), 0, 1);
    const weekNum = Math.ceil(((today - startOfYear) / 86400000 + startOfYear.getDay() + 1) / 7);
    const weekStr = `${today.getFullYear()}-W${weekNum}`;

    // 每日重置
    if (data.tasks.lastResetDate !== dateStr) {
      data.tasks.lastResetDate = dateStr;
      data.tasks.daily = {};
      this.save(data);
    }
    // 每周重置
    if (data.tasks.lastWeekReset !== weekStr) {
      data.tasks.lastWeekReset = weekStr;
      data.tasks.weekly = {};
      this.save(data);
    }
    return data.tasks;
  },

  /** 更新任务进度 */
  updateTaskProgress(taskType, taskId, progress) {
    const data = this.get();
    if (!data.tasks) return;
    if (!data.tasks[taskType]) data.tasks[taskType] = {};
    if (!data.tasks[taskType][taskId]) {
      data.tasks[taskType][taskId] = { completed: false, claimed: false, progress: 0 };
    }
    data.tasks[taskType][taskId].progress = progress;
    this.save(data);
  },

  /** 标记任务完成 */
  completeTask(taskType, taskId) {
    const data = this.get();
    if (!data.tasks?.[taskType]) return;
    if (!data.tasks[taskType][taskId]) {
      data.tasks[taskType][taskId] = { completed: false, claimed: false, progress: 0 };
    }
    data.tasks[taskType][taskId].completed = true;
    this.save(data);
  },

  /** 领取任务奖励，返回奖励内容 */
  claimTaskReward(taskType, taskId, rewards) {
    const data = this.get();
    if (!data.tasks?.[taskType]?.[taskId]?.completed) return null;
    if (data.tasks[taskType][taskId].claimed) return null;
    data.tasks[taskType][taskId].claimed = true;
    // 发放奖励
    rewards.forEach(r => {
      if (r.type === 'cultivateSoul') data.currency.cultivateSoul = (data.currency.cultivateSoul || 0) + r.amount;
      if (r.type === 'lingshi')       data.currency.lingshi       = (data.currency.lingshi || 0) + r.amount;
      if (r.type === 'bututianshi')   data.currency.bututianshi   = (data.currency.bututianshi || 0) + r.amount;
    });
    this.save(data);
    return rewards;
  },
};

// ============================================================
// 默认英雄养成数据
// ============================================================
function getDefaultHeroTraining(heroId) {
  const base = HERO_INDEX[heroId];
  return {
    level:       1,
    starLevel:   1,    // 突破等阶 1~6
    exp:         0,
    expToNext:   100,
    skillLevels: {},   // { skillId: level } 1~5
    // 洗练附加属性（百分比加成，0~1）
    extraStats: {
      hpBonus:   0,
      atkBonus:  0,
      defBonus:  0,
      spdBonus:  0,
      critBonus: 0,
    },
    reforgeCount: 0,  // 洗练次数
  };
}

// ============================================================
// 可选称号
// ============================================================
const PLAYER_TITLES = [
  { id: 'unnamed',    name: '无名执命人',   desc: '来自洪荒长河的旅人' },
  { id: 'starseeker', name: '观星执命人',   desc: '能窥见命运轨迹' },
  { id: 'warden',     name: '守序执命人',   desc: '维护三界秩序的使者' },
  { id: 'chaos',      name: '混沌执命人',   desc: '游走于规则之外' },
  { id: 'immortal',   name: '仙道执命人',   desc: '追求大道的修行者' },
  { id: 'warrior',    name: '征伐执命人',   desc: '以战止战的斗神后裔' },
];

// ============================================================
// 养成消耗配置
// ============================================================
const TRAINING_CONFIG = {
  // 每级升级消耗的修炼魂
  levelUpCost: (currentLevel) => Math.floor(50 * Math.pow(1.12, currentLevel - 1)),
  // 每级升级获得经验
  levelExpGain: 100,
  // 满级上限（按突破阶）
  maxLevelByStars: { 1: 20, 2: 40, 3: 60, 4: 80, 5: 100, 6: 120 },
  // 突破消耗
  breakthroughCost: {
    1: { cultivateSoul: 300,  fragments: 10,  lingshi: 500 },
    2: { cultivateSoul: 800,  fragments: 20,  lingshi: 1500 },
    3: { cultivateSoul: 2000, fragments: 40,  lingshi: 4000 },
    4: { cultivateSoul: 5000, fragments: 80,  lingshi: 10000 },
    5: { cultivateSoul: 12000,fragments: 150, lingshi: 30000 },
  },
  // 技能升级消耗（升到第n级需要的培养材料）
  skillUpgradeCost: (targetLevel) => ({
    cultivateSoul: [0, 200, 500, 1200, 3000, 8000][targetLevel] || 0,
    lingshi:       [0, 100, 300, 800,  2000, 5000][targetLevel] || 0,
  }),
  // 洗练消耗（固定）
  reforgeCost: { cultivateSoul: 800, lingshi: 500 },
};
