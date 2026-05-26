# 单机版规划历史（合并）

> 合并自 `single-player-port-task-plan.md` + `shaonv-mvp-80-percent-restore-plan.md` + `shaonv-p0-continuation-2026-05-22.md` + `shaonv-single-player-knowledge-summary.md`

---

## 目标

使用原游戏资源 (YooAsset bundles + IL bytecode) 实现可离线运行的单机抽卡闭环。

## MVP 范围

| 模块 | 优先级 | 状态 |
|------|:--:|:--:|
| Launch → Login → Main 启动链 | P0 | ✅ 已完成 |
| MainUIView 主界面 (10 面板) | P0 | ✅ 布局完成 |
| LotteryDrawMainView 抽卡主界面 | P0 | ✅ 已完成 |
| HeroRecruitView 抽卡演出 | P0 | ⬜ 骨架 |
| LotteryDrawFinishView 结果展示 | P0 | ✅ 已完成 |
| 图鉴 (GalCollectionView) | P1 | ✅ 已完成 |
| 角色详情 (CommonHeroView) | P1 | ✅ 已完成 |
| 商店/邮件/每日/任务 | P1 | ✅ 已完成 |
| 离线挂机/战役 | P1 | ✅ 已完成 |
| 视图栈 + CanvasLayer | P0 | ✅ 已完成 |
| Spine 角色动画 | P1 | ✅ baked 方案 |

## 80% 还原目标

- 还原度 70-80%：所有核心 UI 面板按 prefab 坐标重建
- 不还原：网络/服务器逻辑、粒子特效、视频播放、音频、Animator 状态机
- 简化：LayoutGroup → 硬编码坐标、CanvasGroup → visible、DOTween → Godot Tween

## 关键架构决策

- **Godot 替代 Unity**: 授权成本 → Godot 4.6.2
- **baked Spine**: spine-godot GDExtension API 不兼容 → 预烘焙 JSON
- **CanvasLayer 视图栈**: 映射 Unity UIRoot2d 5 层
- **layout.json 驱动布局**: 锚点换算 1670→1280，杜绝猜测

## 已删除/归档的原始文档

- `single-player-port-task-plan.md` → 合并于此
- `shaonv-mvp-80-percent-restore-plan.md` → 合并于此
- `shaonv-p0-continuation-2026-05-22.md` → 合并于此
- `shaonv-single-player-knowledge-summary.md` → 合并于此
