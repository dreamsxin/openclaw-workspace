# Prefab 全量清单导出路线

生成时间：2026-05-24。

本文档记录从 `MainUIView` 手工清单沉淀出的通用路线，并用 `CityView` / `ActivityMainView` / Gal 约会界面验证可复用性。

## 通用脚本

脚本路径：

```text
scripts/assets/export_prefab_full_inventory.py
```

基础命令：

```powershell
python scripts\assets\export_prefab_full_inventory.py CityView --repo-root .
python scripts\assets\export_prefab_full_inventory.py ActivityMainView --repo-root .
python scripts\assets\export_prefab_full_inventory.py GalDormitoryMainPanel --repo-root .
python scripts\assets\export_prefab_full_inventory.py HeroMainView --repo-root .
```

脚本会输出：

- `docs/shaonv-<view>-full-control-resource-inventory-2026-05-24.md`
- `reverse-output/godot-layout-inspect/<View>.layout.json`
- `reverse-output/monobehaviour-fields/<View>.mb-fields.json`

## 解析流程

1. 从 `physical-asset-map.csv` 解析 prefab address 到物理 bundle。
2. 对 bundle 做 YooAsset XOR 头部解码。
3. 从 prefab 直接提取 RectTransform 层级，不依赖已有 layout JSON。
4. 从 MonoBehaviour typetree 提取 `Image`、`Text`、`Button`。
5. 当 `m_Script` 类名解析为 `Unknown` 时，用 typetree 稳定字段反推 UI 类型：`m_Sprite/m_RaycastTarget/m_Type` 为 `Image`，`m_Text/m_FontData` 为 `Text`，`m_Interactable/m_OnClick` 为 `Button`。
6. 解析 prefab 内置 Sprite。
7. 读取 SerializedFile external 顺序，把 `m_FileID` 映射到 CAB。
8. 扫描当前物理资源集合，把 CAB 反查到 `bundleName/hashFileName/physicalPath`。
9. 加载已定位 CAB 中的 Sprite，按 `m_PathID` 反查 sprite 名称。
10. 用 sprite 名称回查 `physical-asset-map.csv`，生成资源 Bundle 表。

## 验证结果

| View | Nodes | Image/Text/Button | Resource rows | Result |
|---|---:|---|---:|---|
| `CityView` | 16 | 15 / 0 / 7 | 1 | 跑通。`city_bg_01` 已解析；7 个建筑局部图所在 `CAB-fe0668bd...` 当前未在本地物理资源集合定位，文档显式标为 unresolved external。 |
| `ActivityMainView` | 6 | 2 / 1 / 0 | 2 | 跑通且 Image 全解析。默认空活动壳使用 `bag_bg_01` 背景和 `common_img_59` 空状态图。 |
| `GalDormitoryView` | 4 | 0 / 0 / 0 | 0 | 跑通。该 prefab 是约会/宿舍主壳，只放 `pnlBottom/pnlMiddle/pnlTop` 挂载点和 `GalDormitoryView` 逻辑。 |
| `GalDormitoryMainPanel` | 59 | 31 / 13 / 17 | 26 | 跑通。字段反推修正后可识别 `btnDate/btnGoOut/btnGift/btnDressUp` 等主按钮，并解析 `gal_btn_*` / `gal_img_*` 到对应 bundle。 |
| `GalDateSelectView` | 10 | 4 / 4 / 3 | 4 | 跑通。约会选择子界面使用 `gal_bg_06` 背景，按钮资源为 `gal_btn_25/33/36`。 |
| `HeroMainView` | 233 | 146 / 48 / 43 | 29 | 跑通。英雄详情主屏，包含背景 `hero_bg_01/hero_bg_10`、右侧详情面板、核心/装备/属性等多状态面板。 |
| `HeroDetailInfoView` | 73 | 25 / 36 / 4 | 8 | 跑通。英雄属性详情弹层，背景 `guessing_bg_03`，头像示例 `thero_052`，属性/技能文本完整导出。 |
| `HeroMainSelectHeroGrid` | 15 | 12 / 1 / 1 | 7 | 跑通。详情页左侧/选择用英雄头像格，包含圆头像、星级、等级、选中高亮和透明按钮。 |
| `HeroListTabGrid` | 6 | 4 / 2 / 1 | 1 | 跑通。英雄列表分类 Tab 模板，使用 `common_btn_07` 高亮图。 |
| `HeroListOrdinationTabGrid` | 3 | 1 / 2 / 1 | 0 | 跑通。英雄列表排序 Tab 模板，根 Image 为透明点击区。 |
| `HeroListView` | - | - | - | 未导出。manifest 有 `assets_game_rawassets_prefabs_ui_hero_herolistview.bundle` / `6ee0abcfd37a8ba5a54acfc9003167ca.bundle`，但当前物理集合缺该文件，`physical-asset-map.csv` 无可用路径。 |

## 修正经验

- CAB 名称必须规范成 `CAB-` + 小写 hash。`m_Dependencies` 常写成 `cab-*`，而 SerializedFile external 可能是 `CAB-*`；大小写不统一会导致 CAB 已定位但无法回挂到 `m_FileID`。
- `Unknown` 组件不一定不可解析。若 typetree 仍包含 Unity UI 稳定字段，应按字段反推 `Image/Text/Button`，否则像 `GalDormitoryMainPanel` 这种 stripped/script 外部化的面板会误报为 0 图 0 文本 0 按钮。
- `Image:none` 不等于资源缺失，常见于透明点击热区、运行时替换入口、raycast-only 节点。
- external CAB 未定位时，优先检查当前物理资源集合是否真的包含该 CAB，而不是先怀疑 `Image.sprite` 解析失败。
- 若 `manifest-parsed-assets.csv` 中 `physicalExists=False`，说明地址和 bundle hash 已知但本地物理包缺失；这种情况不能生成 prefab 全量节点清单，应先补物理包再重跑，或只导出当前存在的子 prefab 模板。
- PowerShell 查看结果固定使用 UTF-8：

```powershell
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
Get-Content -Encoding UTF8 -Path docs\shaonv-cityview-full-control-resource-inventory-2026-05-24.md
```

## 下一步

- 对节点较多的 `BagView` 或 `LotteryDrawMainView` 再跑一次，验证脚本在复杂滚动列表和多 atlas 依赖下的性能。
- 如果要补齐 `CityView` 的建筑局部图，需要先找到或补入 `CAB-fe0668bdcadfeccb1da0b36c9fbe13a5` 对应的物理 bundle，再重跑脚本。
