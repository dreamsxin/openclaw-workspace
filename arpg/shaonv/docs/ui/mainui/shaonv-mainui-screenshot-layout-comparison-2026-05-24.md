# MainUIView Screenshot Layout Comparison

Date: 2026-05-24

This pass follows the corrected startup/background mapping and compares the real post-login screenshot:

```text
screenshot/登录后界面主屏.jpg
```

The screenshot is `2400x1080`. The source prefab canvas is `1670x750`, so the screenshot is almost a direct scale-up:

```text
scaleX = 2400 / 1670 = 1.437
scaleY = 1080 / 750 = 1.440
```

## Main Finding

The post-login main screen is `Assets/Game/RawAssets/Prefabs/UI/MainUI/MainUIView.prefab` in its normal state.

It is not `CityView`. The city night scene visible in the screenshot is `mainui_bg_01.png` rendered inside `MainUIView/@WallpaperPanel/imgBackGround`. `CityView` is a separate feature map with building hotspot buttons.

Evidence:

- `LoadingView` transitions to `MainScene`.
- `MainUIView` is the hotfix view for the MainScene main lobby.
- `mainui_bg_01.png` visually matches the screenshot background exactly.
- The screenshot's top player panel, top resource row, chat bar, left activity block, right commerce block, right chapter block, bottom navigation and bottom-right gameplay buttons all match `MainUIView.layout.json`.

## Runtime State

The screenshot shows `MainUIView` in `main_normal`:

```text
@WallpaperPanel + role
@TopBar
pnlPlayerInfo
pnlChat
pnlFunny
pnlCommercialization
btnChapterInfo
pnlBottom
```

The IL analysis already shows these panels are grouped in `listPanel`:

```text
listPanel = [pnlChat, pnlFunny, pnlPlayerInfo, pnlCommercialization, btnChapterInfo, pnlBottom]
```

`ShowOrHide()` can hide this set for wallpaper-focus mode. The screenshot is not wallpaper-focus mode because all lobby UI panels are visible.

## Complete Visible Layout

| Zone | Prefab node | Unity layout | Screenshot match |
|---|---|---|---|
| Fullscreen root | `MainUIView/pnlAdapter` | full stretch | Whole screenshot canvas. |
| Background | `@WallpaperPanel/imgBackGround` | centered `1668x750` | City interior/night skyline background, confirmed as `mainui_bg_01.png`. |
| Role display | `@WallpaperPanel/irole` | centered `957.5x750` | Large centered girl and companion mascots over the background. |
| Tap mask | `btnBodyMask` | full stretch | Invisible role/wallpaper interaction layer. |
| Top player panel | `pnlPlayerInfo` | top-left, `354x113`, pos `(0,-5)` | Level `34`, player name, power value at top-left. |
| Wallpaper buttons | `btnChange`, `btnEye` | top-left icons near player panel, `74x74` | Screenshot labels `壁纸`, `互动`. |
| Top resource row | `@TopBar/svRes` | top row resource scroller | Ticket/stamina-like resource and premium currency at top-right. |
| Menu button | `pnlFunny/btnMenu` | top-right, `78x78`, pos `(-94,-54)` | Compass-like round button at far top-right. |
| Chat bar | `pnlChat` | top-right, `410x40`, pos `(-64,-94)` | `[世界] ...` chat line under the resource row. |
| Left activity area | `pnlCommercialization` | top-left anchored, `416x420`, pos `(265,-333)` | Left banner plus event icon grid. |
| Activity banner | `pnlCommercialization/@pnlAlternate` | `301x108`, pos `(0,0)` | `新手狂欢` banner. |
| Event icons | `pnlCommercialization/pnlGift` | `409x300`, pos `(7,-120)` | 3-row activity icon grid with timers. |
| Right commerce column | `pnlFunny/pnlCharge` | top-right, `158x258`, pos `(-55,-277)` | `储值/活动/商店/福利/月卡` vertical block. |
| Chapter reward preview | `btnChapterInfo` | bottom-right, `276x100`, pos `(-34,150)` | `第5章... 2/4` and three reward icons. |
| Main story/hook block | `pnlFunny/pnlStory` | bottom-right, `278x98`, pos `(-60,19)` | Large `尘世探秘` button and hook timer chest. |
| Gameplay buttons | `pnlFunnyContent` | bottom-right row, height `102`, pos `(-339,70)` | `竞技/祈愿/冒险/召唤` four icons. |
| Bottom nav | `pnlBottom` | bottom-left, height `50`, pos `(64,49)` | `现世/幻灵/背包/遗器/养成/任务/公会`. |
| Special Gal/current-world button | `pnlBottom/pnlGal/btnGal` | `115x129`, protrudes upward from the 50px bottom bar | Big glowing `现世` portal button. |

