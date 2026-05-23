# LoadingView Layout Analysis

**Date**: 2026-05-23
**Source Prefab**: `Assets/Game/RawAssets/Prefabs/UI/Login/LoadingView.prefab`
**Bundle File**: `3eda611616b92cfdb2af7f8c183b1e50/__data`
**Analysis Type**: Deep Layout + IL Lifecycle Analysis

---

## 1. Basic Information

| Property | Value |
|---|---|
| Node Count | 9 |
| Total Components | 24 (AssetBundle: 1, CanvasRenderer: 6, GameObject: 9, MonoBehaviour: 7, MonoScript: 4, RectTransform: 9) |
| Source Bundle | `yoo/Default/UnpackBundleFiles/3e/3eda611616b92cfdb2af7f8c183b1e50/__data` |
| Root GameObject | LoadingView (active=true) |
| UI Layer | 5 (LoadingView, imgBg, txtPercent), 0 (sldSpeed children) |
| Base Class | `ViewBehaviour` (IL: `.ctor()` calls `ViewBehaviour::.ctor()`) |

### Note: Combined IL File

The IL file for LoadingView also contains a second type: `PreloadingView`. This is a separate prefab at `Prefab/PreLoadingView` loaded via `Resources.Load` and instantiated into the `2dUICanvas` scene. It has its own `processTxt`, `processSlider` fields and a `Create()` factory method. The actual LoadingView is the main loading screen shown during the login-to-main transition.

### Node Inventory

| # | Node Name | Active | Parent | Components |
|---|---|---|---|---|
| 1 | LoadingView | true | (root) | RectTransform, CanvasRenderer, MonoBehaviour |
| 2 | imgBg | true | LoadingView | RectTransform, CanvasRenderer, MonoBehaviour |
| 3 | txtPercent | true | LoadingView | RectTransform, CanvasRenderer, MonoBehaviour |
| 4 | sldSpeed | true | LoadingView | RectTransform, MonoBehaviour |
| 5 | Background | true | sldSpeed | RectTransform, CanvasRenderer, MonoBehaviour |
| 6 | Fill Area | true | sldSpeed | RectTransform |
| 7 | Fill | true | Fill Area | RectTransform, CanvasRenderer, MonoBehaviour |
| 8 | Handle Slide Area | true | sldSpeed | RectTransform |
| 9 | Handle | true | Handle Slide Area | RectTransform, CanvasRenderer, MonoBehaviour |

---

## 2. Complete RectTransform Tree

