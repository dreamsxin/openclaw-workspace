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
  - 右侧入口条已用 `zjm_btn_rukou0..4` 和 `zjm_icon_baoju/cangku/jingji/xueyuan/zhaohuan/duanzao` 等真实 SpriteFrame 替换。
  - 左上头像已补 `image/head/105004`，并参考 `heroHead` 坐标调整。

当前注意事项：

- 部分 SpriteFrame 含 `rotated: 1`、`offset`、`originalSize`，直接按 `rect` 裁剪会出现黑块或尺寸偏差。`original_home_screen.gd` 已加入基础 rotated 支持，但还没有完整处理 Cocos trim/offset。
- `daohangPre` 的底部导航主体是 Spine/UISpine 资源，不能简单把 atlas 原图当按钮贴图；当前先用稳定 SpriteFrame 做静态替代。
- `zjm_btn_rukou5` 在 `config.json` 中没有同名 SpriteFrame，MainPre 中可能是节点名复用或运行时代码/子资源生成，后续继续查运行时逻辑。

下一步：

- 继续按 `MainPre.json` + `heroHead/daohangPre` 修坐标，优先修左上玩家信息、右侧入口条文本/图标、底部导航。
- 完整实现 SpriteFrame 的 rotated、offset、originalSize 复原，减少裁剪黑块。
- 从 `Prefab/bigImage/*` 自动生成背景候选列表。
- 从 `Prefab/HerolhPrefab/*` 自动生成角色候选列表。
- 将主城 UI 的顶部资源栏、左侧入口、底部入口、右侧入口分区固定下来。
- 接入 Spine 播放后，把角色层从 PNG 预览替换为真实骨骼动画。

## 阶段 4：Spine 角色和特效预览

状态：开始实施。

已完成：

- 新增 `tools/export_spine_preview_index.py`。
- 生成 `data/spine_preview_index.json`，当前 993 条 Spine 记录。
- 资源浏览器的 Spine 分类可显示：
  - skeleton 名称
  - Spine 版本
  - bones/slots/skins 数量
  - 动画名列表
  - atlas 贴图预览

限制：

- Godot 当前未接入 Spine runtime。
- 现在显示的是 atlas/png 和动画索引，不是真正骨骼动画播放。

下一步优先级：

1. 调研可用 Godot 4 Spine 插件是否能加载 Spine 3.8 数据。
2. 如果插件可用，接入 `sp.SkeletonData` 的 JSON/atlas/png。
3. 如果插件不可用，先写一个简化预览器：
   - 解析 atlas 区域。
   - 显示 attachment 拼图。
   - 按 `idle/show` 的关键帧做局部近似动画。

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

## 当前风险

- 部分资源由 JS 运行时选择，单看 prefab 看不到完整引用。
- 部分 UI 使用九宫格、mask、scroll、layout，直接 TextureRect 会失真。
- Spine 是最大差距；没有 runtime 时角色只能做近似展示。
- Cocos Creator 压缩序列化字段多，新增 prefab 时要优先修工具，不要逐个手工猜。
