# LoginView Layout Analysis

**Date**: 2026-05-23
**Source Prefab**: `Assets/Game/RawAssets/Prefabs/UI/Login/LoginView.prefab`
**Bundle File**: `7996b01a22fa6b87d3cf865ec438316b.bundle`
**Analysis Type**: Deep Layout + IL Lifecycle Analysis

---

## 1. Basic Information

| Property | Value |
|---|---|
| Node Count | 39 |
| Total Components | 165 (AssetBundle: 1, CanvasGroup: 2, CanvasRenderer: 34, GameObject: 39, MonoBehaviour: 67, MonoScript: 15, RectTransform: 38, Transform: 1, VideoPlayer: 1) |
| Source Bundle | `assets/yoo/Default/7996b01a22fa6b87d3cf865ec438316b.bundle` |
| Root GameObjects | @videoPlayer (active=false), LoginView (active=true) |
| UI Layer | 5 (LoginView + children), 0 (@videoPlayer) |
| Base Class | `ViewBehaviour` (IL: `.ctor()` calls `ViewBehaviour::.ctor()`) |

### Serialized Fields (from IL)

```
PrefabName      : System.String
imgBg           : UnityEngine.UI.Image
pnl             : UnityEngine.Transform
btnLogin        : UnityEngine.UI.Button
pnlFunction     : UnityEngine.Transform
btnNotice       : UnityEngine.UI.Button
btnRepair       : UnityEngine.UI.Button
btnSwitchAccount: UnityEngine.UI.Button
btnSelect       : UnityEngine.UI.Button
pnlVersion      : UnityEngine.Transform
txtVer          : UnityEngine.UI.Text
txtApp          : UnityEngine.UI.Text
txtRes          : UnityEngine.UI.Text
imgLogo         : UnityEngine.UI.Image
btnAge          : UnityEngine.UI.Button
txtTipTitle     : UnityEngine.UI.Text
txtGameTip      : UnityEngine.UI.Text
txtCopyright    : UnityEngine.UI.Text
btnServerSel    : UnityEngine.UI.Button
txtServer       : UnityEngine.UI.Text
imgServer       : UnityEngine.UI.Image
txtServerName   : UnityEngine.UI.Text
imgTipLogin     : UnityEngine.UI.Image
inputAccount    : UnityEngine.UI.InputField
txtAccount      : UnityEngine.UI.Text
_loginCoolDown  : UnityEngine.WaitForSeconds
_richUrl        : HyperlinkText
_richBottom     : HyperlinkText
_togAgree       : UnityEngine.UI.Toggle
```

---

## 2. Complete RectTransform Tree

