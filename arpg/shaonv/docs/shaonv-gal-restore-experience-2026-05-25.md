# Gal 界面恢复经验与资源关联方法

日期：2026-05-25。

本文记录本轮恢复 `GalDormitoryView` / `GalDormitoryMainPanel` 到 Godot MVP 时形成的经验，方便后续继续恢复 Gal 子界面和其他界面。

## 1. 从截图反推界面结构

参考截图：`screenshot/现世界面.jpg`。

截图中的界面不是 MainUIView 的普通状态，而是从主界面底部 `pnlGal/btnGal` 进入的 Gal/约会主界面。原游戏结构拆成两层：

- `GalDormitoryView`：主壳，只提供 `pnlTop` / `pnlMiddle` / `pnlBottom` 挂点。
- `GalDormitoryMainPanel`：实际主面板，包含背景透明层、角色展示、左侧人物信息、右侧亲密等级、回忆/相册、底部外出/约会按钮。

恢复时不要只看单个 prefab。先用截图确认当前状态，再用全量清单定位可见节点，最后用运行时数据补上 prefab 中为空或默认文本的内容。

## 2. 资源定位顺序

推荐路线：

1. 先查全量清单文档：`shaonv-galdormitorymainpanel-full-control-resource-inventory-2026-05-24.md`。
2. 用节点名定位控件：例如 `btnDate`、`btnGoOut`、`btnGift`、`btnFile`、`btnLv`、`btnMemories`、`btnPhotoAlbum`。
3. 用清单中的 `Image:<sprite>` 回到资源名：例如 `gal_btn_12`、`gal_btn_13`、`gal_img_07`。
4. 若 prefab 中背景是透明图或空图，继续查截图和剧情/角色数据。`GalDormitoryMainPanel/Image` 使用的 `gal_img_122` 是透明/遮罩层，不是实际房间背景。
5. 背景图优先在 `standalone/unity-mvp/Assets/Resources/UI/BackGround/` 和 `Assets/Game/RawAssets/Sprite/BackGround/Gal/` 路径下按名称比对。

本轮确认：

- 截图同款房间背景：`gal_bg_room_4.png`。
- Godot 位置：`standalone/godot-mvp/assets/ui/background/gal_bg_room_4.png`。
- UI 透明层：`standalone/godot-mvp/assets/ui/gal/gal_img_122.png`。

## 3. 角色资源关联

`hero_resource_map.json` 是角色到 Spine/约会资源的关键索引。以截图中的 Gal 角色为例：

- `heroId=240030`
- 普通 Spine：`hero_037|hero_037_s01`
- Gal 专用 Spine：`hero_037r_s01|hero_037r`
- Gal 半身资源：`phero_037r_s01|phero_037r`

注意：MVP 的 `heroes_mvp.json` 当前用 `240037` 作为 `hero_037` 的可播放条目，这是单机版简化数据；原游戏映射里 `hero_037` 对应的 Gal 角色线索在 `240030`。

## 4. 控件布局落地注意点

Unity 全量清单里的 `RectTransform` 不能直接当 Godot 左上角坐标使用。恢复时要同时处理：

- Unity 画布：`1668x750`。
- Godot MVP 画布：`1280x720`。
- X/Y 非等比缩放。
- 锚点、pivot、父节点坐标。
- `HorizontalLayoutGroup` / `ContentSizeFitter` 的运行时排布。
- Active=N 的节点不会出现在截图当前状态。
- 文本经常来自运行时语言表或角色数据，prefab 中可能显示 `Default` 或空字符串。

截图态校准结果：

- 顶部：返回、帮助、收藏在左上。
- 左栏：`玄武 / 墨茗 / 天真無邪`，侧按钮为 `裝扮`、`甜蜜互動`。
- 右上：亲密等级圆环显示等级 `2`、经验 `0/250`。
- 右侧：`心動回憶` 与 `相冊` 纵向排列。
- 底部：`檔案`、`禮物`、`外出`、`約會` 从左到右排列。

## 5. 动态看板问题

`hero_037r_s01|hero_037r` 是正确的 Gal 专用动态看板线索；当前 Godot MVP 已改为优先使用 `hero_037r_s01`，并验证中间角色区域可正常拼装。早期记录的散片问题不再作为当前阻塞项处理。