```
LoadingView [ROOT]
  anchorMin=(0,0)  anchorMax=(1,1)  pivot=(0.5,0.5)
  sizeDelta=(0,0)  anchoredPosition=(0,0)
  localScale=(1, 1, 1)
  active=true
  Components: RectTransform + CanvasRenderer + MonoBehaviour
  |
  +-- imgBg [child 0]
  |     anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)  pivot=(0.5,0.5)
  |     sizeDelta=(1670, 750)  anchoredPosition=(0,0)
  |     localScale=(1, 1, 1)  active=true
  |     NOTE: Centered background image (same dimensions as LoginView.imgBg)
  |
  +-- txtPercent [child 1]
  |     anchorMin=(1, 0.5)  anchorMax=(1, 0.5)  pivot=(0.5,0.5)
  |     sizeDelta=(123, 37)  anchoredPosition=(-11.39, -355.03)
  |     localScale=(1.00017, 1.00017, 1.00017)  active=true
  |     NOTE: Percentage text, right-anchored, positioned near the slider
  |     NOTE: Anchor (1, 0.5) means positioned relative to right-center of parent
  |
  +-- sldSpeed [child 2]
        anchorMin=(0, 0.5)  anchorMax=(1, 0.5)  pivot=(0.5,0.5)
        sizeDelta=(-181.07, 34)  anchoredPosition=(3.96, -356.8)
        localScale=(1.00019, 1.00019, 1.00019)  active=true
        NOTE: Horizontal slider, stretched full-width with margins
        NOTE: SizeDelta -181.07 means width = parentWidth - 181.07 (margins)
        |
        +-- Background [child 0]
        |     anchorMin=(0, 0.5)  anchorMax=(1, 0.5)  pivot=(0.5,0.5)
        |     sizeDelta=(0, 34)  anchoredPosition=(0,0)
        |     localScale=(1, 1, 1)  active=true
        |     NOTE: Slider track background, full-width, 34px height
        |
        +-- Fill Area [child 1]
        |     anchorMin=(0, 0)  anchorMax=(1, 1)  pivot=(0.5,0.5)
        |     sizeDelta=(0, 0)  anchoredPosition=(0,0)
        |     localScale=(1, 1, 1)  active=true
        |     NOTE: Container for the fill rect (stretches to sldSpeed bounds)
        |     |
        |     +-- Fill [grandchild 0]
        |           anchorMin=(0, 0)  anchorMax=(0, 0)  pivot=(0.5,0.5)
        |           sizeDelta=(0, 0)  anchoredPosition=(0,0)
        |           localScale=(1, 1, 1)  active=true
        |           NOTE: Slider fill graphic (controlled by Slider.value)
        |           NOTE: AnchorMax=(0,0) means fill is driven by Slider component internally
        |
        +-- Handle Slide Area [child 2]
              anchorMin=(0, 0)  anchorMax=(1, 1)  pivot=(0.5,0.5)
              sizeDelta=(0, 0)  anchoredPosition=(0,0)
              localScale=(0.9998, 0.9998, 0.9998)  active=true
              NOTE: Container for the handle (stretches to sldSpeed bounds)
              |
              +-- Handle [grandchild 0]
                    anchorMin=(0, 0)  anchorMax=(0, 0)  pivot=(0, 0.55)
                    sizeDelta=(82, 82)  anchoredPosition=(-40.99, 4.1)
                    localScale=(1, 1, 1)  active=true
                    NOTE: Slider handle/thumb (82x82px), pivot offset for visual centering
```

---

## 3. Component Type Distribution

| Component Type | Count | Nodes |
|---|---|---|
| RectTransform | 9 | All 9 nodes |
| MonoBehaviour | 7 | LoadingView, imgBg, txtPercent, sldSpeed, Background, Fill, Handle |
| CanvasRenderer | 6 | LoadingView, imgBg, txtPercent, Background, Fill, Handle |
| GameObject | 9 | All 9 nodes (implicit) |
| MonoScript | 4 | Unique script types |

### Key Components Breakdown

| Node | Component Types | Purpose |
|---|---|---|
| LoadingView | RectTransform, CanvasRenderer, MonoBehaviour | Root view controller |
| imgBg | RectTransform, CanvasRenderer, MonoBehaviour (Image) | Background image |
| txtPercent | RectTransform, CanvasRenderer, MonoBehaviour (Text) | Progress percentage display |
| sldSpeed | RectTransform, MonoBehaviour (Slider) | Progress bar (Slider component) |
| Background | RectTransform, CanvasRenderer, MonoBehaviour (Image) | Slider track background image |
| Fill | RectTransform, CanvasRenderer, MonoBehaviour (Image) | Slider fill image |
| Handle | RectTransform, CanvasRenderer, MonoBehaviour (Image) | Slider handle/thumb image |

### Slider Structure Analysis

The `sldSpeed` node is a Unity UI Slider with standard sub-structure:
- **Background**: The full-length track image (34px tall)
- **Fill Area**: Container for the fill rectangle
- **Fill**: The actual fill graphic (driven by Slider.value)
- **Handle Slide Area**: Container for the handle/thumb
- **Handle**: The draggable thumb (82x82px)

The Slider is positioned near the bottom of the screen (y = -356.8) and spans horizontally with margins (-181.07 on each side, effectively ~1099px wide on a 1280px target).

---

## 4. Prefab Instances and Panel Naming

- **No `@prefab` prefixed nodes** -- This prefab contains no nested prefab instances
- Naming convention: Functional English names
  - `imgBg` -- Background image
  - `txtPercent` -- Percentage text
  - `sldSpeed` -- Progress slider
  - Standard Unity Slider structure: `Background`, `Fill Area`, `Fill`, `Handle Slide Area`, `Handle`

