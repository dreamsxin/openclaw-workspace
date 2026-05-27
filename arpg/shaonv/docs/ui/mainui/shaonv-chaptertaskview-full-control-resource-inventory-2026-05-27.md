# ChapterTaskView 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `ChapterTaskView`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterTaskView.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_chapter_chaptertaskview.bundle` / `files\yoo\Default\BundleFiles\69\6945f358378121b0baefe8ef03c3f00e\__data`
- 节点数：`35`。
- Image/Text/Button：`17` / `6` / `4`。
- Image 解析：外部 Sprite `10`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `1`，无 sprite `6`，未解析 `0`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `UISprite` | 1 | `Assets/Game/RawAssets/Prefabs/UI/Chapter/ChapterTaskView.prefab#Sprite/UISprite` | `assets_game_rawassets_prefabs_ui_chapter_chaptertaskview.bundle` | `6945f358378121b0baefe8ef03c3f00e.bundle`<br>`files\yoo\Default\BundleFiles\69\6945f358378121b0baefe8ef03c3f00e\__data` | internal Sprite in prefab bundle |
| `hero_bg_01` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/hero_bg_01.png` | `assets_game_rawassets_sprite_background_hero_bg_01.bundle` | `2b868a7a94d216d7a7e215338398da37.bundle`<br>`files\yoo\Default\BundleFiles\2b\2b868a7a94d216d7a7e215338398da37\__data` | external CAB-73d82b519c8c7d1f9dc5d3330606233f |
| `task_bg_01` | 1 | `Assets/Game/RawAssets/Sprite/BackGround/task_bg_01.png` | `assets_game_rawassets_sprite_background_task_bg_01.bundle` | `81f2e0caff1bec6fdd69ece5ad5f2bf1.bundle`<br>`files\yoo\Default\BundleFiles\81\81f2e0caff1bec6fdd69ece5ad5f2bf1\__data` | external CAB-58914aa1370a7dd33051c7f4ab34c6b1 |
| `common_btn_17` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_17.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `hero_img_253` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_253.png` | `assets_game_rawassets_sprite_hero.bundle` | `dd47df4c8590a3b4328f7738890d7a8b.bundle`<br>`resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` | external CAB-b96ec7217268586ea7cfe3cace0b83ac |
| `hero_img_219` | 1 | `Assets/Game/RawAssets/Sprite/Hero/hero_img_219.png` | `assets_game_rawassets_sprite_hero_hero_img_219.bundle` | `cdac970332fe473a649ddf65ae6b4bda.bundle`<br>`files\yoo\Default\UnpackBundleFiles\cd\cdac970332fe473a649ddf65ae6b4bda\__data` | external CAB-f96a7622ac745f7ed34179db3162b1bc |
| `task_btn_01` | 1 | `Assets/Game/RawAssets/Sprite/Task/task_btn_01.png` | `assets_game_rawassets_sprite_task.bundle` | `16317ad091fe49057dc1e5ab10203a9c.bundle`<br>`files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` | external CAB-6f622e0fc6cdf1596810cdfd307887d2 |
| `task_img_37` | 1 | `Assets/Game/RawAssets/Sprite/Task/task_img_37.png` | `assets_game_rawassets_sprite_task.bundle` | `16317ad091fe49057dc1e5ab10203a9c.bundle`<br>`files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` | external CAB-6f622e0fc6cdf1596810cdfd307887d2 |
| `task_img_39` | 1 | `Assets/Game/RawAssets/Sprite/Task/task_img_39.png` | `assets_game_rawassets_sprite_task.bundle` | `16317ad091fe49057dc1e5ab10203a9c.bundle`<br>`files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` | external CAB-6f622e0fc6cdf1596810cdfd307887d2 |
| `task_img_13` | 2 | `Assets/Game/RawAssets/Sprite/Task/task_img_13.png` | `assets_game_rawassets_sprite_task_task_img_13.bundle` | `f5d26c8d5713e9f71e20156c7441727f.bundle`<br>`files\yoo\Default\BundleFiles\f5\f5d26c8d5713e9f71e20156c7441727f\__data` | external CAB-75c9f4d0aa3ed0a37d2b991fb2d9a5ee |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-75c9f4d0aa3ed0a37d2b991fb2d9a5ee` | `assets_game_rawassets_sprite_task_task_img_13.bundle` | `files\yoo\Default\BundleFiles\f5\f5d26c8d5713e9f71e20156c7441727f\__data` |
| 2 | `CAB-d658a91595cb5cdab7e786ba072b54a2` | `-` | `-` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 4 | `CAB-73d82b519c8c7d1f9dc5d3330606233f` | `assets_game_rawassets_sprite_background_hero_bg_01.bundle` | `files\yoo\Default\BundleFiles\2b\2b868a7a94d216d7a7e215338398da37\__data` |
| 5 | `CAB-f96a7622ac745f7ed34179db3162b1bc` | `assets_game_rawassets_sprite_hero_hero_img_219.bundle` | `files\yoo\Default\UnpackBundleFiles\cd\cdac970332fe473a649ddf65ae6b4bda\__data` |
| 6 | `CAB-58914aa1370a7dd33051c7f4ab34c6b1` | `assets_game_rawassets_sprite_background_task_bg_01.bundle` | `files\yoo\Default\BundleFiles\81\81f2e0caff1bec6fdd69ece5ad5f2bf1\__data` |
| 7 | `CAB-6f622e0fc6cdf1596810cdfd307887d2` | `assets_game_rawassets_sprite_task.bundle` | `files\yoo\Default\BundleFiles\16\16317ad091fe49057dc1e5ab10203a9c\__data` |
| 8 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 9 | `CAB-0d5731a6a534bfedecdb443e393185d2` | `-` | `-` |
| 10 | `CAB-44b5aec40c4435959d281419c95097a3` | `-` | `-` |
| 11 | `CAB-b96ec7217268586ea7cfe3cace0b83ac` | `assets_game_rawassets_sprite_hero.bundle` | `resources\assets\yoo\Default\dd47df4c8590a3b4328f7738890d7a8b.bundle` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `ChapterTaskView` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,Animator,ChapterTaskView` | - |
| 2 | 1 | `ChapterTaskView/Image` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_bg_01 [Simple] -> assets_game_rawassets_sprite_background_hero_bg_01.bundle |
| 3 | 2 | `ChapterTaskView/Image/@fx_imgBg_star` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 4 | 1 | `ChapterTaskView/pnlContent` | Y | `pos(0.0,0.0) size(76.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,RectTransformLerp` | - |
| 5 | 2 | `ChapterTaskView/pnlContent/pnlReward` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:none [Simple], a=0.00 |
| 6 | 3 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre` | Y | `pos(329.0,81.0) size(0.0,0.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,RectTransformLerp` | - |
| 7 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/spineRewardPre` | N | `pos(1.0,-150.0) size(1000.0,1000.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 8 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/imgRewardPre` | N | `pos(0.0,300.0) size(600.0,600.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 9 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre` | N | `pos(0.0,240.0) size(957.5,750.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,InteractiveRole,UiPinchZoom,Canvas,GraphicRaycaster,CanvasGroup` | - |
| 10 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/btn` | Y | `pos(0.0,272.0) size(418.2,804.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:UISprite [Sliced] -> assets_game_rawassets_prefabs_ui_chapter_chaptertaskview.bundle, a=0.00<br>Button |
| 11 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/spBg` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 12 | 6 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/spBg/Renderer0` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonSubmeshGraphic` | - |
| 13 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/spHero` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 14 | 6 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/spHero/Renderer0` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonSubmeshGraphic` | - |
| 15 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/spFg` | Y | `pos(0.0,0.0) size(100.0,100.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonGraphic` | - |
| 16 | 6 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/spFg/Renderer0` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,SkeletonSubmeshGraphic` | - |
| 17 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/imgMask` | Y | `pos(0.0,0.0) size(324.0,274.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_253 [Simple] -> assets_game_rawassets_sprite_hero.bundle |
| 18 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/imgSpeak` | N | `pos(0.0,85.0) size(668.0,154.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.0)` | `RectTransform,CanvasRenderer,Image` | Image:hero_img_219 [Simple] -> assets_game_rawassets_sprite_hero_hero_img_219.bundle |
| 19 | 6 | `ChapterTaskView/pnlContent/pnlReward/pnlRewardPre/@RoleRewardPre/imgSpeak/Text` | Y | `pos(0.0,0.0) size(585.0,45.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,ContentSizeFitter` | Text(fs=18):"交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械..." |
| 20 | 3 | `ChapterTaskView/pnlContent/pnlReward/Image_spinemask` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:task_bg_01 [Simple] -> assets_game_rawassets_sprite_background_task_bg_01.bundle |
| 21 | 3 | `ChapterTaskView/pnlContent/pnlReward/btnRewardReview` | Y | `pos(59.0,-95.0) size(60.0,60.0)` | `0.0,1.0->0.0,1.0 p(0.0,1.0)` | `RectTransform,CanvasRenderer,Image,Button,CanvasGroup` | Image:task_btn_01 [Simple] -> assets_game_rawassets_sprite_task.bundle<br>Button |
| 22 | 4 | `ChapterTaskView/pnlContent/pnlReward/btnRewardReview/Text` | Y | `pos(0.0,-48.0) size(56.0,20.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=14):"奖励预览" |
| 23 | 3 | `ChapterTaskView/pnlContent/pnlReward/Image` | Y | `pos(66.0,94.0) size(500.0,150.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Image,RectTransformLerp` | Image:task_img_39 [Simple] -> assets_game_rawassets_sprite_task.bundle |
| 24 | 4 | `ChapterTaskView/pnlContent/pnlReward/Image/txtTips` | Y | `pos(-7.0,-4.0) size(-162.0,-78.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"11111111111111111111111" |
| 25 | 4 | `ChapterTaskView/pnlContent/pnlReward/Image/btnGo` | Y | `pos(-55.0,16.0) size(54.0,54.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:task_img_37 [Simple] -> assets_game_rawassets_sprite_task.bundle<br>Button |
| 26 | 3 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno` | Y | `pos(-448.5,246.0) size(729.0,170.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasGroup` | - |
| 27 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno/txtName` | Y | `pos(-726.0,72.5) size(258.0,25.0)` | `1.0,0.5->1.0,0.5 p(0.0,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=25):"第2章·第一缕曙光" |
| 28 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno/txtProgress` | Y | `pos(-46.0,72.5) size(52.0,25.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=24):"<color=#D3F759>1</color>/10" |
| 29 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno/svChapterReward` | Y | `pos(-131.0,-26.0) size(436.0,84.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,CanvasRenderer,Image,GridScroller,RectMask2D` | Image:none [Sliced], a=0.00 |
| 30 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno/btnGetFull` | Y | `pos(-129.0,-26.0) size(240.0,64.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_17 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 31 | 5 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno/btnGetFull/Text` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=26):"领取" |
| 32 | 4 | `ChapterTaskView/pnlContent/pnlReward/pnlChapterIfno/Image` | Y | `pos(0.5,46.0) size(768.0,8.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:task_img_13 [Simple] -> assets_game_rawassets_sprite_task_task_img_13.bundle |
| 33 | 2 | `ChapterTaskView/pnlContent/pnlTask` | Y | `pos(-835.0,0.0) size(1670.0,750.0)` | `1.0,0.5->1.0,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,CanvasGroup` | Image:none [Sliced], a=0.00 |
| 34 | 3 | `ChapterTaskView/pnlContent/pnlTask/Image` | Y | `pos(387.0,142.0) size(768.0,8.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:task_img_13 [Simple] -> assets_game_rawassets_sprite_task_task_img_13.bundle |
| 35 | 3 | `ChapterTaskView/pnlContent/pnlTask/svTaskList` | Y | `pos(387.0,-101.5) size(786.0,479.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,ScrollRect,CanvasRenderer,Image,Mask,GridScroller` | Image:none [Sliced] |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。
