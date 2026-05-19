# 女神游戏 (Nvshen) UI 界面资源清单

分析时间：2026-05-19 | 数据来源：`nvshenres_decrypted_full/data/prefab_layouts/`

---

## 总览

- **UI 界面总数**：35 个 prefab
- **总节点数**：1926
- **总贴图引用数**：205
- **唯一贴图文件数**：78
- **Spine 骨骼动画资源**：10 个 (分布在 3 个界面)

| 资源类型 | 数量 |
|---------|------|
| 图集（Atlas）贴图（短名，如 `18b29ae48.png`） | 25 |
| 独立 UUID 贴图 | 53 |
| Spine 骨骼动画 | 10 |
| 字体相关 | 2 (见 resources 包 catalog) |
| 音效资源 | 1061 (见 resources 包 catalog) |

## 界面清单及资源详情

### 启动加载
- **Prefab 路径**：`Prefab/loading/LoadingPre`
- **Layout 文件**：`data/prefab_layouts/LoadingPre.json`
- **节点数**：16 | **贴图节点**：3 | **Widget 布局节点**：1

**引用贴图 (3 个)**：
  - `1430d496a.png`
  - `1d816a710.png`
  - `5e7260ec-ef10-44da-88fb-ecf9825936dc.png`

**Sprite 帧 (2 个)**：
  - `cm_frame_TanChuang2`
  - `dl_progress1_jiazai`

**文本内容 (前10个)**：
  - "正在连接服务器"

### 加载进度
- **Prefab 路径**：`Prefab/loading/loadingProgress`
- **Layout 文件**：`data/prefab_layouts/loadingProgress.json`
- **节点数**：3 | **贴图节点**：0 | **Widget 布局节点**：0

**引用贴图 (0 个)**：

### 登录面板
- **Prefab 路径**：`Prefab/login/LoginPre`
- **Layout 文件**：`data/prefab_layouts/LoginPre.json`
- **节点数**：39 | **贴图节点**：6 | **Widget 布局节点**：14

**引用贴图 (5 个)**：
  - `1430d496a.png`
  - `1d1cac610.png`
  - `b43ff3c2-02bb-4874-81f7-f2dea6970f18.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
  - `edd215b9-2796-4a05-aaf5-81f96c9281ce.png`

**Sprite 帧 (6 个)**：
  - `default_btn_normal`
  - `default_btn_pressed`
  - `default_editbox_bg`
  - `dl_frame_wenzi`
  - `dl_icon_gonggao`
  - `dl_logo`

**文本内容 (前10个)**：
  - "进入游戏"
  - "用户协议"
  - "用户中心"
  - "公告"

### 登录选服
- **Prefab 路径**：`Prefab/login/pfLoginPanelPre`
- **Layout 文件**：`data/prefab_layouts/pfLoginPanelPre.json`
- **节点数**：101 | **贴图节点**：10 | **Widget 布局节点**：14

**引用贴图 (9 个)**：
  - `0275e94c-56a7-410f-bd1a-fc7483f7d14a.png`
  - `1430d496a.png`
  - `14d2fafcf.png`
  - `18b29ae48.png`
  - `1d1cac610.png`
  - `478e6f30-ec49-48dd-8704-e191a5e4b607.jpg`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`
  - `93e457e9-3554-4660-801b-b9c1613abdc8.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`

**Sprite 帧 (10 个)**：
  - `1`
  - `cm_btn_LvSe2`
  - `cm_select_fuxuan1off`
  - `default_btn_disabled`
  - `default_btn_normal`
  - `default_sprite_splash`
  - `dl_frame9_fuwuqi`
  - `dl_icon_18`
  - `dl_tab6_off`
  - `dl_tag_weihu`

**文本内容 (前10个)**：
  - "公告"
  - "切换账号"
  - "discord"
  - "facebook"
  - "进入游戏"
  - "取消"
  - "确定"
  - "批许文号：新广出审[2017]6390号  ISBN：978-7-7979-9552-8 
著作权人：长沙骁之翼网络有限公司    出版单位：长沙骁之翼有限公司"
  - "本网络游戏适合年满16周岁以上的用户使用：请您确认已如实进行实名注册"
  - "本网络游戏适合年满16周岁以上的用户使用；请您确定已经实名注册。为了您的健康，请合理控制游戏时间"
  - ... 还有 8 条

### 主城
- **Prefab 路径**：`Prefab/mainpanel/MainPre`
- **Layout 文件**：`data/prefab_layouts/MainPre.json`
- **节点数**：227 | **贴图节点**：27 | **Widget 布局节点**：2

**引用贴图 (10 个)**：
  - `140096250.png`
  - `18b29ae48.png`
  - `199822ca2.png`
  - `19ac1e70d.png`
  - `1a7921f32.png`
  - `1d816a710.png`
  - `1f6b547b4.png`
  - `5eb3feb3-a5f7-4c64-a9b0-a2c5528e79b7.png`
  - `b43ff3c2-02bb-4874-81f7-f2dea6970f18.png`
  - `cdc789e9-d998-4c15-8920-b7ac60af8734.png`