后续继续修 Gal 主界面时优先检查：

- `hero_resource_map.json` / 英雄数据中的 Gal 专用 spine、半身、头像字段，不要把普通战斗/招募资源误用到 Gal 看板。
- `Head/Round/yhero_*` 是否同步到 `standalone/godot-mvp/assets/ui/hero/round/`；例如 `hero_037r_s01` 应依次尝试 `yhero_037r_s01`、`yhero_037r`、`yhero_037`。
- 缺圆头像时只能临时回退到 `zhero_*` 裁切，视觉上会和 Gal/英雄详情的圆头像不一致，必须标记为资源缺口而不是布局问题。

## 6. 快速验证命令

```powershell
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); $OutputEncoding = [Console]::OutputEncoding
$env:SHAONV_MVP_CAPTURE='D:\work\openclaw-workspace\arpg\shaonv\tmp\screenshots\godot-gal-check.png'
$env:SHAONV_MVP_START_VIEW='gal'
& 'D:\work\openclaw-workspace\arpg\shaonv\Godot\Godot_console.exe' --path 'D:\work\openclaw-workspace\arpg\shaonv\standalone\godot-mvp' --scene res://scenes/main.tscn --rendering-method mobile --quit-after 3
```

当前参考验证截图：

- `tmp/screenshots/godot-gal-layout-fix-3.png`

## 7. 资源路径关系速查

本次 Gal 修复最重要的经验不是单个坐标，而是资源路径要按“数据索引、Prefab 节点绑定、物理 bundle、Godot 落地路径”四段一起查。不要只按截图里看到的名字猜资源。

通用查找链路：

1. 先查全量控件清单：`docs/shaonv-*-full-control-resource-inventory-*.md`。节点表里的 `Image:xxx -> bundle` 是 UI 按钮、框、头像格的第一可信来源。
2. 再查角色资源索引：`standalone/godot-mvp/data/hero_resource_map.json` 或 `reverse-output/gacha-static/hero_resource_map.csv`。这里负责回答同一个 `heroId` 在普通英雄、招募、Gal 看板、Gal 半身中分别该用哪套资源。
3. 需要导出原始图时查物理映射：`reverse-output/assets/yoo-physical-map/physical-asset-map.csv`。确认 `address` / `assetPath`、`bundleName`、`physicalPath`、`physicalExists`，不要只看 manifest 地址。注意 `Head/Round/yhero_*` 这类 Sprite 路径在 `address` 列，`assetPath` 可能为空。
4. 最后核对 Godot 落地路径：`standalone/godot-mvp/assets/...`。代码里用的是 `res://assets/...`，例如 `Assets/Game/RawAssets/Sprite/Head/Round/yhero_023.png` 对应 `res://assets/ui/hero/round/yhero_023.png`。

Gal 默认角色 `240030` 的例子：

| 用途 | 数据字段/节点 | Unity 原始资源线索 | Godot 路径 |
|------|---------------|--------------------|------------|
| 中间 Gal Spine | `hero_resource_map.galSpine` | `hero_037r_s01|hero_037r` | `res://assets/spine/hero_037r_s01/hero_037r_s01.baked.json` |
| 普通 Spine | `hero_resource_map.spine` | `hero_037|hero_037_s01` | `res://assets/spine/hero_037/...` |
| 招募立绘兜底 | `hero_resource_map.recruitImg` | `zhero_037|zhero_037_s01` | `res://assets/ui/hero/recruit/zhero_037.png` |
| Gal 半身/皮肤格 | `hero_resource_map.galHalfIcon` | `phero_037r_s01|phero_037r` | `res://assets/ui/hero/half/...`，按实际导出文件核对 |
| 圆头像 | `HeroMainSelectHeroGrid/imgHero` 等节点 | `Head/Round/yhero_*` | `res://assets/ui/hero/round/yhero_*.png` |
| Gal 顶部返回/详情/收藏 | `GalDormitoryMainPanel/pnlTopBar` | `gal_btn_01 / gal_btn_30 / gal_btn_31` | `res://assets/ui/gal/gal_btn_01.png` 等 |

