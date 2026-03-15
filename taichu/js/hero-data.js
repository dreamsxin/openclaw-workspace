/**
 * 《太初演义》英雄数据库
 * 包含所有可用神话人物的完整数据
 */

const RARITY = {
  WHITE:  { id: 'white',  name: '凡', color: '#aaa',    stars: 1, textColor: '#888' },
  GREEN:  { id: 'green',  name: '精', color: '#2ecc71', stars: 2, textColor: '#27ae60' },
  BLUE:   { id: 'blue',   name: '灵', color: '#3498db', stars: 3, textColor: '#2980b9' },
  PURPLE: { id: 'purple', name: '仙', color: '#9b59b6', stars: 4, textColor: '#8e44ad' },
  ORANGE: { id: 'orange', name: '圣', color: '#e67e22', stars: 5, textColor: '#d35400' },
  RED:    { id: 'red',    name: '先天神话', color: '#e74c3c', stars: 6, textColor: '#c0392b' },
};

// 技能定义
const SKILLS = {
  // ===== 火系技能 =====
  fire_god_rage: {
    id: 'fire_god_rage', name: '火神怒',
    desc: '对敌方全体造成120%攻击力伤害，并施加灼烧（每回合损失5%生命，持续3回合）。',
    icon: '🔥', type: 'aoe', target: 'all_enemies', baseDamage: 1.2,
    statusEffect: 'burn', statusTarget: 'all_enemies', cooldown: 3, cost: 3,
    color: '#e74c3c'
  },
  fire_slash: {
    id: 'fire_slash', name: '炎劈',
    desc: '对单体敌人造成150%攻击力伤害。',
    icon: '🗡️', type: 'single', target: 'single_enemy', baseDamage: 1.5,
    cooldown: 2, cost: 2, color: '#e74c3c'
  },
  // ===== 水系技能 =====
  buzhou_collision: {
    id: 'buzhou_collision', name: '怒触不周山',
    desc: '攻击敌方前排，高概率冰冻目标一回合，并驱散其增益效果。',
    icon: '❄️', type: 'single', target: 'front_enemy', baseDamage: 1.1,
    statusEffect: 'freeze', statusTarget: 'front_enemy', statusChance: 0.75,
    dispel: true, cooldown: 3, cost: 3, color: '#2980b9'
  },
  water_wave: {
    id: 'water_wave', name: '洪流',
    desc: '对敌方全体造成90%攻击力伤害。',
    icon: '🌊', type: 'aoe', target: 'all_enemies', baseDamage: 0.9,
    cooldown: 2, cost: 2, color: '#3498db'
  },
  // ===== 金系技能 =====
  gold_axe: {
    id: 'gold_axe', name: '金神执钺',
    desc: '对敌方单体造成200%攻击力伤害，若目标生命值低于30%，则直接斩杀。',
    icon: '⚔️', type: 'single', target: 'single_enemy', baseDamage: 2.0,
    executeThreshold: 0.3, cooldown: 4, cost: 4, color: '#bdc3c7'
  },
  metal_pierce: {
    id: 'metal_pierce', name: '穿甲破防',
    desc: '对单体造成130%攻击力伤害，无视30%防御力。',
    icon: '🗡️', type: 'single', target: 'single_enemy', baseDamage: 1.3,
    armorPierce: 0.3, cooldown: 2, cost: 2, color: '#bdc3c7'
  },
  // ===== 木系技能 =====
  herb_heal: {
    id: 'herb_heal', name: '百草济世',
    desc: '为己方全体持续恢复生命（每回合恢复8%最大生命值，持续3回合），并增加防御力15%。',
    icon: '💚', type: 'heal', target: 'all_allies', baseDamage: 0,
    statusEffect: 'regen', statusTarget: 'all_allies', cooldown: 3, cost: 3, color: '#27ae60'
  },
  revive_vine: {
    id: 'revive_vine', name: '生息藤蔓',
    desc: '对己方单体治疗130%攻击力的生命值。',
    icon: '🌿', type: 'heal_single', target: 'single_ally', baseDamage: 1.3,
    cooldown: 2, cost: 2, color: '#27ae60'
  },
  // ===== 土系技能 =====
  earth_mother_shield: {
    id: 'earth_mother_shield', name: '大地母亲庇护',
    desc: '为己方全体施加护盾（护盾值=施法者最大生命值的30%），并反伤近战攻击者。',
    icon: '🛡️', type: 'shield', target: 'all_allies', baseDamage: 0,
    statusEffect: 'shield', shieldRatio: 0.3, statusTarget: 'all_allies', cooldown: 3, cost: 3, color: '#d35400'
  },
  stone_wall: {
    id: 'stone_wall', name: '磐石固守',
    desc: '对己方单体施加护盾并大幅提升防御两回合。',
    icon: '🏔️', type: 'shield_single', target: 'single_ally', baseDamage: 0,
    statusEffect: 'shield', shieldRatio: 0.2, cooldown: 2, cost: 2, color: '#d35400'
  },
  // ===== 阴系技能 =====
  meng_po_soup: {
    id: 'meng_po_soup', name: '忘川汤',
    desc: '使敌方单体陷入失忆（技能冷却增加，命中率下降），持续2回合。',
    icon: '💭', type: 'debuff', target: 'single_enemy', baseDamage: 0.6,
    statusEffect: 'amnesia', statusTarget: 'single_enemy', cooldown: 3, cost: 3, color: '#8e44ad'
  },
  yin_curse: {
    id: 'yin_curse', name: '玄阴诅咒',
    desc: '对单体敌人造成80%攻击力伤害并施加沉默一回合。',
    icon: '🌑', type: 'single', target: 'single_enemy', baseDamage: 0.8,
    statusEffect: 'silence', statusTarget: 'single_enemy', statusChance: 0.8,
    cooldown: 2, cost: 2, color: '#2c3e50'
  },
  // ===== 阳系技能 =====
  donghuang_bell: {
    id: 'donghuang_bell', name: '东皇钟',
    desc: '为己方最强单体提供无敌护盾一回合，并吸收伤害转化为攻击力。',
    icon: '🔔', type: 'buff', target: 'strongest_ally', baseDamage: 0,
    statusEffect: 'invincible', statusTarget: 'strongest_ally', cooldown: 3, cost: 3, color: '#f39c12'
  },
  yang_burst: {
    id: 'yang_burst', name: '日焰爆发',
    desc: '对敌方全体造成110%攻击力伤害，并有40%概率眩晕目标一回合。',
    icon: '☀️', type: 'aoe', target: 'all_enemies', baseDamage: 1.1,
    statusEffect: 'stun', statusTarget: 'all_enemies', statusChance: 0.4,
    cooldown: 3, cost: 3, color: '#f39c12'
  },
  // ===== 无极技能 =====
  dao_sound: {
    id: 'dao_sound', name: '大道之音',
    desc: '对敌方全体造成无视防御、无视属性、无法被闪避的固定伤害（180%攻击力），并清除双方所有增减益状态。',
    icon: '🌌', type: 'aoe_true', target: 'all_enemies', baseDamage: 1.8,
    trueDamage: true, clearAllStatus: true, cooldown: 5, cost: 5, color: '#9b59b6'
  },
  primal_chaos: {
    id: 'primal_chaos', name: '混沌之力',
    desc: '随机对敌方造成200%-300%攻击力的混沌伤害，无视一切规则。',
    icon: '🌀', type: 'chaos', target: 'random_enemy', baseDamage: 2.5,
    trueDamage: true, cooldown: 4, cost: 4, color: '#9b59b6'
  },
};