---

## 5. IL Lifecycle Methods

### Fields

```
PrefabName : System.String            -- Prefab identifier (not used in IL directly)
imgBg      : UnityEngine.UI.Image     -- Background image
txtPercent : UnityEngine.UI.Text      -- Percentage text display
sldSpeed   : UnityEngine.UI.Slider    -- Progress bar slider
_pos       : System.Int32             -- Internal position counter (0-100+)
```

### .ctor()

Standard constructor calling base class:
```
IL_0000-IL_0006: ViewBehaviour::.ctor()
```

### Awake()

```
IL_0000-IL_002a:
  var picName = GameHelper.FixHarmoniousPic("6")
  if (!string.IsNullOrEmpty(picName)) {
      imgBg.SetSpriteAsync(AssetsHelper.LoadSpriteFromBackground(picName), false).Forget()
  }
```

The `Awake()` method loads a "harmonious" (possibly censored/filtered) background image with index "6" using the `GameHelper.FixHarmoniousPic()` function. The image is loaded asynchronously via `AssetsHelper.LoadSpriteFromBackground()` and applied to `imgBg` using `SetSpriteAsync()`, then forgotten (fire-and-forget UniTask).

Key observations:
- Uses `Cysharp.Threading.Tasks` for async sprite loading
- `FixHarmoniousPic("6")` suggests the game has a system for selecting region-appropriate artwork (possibly age-rating or cultural compliance)
- The sprite loading is non-critical -- if it fails, the background simply doesn't update

### OnOpen(System.Object parameter)

```
IL_0000-IL_0015:
  InvokeRepeating("UpdateProcess", 0, 0.005)
```

Starts a repeating invocation of `UpdateProcess` every 0.005 seconds (200 times per second) with no initial delay (0 seconds start delay).

This creates a rapid progress increment animation.

### UpdateProcess()

```
IL_0000-IL_007e:
  txtPercent.text = string.Format("{0}%", _pos)
  _pos++  // Post-increment
  sldSpeed.value = (float)_pos

  if (_pos > 100) {
      CancelInvoke("UpdateProcess")
      GameHelper.LoadMainScene(LoadingView.<>c.<UpdateProcess>b__7_0).Forget()
  }
```

This is the core progress animation method, invoked 200 times per second:

1. **Updates the percentage text**: Sets `txtPercent.text = "{0}%"` with the current `_pos` value
2. **Increments position**: `_pos++` (post-increment, so the displayed value is one step behind)
3. **Updates the slider**: `sldSpeed.value = (float)_pos` -- drives the progress bar
4. **Checks for completion**: When `_pos > 100`:
   - Stops the repeating invocation: `CancelInvoke("UpdateProcess")`
   - Loads the main scene: `GameHelper.LoadMainScene(callback).Forget()`

Since `UpdateProcess` runs every 0.005s, it takes approximately 0.505 seconds to go from _pos=0 to _pos=101 (when the condition triggers). This creates a rapid fake progress animation that fills from 0% to 100% in about half a second. It is NOT connected to actual loading progress -- it is purely visual.

### b__7_0 (LoadMainScene callback)

This is a compiler-generated static callback (`<>c.<UpdateProcess>b__7_0`). The IL in the LoadingView file does not contain the callback body (it is in a separate compiler-generated class), but from the context it is passed to `GameHelper.LoadMainScene()` which presumably handles the scene transition.

### PreloadingView (Separate Class in Same IL File)

The IL file also contains `PreloadingView`, a different loading screen:

```
TYPE PreloadingView
  FIELD processTxt : UnityEngine.UI.Text
  FIELD processSlider : UnityEngine.UI.Slider
```

**SetProcess(float value)**:
```
processTxt.text = value.ToString() + "%"
processSlider.value = value
```

**Create()** (factory method):
```
var go = Instantiate(Resources.Load<GameObject>("Prefab/PreLoadingView"))
go.transform.SetParent(GameObject.Find("2dUICanvas").transform, false)
return go.GetComponent<PreloadingView>()
```

