// 化学方程式数据 - 用于方程式大爆炸游戏
export const equations = [
  // 燃烧反应
  { 
    full: '2H₂ + O₂ → 2H₂O', 
    name: '氢气燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: '2H₂ + O₂', right: '2H₂O', condition: '点燃' }
  },
  { 
    full: 'C + O₂ → CO₂', 
    name: '碳完全燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: 'C + O₂', right: 'CO₂', condition: '点燃' }
  },
  { 
    full: '2C + O₂ → 2CO', 
    name: '碳不完全燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: '2C + O₂', right: '2CO', condition: '点燃' }
  },
  { 
    full: 'S + O₂ → SO₂', 
    name: '硫燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: 'S + O₂', right: 'SO₂', condition: '点燃' }
  },
  { 
    full: '4P + 5O₂ → 2P₂O₅', 
    name: '磷燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: '4P + 5O₂', right: '2P₂O₅', condition: '点燃' }
  },
  { 
    full: '2Mg + O₂ → 2MgO', 
    name: '镁条燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: '2Mg + O₂', right: '2MgO', condition: '点燃' }
  },
  { 
    full: '4Al + 3O₂ → 2Al₂O₃', 
    name: '铝燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: '4Al + 3O₂', right: '2Al₂O₃', condition: '点燃' }
  },
  { 
    full: '3Fe + 2O₂ → Fe₃O₄', 
    name: '铁丝在氧气中燃烧',
    condition: '点燃',
    type: '化合反应',
    parts: { left: '3Fe + 2O₂', right: 'Fe₃O₄', condition: '点燃' }
  },
  { 
    full: '2Cu + O₂ → 2CuO', 
    name: '铜加热氧化',
    condition: '加热',
    type: '化合反应',
    parts: { left: '2Cu + O₂', right: '2CuO', condition: '加热' }
  },
  
  // 分解反应
  { 
    full: '2H₂O₂ → 2H₂O + O₂↑', 
    name: '双氧水分解',
    condition: 'MnO₂催化',
    type: '分解反应',
    parts: { left: '2H₂O₂', right: '2H₂O + O₂↑', condition: 'MnO₂催化' }
  },
  { 
    full: '2KClO₃ → 2KCl + 3O₂↑', 
    name: '氯酸钾分解',
    condition: 'MnO₂催化、加热',
    type: '分解反应',
    parts: { left: '2KClO₃', right: '2KCl + 3O₂↑', condition: 'MnO₂催化、加热' }
  },
  { 
    full: '2KMnO₄ → K₂MnO₄ + MnO₂ + O₂↑', 
    name: '高锰酸钾分解',
    condition: '加热',
    type: '分解反应',
    parts: { left: '2KMnO₄', right: 'K₂MnO₄ + MnO₂ + O₂↑', condition: '加热' }
  },
  { 
    full: 'CaCO₃ → CaO + CO₂↑', 
    name: '碳酸钙分解',
    condition: '高温',
    type: '分解反应',
    parts: { left: 'CaCO₃', right: 'CaO + CO₂↑', condition: '高温' }
  },
  { 
    full: '2H₂O → 2H₂↑ + O₂↑', 
    name: '水电解',
    condition: '通电',
    type: '分解反应',
    parts: { left: '2H₂O', right: '2H₂↑ + O₂↑', condition: '通电' }
  },
  
  // 置换反应
  { 
    full: 'Zn + 2HCl → ZnCl₂ + H₂↑', 
    name: '锌与盐酸反应',
    condition: '常温',
    type: '置换反应',
    parts: { left: 'Zn + 2HCl', right: 'ZnCl₂ + H₂↑', condition: '常温' }
  },
  { 
    full: 'Zn + H₂SO₄ → ZnSO₄ + H₂↑', 
    name: '锌与稀硫酸反应',
    condition: '常温',
    type: '置换反应',
    parts: { left: 'Zn + H₂SO₄', right: 'ZnSO₄ + H₂↑', condition: '常温' }
  },
  { 
    full: 'Fe + 2HCl → FeCl₂ + H₂↑', 
    name: '铁与盐酸反应',
    condition: '常温',
    type: '置换反应',
    parts: { left: 'Fe + 2HCl', right: 'FeCl₂ + H₂↑', condition: '常温' }
  },
  { 
    full: 'Mg + 2HCl → MgCl₂ + H₂↑', 
    name: '镁与盐酸反应',
    condition: '常温',
    type: '置换反应',
    parts: { left: 'Mg + 2HCl', right: 'MgCl₂ + H₂↑', condition: '常温' }
  },
  { 
    full: '2Al + 6HCl → 2AlCl₃ + 3H₂↑', 
    name: '铝与盐酸反应',
    condition: '常温',
    type: '置换反应',
    parts: { left: '2Al + 6HCl', right: '2AlCl₃ + 3H₂↑', condition: '常温' }
  },
  { 
    full: 'Fe + CuSO₄ → FeSO₄ + Cu', 
    name: '铁置换铜',
    condition: '常温',
    type: '置换反应',
    parts: { left: 'Fe + CuSO₄', right: 'FeSO₄ + Cu', condition: '常温' }
  },
  { 
    full: 'Cu + 2AgNO₃ → Cu(NO₃)₂ + 2Ag', 
    name: '铜置换银',
    condition: '常温',
    type: '置换反应',
    parts: { left: 'Cu + 2AgNO₃', right: 'Cu(NO₃)₂ + 2Ag', condition: '常温' }
  },
  
  // 复分解反应
  { 
    full: 'HCl + NaOH → NaCl + H₂O', 
    name: '盐酸与氢氧化钠中和',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'HCl + NaOH', right: 'NaCl + H₂O', condition: '常温' }
  },
  { 
    full: 'H₂SO₄ + 2NaOH → Na₂SO₄ + 2H₂O', 
    name: '硫酸与氢氧化钠中和',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'H₂SO₄ + 2NaOH', right: 'Na₂SO₄ + 2H₂O', condition: '常温' }
  },
  { 
    full: 'CaCO₃ + 2HCl → CaCl₂ + H₂O + CO₂↑', 
    name: '实验室制二氧化碳',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'CaCO₃ + 2HCl', right: 'CaCl₂ + H₂O + CO₂↑', condition: '常温' }
  },
  { 
    full: 'Na₂CO₃ + 2HCl → 2NaCl + H₂O + CO₂↑', 
    name: '碳酸钠与盐酸反应',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'Na₂CO₃ + 2HCl', right: '2NaCl + H₂O + CO₂↑', condition: '常温' }
  },
  { 
    full: 'NaOH + HCl → NaCl + H₂O', 
    name: '氢氧化钠与盐酸中和',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'NaOH + HCl', right: 'NaCl + H₂O', condition: '常温' }
  },
  { 
    full: 'AgNO₃ + HCl → AgCl↓ + HNO₃', 
    name: '硝酸银与盐酸反应',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'AgNO₃ + HCl', right: 'AgCl↓ + HNO₃', condition: '常温' }
  },
  { 
    full: 'BaCl₂ + H₂SO₄ → BaSO₄↓ + 2HCl', 
    name: '氯化钡与硫酸反应',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'BaCl₂ + H₂SO₄', right: 'BaSO₄↓ + 2HCl', condition: '常温' }
  },
  
  // 其他重要反应
  { 
    full: 'N₂ + 3H₂ ⇌ 2NH₃', 
    name: '合成氨',
    condition: '高温高压催化剂',
    type: '化合反应',
    parts: { left: 'N₂ + 3H₂', right: '2NH₃', condition: '高温高压催化剂' }
  },
  { 
    full: 'CO₂ + H₂O → H₂CO₃', 
    name: '二氧化碳溶于水',
    condition: '常温',
    type: '化合反应',
    parts: { left: 'CO₂ + H₂O', right: 'H₂CO₃', condition: '常温' }
  },
  { 
    full: 'CaO + H₂O → Ca(OH)₂', 
    name: '生石灰与水反应',
    condition: '常温',
    type: '化合反应',
    parts: { left: 'CaO + H₂O', right: 'Ca(OH)₂', condition: '常温' }
  },
  { 
    full: 'CO₂ + Ca(OH)₂ → CaCO₃↓ + H₂O', 
    name: '检验二氧化碳',
    condition: '常温',
    type: '复分解反应',
    parts: { left: 'CO₂ + Ca(OH)₂', right: 'CaCO₃↓ + H₂O', condition: '常温' }
  },
  { 
    full: 'CH₄ + 2O₂ → CO₂ + 2H₂O', 
    name: '甲烷燃烧',
    condition: '点燃',
    type: '氧化反应',
    parts: { left: 'CH₄ + 2O₂', right: 'CO₂ + 2H₂O', condition: '点燃' }
  },
  { 
    full: 'C₂H₅OH + 3O₂ → 2CO₂ + 3H₂O', 
    name: '乙醇燃烧',
    condition: '点燃',
    type: '氧化反应',
    parts: { left: 'C₂H₅OH + 3O₂', right: '2CO₂ + 3H₂O', condition: '点燃' }
  },
  { 
    full: '6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂', 
    name: '光合作用',
    condition: '光照、叶绿素',
    type: '合成反应',
    parts: { left: '6CO₂ + 6H₂O', right: 'C₆H₁₂O₆ + 6O₂', condition: '光照、叶绿素' }
  },
  { 
    full: 'C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O', 
    name: '呼吸作用',
    condition: '酶催化',
    type: '氧化反应',
    parts: { left: 'C₆H₁₂O₆ + 6O₂', right: '6CO₂ + 6H₂O', condition: '酶催化' }
  },
];

