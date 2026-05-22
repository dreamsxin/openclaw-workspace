# shaonv Unity MVP 初始化记录

时间：2026-05-22

## 1. 工程位置

```text
D:\work\openclaw-workspace\arpg\shaonv\standalone\unity-mvp
```

当前本机命令行未检测到 Unity、Unity Hub、dotnet 或 csc，因此本轮完成的是可提交的 Unity 工程骨架和 MVP 源码初始化。后续用 Unity Hub 打开该目录后，Unity 会生成 `Library` 并完成资源导入。

## 2. 当前内容

```text
standalone/unity-mvp/
  Assets/
    Scenes/Boot.unity
    Scripts/
      App/GameApp.cs
      Data/GameDatabase.cs
      Data/GameModels.cs
      Data/SaveData.cs
      Gacha/GachaService.cs
      UI/MainUiController.cs
    Resources/Art/Spine/
      hero_001/
      hero_003Dh/
      hero_005/
      hero_016/
      hero_017/
    StreamingAssets/data/
      heroes_mvp.json
      gacha_pools_mvp.json
      draw_pool_summary.json
      hero_resource_map.json
  Packages/
  ProjectSettings/
```

## 3. MVP 功能

已实现运行时动态 UI：

- 主界面：货币、看板角色、入口按钮。
- 抽卡：普通/高级/进阶/源神祈愿池切换，单抽和十连。
- 结果页：显示抽卡结果、新角色和重复。
- 图鉴：角色收集状态、点击设为看板。
- 记录：抽卡历史。
- 本地存档：`PlayerPrefs["shaonv-unity-mvp-save"]`。

当前角色展示先用 Spine atlas PNG 作为静态图。骨骼动画接入点保留在资源目录中，后续安装 Spine Unity Runtime 后可用 `.skel.bytes + .atlas.txt + .png` 生成 `SkeletonDataAsset`。

## 4. 资源来源

角色资源来自已导出的 YooAsset bundle：

| 角色 | Unity Resources 路径 | 包 |
|---|---|---|
| 哪吒/hero_001 | `Assets/Resources/Art/Spine/hero_001` | `0e5210f0383683827d134d7c0bdb10d7` |
| 莉莉絲/hero_003Dh | `Assets/Resources/Art/Spine/hero_003Dh` | `b61d633c6f7beec5301d9f48ffb87909` |
| 蔡文姬/hero_005 | `Assets/Resources/Art/Spine/hero_005` | `e142aefe30d7727b58a79e487c52e19b` |
| 天狐妲己/hero_016 | `Assets/Resources/Art/Spine/hero_016` | `f110b832f2beea558234c8a70a3b82d2` |
| 女帝/hero_017 | `Assets/Resources/Art/Spine/hero_017` | `d0feba660f4456452e29d9252b2fbd69` |

数据来自：

```text
reverse-output/gacha-static/draw_pool_summary.json
reverse-output/gacha-static/hero_resource_map.json
```

同时新增了适合 Unity `JsonUtility` 解析的精简数据：

```text
Assets/StreamingAssets/data/heroes_mvp.json
Assets/StreamingAssets/data/gacha_pools_mvp.json
```

## 5. 打开和运行

1. 用 Unity Hub 打开：

```text
D:\work\openclaw-workspace\arpg\shaonv\standalone\unity-mvp
```

2. 打开场景：

```text
Assets/Scenes/Boot.unity
```

3. 点击 Play。

如果 Unity 提示版本不一致，使用 2022.3 LTS 打开即可；`ProjectVersion.txt` 当前写的是 `2022.3.55f1`。

## 6. 下一步

1. 在 Unity 编辑器中打开工程并修正可能的 `.meta`/ProjectSettings 兼容问题。
2. 接入 Spine Unity Runtime，替换静态 PNG 为 `SkeletonGraphic`。
3. 把 `HeroRecruitView/LotteryDrawMainView/LotteryDrawFinishView` 的导出 prefab manifest 转成 Unity UI 还原清单。
4. 导入抽卡 UI sprite、结果特效和音效。
5. 用真实掉落表替换当前 MVP 概率。
