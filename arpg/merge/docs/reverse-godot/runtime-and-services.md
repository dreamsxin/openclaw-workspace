# Runtime and Services

## Android Runtime

Main app identity:

- Package: `puzzle.merge.maid.cafe`
- App label: `MergeMaidCafe`
- Launch Activity: `com.singular.unitybridge.SingularUnityActivity`
- Application class: `com.pairip.application.Application`
- Orientation: portrait
- OpenGL ES requirement: `0x30000`
- Vulkan feature declared as optional.

Unity metadata:

- `unityplayer.UnityActivity=true`
- `unity.splash-enable=true`
- `unity.launch-fullscreen=true`
- `unity.render-outside-safearea=true`
- `unity.strip-engine-code=true`
- `unity.auto-set-game-state=true`

## Permissions

Confirmed permissions include:

- Internet and network state
- Wi-Fi state
- Vibration
- Google Advertising ID
- Billing
- Notifications
- Firebase Cloud Messaging receive
- Wake lock
- Foreground service
- Read/write external storage compatibility permissions
- Exact alarm
- Google Play license check
- Android Privacy Sandbox ad services permissions

For Godot, start with a smaller permission set:

- Internet only if backend/ads/IAP are implemented.
- Billing only when IAP is implemented.
- Notifications only when push/local notifications are rebuilt.
- Avoid legacy external storage unless a concrete need appears.

## Deep Links

Confirmed deep link schemes/hosts:

- `mergemaidcafe://`
- `https://mergemaidcafe.sng.link/...`
- `http://mergemaidcafe.sng.link/...`

These likely support Singular attribution and campaign links.

Godot replacement:

- Add equivalent Android intent filters only if deep links are needed.
- Route incoming links through a small platform service interface.

## Third-Party SDKs

Confirmed or strongly indicated integrations:

| Service | Evidence | Godot replacement decision |
| --- | --- | --- |
| Singular | Launch Activity and deep links | Replace with no-op initially; add attribution later if needed |
| Firebase Analytics | `Firebase.Analytics.dll`, resources | Replace with analytics abstraction |
| Firebase Messaging | `Firebase.Messaging.dll`, FCM permissions | Defer unless push is required |
| Firebase Crashlytics | native libs and DLL | Replace with Godot crash/log reporting later |
| Facebook Unity SDK | Manifest activities and DLLs | Defer unless login/share is required |
| Google Play Games | assemblies and resources | Defer achievements/leaderboards |
| Google Play Billing / Unity IAP | billing permission, purchasing DLLs | Rebuild behind IAP interface |
| AppLovin MAX | `MaxSdk.Scripts.dll`, manifest components | Rebuild behind ad mediation interface |
| Unity Ads / ironSource / Fyber / InMobi / Pangle / Yandex / Mintegral | Manifest and package names | Do not port directly in first prototype |
| GameAnalytics | Java package and likely C# integration | Replace with analytics abstraction |
| PairIP / Play integrity | `com.pairip`, native libs | Ignore for local prototype; revisit for store release |

## Service Abstraction Plan

Godot should not directly embed SDK calls inside gameplay scripts. Use interfaces/autoloads:

```text
Services/
├── AnalyticsService
├── AdsService
├── IapService
├── AuthService
├── CloudSaveService
├── NotificationService
└── DeepLinkService
```

Initial implementation can be no-op or local mocks. This keeps gameplay implementation independent from Android SDK decisions.

## Runtime Behavior To Verify

Unknowns:

- Whether the game requires online config at boot.
- Whether save data is local, cloud, or hybrid.
- Whether ad rewards are required for normal progression.
- Whether IAP products are hardcoded or remote-configured.
- Whether push notifications affect gameplay timers.

These should be answered from recovered `Assembly-CSharp` code and runtime testing.