**Sprite 帧 (25 个)**：
  - `btn_change`
  - `cm_frame9_biaotidi`
  - `default_btn_pressed`
  - `lhsz_frame_wenzi`
  - `xsyd_frame9_dianjiqipao2`
  - `zjm_btn_HaoYou`
  - `zjm_btn_PaiHang`
  - `zjm_btn_ZhanBao`
  - `zjm_btn_forecast`
  - `zjm_frame9_LiaoTian`
  - `zjm_icon_FanYeOff`
  - `zjm_icon_FuLi`
  - `zjm_icon_cangku`
  - `zjm_icon_chaozhishouchong`
  - `zjm_icon_dagong`
  - `zjm_icon_discord`
  - `zjm_icon_duanzao`
  - `zjm_icon_gonghuizhan`
  - `zjm_icon_juhui`
  - `zjm_icon_meirilibao`
  - ... 还有 5 个

**文本内容 (前10个)**：
  - "绑定礼物"
  - "活动"
  - "福利"
  - "新服"
  - "打工"
  - "王者争霸"
  - "公会战"
  - "天梯"
  - "限时礼包"
  - "超级钜惠"
  - ... 还有 43 条

### 主城导航
- **Prefab 路径**：`Prefab/mainpanel/daohangPre`
- **Layout 文件**：`data/prefab_layouts/daohangPre.json`
- **节点数**：94 | **贴图节点**：11 | **Widget 布局节点**：3

**引用贴图 (8 个)**：
  - `15a1d9111.png`
  - `18b29ae48.png`
  - `19ec60a29.png`
  - `1f6b547b4.png`
  - `83903e83-5933-42e2-b569-f4c51ebdea94.png`
  - `8715b80b-6cbc-4b88-bf7d-8c2ab401db4e.png`
  - `9a9cb544-24ba-41c7-8cab-41a43a9e9c33.png`
  - `e116f353-6974-488e-86a7-19f294f47e7b.png`

**Sprite 帧 (8 个)**：
  - `cm_TX_Tiao`
  - `cm_TX_TouXiangDi2`
  - `cm_icon_HongDian`
  - `cm_icon_ZhanLi`
  - `cm_image_daohangguang`
  - `cm_menu_TaiYangGuang`
  - `cm_menu_ZhongJing`
  - `zjm_icon_kefu`

**Spine 骨骼动画**：
  - `cm_icon_ChuJi`
  - `cm_icon_GongHui`
  - `cm_icon_YingXiong`

**文本内容 (前10个)**：
  - "城镇"
  - "英雄"
  - "召唤"
  - "副本"
  - "公会"
  - "学院"
  - "冒险"
  - "蓝钻特权"
  - "大厅特权"
  - "绝望深渊选buff"
  - ... 还有 2 条

### 主城头像
- **Prefab 路径**：`Prefab/mainpanel/heroHead`
- **Layout 文件**：`data/prefab_layouts/heroHead.json`
- **节点数**：33 | **贴图节点**：5 | **Widget 布局节点**：3

**引用贴图 (3 个)**：
  - `18935b9e9.png`
  - `18b29ae48.png`
  - `6e0a08c4-ce5c-4071-b1ed-ddb9b5beb9a1.png`

**Sprite 帧 (5 个)**：
  - `70011`
  - `cm_TX_DengJi`
  - `cm_TX_TouXiangDi2`
  - `cm_TX_VIPDi`
  - `cm_icon_HongDian`

**文本内容 (前10个)**：
  - "蓝钻特权"
  - "大厅特权"
  - "专属客服"

### 主城默认角色
- **Prefab 路径**：`Prefab/HerolhPrefab/105004`
- **Layout 文件**：`data/prefab_layouts/105004.json`
- **节点数**：3 | **贴图节点**：0 | **Widget 布局节点**：0

**引用贴图 (0 个)**：

**Spine 骨骼动画**：
  - `LaRuiOu_LH`

### 资源条
- **Prefab 路径**：`Prefab/comPrefab/MoneyItemPre`
- **Layout 文件**：`data/prefab_layouts/MoneyItemPre.json`
- **节点数**：7 | **贴图节点**：2 | **Widget 布局节点**：0

**引用贴图 (2 个)**：
  - `15a1d9111.png`
  - `18b29ae48.png`

**Sprite 帧 (2 个)**：
  - `cm_frame_HuoBi2`
  - `cm_icon_HongDian`

### 商店
- **Prefab 路径**：`Prefab/Shop/ShopPre`
- **Layout 文件**：`data/prefab_layouts/ShopPre.json`
- **节点数**：67 | **贴图节点**：7 | **Widget 布局节点**：8

**引用贴图 (6 个)**：
  - `14d2fafcf.png`
  - `15a1d9111.png`
  - `184257350.png`
  - `929b60ed-1b1e-4419-b357-d7c9d1e43436.jpg`
  - `d6d3ca85-4681-47c1-b5dd-d036a9d39ea2.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`

**Sprite 帧 (7 个)**：
  - `cm_QuanPinBG`
  - `cm_btn_JiaHao`
  - `cm_btn_LvSe2`
  - `default_btn_normal`
  - `default_scrollbar_vertical`
  - `sc_line_xiaotishi`
  - `sc_line_yeqianfenge`

