# Startup Background Layout Reanalysis

Date: 2026-05-24

This pass corrects the startup background mapping with the latest confirmed facts:

- `login_bg_01.png` is the LoginView background.
- `loading_bg_01.png` is the post-login LoadingView background.
- `update_bg_01.png` is the startup resource initialization / hot update background.

## Corrected Startup Chain

| Phase | Runtime / View | Confirmed background | Layout source | Main layout |
|---|---|---|---|---|
| App splash | `AOT.StartView` | Built-in splash list, not confirmed as a `BackGround` PNG | `dump.cs`, `StartView.splashList` | Sequential CanvasGroup splash fade. |
| Resource init / hot update | `AOT.UpdateView` | `update_bg_01.png` | `dump.cs` fields, `UpdateView` class | Fullscreen update image, bottom/center progress text+slider, fix button, modal alter/fix dialogs. |
| Launch video | `LaunchView` | `launch.mp4` / black Image + RawImage, no `*_bg_01` | `LaunchView.layout.json` | 4 nodes: fullscreen Image, centered 1680x1680 RawImage, centered VideoPlayer. |
| Login | `LoginView` | `login_bg_01.png` | `LoginView.layout.json`, `LoginView.mb-fields.json` | Fullscreen background, invisible fullscreen login tap layer, right function column, top-left logo, bottom agreement/copyright, centered account input. |
| Post-login progress | `LoadingView` | `loading_bg_01.png` | `LoadingView.layout.json`, `LoadingView` IL | Fullscreen background, bottom horizontal Slider with 82x82 handle, right-anchored percent text, auto transition to MainScene. |
| Main scene | `MainUIView` | `mainui_bg_01~08.png` candidates; current confirmed MVP uses `mainui_bg_01.png` | `MainUIView.layout.json` | WallpaperPanel background, TopBar, player info, right-side entrances, bottom function bar, chat, chapter button. |

## Startup Layout Details

### UpdateView

`UpdateView` is an AOT `MonoBehaviour`, not a hotfix `ViewBehaviour` prefab in the current exported UI prefab list. The class fields give the layout skeleton:

```text
UpdateView
  txtTip
  sldSpeed
  txtApp
  btnFix
  imgMask + pnlAlter + txtTitle/txtMsg/btnOk/txtOk
  imgFixMask + pnlFixAlter + txtFixTitle/txtFixMsg/btnFixYes/btnFixNo
```

New mapping: `update_bg_01.png` should be the fullscreen background for this phase. `update_bg_03.png` is visually the same scene family and should be treated as an alternate / later update background, not the login or post-login loading page.

### LoginView

`LoginView` keeps the 2026-05-23 prefab layout, but the background assignment is now explicit:

- `imgBg`: centered `1670x750`, background is `login_bg_01.png`.
- `@rawImgBg`: hidden `1670x1670` RawImage for video background fallback.
- `pnl/btnLogin`: fullscreen invisible Button, so tapping anywhere on the panel can trigger login.
- `pnlFunction`: right-edge vertical function column, `131px` wide, contains `btnNotice`, `btnRepair`, `btnSwitchAccount`, `btnSelect`, each `60x60`.
- `imgLogo`: top-left, `260x104`, scaled `0.8`.
- `inputAccount`: centered, `543x64`, with icon, placeholder, text and label children.
- `btnServerSel`: centered `500x34`, default inactive.
- `@richUrl/togAgree`: bottom agreement area.
- `pnlVersion`: bottom-right version panel.

The Godot MVP should not use `login_bg_01.png` for LoadingView anymore.

### LoadingView

`LoadingView.Awake()` uses:

```text
GameHelper.FixHarmoniousPic("6")
AssetsHelper.LoadSpriteFromBackground(picName)
imgBg.SetSpriteAsync(...)
```

Given the confirmed mapping, key `"6"` resolves to the `loading_bg_01` family for this build.

Correct layout:

- `imgBg`: centered `1670x750`, now `loading_bg_01.png`.
- `sldSpeed`: bottom horizontal Unity Slider, stretched width with margins, height `34`.
- `sldSpeed/Background`: track image, `34px` high.
- `sldSpeed/Fill`: value-driven fill.
- `sldSpeed/Handle`: `82x82`, pivot `(0, 0.55)`.
- `txtPercent`: `123x37`, right-anchored, near the slider.
- Behavior: fake progress from `0` to `100`, then auto calls `GameHelper.LoadMainScene`.

