# Godot Demo 还原路线图

目标：基于解密资源和反编译代码，做一个不连接服务端、可本地运行、可展示主要资源效果的 Godot Demo。

相关索引文档：

- `SOURCE_DIRECTORY_GUIDE.md`：目录、关键文件、反编译源码和工具脚本作用索引。
- `RESTORE_LOGIN_TO_HOME.md`：启动加载页 -> 登录页 -> 选服页 -> 主城页专项还原梳理。

## 阶段 1：资源索引与基础入口

状态：已完成第一版。

已完成：

- 生成 Godot 4 工程。
- 默认入口为启动加载页。
- 启动加载页 -> 登录页 -> 选服页 -> 主城页流程可运行。
- 资源浏览器可查看图片、音频、文本、Prefab、Scene。
- 增加 `data/catalog.json`、`data/prefabs.csv`。
- 增加后退/前进导航按钮。

## 阶段 2：Prefab 解析基础设施

状态：进行中。

已完成：

- `tools/export_cocos_prefab_layout.py` 可导出核心 prefab 布局。
- 已导出 `data/prefab_layouts/*.json`。
- 新增 `scripts/cocos_prefab_layer.gd`，Godot 可直接按导出的 prefab layout 绘制 UI 层。
- 注意：`LoginPre.json` / `pfLoginPanelPre.json` 直接渲染后效果不如手工实现，原因是导出器尚未正确处理 anchor、Widget、Button 子节点和部分默认 SpriteFrame。登录页、选服页已恢复为手工实现，prefab 图层暂只作为后续实验能力保留。
- 已修正 SpriteFrame 解析策略，只读取明确字段：
  - `cc.Sprite._spriteFrame`
  - `cc.Button._N$normalSprite/_N$pressedSprite/_N$hoverSprite/_N$disabledSprite`
  - `sp.Skeleton._N$skeletonData`
- 已在 `data/prefab_layouts/*.json` 中补充 SpriteFrame trim 元数据：`sprite_offset`、`sprite_original_size`、`sprite_rotated`。
- `scripts/cocos_prefab_layer.gd`、`scripts/cocos_prefab_preview.gd`、`scripts/original_home_screen.gd` 已统一按 Cocos SpriteFrame 规则复原：rotated 先交换裁剪宽高再旋回，offset/originalSize 贴回透明原始尺寸画布。
- 已导出节点父子关系：
  - `parent_index`
  - `active`
  - `position`
  - `global_position`
- Godot 预览使用 `global_position`，跳过 `_active=false`。

下一步：

- 解析并应用 anchor/pivot。
- 解析 opacity/color。
- 区分普通 Sprite、Button 状态图、九宫格 Sprite。
- 支持 Label 文本和字体样式。
- 支持 Widget、Layout、ScrollView。
- 将 `cocos_prefab_layer.gd` 与 `cocos_prefab_preview.gd` 的渲染逻辑收敛，避免两套坐标/裁剪策略分叉。

## 阶段 3：主城还原

状态：进行中。

已确认：

- `MainPre.json` 只负责主界面 UI prefab 层，不直接固定完整背景和角色。
- 背景由 `MainUIPanel.showBg` 动态加载 `Prefab/bigImage/<id>`。
- 角色由 `RoleLh` 动态加载 `Prefab/HerolhPrefab/<bodyID>`。
- 默认角色 bodyID 可从 JS 中看到：`105004`。
- 示例角色 `105004` 是 Spine 资源，动画包括 `idle`、`show`。

当前实现：

- `scenes/original_home_screen.tscn`
- `scripts/original_home_screen.gd`
- 主页改为手工主城层：坐标参考 `MainPre.json`，资源优先使用已解析出的 atlas 裁剪图。
- 背景和角色作为单独可切换层。
- 不再使用上传截图 `主屏.jpg` 作为实际页面。
- 登录页和选服页暂时保留手工还原版本；直接套 `LoginPre`、`pfLoginPanelPre` 的 prefab 图层会导致布局和资源错位。
- 已手工覆盖主城主要区域：
  - 左上玩家信息和顶部货币栏
  - 左侧好友/邮件/排行/新闻/战报快捷按钮
  - 左侧活动入口矩阵
  - 左下聊天/公告文本区
  - 活动广告图
  - 右侧功能入口带
  - 底部主导航
