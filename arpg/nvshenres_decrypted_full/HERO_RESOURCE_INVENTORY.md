# 女神降临英雄资源分析

本文档由 `arpg/tools/export_hero_resource_inventory.py` 生成，用于记录原始 Cocos 资源到 Godot 本地 Demo 的英雄目录还原依据。

## 资源入口

- Cocos 资源表：`D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\assets\resources\config.json`，其中 `paths` 记录逻辑路径，例如 `image/head/<id>`、`image/heroBook/<id>`、`Prefab/HerolhPrefab/<id>`、`Prefab/HeroPrefab/<id>`、`sound/cv/<id>/<soundId>`。
- Godot 图片索引：`D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full\data\named_resource_index.json`，由解密资源导出，记录 SpriteFrame/native PNG 对应关系。
- 反编译源码里英雄格子、图鉴、详情页使用 `grade/camp/body` 字段：`HeroGridCom`、`HeroBookItemPre`、`HeroBookDetailPanel` 调用 `HeroConstant.heroBigTagArr[n.grade]`、`heroCampSmallArr[n.camp]` 和 `playHeroSound(body, soundId)`。

## 离线品质推断

当前导出的 JS 中没有完整静态英雄表，因此本地 Demo 先按资源完整度推断品质，后续如果找到原表可直接替换 `data/hero_catalog.json` 的 `quality/grade/name/camp/job` 字段。

| 品质 | 推断规则 |
| --- | --- |
| SSS | 有 `image/heroBook`、`Prefab/HerolhPrefab`，并且 `sound/cv` 数量不少于 8 |
| SSR | 有 `image/heroBook`，并且 `sound/cv` 数量不少于 8 |
| SR | 有 `image/heroBook` |
| R | 只有头像等基础资源 |
| N | 其他 6 位英雄 id 资源 |

## 统计

- 基础英雄 id：75
- 头像 `image/head`：75
- 图鉴立绘 `image/heroBook`：75
- 主立绘 Prefab `Prefab/HerolhPrefab`：75
- 战斗 Prefab `Prefab/HeroPrefab`：63
- 有语音目录 `sound/cv` 的英雄：61
- 衣装/展示图 `image/skin/showImg`：17

## 英雄目录