// 英雄数据库
const HEROES = [
  // ==================== 无极 ====================
  {
    id: 'hongjun', name: '鸿钧老祖', title: '大道至尊',
    element: 'wuji', rarity: 'red',
    lore: '天地之始，大道之源。鸿钧化三清，传道于三界，执道德天尊、元始天尊、灵宝天尊，为三界之祖。',
    baseStats: { hp: 5800, atk: 520, def: 280, spd: 65, critRate: 0.20, critDmg: 2.0 },
    skills: ['dao_sound', 'primal_chaos'],
    passiveDesc: '大道本源：鸿钧的攻击无视任何克制关系，伤害恒定。每回合开始时，所有友方单位获得5%攻击力加成。',
    passive: 'wuji_passive',
    portrait: '👴', // 临时用emoji代替
    tags: ['三清之祖', '大道', '无敌']
  },
  {
    id: 'pangu', name: '盘古', title: '开天辟地之神',
    element: 'wuji', rarity: 'red',
    lore: '盘古以斧劈开混沌，以身化天地，轻清者上升为天，重浊者下沉为地，其化身演化为日月山河。',
    baseStats: { hp: 8000, atk: 480, def: 350, spd: 55, critRate: 0.15, critDmg: 1.8 },
    skills: ['primal_chaos', 'stone_wall'],
    passiveDesc: '开天之力：血量低于50%时，防御力提升30%，每回合恢复最大生命值的3%。',
    passive: 'pangu_passive',
    portrait: '🗿',
    tags: ['开天', '坚韧', '不死']
  },
  {
    id: 'nvwa', name: '女娲', title: '造化神女',
    element: 'wuji', rarity: 'red',
    lore: '女娲抟土造人，炼石补天，斩鳌立极，治洪水，杀黑龙，为人族母神。',
    baseStats: { hp: 5200, atk: 420, def: 260, spd: 72, critRate: 0.18, critDmg: 1.8 },
    skills: ['herb_heal', 'earth_mother_shield'],
    passiveDesc: '补天神力：当有友方单位死亡时，50%概率将其复活并恢复30%生命值（每场战斗触发一次）。',
    passive: 'nvwa_passive',
    portrait: '🌸',
    tags: ['复活', '造物', '支援']
  },

  // ==================== 阳 ====================
  {
    id: 'donghuang', name: '东皇太一', title: '太一天帝',
    element: 'yang', rarity: 'orange',
    lore: '东皇太一，天帝之尊，统御诸神。执东皇钟，一击可震三界，为最强阳属性神明。',
    baseStats: { hp: 4800, atk: 460, def: 240, spd: 78, critRate: 0.22, critDmg: 2.0 },
    skills: ['donghuang_bell', 'yang_burst'],
    passiveDesc: '太一之威：每次攻击后，有30%概率额外对目标造成一次普攻伤害。',
    passive: 'donghuang_passive',
    portrait: '☀️',
    tags: ['天帝', '阳威', '无敌']
  },
  {
    id: 'dijun', name: '帝俊', title: '东方天帝',
    element: 'yang', rarity: 'purple',
    lore: '帝俊为上古天帝，育有十个太阳（金乌），掌管东方天界，与东皇太一并称两位上古天帝。',
    baseStats: { hp: 4200, atk: 430, def: 210, spd: 82, critRate: 0.20, critDmg: 1.9 },
    skills: ['yang_burst', 'donghuang_bell'],
    passiveDesc: '十日之主：攻击时有20%概率触发"群星燃烧"，对目标及其相邻单位造成额外50%攻击力火焰伤害。',
    passive: 'dijun_passive',
    portrait: '🌞',
    tags: ['天帝', '太阳', '爆发']
  },
  {
    id: 'jinwu', name: '金乌', title: '太阳神鸟',
    element: 'yang', rarity: 'blue',
    lore: '金乌为帝俊之子，居住在扶桑神木，是传说中的太阳神鸟，浑身金光，所过之处焦土。',
    baseStats: { hp: 3200, atk: 390, def: 160, spd: 95, critRate: 0.25, critDmg: 2.0 },
    skills: ['yang_burst', 'fire_slash'],
    passiveDesc: '太阳之翼：速度最高时，暴击伤害额外提升20%。',
    passive: 'jinwu_passive',
    portrait: '🦅',
    tags: ['速攻', '暴击', '太阳']
  },

  // ==================== 阴 ====================
  {
    id: 'change', name: '嫦娥', title: '广寒仙子',
    element: 'yin', rarity: 'orange',
    lore: '嫦娥奔月，居于广寒宫，以玉兔为伴，为最美阴属性神明，月光可幻化万千迷惑敌人。',
    baseStats: { hp: 3800, atk: 400, def: 180, spd: 85, critRate: 0.20, critDmg: 1.8 },
    skills: ['yin_curse', 'meng_po_soup'],
    passiveDesc: '月华流光：每回合开始时，对所有敌方施加层叠"月迷"效果，每层使命中率降低3%（最多5层）。',
    passive: 'change_passive',
    portrait: '🌙',
    tags: ['诅咒', '削弱', '月光']
  },
  {
    id: 'mengpo', name: '孟婆', title: '忘川渡者',
    element: 'yin', rarity: 'purple',
    lore: '孟婆守于奈何桥，以忘川水制成孟婆汤，令过桥亡魂忘却前世记忆，永堕轮回。',
    baseStats: { hp: 3600, atk: 360, def: 200, spd: 70, critRate: 0.12, critDmg: 1.6 },
    skills: ['meng_po_soup', 'yin_curse'],
    passiveDesc: '忘川之力：技能命中后，有50%概率使目标随机一个技能进入冷却状态。',
    passive: 'mengpo_passive',
    portrait: '👵',
    tags: ['控制', '失忆', '轮回']
  },
  {
    id: 'jiutian', name: '九天玄女', title: '兵法玄女',
    element: 'yin', rarity: 'purple',
    lore: '九天玄女为天帝御女，掌管兵法、符书，传授黄帝兵法，善于谋略与阴阳之术。',
    baseStats: { hp: 3900, atk: 380, def: 220, spd: 76, critRate: 0.16, critDmg: 1.7 },
    skills: ['yin_curse', 'earth_mother_shield'],
    passiveDesc: '玄阴护佑：当友方单位受到致命伤害时，30%概率使其以1点生命值存活（每场战斗每个单位触发一次）。',
    passive: 'jiutian_passive',
    portrait: '💜',
    tags: ['兵法', '护盾', '玄阴']
  },

  // ==================== 火 ====================
  {
    id: 'zhurong', name: '祝融', title: '火神圣主',
    element: 'fire', rarity: 'orange',
    lore: '祝融为上古火神，居于昆仑山之火焰之上，以火焰为武器，为共工之宿敌，神农氏之后裔。',
    baseStats: { hp: 4200, atk: 480, def: 180, spd: 80, critRate: 0.22, critDmg: 1.9 },
    skills: ['fire_god_rage', 'fire_slash'],
    passiveDesc: '烈火之心：灼烧状态下的敌人受到祝融的攻击时，额外受到其攻击力20%的真实伤害。',
    passive: 'zhurong_passive',
    portrait: '🔥',
    tags: ['火神', '灼烧', '爆发']
  },
  {
    id: 'luya', name: '陆压道人', title: '化形异人',
    element: 'fire', rarity: 'blue',
    lore: '陆压道人来历神秘，封神之战中手持"斩仙飞刀"，此刀一出，闪闪红光。',
    baseStats: { hp: 3400, atk: 440, def: 150, spd: 88, critRate: 0.25, critDmg: 2.1 },
    skills: ['fire_slash', 'fire_god_rage'],
    passiveDesc: '斩仙飞刀：攻击时有15%概率触发一次斩仙攻击，造成300%攻击力真实伤害。',
    passive: 'luya_passive',
    portrait: '⚔️',
    tags: ['速攻', '秒杀', '火系']
  },

  // ==================== 水 ====================
  {
    id: 'gonggong', name: '共工', title: '水神怒神',
    element: 'water', rarity: 'orange',
    lore: '共工为上古水神，因与颛顼争帝位失败，怒触不周山，导致天柱折断，是最暴烈的神祇之一。',
    baseStats: { hp: 4800, atk: 420, def: 280, spd: 68, critRate: 0.15, critDmg: 1.7 },
    skills: ['buzhou_collision', 'water_wave'],
    passiveDesc: '洪荒之水：每次攻击命中后，为自身恢复5%最大生命值（每回合最多恢复一次）。',
    passive: 'gonggong_passive',
    portrait: '🌊',
    tags: ['水神', '控制', '坦克']
  },
  {
    id: 'xuanming', name: '玄冥', title: '冥水之神',
    element: 'water', rarity: 'purple',
    lore: '玄冥为黄帝之臣，掌管冬水与死亡，能以冥水封冻一切，令敌人冰封于无尽冰原之中。',
    baseStats: { hp: 3600, atk: 380, def: 200, spd: 72, critRate: 0.15, critDmg: 1.7 },
    skills: ['buzhou_collision', 'water_wave'],
    passiveDesc: '冥水寒冰：被冰冻的敌人受到玄冥攻击时，额外受到15%伤害，并延长冰冻状态1回合。',
    passive: 'xuanming_passive',
    portrait: '❄️',
    tags: ['冰冻', '控制', '水系']
  },

  // ==================== 金 ====================
  {
    id: 'rushou', name: '蓐收', title: '金神秋官',
    element: 'metal', rarity: 'orange',
    lore: '蓐收为西方白帝少昊之辅佐，手持金钺，主司秋季与金属，为最具斩杀力的武神。',
    baseStats: { hp: 4000, atk: 500, def: 200, spd: 75, critRate: 0.20, critDmg: 2.2 },
    skills: ['gold_axe', 'metal_pierce'],
    passiveDesc: '钺斩之威：当蓐收攻击敌方血量低于50%的目标时，暴击率额外提升20%，暴击伤害额外提升30%。',
    passive: 'rushou_passive',
    portrait: '⚔️',
    tags: ['斩杀', '金神', '单体']
  },
  {
    id: 'taibai', name: '太白金星', title: '太白使者',
    element: 'metal', rarity: 'purple',
    lore: '太白金星（金星之神），在天庭担任使者，常奉玉帝之命下界宣旨，外表温和实则深藏不露。',
    baseStats: { hp: 3800, atk: 400, def: 240, spd: 80, critRate: 0.18, critDmg: 1.8 },
    skills: ['metal_pierce', 'gold_axe'],
    passiveDesc: '天使令牌：每场战斗开始时，随机对一名敌方单位施加"封神令"，该单位受到的所有伤害提升15%。',
    passive: 'taibai_passive',
    portrait: '⭐',
    tags: ['使者', '增伤', '金系']
  },

  // ==================== 木 ====================
  {
    id: 'shennong', name: '神农', title: '炎帝神农',
    element: 'wood', rarity: 'orange',
    lore: '神农亲尝百草，教民农耕与医药，以神木之力济世救人，为最强木属性治疗神明。',
    baseStats: { hp: 4400, atk: 320, def: 260, spd: 65, critRate: 0.10, critDmg: 1.5 },
    skills: ['herb_heal', 'revive_vine'],
    passiveDesc: '百草之神：己方单位每回合开始时，所有治疗效果提升20%。神农的技能无法被沉默。',
    passive: 'shennong_passive',
    portrait: '🌿',
    tags: ['治疗', '农业', '生命']
  },
  {
    id: 'goumang', name: '句芒', title: '春木之神',
    element: 'wood', rarity: 'purple',
    lore: '句芒为春神，主司草木生长与农业，身着绿衣，驾两龙，使万物生发。',
    baseStats: { hp: 3800, atk: 300, def: 280, spd: 68, critRate: 0.12, critDmg: 1.5 },
    skills: ['revive_vine', 'herb_heal'],
    passiveDesc: '春生之力：当一名友方单位死亡时，句芒立即恢复该单位最大生命值20%的生命值（每回合最多一次）。',
    passive: 'goumang_passive',
    portrait: '🌱',
    tags: ['春神', '复活', '支援']
  },

  // ==================== 土 ====================
  {
    id: 'houtu', name: '后土', title: '皇地祇',
    element: 'earth', rarity: 'orange',
    lore: '后土娘娘为大地之母，统御幽冥，对应天上玉皇大帝。以大地之力庇护众生，无坚不摧。',
    baseStats: { hp: 7200, atk: 360, def: 420, spd: 55, critRate: 0.10, critDmg: 1.5 },
    skills: ['earth_mother_shield', 'stone_wall'],
    passiveDesc: '大地庇护：后土死亡时，为全体友方单位提供一次免死效果（每场战斗一次）。',
    passive: 'houtu_passive',
    portrait: '🏔️',
    tags: ['坦克', '大地', '护盾']
  },
  {
    id: 'huangdi', name: '黄帝', title: '人文初祖',
    element: 'earth', rarity: 'orange',
    lore: '黄帝为华夏文明之祖，统御四方，战蚩尤，制八卦，创医书，为最具领导力的土属性神明。',
    baseStats: { hp: 5800, atk: 400, def: 360, spd: 70, critRate: 0.15, critDmg: 1.7 },
    skills: ['stone_wall', 'earth_mother_shield'],
    passiveDesc: '人文之祖：黄帝在场时，所有友方单位防御力提升15%，并对五行属性的敌人造成额外10%伤害。',
    passive: 'huangdi_passive',
    portrait: '👑',
    tags: ['领袖', '增益', '土系']
  },
];

