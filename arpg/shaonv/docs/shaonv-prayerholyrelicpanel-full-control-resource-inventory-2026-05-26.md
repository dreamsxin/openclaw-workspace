# PrayerHolyRelicPanel 全控件与资源清单

生成时间：2026-05-24。

本文档由 `scripts/assets/export_prefab_full_inventory.py` 生成，用于验证全量清单导出路线能复用于 `PrayerHolyRelicPanel`。

## 输入与结论

- Prefab: `Assets/Game/RawAssets/Prefabs/UI/Prayer/PrayerHolyRelicPanel.prefab`
- Prefab bundle: `assets_game_rawassets_prefabs_ui_prayer_prayerholyrelicpanel.bundle` / `files\yoo\Default\BundleFiles\e3\e3d3e717016b34809f6b290d4ff3fdd0\__data`
- 节点数：`69`。
- Image/Text/Button：`35` / `21` / `12`。
- Image 解析：外部 Sprite `6`，外部具名但未落到物理表 `0`，prefab 内置 Sprite `0`，无 sprite `5`，未解析 `24`。

## 资源 Bundle 表

| Resource | Count | Asset / Source | Bundle | Hash / physical | Source |
|---|---:|---|---|---|---|
| `common_btn_09` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_09.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_btn_10` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_10.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_btn_46` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_46.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `common_btn_47` | 1 | `Assets/Game/RawAssets/Sprite/Common/common_btn_47.png` | `assets_game_rawassets_sprite_common.bundle` | `a06093a283eeef9c3a67926e932b542b.bundle`<br>`resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` | external CAB-a92c8577f61f9130a2b94e6ff20aa841 |
| `lottery_img_04` | 1 | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_04.png` | `assets_game_rawassets_sprite_lotterydraw_lottery_img_04.bundle` | `dea303e9d66eab234f3c1e6430a20980.bundle`<br>`files\yoo\Default\BundleFiles\de\dea303e9d66eab234f3c1e6430a20980\__data` | external CAB-c715b158950f12de8ee3e20ef8db9ce6 |
| `lottery_img_76` | 1 | `Assets/Game/RawAssets/Sprite/LotteryDraw/lottery_img_76.png` | `assets_game_rawassets_sprite_lotterydraw_lottery_img_76.bundle` | `d18da8991abf543c31a1fd4d689ea7df.bundle`<br>`files\yoo\Default\BundleFiles\d1\d18da8991abf543c31a1fd4d689ea7df\__data` | external CAB-988e4f5565096cd564aafbe5b40ad380 |

## 外部 CAB 对照

| FileID | CAB | Located bundle | Physical |
|---:|---|---|---|
| 1 | `CAB-380dc4eef737e1f3e153b7a16c1efbd3` | `-` | `-` |
| 2 | `CAB-c715b158950f12de8ee3e20ef8db9ce6` | `assets_game_rawassets_sprite_lotterydraw_lottery_img_04.bundle` | `files\yoo\Default\BundleFiles\de\dea303e9d66eab234f3c1e6430a20980\__data` |
| 3 | `CAB-6c60a3a6a32a4b548beb1fe07fe3833e` | `-` | `-` |
| 4 | `CAB-a92c8577f61f9130a2b94e6ff20aa841` | `assets_game_rawassets_sprite_common.bundle` | `resources\assets\yoo\Default\a06093a283eeef9c3a67926e932b542b.bundle` |
| 5 | `CAB-988e4f5565096cd564aafbe5b40ad380` | `assets_game_rawassets_sprite_lotterydraw_lottery_img_76.bundle` | `files\yoo\Default\BundleFiles\d1\d18da8991abf543c31a1fd4d689ea7df\__data` |

## 节点层级清单

| # | D | Path | Active | Rect | Anchor | Components | Bindings / resources |
|---:|---:|---|:---:|---|---|---|---|
| 1 | 0 | `PrayerHolyRelicPanel` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,PrayerHolyRelicPanel` | - |
| 2 | 1 | `PrayerHolyRelicPanel/pnlAnimation` | Y | `pos(0.0,0.0) size(1670.0,750.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 3 | 1 | `PrayerHolyRelicPanel/imgFrame` | Y | `pos(0.0,156.5) size(0.0,313.0)` | `0.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:lottery_img_76 [Simple] -> assets_game_rawassets_sprite_lotterydraw_lottery_img_76.bundle |
| 4 | 2 | `PrayerHolyRelicPanel/imgFrame/Image` | Y | `pos(0.0,-26.0) size(1542.0,7.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:lottery_img_04 [Simple] -> assets_game_rawassets_sprite_lotterydraw_lottery_img_04.bundle |
| 5 | 2 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList` | Y | `pos(64.0,83.5) size(0.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.0,0.5)` | `RectTransform,HorizontalLayoutGroup,ContentSizeFitter` | - |
| 6 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnRate` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=-4035612386460074897 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 7 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnRate/Text` | Y | `pos(0.0,-34.0) size(0.0,-40.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=14):"Default" |
| 8 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnShop` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=-7159043926509657500 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 9 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnShop/Text` | Y | `pos(0.0,-34.0) size(0.0,-40.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=14):"Default" |
| 10 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnRecharge` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=9155956380031670154 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 11 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnRecharge/Text` | Y | `pos(0.0,-34.0) size(0.0,-40.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=14):"Default" |
| 12 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnRecharge/@pnlRd` | Y | `pos(-10.7,-11.8) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 13 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnHolyRelic` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:external fid=1 pid=8268279253554149858 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 14 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnHolyRelic/Text` | Y | `pos(0.0,-34.0) size(0.0,-40.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=14):"Default" |
| 15 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 16 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/imgIntegral` | Y | `pos(30.0,-30.0) size(60.0,60.0)` | `0.0,1.0->0.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=1076327022705815863 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 17 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/imgIntegral/imgIntegralIcon` | Y | `pos(0.0,0.0) size(54.0,54.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-8319959417636250724 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 18 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/imgIntegral/imgIntegralSlider` | Y | `pos(0.0,0.0) size(54.0,54.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-5545066425052016706 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Filled] |
| 19 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/imgIntegralFinish` | Y | `pos(0.0,0.0) size(60.0,60.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-517402153190721771 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 20 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/btnIntegralNum` | Y | `pos(0.0,-33.5) size(60.0,17.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:none [Simple], a=0.00<br>Button |
| 21 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/btnIntegralNum/Text` | Y | `pos(0.0,8.5) size(60.0,17.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=14):"Default" |
| 22 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/@pnlRd` | Y | `pos(-10.7,-11.8) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 23 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlBtnList/btnIntegral/@pnlRd2` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform` | - |
| 24 | 2 | `PrayerHolyRelicPanel/imgFrame/tglSkipAnimation` | Y | `pos(-830.0,74.5) size(32.0,31.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,Toggle` | - |
| 25 | 3 | `PrayerHolyRelicPanel/imgFrame/tglSkipAnimation/Background` | Y | `pos(0.0,0.0) size(0.0,0.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_btn_09 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 26 | 4 | `PrayerHolyRelicPanel/imgFrame/tglSkipAnimation/Background/Checkmark` | Y | `pos(0.0,0.0) size(32.0,32.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:common_btn_10 [Simple] -> assets_game_rawassets_sprite_common.bundle |
| 27 | 3 | `PrayerHolyRelicPanel/imgFrame/tglSkipAnimation/Text` | Y | `pos(78.9,1.0) size(73.7,-5.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,LangLabel` | Text(fs=18):"Default" |
| 28 | 2 | `PrayerHolyRelicPanel/imgFrame/btnPrayerOnce` | Y | `pos(-544.0,70.0) size(324.0,94.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_46 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 29 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerOnce/txtPrayerOnce` | Y | `pos(-49.0,6.5) size(150.0,31.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Default" |
| 30 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerOnce/imgPrayerOnceCost` | Y | `pos(42.0,5.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 31 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerOnce/txtPrayerOnceCost` | Y | `pos(88.0,6.5) size(30.8,31.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"11" |
| 32 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerOnce/@pnlRd` | Y | `pos(-29.3,-11.9) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 33 | 2 | `PrayerHolyRelicPanel/imgFrame/btnPrayerContinuous` | Y | `pos(-214.0,70.0) size(324.0,94.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button` | Image:common_btn_47 [Simple] -> assets_game_rawassets_sprite_common.bundle<br>Button |
| 34 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerContinuous/txtPrayerContinuous` | Y | `pos(-49.0,6.5) size(150.0,31.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"Default" |
| 35 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerContinuous/imgPrayerContinuousCost` | Y | `pos(42.0,5.0) size(50.0,50.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:none [Simple] |
| 36 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerContinuous/txtPrayerContinuousCost` | Y | `pos(88.0,6.5) size(30.8,31.2)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=26):"11" |
| 37 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerContinuous/txtPrayerContinuousLimitNum` | Y | `pos(0.0,-0.5) size(324.0,25.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text` | Text(fs=25):"Default" |
| 38 | 3 | `PrayerHolyRelicPanel/imgFrame/btnPrayerContinuous/@pnlRd` | Y | `pos(-29.3,-11.9) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 39 | 2 | `PrayerHolyRelicPanel/imgFrame/pnlTab` | Y | `pos(-64.0,210.0) size(0.0,111.0)` | `1.0,0.0->1.0,0.0 p(1.0,0.5)` | `RectTransform,TabGroup,HorizontalLayoutGroup,ContentSizeFitter` | - |
| 40 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1` | Y | `pos(0.0,0.0) size(104.0,104.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,TabItem` | Image:external fid=1 pid=7009740968499786140 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 41 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1/imgPrayer1` | Y | `pos(0.0,-15.0) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-2575141339789417602 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 42 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1/imgPrayer1Select` | Y | `pos(0.0,0.0) size(111.0,111.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-5766182629493693437 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 43 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1/imgPrayer1Select/Image` | Y | `pos(0.0,-14.5) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-4772808405487343137 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 44 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1/txtPrayer1` | Y | `pos(0.0,6.5) size(104.0,37.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=22):"Default" |
| 45 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1/@pnlRd` | Y | `pos(-16.0,-23.6) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 46 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer1/@txtNum` | Y | `pos(-54.0,35.5) size(100.0,37.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"Default" |
| 47 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2` | Y | `pos(0.0,0.0) size(104.0,104.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,TabItem` | Image:external fid=1 pid=352204763180801471 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 48 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2/imgPrayer2` | Y | `pos(0.0,-15.0) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-613239148736052799 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 49 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2/imgPrayer2Select` | Y | `pos(0.0,0.0) size(111.0,111.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-5766182629493693437 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 50 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2/imgPrayer2Select/Image` | Y | `pos(0.0,-14.5) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=3942198674152777362 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 51 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2/txtPrayer2` | Y | `pos(0.0,6.5) size(104.0,37.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=22):"Default" |
| 52 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2/@pnlRd` | Y | `pos(-16.0,-23.6) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 53 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer2/@txtNum` | Y | `pos(-57.5,35.5) size(107.0,37.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"Default" |
| 54 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3` | Y | `pos(0.0,0.0) size(104.0,104.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,TabItem` | Image:external fid=1 pid=947226610941265192 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 55 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3/imgPrayer3` | Y | `pos(0.0,-15.0) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-7018412386410085690 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 56 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3/imgPrayer3Select` | Y | `pos(0.0,0.0) size(111.0,111.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-5766182629493693437 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 57 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3/imgPrayer3Select/Image` | Y | `pos(0.0,-14.5) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=3520347601309565911 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 58 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3/txtPrayer3` | Y | `pos(0.0,6.5) size(104.0,37.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=22):"Default" |
| 59 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3/@pnlRd` | Y | `pos(-16.0,-23.6) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 60 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer3/@txtNum` | Y | `pos(-54.0,35.5) size(100.0,37.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"Default" |
| 61 | 3 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4` | Y | `pos(0.0,0.0) size(104.0,104.0)` | `0.0,0.0->0.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image,Button,TabItem` | Image:external fid=1 pid=510389095063694228 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple]<br>Button |
| 62 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4/imgPrayer4` | Y | `pos(0.0,-15.0) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=6675259198021006933 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 63 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4/imgPrayer4Select` | Y | `pos(0.0,0.0) size(111.0,111.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=-5766182629493693437 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 64 | 5 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4/imgPrayer4Select/Image` | Y | `pos(0.0,-14.5) size(118.0,118.0)` | `0.5,0.5->0.5,0.5 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Image` | Image:external fid=1 pid=2062222436411578312 cab=CAB-380dc4eef737e1f3e153b7a16c1efbd3 [Simple] |
| 65 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4/txtPrayer4` | Y | `pos(0.0,6.5) size(104.0,37.0)` | `0.5,0.0->0.5,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=22):"Default" |
| 66 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4/@pnlRd` | Y | `pos(-16.0,-23.6) size(0.0,0.0)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform` | - |
| 67 | 4 | `PrayerHolyRelicPanel/imgFrame/pnlTab/btnPrayer4/@txtNum` | Y | `pos(-57.5,35.5) size(107.0,37.0)` | `1.0,0.0->1.0,0.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"Default" |
| 68 | 1 | `PrayerHolyRelicPanel/txtDrawName` | Y | `pos(-488.5,-152.5) size(853.0,69.5)` | `1.0,1.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline,LangLabel` | Text(fs=60):"Default" |
| 69 | 1 | `PrayerHolyRelicPanel/txtTip` | Y | `pos(346.0,153.0) size(-818.0,-690.0)` | `0.0,0.0->1.0,1.0 p(0.5,0.5)` | `RectTransform,CanvasRenderer,Text,NicerOutline` | Text(fs=22):"Default" |

## 复用路线验证

- 该文档不是手工拼表，而是由通用脚本从 prefab bundle、layout、MonoBehaviour 字段和物理资产表组合生成。
- 若 `Image:none` 出现在按钮或点击区上，通常表示透明 hit target 或运行时替换资源，不应直接判定资源缺失。
- 若 external CAB 未定位，需要先扩充本地 bundle 样本或物理资产映射，再重跑脚本。

## 2026-05-26 遺器祈願补充定位

`CAB-380dc4eef737e1f3e153b7a16c1efbd3` 对应 `Assets/Game/RawAssets/Sprite/LotteryDraw/LotteryDraw.spriteatlas`。Manifest 显示逻辑包为 `assets_game_rawassets_sprite_lotterydraw.bundle` / `6c8ca2312693e27b46729a868236cce3.bundle`，但本地物理表可能无法直接闭合；实际可读样本位于：

```powershell
files\yoo\Default\BundleFiles\ce\ce18fceb7ff2f67915e3b4177b14df94\__data
```

解包命令沿用 YooAsset 前缀 XOR 经验，必须使用 `--xor-prefix 222 --xor-key 0x16`：

```powershell
py -3.14 .\scripts\assets\export_unity_bundle_images.py `
  .\files\yoo\Default\BundleFiles\ce\ce18fceb7ff2f67915e3b4177b14df94\__data `
  --out .\reverse-output\godot-resource-export\lotterydraw-ce `
  --xor-prefix 222 --xor-key 0x16
```

本轮验证：该包可解析 `210` 个 Unity 对象，其中 `207` 个图片成功导出。经验：不要只试 `0/32/64/128/256` 这类常见前缀，`PrayerHolyRelicPanel` 与 `LotteryDrawNewStageView` 仍需要历史确认过的 `222` 字节前缀。

### PrayerHolyRelicPanel pid 对照

| Prefab 节点 | pid | Sprite | 尺寸 | Godot 路径 |
|---|---:|---|---|---|
| `btnRate` | `-4035612386460074897` | `lottery_btn_04` | `60x60` | `assets/ui/lottery/lottery_btn_04.png` |
| `btnShop` | `-7159043926509657500` | `lottery_btn_22` | `60x60` | `assets/ui/lottery/lottery_btn_22.png` |
| `btnRecharge` | `9155956380031670154` | `lottery_btn_23` | `60x60` | `assets/ui/lottery/lottery_btn_23.png` |
| `btnHolyRelic` | `8268279253554149858` | `lottery_btn_24` | `60x60` | `assets/ui/lottery/lottery_btn_24.png` |
| `btnIntegral/imgIntegral` | `1076327022705815863` | `lottery_img_95` | `60x60` | `assets/ui/lottery/lottery_img_95.png` |
| `btnIntegral/imgIntegral/imgIntegralIcon` | `-8319959417636250724` | `lottery_btn_25` | `84x82` | `assets/ui/lottery/lottery_btn_25.png` |
| `btnIntegral/imgIntegral/imgIntegralSlider` | `-5545066425052016706` | `lottery_img_10` | `54x54` | `assets/ui/lottery/lottery_img_10.png` |
| `btnIntegral/imgIntegralFinish` | `-517402153190721771` | `lottery_img_115` | `60x60` | `assets/ui/lottery/lottery_img_115.png` |
| `btnPrayer1` | `7009740968499786140` | `lottery_img_75` | `104x104` | `assets/ui/lottery/lottery_img_75.png` |
| `btnPrayer1/imgPrayer1` | `-2575141339789417602` | `lottery_btn_29` | `87x82` | `assets/ui/lottery/lottery_btn_29.png` |
| `btnPrayer1/imgPrayer1Select` | `-5766182629493693437` | `lottery_img_77` | `111x111` | `assets/ui/lottery/lottery_img_77.png` |
| `btnPrayer1/imgPrayer1Select/Image` | `-4772808405487343137` | `lottery_btn_30` | `118x110` | `assets/ui/lottery/lottery_btn_30.png` |
| `btnPrayer2` | `352204763180801471` | `lottery_img_96` | `104x104` | `assets/ui/lottery/lottery_img_96.png` |
| `btnPrayer2/imgPrayer2` | `-613239148736052799` | `lottery_btn_31` | `83x84` | `assets/ui/lottery/lottery_btn_31.png` |
| `btnPrayer2/imgPrayer2Select/Image` | `3942198674152777362` | `lottery_btn_32` | `115x116` | `assets/ui/lottery/lottery_btn_32.png` |
| `btnPrayer3` | `947226610941265192` | `lottery_img_74` | `104x104` | `assets/ui/lottery/lottery_img_74.png` |
| `btnPrayer3/imgPrayer3` | `-7018412386410085690` | `lottery_btn_33` | `85x87` | `assets/ui/lottery/lottery_btn_33.png` |
| `btnPrayer3/imgPrayer3Select/Image` | `3520347601309565911` | `lottery_btn_34` | `118x110` | `assets/ui/lottery/lottery_btn_34.png` |
| `btnPrayer4` | `510389095063694228` | `lottery_img_97` | `104x104` | `assets/ui/lottery/lottery_img_97.png` |
| `btnPrayer4/imgPrayer4` | `6675259198021006933` | `lottery_btn_35` | `87x89` | `assets/ui/lottery/lottery_btn_35.png` |
| `btnPrayer4/imgPrayer4Select/Image` | `2062222436411578312` | `lottery_btn_36` | `118x114` | `assets/ui/lottery/lottery_btn_36.png` |
