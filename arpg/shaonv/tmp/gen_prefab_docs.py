#!/usr/bin/env python3
"""Batch generate 4 prefab analysis docs."""
import json, os

BASE = 'D:/work/openclaw-workspace/arpg/shaonv'
LAYOUT = f'{BASE}/reverse-output/godot-layout-inspect'
DOCS = f'{BASE}/docs/prefabs'

def analyze_prefab(name, json_path, extra_info=""):
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    tc = data.get('typeCounts', {})
    nc = data.get('nodeCount', 0)
    roots = data['roots']

    # Component counts
    mono = tc.get('MonoBehaviour', 0)
    cg = tc.get('CanvasGroup', 0)
    ps = tc.get('ParticleSystem', 0)
    anim = tc.get('Animator', 0)
    src = data.get('source', '').split('\\')[-1]

    # Build tree
    lines = []
    def print_tree(node, depth=0):
        nm = node.get('name','?')
        r = node.get('rect', {}) or {}
        sz = r.get('sizeDelta', [0,0])
        pos = r.get('anchoredPosition', [0,0])
        anc = r.get('anchorMin', [0,0])
        act = node.get('active', True)
        cts = node.get('componentTypes', []) or []
        cg_s = ' CG' if 'CanvasGroup' in cts else ''
        ps_s = ' PS' if 'ParticleSystem' in cts else ''
        an_s = ' Anim' if 'Animator' in cts else ''
        off = ' OFF' if act is False else ''
        mb = cts.count('MonoBehaviour')
        extra = f'[{mb}M]{cg_s}{ps_s}{an_s}'
        if depth <= 3:
            prefix = '  ' * depth
            lines.append(f'{prefix}- `{nm}` ({pos[0]:.0f},{pos[1]:.0f}) {sz[0]:.0f}×{sz[1]:.0f} {extra}{off}')
        for child in node.get('children', []):
            print_tree(child, depth+1)

    for r in roots:
        print_tree(r)

    tree_text = '\n'.join(lines)

    # Count interactive
    interactive = sum(1 for n in data.get('nodes',[]) if n.get('componentTypes',[]).count('MonoBehaviour') >= 2)

    # Count @-prefabs and panels
    at_prefabs = sorted(set(n['name'] for n in data['nodes'] if n['name'].startswith('@')))
    panels = sorted(set(n['name'] for n in data['nodes'] if n['name'].startswith('pnl')))

    # List all buttons with sizes
    buttons = []
    for n in data['nodes']:
        nm = n.get('name','')
        r = n.get('rect', {}) or {}
        sz = r.get('sizeDelta', [0,0])
        if nm.startswith('btn') and sz[0] > 0:
            buttons.append(f"  - `{nm}` ({sz[0]:.0f}×{sz[1]:.0f})")

    doc = f"""# {name} Prefab 布局分析

> 自动生成 · 2026-05-23 · {nc} 节点

## 基本信息

| 字段 | 值 |
|------|-----|
| Bundle | `{src}` |
| 节点数 | {nc} |
| MonoBehaviour | {mono} |
| CanvasGroup | {cg} |
| ParticleSystem | {ps} |
| Animator | {anim} |
| 根节点 | {', '.join(r['name'] for r in roots)} |
| 交互式元素 | {interactive} (MonoB≥2) |

## 完整 RectTransform 层级

```
{tree_text}
```

## 按钮清单 ({len(buttons)}个)

{chr(10).join(buttons[:30])}

## @prefab 实例 ({len(at_prefabs)}个)

{chr(10).join(f'  - {a}' for a in at_prefabs)}

## 面板命名 ({len(panels)}个)

{chr(10).join(f'  - {p}' for p in panels)}

{extra_info}
"""
    return doc


# ── Prefab 4: TopResGrid ──
doc = analyze_prefab('TopResGrid', f'{LAYOUT}/TopResGrid.layout.json', 
"""## 组件分析

TopResGrid 是 MainUIView 的 `svRes/Content` 内部的**资源项单元格 prefab**。

### 结构
```
TopResGrid (200×40, center anchor)
  imgBg (200×40) ← 半透明背景
  imgIcon (-5,1) 50×50 ← 资源图标
  txtNum (27,0) 130×40 ← 数量
  btnClick (0,0) 200×40 OFF ← 默认禁用
  txtTitle (11,0) 160×30 OFF ← 默认禁用
```

### 用途
MainUI 顶部资源栏 (svRes) 中，每项资源（邮件、唤灵券、源石）是一个 TopResGrid 实例，由 `RefreshTopBar()` 动态创建。

### 对比 Godot MVP
| 项目 | 原始 | Godot |
|------|------|-------|
| 布局 | imgIcon(50×50) + txtNum(130×40) | 纯文本 `"邮件 %d"` |
| 背景 | imgBg 半透明圆角 | 色块面板 |

### 建议
- svRes 应改用 icon + number 的卡片式布局
- 当前可用 mainui 的 button sprite 作为临时图标
""")
with open(f'{DOCS}/TopResGrid-layout-analysis-2026-05-23.md', 'w', encoding='utf-8') as f:
    f.write(doc)
print('TopResGrid done')


