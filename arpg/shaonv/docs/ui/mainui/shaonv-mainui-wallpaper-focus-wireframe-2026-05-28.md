# MainUIView Wallpaper Focus Wireframe

Source scope: MainUIView normal state, `btnEye` interaction entry, and WallpaperPanel `wallpaper_focus` first-level interaction.

```text
MainUIView normal
┌──────────────────────────────────────────────────────────────────────────────┐
│ TopBar / resources                                                    menu   │
│ ┌──────────── player info ────────────┐  [壁紙 btnChange] [互動 btnEye]       │
│ └─────────────────────────────────────┘                                      │
│                                                                              │
│                         @WallpaperPanel                                      │
│                         ┌──────── irole 560x620 ────────┐                   │
│                         │      role/spBg/spHero/spFg     │                   │
│                         │      transparent body mask      │                   │
│                         └────────────────────────────────┘                   │
│                                                                              │
│ left event banners                                      charge/funny/story   │
│                                                                              │
│ bottom nav / Gal                                                   chat      │
└──────────────────────────────────────────────────────────────────────────────┘
                         click 互動 / btnEye
                                │
                                ▼
wallpaper_focus / focus_idle
┌──────────────────────────────────────────────────────────────────────────────┐
│ [transparent return hotzone 96x96]                                           │
│                                                                              │
│                         @WallpaperPanel fullscreen                           │
│                 ┌──────────── irole 957.5x750 ────────────┐                 │
│                 │                                          │                 │
│                 │  role/spBg → spHero → spFg → imgMask     │                 │
│                 │                                          │                 │
│                 │        ┌─ irole/btn touch 418.2x804.2 ─┐ │                 │
│                 │        │ click role: speech + voice     │ │                 │
│                 │        └────────────────────────────────┘ │                 │
│                 └──────────────────────────────────────────┘                 │
│                                                                              │
│ full-screen transparent body mask: blank click => ActivateCtlBar(true, 5)     │
└──────────────────────────────────────────────────────────────────────────────┘

focus_ctl after blank/control click
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│                         irole remains interactive                            │
│                                                                              │
│                         pnlCtl center pos(0,-181)                            │
│                              ┌───────┐                                       │
│                       ┌──────┤ play/ ├──────┐                                │
│                       │ left │ pause │ right│                                │
│                       │92x50 │ 68x68 │92x50 │                                │
│                       └──────┴───────┴──────┘                                │
│                                                                              │
│ left/right: cycle selected_hero_id   play/pause: wallpaper_auto_play          │
│ any pnlCtl click refreshes 5s auto-hide                                       │
└──────────────────────────────────────────────────────────────────────────────┘

focus_speak after role touch
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│                         irole stays focused                                  │
│                    ┌──── imgSpeak hero_img_219 668x154 ────┐                │
│                    │              touch line text            │                │
│                    └─────────────────────────────────────────┘                │
│                                                                              │
│ speech auto hides after short local feedback; no return to main UI            │
└──────────────────────────────────────────────────────────────────────────────┘
```