**文本内容 (前10个)**：
  - "基础商城"
  - "基础商城"
  - "战场商城"
  - "战场商城"
  - "(1/5)"
  - "刷新"
  - "重置"
  - "01:30:20"
  - "10/50"
  - "所有商品买完自动重置"
  - ... 还有 2 条

### 商店页签
- **Prefab 路径**：`Prefab/Shop/ShopItemPre`
- **Layout 文件**：`data/prefab_layouts/ShopItemPre.json`
- **节点数**：7 | **贴图节点**：1 | **Widget 布局节点**：0

**引用贴图 (1 个)**：
  - `47e154d7-f9c2-4a5a-85c0-b299960f439b.png`

**Sprite 帧 (1 个)**：
  - `102`

**文本内容 (前10个)**：
  - "随机"
  - "随机"

### 商店商品
- **Prefab 路径**：`Prefab/Shop/GoodsItemPre`
- **Layout 文件**：`data/prefab_layouts/GoodsItemPre.json`
- **节点数**：21 | **贴图节点**：3 | **Widget 布局节点**：1

**引用贴图 (2 个)**：
  - `184257350.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`

**Sprite 帧 (3 个)**：
  - `default_btn_disabled`
  - `sc_tag_vip`
  - `sc_tag_xiyou`

**文本内容 (前10个)**：
  - "稀有"
  - "战意专属"
  - "500"
  - "20/100"
  - "vip2专属"

### 商店购买确认
- **Prefab 路径**：`Prefab/Shop/ShopBuyEquitPre`
- **Layout 文件**：`data/prefab_layouts/ShopBuyEquitPre.json`
- **节点数**：33 | **贴图节点**：7 | **Widget 布局节点**：5

**引用贴图 (7 个)**：
  - `15a1d9111.png`
  - `184257350.png`
  - `18b29ae48.png`
  - `1a61aeab8.png`
  - `1d816a710.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`

**Sprite 帧 (7 个)**：
  - `cm_btn_LvSe1`
  - `cm_btn_LvSe1_1`
  - `cm_btn_shujiajia`
  - `default_btn_disabled`
  - `default_btn_normal`
  - `sc_frame9_kongjian1di2`
  - `xs_slider_qingbao1`

**文本内容 (前10个)**：
  - "购买数量:"
  - "购买"
  - "x21"

### 英雄
- **Prefab 路径**：`Prefab/HeroPanel/HeroMainPre`
- **Layout 文件**：`data/prefab_layouts/HeroMainPre.json`
- **节点数**：170 | **贴图节点**：22 | **Widget 布局节点**：8

**引用贴图 (14 个)**：
  - `11df61351.png`
  - `14d2fafcf.png`
  - `15a1d9111.png`
  - `1604df330.png`
  - `18b29ae48.png`
  - `19ec60a29.png`
  - `1d28f92d9.png`
  - `1d816a710.png`
  - `6584b3e8-bae9-4ef6-8379-4161f13fa2d2.png`
  - `929b60ed-1b1e-4419-b357-d7c9d1e43436.jpg`
  - `9ec8c387-6381-46b4-93eb-7ebe016dbffc.png`
  - `d3604276-914a-4e56-a652-e53ab2b66f64.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
  - `ec048890-57a1-4fde-bb09-c62023058814.png`

**Sprite 帧 (22 个)**：
  - `101`
  - `112`
  - `cm_QuanPinBG`
  - `cm_btn_LvSe0`
  - `cm_btn_PingLun`
  - `cm_btn_ShiZhuang`
  - `cm_frame9_biaotidi`
  - `cm_frame_HuoBi3`
  - `cm_icon_FangYu`
  - `cm_icon_GongJi`
  - `cm_icon_HongDian`
  - `cm_icon_XingXing1_1`
  - `cm_icon_ZhanLi`
  - `cm_line_RongQi`
  - `cm_line_XiaoBiaoTi`
  - `cm_mask_QuanPinLieBiao1`
  - `cm_tab2_off`
  - `default_btn_normal`
  - `xyxhd_btn_yingxiongyulan`
  - `yx_frame_BaiBan`
  - ... 还有 2 个

**文本内容 (前10个)**：
  - "120360"
  - "12345"
  - "英雄"
  - "3"
  - "英雄名字"
  - "英雄名字"
  - "120/360"
  - "120360"
  - "120360"
  - "升2级"
  - ... 还有 32 条

### 英雄详情
- **Prefab 路径**：`Prefab/HeroPanel/HeroBookDetailPre`
- **Layout 文件**：`data/prefab_layouts/HeroBookDetailPre.json`
- **节点数**：117 | **贴图节点**：13 | **Widget 布局节点**：6

**引用贴图 (9 个)**：
  - `089f225e-78e8-428c-aeec-39bb5b669f43.png`
  - `15a1d9111.png`
  - `18b29ae48.png`
  - `19ec60a29.png`
  - `1d28f92d9.png`
  - `1d816a710.png`
  - `3b40416e-3446-4e12-8754-83cca6313046.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`
  - `b43ff3c2-02bb-4874-81f7-f2dea6970f18.png`

**Sprite 帧 (13 个)**：
  - `5050091`
  - `cm_btn_chakan`
  - `cm_btn_fanhui2`
  - `cm_btn_huangse1_1`
  - `cm_line_RongQi`
  - `cm_line_XiaoBiaoTi`
  - `cm_mask_QuanPinLieBiao2`
  - `cm_tab2_on`
  - `cm_tag_SSR2`
  - `default_btn_disabled`
  - `default_btn_pressed`
  - `lhsz_btn_qieping`
  - `yx_frame_BaiBan`

**文本内容 (前10个)**：
  - "12345"
  - "图鉴"
  - "3"
  - "英雄名字"
  - "英雄标签"
  - "高输出 物理伤害"
  - "165cm"
  - "22"
  - "冷酷"
  - "78kg"
  - ... 还有 28 条

### 英雄页签
- **Prefab 路径**：`Prefab/HeroPanel/HeroTabPre`
- **Layout 文件**：`data/prefab_layouts/HeroTabPre.json`
- **节点数**：16 | **贴图节点**：1 | **Widget 布局节点**：0

**引用贴图 (1 个)**：
  - `15a1d9111.png`

**Sprite 帧 (1 个)**：
  - `cm_tab2_on`

**文本内容 (前10个)**：
  - "培
养"
  - "装
备"
  - "升
星"
  - "战
意"
  - "饰品"
  - "升
星"

### 英雄列表
- **Prefab 路径**：`Prefab/HeroListPanel/HeroListPre`
- **Layout 文件**：`data/prefab_layouts/HeroListPre.json`
- **节点数**：58 | **贴图节点**：10 | **Widget 布局节点**：6

**引用贴图 (8 个)**：
  - `089f225e-78e8-428c-aeec-39bb5b669f43.png`
  - `14d2fafcf.png`
  - `15a1d9111.png`
  - `18b29ae48.png`
  - `c8384043-da3b-41dd-95e5-2ce3d2028977.png`
  - `d7549124-d268-4341-9e69-5c65e56a1d49.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
  - `ec048890-57a1-4fde-bb09-c62023058814.png`

