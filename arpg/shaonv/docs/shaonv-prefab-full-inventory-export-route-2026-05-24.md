# Prefab 全量清单导出路线

生成时间：2026-05-24。

本文档记录从 `MainUIView` 手工清单沉淀出的通用路线，并用 `CityView` / `ActivityMainView` 验证可复用性。

## 通用脚本

脚本路径：

```text
scripts/assets/export_prefab_full_inventory.py
```

基础命令：

```powershell
python scripts\assets\export_prefab_full_inventory.py CityView --repo-root .
python scripts\assets\export_prefab_full_inventory.py ActivityMainView --repo-root .
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
5. 解析 prefab 内置 Sprite。
6. 读取 SerializedFile external 顺序，把 `m_FileID` 映射到 CAB。
7. 扫描当前物理资源集合，把 CAB 反查到 `bundleName/hashFileName/physicalPath`。
8. 加载已定位 CAB 中的 Sprite，按 `m_PathID` 反查 sprite 名称。
9. 用 sprite 名称回查 `physical-asset-map.csv`，生成资源 Bundle 表。

## 验证结果

| View | Nodes | Image/Text/Button | Resource rows | Result |
|---|---:|---|---:|---|
| `CityView` | 16 | 15 / 0 / 7 | 1 | 跑通。`city_bg_01` 已解析；7 个建筑局部图所在 `CAB-fe0668bd...` 当前未在本地物理资源集合定位，文档显式标为 unresolved external。 |
| `ActivityMainView` | 6 | 2 / 1 / 0 | 2 | 跑通且 Image 全解析。默认空活动壳使用 `bag_bg_01` 背景和 `common_img_59` 空状态图。 |

## 修正经验

- CAB 名称必须规范成 `CAB-` + 小写 hash。`m_Dependencies` 常写成 `cab-*`，而 SerializedFile external 可能是 `CAB-*`；大小写不统一会导致 CAB 已定位但无法回挂到 `m_FileID`。
- `Image:none` 不等于资源缺失，常见于透明点击热区、运行时替换入口、raycast-only 节点。
- external CAB 未定位时，优先检查当前物理资源集合是否真的包含该 CAB，而不是先怀疑 `Image.sprite` 解析失败。
- PowerShell 查看结果固定使用 UTF-8：

```powershell
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
Get-Content -Encoding UTF8 -Path docs\shaonv-cityview-full-control-resource-inventory-2026-05-24.md
```

## 下一步

- 对节点较多的 `BagView` 或 `LotteryDrawMainView` 再跑一次，验证脚本在复杂滚动列表和多 atlas 依赖下的性能。
- 如果要补齐 `CityView` 的建筑局部图，需要先找到或补入 `CAB-fe0668bdcadfeccb1da0b36c9fbe13a5` 对应的物理 bundle，再重跑脚本。