| 品质 | 英雄ID | 名称 | 头像 | 图鉴 | 立绘Prefab | 战斗Prefab | 语音数 | 皮肤/变体 |
| --- | --- | --- | --- | --- | --- | --- | ---: | --- |
| SSS | 104001 | 英雄104001 | Y | Y | Y | Y | 11 |  |
| SSS | 104002 | 莉莉 | Y | Y | Y | Y | 11 |  |
| SSS | 104003 | 英雄104003 | Y | Y | Y | Y | 11 |  |
| SSS | 105004 | 伊卡洛斯 | Y | Y | Y | Y | 11 |  |
| SSS | 105005 | 英雄105005 | Y | Y | Y | Y | 11 |  |
| SSS | 105006 | 英雄105006 | Y | Y | Y | Y | 11 | 1050061 |
| SSS | 105007 | 英雄105007 | Y | Y | Y | Y | 11 |  |
| SSS | 105008 | 英雄105008 | Y | Y | Y | Y | 11 |  |
| SSS | 105009 | 英雄105009 | Y | Y | Y | Y | 11 |  |
| SSS | 105010 | 英雄105010 | Y | Y | Y | Y | 11 |  |
| SSS | 105011 | 英雄105011 | Y | Y | Y | Y | 11 | 1050111, 1050112 |
| SSS | 105012 | 英雄105012 | Y | Y | Y | Y | 11 |  |
| SSS | 204001 | 阿瓦隆 | Y | Y | Y | Y | 11 |  |
| SSS | 204002 | 艾琳 | Y | Y | Y | Y | 11 |  |
| SSS | 204003 | 英雄204003 | Y | Y | Y | Y | 11 |  |
| SSS | 205004 | 英雄205004 | Y | Y | Y | Y | 11 |  |
| SSS | 205005 | 英雄205005 | Y | Y | Y | Y | 11 |  |
| SSS | 205006 | 英雄205006 | Y | Y | Y | Y | 11 |  |
| SSS | 205007 | 英雄205007 | Y | Y | Y | Y | 11 |  |
| SSS | 205008 | 苏拉 | Y | Y | Y | Y | 11 | 2050081 |
| SSS | 205009 | 英雄205009 | Y | Y | Y | Y | 11 |  |
| SSS | 205010 | 英雄205010 | Y | Y | Y | Y | 11 |  |
| SSS | 205011 | 英雄205011 | Y | Y | Y | Y | 11 | 2050111 |
| SSS | 205012 | 英雄205012 | Y | Y | Y | Y | 11 |  |
| SSS | 304001 | 米莉娅 | Y | Y | Y | Y | 11 |  |
| SSS | 304002 | 英雄304002 | Y | Y | Y | Y | 11 |  |
| SSS | 304003 | 英雄304003 | Y | Y | Y | Y | 11 |  |
| SSS | 305004 | 英雄305004 | Y | Y | Y | Y | 11 |  |
| SSS | 305005 | 英雄305005 | Y | Y | Y | Y | 11 |  |
| SSS | 305006 | 尤朵拉 | Y | Y | Y | Y | 11 |  |
| SSS | 305007 | 英雄305007 | Y | Y | Y | Y | 11 | 3050071 |
| SSS | 305008 | 英雄305008 | Y | Y | Y | Y | 11 |  |
| SSS | 305009 | 英雄305009 | Y | Y | Y | Y | 11 |  |
| SSS | 305010 | 英雄305010 | Y | Y | Y | Y | 11 | 3050101 |
| SSS | 305011 | 英雄305011 | Y | Y | Y | Y | 11 | 3050111 |
| SSS | 305012 | 英雄305012 | Y | Y | Y | Y | 11 |  |
| SSS | 305013 | 英雄305013 | Y | Y | Y | Y | 11 |  |
| SSS | 404001 | 英雄404001 | Y | Y | Y | Y | 11 |  |
| SSS | 404002 | 英雄404002 | Y | Y | Y | Y | 11 |  |
| SSS | 405003 | 英雄405003 | Y | Y | Y | Y | 11 |  |
| SSS | 405004 | 英雄405004 | Y | Y | Y | Y | 11 | 4050041 |
| SSS | 405005 | 英雄405005 | Y | Y | Y | Y | 11 |  |
| SSS | 405006 | 英雄405006 | Y | Y | Y | Y | 11 |  |
| SSS | 405007 | 拉瑞欧 | Y | Y | Y | Y | 11 | 4050071 |
| SSS | 405008 | 英雄405008 | Y | Y | Y | Y | 11 | 4050081 |
| SSS | 405009 | 英雄405009 | Y | Y | Y | Y | 11 | 4050091 |
| SSS | 504001 | 英雄504001 | Y | Y | Y | Y | 11 |  |
| SSS | 504002 | 奥斯曼 | Y | Y | Y | Y | 11 |  |
| SSS | 505003 | 英雄505003 | Y | Y | Y | Y | 11 |  |
| SSS | 505004 | 诺萨 | Y | Y | Y | Y | 11 | 5050041 |
| SSS | 505005 | 英雄505005 | Y | Y | Y | Y | 11 |  |
| SSS | 505006 | 英雄505006 | Y | Y | Y | Y | 11 |  |
| SSS | 505007 | 英雄505007 | Y | Y | Y | Y | 11 | 5050071 |
| SSS | 505008 | 英雄505008 | Y | Y | Y | Y | 11 |  |
| SSS | 505009 | 英雄505009 | Y | Y | Y | Y | 11 | 5050091 |
| SSS | 505010 | 英雄505010 | Y | Y | Y | Y | 11 | 5050101 |
| SSS | 505012 | 英雄505012 | Y | Y | Y | Y | 11 | 5050121 |
| SR | 101001 | 英雄101001 | Y | Y | Y | - | 0 |  |
| SR | 102001 | 英雄102001 | Y | Y | Y | - | 0 |  |
| SR | 103001 | 英雄103001 | Y | Y | Y | - | 0 |  |
| SR | 201001 | 英雄201001 | Y | Y | Y | - | 0 |  |
| SR | 202001 | 英雄202001 | Y | Y | Y | - | 0 |  |
| SR | 203001 | 英雄203001 | Y | Y | Y | - | 0 |  |
| SR | 205013 | 英雄205013 | Y | Y | Y | Y | 4 |  |
| SR | 301001 | 英雄301001 | Y | Y | Y | - | 0 |  |
| SR | 302001 | 英雄302001 | Y | Y | Y | - | 0 |  |
| SR | 303001 | 英雄303001 | Y | Y | Y | - | 0 |  |
| SR | 305014 | 英雄305014 | Y | Y | Y | Y | 4 |  |
| SR | 403001 | 英雄403001 | Y | Y | Y | - | 0 |  |
| SR | 405010 | 英雄405010 | Y | Y | Y | Y | 4 |  |
| SR | 405011 | 英雄405011 | Y | Y | Y | Y | 0 |  |
| SR | 405012 | 英雄405012 | Y | Y | Y | Y | 0 |  |
| SR | 503001 | 英雄503001 | Y | Y | Y | - | 0 |  |
| SR | 505011 | 英雄505011 | Y | Y | Y | Y | 4 |  |
| SR | 605001 | 英雄605001 | Y | Y | Y | - | 0 |  |