```
@videoPlayer [ROOT, LAYER 0]
  Transform (not RectTransform) + VideoPlayer
  active=false
  NOTE: Hidden game object hosting VideoPlayer for login background video

LoginView [ROOT, LAYER 5]
  anchorMin=(0,0)  anchorMax=(1,1)  pivot=(0.5,0.5)
  sizeDelta=(0,0)  anchoredPosition=(0,0)
  localScale=(1,1,1)  active=true
  Components: RectTransform + 2x MonoBehaviour
  |
  +-- @rawImgBg [child 0]
  |     anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)
  |     sizeDelta=(1670, 1670)  anchoredPosition=(0,0)
  |     localScale=(0.99997, 0.99997, 0.99997)
  |     active=false
  |     NOTE: Hidden RawImage for video background (1670x1670)
  |
  +-- imgBg [child 1]
  |     anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)
  |     sizeDelta=(1670, 750)  anchoredPosition=(0,0)
  |     localScale=(1,1,1)  active=true
  |     NOTE: Static background image (1670x750 centered)
  |
  +-- pnl [child 2]
  |     anchorMin=(0,0)  anchorMax=(1,1)  pivot=(0.5,0.5)
  |     sizeDelta=(0,0)  anchoredPosition=(0,0)
  |     localScale=(1,1,1)  active=true
  |     Components: RectTransform + CanvasRenderer + MonoBehaviour + CanvasGroup
  |     NOTE: Main content panel (full-screen), has CanvasGroup for fade effects
  |     |
  |     +-- btnLogin [0]
  |     |     anchorMin=(0,0)  anchorMax=(1,1)
  |     |     sizeDelta=(0,0)  anchoredPosition=(0,0)
  |     |     localScale=(0.99975, 0.99975, 0.99975)  active=true
  |     |     NOTE: Full-screen invisible button overlay for tap-to-login
  |     |
  |     +-- pnlFunction [1]
  |     |     anchorMin=(1,0)  anchorMax=(1,1)  pivot=(0.5,0.5)
  |     |     sizeDelta=(131.345, 0)  anchoredPosition=(-65.67, 0)
  |     |     localScale=(1,1,1)  active=true
  |     |     NOTE: Right-edge function button column (131px wide)
  |     |     |
  |     |     +-- btnNotice [0]
  |     |     |     anchorMin=(0,0)  anchorMax=(0,0)
  |     |     |     sizeDelta=(60, 60)  anchoredPosition=(0,0)  active=true
  |     |     |     NOTE: 60x60 function button (notice/announcement)
  |     |     |     |
  |     |     |     +-- Text
  |     |     |           anchorMin=(0.5,0)  anchorMax=(0.5,0)
  |     |     |           sizeDelta=(160, 30)  anchoredPosition=(0,0)
  |     |     |           active=false
  |     |     |           NOTE: Hidden label text below button
  |     |     |
  |     |     +-- btnRepair [1]
  |     |     |     anchorMin=(0,0)  anchorMax=(0,0)
  |     |     |     sizeDelta=(60, 60)  anchoredPosition=(0,0)  active=true
  |     |     |     NOTE: 60x60 function button (repair)
  |     |     |     |
  |     |     |     +-- Text (active=false)
  |     |     |
  |     |     +-- btnSwitchAccount [2]
  |     |     |     anchorMin=(0,0)  anchorMax=(0,0)
  |     |     |     sizeDelta=(60, 60)  anchoredPosition=(0,0)  active=true
  |     |     |     NOTE: 60x60 function button (switch account)
  |     |     |     |
  |     |     |     +-- Text (active=false)
  |     |     |
  |     |     +-- btnSelect [3]
  |     |           anchorMin=(0,0)  anchorMax=(0,0)
  |     |           sizeDelta=(60, 60)  anchoredPosition=(0,0)  active=true
  |     |           NOTE: 60x60 function button (server select)
  |     |           |
  |     |           +-- Text (active=false)
  |     |
  |     +-- pnlVersion [2]
  |     |     anchorMin=(1,0)  anchorMax=(1,0)  pivot=(1,0)
  |     |     sizeDelta=(100, 126.754)  anchoredPosition=(-13, 114)
  |     |     localScale=(1,1,1)  active=true
  |     |     NOTE: Bottom-right version info panel
  |     |     |
  |     |     +-- txtVer    anchorMin=(0,0)  sizeDelta=(332,30)  pivot=(1,0.5)  active=true
  |     |     +-- txtApp    anchorMin=(0,0)  sizeDelta=(332,30)  pivot=(1,0.5)  active=true
  |     |     +-- txtRes    anchorMin=(0,0)  sizeDelta=(332,30)  pivot=(1,0.5)  active=true
  |     |
  |     +-- imgLogo [3]
  |     |     anchorMin=(0,1)  anchorMax=(0,1)  pivot=(0,0)
  |     |     sizeDelta=(260, 104)  anchoredPosition=(61, -129)
  |     |     localScale=(0.8, 0.8, 1)  active=true
  |     |     Components: RectTransform + CanvasRenderer + 3x MonoBehaviour
  |     |     NOTE: Game logo in top-left corner (scaled 0.8)
  |     |
  |     +-- btnAge [4]
  |     |     anchorMin=(0,0)  anchorMax=(0,0)  pivot=(0.5,0.5)
  |     |     sizeDelta=(83, 104)  anchoredPosition=(90, 154)
  |     |     localScale=(0.8, 0.8, 1)  active=true
  |     |     NOTE: Age rating button (12+) near logo
  |     |
  |     +-- @richBottom [5]
  |     |     anchorMin=(0.5,1)  anchorMax=(0.5,1)  pivot=(0.5,1)
  |     |     sizeDelta=(1670, 78)  anchoredPosition=(0, -667)
  |     |     localScale=(1,1,1)  active=true
  |     |     NOTE: Bottom HyperlinkText area (copyright/license)
  |     |     |
  |     |     +-- txtGameTip     sizeDelta=(800,40)  anchoredPos=(0,-24)  active=false
  |     |     +-- txtCopyright   sizeDelta=(800,40)  anchoredPos=(0,-48)  active=false
  |     |     +-- txtCopyleft    sizeDelta=(800,40)  anchoredPos=(0,-70)  active=false
  |     |
  |     +-- btnServerSel [6]
  |     |     anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)  pivot=(0.5,0.5)
  |     |     sizeDelta=(500, 34)  anchoredPosition=(0, -99)
  |     |     localScale=(1,1,1)  active=false
  |     |     NOTE: Server selection bar (hidden, shown when server select is available)
  |     |     |
  |     |     +-- txtServer      sizeDelta=(101,44)  anchoredPos=(-223.5, 0.24)  active=false
  |     |     +-- imgServer      sizeDelta=(26,26)  anchoredPos=(-20, 0)  scale=(0.9,0.9,1)  active=true
  |     |     +-- txtServerName  sizeDelta=(311.26,42)  anchoredPos=(0,0)  active=true
  |     |
  |     +-- imgTipLogin [7]
  |     |     anchorMin=(0.5,1)  anchorMax=(0.5,1)  pivot=(0.5,1)
  |     |     sizeDelta=(536,30)  anchoredPosition=(0, -553)
  |     |     localScale=(1,1,1)  active=true
  |     |     Components: RectTransform + CanvasRenderer + MonoBehaviour + CanvasGroup
  |     |     NOTE: Login tip text flicker area (has CanvasGroup for DOFade animation)
  |     |
  |     +-- @richUrl [8]
  |           anchorMin=(0.5,1)  anchorMax=(0.5,1)  pivot=(0.5,1)
  |           sizeDelta=(0, 32)  anchoredPosition=(19.9, -620)
  |           localScale=(1,1,1)  active=true
  |           Components: RectTransform + CanvasRenderer + 3x MonoBehaviour
  |           NOTE: Privacy policy / user agreement HyperlinkText area
  |           |
  |           +-- togAgree
  |                 anchorMin=(0,0.5)  anchorMax=(0,0.5)  pivot=(1,0.5)
  |                 sizeDelta=(32,32)  anchoredPosition=(-10, 0)
  |                 active=true
  |                 |
  |                 +-- Background
  |                       anchorMin=(0,0)  anchorMax=(1,1)
  |                       sizeDelta=(0,0)  anchoredPosition=(0,0)
  |                       active=true
  |                       |
  |                       +-- Checkmark
  |                             anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)
  |                             sizeDelta=(32,32)  anchoredPosition=(0,0)
  |                             active=true
  |
  +-- inputAccount [child 3]
        anchorMin=(0.5,0.5)  anchorMax=(0.5,0.5)  pivot=(0.5,0.5)
        sizeDelta=(543, 64)  anchoredPosition=(0, -114.5)
        localScale=(1,1,1)  active=true
        NOTE: Account name input field (centered, 543x64)
        |
        +-- Placeholder    sizeDelta=(362.7,63.9)  anchoredPos=(160.8,0)  pivot=(0,0.5)  active=true
        +-- Text           sizeDelta=(362.7,63.9)  anchoredPos=(160.8,0)  pivot=(0,0.5)  active=true
        +-- Image          sizeDelta=(40,40)  anchoredPos=(-239.1,0)  active=true  (icon)
        +-- txtAccount     sizeDelta=(-469,-0.05)  anchoredPos=(-172,0.025)  active=true
```

