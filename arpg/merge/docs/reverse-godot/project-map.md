# Project Map

## Root Layout

Current workspace:

```text
D:/work/openclaw-workspace/arpg/merge
├── resources/
└── sources/
```

## `resources/`

APK resources and Unity runtime data.

Important paths:

```text
resources/AndroidManifest.xml
resources/assets/
resources/assets/bin/Data/
resources/assets/bin/Data/Managed/Metadata/global-metadata.dat
resources/assets/aa/
resources/lib/arm64-v8a/
resources/res/
```

### `resources/AndroidManifest.xml`

Confirmed application metadata:

- Package: `puzzle.merge.maid.cafe`
- Version name: `0.2.74`
- Version code: `74`
- minSdk: `23`
- targetSdk: `35`
- Application class: `com.pairip.application.Application`
- Launch Activity: `com.singular.unitybridge.SingularUnityActivity`
- Screen orientation: portrait
- Deep links:
  - `mergemaidcafe://`
  - `https://mergemaidcafe.sng.link/...`

### `resources/assets/bin/Data/`

Unity player data.

Key files:

- `data.unity3d`: main Unity data archive, about 102 MB.
- `datapack.unity3d`: larger Unity data archive, about 146 MB.
- `resources.resource`: Unity resource data, about 24 MB.
- `sharedassets0.resource`: small shared asset resource.
- `boot.config`: Unity boot settings.
- `ScriptingAssemblies.json`: list of C# assemblies compiled into IL2CPP.
- `RuntimeInitializeOnLoads.json`: runtime init method list.
- `Managed/Metadata/global-metadata.dat`: IL2CPP metadata, required for code recovery.

### `resources/assets/aa/`

Unity Addressables local configuration.

Key files:

- `settings.json`: Addressables settings, version `2.9.1`.
- `catalog.bin`: Addressables catalog.
- `catalog.hash`: catalog hash.
- `AddressablesLink/link.xml`: Unity linker preservation rules.
- `Android/*.bundle`: local bundles. Current visible names mostly point to localization data.

### `resources/lib/arm64-v8a/`

Native libraries.

Most important:

- `libil2cpp.so`: IL2CPP native code, about 97 MB.
- `libunity.so`: Unity engine, about 22 MB.
- `lib_burst_generated.so`: Unity Burst generated native code.

Other libraries are mostly SDK integrations:

- Firebase
- Crashlytics
- AppLovin
- Pangle/ByteDance
- Google/PairIP

## `sources/`

Java source recovered from APK bytecode. Current counts show most files are third-party libraries:

| Top package | Approx Java files | Notes |
| --- | ---: | --- |
| `com` | 28947 | Google, Firebase, Facebook, ad SDKs, Unity SDKs |
| `yads` | 4642 | Yandex ads/internal dependencies |
| `androidx` | 2677 | AndroidX libraries |
| `io` | 2032 | AppMetrica and related libraries |
| `kotlinx` | 816 | Kotlin libraries |
| `kotlin` | 691 | Kotlin runtime |
| `gatewayprotocol` | 165 | SDK protocol classes, likely ads/monetization related |
| `puzzle` | 1 | App `R.java` only |
| `stack` | 1 | Library `BuildConfig.java` only |

Important conclusion: there is no substantial game Java source under `puzzle.merge.maid.cafe`; gameplay should be recovered from IL2CPP and Unity assets.
