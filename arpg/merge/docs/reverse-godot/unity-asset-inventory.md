# Unity Asset Inventory

## Confirmed Unity Data Files

| Path | Approx size | Purpose |
| --- | ---: | --- |
| `resources/assets/bin/Data/data.unity3d` | 102 MB | Main Unity data archive |
| `resources/assets/bin/Data/datapack.unity3d` | 146 MB | Additional packed Unity data |
| `resources/assets/bin/Data/resources.resource` | 24 MB | Unity resource backing file |
| `resources/assets/bin/Data/sharedassets0.resource` | 11 KB | Shared asset backing file |
| `resources/assets/bin/Data/Resources/unity default resources` | 3.6 MB | Unity built-in/default resources |
| `resources/assets/bin/Data/Managed/Metadata/global-metadata.dat` | 15 MB | IL2CPP metadata |

## Addressables

Addressables are configured in:

```text
resources/assets/aa/settings.json
resources/assets/aa/catalog.bin
resources/assets/aa/catalog.hash
resources/assets/aa/AddressablesLink/link.xml
resources/assets/aa/Android/
```

Known settings:

- Build target: `Android`
- Addressables version: `2.9.1`
- Main content catalog key: `AddressablesMainContentCatalog`
- Catalog internal id: `{UnityEngine.AddressableAssets.Addressables.RuntimePath}/catalog.bin`

Visible local bundles:

```text
ab6dd0c01737961f2405c4e9f831b261_monoscripts_538c19e2fabf677a067b89c8315b3e98.bundle
localization-assets-shared_assets_all.bundle
localization-locales_assets_all.bundle
localization-string-tables-chinese(traditional)(zh-tw)_assets_all.bundle
localization-string-tables-english(en)_assets_all.bundle
localization-string-tables-japanese(ja)_assets_all.bundle
localization-string-tables-korean(ko)_assets_all.bundle
```

The listed bundles are small, so the largest gameplay assets are probably in `data.unity3d` and `datapack.unity3d`, not in local Addressables bundles.

## Scripting Assemblies

`ScriptingAssemblies.json` lists many Unity and third-party assemblies. High-value entries:

- `Assembly-CSharp.dll`: main game code.
- `Unity.Addressables.dll`
- `Unity.Localization.dll`
- `UnityEngine.Purchasing.dll`
- `Firebase.App.dll`
- `Firebase.Analytics.dll`
- `Firebase.Messaging.dll`
- `Firebase.Crashlytics.dll`
- `Facebook.Unity.dll`
- `SingularSDK.dll`
- `MaxSdk.Scripts.dll`
- `spine-csharp.dll`
- `spine-unity.dll`
- `Coffee.SoftMaskForUGUI.dll`
- `Coffee.UIParticle.dll`
- `ToonyColorsPro.Runtime.dll`

## Runtime Initialization

`RuntimeInitializeOnLoads.json` confirms these game-level startup hooks:

| Assembly | Class | Method |
| --- | --- | --- |
| `Assembly-CSharp` | `GameManager` | `OnGameStart` |
| `Assembly-CSharp` | `HighscoreService.HighscoreService` | `OnGameStart` |

These should be first targets after IL2CPP dump.

## Godot Asset Import Expectations

Likely mapping:

| Unity asset | Godot target |
| --- | --- |
| Texture2D/Sprite/SpriteAtlas | PNG/WebP plus Godot AtlasTexture or imported Texture2D |
| AudioClip | WAV/OGG imported as AudioStream |
| TextAsset JSON/CSV | JSON/CSV resources loaded by data importers |
| ScriptableObject configs | Godot `.tres` resources or JSON data tables |
| Prefab UI | Rebuilt as Godot scenes |
| Spine assets | Godot Spine runtime or converted skeletal animation workflow |
| Localization StringTables | Godot Translation resources or CSV import |

## Extraction Notes To Fill Later

For every extracted asset folder, record:

- Tool and version used.
- Input file.
- Output folder.
- Export format.
- Whether names are original or generated.
- Any extraction errors.

## AssetStudio CLI Export Results

Checked on 2026-05-21 with:

```text
D:/work/openclaw-workspace/arpg/tools/AssetStudio-net10.0-win/AssetStudio.CLI.exe
```

Input:

```text
D:/work/openclaw-workspace/arpg/merge/resources/assets/bin/Data
```

Important options:

```text
--game Normal
--unity_version 6000.0.73f1
--dummy_dlls reverse-output/il2cpp/2026-05-21-101217-il2cppdumper/DummyDll
```

Exported outputs:

| Asset type | Output folder | Files | Size |
| --- | --- | ---: | ---: |
| Full JSON dump | `reverse-output/assets/assetstudio-cli-data-json/` | 130,943 | 130.11 MB |
| Texture2D | `reverse-output/assets/assetstudio-cli-data-texture2d/` | 1,798 | 444.07 MB |
| Sprite | `reverse-output/assets/assetstudio-cli-data-sprite/` | 3,045 | 274.18 MB |
| TextAsset | `reverse-output/assets/assetstudio-cli-data-textasset/` | 1,235 | 13.37 MB |
| Combined CSV inventory | `reverse-output/assets/assetstudio-cli-inventory.csv` | 6,078 records | 0.77 MB |

Useful asset examples already visible in the Sprite export:

- Board and block visuals: `BG_gameboard`, `BG_gameboard2`, `BlockLock`, `Block_Shadow`, `Block_Unknown`, `Board01`, `Board02`, `BoardCorner*`, `BoardSkin_Inner`, `BoardSkin_Outer`.
- Currency and economy icons: `CURRENCY_AP`, `CURRENCY_GOLD`, `CURRENCY_JEWEL`, `CURRENCY_TICKET_*`.
- Cafe and character art: `cafe_*`, `Ch_Maid*`, `Appicon_Maid*`.
- Spine-related text assets: many `.skel.dat` and `.atlas.dat` files in the TextAsset export.

Notes:

- Single-type CLI exports succeeded for `Texture2D`, `Sprite`, and `TextAsset`.
- A combined multi-type `Convert` export produced no files, so continue using one asset type per command.
- The full JSON dump is useful for metadata search but logged several duplicate-name/file-contention errors for MonoBehaviour JSON files.
- Some TextAsset `.skel`, `.atlas`, and transform exports failed; use AssetRipper or UABEA to recover missing animation/config files if needed.

## AssetRipper Primary Content Check

Checked on 2026-05-21 after manual AssetRipper export to:

```text
reverse-output/assets/assetripper-primary/
```

Summary:

| Export | Files | Size |
| --- | ---: | ---: |
| AssetRipper primary content | 10,224 | 882.30 MB |

Top exported extensions:

| Extension | Files |
| --- | ---: |
| `.json` | 3,338 |
| `.glb` | 3,099 |
| `.png` | 1,869 |
| `.bytes` | 1,370 |
| `.ogg` | 538 |

Missing-file check:

- Source failure list: `reverse-output/logs/assetstudio-cli-data-textasset.log`
- AssetStudio failed TextAsset names checked: 92
- Strict matches found in `reverse-output/assets/assetripper-primary/Assets/TextAsset`: 92
- Strict missing names: 0
- Report files:
  - `reverse-output/assets/assetripper-primary-missing-check.csv`
  - `reverse-output/assets/assetripper-primary-textasset-strict-check.csv`

Conclusion:

- AssetRipper recovered all TextAsset names that AssetStudio CLI failed to export.
- The recovered files are exported as `.bytes`, including original names such as `*.skel.bytes`, `*.atlas.bytes`, and `*transform.bytes`.
- Use `reverse-output/assets/assetripper-primary/Assets/TextAsset/` as the authoritative source for Spine skeleton, atlas, and transform TextAsset recovery.

## Tool Automation Status

Checked on 2026-05-21:

- AssetRipper `1.3.14` is available and supports Unity 6000, but the downloaded build is a web GUI/local server app. `--headless` prevents automatic browser launch; it is not a one-shot export CLI.
- AssetStudio `v0.16.47` is available as `AssetStudioGUI.exe`; it is GUI-oriented and may not fully support Unity 6000 assets.
- UABEA `v8` is available as `UABEAvalonia.exe`; it is GUI-oriented.

Current plan:

1. Use AssetStudio CLI single-type exports as the repeatable first-pass asset dump.
2. Use AssetRipper for primary Unity 6000 reconstruction through its web GUI/headless local server, especially prefab/scene/MonoBehaviour structure.
3. Use UABEA for bundle-level inspection and recovery of files that AssetStudio CLI failed to export.
4. Consider UnityPy or a custom script only if AssetStudio CLI and AssetRipper leave gaps in repeatability.