---

## 3. Component Type Distribution

| Component Type | Count | Key Nodes |
|---|---|---|
| RectTransform | 38 | All UI nodes (except @videoPlayer) |
| MonoBehaviour | 67 | All interactive and functional nodes |
| CanvasRenderer | 34 | All nodes that render (Image, Text, etc.) |
| GameObject | 39 | All nodes |
| MonoScript | 15 | Unique script types referenced |
| CanvasGroup | 2 | pnl, imgTipLogin |
| Transform | 1 | @videoPlayer |
| VideoPlayer | 1 | @videoPlayer |

### CanvasGroup Usage

| Node | Purpose |
|---|---|
| pnl | Main content panel (fade in/out control) |
| imgTipLogin | Login tip with DOFade animation |

### Button Distribution (7 buttons total)

| Button | Active | Click Handler (from IL) |
|---|---|---|
| btnLogin | true | Handles login flow (server check, agree toggle, SDK login, connect) |
| btnNotice | true | ShowAnnounce() |
| btnRepair | true | ShowRepairAlter() |
| btnSwitchAccount | true | SDK switch login (conditionally active) |
| btnSelect | true | Open ServerSelectView or ReqServerList() |
| btnAge | true | Statically wired to open age/rating info |
| btnServerSel | false | Server selection bar (hidden by default) |