圆头像命名要特别小心：Gal Spine 往往带皮肤/场景后缀，例如 `hero_037r_s01`。Godot 现在的候选链是 `yhero_037r_s01 -> yhero_037r -> yhero_037`；`Head/Round/yhero_*` 已全量导出后，Gal 默认角色会命中第一优先级 `yhero_037r_s01`，不再回退到 `zhero_037` 裁切。

本轮已从 `assets_game_rawassets_sprite_head_round.bundle` 全量导出 `141` 个 `yhero_*` 圆头像到 `standalone/godot-mvp/assets/ui/hero/round/`，导出计划为 `tmp/all-yhero-round-head-export-plan.json`，导出 manifest 为 `reverse-output/godot-resource-export/all-yhero-round-heads/godot-plan-export-manifest.json`。Gal 角色头像命中结果：

| heroId | 角色 | galSpine | 圆头像命中 |
|------:|------|----------|------------|
| `240030` | 妲己 | `hero_037r_s01|hero_037r` | `yhero_037r_s01` |
| `240043` | 奇美拉 | `hero_021r_s01|hero_021r` | `yhero_021r_s01` |
| `240065` | 莉莉絲 | `hero_003r_s01|hero_003r` | `yhero_003r_s01` |
| `240093` | 朱雀 | `hero_052r_s01|hero_052r` | `yhero_052r_s01` |
| `240094` | 白虎 | `hero_051r_s01|hero_051r` | `yhero_051r_s01` |
| `240096` | 青龍 | `hero_050r_s01|hero_050r` | `yhero_050r_s01` |
| `240101` | 玄武 | `hero_053r_s01|hero_053r` | `yhero_053r_s01` |

同类界面查找时可以套用这条规则：

- `zhero_*`：招募/卡片立绘兜底，通常不适合作圆头像。
- `yhero_*` / `ypet_*`：圆头像，英雄详情左侧条、Gal 角色入口、Toast/Map 头像节点优先用这一类。
- `phero_*`：半身/皮肤格，Gal 换装类界面会出现。
- `hero_*` Spine：战斗/普通展示用；`hero_*r*` 通常是 Gal/宿舍看板特化资源，要优先查 `galSpine` 而不是普通 `spine`。
- `gal_btn_* / gal_img_*`：Gal UI 按钮和框，先从 `GalDormitoryMainPanel` 清单拿节点名与 sprite 名，再映射到 `res://assets/ui/gal/`。

## 8. 子界面继续恢复记录

本轮继续把 `GalDateSelectView` 与 `GalCharacterView` 接入 Godot MVP，形成 `gal_screen.gd` 内部三态：

- `main`：`GalDormitoryView` / `GalDormitoryMainPanel` 主界面。
- `date_select`：约会选择界面，对应 `shaonv-galdateselectview-full-control-resource-inventory-2026-05-24.md`。
- `character`：性格分析界面，对应 `shaonv-galcharacterview-full-control-resource-inventory-2026-05-24.md`。

实践结论：

- Gal 主界面的按钮不能继续全部指回主页。`btnDate`、`btnGoOut`、`btnGift`、`btnPhotoAlbum`、`btnMemories` 可以先接到 `date_select`；`btnFile`、`btnDressUp`、`btnPrivateInteraction`、`btnPersonality`、角色选择入口可以先接到 `character`。
- 若子界面的运行时文本仍未定位，先用可读 MVP 数据补齐，不照搬 prefab 里的 `Default`。布局和跳转优先，细节表数据后续再接。
- GDScript 中 `var x := app._label(...)` 会因为 `app` 是动态对象而无法推断类型。跨脚本 helper 返回值建议使用普通 `=`，或显式写类型。
- 子界面资源可以直接从清单中的 sprite 名称反查 bundle。`gal_btn_25`、`gal_btn_33`、`gal_btn_36`、`gal_img_103`、`gal_img_105`、`gal_img_106`、`gal_img_111` 至 `gal_img_119` 均来自 Gal atlas 或单图 bundle；`gal_bg_06`、`gal_bg_11` 已在 `standalone/unity-mvp/Assets/Resources/UI/BackGround/` 中有现成 PNG。
- `HeroListView` 这类缺物理 bundle 的界面不要强行生成清单。先查 `*-physical-bundle-gap` 文档，确认可用子模板，再用运行时数据和已导出的模板恢复可用 MVP。

新增验证截图：

