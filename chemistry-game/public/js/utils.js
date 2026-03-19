/**
 * 化学游戏工具函数库
 * @module utils
 */

/**
 * 防抖函数 - 限制函数执行频率
 * @param {Function} func - 要防抖的函数
 * @param {number} wait - 等待时间（毫秒）
 * @returns {Function} 防抖后的函数
 */
export function debounce(func, wait = 300) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/**
 * 节流函数 - 限制函数执行频率
 * @param {Function} func - 要节流的函数
 * @param {number} limit - 时间限制（毫秒）
 * @returns {Function} 节流后的函数
 */
export function throttle(func, limit = 300) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

/**
 * 本地存储管理器
 * @namespace storage
 */
export const storage = {
  /**
   * 保存数据到 localStorage
   * @param {string} key - 存储键名
   * @param {any} value - 存储值
   */
  save(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error('LocalStorage save error:', error);
    }
  },

  /**
   * 从 localStorage 获取数据
   * @param {string} key - 存储键名
   * @returns {any|null} 存储的值，不存在返回 null
   */
  get(key) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : null;
    } catch (error) {
      console.error('LocalStorage get error:', error);
      return null;
    }
  },

  /**
   * 从 localStorage 删除数据
   * @param {string} key - 存储键名
   */
  remove(key) {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('LocalStorage remove error:', error);
    }
  }
};

/**
 * 元素数据工具
 * @namespace elementUtils
 */
export const elementUtils = {
  /**
   * 按类别对元素分组
   * @param {Array} elements - 元素数组
   * @returns {Object} 按类别分组的对象
   */
  groupByCategory(elements) {
    return elements.reduce((groups, element) => {
      const category = element.category;
      if (!groups[category]) {
        groups[category] = [];
      }
      groups[category].push(element);
      return groups;
    }, {});
  },

  /**
   * 搜索元素
   * @param {Array} elements - 元素数组
   * @param {string} query - 搜索关键词
   * @returns {Array} 匹配的元素数组
   */
  search(elements, query) {
    if (!query) return elements;
    
    const searchTerm = query.toLowerCase().trim();
    return elements.filter(element => 
      element.name.toLowerCase().includes(searchTerm) ||
      element.symbol.toLowerCase().includes(searchTerm) ||
      element.nameEn.toLowerCase().includes(searchTerm) ||
      element.atomicNumber.toString().includes(searchTerm)
    );
  },

  /**
   * 获取元素的中文名称
   * @param {Object} element - 元素对象
   * @returns {string} 中文名称
   */
  getChineseName(element) {
    return element.name;
  },

  /**
   * 获取元素的电子排布字符串
   * @param {Object} element - 元素对象
   * @returns {string} 电子排布字符串
   */
  getElectronConfigString(element) {
    return element.electronConfig.join(') (') + ')';
  },

  /**
   * 获取元素的化合价字符串
   * @param {Object} element - 元素对象
   * @returns {string} 化合价字符串
   */
  getValenceString(element) {
    return element.valence.map(v => v > 0 ? `+${v}` : v.toString()).join(', ');
  }
};

/**
 * 实验数据工具
 * @namespace experimentUtils
 */