---

## 4. @prefab Instances and Panel Naming Patterns

### @-prefixed Nodes (likely internal/prefab instances)

| Node Name | Active | Role |
|---|---|---|
| @videoPlayer | false | Root-level VideoPlayer for animated login background |
| @rawImgBg | false | RawImage child for video background rendering |
| @richBottom | true | HyperlinkText component for copyright/license clickable text |
| @richUrl | true | HyperlinkText component for privacy policy/user agreement clickable text |

### Panel Naming Convention

- `pnl` -- Main content panel (full-screen)
- `pnlFunction` -- Right-side function button container
- `pnlVersion` -- Bottom-right version info panel
- Button prefix: `btn` (btnLogin, btnNotice, btnRepair, etc.)
- Text prefix: `txt` (txtVer, txtApp, txtRes, etc.)
- Image prefix: `img` (imgBg, imgLogo, imgServer, etc.)

---

## 5. IL Lifecycle Methods

### .ctor()

```
IL_0000-IL_0016:
  _loginCoolDown = new WaitForSeconds(2)
  base.ViewBehaviour::.ctor()
```
Sets up a 2-second login cooldown timer, then calls the base constructor.

### Awake() [largest method]

The `Awake()` method performs extensive UI wiring in a specific order:

**Phase 1: HyperlinkText Resolution**
1. Finds `@richBottom` child in `pnl` via `Transform.Find("@richBottom")` and gets `HyperlinkText` component
2. Registers `OnRichBottomClick` as the `onHrefClick` listener on `_richBottom`
3. Finds `@richUrl` child in `pnl` via `Transform.Find("@richUrl")` and gets `HyperlinkText` component
4. Registers `OnPrivacyClick` as the `onHrefClick` listener on `_richUrl`

**Phase 2: Toggle Setup**
5. Finds `togAgree` child in `_richUrl` via `Find("togAgree")` and gets `Toggle` component
6. Sets `_togAgree.isOn` based on `PlayerSetting.GetLocalInt("AgreePrivacy") == 1`
7. Registers a listener on `_togAgree.onValueChanged` to persist the agreement to `PlayerSetting`

**Phase 3: Button Click Registration**
8. `btnAge` -- Registers click to statically open age/rating page (directly wired, no cooldown)
9. `btnSelect` -- Registers click with instance method `<Awake>b__29_2` (opens ServerSelectView or calls ReqServerList)
10. `btnLogin` -- Registers click with 1.0s cooldown to `<Awake>b__29_3` (the complex login handler)
11. `btnRepair` -- Registers click to `<Awake>b__29_4` (shows repair dialog)
12. `btnNotice` -- Registers click to `ShowAnnounce()` instance method
13. `btnSwitchAccount` -- Conditionally set active based on `SDKService.GetIsSupportSwitchLogin()`, then registers click if active

### OnOpen(System.Object parameter)

```
IL_0000-IL_0090:
  InitView()
  openId = ModelCenter.Get<LoginModel>().GetOpenId()
  if (!string.IsNullOrEmpty(openId)) {
      inputAccount.text = openId
  }
  if (string.IsNullOrEmpty(SDKService.GetChannel())) {
      // No SDK channel -- direct server list request
      ReqServerList()
  } else {
      // Has SDK channel
      inputAccount.gameObject.SetActive(false)  // Hide manual input
      if (getSdkLogin.data.userID is empty or token is empty) {
          // Need SDK login
          LoginModel.SdkLogin(<OnOpen>b__32_0 callback)
      }
      // else: already has SDK credentials, proceed to server list
  }
```