**Sprite 帧 (10 个)**：
  - `cm_btn_BangZhu`
  - `cm_btn_JiaHao`
  - `cm_icon_HongDian`
  - `cm_icon_ZhenYing1`
  - `cm_icon_ZhenYing4`
  - `cm_icon_ZhenYing6`
  - `cm_mask_QuanPinLieBiao1`
  - `cm_mask_QuanPinLieBiao2`
  - `cm_tab1_on`
  - `default_btn_normal`

**文本内容 (前10个)**：
  - "英雄"
  - "图鉴"
  - "英魂"
  - "共鸣"
  - "法阵"
  - "星辉"
  - "228/450"

### 英雄列表卡片
- **Prefab 路径**：`Prefab/comPrefab/HeroGridPre`
- **Layout 文件**：`data/prefab_layouts/HeroGridPre.json`
- **节点数**：45 | **贴图节点**：10 | **Widget 布局节点**：0

**引用贴图 (9 个)**：
  - `15a1d9111.png`
  - `163190da-39e9-4c6d-9a21-08f78225fe2f.png`
  - `18b29ae48.png`
  - `19ec60a29.png`
  - `3a30c88d-1f0a-44b3-b048-ab8a91a84038.png`
  - `5ee39f50-ef9d-4780-a5bb-f679e0080db0.png`
  - `6584b3e8-bae9-4ef6-8379-4161f13fa2d2.png`
  - `bb54d77e-02ea-4b81-8204-c992ae79d305.png`
  - `d7549124-d268-4341-9e69-5c65e56a1d49.png`

**Sprite 帧 (10 个)**：
  - `bb_progressBG_SuiPian`
  - `cm_frame_TouXiangKuang6`
  - `cm_icon_SuoDing`
  - `cm_icon_XingXing1_1`
  - `cm_icon_XingXing3_1`
  - `cm_icon_ZhenYing4`
  - `cm_icon_ban`
  - `cm_icon_yuan`
  - `cm_progress_touxiangxuetiao`
  - `xzyx_frame_mengban`

**文本内容 (前10个)**：
  - "已阵亡"
  - "1"
  - "3"
  - "3"
  - "上阵中"
  - "100"

### 英雄图鉴卡片
- **Prefab 路径**：`Prefab/HeroListPanel/HeroBookItemPre`
- **Layout 文件**：`data/prefab_layouts/HeroBookItemPre.json`
- **节点数**：32 | **贴图节点**：3 | **Widget 布局节点**：0

**引用贴图 (3 个)**：
  - `14d2fafcf.png`
  - `1604df330.png`
  - `27d01a37-7907-4d1b-883f-fed004ac922b.png`

**Sprite 帧 (3 个)**：
  - `cm_frame_kadicheng`
  - `cm_icon_ZhenYing5`
  - `cm_mask_juese`

**文本内容 (前10个)**：
  - "英雄的名字"
  - "3"

### 英雄等级共享
- **Prefab 路径**：`Prefab/HeroListPanel/HeroLevelSharedPre`
- **Layout 文件**：`data/prefab_layouts/HeroLevelSharedPre.json`
- **节点数**：118 | **贴图节点**：4 | **Widget 布局节点**：2