## Background-Driven UI Layouts Found

The `BackGround` folder contains many `1670x750` fullscreen images. These are not all interchangeable; many imply specific UI families. The strongest matches are below.

| Background group | Likely view / prefab | Evidence | Layout shape |
|---|---|---|---|
| `mainui_bg_01~08` | `MainUIView` wallpaper variants | Existing MainUI docs + current MVP mapping | Fullscreen scenery behind persistent top bar, bottom bar, right gameplay buttons and role display. |
| `bag_bg_01` | `BagView` | Sampled `BagView.layout.json` | Fullscreen bg, right item detail panel `350x750`, central item grid `740x655`, left vertical tabs. |
| `mail_bg_01` | `MailboxView` | Sampled `MailboxView.layout.json` | Framed 1307x718 mail window, left mail list, right content/reward pane, close button top-right. |
| `task_bg_01/02` | `TaskView` | Sampled `TaskView.layout.json` | Fullscreen task shell with left tab rail and large content panel under `pnl`. |
| `announcement_bg_01/02` | `AnnounceView` | Sampled `AnnounceView.layout.json` | Modal announcement window, left tab list, right web/text content area, close button. |
| `hero_bg_*` | `HeroMainView` and hero subviews | Sampled `HeroMainView.layout.json` | Fullscreen character view, large role display zone, left hero selector, right detail/action panels. |
| `lottery_bg_01~09` | `LotteryDrawMainView`, wish/stage panels | Existing lottery prefab docs + asset names | Fullscreen gacha background, left/right wish panels, pool tabs, bottom draw buttons. |
| `lottery_img_09~11` | `LotteryDrawFinishView` / recruit result illustration backgrounds | Existing lottery docs + visual assets | Result/recruit display backgrounds, character/result focus with overlay UI. |
| `activity_bg_*`, `activity_a*_bg_*`, `celebration_*`, `cumulative_*`, `privilege_*`, `limitGift_*` | `ActivityMainView` plus activity sub-panels | Sampled `ActivityMainView.layout.json`, `ac_limit_drawconfig.bgPic` | Fullscreen activity shell, `imgBg` `1670x750`, left/bottom `tabActivity` rail, dynamic content host under `pnlActivity`. |
| `city_bg_01` | `CityView` | Sampled `CityView.layout.json` | Fullscreen city map with fixed scene hot spots: coffee, hospice, camp, tactics, shelter, ladder, pavilion. |
| `expedition_bg_02/04/05` | `ExpeditionMainView`, `ExpeditionMapView` | Sampled `ExpeditionMainView.layout.json`, `ExpeditionMapView.layout.json` | Expedition hub with bottom command cluster and separate scrollable map view. |
| `dispatch_bg_01/02/03` | `DispatchView` | Sampled `DispatchView.layout.json` | Fullscreen dispatch list, task scroll area, refresh/fast-get buttons, auto toggle panel. |
| `gal_bg_*`, `BackGround/Gal/*` | `GalMapView`, `GalCollectionView`, story/date scenes | Manifest + `gal_plot.csv` background fields | Visual novel/date scene backgrounds, dialogue/choice overlays; exact prefab bundles not present locally. |
| `gameshop_bg_*` | `GameShopView` family | Manifest naming; sampled `GameShopWeaponExChangePanel.layout.json` only | Main shop background family is clear by name, but current physical map only yielded a small weapon-exchange price row panel. |
| `arena_bg_*`, `arena_cross_bg_*`, `arena_top_bg_*` | Arena views | Sampled `ArenaMainView.layout.json` + prefab list | Fullscreen arena hub with multiple large mode cards. |
| `alliance_bg_*` | Alliance views, confirmed for `AllianceExpeditionMainView` | Sampled `AllianceExpeditionMainView.layout.json`; `AllianceMainView` still missing physically | Fullscreen alliance expedition boss page: interactive role layer, boss info top, battle info left, reward scroller right. |
| `roguelike_bg_*`, `Roguelike_event_bg_*` | `RoguelikeView` and roguelike event views | Sampled `RoguelikeView.layout.json` | Tall scrollable map background, left action buttons, top hero list, right event/message panel. |
| `chapter_chufa_*` | `ChapterTaskView` / chapter task flow | `chapter.csv.background`, sampled `ChapterTaskView.layout.json` | Fullscreen chapter image layer with `pnlReward` and `pnlTask` over it. These names are table background keys, not extracted in the local `BackGround` image folder yet. |
| `weapon_bg_01~03` | `ExclusiveWeaponMainView` | Sampled `ExclusiveWeaponMainView.layout.json` | Fullscreen weapon upgrade page: background, large weapon art, left weapon list, level/star tabs and upgrade panels. |
| `mastery_bg_01` | `MasteryMainView` | Sampled `MasteryMainView.layout.json` | Fullscreen mastery page with large level/attribute art, effect scroll area, cost scroll area and update/max states. |
| `Remnants_bg_*`, `remnants_bg_*`, `march_bg_02` | `RemnantsMainView`, `RemnantsListView`, `RemnantsMarchView` | Sampled three Remnants layouts | Relic/remnant hub with layered fog and central show panels; list page has left scroll list plus large detail base; march view is a `1250x650` modal. |
| `common_bg_*`, `popup_bg_*` | Common modal panels | Visual frame assets + common prefab list | Reusable white/blue/brown modal sheets, usually not fullscreen scene backgrounds. |
| `story_bg_*` | Story / cutscene screens | Manifest + Story prefabs | Fullscreen story background with dialogue/insert overlays. |
| `update_bg_01/03` | AOT update / resource init | Confirmed mapping + `UpdateView` fields | Startup update page with progress text/slider and repair/fix dialogs. |

