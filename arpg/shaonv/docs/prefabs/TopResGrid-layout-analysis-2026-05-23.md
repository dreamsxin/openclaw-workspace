# TopResGrid Prefab 布局分析

> 自动生成 · 2026-05-23 · 6 节点

## 基本信息

| 字段 | 值 |
|------|-----|
| Bundle | `__data` |
| 节点数 | 6 |
| MonoBehaviour | 7 |
| CanvasGroup | 0 |
| ParticleSystem | 0 |
| Animator | 0 |
| 根节点 | TopResGrid |
| 交互式元素 | 1 (MonoB≥2) |

## 完整 RectTransform 层级

```
- `TopResGrid` (0,0) 200×40 [0M]
  - `imgBg` (0,0) 200×40 [0M]
  - `imgIcon` (-5,1) 50×50 [0M]
  - `txtNum` (27,-0) 130×40 [0M]
  - `btnClick` (0,0) 200×40 [0M] OFF
  - `txtTitle` (11,0) 160×30 [0M] OFF
```

## 按钮清单 (1个)

  - `btnClick` (200×40)

## @prefab 实例 (0个)



## 面板命名 (0个)



## 组件分析

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