Key differences from LoadingView:
- PreloadingView uses `Resources.Load` (not a prefab reference) to instantiate itself
- PreloadingView has an explicit `SetProcess(value)` that takes external progress values (not self-animated)
- PreloadingView is parented to a scene object called "2dUICanvas"
- LoadingView's `UpdateProcess` is a fake self-animated progress, while PreloadingView's `SetProcess` receives real progress from external systems

This suggests two different loading scenarios:
1. **PreloadingView** -- Shown during initial asset/resource preloading, driven by actual loading progress events
2. **LoadingView** -- Shown during the login-to-main transition, with a quick fake animation before loading the main scene

---

## 6. Red Dot Keys

**No red dot keys found** in this prefab. The LoadingView is a transitional loading screen with no notification indicators.

The background image key "6" (passed to `GameHelper.FixHarmoniousPic`) may be related to a content filtering/regional compliance system rather than a red dot feature.

---

## 7. Comparison with Godot MVP Implementation

### Original (Unity/C#) Behavior

The LoadingView is a transitional loading screen:
1. **Awake()**: Loads a background image asynchronously using the harmonious picture system (key "6")
2. **OnOpen()**: Starts `UpdateProcess` repeating every 0.005s (no initial delay)
3. **UpdateProcess()**: Self-animates from 0% to 100% in ~0.5 seconds, updating text and slider
4. **Completion**: When _pos exceeds 100, cancels the invoke and calls `GameHelper.LoadMainScene()`