- 已继续追踪 `MainPre.json` 缺失入口：
  - 新增导出 `Prefab/mainpanel/daohangPre`、`Prefab/mainpanel/heroHead`。
  - 生成 `data/mainpre_asset_trace.json`，保存 `image/com/mainpanel/*` 的 SpriteFrame -> import -> native atlas -> rect 映射。
  - 左侧快捷按钮已改用真实 `zjm_btn_HaoYou/zjm_btn_YouJian/zjm_btn_PaiHang/zjm_btn_XinWen/zjm_btn_ZhanBao` 区域。
  - 活动入口矩阵已用 `zjm_icon_huodong/FuLi/first/libao/xianshihuodong/skin/tianti/shengxingjihua/thank/meirilibao/zhaohuan` 等真实 atlas 区域替换多数占位。
  - 活动广告入口已确认使用 `assets/resources/native/00/002545b0-69b1-4515-ac70-e545a4c8b5d2.png`，对应 `MainPre.json` 的 `zjm_image_GuanGao1` 区域，节点尺寸约 `320x150`，全局中心约 `(-464.409, -115.622)`。
  - 右侧入口条已用 `zjm_btn_rukou0..4` 和 `zjm_icon_baoju/cangku/jingji/xueyuan/zhaohuan/duanzao` 等真实 SpriteFrame 替换。
  - 右侧入口条已按 `MainPre.json` 的父节点尺寸 `260x34` 收缩，避免早期手写 `344x56` 导致入口条互相压住。
  - 底部导航已改用 `cm_icon_ChengZhen/YingXiong/CangKu/FuBen/GongHui` 和多语言 `cm_btn_Maoxian` 的真实 SpriteFrame。
  - 左上头像已补 `image/head/105004`，并参考 `heroHead` 坐标调整。

当前注意事项：

- 部分 SpriteFrame 含 `rotated: 1`、`offset`、`originalSize`，直接按 `rect` 裁剪会出现黑块或尺寸偏差。当前通用 prefab layer、prefab 预览器和主城页已支持基础 trim 复原；登录页/选服页等独立旧脚本还保留本地裁剪函数。
- `daohangPre` 的底部导航主体是 Spine/UISpine 资源，不能简单把 atlas 原图当按钮贴图；当前先用稳定 SpriteFrame 做静态替代。
- 当前只找到 `image/en/mainpanel/cm_btn_Maoxian` 等多语言冒险按钮，未找到 `image/com/mainpanel/cm_btn_Maoxian`，Godot 先用英文按钮图叠加中文 Label。
- `zjm_btn_rukou5` 在 `config.json` 中没有同名 SpriteFrame，MainPre 中可能是节点名复用或运行时代码/子资源生成，后续继续查运行时逻辑。

下一步：

- 继续按 `MainPre.json` + `heroHead/daohangPre` 修坐标，优先修右侧入口条文本/图标、底部导航。
- 将登录页/选服页等独立旧脚本也迁移到统一 SpriteFrame 复原函数。
- 从 `Prefab/bigImage/*` 自动生成背景候选列表。
- 从 `Prefab/HerolhPrefab/*` 自动生成角色候选列表。
- 将主城 UI 的顶部资源栏、左侧入口、底部入口、右侧入口分区固定下来。
- 接入 Spine 播放后，把角色层从 PNG 预览替换为真实骨骼动画。

## 阶段 4：Spine 角色和特效预览

状态：已接入项目内轻量 runtime，继续校正精度。

已完成：

- 新增 `tools/export_spine_preview_index.py`。
- 生成 `data/spine_preview_index.json`，当前 993 条 Spine 记录。
- 资源浏览器的 Spine 分类可显示：
  - skeleton 名称
  - Spine 版本
  - bones/slots/skins 数量
  - 动画名列表
  - atlas 贴图预览