export const experimentUtils = {
  /**
   * 实验器材列表（用于过滤，避免错误匹配）
   */
  labEquipment: [
    '试管', '烧杯', '锥形瓶', '集气瓶', '量筒', '漏斗', '铁架台', '蒸发皿',
    '酒精灯', '石棉网', '玻璃棒', '药匙', '镊子', '滴管', '导管', '水槽',
    '天平', '砝码', '滤纸', '铁圈', '铁夹', '试管夹', '坩埚钳', '燃烧匙',
    '胶头滴管', '长颈漏斗', '分液漏斗', '容量瓶', '表面皿', '干燥管',
    'U 型管', '导管', '橡皮塞', '止水夹', '托盘', '火柴'
  ],

  /**
   * 常见溶剂/辅助试剂（不作为元素关联的主要依据）
   */
  commonSolvents: [
    '蒸馏水', '水', '自来水', '去离子水',
    '稀盐酸', '浓盐酸', '稀硫酸', '浓硫酸', '稀硝酸',
    '氢氧化钠溶液', '氢氧化钾溶液', '石灰水',
    '酒精', '乙醇', '丙酮', '汽油', '苯'
  ],

  /**
   * 判断是否为化学药品（排除实验器材）
   * @param {string} material - 材料名称
   * @returns {boolean} 是否为化学药品
   */
  isChemical(material) {
    // 检查是否包含器材关键词
    const isEquipment = this.labEquipment.some(equip => material.includes(equip));
    if (isEquipment) return false;
    
    // 检查是否为化学药品（包含化学式、酸、碱、盐等）
    const chemicalPatterns = [
      /\([A-Z][a-z]?\)/,  // 化学式括号，如 (NaCl)
      /[A-Z][a-z]?\d*/,   // 元素符号，如 H2O
      /酸$/, /碱$/, /盐$/, /溶液$/, /粉末$/, /晶体$/,
      /氢$/, /氧$/, /氮$/, /碳$/, /硫$/, /磷$/, /氯$/,
      /钠$/, /钾$/, /钙$/, /镁$/, /铝$/, /锌$/, /铁$/, /铜$/, /银$/, /钡$/,
      /石蕊$/, /酚酞$/, /石灰水$/, /双氧水$/, /盐酸$/, /硫酸$/, /硝酸$/
    ];
    
    return chemicalPatterns.some(pattern => pattern.test(material));
  },

  /**
   * 判断是否为常见溶剂/辅助试剂
   * @param {string} material - 材料名称
   * @returns {boolean} 是否为溶剂
   */
  isSolvent(material) {
    return this.commonSolvents.some(solvent => material.includes(solvent));
  },

  /**
   * 查找与元素相关的实验
   * @param {Array} experiments - 实验数组
   * @param {Object} element - 元素对象
   * @returns {Array} 相关实验数组
   */
  findByElement(experiments, element) {
    const symbol = element.symbol;
    const name = element.name;
    const nameEn = element.nameEn;
    
    return experiments.filter(exp => {
      // 检查实验名称（优先级最高）
      const inName = exp.name.includes(name);
      if (inName) return true;
      
      // 检查方程式（优先级最高）
      const inEquation = exp.equation.includes(symbol);
      if (inEquation) return true;
      
      // 检查实验用品（排除器材和溶剂）
      const inMaterials = exp.materials.some(m => {
        // 排除实验器材
        if (!this.isChemical(m)) return false;
        
        // 排除常见溶剂/辅助试剂（如水、稀酸、稀碱）
        if (this.isSolvent(m)) return false;
        
        // 检查是否包含元素符号或名称
        return m.includes(symbol) || m.includes(name) || m.includes(nameEn);
      });
      
      return inMaterials;
    });
  },

  /**
   * 按类别对实验分组
   * @param {Array} experiments - 实验数组
   * @returns {Object} 按类别分组的对象
   */
  groupByCategory(experiments) {
    return experiments.reduce((groups, exp) => {
      const category = exp.category;
      if (!groups[category]) {
        groups[category] = [];
      }
      groups[category].push(exp);
      return groups;
    }, {});
  },

  /**
   * 按难度排序实验
   * @param {Array} experiments - 实验数组
   * @param {string} order - 排序顺序 'asc' 或 'desc'
   * @returns {Array} 排序后的实验数组
   */
  sortByDifficulty(experiments, order = 'asc') {
    const difficultyValue = {
      '★☆☆': 1,
      '★★☆': 2,
      '★★★': 3
    };
    
    return [...experiments].sort((a, b) => {
      const diff = difficultyValue[a.difficulty] - difficultyValue[b.difficulty];
      return order === 'asc' ? diff : -diff;
    });
  }
};

/**
 * UI 工具
 * @namespace uiUtils
 */
