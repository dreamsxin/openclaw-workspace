# Spine Baker

Small local helper for baking recovered Spine binary skeletons into Godot-friendly JSON frames.

Install dependencies when needed:

```powershell
cd tools/spine-baker-js
npm install
```

Bake the current MVP verification character:

```powershell
node ..\..\scripts\spine\bake_hero_spine_preview.mjs --hero=hero_016 --fps=8 --max-duration=1.2 --max-clips=2
```
