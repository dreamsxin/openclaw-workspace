# shaonv Godot MVP 80% 還原目標

日期：2026-05-23

## 目標

後續不追求完整搬運 Unity 專案，也不追求所有界面像素級 100% 復刻。MVP 目標調整為：

```text
單機可玩 + 核心界面觀感至少 80% 接近原遊戲
```

## 80% 的評估方式

每個核心界面按 100 分估算：

| 項目 | 權重 | 判定方式 |
|---|---:|---|
| Prefab 布局 | 30 | 是否按 Unity `RectTransform` 層級、錨點、主要節點位置重建 |
| 真實 UI 資源 | 30 | 是否使用原 PNG/Sprite/背景/按鈕/框體，而不是 Godot 幾何色塊 |
| 角色與動效展示 | 25 | 是否使用真實角色資源、baked Spine 或後續 Spine runtime |
| 核心交互 | 15 | 是否能完成原界面的主要流程，例如登入、進主城、抽卡、結果、角色詳情 |

界面達到 80 分即可視為 MVP 達標。缺失視頻、粒子、Shader、部分 Animator 不阻塞 MVP，但需記錄缺口。

## 核心界面範圍

P0 必須達到 80%：

| 界面 | 原 prefab / 類 | MVP 目的 |
|---|---|---|
| 登入鏈路 | `LaunchView` / `LoginView` / `LoadingView` | 進入單機主界面 |
| 主界面 | `MainUIView` | 主城、看板角色、入口菜單 |
| 抽卡主界面 | `LotteryDrawMainView` | 現世/幻靈卡池、單抽/十連 |
| 抽卡結果/招募演出 | `LotteryDrawFinishView` / `HeroRecruitView` | 核心美術展示與結果反饋 |
| 角色詳情 | `CommonHeroView` | 角色展示、技能、碎片、獲得狀態 |
| 圖鑑 | `GalCollectionView` | 收集進度與角色列表 |

P1 可接近即可：

| 界面 | MVP 目的 |
|---|---|
| 商店 | 單機資源兌換 |
| 任務 | 單機循環獎勵 |
| 郵件/每日補給 | 啟動資源補給 |
| 戰役/掛機 | 單機資源產出 |

## 當前狀態估算

| 界面 | 估算 | 狀態 |
|---|---:|---|
| LaunchView | 45% | 有 prefab 結構和跳過流程，缺 `launch.mp4` 真實視頻 |
| LoginView | 65% | 已接入真實背景、logo、登入按鈕、服務器框；仍缺部分按鈕 icon、提示圖和 SDK 彈層 |
| LoadingView | 60% | 已按背景+底部進度條收斂；缺真實 loading tip / 進度邏輯 |
| MainUIView | 65% | 已按 prefab 全屏布局重排並接入背景/Spine；仍缺大量 MainUI 按鈕切片和動效 |
| LotteryDrawMainView | 65% | 已按 prefab 修正右側 tab、祈願位、底部抽卡按鈕；仍需更多真實切片和細節 |
| HeroRecruit/Finish | 45% | 有結果流程和角色展示，缺真實結果粒子、光效、框體布局 |
| CommonHeroView | 50% | 有角色、技能圖、碎片信息；未按 prefab 完整重排 |
| GalCollectionView | 45% | 有列表/篩選/進度；缺 prefab 布局與真實卡牌資源 |

## 後續策略

1. 每次只推進一個核心界面，先抽 prefab 布局，再補真實資源，再接交互。
2. 優先級改為：`LotteryDrawMainView -> HeroRecruitView/LotteryDrawFinishView -> MainUIView -> CommonHeroView -> GalCollectionView`。
3. 啟動鏈路保留可進入主界面的程度即可，不再為缺失 `launch.mp4` 追求像素級復刻。
4. Godot 腳本繼續按界面拆分到 `standalone/godot-mvp/scripts/screens/`，`main.gd` 僅保留數據、存檔、路由和公共 helper。
5. 每個界面至少保留一張本地截圖，作為回歸對比依據。

## 下一個可執行任務

優先把 `HeroRecruitView` / `LotteryDrawFinishView` 從當前幾何結果頁提升到 80%：

- 使用 `docs/shaonv-lottery-prefab-layout-2026-05-23.md` 的層級作為布局源。
- 將結果頁拆成 `result_screen.gd`。
- 使用 `lottery_img_60*`、`fx_lottery_img_60_*`、`zhero_*`、baked Spine 展示主出貨角色。
- 先用 Godot 半透明節點模擬粒子位置，等真實粒子/材質可解析後再替換。