Key logic:
- Initializes the view (version display, server selection, tip animation)
- Fills in the account input field with saved OpenId if available
- Hides account input for SDK channel users
- Triggers SDK login flow if SDK credentials are missing
- Falls back to direct server list request otherwise

### InitView()

```
IL_0000-IL_00eb:
  if (LoginModel.selectServer != null) {
      txtServerName.text = selectServer.serverName
      SetStatusImg(selectServer.status, selectServer.type).Forget()
  }
  txtVer.text = "ver " + GlobalConfig.GetConfig().forceVersion
  txtApp.text = $"app {{{AssetsConfig.GetConfig().packVersion}}}_{GameConfig.I18N}"
  txtRes.text = $"ver {{{AssetsService.GetVersion()}}}"

  // Animated fade loop on imgTipLogin
  CreateLoopSequence()
      .Append(imgTipLogin.DOFade(0.2, 1))
      .Append(imgTipLogin.DOFade(1, 1))
```

Key effects:
- Displays server name and status if previously selected
- Shows three version lines: force version, app pack version, resource version
- Creates a looping fade animation on the login tip image (flicker effect)

### StartCountDownBtnLogin()

Returns an IEnumerator `<StartCountDownBtnLogin>d__30` that implements login button cooldown logic. Used by `MonoBehaviour.StartCoroutine(StartCountDownBtnLogin())`.

### OnBack(System.Object parameter) -- Server Selection Callback

```
IL_0000-IL_003b:
  if (parameter != null) {
      var server = (EnityServer)parameter
      LoginModel.selectServer = server
      txtServerName.text = server.serverName
      SetStatusImg(server.status, server.type).Forget()
  }
```

Called when returning from server selection view. Updates the selected server display.

### OnGetAnnounce(EntityAnnounce announce)

```
IL_0000-IL_0020:
  if (announce.data.Count > 0) {
      ViewBehaviour.Open("Prefabs/UI/Announce/AnnounceView", announce, false, true).Forget()
  }
```

Opens the announcement popup if there are announcements available.

### SetStatusImg(System.Int32 status, System.Int32 type)

An async UniTask (`<SetStatusImg>d__35`) that updates the server status indicator image. Uses Cysharp.Threading.Tasks for async operations.

### ShowRepairAlter()

An async UniTaskVoid (`<ShowRepairAlter>d__36`) that displays the repair/resource fix dialog. Implemented as an async state machine with Cysharp.Threading.Tasks.

### ReqServerList()

```
IL_0000-IL_0026:
  ModelCenter.Get<LoginModel>().ReqServerList(
      inputAccount.text.Trim(),
      callback: <ReqServerList>b__37_0
  )
```

Requests the server list with the trimmed account name. The callback either shows an error alert or populates server info.

### ShowAnnounce()

```
IL_0000-IL_0017:
  ModelCenter.Get<LoginModel>().GetAnnounceInfo(1, OnGetAnnounce)
```

### OnPrivacyClick(System.String key)

```
IL_0000-IL_002a:
  if (key == "privacy")
      url = GameConfig.PrivacyPolicyUrl
  else
      url = GameConfig.UserUrl
  ViewBehaviour.Open("Prefabs/UI/Common/CommonWebView", url, false, true).Forget()
```

Opens the privacy policy or user agreement webview based on the hyperlink key.

### OnRichBottomClick(System.String key)

```
IL_0000-IL_000f:
  SDKService.GetSDKService().OpenUrl(GameConfig.InternetStandardPublishNumberUrl)
```

Opens the internet standard publish number URL (copyright/license related).

### Button Handler Detail

#### b__29_2 (btnSelect click)
If `getServerEnity` exists, opens `ServerSelectView` prefab. Otherwise calls `ReqServerList()`.

#### b__29_3 (btnLogin click) -- MOST COMPLEX HANDLER
This is the critical login flow handler:
1. Checks if `LoginModel.selectServer` exists. If not, calls `ReqServerList()` and returns.
2. Checks server status. If status is 0 (maintenance), shows toast "UI1022010".
3. Checks `_togAgree.isOn`. If not agreed, shows toast "UI1022013".
4. If server status is 1 and type is 3, iterates role list to check if player has role on this server.
5. If no role found, shows toast "UI1022009".
6. If SDK channel has no value:
   - Validates account name is not empty
   - Calls `LoginModel.SaveOpenId(accountName)`
