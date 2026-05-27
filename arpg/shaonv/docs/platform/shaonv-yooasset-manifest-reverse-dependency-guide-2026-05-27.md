# YooAsset Manifest 反向依赖定位手册

生成时间：2026-05-27

这份文档记录 UI 资源修复时的固定定位路线，目标是下次不要再从 prefab、CAB、bundle、physical path 之间反复试错。

## 关键文件

| 文件 | 用途 |
|---|---|
| `reverse-output/assets/manifest-parsed-py/manifest-parsed-assets.csv` | 最完整的 asset -> bundle/physical 映射，优先查这个。 |
| `reverse-output/assets/manifest-parsed-py/manifest-parsed-bundles.csv` | bundle -> dependBundleIDs/physical 映射，用来做 bundle 级反查。 |
| `reverse-output/assets/yoo-physical-map/physical-asset-map.csv` | Godot 导出脚本当前使用的 asset -> physical 映射。字段比 manifest 少，但可直接喂给导出脚本。 |
| `reverse-output/assets/yoo-physical-map/physical-bundle-map.csv` | bundle -> physical 映射，和 parsed bundles 对齐。 |
| `scripts/assets/export_prefab_full_inventory.py` | 从 prefab bundle 导出控件树、Image/Text/Button、外部 CAB、资源表。 |
| `scripts/assets/export_unity_bundle_images.py` | 按 JSON plan 从 physical map 定位 bundle 并导出 PNG 到 Godot。 |

## 推荐工作流

1. 先用全量 prefab 清单确认控件真实资源名。

```powershell
py -3.14 scripts\assets\export_prefab_full_inventory.py --prefab GalDateSelectGrid --out-dir docs\ui\gal
```

清单中的 `Resource Bundle 表` 给出 `Resource`、原始 `Asset / Source`、`Bundle`、`physicalPath`。如果这里已经显示 `Image 解析：未解析 0`，不要再从 CAB 猜图，直接按资源名导出。

2. 用 manifest/physical map 按 asset 地址定位。

优先查 `manifest-parsed-assets.csv`：

```powershell
Import-Csv reverse-output\assets\manifest-parsed-py\manifest-parsed-assets.csv |
  Where-Object { $_.address -eq 'Assets/Game/RawAssets/Sprite/Gal/gal_img_77.png' } |
  Select-Object id,address,bundleID,bundleName,hashFileName,physicalPath,physicalExists,dependBundleIDs
```

如果只需要导出 PNG，查 `physical-asset-map.csv` 是否存在同一 `address` 即可，因为 `export_unity_bundle_images.py --plan` 读的是这张表。

3. 写 plan，交给导出脚本，不手工找 bundle。

```json
{
  "items": [
    {
      "asset": "Assets/Game/RawAssets/Sprite/Gal/gal_img_77.png",
      "godot": "assets/ui/gal/gal_img_77.png",
      "name": "gal_img_77"
    }
  ]
}
```

```powershell
py -3.14 scripts\assets\export_unity_bundle_images.py `
  --plan tmp\gal-all-controls-export-plan.json `
  --repo-root . `
  --godot-root standalone\godot-mvp `
  --export-root reverse-output\godot-resource-export\gal-all-controls
```

导出脚本会做：

`asset address -> physical-asset-map.csv row -> physicalPath -> UnityPy load/decrypt -> Sprite name -> Godot target`

## CAB 反向依赖怎么理解

Unity prefab 中的 `Image.m_Sprite` 常见两种情况：

| 情况 | 清单表现 | 处理 |
|---|---|---|
| prefab 内置 Sprite | `internal Sprite in prefab bundle` | 资源在 prefab bundle 内，通常不需要外部 PNG 导出，除非要还原这个内置图。 |
| 外部 Sprite 且已解析 | `Image:gal_img_77 -> assets_game_rawassets_sprite_gal.bundle` | 直接按 `Resource Bundle 表` 的 asset 地址导出。 |
| 外部 Sprite 具名但没有 physical row | `external_sprite_name_only` | 先查 `manifest-parsed-assets.csv`，再决定是否补 `physical-asset-map.csv` 或脚本规则。 |
| 外部 CAB 未定位 | `Image:external fid=... pid=... cab=CAB-...` | 不要猜资源名；先做 bundle 级反查或补样本。 |

`export_prefab_full_inventory.py` 的 CAB 路线是：

`prefab AssetBundle.externals -> fileID -> CAB name`

