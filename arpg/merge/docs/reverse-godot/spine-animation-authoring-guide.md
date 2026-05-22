# Spine Animation Authoring Guide

This guide is for rebuilding character animation assets in Godot-compatible form while keeping the original Unity/Spine asset rules auditable.

## Official References

- Spine getting started: `https://en.esotericsoftware.com/spine-getting-started`
- Spine animation workflow: `https://en.esotericsoftware.com/spine-animating`
- Keys and timelines: `https://esotericsoftware.com/spine-keys`
- Mesh attachments: `https://esotericsoftware.com/spine-meshes`
- Weights: `https://us.esotericsoftware.com/spine-weights`
- Skins: `https://en.esotericsoftware.com/spine-skins`
- Texture packing: `https://esotericsoftware.com/spine-texture-packer`
- Export: `https://esotericsoftware.com/spine-export`
- Runtime loading: `https://en.esotericsoftware.com/spine-loading-skeleton-data`

## Texture Preparation

Use layered source art. PSD is preferred.

Recommended layers:

- head, face base, hair back, hair front, body, skirt, upper arms, forearms, hands, thighs, calves, feet, accessories;
- separate expression layers: eye white, iris, eyelid, eyebrows, mouth, blush, sweat, tears;
- separate outfit layers for each costume or skin.

Rules:

- Keep overlap around joints. Arms, legs, neck, skirt, sleeves, and hair should extend under neighboring parts so rotation does not expose gaps.
- Do not crop parts too tightly. Mesh deformation needs spare pixels around edges.
- Keep stable naming. Slot/attachment names should stay consistent across base/costume variants.
- Use full atlas pages for Spine runtime rendering. Sprite crops are only valid for static thumbnails or portraits.
- Before using a PNG as an atlas page, compare `.atlas` `size:W,H` with the PNG header size.

## Skeleton Setup

Use `Setup` mode for the bind pose:

1. Import separated images.
2. Create the root, body, head, limb, hair, cloth, and accessory bones.
3. Assign slots in original draw order: back hair/accessories first, body and limbs next, face/hair front last.
4. Convert deforming parts to mesh attachments.
5. Add weights for soft deformation: hair, skirt, sleeves, jacket, cloth strips, ribbons.
6. Keep rigid parts as simple region or low-vertex mesh attachments.

Audit notes:

- Mesh triangles and UVs must be preserved exactly when baking to Godot.
- Runtime renderers must use the Spine draw order, not alphabetical slot order.
- Godot canvas rendering flips Spine Y coordinates.

## Skins And Expressions

Use skins for:

- costumes;
- expression sets;
- interaction state variants;
- event outfits;
- alternate accessories.

Project-specific lesson:

- Many recovered characters have skins such as `default`, `01 Idle`, `03 Interaction`, `03 Interactive`, `Idle`, `Happy`, and `Angry`.
- Baking an animation with the wrong skin can make eyes, mouth, eyebrows, or expression meshes look missing or offset.
- The current baker chooses exact animation-skin matches first, then normalized aliases, then `default`.

## Animation Clips

Minimum clips for restored UI screens:

- `Idle`: default loop.
- `Ready`: short ready/attention loop where present.
- `Interaction`: tap/talk interaction loop or one-shot.
- expression clips such as `Happy`, `Sad`, `Angry`, `Surprise`, `Sigh` when the UI references dialog facial state.

Workflow:

1. Pose major keyframes first.
2. Add secondary motion for hair, skirt, ribbons, and accessories.
3. Add facial keys after the body motion is stable.
4. Use graph curves for easing; avoid robotic linear motion unless matching the source.
5. Keep clip names close to original recovered names where possible.

## Texture Packing And Export

Export set:

```text
character.skel or character.json
character.atlas
character.png / character_2.png / ...
```

Rules:

- Match Spine editor/runtime version. The current recovered skeletons identify Spine `4.2.43`.
- Keep complete atlas pages. Do not replace atlas pages with Unity Sprite exports.
- Preserve atlas region names. A missing or renamed region causes runtime load failures such as `Region not found in atlas`.
- Use binary `.skel` for closer parity with the recovered game; `.json` is acceptable for authoring/debugging if the runtime supports it.

## Godot Reimplementation Notes

Current project path:

- Browser: `run-spine-browser.bat`
- Baker: `scripts/reverse/bake_character_spine_previews.mjs`
- Atlas sync: `scripts/reverse/sync_character_atlas_pages.mjs`
- Renderer: `godot-project/scripts/spine_baked_preview_canvas.gd`
- Audit knowledge: `docs/reverse-godot/reverse-audit-knowledge.md`

Validation:

```powershell
node .\scripts\reverse\sync_character_atlas_pages.mjs
node .\scripts\reverse\bake_character_spine_previews.mjs --fps=8 --max-duration=0.9 --max-clips=2
.\tools\Godot\Godot_console.exe --headless --import --path .\godot-project
.\capture-spine-browser.bat
```

Pass criteria:

- atlas-size mismatch count is zero;
- preview body parts assemble correctly;
- selected clip uses the intended skin;
- no new missing-region errors appear.

## Common Failure Modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| body parts sampled from wrong image area | sprite crop used instead of full atlas page | replace with `Texture2D` atlas page |
| eyes/mouth missing or offset | wrong skin for animation clip | select animation-specific skin during bake |
| skeleton parse fails from `.dat` | Unity/TextAsset wrapper header | use AssetRipper raw `.bytes` or unwrap first |
| blank Spine render in Godot | UVs treated as pixels instead of normalized values | pass `0..1` UVs directly to `draw_polygon` |
| load error: `Region not found in atlas` | missing region or wrong atlas variant | compare AssetRipper primary/main and UABEA exports |