7. Otherwise (SDK channel present):
   - If SDK userID/token are missing, triggers `LoginModel.SdkLogin()` with callback `b__29_6` which fills account and requests server list
8. Selects a random port from `server.portList`
9. Starts cooldown coroutine: `StartCoroutine(StartCountDownBtnLogin())`
10. Reports SDK steps "8063" and "8066"
11. Connects via `RPCSession.Connect(server.host, port, false)`

#### b__29_6 (SdkLogin callback)
Fills inputAccount.text with the OpenId (if not empty), then calls `ReqServerList()`.

#### b__29_4 (btnRepair click)
Calls `ShowRepairAlter().Forget()`.

### b__37_0 (ReqServerList callback)
If server entity is null, calls `ShowRequestAlter()`. Otherwise updates txtServerName, calls SetStatusImg, and calls ShowAnnounce().

### ShowRequestAlter()
An async UniTask (`<ShowRequestAlter>d__38`) that displays network request error/failure dialog.

---

## 6. Red Dot Keys

| Key | Context | Usage |
|---|---|---|
| `AgreePrivacy` | PlayerSetting LocalInt | Persists whether user has agreed to privacy policy (read in Awake, written on toggle change) |

No traditional red dot notification keys were found. The privacy agreement toggle is the only persistent state stored.
The `btnNotice` (announcement button) likely has a red dot managed externally (not in this IL, probably in a red dot manager system).

---

## 7. Comparison with Godot MVP Implementation

### Original (Unity/C#) Behavior

The original LoginView is a complex login screen with:
1. **Video background capability**: Hidden `@videoPlayer` + `@rawImgBg` for animated backgrounds
2. **SDK integration**: Platform SDK login (channel-specific)
3. **Server selection**: Full server list with status indicators and port selection
4. **Multi-version display**: Force version, app pack version, resource version
5. **Account persistence**: OpenId saved via LoginModel.SaveOpenId
6. **Privacy agreement**: Toggle with persistent storage
7. **Announcement system**: Server-driven announcements displayed via popup
8. **Login cooldown**: 2-second WaitForSeconds between login attempts
9. **Function buttons**: Notice, Repair, Switch Account, Server Select
10. **Age rating**: btnAge button
11. **Fade animation**: imgTipLogin with DOTween looping fade
12. **Network connection**: RPCSession.Connect to selected server

### Godot MVP (`show_login()` in startup_screen.gd)

