# LaunchView Layout Analysis

**Date**: 2026-05-23
**Source Prefab**: `Assets/Game/RawAssets/Prefabs/UI/Launch/LaunchView.prefab`
**Bundle File**: `02f333e981e168e801ed39cad54a6f17/__data`
**Analysis Type**: Deep Layout + IL Lifecycle Analysis

---

## 1. Basic Information

| Property | Value |
|---|---|
| Node Count | 4 |
| Total Components | 12 (AssetBundle: 1, CanvasRenderer: 2, GameObject: 4, MonoBehaviour: 3, MonoScript: 3, RectTransform: 4, VideoPlayer: 1) |
| Source Bundle | `yoo/Default/BundleFiles/02/02f333e981e168e801ed39cad54a6f17/__data` |
| Root GameObject | LaunchView (active=true) |
| UI Layer | 5 (Unity UI layer) |
| Base Class | `ViewBehaviour` (IL: `.ctor()` calls `ViewBehaviour::.ctor()`) |

### Node Inventory

| # | Node Name | Active | Parent | Components |
|---|---|---|---|---|
| 1 | LaunchView | true | (root) | RectTransform, MonoBehaviour |
| 2 | Image | true | LaunchView | RectTransform, CanvasRenderer, MonoBehaviour |
| 3 | RawImage | true | LaunchView | RectTransform, CanvasRenderer, MonoBehaviour |
| 4 | video | true | LaunchView | RectTransform, VideoPlayer |

---

## 2. Complete RectTransform Tree

```
LaunchView [ROOT]
  anchorMin=(0,0)  anchorMax=(1,1)  pivot=(0.5,0.5)
  sizeDelta=(0,0)  anchoredPosition=(0,0)
  localScale=(1, 1, 1)
  active=true
  |
  +-- Image [child 0]
  |     anchorMin=(0,0)  anchorMax=(1,1)  pivot=(0.5,0.5)
  |     sizeDelta=(0,0)  anchoredPosition=(0,0)
  |     localScale=(1, 1, 1)
  |     active=true
  |     NOTE: Full-screen stretched image (fills entire parent)
  |
  +-- RawImage [child 1]
  |     anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)  pivot=(0.5,0.5)
  |     sizeDelta=(1680, 1680)  anchoredPosition=(0,0)
  |     localScale=(0.99997, 0.99997, 0.99997)
  |     active=true
  |     NOTE: Large square (1680x1680) centered, nearly identity scale
  |     NOTE: Nearly identity scale suggests a deliberate rounding adjustment
  |
  +-- video [child 2]
        anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)  pivot=(0.5,0.5)
        sizeDelta=(100, 100)  anchoredPosition=(0,0)
        localScale=(0.99997, 0.99997, 0.99997)
        active=true
        NOTE: Small placeholder (100x100) centered, actual rendering goes to RenderTexture
        NOTE: This node exists but video is output to the RawImage via RenderTexture
```

### Anchor Pattern Analysis

- **LaunchView**: Full-screen (0,0)-(1,1) -- standard full-screen overlay panel
- **Image**: Full-screen stretch -- serves as a full-size background image
- **RawImage**: Center-anchored (0.5,0.5) with fixed 1680x1680 size -- the actual video display area
- **video**: Center-anchored (0.5,0.5) with nominal 100x100 size -- VideoPlayer component host node

---

## 3. Component Type Distribution

| Component Type | Count | Nodes |
|---|---|---|
| RectTransform | 4 | All 4 nodes |
| MonoBehaviour | 3 | LaunchView, Image, RawImage |
| CanvasRenderer | 2 | Image, RawImage |
| VideoPlayer | 1 | video |
| GameObject | 4 | All 4 nodes (implicit) |

### MonoBehaviour Scripts Identified

1. **LaunchView root MonoBehaviour** (pathId: 2899315633990140760) -- The `LaunchView` class itself
2. **Image MonoBehaviour** (pathId: -7893108989607345320) -- Possibly an Image component or decorative overlay
3. **RawImage MonoBehaviour** (pathId: -4519270250381769896) -- RawImage UI component for rendering video texture