- `tmp/screenshots/godot-gal-restored-main.png`

## 9. 幻靈详情页恢复补充

从 `MainUI` 底栏进入的 `幻靈` 不是抽卡 `喚靈`，而是 `RemnantsListView` / `RemnantsMainView` 链路；`喚靈` 才对应 `LotteryDrawMainView`。恢复时先把入口语义分清，否则会把 Home 按钮接到错误界面。

继续对照全量控件清单后还要再纠偏一层：截图中的“幻靈详情页”并不直接等同 `RemnantsMainView`。`RemnantsMainView` 清单实际是 `遗器属性 / 遗器目录 / 陈列室`，主结构为三组 `@RemnantsMainShowPanel`，更像遗器/基座展示页；女帝截图的左侧头像条、左侧 `主頁 / 養成 / 靈裝 / 靈階` 页签和右侧角色属性面板，更接近 `HeroMainView` 的 `pnlRole / pnllLeft / pnlRight` 骨架。

详情页不要只使用通用 UI 背景。角色常带专属背景 Spine/PNG，例如女帝 `hero_017` 在导出目录中存在 `hero_017_bg.png`，画面中的水墨山景和白鹤来自这类角色背景层。Godot MVP 当前使用方式：

- 底层用星空背景 `hero_bg_10`，保持截图中的深色夜空氛围。
- 角色专属背景叠在中左舞台区，女帝使用 `assets/spine/hero_017/hero_017_bg.png`。
- 信息面板区域额外压暗，避免竖图背景冲淡战力、属性、技能按钮。
- 普通 `Label` 不解析 BBCode；等级高亮要拆成两个 Label，不能写 `[color]101[/color]/180`。
- 临时数值/属性映射要允许角色特例。女帝截图为 `土相 / 狂刃`，不要只用 `hero_id % n` 生成导致显示成其他属性。
- 星级使用 `common_img_73 / common_img_74`，不要用文本星号硬画；技能按钮优先使用 `skillResources` 中的真实技能图标。
- 技能图标 PNG 自带透明边界，Godot `TextureRect` 直接画会越界或只露局部。需要裁剪容器或专用 helper 控制显示区域。

新增验证截图：

- `tmp/screenshots/godot-remnant-detail.png`

继续细化后补充几条更具体的复原规则：

- `HeroMainView` 静态清单里 `pnlRight/pnl4` 是未激活的 `HeroCorePanel`，不能误认为截图右侧主页属性面板只来自这个子节点。截图中的 `昭陽 / 女帝 / SSR / 等級 / 戰力 / 四属性 / 技能` 更像运行时把英雄数据填进 `HeroMainView` 主页面板，而不是 `RemnantsMainView` 的遗器陈列结构。
- `HeroMainSelectHeroGrid` 的左侧头像格尺寸为 `70x70`，选中高亮 `hero_img_119` 为 `100x100`，星条背景 `common_img_62` 为 `70x14`。但 `hero_img_60` 原图带较大透明外扩光晕，直接按 14px 多颗叠加会造成整条头像栏过曝；在缺少运行时圆头像/星级排版完全信息时，先用低调星级文本或低透明占位，比强行堆素材更接近截图观感。
- 早期缺少 `yhero_017` 圆头像时曾临时用 `zhero_017` 招募头像裁切；第 10 节已定位并导出 `assets_game_rawassets_sprite_head_round.bundle` 中的 `yhero_*`，详情页左侧头像条和 Gal 小头像应优先替换为圆头像资源。
- 技能图标本身就是 84px 圆形金色图标，`HeroDetailInfoView` 也用 `common_img_208` 的 84px 技能容器。不要用居中不缩放的裁剪方式显示技能 PNG，否则只会露出图标局部；应直接按目标尺寸缩放，必要时只用轻透明框做底。
- 对截图中已确定的角色特例，先固定数据比公式生成更可靠：女帝 `昭陽 / 土相 / 狂刃 / 100/180 / 274369 / 攻擊23746 / 生命212970 / 防禦1805 / 速度104`，后续再替换为真实表驱动。

新增验证截图：

- `tmp/screenshots/godot-remnant-detail-v3.png`

## 10. 按 prefab 节点反查 Sprite / Icon