随后脚本会扫候选 bundle，读取 UnityPy `env.assets[*].name` 和 AssetBundle `m_Name`，尝试把 CAB 定位回 `physical-asset-map.csv` 的 row。这个扫描很慢，也不一定成功；能通过 manifest asset 地址定位时，应优先避开这一步。

## Bundle 级反向依赖

当只知道某个资源 bundle，想知道哪些 prefab/asset 依赖它：

1. 从 `manifest-parsed-assets.csv` 找目标资源的 `bundleID`。
2. 在 `manifest-parsed-assets.csv` 或 `manifest-parsed-bundles.csv` 中搜索 `dependBundleIDs` 是否包含该 bundleID。

PowerShell 示例：

```powershell
$target = '5695'
Import-Csv reverse-output\assets\manifest-parsed-py\manifest-parsed-assets.csv |
  Where-Object { ($_.dependBundleIDs -split '\|') -contains $target } |
  Select-Object -First 50 id,address,bundleID,bundleName,dependBundleIDs
```

注意：很多 Sprite 原子资源没有依赖项；依赖关系通常从 prefab bundle 指向 sprite atlas / sprite bundle。若 `dependBundleIDs` 为空，不代表资源不存在，只代表它本身不依赖其他 bundle。

## 这次 Gal 的已验证样例

| 资源 | asset 地址 | bundleID | bundle | physical |
|---|---|---:|---|---|
| 日期选择选中框 `gal_img_77` | `Assets/Game/RawAssets/Sprite/Gal/gal_img_77.png` | `5695` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 礼物获取途径 `gal_btn_48` | `Assets/Game/RawAssets/Sprite/Gal/gal_btn_48.png` | `5695` | `assets_game_rawassets_sprite_gal.bundle` | `files\yoo\Default\UnpackBundleFiles\9b\9b3005c642f23a035f900e91974d2f1f\__data` |
| 等级页背景 `gal_bg_03` | `Assets/Game/RawAssets/Sprite/BackGround/gal_bg_03.png` | `5201` | `assets_game_rawassets_sprite_background_gal_bg_03.bundle` | `files\yoo\Default\BundleFiles\44\44ab770f0d7327968fff1ed15db66a53\__data` |
| 礼物空态 `common_img_59` | `Assets/Game/RawAssets/Sprite/Common/common_img_59.png` | `5500` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 触摸教学面板 prefab | `Assets/Game/RawAssets/Prefabs/UI/Gal/SpineTouch/Teach/SpineTouchTeachPanel.prefab` | `2271` | `assets_game_rawassets_prefabs_ui_gal_spinetouch_teach_spinetouchteachpanel.bundle` | `resources\assets\yoo\Default\3d3dd9c2b5fbc97840d5b40b410d2834.bundle` |

## 排障顺序

1. `Image 解析：未解析 0`：清单已经足够，直接按 Resource 表导出。
2. 资源名已知但 physical map 查不到：先查 `manifest-parsed-assets.csv`，确认是否是 physical map 生成遗漏。
3. 只有 CAB + pathID：查 prefab bundle 的 externals/dependencies；再用 `manifest-parsed-bundles.csv` 和 bundle `m_Name` 做定位。
4. CAB 仍找不到：把对应 bundle 样本补进 `KNOWN_CAB_SAMPLE_ROWS` 或扩充 physical map，再重跑清单。
5. 导出成功但 Godot 找不到：检查 plan 的 `godot` 路径是否以 Godot project root 为基准，例如 `assets/ui/gal/gal_img_77.png`。

## 常用校验

检查 Godot 脚本中新增资源是否落地：

```powershell
Select-String -Path standalone\godot-mvp\scripts\screens\gal_screen.gd `
  -Pattern 'res://assets/[^"\)]+' -AllMatches |
  ForEach-Object { $_.Matches.Value } |
  Sort-Object -Unique |
  ForEach-Object {
    $p = $_ -replace '^res://','standalone/godot-mvp/'
    if (-not (Test-Path $p)) { $_ }
  }
```

启动 Godot 解析校验：

```powershell
.\Godot\Godot_console.exe --headless --path .\standalone\godot-mvp --quit
```

指定 Gal 子界面启动：

```powershell
$env:SHAONV_MVP_START_VIEW='gal'
$env:SHAONV_MVP_GAL_VIEW='date_select'
.\Godot\Godot_console.exe --headless --path .\standalone\godot-mvp --scene res://scenes/main.tscn --rendering-method mobile --quit-after 1
```