---

## 4. Prefab Instances and Panel Naming

- **No `@prefab` prefixed nodes** -- This prefab contains no nested prefab instances
- Naming convention: English descriptive names -- `Image`, `RawImage`, `video`
- The prefab is relatively simple, functioning as a splash/launch video player with a background image overlay

---

## 5. IL Lifecycle Methods

### Fields

```
videoPlayer : UnityEngine.Video.VideoPlayer  -- Serialized field for the video node
rawImage    : UnityEngine.UI.RawImage        -- Serialized field for the RawImage node
m_finish    : UnityEngine.Events.UnityAction -- Callback invoked when video finishes or is skipped
```

### Awake()

The `Awake()` method is the most complex lifecycle method. It performs the following in order:

1. **Creates a RenderTexture**: 1670x1670 pixels, with mipmaps disabled, named "VideoRT"
   ```
   IL_0000-IL_000b: new RenderTexture(1670, 1670, 0)
   IL_0012-IL_0013: renderTexture.useMipMap = false
   IL_0019-IL_001e: renderTexture.name = "VideoRT"
   ```

2. **Assigns the RenderTexture to the RawImage**: Sets `rawImage.texture` to the newly created RenderTexture
   ```
   IL_0023-IL_002a: rawImage.texture = renderTexture
   ```

3. **Configures the VideoPlayer**:
   - Sets empty URL initially
   - Sets targetTexture to the RenderTexture
   - Sets isLooping to false
   ```
   IL_002f-IL_003a: videoPlayer.url = ""
   IL_003f-IL_0046: videoPlayer.targetTexture = renderTexture
   IL_0051-IL_0052: videoPlayer.isLooping = false
   ```

4. **Hides rawImage initially**: Sets rawImage.color to (1, 1, 1, 0) -- fully transparent white
   ```
   IL_0057-IL_0076: rawImage.color = new Color(1, 1, 1, 0)
   ```

5. **Prepares the video**: Calls `videoPlayer.Prepare()`
   ```
   IL_0081: videoPlayer.Prepare()
   ```

6. **Resolves the actual video path**: Uses `FileUtils.FullPathForFilename("launch.mp4")` to get the full file path and assigns it to videoPlayer.url
   ```
   IL_008c-IL_009b: videoPlayer.url = FileUtils.Instance.FullPathForFilename("launch.mp4")
   ```

7. **Registers video event handlers**:
   - `loopPointReached` handler (`b__3_0`): When video finishes playing, invokes `m_finish` callback and destroys the view via `UIControl.Destroy(false, null)`
   - `prepareCompleted` handler (`b__3_1`): When video is ready, calls `videoPlayer.Play()` and schedules `ShowRawImage` after 0.1 seconds via `MonoBehaviour.Invoke("ShowRawImage", 0.1)`

### ShowRawImage()

A public method that reveals the video texture:
1. Activates the RawImage GameObject: `rawImage.SetActive(true)`
2. Sets rawImage.color to white fully opaque: `new Color(1, 1, 1, 1)`

### OnOpen(System.Object parameter)

Stores the callback parameter for use when the video finishes:
```
IL_0000-IL_0007: m_finish = (UnityAction)parameter
```

This allows the caller (typically `show_launch` logic) to pass a completion callback.

### b__3_0 (loopPointReached handler)

When the video reaches its end (loop point even though looping is disabled):
1. If `m_finish` is not null, invokes the callback: `m_finish.Invoke()`
2. Destroys the view: `UIControl.Destroy(false, null)`

### b__3_1 (prepareCompleted handler)

When the video is ready to play:
1. Starts playback: `videoPlayer.Play()`
2. Schedules `ShowRawImage` after 0.1 seconds: `MonoBehaviour.Invoke("ShowRawImage", 0.1)`

This 0.1s delay prevents a flash of the initial video frame before playback actually starts.

### .ctor()

Standard constructor calling base class: `ViewBehaviour::.ctor()`

---

## 6. Red Dot Keys

**No red dot keys found** in this prefab. The LaunchView is purely a video splash screen with no notification indicators.