## Godot 使用

- 英雄列表读取 `res://data/hero_catalog.json`，按 `SSS > SSR > SR > R > N` 排序。
- 资源分析完整结果在 `res://data/hero_resource_inventory.json`，用于继续补角色名、阵营、职业、真实 grade。
- 已人工确认的英雄名会覆盖自动名称，其余暂用 `英雄<id>`，避免阻塞完整列表展示。

## 英雄详情页动画链

源码确认：

- `HeroBookDetailPanel` 的 `preUrl` 是 `Prefab/HeroPanel/HeroBookDetailPre`。
- `HeroBookDetailPanel.initHeroLHPos()` 创建 3 个 `RoleLh` 放到 `heroBodyBox`，用于当前/前一个/后一个英雄滑动展示。
- 衣装页另建 `skinLH = new RoleLh()`，父节点是 `skinBodyBox`。
- `showSkin()` / `btnChaKan()` / 角色点击等逻辑最终都围绕 `RoleLh.body` 切换 body。
- `RoleLh.body = <bodyID>` 对应资源路径是 `Prefab/HerolhPrefab/<bodyID>`，所以英雄详情页主展示应优先使用 `HerolhPrefab` 里的 Spine，而不是 `image/heroBook` 静态图。

当前 Godot 实现：

- `tools/export_hero_spine_runtime_batch.py` 批量读取 `Prefab/HerolhPrefab/<id>`。
- 对每个 prefab，提取 `sp.Skeleton._N$skeletonData`，再调用 `export_spine_runtime_data.py` 导出到 `data/spine_runtime/<id>.json`。
- 生成 `data/hero_spine_runtime_index.json`，详情页按 body id 自动查 runtime。
- `original_hero_list_panel.gd` 与 `original_hero_panel.gd` 会按 `hero_spine_runtime_index.json` 过滤英雄；缺少 runtime 的基础英雄不在英雄列表和详情页头像列表中展示。
- `original_hero_panel.gd` 当前只对可播放 body 展示 Spine。直接用命令打开缺少 runtime 的 hero id 时，会落到第一个可播放英雄，不再展示静态图鉴兜底。