// 构建英雄ID索引
const HERO_INDEX = {};
HEROES.forEach(h => { HERO_INDEX[h.id] = h; });

// 创建战斗用英雄实例（深拷贝，防止修改原始数据）
function createHeroInstance(heroId, level = 1, starLevel = 1) {
  const base = HERO_INDEX[heroId];
  if (!base) return null;
  const lvlMul = 1 + (level - 1) * 0.08;
  const starMul = 1 + (starLevel - 1) * 0.15;

  return {
    ...JSON.parse(JSON.stringify(base)),
    level, starLevel,
    maxHp: Math.floor(base.baseStats.hp * lvlMul * starMul),
    hp: Math.floor(base.baseStats.hp * lvlMul * starMul),
    atk: Math.floor(base.baseStats.atk * lvlMul * starMul),
    def: Math.floor(base.baseStats.def * lvlMul * starMul),
    spd: base.baseStats.spd,
    critRate: base.baseStats.critRate,
    critDmg: base.baseStats.critDmg,
    rage: 0,
    maxRage: 5,
    statusEffects: [],
    skillCooldowns: {},
    isDead: false,
    isPlayer: true,
  };
}

// 获取英雄技能数据
function getHeroSkills(heroId) {
  const hero = HERO_INDEX[heroId];
  if (!hero) return [];
  return hero.skills.map(sid => SKILLS[sid]).filter(Boolean);
}