Key characteristics:
- **Fake progress**: The progress is self-animated, not connected to actual loading
- **Rapid animation**: 200 Hz update rate for smooth slider animation
- **Auto-transition**: Automatically proceeds to main scene after ~0.5 seconds (user can't interrupt)
- **Background loading**: Background image loads asynchronously and may appear after the view is already visible

### Godot MVP (`show_loading()` in startup_screen.gd)

```gdscript
func show_loading() -> void:
    app.current_view = "loading"
    app._set_chrome_visible(false)
    app._clear("载入")
    app.content.position = Vector2(0, 0)
    app.content.size = Vector2(1280, 720)

    # Background
    app._draw_image(UI_LOGIN_BG, Vector2(-195, -4), Vector2(1670, 728), true, Color(1, 1, 1, 0.92))
    app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.014, 0.018, 0.16)))

    # Loading info text
    var info = app._label("正在进入主城", 22, HORIZONTAL_ALIGNMENT_CENTER)
    info.position = Vector2(340, 550)
    info.size = Vector2(600, 36)
    app.content.add_child(info)

    # Tip text
    var tip = app._label("提示：喚灵可获得新武将，重复武将将转换为碎片。", 16, HORIZONTAL_ALIGNMENT_CENTER)
    tip.position = Vector2(290, 596)
    tip.size = Vector2(700, 30)
    tip.modulate = Color(0.7, 0.66, 0.6)
    app.content.add_child(tip)

    # Static progress bar
    var slider_y = 624
    var slider_margin = 90
    app._draw_progress_bar(Vector2(slider_margin, slider_y), Vector2(1280 - slider_margin * 2, 22), 0.88)

    # Static percentage
    var pct = app._label("88%", 20, HORIZONTAL_ALIGNMENT_RIGHT)
    pct.position = Vector2(1280 - slider_margin + 12, slider_y - 20)
    pct.size = Vector2(60, 28)
    app.content.add_child(pct)

    # Explicit "enter" button
    app._add_action_button("进入", Vector2(574, 664), app._enter_main_scene, Vector2(132, 38))
```

### Key Differences

| Aspect | Original Unity | Godot MVP | Status |
|---|---|---|---|
| Progress animation | Auto-animated (0.005s interval, ~0.5s total) | Static (88% fixed) | MISSING |
| Auto-transition | Automatic after ~0.5s | Manual (must press "enter") | DIFFERENT |
| Background | Async loaded via FixHarmoniousPic("6") | Same login background image | PARTIAL |
| Progress display | Text + Slider (both animated) | Static label (88%) + static progress bar | MISSING (animation) |
| Slider structure | Full Unity Slider (Background, Fill, Handle) | Simple colored rectangle | PARTIAL |
| Info text | None (just percentage) | "正在进入主城" + tip text | ADDED (MVP extra) |
| User interaction | None (passive) | "进入" button (active) | DIFFERENT |
| Viewport | Adapts to screen via anchors | Fixed 1280x720 layout | DIFFERENT |

---

## 8. Improvement Suggestions

### For Godot MVP

1. **Add auto-transition**: The original LoadingView auto-transitions to the main scene after ~0.5s. The MVP requires a button press. Add an auto-timer (e.g., 3 seconds) to mimic the original passive experience, while keeping the button as a skip option.

2. **Implement animated progress**: The original has a 200 Hz self-animating progress bar from 0% to 100%. This can be replicated with a simple `Tween` or `_process` based animation on the progress bar value.

3. **Different background image**: The original uses `FixHarmoniousPic("6")` which may produce a different background than the login screen. The MVP reuses `UI_LOGIN_BG` which is from LoginView. Consider differentiating the loading background.

4. **Match the slider layout**: The original slider is at y = -356.8 (from center), approximately 3.2px above the bottom at 720px height. The MVP slider at y = 624 (from top) corresponds roughly to y = -96 from center. The original slider is significantly lower on screen.

5. **Keep the game tip**: The MVP adds a helpful tip line ("唤起可获得新武将...") that does not exist in the original. This is a good UX addition and should be kept, especially since the original simply auto-transitions without any user engagement.

6. **Add slider handle**: The original has an 82x82px handle/thumb on the slider. The MVP uses a simple colored rectangle. Adding a handle would improve visual authenticity.

### For PreloadingView Consideration

The separate `PreloadingView` class in the same IL file should also be considered for the MVP. It represents the pre-loading screen that shows before the LoginView, driven by actual asset loading progress. The Godot MVP's `show_preloading()` function corresponds to this (`PreloadingView`), not the `LoadingView`. The current MVP correctly shows a progress-driven loading screen in `show_preloading()`, which aligns with the `PreloadingView` pattern.

### Architecture Notes

- `GameHelper.FixHarmoniousPic(index)` -- A content filtering system that selects appropriate background art based on regional/harmonization rules
- `AssetsHelper.LoadSpriteFromBackground(picName)` -- Asynchronous sprite loading from the background assets pool
- `ExtensionMethod.SetSpriteAsync(image, spriteTask, preserveAspect)` -- Unity extension for async sprite assignment with aspect ratio options
- `GameHelper.LoadMainScene(callback)` -- Transitions to the main game scene with a callback pattern

---

## Summary

LoadingView is a **simple 9-node loading/transition screen** with:

1. **Root**: LoadingView (full-screen, inherits ViewBehaviour)
2. **Background**: imgBg (1670x750, asynchronously loaded via FixHarmoniousPic)
3. **Progress display**: txtPercent (right-anchored text) + sldSpeed (Unity Slider with 5 child nodes)
4. **Lifecycle**:
   - `Awake()` -- Async load background image
   - `OnOpen()` -- Start InvokeRepeating("UpdateProcess", 0, 0.005)
   - `UpdateProcess()` -- Self-animate 0%-100% in ~0.5s, then LoadMainScene
5. **Il file also contains PreloadingView** -- A separate class with different behavior (externally driven progress, Resources.Load instantiation)

The LoadingView is a **passive transition screen** -- the player does not interact with it. It shows a quick fake progress animation and automatically moves to the main scene. It is NOT connected to actual asset loading; that responsibility falls to `PreloadingView` which is used earlier in the startup flow.

The Godot MVP makes the screen interactive (adds a "进入" button and game tips) and shows a static 88% progress bar. The MVP's `show_preloading()` function actually corresponds more closely to the original `PreloadingView` behavior (externally driven progress), while `show_loading()` corresponds to `LoadingView` but with manual transition instead of automatic.