- 新增 `tools/export_spine_runtime_data.py`，可把 Cocos `sp.SkeletonData` 导出为 `data/spine_runtime/*.json`。
- 新增 `tools/cocos_spine_trace_tool.py`，可做 Cocos UUID 压缩/解压、native PNG -> SkeletonData 反查、native PNG -> runtime 导出。
- 新增 `scripts/simple_spine_player.gd`：
  - 支持 Spine 3.8 JSON 的 bones / slots / skins。
  - 支持 region attachment。
  - 支持 mesh attachment。
  - 支持 weighted mesh。
  - 支持 bone rotate / translate / scale timeline。
  - 支持 slot attachment / color timeline。
  - 支持 drawOrder timeline。
  - 支持 deform timeline 的 mesh 顶点偏移。
  - 支持 atlas `rotate: true` 的 mesh UV 换算；已修正 YiKaLuoSi 左侧脚部 rotated mesh 方向。
  - 支持 Bezier 曲线采样，骨骼/颜色/deform 插值不再只是线性近似。
  - 支持 slot blend mode 的 additive/multiply 基础映射。
  - 支持 setup-only 单骨/二骨 IK，当前用 YiKaLuoSi 的 `yik` / `zik` 验证腿部约束。
  - IK 后会重算子骨骼世界矩阵，避免 weighted mesh 使用旧矩阵。
  - 支持 `only_slots` 调试渲染，可隔离头部、腿部等局部 slot。
- 新增 `scenes/spine_character_viewer.tscn`，用于独立查看角色 Spine 动画。
- 资源浏览器 Spine 条目如果已导出 runtime JSON，会显示 `Open Spine Viewer` 并跳转播放。
- 已导出并验证：
  - `data/spine_runtime/YiKaLuoSi.json`
  - `data/spine_runtime/105004.json`
- 已根据 native 图片继续反查并导出角色 Spine runtime：
  - `assets/resources/native/0f/0f3c9b3a-e75f-4064-9c82-00a4c0c086f8.png` -> `data/spine_runtime/SuLa_LH.json`
  - `assets/resources/native/1b/1baef3d2-6771-487a-84f3-f3222ae92456.png` -> `data/spine_runtime/YouDuoLa_LH.json`
- `spine_character_viewer.tscn` 已增加左侧 Spine 列表，自动扫描 `data/spine_runtime/*.json`，当前可直接切换 `LaRuiOu_LH`、`SuLa_LH`、`YiKaLuoSi`、`YouDuoLa_LH`。
- `spine_character_viewer.tscn` 已按骨骼绘制包围盒自动缩放/居中，动画按钮根据 skeleton 内 `animations` 动态生成。
- 主城 `Herolh/105004` 已由静态 PNG 切换为 `SimpleSpinePlayer` 播放。
- 主城页的 Hero 轮换已接入 `105004`、`SuLa_LH`、`YouDuoLa_LH` 三个动态 Spine，并用包围盒自动适配主城角色展示区域。
- 主城默认角色已改为 `105004` Spine，符合 `assets/main/index.js` 中 `_roleLhbody = "105004"` 的运行时默认值；静态插画只作为轮换候选保留。
- 主城角色区域可点击切换当前 Spine 的动作。`105004` 当前可在 `idle` / `show` 之间切换，标题栏会显示 `Anim: <name>`。
- 主城截图回归支持 `--home-animation <name>` 和 `--home-click-hero-once`，用于验证点击切换动作。
- YiKaLuoSi 调试结论：
  - `YiKaLuoSi_toushi03` 挂在独立的 `bone21`，不是头部 `bone5`，当前保留最小角色级位置补偿。
  - 屏幕左侧脚部对应 rotated atlas mesh，问题来源是 mesh UV 旋转方向，不是 deform timeline。
  - `YiKaLuoSi_zuojiao` 是 weighted mesh，权重骨骼包括 `bone9`、`bone10`、`bone11`。

限制：

- 这是项目内轻量 Spine runtime，不是官方 Spine Runtime。
- clipping、path、transform constraint 等高级能力尚未实现。
- IK 当前覆盖 setup-only 单骨/二骨约束，尚未实现 IK 时间线、stretch/compress/uniform 等高级选项。
- 局部 weighted mesh / deform 已可用，但和原版仍可能有细微差异。
- Godot 直接 `Image.load()` 读取 PNG 会输出导出警告，本地 demo 可接受；正式导出需走 import 资源。

下一步优先级：

1. 继续用 `spine_character_viewer.tscn` 对比 `idle/run/attack/skill1/skill2`。
2. 继续把主城角色候选从 `Prefab/HerolhPrefab/*` 批量导出，并接入主城 Hero 轮换。
3. 修正剩余 mesh 细节：少量 weighted mesh 形变误差、slot blend mode 精度。
4. 继续扩展 Spine 约束：IK timeline、transform constraint、clipping/path。
5. 根据角色面板/原主城逻辑确认每个角色在主城应播放 `idle` 还是 `show`，并为横向或超宽角色加场景级展示偏移。