**引用贴图 (4 个)**：
  - `167d391d0.png`
  - `18b29ae48.png`
  - `7a849744-e05b-4906-bc28-b8c69c8032c3.png`
  - `fa75a61e-9604-40cf-b07f-23655ab99ff8.png`

**Sprite 帧 (3 个)**：
  - `changanniu`
  - `cm_icon_SuoDing`
  - `yxtj_Frame_di`

**文本内容 (前10个)**：
  - "120360"
  - "冷却中"
  - "解锁"
  - "150级"
  - "150级"
  - "150级"
  - "150级"
  - "150级"
  - "最低等级"
  - "1000"
  - ... 还有 12 条

### 英雄阵容
- **Prefab 路径**：`Prefab/HeroXZPrefab/HeroNormalarrayPre`
- **Layout 文件**：`data/prefab_layouts/HeroNormalarrayPre.json`
- **节点数**：91 | **贴图节点**：8 | **Widget 布局节点**：2

**引用贴图 (8 个)**：
  - `1e7cde78-9132-4508-9a6f-336cf8a62c03.png`
  - `3c5d92ea-7e41-4ef5-a18b-e9804a4e051d.png`
  - `3e2bc165-dfc0-4f4d-9d48-b79987a0bb3b.png`
  - `472bf6ae-0b03-4459-a83a-10003eb0faaf.png`
  - `506cb3e2-70b1-429c-b7ab-4f2d61d309c1.png`
  - `d0cccd97-a1e8-4152-aecb-38157314d9ed.png`
  - `d6d3ca85-4681-47c1-b5dd-d036a9d39ea2.png`
  - `e4a12a0a-afdc-402e-978c-47ed97666606.png`

**Sprite 帧 (8 个)**：
  - `default_scrollbar_vertical`
  - `lb-wenhao`
  - `zdbz_btn_ZhenXing`
  - `zdbz_image_GeZiDi`
  - `zdbz_image_GeZiOn1`
  - `zdbz_image_GeZiOn3`
  - `zdbz_image_GeZiOn5`
  - `zdbz_image_GeZiOn7`

**文本内容 (前10个)**：
  - "白羊座"
  - "30级"
  - "3级"
  - "3级"
  - "3级"
  - "3级"
  - "3级"
  - "3级"
  - "3级"
  - "3级"
  - ... 还有 11 条

### 英雄升星
- **Prefab 路径**：`Prefab/HeroXZPrefab/HeroStarPre`
- **Layout 文件**：`data/prefab_layouts/HeroStarPre.json`
- **节点数**：30 | **贴图节点**：2 | **Widget 布局节点**：1

**引用贴图 (2 个)**：
  - `51e3fcf8-1cf6-4d11-9a6a-8ede77c0fc45.png`
  - `fa75a61e-9604-40cf-b07f-23655ab99ff8.png`

**Sprite 帧 (2 个)**：
  - `changanniu`
  - `dikuang6`

**文本内容 (前10个)**：
  - "目标材料"
  - "四象星辉"
  - "四象魔尘"
  - "可用道具"
  - "预计获得"
  - "水相魔尘"
  - "转化"

### 背包
- **Prefab 路径**：`Prefab/BagPanel/BagPre`
- **Layout 文件**：`data/prefab_layouts/BagPre.json`
- **节点数**：62 | **贴图节点**：8 | **Widget 布局节点**：4

**引用贴图 (6 个)**：
  - `089f225e-78e8-428c-aeec-39bb5b669f43.png`
  - `14d2fafcf.png`
  - `15a1d9111.png`
  - `1604df330.png`
  - `18b29ae48.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`

**Sprite 帧 (8 个)**：
  - `cm_Line_ShenSeFenGe`
  - `cm_btn_BanTou3`
  - `cm_frame9_QuanPinJieMian2`
  - `cm_frame9_xitongtishi`
  - `cm_mask_QuanPinLieBiao2`
  - `cm_tab1_off`
  - `cm_tab1_on`
  - `default_btn_disabled`

**文本内容 (前10个)**：
  - "装备"
  - "装备"
  - "道具"
  - "道具"
  - "碎片"
  - "碎片"
  - "符文"
  - "符文"
  - "神器"
  - "神器"
  - ... 还有 4 条

### 背包格子
- **Prefab 路径**：`Prefab/BagPanel/GridBoxItemPre`
- **Layout 文件**：`data/prefab_layouts/GridBoxItemPre.json`
- **节点数**：6 | **贴图节点**：1 | **Widget 布局节点**：0

**引用贴图 (1 个)**：
  - `18b29ae48.png`

**Sprite 帧 (1 个)**：
  - `cm_select_fuxuan1on`

### 抽卡
- **Prefab 路径**：`Prefab/DrawCard/drawCardPre`
- **Layout 文件**：`data/prefab_layouts/drawCardPre.json`
- **节点数**：166 | **贴图节点**：15 | **Widget 布局节点**：13