# ── Prefab 5: LotteryDrawMainView ──
doc = analyze_prefab('LotteryDrawMainView', f'{LAYOUT}/LotteryDrawMainView.layout.json',
"""## 组件深度分析

### 面板结构
```
LotteryDrawMainView (全屏, Anim+CG)
  pnlRoot → 根容器
    ├── pnlSkipAnim      → 跳过动画栏 (tglSkip + btnSkipAnim)
    ├── pnlBtn (64,78) 500×60 → 底部功能按钮行(5个60×60)
    ├── pnlLeft (835,0)       → 左侧英雄展示区
    │   └── tabView (170,39)  → Tab 标签切换
    ├── pnlNormalWish (-62,-196) 304×52 → 普通愿望
    └── pnlEpicWish (-83,179) 204×52 → 史诗愿望
```

### 32 CanvasGroup 面板管理
类似 MainUIView 的 `listPanel` 模式，每个 CanvasGroup 控制一组 UI 的显隐。

### 对比 Godot MVP
| 项目 | 原始 | Godot gacha_screen.gd |
|------|------|-------|
| Tab 系统 | tabView + 5 @LotteryDrawTabGrid | 文字标签替代 |
| 愿望系统 | pnlNormalWish + pnlEpicWish + hero slots | 无 |
| 跳过动画 | pnlSkipAnim + tglSkip | 无 |
| 按钮行 | 5个60×60排列 | 简化版 |

### 建议
- 实现 Tab 切换 (限时/普通/新手/回归/积分)
- 添加愿望 hero slot (5个70×70)
""")
with open(f'{DOCS}/LotteryDrawMainView-layout-analysis-2026-05-23.md', 'w', encoding='utf-8') as f:
    f.write(doc)
print('LotteryDrawMainView done')


# ── Prefab 6: HeroRecruitView ──  
doc = analyze_prefab('HeroRecruitView', f'{LAYOUT}/HeroRecruitView.layout.json',
f"""## 组件深度分析

### 核心演出分层
```
HeroRecruitView (全屏, Anim+CG)
  ├── imgBg → 4色稀有度背景 (@imgBg_blue/purple/yellow/red)
  ├── pnlMessage → 主演出层 (CG)
  │   ├── @fx_01 → vfx 入场粒子
  │   ├── pnlHeroSilhouette → spSilhouette 剪影
  │   ├── @fx_03 → vfx 揭示粒子
  │   ├── irole (958×750) → spBg/spHero/spFg 三层 Spine
  │   │   ├── btn (418×804) 大点击区
  │   │   └── imgSpeak (668×154) OFF 对话气泡
  │   ├── @fx_02 → vfx2 收尾粒子
  │   ├── @ImgFrame_blue~red → 4色稀有度边框(1670×437)
  │   ├── spineHeroQ + spineHeroQReflection
  │   └── pnlInfo → 角色信息(稀有度图标+名字+标签+职业)
  └── pnlVideo → 视频层(VideoPlayer + btnSkipVideo OFF)
```

### 12 ParticleSystem 特效
- caiguang2 ×3 (彩光)
- glow/glow2 (金色光晕)
- gyunlizi3/gyunlizi7 (旋转粒子流)
- vfx ×3 (入场/揭示/收尾特效)

### 8 CanvasGroup
pnlMessage 下有 8 个 CG，分别控制剪影/Spine/边框/信息的显隐时序。

### 对比 Godot MVP
| 项目 | 原始 | Godot gacha_result_screen.gd |
|------|------|-------|
| 演出分层 | 8 层 CG 时序控制 | 简化遮罩+文字 |
| 剪影→揭示→角色→边框 | 完整流程 | 无 |
| 4 色稀有度切换 | 背景+边框+标签 3套 | 色块模拟 |
| 12 ParticleSystem | 完整 VFX | 无 |

### 建议
- 即使不用 ParticleSystem，至少用 Tween 实现剪影→角色→边框的时序动画
- 稀有度边框可先用 ColorRect 模拟，后续替换真实图片
""")
with open(f'{DOCS}/HeroRecruitView-layout-analysis-2026-05-23.md', 'w', encoding='utf-8') as f:
    f.write(doc)
print('HeroRecruitView done')


# ── Prefab 7: LotteryDrawFinishView ──
doc = analyze_prefab('LotteryDrawFinishView', f'{LAYOUT}/LotteryDrawFinishView.layout.json',
f"""## 组件深度分析

### VFX 核心
LotteryDrawFinishView 有 **190 个 ParticleSystem** 和 **40 个 Animator**，是全部 prefab 中 VFX 密度最高的。

### 光效系统
```
LotteryDrawFinishView (全屏)
  ├── imgBg (1670×750) → Canvas + 结果背景
  │   ├── @pnlLight01~10 → 10个光效容器(40 mask 层)
  │   │   ├── light01_mask~light10_mask (active)
  │   │   └── light01_colormask~light10_colormask (OFF)
  │   └── 稀有度光效层:
  │       ├── fx_light ×8 (Triggers)
  │       ├── light_blue ×10 (OFF)
  │       ├── light_orange ×8 (含 Animator + vfx 粒子层)
  │       ├── light_purple ×10 (OFF)
  │       ├── light_red ×10 (OFF)
  │       └── vfx ×40 → GameObject → gzhu/gzhu2/gzhu3/gzhu4/gzhu6
  └── 40 Animator → 光效动画状态机
```

### 粒子特效
- gzhu/gzhu2/gzhu3/gzhu4/gzhu6 × 多个实例
- 每层 vfx 包含 4-5 种粒子组合
- light_orange 内部有 Animator 控制

### 对比 Godot MVP
| 项目 | 原始 | Godot |
|------|------|-------|
| ParticleSystem | 190 | 0 (全部缺失) |
| Animator | 40 | 0 |
| light mask | 20 个 | 0 |
| 稀有度光效 | 4色80+实例 | 色块模拟 |

### 建议
- 190 PS 不可行 → 用 Godot Tween/AnimationPlayer 模拟光效
- 至少实现 4 色稀有度光效的颜色切换 (ColorRect alpha anim)
""")
with open(f'{DOCS}/LotteryDrawFinishView-layout-analysis-2026-05-23.md', 'w', encoding='utf-8') as f:
    f.write(doc)
print('LotteryDrawFinishView done')

print('\\nAll 7 docs generated!')