## Follow-On Sweep Findings

The continued sweep used two extra signals:

- Physical background inventory: 427 local `BackGround` PNG files are present; 265 are exactly `1670x750`, which matches the dominant fullscreen UI canvas.
- Prefab sampling: 20 additional or startup-adjacent UI prefabs were extracted to `reverse-output/background-layout-inspect/*.layout.json`, and the summary was regenerated in `docs/shaonv-background-prefab-sampling-2026-05-24.md`.

New layout conclusions:

- `ActivityMainView` is intentionally sparse. It is a fullscreen background plus `tabActivity` and an empty `pnlActivity` host, so most `activity_*` backgrounds belong to driven sub-panels loaded into this shell.
- `CityView` is not a list/detail UI. It is a clickable map; each visible building is a separate image with an oversized hit Button.
- `ExpeditionMainView` and `ExpeditionMapView` split the feature into a hub and map. The hub has a bottom action row; the map prefab is almost entirely a scroller/recycled map container.
- `DispatchView` is a stable fullscreen operations layout: background, task scroll region, refresh controls, fast collect, and an auto-dispatch toggle.
- `AllianceExpeditionMainView` gives a concrete alliance layout even though `AllianceMainView` itself is still absent from the local physical map.
- `RemnantsMainView` confirms that the `Remnants_bg_*` family is not a simple static page. It has layered fog masks, multiple central show panels and separate list/march subviews.
- `ExclusiveWeaponMainView` and `MasteryMainView` confirm that `weapon_bg_*` and `mastery_bg_01` are progression pages rather than generic popups.

## Confidence Notes

- High confidence: startup chain, LoginView, LoadingView, MainUIView, BagView, MailboxView, TaskView, AnnounceView, HeroMainView, ArenaMainView, RoguelikeView, ActivityMainView, CityView, ExpeditionMainView, ExpeditionMapView, DispatchView, AllianceExpeditionMainView, ChapterTaskView, ExclusiveWeaponMainView, MasteryMainView, RemnantsMainView, RemnantsListView and RemnantsMarchView.
- Medium confidence: lottery backgrounds, because existing prefab analysis covers `LotteryDrawMainView`, `HeroRecruitView`, `LotteryDrawFinishView`, but exact per-background runtime selection still needs code/table mapping.
- Medium confidence: GameShop and Alliance main hub. `GameShopWeaponExChangePanel` and `AllianceExpeditionMainView` now give family evidence, but the main `GameShopView` / `AllianceMainView` physical rows are still missing.
- Lower confidence: Gal map/collection prefab layouts, because the manifest lists their prefabs and story tables reference many `gal_bg_*` backgrounds, but the current local extraction did not provide their exact prefab bundles.

## Artifacts From This Pass

- Sampled prefab layouts: `docs/shaonv-background-prefab-sampling-2026-05-24.md`
- MainUI screenshot comparison: `docs/shaonv-mainui-screenshot-layout-comparison-2026-05-24.md`
- Generated JSON layouts: `reverse-output/background-layout-inspect/*.layout.json` currently includes 20 successful prefab layout snapshots.
- Local scratch visual sheets: `tmp/background-analysis/*.png` (not part of the committed source set).