---

## 7. Comparison with Godot MVP Implementation

### Original (Unity/C#) Behavior

1. On creation, creates a 1670x1670 RenderTexture
2. Loads `launch.mp4` from file system
3. Prepares and plays the video on the VideoPlayer
4. Video renders into the RenderTexture, which is assigned to RawImage
5. RawImage starts transparent, becomes visible 0.1s after video starts
6. When video finishes (loopPointReached), invokes the `m_finish` callback and self-destructs

### Godot MVP (`show_launch()` in startup_screen.gd)

```gdscript
func show_launch() -> void:
    app.current_view = "launch"
    app._set_chrome_visible(false)
    app._clear("启动")
    app.content.position = Vector2(0, 0)
    app.content.size = Vector2(1280, 720)

    # No VideoPlayer -- substitutes with colored panels
    app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.0, 0.0, 0.0, 1.0)))
    app.content.add_child(app._panel(Vector2(-200, -120), Vector2(1680, 1680), Color(0.05, 0.032, 0.026, 0.38)))

    # Skip hint
    var hint = app._label("点击跳过", 18, HORIZONTAL_ALIGNMENT_CENTER)
    hint.position = Vector2(520, 650)
    hint.size = Vector2(240, 34)
    hint.modulate = Color(0.86, 0.80, 0.70, 1.0)
    app.content.add_child(hint)
    app._add_action_button("跳过", Vector2(1128, 32), app._show_preloading, Vector2(104, 40))
```

### Key Differences

| Aspect | Original Unity | Godot MVP | Status |
|---|---|---|---|
| Video playback | Yes (VideoPlayer + RenderTexture -> RawImage) | No (static colored panels) | MISSING |
| Background | Image (full-screen) | Black panel (1280x720) + dark brown panel (1680x1680) | PARTIAL |
| Skip mechanism | Implicit via video finish callback | Explicit "skip" button | DIFFERENT |
| Viewport size | 1670x1670 RenderTexture (tall phone) | 1280x720 (landscape) | CHANGED |
| RawImage visibility | Delayed 0.1s after prepare to avoid flash | N/A (no video) | N/A |
| Auto-destruction | Self-destructs after video finishes | Must click "skip" button | DIFFERENT |

---

## 8. Improvement Suggestions

### For Godot MVP

1. **Integrate VideoPlayer**: Godot has a built-in `VideoStreamPlayer` node. Could load `launch.mp4` for an authentic splash experience. However, in a test/MVP context, the static panel is acceptable.

2. **Maintain the auto-transition pattern**: The original auto-transitions after video finishes via `m_finish` callback. Consider adding a timer-based auto-transition (e.g., 3 seconds auto-skip) to simulate this behavior.

3. **Match viewport proportions**: The original uses 1670x1670 (1:1 aspect ratio) for the video area. MVP uses 1280x720 (16:9). The centered 1680x1680 dark panel at offset (-200, -120) somewhat mimics the original large render texture but could be sized more appropriately.

4. **Preserve the RawImage preview delay pattern**: In a real implementation with video, the 0.1s delay before showing the RawImage prevents a first-frame glitch. This subtle UX pattern should be documented for future video integration.

### Documentation Notes

- The `launch.mp4` file is resolved through `Scx.FileUtils.FullPathForFilename()`, suggesting it reads from the streaming assets or persistent data path.
- The VideoPlayer URL is set twice: first to empty string (during Prepare), then to the actual file path. This is because `Prepare()` requires a valid URL to be set before it can start. The initial empty string may be for initialization.

---

## Summary

LaunchView is a **single-purpose video splash screen** with 4 nodes. Its lifecycle is:
1. `Awake()` -- Create RenderTexture, configure VideoPlayer, hide RawImage, register event handlers
2. `prepareCompleted` -- Play video, delay-show RawImage after 0.1s
3. `loopPointReached` -- Invoke callback, self-destruct
4. `OnOpen(callback)` -- Store completion callback from caller

The Godot MVP replaces actual video playback with static colored panels and an explicit "skip" button. This is functional for testing but loses the cinematic splash experience.