后续恢复界面时不要只靠截图猜 icon，优先走 `prefab 节点名 -> Image.sprite -> sprite 名称 -> 本地 PNG/物理 bundle` 的链路：

- 先读对应 `*-full-control-resource-inventory-*.md`，查 `Path` 与 `Bindings / resources`。例如 `HeroMainView/pnllLeft/pnlSelectHero` 明确绑定 `hero_img_36`，`pnlSelectHero_bg2` 绑定 `hero_img_36a`，`HeroMainSelectHeroGrid/imgHightLight` 绑定 `hero_img_119`。
- 如果节点是 `Image:none` 或 `Image:UISprite`，先判断是否透明点击区、遮罩或 prefab 内置占位，不要当成缺图。`HeroTabGrid/btn` 就是透明按钮占位，真正的 tab icon 由运行时数据注入。
- 对运行时注入的 icon，再用节点语义和图集候选缩略图交叉验证。本轮把 `standalone/unity-mvp/Assets/Resources/UI/Hero/hero_img_1~90` 做成 contact sheet 后确认：`hero_img_37~46` 是 Hero 详情左侧 tab/职业/元素类 icon，其中 `hero_img_37` 对应截图绿色 `主頁` 图标，`hero_img_43/44/45` 可用于 `養成/靈裝/靈階` 占位。
- 反查结果要同步到 Godot 资源目录再使用，不要硬编码不存在的路径。本轮同步 `hero_img_37~46` 到 `standalone/godot-mvp/assets/ui/hero/`，再在 `main.gd` 中通过常量引用。
- 做资源表时建议输出四列：`prefab path`、`sprite name`、`Unity source png`、`Godot target png / missing`。这样一眼能看出是“缺资源”、“运行时注入”还是“代码没用对图”。

新增辅助图与验证截图：

- `tmp/screenshots/hero-img-1-90-contact.png`
- `tmp/screenshots/godot-remnant-detail-v4.png`

## 11. 头像资源不要混用

英雄/gal/幻靈界面的头像必须按原始资源类别区分，不能把抽卡招募图裁切后到处复用：

- `Head/Round/yhero_*.png`：圆头像。`HeroMainSelectHeroGrid/imgHero`、`GalToastGrid/imgHead`、`GalCharacterView/imgHead` 都明确绑定这一类；详情页左侧英雄条和 Gal 小头像应优先用它。
- `Head/Square/thero_*.png`：方头像。`HeroDetailInfoView/imgHeadFrame/imgHead` 使用这一类，适合详情弹层/属性弹层头像。
- `Head/Recruit/zhero_*.png`：招募/卡面头像。适合抽卡、图鉴卡、招募列表，不适合作为详情页左侧小圆头像。

本轮已定位到圆头像物理包：

```text
Assets/Game/RawAssets/Sprite/Head/Round/yhero_017.png
bundle: assets_game_rawassets_sprite_head_round.bundle
physical: resources/assets/yoo/Default/ed83c7f6493927f7eb32770282eb16b5.bundle
```

Godot MVP 中新增规则：从 hero 数据的 `spine=hero_017` 推导 `assets/ui/hero/round/yhero_017.png`；缺失时才降级回 `portraitResource=zhero_*`，且回退图要缩小/降透明，避免招募卡视觉污染头像条。

已导出首批圆头像到：

```text
standalone/godot-mvp/assets/ui/hero/round/yhero_*.png
```

女帝附近列表已继续补齐 `yhero_003 / yhero_023 / yhero_024 / yhero_036 / yhero_041 / yhero_042 / yhero_043 / yhero_058 / yhero_060` 等；导出计划记录在 `tmp/hero-round-head-export-plan.json`，后续可按同一模式追加缺失头像。

新增验证截图：

- `tmp/screenshots/godot-remnant-detail-round-heads-v2.png`

## 12. 控件 icon / sprite 资源页

恢复界面时建议先生成资源页，再结合 prefab 节点清单查图，不要只凭截图猜。已新增脚本：

```powershell
& 'C:\Users\admin\AppData\Local\Python\pythoncore-3.14-64\python.exe' scripts\assets\make_ui_resource_sheets.py --repo-root . --out tmp\screenshots\resource-sheets
```

生成的资源页：

