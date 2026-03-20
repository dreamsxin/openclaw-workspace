// 化合物配对规则 - 用于元素消消乐
export const compounds = [
  // 氧化物
  { formula: 'H₂O', name: '水', elements: [{ symbol: 'H', count: 2, valence: 1 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'CO₂', name: '二氧化碳', elements: [{ symbol: 'C', count: 1, valence: 4 }, { symbol: 'O', count: 2, valence: -2 }] },
  { formula: 'CO', name: '一氧化碳', elements: [{ symbol: 'C', count: 1, valence: 2 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'MgO', name: '氧化镁', elements: [{ symbol: 'Mg', count: 1, valence: 2 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'CaO', name: '氧化钙', elements: [{ symbol: 'Ca', count: 1, valence: 2 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'Na₂O', name: '氧化钠', elements: [{ symbol: 'Na', count: 2, valence: 1 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'Al₂O₃', name: '氧化铝', elements: [{ symbol: 'Al', count: 2, valence: 3 }, { symbol: 'O', count: 3, valence: -2 }] },
  { formula: 'Fe₂O₃', name: '氧化铁', elements: [{ symbol: 'Fe', count: 2, valence: 3 }, { symbol: 'O', count: 3, valence: -2 }] },
  { formula: 'CuO', name: '氧化铜', elements: [{ symbol: 'Cu', count: 1, valence: 2 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'ZnO', name: '氧化锌', elements: [{ symbol: 'Zn', count: 1, valence: 2 }, { symbol: 'O', count: 1, valence: -2 }] },
  { formula: 'SiO₂', name: '二氧化硅', elements: [{ symbol: 'Si', count: 1, valence: 4 }, { symbol: 'O', count: 2, valence: -2 }] },
  { formula: 'SO₂', name: '二氧化硫', elements: [{ symbol: 'S', count: 1, valence: 4 }, { symbol: 'O', count: 2, valence: -2 }] },
  
  // 氯化物
  { formula: 'NaCl', name: '氯化钠', elements: [{ symbol: 'Na', count: 1, valence: 1 }, { symbol: 'Cl', count: 1, valence: -1 }] },
  { formula: 'HCl', name: '氯化氢', elements: [{ symbol: 'H', count: 1, valence: 1 }, { symbol: 'Cl', count: 1, valence: -1 }] },
  { formula: 'KCl', name: '氯化钾', elements: [{ symbol: 'K', count: 1, valence: 1 }, { symbol: 'Cl', count: 1, valence: -1 }] },
  { formula: 'MgCl₂', name: '氯化镁', elements: [{ symbol: 'Mg', count: 1, valence: 2 }, { symbol: 'Cl', count: 2, valence: -1 }] },
  { formula: 'CaCl₂', name: '氯化钙', elements: [{ symbol: 'Ca', count: 1, valence: 2 }, { symbol: 'Cl', count: 2, valence: -1 }] },
  { formula: 'AlCl₃', name: '氯化铝', elements: [{ symbol: 'Al', count: 1, valence: 3 }, { symbol: 'Cl', count: 3, valence: -1 }] },
  { formula: 'FeCl₃', name: '氯化铁', elements: [{ symbol: 'Fe', count: 1, valence: 3 }, { symbol: 'Cl', count: 3, valence: -1 }] },
  { formula: 'ZnCl₂', name: '氯化锌', elements: [{ symbol: 'Zn', count: 1, valence: 2 }, { symbol: 'Cl', count: 2, valence: -1 }] },
  { formula: 'CuCl₂', name: '氯化铜', elements: [{ symbol: 'Cu', count: 1, valence: 2 }, { symbol: 'Cl', count: 2, valence: -1 }] },
  
  // 氢化物
  { formula: 'NH₃', name: '氨气', elements: [{ symbol: 'N', count: 1, valence: -3 }, { symbol: 'H', count: 3, valence: 1 }] },
  { formula: 'CH₄', name: '甲烷', elements: [{ symbol: 'C', count: 1, valence: -4 }, { symbol: 'H', count: 4, valence: 1 }] },
  { formula: 'HF', name: '氟化氢', elements: [{ symbol: 'H', count: 1, valence: 1 }, { symbol: 'F', count: 1, valence: -1 }] },
  
  // 硫化物
  { formula: 'H₂S', name: '硫化氢', elements: [{ symbol: 'H', count: 2, valence: 1 }, { symbol: 'S', count: 1, valence: -2 }] },
  { formula: 'Na₂S', name: '硫化钠', elements: [{ symbol: 'Na', count: 2, valence: 1 }, { symbol: 'S', count: 1, valence: -2 }] },
  { formula: 'FeS', name: '硫化亚铁', elements: [{ symbol: 'Fe', count: 1, valence: 2 }, { symbol: 'S', count: 1, valence: -2 }] },
  
  // 其他
  { formula: 'NaOH', name: '氢氧化钠', elements: [{ symbol: 'Na', count: 1, valence: 1 }, { symbol: 'O', count: 1, valence: -2 }, { symbol: 'H', count: 1, valence: 1 }] },
  { formula: 'CaCO₃', name: '碳酸钙', elements: [{ symbol: 'Ca', count: 1, valence: 2 }, { symbol: 'C', count: 1, valence: 4 }, { symbol: 'O', count: 3, valence: -2 }] },
  { formula: 'Na₂CO₃', name: '碳酸钠', elements: [{ symbol: 'Na', count: 2, valence: 1 }, { symbol: 'C', count: 1, valence: 4 }, { symbol: 'O', count: 3, valence: -2 }] },
  { formula: 'AgCl', name: '氯化银', elements: [{ symbol: 'Ag', count: 1, valence: 1 }, { symbol: 'Cl', count: 1, valence: -1 }] },
  { formula: 'AgNO₃', name: '硝酸银', elements: [{ symbol: 'Ag', count: 1, valence: 1 }, { symbol: 'N', count: 1, valence: 5 }, { symbol: 'O', count: 3, valence: -2 }] },
  { formula: 'KMnO₄', name: '高锰酸钾', elements: [{ symbol: 'K', count: 1, valence: 1 }, { symbol: 'Mn', count: 1, valence: 7 }, { symbol: 'O', count: 4, valence: -2 }] },
  { formula: 'H₂SO₄', name: '硫酸', elements: [{ symbol: 'H', count: 2, valence: 1 }, { symbol: 'S', count: 1, valence: 6 }, { symbol: 'O', count: 4, valence: -2 }] },
  { formula: 'HNO₃', name: '硝酸', elements: [{ symbol: 'H', count: 1, valence: 1 }, { symbol: 'N', count: 1, valence: 5 }, { symbol: 'O', count: 3, valence: -2 }] },
  { formula: 'H₃PO₄', name: '磷酸', elements: [{ symbol: 'H', count: 3, valence: 1 }, { symbol: 'P', count: 1, valence: 5 }, { symbol: 'O', count: 4, valence: -2 }] },
  
  // 单质（相同元素配对）
  { formula: 'H₂', name: '氢气', elements: [{ symbol: 'H', count: 2, valence: 0 }] },
  { formula: 'O₂', name: '氧气', elements: [{ symbol: 'O', count: 2, valence: 0 }] },
  { formula: 'N₂', name: '氮气', elements: [{ symbol: 'N', count: 2, valence: 0 }] },
  { formula: 'Cl₂', name: '氯气', elements: [{ symbol: 'Cl', count: 2, valence: 0 }] },
  { formula: 'Fe', name: '铁', elements: [{ symbol: 'Fe', count: 1, valence: 0 }] },
  { formula: 'Cu', name: '铜', elements: [{ symbol: 'Cu', count: 1, valence: 0 }] },
  { formula: 'Ag', name: '银', elements: [{ symbol: 'Ag', count: 1, valence: 0 }] },
  { formula: 'C', name: '碳', elements: [{ symbol: 'C', count: 1, valence: 0 }] },
  { formula: 'S', name: '硫', elements: [{ symbol: 'S', count: 1, valence: 0 }] },
];

// 检查两个元素是否能组成化合物
export function canFormCompound(tile1, tile2) {
  for (const compound of compounds) {
    if (compound.elements.length < 2) continue;
    
    // 简化：只检查二元化合物
    if (compound.elements.length === 2) {
      const elem1 = compound.elements[0];
      const elem2 = compound.elements[1];
      
      // 检查是否匹配（顺序无关）
      const match1 = (tile1.symbol === elem1.symbol && tile2.symbol === elem2.symbol);
      const match2 = (tile1.symbol === elem2.symbol && tile2.symbol === elem1.symbol);
      
      if (match1 || match2) {
        return { valid: true, compound };
      }
    }
  }
  
  return { valid: false, compound: null };
}

// 获取所有可能的配对
export function getPossibleMatches(tiles) {
  const matches = [];
  
  for (let i = 0; i < tiles.length; i++) {
    for (let j = i + 1; j < tiles.length; j++) {
      const result = canFormCompound(tiles[i], tiles[j]);
      if (result.valid) {
        matches.push({ tile1: tiles[i], tile2: tiles[j], compound: result.compound });
      }
    }
  }
  
  return matches;
}
