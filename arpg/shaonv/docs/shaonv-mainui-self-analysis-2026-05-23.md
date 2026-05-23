# MainUIView 自提取分析记录

时间：2026-05-23

## 本次提取命令

```powershell
python scripts\assets\inspect_unity_prefab_layout.py `
  "Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab" `
  --repo-root . `
  --out reverse-output\godot-layout-inspect-self `
  --markdown docs\shaonv-mainui-prefab-self-extract-2026-05-23.md `
  --markdown-depth 4
```

产物：

- `reverse-output/godot-layout-inspect-self/MainUIView.layout.json`
- `docs/shaonv-mainui-prefab-self-extract-2026-05-23.md`

提取结果稳定：`MainUIView.prefab` 为 212 个节点，来源 bundle 为 `resources/assets/yoo/Default/550a7cadacd941b64b750257fc8891d0.bundle`。

## 新核对出的关键偏差

1. `pnlStory` 是右下锚：anchor `(1,0)-(1,0)`，pivot `(1,0)`，pos `(-60,19)`，不是右上区域。
2. `pnlFunnyContent` 是右下锚：anchor `(1,0)-(1,0)`，pivot `(1,0.5)`，pos `(-339,70)`，4 个按钮由 LayoutGroup 排列。
3. `btnChapterInfo` 是右下锚：anchor `(1,0)-(1,0)`，pivot `(1,0)`，pos `(-34,150)`。
4. `pnlCommercialization` 是左上锚但 pivot 为中心：pos `(265,-333)` 不能当左上角使用；左上约为 `(57,123)`。
5. `btnMenu`、`pnlCharge`、`pnlChat` 是右上锚，需要按右侧偏移和 pivot 计算。
6. `pnlBottom` 是左下锚，pivot `(0,0.5)`，pos `(64,49)`；视觉上不是简单贴底 50px。

## 已据此修正

- 玩家信息旁 `btnChange/btnEye` 位置改回 prefab 的 top-left 计算结果。
- `btnAssist`、`btnMenu`、`pnlCharge`、`pnlChat` 改为 anchor/pivot 计算位置。
- `pnlCommercialization` 改回左上偏中的中心 pivot 位置。
- `btnChapterInfo` 和 `pnlStory` 改回右下锚位置。
- `pnlBottom` 改为根据 bottom anchor 留出下边距。

## 仍不能完全自动还原的部分

当前提取脚本只读 RectTransform，不解析 Unity LayoutGroup / ContentSizeFitter / 自定义 UI 绑定数据。因此这些节点的子项仍需要二次解析或人工推断：

- `pnlFunnyContent` 下 `btnArena/btnPrayer/btnAdventure/btnDraw` 的实际水平间距。
- `pnlCommercialization/pnlGift` 下 15 个 `LimitIconView` 的网格排布。
- `@TopBar/svRes` 的资源图标列表和滚动内容。
- Spine 三层 `spBg/spHero/spFg` 与 `imgMask` 的显示层次。

下一步若继续提升 MainUI 还原度，应扩展 `inspect_unity_prefab_layout.py`，把 LayoutGroup 参数和绑定 Sprite 名称也导出。