## 阶段 5：核心界面批量还原

登录到主页面的专项梳理见：

```text
RESTORE_LOGIN_TO_HOME.md
```

优先级 1：

- `Prefab/loading/LoadingPre`
- `Prefab/loading/loadingProgress`
- `Prefab/login/LoginPre`
- `Prefab/login/pfLoginPanelPre`
- `Prefab/mainpanel/MainPre`
- `Prefab/HeroPanel/HeroMainPre`
- `Prefab/BagPanel/BagPre`
- `Prefab/DrawCard/drawCardPre`
- `Prefab/Battle/battle`

优先级 2：

- `Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre`
- `Prefab/Guild/GuildMainPre`
- `Prefab/JingjiPrefab/JingjiPre`
- `Prefab/SkyCityPanel/SkyCityPre`

清单文件：

- `data/prefab_restore_inventory.csv`
- `data/prefab_restore_inventory.md`

执行方式：

1. 每次选一个界面 prefab。
2. 先修复自动转换器缺失能力。
3. 再做少量场景级补丁。
4. 禁止用截图冒充资源还原。
5. 对运行时动态内容使用 mock 数据，但资源必须来自 catalog/prefab/spine 索引。

当前进度：

- `cocos_prefab_preview.gd` 支持 `--prefab-layout <label>` 和 `Navigation.go_with_args(..., {"layout": label})`。
- Godot 使用方式和界面还原实现流程已集中补充到 `RESTORE_LOGIN_TO_HOME.md`，包括默认启动、直开场景、截图回归、日志重定向、prefab 预览和 Spine 查看器命令。
- 当前界面还原流程固定为：`config.json` / `import` / `native` / Spine 资源 -> `tools/*.py` 导出 `data/*.json` -> Godot 脚本按 Cocos 坐标、SpriteFrame、Widget、NinePatch、Label 规则渲染 -> 对运行时动态列表使用子 prefab + 本地 mock 数据补齐。
- 主城底部/侧边主要入口已接入 prefab 预览器，可从主城进入英雄、背包、抽卡、战斗、公会、竞技、天空城、活动抽卡等界面骨架。
- Prefab 预览器已切换为 `global_position`，并跳过无贴图根节点，作为主要功能界面的恢复检查入口。
- `export_cocos_prefab_layout.py` 已导出 `cc.Label` 的 `_string`、字号、行高和对齐信息。
- `cocos_prefab_preview.gd` 已能显示真实 Label 文本，并应用节点 scale。英雄、背包、抽卡等主要 prefab 不再只显示节点名。
- `export_cocos_prefab_layout.py` 已导出 `cc.Sprite._type/_sizeMode` 和 SpriteFrame `capInsets`。
- `cocos_prefab_preview.gd` 对 sliced Sprite 使用 `NinePatchRect`，九宫格按钮/标题框开始按 Cocos inset 渲染。
- `HeroMainPre` 预览已叠加本地 mock 的 `105004` Spine 角色展示，用于检查英雄面板的角色展示区域。
- `export_cocos_prefab_layout.py` 已导出 `_anchorPoint`；`cocos_prefab_preview.gd` 已按 Cocos anchor 计算节点左上角。英雄面板属性、标题、按钮文字位置比中心点近似更接近原布局。
- `export_cocos_prefab_layout.py` 已导出并基础应用 `cc.Widget` 的 `_alignFlags` 与 left/right/top/bottom，主要覆盖四边拉伸、左/右/上/下贴边和中心对齐。
- `export_cocos_prefab_layout.py` 已把 `Prefab/BagPanel/GridBoxItemPre` 加入导出清单，`BagPre` 的动态条目可按原子 Prefab 结构叠加。
- `export_equipment_icon_index.py` 可从 `assets/resources/config.json` 导出 `data/equipment_icon_index.json`，解析源码中常见的 `image/equipment/<icon>` 图标路径。
- `BagPre` 预览已叠加本地背包条目 mock，条目结构来自 `GridBoxItemPre`，图标来自真实 `image/equipment` SpriteFrame/Texture2D。
- `export_named_resource_index.py` 可导出 `image/com/DrawCard/*`、`image/com/Guild/*`、`image/guildFlag/*` 等按路径加载的 UI 资源索引。
- `drawCardPre` 预览已叠加本地抽卡 mock，补卡池背景、三张卡牌、宝箱进度和召唤按钮状态，资源来自 `image/com/DrawCard`。
- `GuildMainPre` 预览已叠加本地公会大厅 mock，补公会背景、旗帜、公会信息和公会首领/科技/成员/公会战入口，资源来自 `image/com/Guild` 与 `image/guildFlag`。
- `SkyCityPre` 预览已叠加本地天空城 mock，补空岛、云层、建筑、矿物、副本入口和底部操作按钮。
- `export_named_resource_index.py` 已扩展 `image/com/skyCity/*`，`data/named_resource_index.json` 当前包含 325 条命名资源，可供天空城及其子界面继续复用。
- `JingjiPre` 静态 prefab 只有文字和空节点，主要贴图由运行时路径加载；`export_named_resource_index.py` 已扩展 `image/com/Jingji/*` 和 `image/com/pvpActivity/*`。
- `JingjiPre` 预览已叠加本地竞技 mock，补 PVP 背景、冠军联赛、战神殿、王者争霸、组队竞技、巅峰对决、膜拜信息和赛季奖励区域。
- `battle` 静态 prefab 是战斗站位容器，包含左右 5 个角色位、hp/hit/zidan 和背景节点，但不直接带贴图；预览器已叠加本地战斗 mock。
- `battle` 预览已补地图背景、双方 5 个站位、头像、血条、伤害/治疗反馈和战斗胜利奖励面板。
- `export_named_resource_index.py` 已扩展 `image/com/Battle*`、`image/com/FuBen/*`、`image/com/map/*`、`image/head/*`、`map/worldMap/*`。
- `DrawCardActivityPre` 静态 prefab 只有背景、ScrollView 和时间节点，具体活动内容需要结合 `Prefab/ActivityPanel/DrawCardActivity/13002..13005` 子 prefab 与运行时数据。
- `DrawCardActivityPre` 预览已叠加本地活动抽卡 mock，补活动标题、倒计时、限定英雄概率提升、抽数奖励进度、活动兑换和前往召唤/领取奖励按钮。
- `export_named_resource_index.py` 已扩展 `image/com/ActivityPanel/ZhaoHuan/*`、`image/com/ActivityPanel/NewHeroComing/*`、`image/com/ActivityPanel/thousandDrawCardActivity/*`。
- `HeroMainPre` 预览已继续补本地英雄页动态内容：左侧英雄列表、右侧属性面板、技能格、装备格，中心继续使用 `105004` Spine 展示。
- `export_named_resource_index.py` 已扩展 `image/en/HeroPanel/*`、`image/comHeroGrid/*`、`image/skill/*`、`image/heroBook/*`。
- `BagPre` 预览已继续补本地背包页动态内容：右侧分类按钮、道具详情区、使用/出售/一键出售操作区。
- `export_named_resource_index.py` 已扩展 `image/common/cm_btn*`；装备图标仍由专门的 `data/equipment_icon_index.json` 提供。
- `data/named_resource_index.json` 当前包含 1516 条命名资源。
- 当前 `HeroMainPre` 的右侧信息仍会和原 prefab 静态文本有重叠，后续需要继续完善 ScrollView/层级裁剪和动态节点替换规则。
- 当前 `BagPre` 的详情区仍受原 prefab 暗层/遮罩影响，后续需要统一处理 ScrollView、Mask 和 mock 层级。

下一步优先级：

1. 完善 `HeroMainPre` 的 ScrollView 裁剪、Layout 重排、右侧信息层级和动态节点替换。
2. 继续完善 `BagPre` 的页签交互、ScrollView/Mask 裁剪、详情层级和运行时分类数据。
3. 继续完善 `DrawCardActivityPre` 的 `13002..13005` 子 prefab、页签切换和抽卡活动 Spine。
4. 继续完善 `battle` 的真实 Spine 战斗角色、技能特效、站位坐标和战斗结束子 prefab。

## 当前风险

- 部分资源由 JS 运行时选择，单看 prefab 看不到完整引用。
- 坐标、尺寸、锚点可以从 prefab 读取；运行时列表项通常由子 Prefab 动态实例化，必须结合源码路径规则和本地 mock 数据补齐。
- 部分 UI 使用九宫格、mask、scroll、layout，直接 TextureRect 会失真。
- Spine 是最大差距；没有 runtime 时角色只能做近似展示。
- Cocos Creator 压缩序列化字段多，新增 prefab 时要优先修工具，不要逐个手工猜。
