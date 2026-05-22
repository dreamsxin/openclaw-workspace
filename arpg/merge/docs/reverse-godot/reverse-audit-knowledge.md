# Reverse Audit Knowledge

This document records low-level reverse-engineering facts that are easy to forget and should be checked during manual audit. It is intentionally concrete: paths, byte patterns, source priority, and known failure modes.

## Unity TextAsset Wrapping

AssetStudio `TextAsset` exports in this project often use `.dat` files that are not the original payload. They can contain a Unity/TextAsset-style wrapper:

```text
uint32_le name_length
ascii/utf8 name_without_original_extension_suffix
00 00
uint32_le payload_length
payload bytes
00 00
```

Observed sample:

| File | Wrapped path | Raw path | Wrapped bytes | Raw bytes | Payload offset |
| --- | --- | --- | ---: | ---: | ---: |
| `Ch_Maid01_Basic01_SD.skel` | `godot-project/assets/characters/maid_base/Ch_Maid01_Basic01_SD.skel.dat` | `reverse-output/assets/assetripper-primary/Assets/TextAsset/Ch_Maid01_Basic01_SD.skel.bytes` | 78,948 | 78,910 | 36 |
| `Ch_Maid01_Basic01_SD.atlas` | `godot-project/assets/characters/maid_base/Ch_Maid01_Basic01_SD.atlas.dat` | `reverse-output/assets/assetripper-primary/Assets/TextAsset/Ch_Maid01_Basic01_SD.atlas.bytes` | 1,488 | 1,450 | 36 |

Example wrapped `.skel.dat` header:

```text
19 00 00 00
43 68 5f 4d 61 69 64 30 31 5f 42 61 73 69 63 30 31 5f 53 44 2e 73 6b 65 6c
00 00
3e 34 01 00
```

Meaning:

| Bytes | Meaning |
| --- | --- |
| `19 00 00 00` | name length = 25 |
| `Ch_Maid01_Basic01_SD.skel` | embedded TextAsset name |
| `00 00` | separator/padding |
| `3e 34 01 00` | payload length = `0x0001343e` = 78,910 |
| next byte `f1` | first byte of raw Spine binary payload |

Audit rules:

- Do not feed committed `.skel.dat` or `.atlas.dat` directly to `spine-core`.
- Prefer AssetRipper raw files under `reverse-output/assets/assetripper-primary/Assets/TextAsset/*.bytes`.
- If unwrapping `.dat` manually, validate both payload length and a long payload prefix. For `.atlas`, the raw payload starts with the page filename, so a short prefix can falsely match inside the wrapper name.
- If `wrapped_length - raw_length == 38`, the sample wrapper shape above is likely present: 36-byte prefix plus trailing `00 00`.

## Spine Source Priority

For Spine skeleton and atlas recovery, use this source order:

1. `reverse-output/assets/assetripper-primary/Assets/TextAsset/*.skel.bytes` and `*.atlas.bytes`
2. `reverse-output/assets/assetripper-main/ExportedProject/Assets/TextAsset/*`
3. UABEA export if AssetRipper and AssetStudio disagree
4. AssetStudio `.dat` only after wrapper detection/unwrapping

Reason:

- AssetRipper raw `.bytes` files are parseable as source-like TextAsset payloads.
- AssetStudio `TextAsset` `.dat` files may be wrapped.
- AssetStudio logged TextAsset export errors for several Spine/atlas/transform names, but AssetRipper primary recovered all 92 failed names checked on 2026-05-21.

## Spine Atlas Page Versus Sprite Crop

A Spine atlas page PNG is not the same thing as a Unity Sprite export.

Observed failure:

- `Ch_Customer01_SD.atlas.bytes` declares `size:512,512`.
- The earlier committed `godot-project/assets/characters/customer/Ch_Customer01_SD.png` was a Sprite crop of `318x490`.
- Godot rendered the skeleton with correct vertices but sampled UVs from the wrong image coordinates, producing disassembled or offset body parts.