// 生成错误选项
export function generateWrongOptions(correct, questionType) {
  const wrongOptions = [];
  const used = new Set([correct]);
  
  while (wrongOptions.length < 3) {
    let wrong;
    
    if (questionType === 'left') {
      // 生成错误的左边
      const randomEq = equations[Math.floor(Math.random() * equations.length)];
      wrong = randomEq.parts.left;
    } else if (questionType === 'right') {
      // 生成错误的右边
      const randomEq = equations[Math.floor(Math.random() * equations.length)];
      wrong = randomEq.parts.right;
    } else if (questionType === 'condition') {
      // 生成错误的条件
      const conditions = ['点燃', '加热', '高温', '常温', '通电', '催化剂', '光照', 'MnO₂催化'];
      wrong = conditions[Math.floor(Math.random() * conditions.length)];
    }
    
    if (wrong !== correct && !used.has(wrong)) {
      wrongOptions.push(wrong);
      used.add(wrong);
    }
  }
  
  return wrongOptions;
}

// 从反应物或生成物中选择一个物质隐藏
function selectPartToHide(parts, side) {
  const items = side === 'left' ? parts.left : parts.right;
  // 如果有 + 号，说明有多个物质
  if (items.includes(' + ')) {
    const substances = items.split(' + ');
    // 随机选择一个隐藏
    const hideIndex = Math.floor(Math.random() * substances.length);
    const hidden = substances[hideIndex];
    substances[hideIndex] = '___';
    const display = substances.join(' + ');
    
    return {
      leftDisplay: side === 'left' ? display : parts.left,
      rightDisplay: side === 'right' ? display : parts.right,
      correct: hidden,
      questionType: side
    };
  }
  return null;
}