批量导出结果：

- `Prefab/HerolhPrefab/*` 总数：91。
- 基础 6 位英雄 body：75。
- 衣装/变体 body：16，包含 `1050061`、`1050111`、`1050112`、`2050081`、`2050111`、`3050071`、`3050101`、`3050111`、`4050071`、`4050081`、`4050091`、`5050041`、`5050071`、`5050091`、`5050101`、`5050121`。
- 成功导出可播放 runtime：79。
- 未导出 skeleton 的 body：12，分别是 `101001`、`102001`、`103001`、`201001`、`202001`、`203001`、`301001`、`302001`、`303001`、`403001`、`503001`、`605001`。

未导出的 12 个不是详情页脚本遗漏。对比 prefab 结构：

- `Prefab/HerolhPrefab/104001` 的 `sp.Skeleton` 模板包含 `_N$skeletonData`，可解析出 skeleton uuid 并导出 `GeLanTe_LH`，动画有 `idle/show`。
- `Prefab/HerolhPrefab/101001` 的模板只有 `cc.Sprite._spriteFrame` 和不带 `_N$skeletonData` 的 `sp.Skeleton`，没有可导出的 skeletonData；同时也没有 `Prefab/HeroPrefab/101001` 战斗 prefab。
- 这些 body 当前不展示，后续需要继续查是否有其它替代动画资源或仅为低阶静态图。

## 英雄详情页布局链

原始截图 `D:\work\openclaw-workspace\arpg\nvshenres\英雄页.jpg` 对应的主体 prefab 已重新确认：

- `Prefab/HeroPanel/HeroBookDetailPre`
- 导出布局：`data/prefab_layouts/HeroBookDetailPre.json`
- 原始 import：`assets/resources/import/90/901e5e08-d65e-418f-86ba-cd667c2f696b.json`
- 源码入口：`assets/main/index.js` 中 `HeroBookDetailPanel.preUrl="Prefab/HeroPanel/HeroBookDetailPre"`。
- 英雄列表也会用 `url: "Prefab/HeroPanel/HeroBookDetailPre"` 打开图鉴详情。

关键绑定来自 `HeroBookDetailPanelCom`：

- `lblTitle/lblVal1..lblVal7`：右侧详情文本。
- `lblHeroName/lblNickName/imgZhenYing/imgJob/imgJobName/imgTag/ft_zhanli`：左上英雄名、阵营、职业、品质和战力。
- `btnPre/btnNext/btnLingqu/btnChaKan/btnPingLun`：左右切换、领取、查看/全屏预览、评论。
- `heroBodyBox/skinBodyBox`：普通详情和衣装详情的 `RoleLh` 容器。
- `boxStar1/boxStar2/infoToggle/skinToggle/skinBox/rightBox`：星级、信息/衣装页签和左右内容区。

截图中的顶部资源条和底部主导航不是 `HeroBookDetailPre` 的子节点，而是独立叠加的 `Prefab/mainpanel/daohangPre`。源码里 `btnChaKan()` 进入全屏预览时会隐藏 `DaohangPanel.instance.active`，这能反向证明截图底部导航来自 `DaohangPanel` overlay。

`HeroMainPre` 仍然存在，但它不是这张截图的精确主体。它更像另一个英雄主面板入口，当前 Godot 手工页早期以它近似布局，后续应切换为 `HeroBookDetailPre + daohangPre` 组合来校准。

历史已分析的相近 prefab：

- `Prefab/HeroPanel/HeroMainPre`
- 导出布局：`data/prefab_layouts/HeroMainPre.json`
- 关键绑定组件：`HeroMainPre` / `HeroBookDetailPanelCom`

关键节点坐标以 Cocos 中心为原点，Godot 换算为屏幕坐标时使用 `(640 + x, 360 - y)`：