- `tmp/screenshots/resource-sheets/hero-buttons.png`：`hero_btn_*` 按钮类控件。
- `tmp/screenshots/resource-sheets/hero-icons-1-120.png`：`hero_img_* / hero_zhiye_*`，包含详情页左侧 tab、元素、职业、星级、SSR 标签、筛选 icon 等。
- `tmp/screenshots/resource-sheets/common-buttons.png`：`common_btn_* / tongyong_btn_* / *_btn_*` 通用按钮。
- `tmp/screenshots/resource-sheets/common-icons.png`：`common_img_*` 通用图标、框、星、技能底座等。
- `tmp/screenshots/resource-sheets/skill-icons.png`：当前已导出的技能 icon。
- `tmp/screenshots/resource-sheets/hero-round-heads.png`：已导出的 `yhero_*` 圆头像。
- `tmp/screenshots/resource-sheets/hero-square-heads.png`：`thero_*` 方头像。
- `tmp/screenshots/resource-sheets/gal-godot.png`：当前 Godot 已导出的 Gal 资源。

导出经验：

- 已落地 PNG 生成资源页很快，优先用 `make_ui_resource_sheets.py`；它只读 `standalone/unity-mvp/Assets/Resources/UI` 和 `standalone/godot-mvp/assets/ui`，不解 Unity bundle。
- 大 bundle 不要在普通交互回合里全量 `Texture2D/Sprite.image` 导出。`assets_game_rawassets_sprite_head_round.bundle` 这类头像图集会导致 UnityPy 解码 ASTC 大图非常慢，表现为电脑卡住或残留多个 `python.exe`。
- Windows 上 `python` 可能先启动 `Python Install Manager` / WindowsApps shim，再拉起真正解释器。长任务建议显式调用真实解释器路径，例如 `C:\Users\admin\AppData\Local\Python\pythoncore-3.14-64\python.exe`，避免进程判断混乱。
- 如果必须从 bundle 导出，应按 prefab 资源表列出目标 sprite 名称，分批导出并只读目标 Sprite；不要遍历所有 Texture2D。若导出卡住，先检查/结束残留 Python 进程，再继续。
- 资源页只作为“看图索引”，最终使用前仍要回到 `*-full-control-resource-inventory-*.md` 验证节点绑定，例如 `HeroMainView/pnllLeft/pnlSelectHero -> hero_img_36`、`HeroMainSelectHeroGrid/imgHero -> yhero_000`。

## 13. Unity bundle 小样本解包验证

本轮继续测试 Unity bundle 解包，结论是：小样本按 `physical-asset-map.csv` 精确导出目标 sprite 是稳定的，之前卡住不是包不可解，而是全量/半全量读取大图集、以及 Windows `Python Install Manager` shim 干扰进程判断。

验证计划：

```text
tmp/unity-bundle-smoke-plan.json
```

测试资源：

- `Common/common_btn_04.png`
- `Common/common_img_208.png`
- `Hero/hero_btn_05.png`
- `Hero/hero_img_37.png`
- `Head/Round/yhero_017.png`

命令：

```powershell
$py='C:\Users\admin\AppData\Local\Python\pythoncore-3.14-64\python.exe'
Measure-Command { & $py scripts\assets\export_unity_bundle_images.py --plan tmp\unity-bundle-smoke-plan.json --repo-root . --godot-root . --export-root tmp\unity-bundle-test\raw }
```

结果：

- 5 个目标 sprite 全部成功。
- 耗时约 `1.56s`。
- 输出位于 `tmp/unity-bundle-test/godot/`，manifest 位于 `tmp/unity-bundle-test/raw/godot-plan-export-manifest.json`。

随后用同一计划导出正式 round 头像：

```powershell
$py='C:\Users\admin\AppData\Local\Python\pythoncore-3.14-64\python.exe'
Measure-Command { & $py scripts\assets\export_unity_bundle_images.py --plan tmp\hero-round-head-export-plan.json --repo-root . --godot-root standalone\godot-mvp --export-root reverse-output\godot-resource-export\hero-round-heads }
```

结果：