Correct rule:

- Spine atlas pages must come from full `Texture2D` exports, usually `reverse-output/assets/assetripper-primary/Assets/Texture2D/<page>.png`.
- Sprite exports are cropped and may be useful as static portraits, but they are invalid for Spine UV rendering.
- Before baking or rendering, compare each atlas `size:W,H` with the PNG header size.
- Use `scripts/reverse/sync_character_atlas_pages.mjs` to replace mismatched Godot character atlas pages from AssetRipper `Texture2D`.

Current fixed state:

- `sync_character_atlas_pages.mjs` replaced 18 mismatched atlas pages.
- The latest atlas-size audit reports zero mismatches for committed character Spine pages.

## Spine Skin Selection

Many character skeletons include animation-specific skins:

```text
default
01 Idle
03 Interaction
03 Interactive
Idle
Happy
Angry
...
```

If a clip is baked with the wrong skin:

- face, eye, mouth, eyebrow, and expression attachments may be missing;
- some attachments may use default-state geometry while the animation expects an expression-specific mesh;
- the result can look like misplaced or incomplete body parts even when UVs are correct.

Current bake rule in `scripts/reverse/bake_character_spine_previews.mjs`:

- exact skin match first, such as animation `01 Idle` -> skin `01 Idle`;
- normalized semantic aliases next, such as `Interaction` -> `interactive/interaction`, `Surp` -> `surprise`, `Sig` -> `signature`;
- fallback to `default`.

Audit clue:

- In the fixed bake, `Ch_Customer01_SD` `01 Idle` uses skin `01 Idle` and has 28 attachments; the old default-skin bake had 19 attachments.

## Godot Spine Polygon Rendering

The baked Spine preview renderer uses world vertices and normalized UVs produced by `@esotericsoftware/spine-core`.

Rules:

- Flip Y when mapping Spine world coordinates into Godot canvas coordinates.
- Pass UVs directly to `draw_polygon`; they are normalized `0..1`.
- Do not multiply UVs by texture size. That caused `UISceneLoading` to render as a blank/progress-only screen.
- Keep draw order from `skeleton.drawOrder`.
- Use mesh triangles exactly as emitted by Spine runtime.

Relevant files:

- `godot-project/scripts/spine_baked_preview_canvas.gd`
- `godot-project/scripts/scene_loading_reference_screen.gd`
- `scripts/reverse/bake_character_spine_previews.mjs`
- `scripts/reverse/bake_kokomi_loading_spine.mjs`

## Character Spine Known Exceptions

`Ch_Maid02_Basic01_SD` still fails the current character preview bake:

```text
Region not found in atlas: leg_L _under (mesh attachment: leg_L _under)
```

Audit path:

1. Compare `assetripper-primary` and `assetripper-main` TextAsset/Texture2D output.
2. Check whether UABEA exposes an alternate atlas page or bundled variant.
3. Search for region spelling variants or a companion atlas page.
4. Do not hide this failure by substituting static art; keep it listed in `character_spine_browser.json.failures`.

## Validation Commands

Regenerate and verify character Spine previews:

```powershell
node .\scripts\reverse\sync_character_atlas_pages.mjs
node .\scripts\reverse\bake_character_spine_previews.mjs --fps=8 --max-duration=0.9 --max-clips=2
.\tools\Godot\Godot_console.exe --headless --import --path .\godot-project
.\capture-spine-browser.bat
```

Expected screenshot:

```text
reverse-output/spine-browser-captures/18-character-spine-browser.png
```

Manual pass criteria:

- Atlas-size mismatch count is zero.
- Character preview shows assembled bodies, not cropped atlas pieces.
- The selected clip metadata shows the intended animation and skin.
- `Ch_Maid02_Basic01_SD` remains the only known failed candidate until its missing atlas region is recovered.
