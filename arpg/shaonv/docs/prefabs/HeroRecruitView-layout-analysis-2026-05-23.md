# HeroRecruitView Prefab 布局分析

> 自动生成 · 2026-05-23 · 186 节点

## 基本信息

| 字段 | 值 |
|------|-----|
| Bundle | `__data` |
| 节点数 | 186 |
| MonoBehaviour | 243 |
| CanvasGroup | 8 |
| ParticleSystem | 12 |
| Animator | 1 |
| 根节点 | HeroRecruitView |
| 交互式元素 | 66 (MonoB≥2) |

## 完整 RectTransform 层级

```
- `HeroRecruitView` (0,0) 0×0 [0M]
  - `imgBg` (0,0) 1670×750 [0M]
    - `@imgBg_blue` (0,0) 1670×750 [0M] OFF
    - `@imgBg_purple` (0,0) 1670×750 [0M] OFF
    - `@imgBg_yellow` (0,0) 1670×750 [0M] OFF
    - `@imgBg_red` (0,0) 1670×750 [0M] OFF
  - `pnlMessage` (0,0) 0×0 [0M]
    - `@fx_HeroRecruitView_01` (147,0) 100×100 [0M]
      - `vfx` (0,0) 100×100 [0M]
    - `pnlHeroSilhouette` (199,0) 958×750 [0M]
      - `spSilhouette` (0,-334) 100×100 [0M]
    - `@fx_HeroRecruitView_03` (147,0) 100×100 [0M]
      - `vfx` (0,0) 100×100 [0M]
    - `irole` (199,0) 958×750 [0M]
      - `btn` (0,272) 418×804 [0M]
      - `spBg` (0,0) 100×100 [0M]
      - `spHero` (0,0) 100×100 [0M]
      - `spFg` (0,0) 100×100 [0M]
      - `imgMask` (0,0) 324×274 [0M]
      - `imgSpeak` (0,85) 668×154 [0M] OFF
    - `@fx_HeroRecruitView_02` (147,0) 100×100 [0M]
      - `vfx2` (0,0) 100×100 [0M]
    - `@ImgFrame_blue` (0,-156) 1670×437 [0M] OFF
      - `ImgFrame_blue_l` (-418,218) 835×437 [0M] OFF
      - `ImgFrame_blue_r` (418,218) 835×437 [0M] OFF
      - `ImgFrame_blue` (0,218) 1670×437 [0M]
    - `@ImgFrame_purple` (0,-156) 1670×437 [0M] OFF
      - `ImgFrame_purple_l` (-418,218) 835×437 [0M] OFF
      - `ImgFrame_purple_r` (418,218) 835×437 [0M] OFF
      - `ImgFrame_purple` (0,218) 1670×437 [0M]
    - `@ImgFrame_yellow` (0,-156) 1670×437 [0M] OFF
      - `ImgFrame_yellow_l` (-418,218) 835×437 [0M] OFF
      - `ImgFrame_yellow_r` (418,218) 835×437 [0M] OFF
      - `ImgFrame_yellow` (0,218) 1670×437 [0M]
    - `@ImgFrame_red` (0,-156) 1670×437 [0M] OFF
      - `ImgFrame_red_l` (-418,218) 835×437 [0M] OFF
      - `ImgFrame_red_r` (418,218) 835×437 [0M] OFF
      - `ImgFrame_red` (0,218) 1670×437 [0M]
    - `spineHeroQReflection` (-484,-325) 100×100 [0M]
    - `spineHeroQ` (-484,-330) 100×100 [0M]
    - `pnlInfo` (-459,-20) 410×70 [0M]
      - `@imgTypeNew_33` (-17,164) 222×222 [0M] OFF
      - `@imgTypeNew_34` (-17,164) 222×222 [0M] OFF
      - `@imgTypeNew_36` (-17,164) 222×222 [0M] OFF
      - `@imgTypeNew_35` (-17,164) 222×222 [0M] OFF
      - `@imgTypeNew_37` (-17,164) 222×222 [0M] OFF
      - `imgNew` (153,35) 58×48 [0M]
      - `txtName` (60,0) -306×-30 [0M]
      - `imgQuality` (-130,0) 132×68 [0M]
      - `pnlHeroTag` (-17,-84) 290×58 [0M]
      - `imgOccupation` (-20,0) 70×70 [0M]
  - `pnlVideo` (0,0) 0×0 [0M]
    - `riVideo` (0,0) 1670×750 [0M]
    - `pnlVideoPlayer` (0,0) 100×100 [0M]
    - `btnSkipVideo` (-60,-24) 138×52 [0M] OFF
      - `Text` (-28,0) -56×0 [0M]
  - `btnClose` (0,0) 0×0 [0M]
```

## 按钮清单 (2个)

  - `btn` (418×804)
  - `btnSkipVideo` (138×52)

## @prefab 实例 (20个)

  - @ImgFrame_blue
  - @ImgFrame_purple
  - @ImgFrame_red
  - @ImgFrame_yellow
  - @fx_HeroRecruitView_01
  - @fx_HeroRecruitView_02
  - @fx_HeroRecruitView_03
  - @imgBg_blue
  - @imgBg_purple
  - @imgBg_red
  - @imgBg_yellow
  - @imgTypeNew_33
  - @imgTypeNew_34
  - @imgTypeNew_35
  - @imgTypeNew_36
  - @imgTypeNew_37
  - @txtTag1
  - @txtTag2
  - @txtTag3
  - @txtTag4

## 面板命名 (10个)

  - pnlHeroSilhouette
  - pnlHeroTag
  - pnlInfo
  - pnlMessage
  - pnlTag1
  - pnlTag2
  - pnlTag3
  - pnlTag4
  - pnlVideo
  - pnlVideoPlayer

## 组件深度分析

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