- `yhero_*` 从 10 个补到 19 个。
- 耗时约 `1.28s`。
- `tmp/screenshots/resource-sheets/hero-round-heads.png` 已更新。
- `tmp/screenshots/godot-remnant-detail-round-heads-v3.png` 验证详情页左侧已全部使用 `Head/Round/yhero_*` 圆头像。
- 2026-05-25 复核 Gal 默认角色 `hero_037r_s01`：当前工作区未找到 `yhero_037*.png`，Gal 左下角色头像仍会回退到 `zhero_037` 裁切；已在 Godot 资源解析中加入 `037r_s01 -> 037r -> 037` 候选链，资源补齐后会自动命中。

补充脚本经验：

- `export_unity_bundle_images.py` 在传入 `wanted` 时会跳过 `Texture2D`，只读取目标 `Sprite`，这是避免头像大图集卡死的关键。
- 仍然不要一次性全量导出大型 atlas；优先从 prefab 清单或 manifest 中列计划文件，10-50 个一批导出更安全。

## 14. 英雄详情左侧头像外圈

英雄详情左侧头像条对应 `HeroMainSelectHeroGrid`，外圈不是单个资源，而是至少三层组合：

- `HeroMainSelectHeroGrid/imgHightLight`：`hero_img_119`，Rect 为 `100x100`，用于选中状态的大绿色外圈。PNG 本体是 `68x68`，运行时会拉伸到 100。
- `HeroMainSelectHeroGrid/imgHero`：`Head/Round/yhero_*`，Rect 为 `70x70`，用于圆头像。
- `HeroMainSelectHeroGrid/imgFrame`：`common_img_64`，Rect 为 `70x70`，用于常驻头像框/品质色层。它中心 alpha 为 0，单独预览时像红块，但叠在头像上是外沿颜色框，不应低透明到几乎不可见。

Godot MVP 已按 prefab 尺寸调整详情左侧头像条：头像 `70x70`，`common_img_64` 同位置 `70x70` 覆盖，选中时 `hero_img_119` 以 `100x100` 居中铺底。

新增验证截图：

- `tmp/screenshots/godot-remnant-detail-head-frame.png`

## 15. Gal 互动音频导出与播放

Gal 主界面的角色互动音频来自 `Assets/Game/RawAssets/Sound/Action/hero_xxx_*.wav`，不是 `Sound/Battle/hero_xxxq_*`。以默认 Gal 角色 `hero_037r_s01` 为例，互动语音仍按本体编号 `hero_037` 查找：

- `hero_037_greet.wav`：进入 Gal 主界面/确认出行等问候反馈。
- `hero_037_wait1.wav` / `hero_037_wait2.wav` / `hero_037_wait3.wav`：主界面待机语音。
- `hero_037_arm1.wav` / `hero_037_er.wav`：触摸/短反馈语音。
- `hero_037_gift.wav` / `hero_037_gift_fav.wav`：礼物反馈。

导出脚本：

```powershell
$py='C:\Users\admin\AppData\Local\Python\pythoncore-3.14-64\python.exe'
& $py scripts\assets\export_unity_audio_clips.py --plan tmp\gal-hero037-audio-export-plan.json --repo-root . --godot-root standalone\godot-mvp --export-root reverse-output\godot-resource-export\gal-audio-hero037
```

关键经验：

- 音频 bundle 同样需要 YooAsset 前 `222` 字节 XOR `0x16`。只 XOR 32 字节会触发 UnityPy 的 encrypted BundleFile 报错。
- `AudioClip.samples` 可直接导出 RIFF WAV；`hero_037_*` 样本均为 PCM、单声道、16-bit、22050Hz。
- Godot CLI/运行时不会自动 import 新导出的 `.wav`，直接 `load("res://...wav")` 会报 `No loader found`。当前 Gal 脚本用轻量 RIFF WAV parser 构造 `AudioStreamWAV`，避免依赖 Godot Editor 导入流程。
- 当前运行环境 WASAPI 初始化失败会回退 dummy driver，因此自动验证只能证明播放链路无脚本错误；实际听音需在音频设备正常的环境中打开。

已接入的 Godot 互动：

- 所有 Gal 透明命中按钮增加按下缩放、悬停透明反馈，并播放短点击音。
- 角色中间区域增加触摸命中，轮播 `greet/arm/wait` 语音并显示短飘字。
- 礼物按钮播放 `gift/gift_fav` 语音。
- Gal 主界面启动后会播放问候语音，并开启待机语音定时器。