// 随机选择一个方程式生成问题
export function generateQuestion() {
  const eq = equations[Math.floor(Math.random() * equations.length)];
  
  // 30% 概率出条件题，70% 概率出物质题
  const isConditionQuestion = Math.random() < 0.3;
  
  let questionData = null;
  
  // 如果随机到条件题，且方程式有条件
  if (isConditionQuestion && eq.parts.condition) {
    questionData = {
      leftDisplay: eq.parts.left,
      rightDisplay: eq.parts.right,
      correct: eq.parts.condition,
      questionType: 'condition'
    };
  }
  
  // 如果不是条件题，尝试从左右边选择一个物质隐藏
  if (!questionData) {
    // 优先选择有多个反应物或生成物的方程式
    if (eq.parts.left.includes(' + ')) {
      questionData = selectPartToHide(eq.parts, 'left');
    } else if (eq.parts.right.includes(' + ')) {
      questionData = selectPartToHide(eq.parts, 'right');
    }
  }
  
  // 如果都没有多个物质，则随机选择左边、右边或条件
  if (!questionData) {
    const types = ['left', 'right', 'condition'];
    const questionType = types[Math.floor(Math.random() * types.length)];
    
    let leftDisplay, rightDisplay, correct;
    
    if (questionType === 'left') {
      leftDisplay = '___';
      rightDisplay = eq.parts.right;
      correct = eq.parts.left;
    } else if (questionType === 'right') {
      leftDisplay = eq.parts.left;
      rightDisplay = '___';
      correct = eq.parts.right;
    } else {
      leftDisplay = eq.parts.left;
      rightDisplay = eq.parts.right;
      correct = eq.parts.condition || '常温';
    }
    
    questionData = { leftDisplay, rightDisplay, correct, questionType };
  }
  
  const { leftDisplay, rightDisplay, correct, questionType } = questionData;
  const wrongOptions = generateWrongOptions(correct, questionType);
  const options = shuffleArray([correct, ...wrongOptions]);
  
  // 生成显示用的方程式
  const display = `${leftDisplay} ${eq.parts.condition && questionType !== 'condition' ? `[${eq.parts.condition}]` : ''}→ ${rightDisplay}`;
  
  return {
    question: display,
    display,
    leftDisplay,
    rightDisplay,
    correct,
    options,
    equationName: eq.name,
    equationType: eq.type,
    questionType,
    parts: eq.parts
  };
}

function shuffleArray(array) {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}