**引用贴图 (8 个)**：
  - `14003f053.png`
  - `17cfeb087.png`
  - `18b29ae48.png`
  - `1a8c36b95.png`
  - `208d427e-9508-49d1-90fd-347250e7b375.png`
  - `6f4ea549-dfba-48c2-9f59-db1fbd28680b.png`
  - `75670df3-3c46-493a-93d2-59d30a110e9c.png`
  - `7d68a9f3-36ad-4a63-bdea-75784fefcfda.jpg`

**Sprite 帧 (12 个)**：
  - `cm_btn_BangZhu`
  - `zh_bg`
  - `zh_btn_putongoff`
  - `zh_btn_putongon`
  - `zh_btn_xianzhioff`
  - `zh_icon_zhenying4`
  - `zh_image_pan0`
  - `zh_image_pan8`
  - `zh_image_pan9`
  - `zh_progressbar_jiangli`
  - `zh_select_zhizhen`
  - `zh_title_tip`

**Spine 骨骼动画**：
  - `zhuanpan_idle`

**文本内容 (前10个)**：
  - "免费召唤"
  - "20:23:56后免费"
  - "推荐阵容"
  - "英雄转换"
  - "1000"
  - "免费召唤"
  - "1000"
  - "召唤10次"
  - "0/100"
  - "前往召唤"
  - ... 还有 25 条

### 战斗
- **Prefab 路径**：`Prefab/Battle/battle`
- **Layout 文件**：`data/prefab_layouts/battle.json`
- **节点数**：43 | **贴图节点**：0 | **Widget 布局节点**：0

**引用贴图 (0 个)**：

### 活动抽卡
- **Prefab 路径**：`Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre`
- **Layout 文件**：`data/prefab_layouts/DrawCardActivityPre.json`
- **节点数**：8 | **贴图节点**：1 | **Widget 布局节点**：0

**引用贴图 (1 个)**：
  - `f86301ec-43cd-48e5-a09c-4f7e6683e6d8.png`

**Sprite 帧 (1 个)**：
  - `qtl_bj`

### 活动抽卡-登录领取
- **Prefab 路径**：`Prefab/ActivityPanel/DrawCardActivity/13002`
- **Layout 文件**：`data/prefab_layouts/13002.json`
- **节点数**：16 | **贴图节点**：3 | **Widget 布局节点**：2

**引用贴图 (3 个)**：
  - `083fe93c-c0d5-4e8f-b7a0-9eb62a398952.png`
  - `15a1d9111.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`

**Sprite 帧 (3 个)**：
  - `bx_icon_04a`
  - `default_btn_disabled`
  - `xs_slider_shijian1`

**文本内容 (前10个)**：
  - "达成条件可领取黄金大宝箱"

### 活动抽卡-循环礼包
- **Prefab 路径**：`Prefab/ActivityPanel/DrawCardActivity/13003`
- **Layout 文件**：`data/prefab_layouts/13003.json`
- **节点数**：24 | **贴图节点**：0 | **Widget 布局节点**：0

**引用贴图 (0 个)**：

**文本内容 (前10个)**：
  - "对"
  - "应"
  - "奖"
  - "励"
  - "活动期间累计消耗钻石达到指定金额即可领取"
  - "即可领取"
  - "领取"
  - "已领取"
  - "前往"

### 活动抽卡-抽数任务
- **Prefab 路径**：`Prefab/ActivityPanel/DrawCardActivity/13004`
- **Layout 文件**：`data/prefab_layouts/13004.json`
- **节点数**：44 | **贴图节点**：6 | **Widget 布局节点**：0

**引用贴图 (3 个)**：
  - `14003f053.png`
  - `17f7aa586.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`

**Sprite 帧 (6 个)**：
  - `bx_icon_02a`
  - `bx_icon_04a`
  - `default_btn_disabled`
  - `zsrw_progress_jiangli`
  - `zsrw_progress_renwu`
  - `zsrw_progressbg_renwu`

**文本内容 (前10个)**：
  - "领取"
  - "1"
  - "2"
  - "3"
  - "4"
  - "5"
  - "6"
  - "同一英雄仅限参与一次"
  - "已完成"

### 活动抽卡-许愿礼包
- **Prefab 路径**：`Prefab/ActivityPanel/DrawCardActivity/13005`
- **Layout 文件**：`data/prefab_layouts/13005.json`
- **节点数**：5 | **贴图节点**：0 | **Widget 布局节点**：2

**引用贴图 (0 个)**：

### 活动抽卡页签
- **Prefab 路径**：`Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityToggle`
- **Layout 文件**：`data/prefab_layouts/DrawCardActivityToggle.json`
- **节点数**：6 | **贴图节点**：1 | **Widget 布局节点**：0

**引用贴图 (1 个)**：
  - `18b29ae48.png`

**Sprite 帧 (1 个)**：
  - `cm_icon_HongDian`

### 公会
- **Prefab 路径**：`Prefab/Guild/GuildMainPre`
- **Layout 文件**：`data/prefab_layouts/GuildMainPre.json`
- **节点数**：98 | **贴图节点**：9 | **Widget 布局节点**：13