```gdscript
func show_login() -> void:
    app.current_view = "login"
    app._set_chrome_visible(false)
    app._clear("登入")
    app.content.position = Vector2(0, 0)
    app.content.size = Vector2(1280, 720)

    # Background
    app._draw_image(UI_LOGIN_BG, Vector2(-195, -4), Vector2(1670, 728), true, Color(1, 1, 1, 0.94))
    app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.014, 0.012, 0.08)))

    # Logo (image fallback to label)
    if app._draw_image(UI_LOGIN_LOGO, Vector2(48, 90), Vector2(258, 86), false) == null:
        var logo = app._label("少女回战", 54, HORIZONTAL_ALIGNMENT_CENTER)
        logo.position = Vector2(46, 102)
        logo.size = Vector2(300, 82)
        app.content.add_child(logo)

    # Age button
    var age_btn = Button.new()
    age_btn.text = "12+"
    age_btn.position = Vector2(106, 214)
    age_btn.size = Vector2(64, 70)
    age_btn.pressed.connect(app._show_login)
    app.content.add_child(age_btn)

    # Version info
    var ver = app._label("版本 1.0.0\n程序 v1.18\n资源 v1.18", 14, HORIZONTAL_ALIGNMENT_RIGHT)
    ver.position = Vector2(934, 80)
    ver.size = Vector2(230, 78)
    ver.modulate = Color(0.68, 0.64, 0.58)
    app.content.add_child(ver)

    # Account input area
    app.content.add_child(app._panel(Vector2(376, 418), Vector2(38, 38), Color(0.14, 0.11, 0.09, 0.9)))
    var icon_label = app._label("人", 22, HORIZONTAL_ALIGNMENT_CENTER)
    icon_label.position = Vector2(378, 423)
    icon_label.size = Vector2(34, 30)
    app.content.add_child(icon_label)

    var account = LineEdit.new()
    account.text = "LocalPlayer"
    account.placeholder_text = "输入玩家名称"
    account.position = Vector2(426, 418)
    account.size = Vector2(376, 62)
    app.content.add_child(account)

    # Login button
    app._draw_image(UI_LOGIN_BTN, Vector2(498, 340), Vector2(284, 82), false)
    app._add_action_button("开始游戏", Vector2(526, 358), app._show_loading, Vector2(228, 54))

    # Function buttons (right side)
    app._add_action_button("公告", Vector2(1138, 178), app._show_login_notice_popup, Vector2(60, 60))
    app._add_action_button("修复", Vector2(1138, 250), app._show_repair_popup, Vector2(60, 60))
    app._add_action_button("账号", Vector2(1138, 322), app._show_login_account_popup, Vector2(60, 60))
    app._add_action_button("切换", Vector2(1138, 394), app._show_login, Vector2(60, 60))

    # Server info
    if app._draw_image(UI_LOGIN_SERVER_BG, Vector2(390, 486), Vector2(500, 42), false) == null:
        app.content.add_child(app._panel(Vector2(390, 486), Vector2(500, 42), Color(0.09, 0.065, 0.052, 0.88)))
    var server_label = app._label("推荐服务器    Local MainScene", 18, HORIZONTAL_ALIGNMENT_CENTER)
    server_label.position = Vector2(410, 490)
    server_label.size = Vector2(460, 34)
    app.content.add_child(server_label)
    # Server status indicator
    app.content.add_child(app._panel(Vector2(888, 494), Vector2(18, 18), Color(0.18, 0.88, 0.28, 0.95)))
    var state_label = app._label("流畅", 14, HORIZONTAL_ALIGNMENT_CENTER)
    state_label.position = Vector2(912, 492)
    state_label.size = Vector2(46, 26)
    state_label.modulate = Color(0.22, 0.88, 0.32)
    app.content.add_child(state_label)

    # Tip text
    var tip = app._label("离线单机模式，数据仅供本地验证使用", 15, HORIZONTAL_ALIGNMENT_CENTER)
    tip.position = Vector2(390, 548)
    tip.size = Vector2(500, 30)
    tip.modulate = Color(0.62, 0.58, 0.52, 0.85)
    app.content.add_child(tip)

    # Agreement checkbox
    var agree = CheckBox.new()
    agree.text = "我已阅读并同意隐私政策与使用者协议"
    agree.button_pressed = true
    agree.position = Vector2(426, 594)
    agree.size = Vector2(428, 34)
    app.content.add_child(agree)

    # Copyright
    var copyright = app._label("Copyright © Offline MVP. 本地喚灵资料仅用于还原验证。", 14, HORIZONTAL_ALIGNMENT_CENTER)
    copyright.position = Vector2(340, 654)
    copyright.size = Vector2(600, 28)
    copyright.modulate = Color(0.46, 0.43, 0.4)
    app.content.add_child(copyright)
```

### Key Differences

| Aspect | Original Unity | Godot MVP | Status |
|---|---|---|---|
| Background | imgBg (1670x750) + hidden video bg | Single image (1670x728) + overlay panel | PARTIAL |
| Logo | Image component (260x104, scaled 0.8) | Image with Label fallback (258x86) | GOOD |
| Age button | btnAge (83x104, scaled 0.8, wired to open age page) | Button (64x70, wired to show_login) | PARTIAL |
| Version display | 3 separate lines (txtVer, txtApp, txtRes) | Single multi-line label | PARTIAL |
| Account input | InputField (543x64) + Placeholder + Icon Image | LineEdit (376x62) + panel icon + label | GOOD |
| Login button | btnLogin (full-screen overlay) with cooldown | Visible button (228x54) | DIFFERENT |
| Function buttons | 4 buttons in pnlFunction column (60x60 each) | 4 action buttons (60x60 each) | GOOD |
| Server bar | btnServerSel (500x34, hidden initially) | Static panel (500x42) with label | PARTIAL |
| Server status | Dynamic SetStatusImg (async) | Static green panel + "流畅" label | MISSING (dynamic) |
| Login tip | imgTipLogin with DOFade animation loop | Static text label | MISSING (animation) |
| Privacy toggle | togAgree with persistent PlayerSetting | CheckBox (always true by default) | PARTIAL |
| Copyright | HyperlinkText (@richBottom) with URL opening | Static label | PARTIAL |
| SDK integration | Full SDK login flow | Not applicable (offline MVP) | N/A |
| Network connect | RPCSession.Connect | Not applicable (offline MVP) | N/A |
| Login cooldown | 2-second WaitForSeconds | No cooldown | MISSING |
| Announcement | Server-driven OnGetAnnounce with popup | Static "公告" button | MISSING (dynamic) |
| Button float layout | Anchored via pnlFunction (131px right column) | Absolute positioned | DIFFERENT |

