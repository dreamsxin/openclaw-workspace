# Launch Video Reverse Lookup And Godot Fix

Date: 2026-05-26

## Goal

Use the exported video list to return each video's owning prefab, then use `game_start.mp4` as the concrete case to improve the Godot MVP startup screen.

## Inputs

- Exported media manifest: `reverse-output/media-export/media-export-manifest.json`
- Video ownership CSV: `reverse-output/media-export/video-prefab-owners.csv`
- Video ownership JSON: `reverse-output/media-export/video-prefab-owners.json`
- Manifest asset index: `reverse-output/assets/manifest-parsed-py/manifest-parsed-assets.csv`
- Manifest bundle index: `reverse-output/assets/manifest-parsed-py/manifest-parsed-bundles.csv`
- Launch IL: `reverse-output/managed/Assembly-CSharp-ui-callgraph/LaunchView.il.txt`

## Reverse Lookup Result

`game_start.mp4` exports cleanly from:

`Assets/Game/RawAssets/Video/game_start.mp4`

The generated ownership table reports `ownerCount=0` for `game_start.mp4`. This is expected and should not be treated as a failed extraction. Startup video ownership is not expressed as a prefab dependency in the YooAsset manifest. `LaunchView` resolves the video at runtime by filename:

```text
FileUtils.FullPathForFilename("launch.mp4")
videoPlayer.url = resolved path
```

So the correct chain is:

```text
LaunchView prefab
  -> VideoPlayer node exists
  -> hotfix/runtime code asks FileUtils for launch.mp4
  -> exported manifest video equivalent is game_start.mp4
  -> Godot should wire it as startup video, not wait for a prefab dependency hit
```

## Lessons

1. A zero prefab owner count does not always mean an orphaned video. Startup, PV, and some guide videos can be filename or config driven.
2. Prefab dependency reverse lookup works best for resources serialized into prefab or prefab bundle dependencies. Runtime `VideoPlayer.url` paths need IL/config/static-table confirmation.
3. For media ownership reports, keep both columns:
   - `prefab-depend-list`: direct prefab asset dependency list match.
   - `bundle-depend-list`: prefab bundle reverse-depends on the media bundle.
4. `mp4` files exported from Unity are good source evidence, but Godot 4's built-in `VideoStreamPlayer` should use a Godot-supported stream. For this MVP, `game_start.mp4` was transcoded to Theora OGV.

## Godot Change

Added:

`standalone/godot-mvp/assets/video/game_start.ogv`

Updated:

- `standalone/godot-mvp/scripts/screens/startup_screen.gd`
  - `LaunchView` now tries `res://assets/video/game_start.ogv`.
  - If the video resource is missing or cannot load, it falls back to the previous black RawImage placeholder.
  - The video `finished` signal advances to login when still on the launch screen.
- `standalone/godot-mvp/scripts/main.gd`
  - Startup stage 0 now waits `15.8s`, matching the exported video duration, instead of the old `1.5s` placeholder.

## Verification

Commands run:

```powershell
python .\scripts\assets\map_exported_video_prefab_owners.py --repo-root .
.\Godot\Godot_console.exe --path .\standalone\godot-mvp --headless --quit
$env:SHAONV_MVP_START_VIEW='launch'
$env:SHAONV_MVP_CAPTURE='D:\work\openclaw-workspace\arpg\shaonv\tmp\screenshots\launch-game-start-video.png'
$env:SHAONV_MVP_CAPTURE_DELAY='1.5'
.\Godot\Godot_console.exe --path .\standalone\godot-mvp --scene res://scenes/main.tscn --rendering-method mobile --quit-after 120
```

Screenshot:

`tmp/screenshots/launch-game-start-video.png`

The screenshot was generated at `1280x720`, confirming the launch view renders after the video resource was added.
