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

## APK 复核

已检查完整 APK 目录：

| APK | Size | 结果 |
|---|---:|---|
| `apk/base.apk` | 77,146,597 | 未找到 `HeroListView` prefab bundle hash / bundle name。 |
| `apk/split_config.arm64_v8a.apk` | 114,201,813 | 未找到 `HeroListView` prefab bundle hash / bundle name。 |
| `apk/split_install_time_asset_pack.apk` | 234,587,690 | 包含 `assets/asd/YooAsset` 与 `assets/yoo/Default/*`，但未找到目标 hash。 |

复核细节：

- 目标 hash：`6ee0abcfd37a8ba5a54acfc9003167ca.bundle`。
- 目标 bundle：`assets_game_rawassets_prefabs_ui_hero_herolistview.bundle`。
- `split_install_time_asset_pack.apk` 内的 `assets/yoo/Default` 与当前 `resources/assets/yoo/Default` 集合一致，仍不含目标 hash。
- 按 manifest size `28585` 附近抽查候选 bundle，能解出的 prefab / scene 分别为 `BattleScene_01_GCSB.unity`、`MonsterFSM.prefab`、`fx_blackBG.prefab`、`Bdd2.prefab`，不是 `HeroListView`。
- `globalgamemanagers.assets` 只出现 `HeroListView` 类型/脚本注册字符串，不能恢复 prefab 节点与 UI 资源。
- `sources` / `reverse-output` 能确认 `YooAssetsService.Load` 等加载链路，但当前未定位到可直接下载该 hash 的 CDN 地址。

结论：这组 APK 仍然没有 `HeroListView` 主 prefab 的物理 bundle。该资源更像是远程热更新、运行时缓存或未随 install-time asset pack 下发的内容。下一步应优先找已安装客户端的运行时缓存，或继续从热更 manifest / 网络配置中定位可下载的资源源。

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