**引用贴图 (7 个)**：
  - `18b29ae48.png`
  - `1d8242d57.png`
  - `1fd3df656.png`
  - `aa6096be-9b00-4e64-9b5d-15f858984e3e.png`
  - `cf9b7166-9d0c-4a24-8457-b7ef1db55643.png`
  - `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
  - `e951bf2e-e2e9-4201-b192-d85a311d9e2b.png`

**Sprite 帧 (7 个)**：
  - `GongHui_BG02`
  - `GongHui_Stool_F`
  - `cm_icon_HongDian`
  - `cm_imput_ShenSe`
  - `default_btn_normal`
  - `gh_frame_rukoudi1`
  - `gh_frame_rukoudi2`

**Spine 骨骼动画**：
  - `GongHui_Flag_Door_O`
  - `GongHui_Flag_T`
  - `GongHui_KeJi`
  - `GongHui_XiWeiEr`
  - `GongHui_jianguang`

**文本内容 (前10个)**：
  - "首领"
  - "福利日：公会首领挑战双倍奖励"
  - "科技"
  - "公会名字六字"
  - "Lv6"
  - "详情"
  - "商店"
  - "捐献"
  - "任务"
  - "公会宣言"
  - ... 还有 3 条

### 竞技
- **Prefab 路径**：`Prefab/JingjiPrefab/JingjiPre`
- **Layout 文件**：`data/prefab_layouts/JingjiPre.json`
- **节点数**：74 | **贴图节点**：0 | **Widget 布局节点**：0

**引用贴图 (0 个)**：

**文本内容 (前10个)**：
  - "冠军联赛"
  - "战神殿"
  - "王者争霸"
  - "组队竞技"
  - "巅峰对决"
  - "暂未开放"
  - "挑战条件：冠军联赛50名以内"
  - "当前冠军联赛排名："
  - "暂未开放"
  - "历史最高"
  - ... 还有 13 条

### 天空城
- **Prefab 路径**：`Prefab/SkyCityPanel/SkyCityPre`
- **Layout 文件**：`data/prefab_layouts/SkyCityPre.json`
- **节点数**：46 | **贴图节点**：6 | **Widget 布局节点**：4

**引用贴图 (6 个)**：
  - `15a1d9111.png`
  - `18b29ae48.png`
  - `35075d2d-3b76-4891-ab91-dbf7631cd243.png`
  - `3ea5b0b8-e5de-4cb5-ae9c-647340ed97ae.png`
  - `71561142-4c83-4933-afca-cb7a17f67053.png`
  - `e20726ef-252b-44c5-a8c6-b0a44b449b65.png`

**Sprite 帧 (4 个)**：
  - `cm_frame_HuoBi2`
  - `cm_icon_HongDian`
  - `default_btn_disabled`
  - `kongzhonghuayuan-dao`

**文本内容 (前10个)**：
  - "一键领取"
  - "出征"
  - "战意制作"

---

## 图集贴图清单

以下贴图来自 Cocos 图集打包（短名格式），通常在一个 PNG 中包含多个 SpriteFrame。
共 25 个图集：

- `11df61351.png`
- `14003f053.png`
- `140096250.png`
- `1430d496a.png`
- `14d2fafcf.png`
- `15a1d9111.png`
- `1604df330.png`
- `167d391d0.png`
- `17cfeb087.png`
- `17f7aa586.png`
- `184257350.png`
- `18935b9e9.png`
- `18b29ae48.png`
- `199822ca2.png`
- `19ac1e70d.png`
- `19ec60a29.png`
- `1a61aeab8.png`
- `1a7921f32.png`
- `1a8c36b95.png`
- `1d1cac610.png`
- `1d28f92d9.png`
- `1d816a710.png`
- `1d8242d57.png`
- `1f6b547b4.png`
- `1fd3df656.png`

## 独立贴图清单

共 53 个独立贴图：

- `0275e94c-56a7-410f-bd1a-fc7483f7d14a.png`
- `083fe93c-c0d5-4e8f-b7a0-9eb62a398952.png`
- `089f225e-78e8-428c-aeec-39bb5b669f43.png`
- `163190da-39e9-4c6d-9a21-08f78225fe2f.png`
- `1e7cde78-9132-4508-9a6f-336cf8a62c03.png`
- `208d427e-9508-49d1-90fd-347250e7b375.png`
- `27d01a37-7907-4d1b-883f-fed004ac922b.png`
- `35075d2d-3b76-4891-ab91-dbf7631cd243.png`
- `3a30c88d-1f0a-44b3-b048-ab8a91a84038.png`
- `3b40416e-3446-4e12-8754-83cca6313046.png`
- `3c5d92ea-7e41-4ef5-a18b-e9804a4e051d.png`
- `3e2bc165-dfc0-4f4d-9d48-b79987a0bb3b.png`
- `3ea5b0b8-e5de-4cb5-ae9c-647340ed97ae.png`
- `472bf6ae-0b03-4459-a83a-10003eb0faaf.png`
- `478e6f30-ec49-48dd-8704-e191a5e4b607.jpg`
- `47e154d7-f9c2-4a5a-85c0-b299960f439b.png`
- `506cb3e2-70b1-429c-b7ab-4f2d61d309c1.png`
- `51e3fcf8-1cf6-4d11-9a6a-8ede77c0fc45.png`
- `5e7260ec-ef10-44da-88fb-ecf9825936dc.png`
- `5eb3feb3-a5f7-4c64-a9b0-a2c5528e79b7.png`
- `5ee39f50-ef9d-4780-a5bb-f679e0080db0.png`
- `6584b3e8-bae9-4ef6-8379-4161f13fa2d2.png`
- `6e0a08c4-ce5c-4071-b1ed-ddb9b5beb9a1.png`
- `6f4ea549-dfba-48c2-9f59-db1fbd28680b.png`
- `71561142-4c83-4933-afca-cb7a17f67053.png`
- `75670df3-3c46-493a-93d2-59d30a110e9c.png`
- `7a849744-e05b-4906-bc28-b8c69c8032c3.png`
- `7d68a9f3-36ad-4a63-bdea-75784fefcfda.jpg`
- `83903e83-5933-42e2-b569-f4c51ebdea94.png`
- `8715b80b-6cbc-4b88-bf7d-8c2ab401db4e.png`
- `929b60ed-1b1e-4419-b357-d7c9d1e43436.jpg`
- `93e457e9-3554-4660-801b-b9c1613abdc8.png`
- `9a9cb544-24ba-41c7-8cab-41a43a9e9c33.png`
- `9ec8c387-6381-46b4-93eb-7ebe016dbffc.png`
- `aa6096be-9b00-4e64-9b5d-15f858984e3e.png`
- `b43ff3c2-02bb-4874-81f7-f2dea6970f18.png`
- `bb54d77e-02ea-4b81-8204-c992ae79d305.png`
- `c8384043-da3b-41dd-95e5-2ce3d2028977.png`
- `cdc789e9-d998-4c15-8920-b7ac60af8734.png`
- `cf9b7166-9d0c-4a24-8457-b7ef1db55643.png`
- `d0cccd97-a1e8-4152-aecb-38157314d9ed.png`
- `d3604276-914a-4e56-a652-e53ab2b66f64.png`
- `d6d3ca85-4681-47c1-b5dd-d036a9d39ea2.png`
- `d7549124-d268-4341-9e69-5c65e56a1d49.png`
- `e116f353-6974-488e-86a7-19f294f47e7b.png`
- `e20726ef-252b-44c5-a8c6-b0a44b449b65.png`
- `e4a12a0a-afdc-402e-978c-47ed97666606.png`
- `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png`
- `e951bf2e-e2e9-4201-b192-d85a311d9e2b.png`
- `ec048890-57a1-4fde-bb09-c62023058814.png`
- `edd215b9-2796-4a05-aaf5-81f96c9281ce.png`
- `f86301ec-43cd-48e5-a09c-4f7e6683e6d8.png`
- `fa75a61e-9604-40cf-b07f-23655ab99ff8.png`

---

## 贴图共享分析

以下贴图被 3 个及以上界面引用（公共资源）：

| 贴图 | 引用界面数 | 类型 |
|-----|-----------|------|
| `18b29ae48.png` | 17 | 图集 |
| `15a1d9111.png` | 12 | 图集 |
| `71561142-4c83-4933-afca-cb7a17f67053.png` | 8 | 独立贴图 |
| `e851e89b-faa2-4484-bea6-5c01dd9f06e2.png` | 7 | 独立贴图 |
| `14d2fafcf.png` | 6 | 图集 |
| `1d816a710.png` | 5 | 图集 |
| `19ec60a29.png` | 4 | 图集 |
| `089f225e-78e8-428c-aeec-39bb5b669f43.png` | 3 | 独立贴图 |
| `1604df330.png` | 3 | 图集 |
| `184257350.png` | 3 | 图集 |
| `b43ff3c2-02bb-4874-81f7-f2dea6970f18.png` | 3 | 独立贴图 |
| `1430d496a.png` | 3 | 图集 |


**注**：`18b29ae48.png` 被 29 个界面引用（占 35 个界面的 83%），是核心公共图集。

---

## 资源包 (Bundle) 统计

| 包名 | 资产数 | 场景数 | 主要内容 |
|-----|--------|--------|---------|
| `resources` | 17141 | 0 | Prefab 1007, SpriteFrame 8139, Texture 4744, Spine 993, Audio 1061 |
| `main` | 0 | 2 | 主场景 Main.fire, updataScene.fire |
| `internal` | 17 | 0 | Effect 8, Material 9 (引擎内置) |

---

## Spine 动画资源清单

| 名称 | 所属界面 | 用途推断 |
|-----|---------|---------|
| `cm_icon_YingXiong` | 主城导航 | 英雄导航图标动画 |
| `cm_icon_GongHui` | 主城导航 | 公会导航图标动画 |
| `cm_icon_ChuJi` | 主城导航 | 出击导航图标动画 |
| `LaRuiOu_LH` | 主城默认角色(105004) | 主城默认展示角色 Spine |
| `zhuanpan_idle` | 抽卡 | 抽卡转盘待机动画 |
| `GongHui_Flag_Door_O` | 公会 | 公会旗帜(门) |
| `GongHui_Flag_T` | 公会 | 公会旗帜 |
| `GongHui_KeJi` | 公会 | 公会科技图标 |
| `GongHui_XiWeiEr` | 公会 | 公会 NPC 动画 |
| `GongHui_jianguang` | 公会 | 公会剑光特效 |