---

## 8. Improvement Suggestions

### For Godot MVP

1. **Add login cooldown**: The original has a 2-second cooldown between login attempts via `_loginCoolDown`. The MVP button can be spammed. Add a timer-based guard.

2. **Add fade animation on tip text**: The original uses DOTween to create a looping flicker on `imgTipLogin`. The MVP's static label is functional but less visually engaging. Consider a simple `Tween` in Godot.

3. **Implement proper version triple**: Original shows three distinct version lines (forceVersion, packVersion, resourceVersion). MVP shows hardcoded values. Connect to actual project version info.

4. **Preserve button positioning logic**: The original right-side buttons use a `pnlFunction` panel anchored to (1,0)-(1,1) with 131px width and -65.67px offset, creating a right-aligned toolbar. The MVP uses absolute positioning which works at 1280x720 but may break at other resolutions.

5. **Restore HyperlinkText for copyright**: The original uses `HyperlinkText` components that fire click events opening external URLs. The MVP uses static Label. Consider using RichTextLabel with `meta_clicked` signal in Godot for clickable URLs.

6. **Add server status dynamic display**: Original calls `SetStatusImg(server.status, server.type)` asynchronously. MVP has a static green indicator. Would benefit from dynamic status information.

7. **Proper announcement system**: Original fetches announcements from the server and opens a dedicated AnnounceView popup. MVP could simulate this with local announcement data for testing purposes.

8. **Privacy agreement persistence**: Original stores `AgreePrivacy` to `PlayerSetting` and restores it on next open. MVP always defaults to checked. Consider saving to a config file.

### Architecture Notes

- The LoginView inherits from `ViewBehaviour`, which provides `Open()`, `Destroy()`, and `CreateLoopSequence()` methods.
- Heavy use of `Cysharp.Threading.Tasks` for async operations (SetStatusImg, ShowRepairAlter, ShowRequestAlter).
- `ModelCenter.Get<LoginModel>()` is the Singleton pattern for accessing login business logic.
- `SDKServiceHelp.get_SDKService()` provides platform-specific SDK integration.
- `Scx.ButtonExtension.AddClickListener()` wraps button click handling with optional cooldown and sound effects.

---

## Summary

LoginView is a **complex 39-node login screen** with:

1. **Background**: Static image (imgBg) + hidden video player (@videoPlayer/@rawImgBg)
2. **UI Layout**: Full-screen pnl with CanvasGroup containing:
   - Invisible login button overlay (btnLogin)
   - Right-side function button column (pnlFunction: 4 buttons)
   - Version info panel (pnlVersion: 3 text lines)
   - Game logo (imgLogo)
   - Age rating button (btnAge)
   - Copyright text (@richBottom)
   - Server selection bar (btnServerSel)
   - Login tip (imgTipLogin)
   - Privacy agreement (@richUrl + togAgree)
3. **Key Lifecycle Methods**:
   - `Awake()` -- Finds HyperlinkText components, sets up toggle, registers 7 button handlers
   - `OnOpen()` -- Initialize view, handle SDK login flow, fill account info, request server list
   - `OnBack()` -- Handle server selection callback
4. **Button Handlers**: Complex login flow with server status check, privacy agreement check, SDK login, random port selection, and RPCSession connection
5. **Async Operations**: DOTween animations, UniTask-based server status loading, repair dialog

The Godot MVP captures ~60% of the layout visually but misses dynamic elements (animations, server status updates, announcement system) and completely omits SDK integration (appropriate for offline testing).
