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

`hero_037r` 与 `hero_037r_s01` 是正确的 Gal 专用动态看板线索，但当前 Godot baked 渲染会出现 atlas 散片被放大到前景的问题。现象：

- `hero_037r_s01`：脸、手、衣服等 attachment 以巨大散片覆盖屏幕。
- `hero_037r`：腿、头发等 attachment 以错误尺度覆盖前景。
- `hero_037`：可正常拼装，因此作为当前 MVP 临时回退。

下一步修复应优先检查：

- baked JSON 的 `bounds` 是否被异常大的附件污染。
- `spine_baked_preview_canvas.gd` 是否按 clip 全局 bounds 缩放，导致 Gal r 资源中某些附件扩大后拖垮整体 scale。
- baker 是否需要过滤 inactive/hidden slot，或按 drawOrder/attachment color alpha 判断可见性。
- atlas region 的旋转、offset、originalSize、uv 是否在 baker 输出和 Godot canvas 中被一致处理。
- `hero_037r*` 是否需要按背景/前景/角色分层渲染，而不是合成到单个 baked canvas。

## 6. 快速验证命令

```powershell
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); $OutputEncoding = [Console]::OutputEncoding
$env:SHAONV_MVP_CAPTURE='D:\work\openclaw-workspace\arpg\shaonv\tmp\screenshots\godot-gal-check.png'
$env:SHAONV_MVP_START_VIEW='gal'
& 'D:\work\openclaw-workspace\arpg\shaonv\Godot\Godot_console.exe' --path 'D:\work\openclaw-workspace\arpg\shaonv\standalone\godot-mvp' --scene res://scenes/main.tscn --rendering-method mobile --quit-after 3
```

当前参考验证截图：

- `tmp/screenshots/godot-gal-layout-fix-3.png`

## 7. 子界面继续恢复记录

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

## 8. 幻靈详情页恢复补充

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

## 9. 按 prefab 节点反查 Sprite / Icon

后续恢复界面时不要只靠截图猜 icon，优先走 `prefab 节点名 -> Image.sprite -> sprite 名称 -> 本地 PNG/物理 bundle` 的链路：

- 先读对应 `*-full-control-resource-inventory-*.md`，查 `Path` 与 `Bindings / resources`。例如 `HeroMainView/pnllLeft/pnlSelectHero` 明确绑定 `hero_img_36`，`pnlSelectHero_bg2` 绑定 `hero_img_36a`，`HeroMainSelectHeroGrid/imgHightLight` 绑定 `hero_img_119`。
- 如果节点是 `Image:none` 或 `Image:UISprite`，先判断是否透明点击区、遮罩或 prefab 内置占位，不要当成缺图。`HeroTabGrid/btn` 就是透明按钮占位，真正的 tab icon 由运行时数据注入。
- 对运行时注入的 icon，再用节点语义和图集候选缩略图交叉验证。本轮把 `standalone/unity-mvp/Assets/Resources/UI/Hero/hero_img_1~90` 做成 contact sheet 后确认：`hero_img_37~46` 是 Hero 详情左侧 tab/职业/元素类 icon，其中 `hero_img_37` 对应截图绿色 `主頁` 图标，`hero_img_43/44/45` 可用于 `養成/靈裝/靈階` 占位。
- 反查结果要同步到 Godot 资源目录再使用，不要硬编码不存在的路径。本轮同步 `hero_img_37~46` 到 `standalone/godot-mvp/assets/ui/hero/`，再在 `main.gd` 中通过常量引用。
- 做资源表时建议输出四列：`prefab path`、`sprite name`、`Unity source png`、`Godot target png / missing`。这样一眼能看出是“缺资源”、“运行时注入”还是“代码没用对图”。

新增辅助图与验证截图：

- `tmp/screenshots/hero-img-1-90-contact.png`
- `tmp/screenshots/godot-remnant-detail-v4.png`

## 10. 头像资源不要混用

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

## 11. 控件 icon / sprite 资源页

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

## 12. Unity bundle 小样本解包验证

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

补充脚本经验：

- `export_unity_bundle_images.py` 在传入 `wanted` 时会跳过 `Texture2D`，只读取目标 `Sprite`，这是避免头像大图集卡死的关键。
- 仍然不要一次性全量导出大型 atlas；优先从 prefab 清单或 manifest 中列计划文件，10-50 个一批导出更安全。
