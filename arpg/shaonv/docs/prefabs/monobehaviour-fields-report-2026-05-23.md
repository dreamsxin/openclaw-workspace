# Prefab MonoBehaviour 字段提取报告

Image.sprite / Text.text / Button.onClick 绑定数据

## MainUIView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\resources\assets\yoo\Default\550a7cadacd941b64b750257fc8891d0.bundle`
- Image: 90 (✅47 🔴18 ⚪25)
- Text: 61
- Button: 49
- 其他 MB: {"SkeletonSubmeshGraphic": 3, "UIShiny": 23, "UiParticles": 10, "GridLayoutGroup": 2, "Outline": 6, "NicerOutline": 43, "TextMeshProUGUI": 1, "LangLabel": 23, "LimitIconView": 15, "SkeletonGraphic": 3, "ResBar": 1, "HorizontalLayoutGroup": 3, "ContentSizeFitter": 4, "RectTransformLerp": 2, "GridScroller": 2, "UiPinchZoom": 1, "Rotator": 1, "ScrollRect": 2, "GraphicRaycaster": 1, "TopBar": 1, "ChatEntryPanel": 1, "RectMask2D": 1, "Mask": 1, "BackgroundMusic": 1, "MainUIView": 1, "RawImage": 1, "WallpaperPanel": 1, "AlternatePanel": 1, "InteractiveRole": 1, "LimitIconPanel": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| @btnChat | mainui_btn_04 | 6 | 3719458637926800483 | ✅ | Simple |
| btnActivity | mainui_btn_06 | 6 | 8993021672258401911 | ✅ | Simple |
| btnWelfare | mainui_btn_07 | 6 | 6152470334675078868 | ✅ | Simple |
| btnCharge | mainui_btn_08 | 6 | -5606386317076495039 | ✅ | Simple |
| btnShop | mainui_btn_09 | 6 | -6494552170004257140 | ✅ | Simple |
| btnCard | mainui_btn_10 | 6 | 6896097519155886632 | ✅ | Simple |
| btnMenu | mainui_btn_11 | 6 | 7939974300311425186 | ✅ | Simple |
| fxbtnMenu (1) | mainui_btn_11 | 6 | 7939974300311425186 | ✅ | Simple |
| btnEye | mainui_btn_12 | 6 | 2311679502751066023 | ✅ | Simple |
| btnChange | mainui_btn_13 | 6 | -66626497823637285 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| btnIcon | mainui_btn_14 | 6 | 3485004306131676500 | ✅ | Simple |
| Image | mainui_btn_25 | 6 | 1580482395419275427 | ✅ | Simple |
| pnlPlayerInfo | mainui_img_02 | 6 | 4396609056240251797 | ✅ | Simple |
| imgHeadBg | mainui_img_03 | 6 | 2790963330835763688 | ✅ | Filled |
| imgExp | mainui_img_04 | 6 | 1975043551427314484 | ✅ | Filled |
| @pnlAlternate | mainui_img_05 | 6 | 6770126371775491485 | ✅ | Simple |
| imgHookTime | mainui_img_08 | 6 | 2153397326245451295 | ✅ | Simple |
| Image | mainui_img_11 | 6 | 841309611147859695 | ✅ | Simple |
| Image | mainui_img_11 | 6 | 841309611147859695 | ✅ | Simple |
| Image | mainui_img_11 | 6 | 841309611147859695 | ✅ | Simple |
| Image | mainui_img_11 | 6 | 841309611147859695 | ✅ | Simple |
| Image | mainui_img_11 | 6 | 841309611147859695 | ✅ | Simple |
| btnHarvest | mainui_img_18 | 6 | 4685409181234200828 | ✅ | Simple |
| btnAssist | mainui_img_19 | 6 | -8286312790708527953 | ✅ | Simple |
| Image | mainui_img_32 | 6 | 2802551037928187732 | ✅ | Simple |
| Image | mainui_img_34 | 6 | -9003754687294378586 | ✅ | Simple |
| btnChapterInfo | mainui_img_35 | 6 | 6469282562519987748 | ✅ | Simple |
| btnJumpAutoFight | mainui_img_36 | 6 | -7852815129252393452 | ✅ | Simple |
| pnlStory | mainui_txt_01 | 6 | -2301656469657668396 | ✅ | Simple |
| btnAdventure | mainui_txt_02 | 6 | -2960129425230113647 | ✅ | Simple |
| btnArena | mainui_txt_03 | 6 | 5494097789311945855 | ✅ | Simple |
| btnDraw | mainui_txt_05 | 6 | -4476747461776438603 | ✅ | Simple |
| btnPrayer | mainui_txt_06 | 6 | -6082812322281840479 | ✅ | Simple |
| @BuryGift | — | 0 | 0 | ✅ | Simple |
| @DiscountLimitGift | — | 0 | 0 | ✅ | Simple |
| @LimitIconView01 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView02 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView03 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView04 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView05 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView06 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView07 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView08 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView09 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView10 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView11 | — | 0 | 0 | ✅ | Simple |
| @LimitIconView12 | — | 0 | 0 | ✅ | Simple |
| @Question | — | 0 | 0 | ✅ | Simple |
| @btnGalClickRrea | — | 0 | 0 | ✅ | Simple |
| Image | ❓ external:-6009537262924674716 | 11 | -6009537262924674716 | ✅ | Simple |
| Image | — | 0 | 0 | ✅ | Simple |
| Image | ❓ external:8828590025574504516 | 3 | 8828590025574504516 | ✅ | Simple |
| Viewport | ❓ external:-426171492875694260 | 0 | -426171492875694260 | ✅ | Sliced |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btnBagpack | — | 0 | 0 | ✅ | Simple |
| btnBodyMask | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btnClose | ❓ external:-4683822101859364422 | 8 | -4683822101859364422 | ❌ | Simple |
| btnDetail | ❓ external:2184835393858322729 | 8 | 2184835393858322729 | ❌ | Simple |
| btnDevelop | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btnGal | — | 0 | 0 | ✅ | Simple |
| btnHero | — | 0 | 0 | ✅ | Simple |
| btnLeft | ❓ external:-3652104890317513520 | 3 | -3652104890317513520 | ✅ | Simple |
| btnLegion | — | 0 | 0 | ✅ | Simple |
| btnPause | ❓ external:6743435939479724023 | 3 | 6743435939479724023 | ✅ | Simple |
| btnPet | — | 0 | 0 | ✅ | Simple |
| btnPlay | ❓ external:4019677898799196320 | 3 | 4019677898799196320 | ❌ | Simple |
| btnPlayerInfo | — | 0 | 0 | ✅ | Sliced |
| btnRight | ❓ external:-3652104890317513520 | 3 | -3652104890317513520 | ✅ | Simple |
| btnStory | — | 0 | 0 | ✅ | Sliced |
| btnTask | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| imgBackGround | — | 0 | 0 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 12 | -3438178970352523766 | ✅ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 13 | -6864174782452307236 | ❌ | Simple |
| pnlBottom | ❓ external:3421664766724650376 | 9 | 3421664766724650376 | ✅ | Sliced |
| pnlCommercialization | ❓ external:1660267235368898380 | 0 | 1660267235368898380 | ✅ | Sliced |
| svRes | ❓ external:1660267235368898380 | 0 | 1660267235368898380 | ✅ | Sliced |

### Text 字段

| GameObject | Text Content | FontSize | Alignment |
|-----------|-------------|----------|-----------|
| txtTime |  | 18 | 4 |
| txtName |  | 20 | 4 |
| txtName |  | 20 | 4 |
| txtName |  | 20 | 4 |
| Text | 养成 | 24 | 4 |
| Text | 现世 | 24 | 4 |
| txtName | 玩家姓名七个字 | 20 | 3 |
| txtName |  | 20 | 4 |
| txtTime |  | 18 | 4 |
| txtHookTime | 12:08:08 | 18 | 4 |
| txtName |  | 20 | 4 |
| Text | 充值 | 20 | 4 |
| Text | 宠物 | 24 | 4 |
| txtName |  | 20 | 4 |
| txtTime |  | 18 | 4 |
| Text | 背包 | 24 | 4 |
| txtPower | 99999999 | 26 | 3 |
| txtStory | 进度：<Color=#FFED9B>88-88</Color> | 20 | 4 |
| Text | 月卡 | 20 | 4 |
| Text | 小助手 | 20 | 4 |
| txtName | 埋点礼包 | 20 | 4 |
| Text | 活动 | 20 | 4 |
| txtTime |  | 18 | 4 |
| txtName |  | 20 | 4 |
| txtTime |  | 18 | 4 |
| txtTime |  | 18 | 4 |
| Text | Default | 18 | 4 |
| Text | Default | 18 | 4 |
| txtTime |  | 18 | 4 |
| txtLevel | 999 | 34 | 4 |
| txtTime | 可领取 | 18 | 4 |
| Text | LEVEL | 8 | 4 |
| txtTime |  | 18 | 4 |
| txtName |  | 20 | 4 |
| Text | Default | 22 | 4 |
| txtName |  | 20 | 4 |
| txtTime |  | 18 | 4 |
| txtChapterTitle | 第1章砸瓦鲁多 1/30 | 22 | 3 |
| txtName | 问卷 | 20 | 4 |
| txtAssistProject | 历战尖塔-单队 | 20 | 4 |
| Text | 养成 | 24 | 4 |
| Text | 公会 | 24 | 4 |
| Text | 商店 | 20 | 4 |
| Text | 幻灵 | 24 | 4 |
| Text | 返回 | 22 | 4 |
| txtName | 显示折扣礼包 | 20 | 4 |
| txtName |  | 20 | 4 |
| txtTime |  | 18 | 4 |
| txtTime |  | 18 | 4 |
| Text | 福利 | 20 | 4 |
| txtTime |  | 18 | 4 |
| Text | Default | 22 | 4 |
| txtTime |  | 18 | 4 |
| txtName |  | 20 | 4 |
| txtTime |  | 18 | 4 |
| txtAssist | <i>自动挑战中...</i> | 22 | 4 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| Text | Default | 22 | 4 |
| Text | 尘世探秘11 | 32 | 4 |
| txtName |  | 20 | 4 |
| Text | Default | 22 | 4 |

### Button.onClick 回调

| GameObject | Target | Method |
|-----------|--------|--------|
| btnCard | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnMenu | *(empty)* | — |
| btnPause | *(empty)* | — |
| btnIcon | *(empty)* | — |
| @btnChat | *(empty)* | — |
| btnLegion | *(empty)* | — |
| btnTask | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnJumpAutoFight | *(empty)* | — |
| btnGal | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnActivity | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnEye | *(empty)* | — |
| btnPrayer | *(empty)* | — |
| btnDetail | *(empty)* | — |
| btnDevelop | *(empty)* | — |
| btnShop | *(empty)* | — |
| btnBodyMask | *(empty)* | — |
| btnDraw | *(empty)* | — |
| btnChange | *(empty)* | — |
| btnPlay | *(empty)* | — |
| btnAssist | *(empty)* | — |
| btn | *(empty)* | — |
| btnPet | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnWelfare | *(empty)* | — |
| btnPlayerInfo | *(empty)* | — |
| btnLeft | *(empty)* | — |
| btnClose | *(empty)* | — |
| btnBagpack | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnArena | *(empty)* | — |
| btnAdventure | *(empty)* | — |
| btnHero | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnCharge | *(empty)* | — |
| btnStory | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnRight | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnIcon | *(empty)* | — |
| btnChapterInfo | *(empty)* | — |
| btnHarvest | *(empty)* | — |
| btnIcon | *(empty)* | — |

## LotteryDrawMainView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawMainView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\resources\assets\yoo\Default\1918525995d5a5ed05fce5506c55ca0d.bundle`
- Image: 138 (✅15 🔴91 ⚪32)
- Text: 48
- Button: 33
- 其他 MB: {"LangLabel": 18, "SkeletonGraphic": 19, "GraphicRaycaster": 6, "CommonIconTabGrid": 5, "SkeletonSubmeshGraphic": 23, "LotteryDrawPanel": 1, "ContentSizeFitter": 6, "UIImageRotator": 7, "Mask": 1, "InteractiveRole": 6, "ScrollRect": 1, "UiPinchZoom": 6, "UIShiny": 7, "HorizontalLayoutGroup": 2, "NicerOutline": 8, "UIImageScaler": 7, "Shadow": 3, "Outline": 3, "Toggle": 1, "FixedTabScrollView": 1, "LotteryDrawMainView": 1, "BackgroundMusic": 1, "RectMask2D": 1, "UIImageMover": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| Background | common_btn_09 | 6 | -3502581629231052866 | ✅ | Simple |
| Checkmark | common_btn_10 | 6 | 5572699248995261620 | ✅ | Simple |
| btnJump | common_btn_24 | 6 | 3488856880393979331 | ✅ | Simple |
| btnOne | common_btn_46 | 6 | -4850742817454507536 | ✅ | Simple |
| btnTen | common_btn_47 | 6 | -3237526478772283882 | ✅ | Simple |
| imgEpicColor | common_img_64 | 6 | -1608669623929483704 | ✅ | Simple |
| imgColor | common_img_66 | 6 | -8850499571484738526 | ✅ | Simple |
| imgColor | common_img_67 | 6 | 5528284856141885846 | ✅ | Simple |
| @pnlHero | common_img_71 | 6 | -7024279675554190832 | ✅ | Simple |
| @pnlHero1 | common_img_71 | 6 | -7024279675554190832 | ✅ | Simple |
| @pnlHero2 | common_img_71 | 6 | -7024279675554190832 | ✅ | Simple |
| imgAdd | common_img_72 | 6 | -7101735860607543896 | ✅ | Simple |
| imgAdd | common_img_72 | 6 | -7101735860607543896 | ✅ | Simple |
| imgAdd | common_img_72 | 6 | -7101735860607543896 | ✅ | Simple |
| imgShowInfoRare | common_img_80 | 6 | -8506298652032363976 | ✅ | Simple |
| @Image_cloud | ❓ external:-6167712979569151819 | 10 | -6167712979569151819 | ✅ | Simple |
| @Image_cloud | ❓ external:-6167712979569151819 | 10 | -6167712979569151819 | ✅ | Simple |
| @Image_cloud | ❓ external:-6167712979569151819 | 10 | -6167712979569151819 | ✅ | Simple |
| @Image_line_l | ❓ external:3313484144776772945 | 11 | 3313484144776772945 | ✅ | Filled |
| @Image_line_r | ❓ external:3313484144776772945 | 11 | 3313484144776772945 | ✅ | Filled |
| @fx_imgBg_star | — | 0 | 0 | ❌ | Simple |
| @fx_imgBg_star | — | 0 | 0 | ❌ | Simple |
| @fx_imgBg_star | — | 0 | 0 | ❌ | Simple |
| @imgBg | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ✅ | Simple |
| @imgBg | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ✅ | Simple |
| @imgHightLight | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| @imgHightLight | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| @imgHightLight | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ❌ | Simple |
| @imgHightLight | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| @imgHightLight | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| Image | — | 0 | 0 | ✅ | Simple |
| Image | ❓ external:-1597350391430084997 | 5 | -1597350391430084997 | ✅ | Simple |
| Image | — | 0 | 0 | ❌ | Simple |
| Image | ❓ external:-1597350391430084997 | 5 | -1597350391430084997 | ✅ | Simple |
| Image | ❓ external:4036757014874084065 | 5 | 4036757014874084065 | ✅ | Simple |
| Image | ❓ external:-2551413631015923876 | 5 | -2551413631015923876 | ✅ | Simple |
| Image | — | 0 | 0 | ✅ | Simple |
| Image | — | 0 | 0 | ❌ | Simple |
| Image | — | 0 | 0 | ❌ | Simple |
| Image | — | 0 | 0 | ✅ | Simple |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btnActivity | — | 0 | 0 | ✅ | Sliced |
| btnChooseHero | — | 0 | 0 | ❌ | Simple |
| btnClick | — | 0 | 0 | ✅ | Simple |
| btnClick | — | 0 | 0 | ✅ | Simple |
| btnClick | — | 0 | 0 | ✅ | Simple |
| btnClick | — | 0 | 0 | ✅ | Simple |
| btnClick | — | 0 | 0 | ✅ | Simple |
| btnCrystalShop | ❓ external:5389286458198875501 | 5 | 5389286458198875501 | ✅ | Simple |
| btnEpicFinish | ❓ external:-2235840948123996511 | 5 | -2235840948123996511 | ✅ | Simple |
| btnEpicWish | — | 0 | 0 | ✅ | Simple |
| btnExChange | — | 0 | 0 | ❌ | Simple |
| btnFinish | ❓ external:-2235840948123996511 | 5 | -2235840948123996511 | ✅ | Simple |
| btnFinish | ❓ external:-2235840948123996511 | 5 | -2235840948123996511 | ✅ | Simple |
| btnIntegral | ❓ external:569777434831468555 | 5 | 569777434831468555 | ✅ | Simple |
| btnMarch | ❓ external:-7769888520061757820 | 5 | -7769888520061757820 | ✅ | Simple |
| btnProbability | ❓ external:-4035612386460074897 | 5 | -4035612386460074897 | ✅ | Simple |
| btnReward | — | 0 | 0 | ❌ | Simple |
| btnShop | — | 0 | 0 | ❌ | Simple |
| btnShop1 | ❓ external:5389286458198875501 | 5 | 5389286458198875501 | ✅ | Simple |
| btnShop2 | ❓ external:-2656360665009272923 | 5 | -2656360665009272923 | ✅ | Simple |
| btnSkipAnim | — | 0 | 0 | ✅ | Sliced |
| btnUp | ❓ external:569777434831468555 | 5 | 569777434831468555 | ✅ | Simple |
| btnWish | — | 0 | 0 | ✅ | Simple |
| btnWish | — | 0 | 0 | ✅ | Simple |
| imgBg | ❓ external:-2900045040753842573 | 5 | -2900045040753842573 | ✅ | Simple |
| imgBg | ❓ external:-2900045040753842573 | 5 | -2900045040753842573 | ✅ | Simple |
| imgBg | ❓ external:-2900045040753842573 | 5 | -2900045040753842573 | ✅ | Simple |
| imgBg | ❓ external:-2900045040753842573 | 5 | -2900045040753842573 | ✅ | Simple |
| imgBg | ❓ external:-2900045040753842573 | 5 | -2900045040753842573 | ✅ | Simple |
| imgBg_mask | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ✅ | Simple |
| imgBg_mask | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ✅ | Simple |
| imgBg_mask2 | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ✅ | Simple |
| imgEpicBg | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ❌ | Simple |
| imgEpicCharacter | ❓ external:-6932162167396372591 | 14 | -6932162167396372591 | ✅ | Simple |
| imgEpicWishHero | ❓ external:-3591043534988315747 | 1 | -3591043534988315747 | ✅ | Simple |
| imgHeroSpineBg | — | 0 | 0 | ❌ | Simple |
| imgIntegralSlider | ❓ external:-5545066425052016706 | 5 | -5545066425052016706 | ✅ | Filled |
| imgLock | ❓ external:-218697301225825353 | 5 | -218697301225825353 | ✅ | Simple |
| imgLotterySource | — | 0 | 0 | ❌ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 1 | -3438178970352523766 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 1 | -3438178970352523766 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 1 | -3438178970352523766 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 1 | -3438178970352523766 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 1 | -3438178970352523766 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 1 | -3438178970352523766 | ✅ | Simple |
| imgMiddleBg | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ❌ | Simple |
| imgNormalBg | ❓ external:-6653295894294581443 | 12 | -6653295894294581443 | ✅ | Simple |
| imgOneCost | ❓ external:788262251366900655 | 5 | 788262251366900655 | ✅ | Simple |
| imgRemainTip | — | 0 | 0 | ✅ | Simple |
| imgShopRedTip | — | 0 | 0 | ❌ | Simple |
| imgShopRedTip2 | — | 0 | 0 | ❌ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 7 | -6864174782452307236 | ❌ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 7 | -6864174782452307236 | ❌ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 7 | -6864174782452307236 | ❌ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 7 | -6864174782452307236 | ❌ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 7 | -6864174782452307236 | ❌ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 7 | -6864174782452307236 | ❌ | Simple |
| imgTenCost | ❓ external:788262251366900655 | 5 | 788262251366900655 | ✅ | Simple |
| imgTip | — | 0 | 0 | ✅ | Simple |
| imgWishHero | ❓ external:-3591043534988315747 | 1 | -3591043534988315747 | ❌ | Simple |
| imgWishHero | ❓ external:-3591043534988315747 | 1 | -3591043534988315747 | ❌ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03_effect | ❓ external:3327515815891958839 | 5 | 3327515815891958839 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| lottery_btn_03a_effect | ❓ external:-5340275345408209172 | 5 | -5340275345408209172 | ✅ | Simple |
| pnlBg | — | 0 | 0 | ✅ | Simple |
| pnlEpic | ❓ external:1660267235368898380 | 0 | 1660267235368898380 | ✅ | Sliced |
| pnlEpicWish | ❓ external:2709020919140766213 | 5 | 2709020919140766213 | ✅ | Simple |
| pnlNormalWish | ❓ external:-218697301225825353 | 5 | -218697301225825353 | ✅ | Simple |
| pnlRate | — | 0 | 0 | ❌ | Filled |
| pnlTag1 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| pnlTag2 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| pnlTag3 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| pnlTag4 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| tabView | — | 0 | 0 | ✅ | Sliced |

### Text 字段

| GameObject | Text Content | FontSize | Alignment |
|-----------|-------------|----------|-----------|
| Text | 心愿单： | 18 | 4 |
| Text | 商城礼包 | 20 | 4 |
| Text | 积分抽奖 | 14 | 4 |
| Text (1) | 投影券获得 | 18 | 3 |
| txtAcTime | 11月14日-11月21日结束 | 25 | 3 |
| txtMainDrawType | 普通回响 | 60 | 5 |
| txtFreeTimeTip |  | 26 | 3 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| txtOneCost | x300 | 24 | 3 |
| txtTag3 | sdfsdf | 16 | 4 |
| txtRemainTip1 | 必定获得<color=#FFDB5F>SSR</color>幻灵 | 22 | 5 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| txtIntegralSlider | 9999 | 12 | 4 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| Text | 奖励预览 | 14 | 4 |
| txtOne | 回响1次 | 26 | 4 |
| txtFreeTimeNum | 今日剩余免费次数 ：1/1 | 20 | 4 |
| txtTenCost | x2700 | 24 | 3 |
| txtName | 高级回响 | 18 | 3 |
| Text | 跳过动画 | 18 | 3 |
| Text | 回响10次 | 26 | 4 |
| Text | 结晶商城 | 14 | 4 |
| txtFreeTime |  | 26 | 5 |
| txtShowInfoName | 狄俄捏 | 22 | 3 |
| Text | 心愿单： | 18 | 4 |
| txtName | 高级回响 | 18 | 3 |
| txtName | 高级回响 | 18 | 3 |
| txtTag4 | sdfsdf | 16 | 4 |
| Text | 抽后解锁心愿单 | 18 | 3 |
| txtLock | 200 | 18 | 5 |
| txtName | 高级回响 | 18 | 3 |
| txtName | 高级回响 | 18 | 3 |
| txtRateNum | 60% | 50 | 4 |
| Text | 回响礼包 | 14 | 4 |
| txtTag1 | sdfsdf | 16 | 4 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| txtRateTip | SS概率 | 22 | 4 |
| Text | 概率公示 | 14 | 4 |
| txtRemainTip2 | 今日剩余免费次数 ：1/1 | 20 | 4 |
| Text | 投影10次 | 28 | 4 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| txtTag2 | sdfsdf | 16 | 4 |
| Text | 阵容推荐 | 14 | 4 |
| txtRemainTip | 继续唤灵<color=#FFDB5F>40</color>次 | 22 | 5 |
| txtSecondDrawType | 新手自选回响 | 18 | 5 |
| Text | 礼包商城 | 14 | 4 |
| Text | 投影战令 | 17 | 4 |

### Button.onClick 回调

| GameObject | Target | Method |
|-----------|--------|--------|
| btnUp | *(empty)* | — |
| btnShop2 | *(empty)* | — |
| btnClick | *(empty)* | — |
| btnClick | *(empty)* | — |
| btn | *(empty)* | — |
| btnIntegral | *(empty)* | — |
| btnChooseHero | *(empty)* | — |
| btnActivity | *(empty)* | — |
| btnSkipAnim | *(empty)* | — |
| btnClick | *(empty)* | — |
| btnReward | *(empty)* | — |
| btnClick | *(empty)* | — |
| btn | *(empty)* | — |
| btn | *(empty)* | — |
| btnShop1 | *(empty)* | — |
| btn | *(empty)* | — |
| btnJump | *(empty)* | — |
| btnShop | *(empty)* | — |
| btnOne | *(empty)* | — |
| btnProbability | *(empty)* | — |
| btnEpicWish | *(empty)* | — |
| btnClick | *(empty)* | — |
| btnFinish | *(empty)* | — |
| btnWish | *(empty)* | — |
| btn | *(empty)* | — |
| btnCrystalShop | *(empty)* | — |
| btnWish | *(empty)* | — |
| btnFinish | *(empty)* | — |
| btnMarch | *(empty)* | — |
| btn | *(empty)* | — |
| btnTen | *(empty)* | — |
| btnExChange | *(empty)* | — |
| btnEpicFinish | *(empty)* | — |

## LotteryDrawFinishView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/LotteryDrawFinishView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default\UnpackBundleFiles\86\86c05702d8a8a6410d5a48ddc7449de4\__data`
- Image: 13 (✅0 🔴12 ⚪1)
- Text: 0
- Button: 0
- 其他 MB: {"UiParticles": 190, "LotteryDrawFinishView": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| imgBg | ❓ external:-4233867625238272382 | 4 | -4233867625238272382 | ✅ | Simple |
| light01_colormask | ❓ external:-5552753283811714492 | 3 | -5552753283811714492 | ❌ | Simple |
| light01_mask | ❓ external:-4802445779277610747 | 3 | -4802445779277610747 | ✅ | Simple |
| light02_colormask | ❓ external:7038411349513095343 | 3 | 7038411349513095343 | ❌ | Simple |
| light03_colormask | ❓ external:-4914177483640181437 | 3 | -4914177483640181437 | ❌ | Simple |
| light04_colormask | — | 0 | 0 | ❌ | Simple |
| light04_mask | ❓ external:8088379268696657538 | 3 | 8088379268696657538 | ✅ | Simple |
| light05_mask | ❓ external:-5131834437514227985 | 3 | -5131834437514227985 | ✅ | Simple |
| light06_mask | ❓ external:-9087237373623916597 | 3 | -9087237373623916597 | ✅ | Simple |
| light07_mask | ❓ external:745068100067841517 | 3 | 745068100067841517 | ✅ | Simple |
| light08_mask | ❓ external:-4375803870052935860 | 3 | -4375803870052935860 | ✅ | Simple |
| light09_mask | ❓ external:-5758822076297523568 | 3 | -5758822076297523568 | ✅ | Simple |
| light10_mask | ❓ external:8257951870831616950 | 3 | 8257951870831616950 | ✅ | Simple |

## HeroRecruitView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/LotteryDraw/HeroRecruitView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default\BundleFiles\7f\7f985e1dae908dae92d5f38cbc8a5b82\__data`
- Image: 109 (✅1 🔴105 ⚪3)
- Text: 7
- Button: 2
- 其他 MB: {"UIShiny": 10, "FacingCamera": 30, "SkeletonGraphic": 6, "UIImageRotator": 50, "UIImageMover": 5, "InteractiveRole": 1, "UiParticles": 12, "RawImage": 1, "SkeletonSubmeshGraphic": 3, "BackgroundMusic": 1, "UiPinchZoom": 1, "SpineMaterialSelector": 1, "GraphicRaycaster": 1, "HeroRecruitView": 1, "CDButton": 1, "ContentSizeFitter": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| imgQuality | common_img_165 | 17 | 8669400321183480780 | ✅ | Simple |
| @ImgFrame_blue | ❓ external:1925334468300839857 | 7 | 1925334468300839857 | ❌ | Simple |
| @ImgFrame_purple | ❓ external:-5509646378765024138 | 11 | -5509646378765024138 | ❌ | Simple |
| @ImgFrame_red | ❓ external:-4773586797989036858 | 13 | -4773586797989036858 | ❌ | Simple |
| @ImgFrame_yellow | ❓ external:5760813790217519314 | 9 | 5760813790217519314 | ❌ | Simple |
| @imgBg_blue | ❓ external:-4767352877613415696 | 14 | -4767352877613415696 | ❌ | Simple |
| @imgBg_purple | ❓ external:-2129247368766607594 | 14 | -2129247368766607594 | ❌ | Simple |
| @imgBg_red | ❓ external:1329417041124735688 | 14 | 1329417041124735688 | ❌ | Simple |
| @imgBg_yellow | ❓ external:-2000470450753402836 | 14 | -2000470450753402836 | ❌ | Simple |
| ImgFrame_blue | ❓ external:1925334468300839857 | 7 | 1925334468300839857 | ✅ | Simple |
| ImgFrame_blue_l | ❓ external:-2523178638703296616 | 8 | -2523178638703296616 | ❌ | Simple |
| ImgFrame_blue_r | ❓ external:-5046529114605351207 | 10 | -5046529114605351207 | ❌ | Simple |
| ImgFrame_purple | ❓ external:-5509646378765024138 | 11 | -5509646378765024138 | ✅ | Simple |
| ImgFrame_purple_l | ❓ external:-2523178638703296616 | 8 | -2523178638703296616 | ❌ | Simple |
| ImgFrame_purple_r | ❓ external:-5046529114605351207 | 10 | -5046529114605351207 | ❌ | Simple |
| ImgFrame_red | ❓ external:-4773586797989036858 | 13 | -4773586797989036858 | ✅ | Simple |
| ImgFrame_red_l | ❓ external:-2523178638703296616 | 8 | -2523178638703296616 | ❌ | Simple |
| ImgFrame_red_r | ❓ external:-5046529114605351207 | 10 | -5046529114605351207 | ❌ | Simple |
| ImgFrame_yellow | ❓ external:5760813790217519314 | 9 | 5760813790217519314 | ✅ | Simple |
| ImgFrame_yellow_l | ❓ external:-2523178638703296616 | 8 | -2523178638703296616 | ❌ | Simple |
| ImgFrame_yellow_r | ❓ external:-5046529114605351207 | 10 | -5046529114605351207 | ❌ | Simple |
| btn | ❓ external:5837791642106728268 | 0 | 5837791642106728268 | ✅ | Sliced |
| btnClose | — | 0 | 0 | ✅ | Sliced |
| btnSkipVideo | ❓ external:-4403074470763856018 | 19 | -4403074470763856018 | ❌ | Simple |
| imgBg | — | 0 | 0 | ✅ | Simple |
| imgMask | ❓ external:-3438178970352523766 | 18 | -3438178970352523766 | ✅ | Simple |
| imgNew | ❓ external:1051623842213454126 | 5 | 1051623842213454126 | ✅ | Simple |
| imgOccupation | — | 0 | 0 | ✅ | Simple |
| imgSpeak | ❓ external:-6864174782452307236 | 12 | -6864174782452307236 | ❌ | Simple |
| lottery_img_33a | ❓ external:-1888497358176401736 | 5 | -1888497358176401736 | ✅ | Simple |
| lottery_img_33a_effect | ❓ external:-1888497358176401736 | 5 | -1888497358176401736 | ✅ | Simple |
| lottery_img_33b | ❓ external:-1548126502286454278 | 5 | -1548126502286454278 | ✅ | Simple |
| lottery_img_33b_effect | ❓ external:-1548126502286454278 | 5 | -1548126502286454278 | ✅ | Simple |
| lottery_img_33c | ❓ external:7468542121466779856 | 5 | 7468542121466779856 | ✅ | Simple |
| lottery_img_34a | ❓ external:969356671336342686 | 5 | 969356671336342686 | ✅ | Simple |
| lottery_img_34a_effect | ❓ external:969356671336342686 | 5 | 969356671336342686 | ✅ | Simple |
| lottery_img_34b | ❓ external:-2011699648156969468 | 5 | -2011699648156969468 | ✅ | Simple |
| lottery_img_34b_effect | ❓ external:-2011699648156969468 | 5 | -2011699648156969468 | ✅ | Simple |
| lottery_img_34c | ❓ external:-670900402579214912 | 5 | -670900402579214912 | ✅ | Simple |
| lottery_img_34d | ❓ external:1556105836523823528 | 5 | 1556105836523823528 | ✅ | Simple |
| lottery_img_34d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_34d | ❓ external:1556105836523823528 | 5 | 1556105836523823528 | ✅ | Simple |
| lottery_img_34d | ❓ external:1556105836523823528 | 5 | 1556105836523823528 | ✅ | Simple |
| lottery_img_34d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_34d | ❓ external:1556105836523823528 | 5 | 1556105836523823528 | ✅ | Simple |
| lottery_img_34d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_34d | ❓ external:1556105836523823528 | 5 | 1556105836523823528 | ✅ | Simple |
| lottery_img_34d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_34d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_34d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_34d | ❓ external:1556105836523823528 | 5 | 1556105836523823528 | ✅ | Simple |
| lottery_img_35a | ❓ external:8144409868299953294 | 5 | 8144409868299953294 | ✅ | Simple |
| lottery_img_35a_effect | ❓ external:8144409868299953294 | 5 | 8144409868299953294 | ✅ | Simple |
| lottery_img_35b | ❓ external:-43584943063940790 | 5 | -43584943063940790 | ✅ | Simple |
| lottery_img_35b_effect | ❓ external:-43584943063940790 | 5 | -43584943063940790 | ✅ | Simple |
| lottery_img_35c | ❓ external:1823408057670073488 | 5 | 1823408057670073488 | ✅ | Simple |
| lottery_img_35d | ❓ external:-8865123971975103850 | 5 | -8865123971975103850 | ✅ | Simple |
| lottery_img_35d | ❓ external:-8865123971975103850 | 5 | -8865123971975103850 | ✅ | Simple |
| lottery_img_35d | ❓ external:-8865123971975103850 | 5 | -8865123971975103850 | ✅ | Simple |
| lottery_img_35d | ❓ external:-8865123971975103850 | 5 | -8865123971975103850 | ✅ | Simple |
| lottery_img_35d | ❓ external:-8865123971975103850 | 5 | -8865123971975103850 | ✅ | Simple |
| lottery_img_35d | ❓ external:-8865123971975103850 | 5 | -8865123971975103850 | ✅ | Simple |
| lottery_img_36a | ❓ external:5184210422127566296 | 5 | 5184210422127566296 | ✅ | Simple |
| lottery_img_36a_effect | ❓ external:5184210422127566296 | 5 | 5184210422127566296 | ✅ | Simple |
| lottery_img_36b | ❓ external:-8546814579341347013 | 5 | -8546814579341347013 | ✅ | Simple |
| lottery_img_36b_effect | ❓ external:-8546814579341347013 | 5 | -8546814579341347013 | ✅ | Simple |
| lottery_img_36c | ❓ external:8951879108016033774 | 5 | 8951879108016033774 | ✅ | Simple |
| lottery_img_36d | ❓ external:1137080542612877092 | 5 | 1137080542612877092 | ✅ | Simple |
| lottery_img_36d | ❓ external:1137080542612877092 | 5 | 1137080542612877092 | ✅ | Simple |
| lottery_img_36d | ❓ external:1137080542612877092 | 5 | 1137080542612877092 | ✅ | Simple |
| lottery_img_36d | ❓ external:1137080542612877092 | 5 | 1137080542612877092 | ✅ | Simple |
| lottery_img_36d | ❓ external:1137080542612877092 | 5 | 1137080542612877092 | ✅ | Simple |
| lottery_img_36d | ❓ external:1137080542612877092 | 5 | 1137080542612877092 | ✅ | Simple |
| lottery_img_37a | ❓ external:5824275418857166755 | 5 | 5824275418857166755 | ✅ | Simple |
| lottery_img_37a_effect | ❓ external:5824275418857166755 | 5 | 5824275418857166755 | ✅ | Simple |
| lottery_img_37b | ❓ external:8884092793599753622 | 5 | 8884092793599753622 | ✅ | Simple |
| lottery_img_37b_effect | ❓ external:8884092793599753622 | 5 | 8884092793599753622 | ✅ | Simple |
| lottery_img_37c | ❓ external:3875252587836837536 | 5 | 3875252587836837536 | ✅ | Simple |
| lottery_img_37d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_37d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_37d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_37d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_37d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| lottery_img_37d | ❓ external:5121032711657229990 | 5 | 5121032711657229990 | ✅ | Simple |
| pnlInfo | ❓ external:-8865498167813786430 | 5 | -8865498167813786430 | ✅ | Simple |
| pnlTag1 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| pnlTag2 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| pnlTag3 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| pnlTag4 | ❓ external:1767084436358875671 | 5 | 1767084436358875671 | ✅ | Simple |
| ring_down | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_down | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_down | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_down | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_down | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_left | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_left | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_left | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_left | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_left | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_right | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_right | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_right | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_right | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_right | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_top | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_top | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_top | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_top | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |
| ring_top | ❓ external:2520918171841528110 | 5 | 2520918171841528110 | ✅ | Simple |

### Text 字段

| GameObject | Text Content | FontSize | Alignment |
|-----------|-------------|----------|-----------|
| @txtTag2 | aaaaaaa | 16 | 4 |
| @txtTag3 | aaaaaaa | 16 | 4 |
| Text | 跳过 | 20 | 4 |
| Text | 交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。 | 18 | 3 |
| @txtTag1 | aaaaaaa | 16 | 4 |
| @txtTag4 | aaaaaaa | 16 | 4 |
| txtName | 亚尔薇特 | 26 | 3 |

### Button.onClick 回调

| GameObject | Target | Method |
|-----------|--------|--------|
| btn | *(empty)* | — |
| btnClose | *(empty)* | — |

## LoginView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/Login/LoginView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\resources\assets\yoo\Default\7996b01a22fa6b87d3cf865ec438316b.bundle`
- Image: 16 (✅10 🔴4 ⚪2)
- Text: 15
- Button: 7
- 其他 MB: {"InputField": 1, "LangLabel": 13, "LoginView": 1, "Shadow": 4, "Toggle": 1, "HyperlinkText": 2, "UIShiny": 1, "VerticalLayoutGroup": 2, "RawImage": 1, "UILongTouch": 1, "BackgroundMusic": 1, "ContentSizeFitter": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| btnNotice | login_btn_01 | 1 | -4328938831171630855 | ✅ | Simple |
| btnRepair | login_btn_02 | 1 | 1836269955959486094 | ✅ | Simple |
| btnSwitchAccount | login_btn_05 | 1 | -2116414737881277758 | ✅ | Simple |
| btnSelect | login_btn_06 | 1 | -7156324457455228603 | ✅ | Simple |
| btnServerSel | login_img_01 | 1 | 4119201380006923501 | ❌ | Simple |
| imgServer | login_img_02 | 1 | 611098680668325209 | ✅ | Simple |
| inputAccount | login_img_03 | 1 | -840543035227367536 | ✅ | Simple |
| Image | login_img_04 | 1 | 3830757097710854422 | ✅ | Simple |
| imgLogo | login_txt_02 | 1 | 3231618429689738491 | ✅ | Simple |
| btnAge | login_txt_03 | 1 | 8887836707377167970 | ✅ | Simple |
| Background | ❓ external:-3502581629231052866 | 4 | -3502581629231052866 | ✅ | Simple |
| Checkmark | ❓ external:5572699248995261620 | 4 | 5572699248995261620 | ✅ | Simple |
| btnLogin | — | 0 | 0 | ✅ | Simple |
| imgBg | ❓ external:3134200618008424981 | 5 | 3134200618008424981 | ✅ | Simple |
| imgTipLogin | ❓ external:5479287719857653922 | 3 | 5479287719857653922 | ✅ | Simple |
| pnl | — | 0 | 0 | ✅ | Sliced |

### Text 字段

| GameObject | Text Content | FontSize | Alignment |
|-----------|-------------|----------|-----------|
| Text | 账号 | 22 | 4 |
| txtApp | 1.0.0 | 20 | 5 |
| Text |  | 25 | 3 |
| txtVer | 1.0.0 | 20 | 5 |
| Text | 公告 | 22 | 4 |
| txtRes | 999 | 20 | 5 |
| txtServerName | 东胜神洲 | 20 | 4 |
| txtCopyright | 审批文号：国新出审[2024]866号 ISBN 978-7-498-13464-6  出版单位：杭州润趣科技有限公司  | 16 | 4 |
| txtCopyleft | 运营单位：杭州游聚信息技术有限公司  著作权登记号：2025SR1094284 | 16 | 4 |
| Placeholder | 输入账号... | 22 | 3 |
| Text | 选服 | 22 | 4 |
| Text | 修复 | 22 | 4 |
| txtGameTip | 抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。 | 16 | 4 |
| txtServer | 服务器 | 26 | 4 |
| txtAccount | 账号 | 22 | 3 |

### Button.onClick 回调

| GameObject | Target | Method |
|-----------|--------|--------|
| btnNotice | *(empty)* | — |
| btnAge | *(empty)* | — |
| btnSwitchAccount | *(empty)* | — |
| btnRepair | *(empty)* | — |
| btnLogin | *(empty)* | — |
| btnServerSel | *(empty)* | — |
| btnSelect | *(empty)* | — |

## LaunchView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/Launch/LaunchView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default\BundleFiles\02\02f333e981e168e801ed39cad54a6f17\__data`
- Image: 1 (✅0 🔴0 ⚪1)
- Text: 0
- Button: 0
- 其他 MB: {"RawImage": 1, "LaunchView": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| Image | — | 0 | 0 | ✅ | Simple |

## LoadingView

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/Login/LoadingView.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default\UnpackBundleFiles\3e\3eda611616b92cfdb2af7f8c183b1e50\__data`
- Image: 4 (✅0 🔴4 ⚪0)
- Text: 1
- Button: 0
- 其他 MB: {"Slider": 1, "LoadingView": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| Background | ❓ external:-8597032072316169813 | 2 | -8597032072316169813 | ✅ | Sliced |
| Fill | ❓ external:-6622355985077409240 | 1 | -6622355985077409240 | ✅ | Sliced |
| Handle | ❓ external:-492698782526076828 | 3 | -492698782526076828 | ✅ | Simple |
| imgBg | ❓ external:1392122626399674207 | 5 | 1392122626399674207 | ✅ | Simple |

### Text 字段

| GameObject | Text Content | FontSize | Alignment |
|-----------|-------------|----------|-----------|
| txtPercent | 0% | 26 | 3 |

## TopResGrid

- 预制体: `Assets/Game/RawAssets/Prefabs/UI/Common/TopResGrid.prefab`
- 源 Bundle: `D:\work\openclaw-workspace\arpg\shaonv\files\yoo\Default\UnpackBundleFiles\b2\b23b6d9847109cf0f7aa85ad748645e6\__data`
- Image: 3 (✅2 🔴1 ⚪0)
- Text: 2
- Button: 1
- 其他 MB: {"TopResGrid": 1}

### Image → Sprite 绑定

| GameObject | Sprite Name | FileID | PathID | Active | Type |
|-----------|------------|--------|--------|--------|------|
| btnClick | common_btn_13 | 1 | 4579297552677319727 | ❌ | Simple |
| imgBg | common_img_25 | 1 | 2534816661587114454 | ✅ | Simple |
| imgIcon | ❓ external:-4841979435658239268 | 2 | -4841979435658239268 | ✅ | Simple |

### Text 字段

| GameObject | Text Content | FontSize | Alignment |
|-----------|-------------|----------|-----------|
| txtNum | 99/99 | 22 | 5 |
| txtTitle | 挑战次数: | 22 | 3 |

### Button.onClick 回调

| GameObject | Target | Method |
|-----------|--------|--------|
| btnClick | *(empty)* | — |
