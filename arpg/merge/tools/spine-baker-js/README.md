# Spine Baker JS

Local helper workspace for offline Spine baking.

Install dependencies before running `scripts/reverse/bake_kokomi_loading_spine.mjs`:

```powershell
npm install --prefix tools\spine-baker-js
```

The baker currently uses `@esotericsoftware/spine-core@4.2.43`, matching `kokomi_Loading.skel.bytes`.
Do not commit `node_modules`; keep only `package.json` and `package-lock.json`.