| 节点 | Cocos 坐标 | Godot 约略屏幕位置 | 作用 |
| --- | ---: | ---: | --- |
| `lblHeroName` | `(-581.79, 262.61)` | `(58, 97)` | 左上英雄名 |
| `lblNickName` | `(-581.79, 239.98)` | `(58, 120)` | 左上职业/别名 |
| `imgZhenYing` | `(-617, 253)` | `(23, 107)` | 阵营图标 |
| `imgTag` | `(-618.74, 204)` | `(21, 156)` | 品质标签 |
| `heroBodyBox` | `(0, 0)` | 全屏中心 | 当前/前后英雄 `RoleLh` 容器 |
| `btnPre` | `(-500, 10)` | `(140, 350)` | 前一个英雄 |
| `btnNext` | `(91, 10)` | `(731, 350)` | 后一个英雄 |
| `lblGongJiAttr` | `(330.39, 176.90)` | `(970, 183)` | 攻击属性 |
| `lblShengMingAttr` | `(330.39, 136.34)` | `(970, 224)` | 生命属性 |
| `lblFangYuAttr` | `(330.39, 96.77)` | `(970, 263)` | 防御属性 |
| `lblSuduAttr` | `(330.39, 55.38)` | `(970, 305)` | 速度属性 |
| `lblLvValue` | `(389.53, -95.98)` | `(1030, 456)` | 等级进度 |
| `skinBodyBox` | `(0, 0)` | 全屏中心 | 衣装 `RoleLh` 容器 |

源码行为：

- `onShow()` 调 `initHeroLHPos()`，然后默认勾选 `infoToggle` 并调用 `showInfo()`。
- `showInfo()`：`skinBox=false`、`rightBox=true`、`btnPre/btnNext=true`、`heroBodyBox=true`、`skinBodyBox=false`。
- `showSkin()`：`skinBox=true`、`rightBox=false`、`btnPre/btnNext=false`、`heroBodyBox=false`、`skinBodyBox=true`。
- `btnChaKan()`：进入全屏预览，隐藏 `showBox`，显示 `xuanzuan`，当前 `RoleLh` 横向展示。

当前 Godot 手工页已按这些坐标做第一轮收敛：

- 左上信息区移动到原始左上范围。
- 角色 `RoleLh` 目标区域回到全屏中心 `heroBodyBox`，不再贴右侧面板。
- 页签靠近原始右侧分隔线。
- 右侧属性面板压窄并右移，属性/按钮布局接近 `HeroMainPre` 的 `rightBox`。
- 衣装页仍使用同一个详情面板承载本地说明和按钮，后续应继续还原 `skinBox/skinInfo/noSkin/btnNext` 的真实节点层级。

## 截图对比记录

参考截图：`D:\work\openclaw-workspace\arpg\nvshenres\英雄页.jpg`。

已对齐的区域：

- 顶部资源条：金币、经验/瓶子、钻石三栏移动到右上。
- 左上信息：头像、英雄名、职业/别名、星级位于左上区域。
- 中央角色：RoleLh 放在屏幕中间偏左，底部接近主导航线。
- 底部战力：新增底部横向战力条，位置接近原始截图。
- 右侧结构：新增装备/技能竖列，右侧纸张属性区，最右页签列。
- 底部主导航：补城镇/英雄/召唤/冒险/副本/公会六入口。

仍需继续补的差异：

- 左上品质图标应使用原始 `SSR` 大图和阵营小图，而不是当前文字/星级近似。
- 右侧属性面板需要替换为真实白纸纹理和分割线，属性 icon 也需要接入原始资源。
- 装备/技能竖列当前是静态近似，后续应按实际装备/技能数据和 prefab 图标资源显示。
- 底部导航应继续追 `daohangPre` 的 UISpine/动态主体，而不是静态 atlas 裁剪。
- 角色不同 body 的原始缩放/偏移还需要从 `HerolhPrefab` 子节点 TRS 批量提取，不应只依赖统一 fit。