export const uiUtils = {
  /**
   * 显示加载状态
   * @param {string} containerId - 容器 ID
   * @param {string} message - 加载消息
   */
  showLoading(containerId, message = '加载中...') {
    const container = document.getElementById(containerId);
    if (container) {
      container.innerHTML = `
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>${message}</p>
        </div>
      `;
    }
  },

  /**
   * 隐藏加载状态
   * @param {string} containerId - 容器 ID
   */
  hideLoading(containerId) {
    const container = document.getElementById(containerId);
    if (container) {
      const spinner = container.querySelector('.loading-spinner');
      if (spinner) spinner.remove();
    }
  },

  /**
   * 显示错误消息
   * @param {string} message - 错误消息
   * @param {number} duration - 显示时长（毫秒）
   */
  showError(message, duration = 3000) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-toast';
    errorDiv.textContent = message;
    document.body.appendChild(errorDiv);
    
    setTimeout(() => {
      errorDiv.remove();
    }, duration);
  },

  /**
   * 滚动到元素位置
   * @param {string} elementId - 元素 ID
   * @param {Object} options - 滚动选项
   */
  scrollToElement(elementId, options = { behavior: 'smooth' }) {
    const element = document.getElementById(elementId);
    if (element) {
      element.scrollIntoView(options);
    }
  },

  /**
   * 添加临时高亮效果
   * @param {HTMLElement} element - 要高亮的元素
   * @param {string} className - 高亮类名
   * @param {number} duration - 高亮时长（毫秒）
   */
  highlightElement(element, className = 'highlight', duration = 2000) {
    element.classList.add(className);
    setTimeout(() => {
      element.classList.remove(className);
    }, duration);
  }
};

/**
 * 键盘快捷键工具
 * @namespace keyboardUtils
 */
export const keyboardUtils = {
  /**
   * 注册快捷键
   * @param {Object} shortcuts - 快捷键映射 {key: handler}
   */
  register(shortcuts) {
    document.addEventListener('keydown', (e) => {
      const key = e.key.toLowerCase();
      if (shortcuts[key]) {
        // 防止在输入框中触发
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
          return;
        }
        shortcuts[key](e);
      }
    });
  },

  /**
   * 检查是否按下特定键
   * @param {KeyboardEvent} e - 键盘事件
   * @param {string} key - 键名
   * @returns {boolean} 是否按下
   */
  isKeyPressed(e, key) {
    return e.key.toLowerCase() === key.toLowerCase();
  },

  /**
   * 检查是否按下组合键
   * @param {KeyboardEvent} e - 键盘事件
   * @param {string[]} keys - 键名数组
   * @returns {boolean} 是否按下组合键
   */
  isComboPressed(e, keys) {
    return keys.every(key => {
      if (key === 'ctrl') return e.ctrlKey;
      if (key === 'shift') return e.shiftKey;
      if (key === 'alt') return e.altKey;
      return e.key.toLowerCase() === key.toLowerCase();
    });
  }
};

/**
 * 性能监控工具
 * @namespace performanceUtils
 */
export const performanceUtils = {
  /**
   * 测量函数执行时间
   * @param {Function} fn - 要测量的函数
   * @param {string} label - 标签
   * @returns {Function} 包装后的函数
   */
  measure(fn, label = 'Function') {
    return function(...args) {
      const start = performance.now();
      const result = fn.apply(this, args);
      const end = performance.now();
      console.log(`${label} executed in ${(end - start).toFixed(2)}ms`);
      return result;
    };
  },

  /**
   * 记录页面加载时间
   */
  recordPageLoad() {
    window.addEventListener('load', () => {
      const loadTime = performance.now();
      console.log(`Page loaded in ${(loadTime / 1000).toFixed(2)}s`);
      
      // 保存到 localStorage
      storage.save('pageLoadTime', loadTime);
    });
  }
};

// 导出所有工具
export default {
  debounce,
  throttle,
  storage,
  elementUtils,
  experimentUtils,
  uiUtils,
  keyboardUtils,
  performanceUtils
};