## Screenshot Coordinate Check

Approximate screenshot boxes below use `scaleX=1.437`, `scaleY=1.440`. Y ranges are top-origin screenshot pixels.

| Prefab node | Unity box / position | Expected screenshot area | Visible screenshot evidence |
|---|---|---|---|
| `pnlPlayerInfo` | `x=0..354`, top `5..118` | `x=0..509`, `y=7..170` | Level ring/name/power block. |
| `btnChange` | center near `(402,47)`, `74x74` | `x=524..631`, `y=22..128` | `壁纸` icon. |
| `btnEye` | center near `(478,47)`, `74x74` | `x=633..740`, `y=22..128` | `互动` icon. |
| `pnlChat` | `x=1196..1606`, top `94..134` | `x=1718..2308`, `y=135..193` | World chat text. |
| `pnlCommercialization` | `x=57..473`, top `123..543` | `x=82..680`, `y=177..782` | Left banner plus event grid. |
| `@pnlAlternate` | `x=57..358`, top `123..231` | `x=82..514`, `y=177..333` | `新手狂欢` banner. |
| `pnlGift` | `x=64..473`, top `243..543` | `x=92..680`, `y=350..782` | Timer event icon grid. |
| `pnlCharge` | `x=1457..1615`, top `148..406` | `x=2094..2320`, `y=213..585` | Right-side commerce icons. |
| `btnMenu` | `x=1537..1615`, top `15..93` | `x=2209..2320`, `y=22..134` | Compass/menu button. |
| `btnChapterInfo` | `x=1360..1636`, top `500..600` | `x=1954..2351`, `y=720..864` | Chapter reward preview. |
| `pnlStory` | `x=1332..1610`, top `633..731` | `x=1914..2314`, `y=912..1053` | Large `尘世探秘` button. |
| `pnlFunnyContent` | about `x=972..1331`, top `629..731` | about `x=1397..1913`, `y=906..1053` | Four bottom-right gameplay buttons. |
| `pnlBottom` | starts at `x=64`, top `676..726` | starts near `x=92`, `y=973..1045` | Bottom navigation labels. |
| `btnGal` | `115x129`, protrudes above bottom bar | about `y=860..1045`, glow can extend lower | Big `现世` portal. |

## Corrections From Screenshot

- `mainui_bg_01.png` is the exact lobby background seen after login.
- `pnlCommercialization` is the entire left-side activity module. It should not be merged into `pnlFunny`.
- The bottom-right `尘世探秘` button is `pnlStory`, not `btnChapterInfo`.
- `btnChapterInfo` is the reward-preview strip above `pnlStory`.
- The large `现世` button is the special `btnGal`/Gal-current-world entry. It is not a normal same-size bottom tab.
- `pnlCharge` is vertical on the right edge; the screenshot confirms the prefab's vertical stack, not a 2x3 grid.
- `pnlFunnyContent` is the four-icon row `竞技/祈愿/冒险/召唤` at bottom-right.

## Reconstruction Notes

For Godot or other reconstruction, keep the source canvas as `1670x750` and scale to target aspect. The screenshot proves the main screen should be implemented as one dense lobby surface, not as separate floating cards:

1. Draw `mainui_bg_01.png` fullscreen.
2. Overlay the wallpaper role/interactive layer in the center.
3. Place `pnlPlayerInfo`, `@TopBar`, `pnlChat`, `pnlCommercialization`, `pnlCharge`, `btnChapterInfo`, `pnlStory`, `pnlFunnyContent`, and `pnlBottom` as sibling panels under `pnlAdapter`.
4. Keep `btnGal` oversized and protruding upward from the bottom bar.
5. Treat `pnlCtl`, `btnClose`, `btnDetail`, `pnlExpeditionSoftGuide`, `pnlHookSoftGuide`, and `imgSpeak` as conditional/hidden overlays, not part of the screenshot's default state.
