# HeroListView 物理 Bundle 缺口记录

生成时间：2026-05-24。

本记录用于说明英雄列表主 prefab 当前不能生成完整节点清单的原因，并列出已经成功导出的列表相关模板。

## 结论

- 目标 prefab：`Assets/Game/RawAssets/Prefabs/UI/Hero/HeroListView.prefab`
- Managed 类型：`HeroListView : ViewBehaviour`
- 关键方法：`Awake`、`OnEnable`、`OnBtnDetailClick`、`OnBtnFormationClick`、`OnValueChange`、`GridAt`、`GridAtAsync`、`JumpToHero`
- Manifest bundle：`assets_game_rawassets_prefabs_ui_hero_herolistview.bundle`
- Hash 文件名：`6ee0abcfd37a8ba5a54acfc9003167ca.bundle`
- 当前状态：`manifest-parsed-assets.csv` 中存在地址和 hash，但 `physicalExists=False`；`physical-asset-map.csv` 没有 `HeroListView.prefab` 行，`files/yoo` 下也未找到该 hash 的 `__data`。

因此，当前本地资源集合不能对 `HeroListView` 生成和 `MainUIView` 同级的 RectTransform 全量清单。需要先补入 `6ee0abcfd37a8ba5a54acfc9003167ca.bundle` 对应物理文件，再运行：

```powershell
python scripts\assets\export_prefab_full_inventory.py HeroListView --repo-root .
```

## 已导出的列表相关模板

| Prefab | Nodes | Image/Text/Button | Resource rows | 文档 |
|---|---:|---|---:|---|
| `HeroListTabGrid` | 6 | 4 / 2 / 1 | 1 | `docs/shaonv-herolisttabgrid-full-control-resource-inventory-2026-05-24.md` |
| `HeroListOrdinationTabGrid` | 3 | 1 / 2 / 1 | 0 | `docs/shaonv-herolistordinationtabgrid-full-control-resource-inventory-2026-05-24.md` |
| `HeroMainSelectHeroGrid` | 15 | 12 / 1 / 1 | 7 | `docs/shaonv-heromainselectherogrid-full-control-resource-inventory-2026-05-24.md` |

## 关联详情界面

| Prefab | Nodes | Image/Text/Button | Resource rows | 说明 |
|---|---:|---|---:|---|
| `HeroMainView` | 233 | 146 / 48 / 43 | 29 | 英雄详情主屏；包含大背景、角色展示遮罩、右侧多状态详情面板和大量透明按钮热区。 |
| `HeroDetailInfoView` | 73 | 25 / 36 / 4 | 8 | 英雄属性详情弹层；包含头像、星级、属性详情、技能说明等。 |

## 导出经验

- manifest 中存在 prefab 地址不等于本地可以导出；必须同时有 `physical-asset-map.csv` 对应行或能在 `files/yoo` / `resources/assets/yoo` 找到 hash 文件。
- `HeroListView` 的列表主体很可能由 `GridAt/GridAtAsync` 运行时填充，主 prefab 补齐后还要同时关注 `HeroListTabGrid`、`HeroListOrdinationTabGrid`、`HeroListHorListGrid`、`HeroListDividerLine` 等子模板。
- 当前能导出的列表模板仍有价值：分类 tab、排序 tab、详情页头像选择格已经能给出尺寸、透明点击区、文字和资源 bundle。
