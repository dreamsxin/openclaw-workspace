# 单机 MVP 缺口闭合分析

> 2026-05-23 · 基于上一轮"够不够"评估的深入补齐分析

---

## 总览

| 分类 | 项数 | 分析深度 |
|------|:--:|------|
| 🔴 数据层 — 缺可分析的数据 | 2 | 深入源码级分析 |
| 🟡 数据层 — 需要工具增强才能提取 | 4 | 给出提取方案 |
| 🔴 实现层 — Godot 端未实现 | 6 | 给出架构设计 |

---

## 一、数据层缺口（差一点的部分）

### 1. Image→Sprite 精确绑定

#### 现状

`inspect_unity_prefab_layout.py` 当前只提取 RectTransform 层级和组件类型列表，**不提取 MonoBehaviour 序列化字段**。

layout.json 中可以看到：
```json
{
  "typeCounts": { "Sprite": 3, "Texture2D": 3 },
  "nodes": [
    { "name": "imgHeadBg", "componentTypes": ["RectTransform", "CanvasRenderer", "MonoBehaviour"] }
  ]
}
```

但 `Image.sprite` 是 `MonoBehaviour` 的序列化字段，存储为 PPtr（指针）引用，在二进制数据中不可见。

#### 已有的推断映射（通过 IL FIELD + layout.json 交叉）

| Image 节点 | IL FIELD | 推断 sprite | 依据 |
|-----------|----------|------------|------|
| imgHeadBg | `Image imgHeadBg` | mainui_img_03.png | 头像白色圆环，IL 中声明为 Image 类型 |
| imgExp | `Image imgExp` | mainui_img_04.png | EXP 金色环，IL 中声明为 Image 类型 |
| imgHookTime | `Image imgHookTime` (92×20) | **未知** | IL 中声明 + layout 节点尺寸 92×20 |
| (btnGal 内) | — | **未知** (150×170) | 节点尺寸推断 |
| (irole 内 imgMask) | (无独立 FIELD) | **未知** (324×274) | 布局节点 |

MainUIView 3 个 Sprite（typeCounts），已绑定 3 个 IL FIELD Image（imgHeadBg, imgExp, imgHookTime）。这三个正好是 Image 组件的 IL FIELD。

#### 解决方案：扩展 inspect_unity_prefab_layout.py

```python
# 方案 A: 在现有工具中增加 MonoBehaviour 字段提取
# UnityPy 的 MonoBehaviour.read() 可以访问 m_Script → 通过 MonoScript 确定类型
# 然后通过 obj.read_typetree() 获取所有序列化字段的树

def extract_monobehaviour_fields(env):
    """提取所有 MonoBehaviour 的序列化字段"""
    mb_data = {}
    for obj in env.objects:
        if obj.type.name != "MonoBehaviour":
            continue
        data = obj.read()
        script = getattr(data, "m_Script", None)
        if script:
            mono = env.get_asset(script)
            script_name = getattr(mono, "m_ClassName", "")
        else:
            script_name = "Unknown"
        # 尝试读取 typetree
        try:
            tree = obj.read_typetree()
            mb_data[int(obj.path_id)] = {
                "script": script_name,
                "fields": tree
            }
        except:
            pass
    return mb_data
```

典型 Image.sprite 字段在 typetree 中的路径：
```
m_Sprite.fileID / m_Sprite.guid / m_Sprite.type
```
或 Unity 2018+ 格式：
```
m_Sprite.m_PathID / m_Sprite.m_FileID
```

**工作量**: 约 1-2 小时工具增强 + 30 分钟批量提取

**MVP 必需度**: 🟡 中 — 当前 60% 已通过 IL 推断覆盖，剩余可用 atlas 中备选 sprite 肉眼匹配

---

### 2. 本地化文本（lang.bytes / lang_extra.bytes）

#### 关键发现：lang.bytes ≠ MemoryPack 二进制，lang_extra.bytes = UI 键

| 文件 | 格式 | 条目数 | 键格式 | 用途 |
|------|------|:--:|------|------|
| `lang.bytes` | JSON `{"lang": ["key=value", ...]}` | 44,534 | `{prefix}{number}=value` | 通用/系统文本 |
| `lang_extra.bytes` | JSON `{"lang": ["UI10000=確定", ...]}` | 10,827 | `UI{number}=value` | **UI 本地化** |

**`Scx.Lang::Get("UI1000015")` 查找的是 `lang_extra.bytes`**，不是 `lang.bytes`。

#### 全部 7 个 View IL 中引用的 lang key（100% 解析完成）

| Key | 值 | 用途 | 来源 |
|-----|----|------|------|
| `UI1000015` | `進度：<Color=#FFD06C>{0}</Color>` | txtStory 格式化 | MainUIView IL |
| `UI1000026` | `第{0}章{1}<color=#FFD06C>{2}/{3}</color>` | 章节标题 | MainUIView IL |
| `UI1000034` | `<i>自動挑戰中...</i>` | 自动战斗状态 | MainUIView IL |
| `UI1000035` | `<i>自動已完成</i>` | 自动完成状态 | MainUIView IL |
| `UI1022009` | `當前伺服器火爆，請選擇其他伺服器` | 服务器拥挤提示 | LoginView IL |
| `UI1022010` | `伺服器維護中...` | 维护提示 | LoginView IL |
| `UI1022013` | `請詳細閱讀並同意服務協議和隱私政策` | 协议条款 | LoginView IL |
| `UI1027001` | `說明` | 通用"说明" | 其他 IL |
| `UI1032001` | `<i><color=#FFFF99>{0}</color><color=#DAFF5D>+{1}</color></i>` | 数值格式化 | 其他 IL |
| `UI120282` | `星鑽數量不足` | 充值提示 | 其他 IL |
| `UI2049003` | `領取` | 领取按钮 | 其他 IL |
| `UI2049004` | `已領取` | 已领取状态 | 其他 IL |
| `UI3016011` | `星鑽不足` | 充值提示2 | 其他 IL |
| `UI3016012` | `是否前往儲值?` | 充值确认 | 其他 IL |
| `UI3016019` | `當前無法觀看廣告` | 广告不可用 | 其他 IL |

> ✅ **本地化文本缺口已 100% 闭合**。所有 7 个 View IL 中通过 `Ldstr UI...` 引用的 lang key 均已在 `lang_extra.bytes` 中找到对应值。

#### 注意：lang_extra.bytes 键格式

存在两种键格式：
- **短格式** (7 字符): `UI10015` = `推薦出征戰鬥力：` — 战争/老系统
- **长格式** (9 字符): `UI1000015` = `進度：<Color=#FFD06C>{0}</Color>` — **MainUI 使用的格式**

IL `ldstr` 使用的是长格式（9 字符），与 lang_extra.bytes 完全一致。

---

### 3. LayoutGroup 参数

#### 现状

Unity UGUI 的 LayoutGroup（HorizontalLayoutGroup, GridLayoutGroup 等）参数在 MonoBehaviour 序列化字段中：

| 参数 | 字段名 | layout.json 中 | IL 中 |
|------|--------|:--:|:--:|
| Padding (left/right/top/bottom) | `m_Padding` | ❌ | ❌ |
| Spacing | `m_Spacing` | ❌ | ❌ |
| ChildAlignment | `m_ChildAlignment` | ❌ | ❌ |
| ChildForceExpand | `m_ChildForceExpandWidth/Height` | ❌ | ❌ |
| CellSize (Grid) | `m_CellSize` | ❌ | ❌ |
| Constraint/Count (Grid) | `m_Constraint` / `m_ConstraintCount` | ❌ | ❌ |

**可见信息**: 子节点的 RectTransform（sizeDelta, anchoredPosition）已被 layout.json 提取，这给出了经过 LayoutGroup 计算后的**最终坐标和尺寸**。对于 MVP 还原，可以直接使用这些数值硬编码布局，不需要运行时 LayoutGroup 计算。

**结论**: 🟢 对于 MVP，布局坐标和尺寸数据已完全足够——layout.json 中的子节点坐标就是 LayoutGroup 计算后的结果。可以直接硬编码。

---

### 4. Animator 状态机参数

#### 现状

| View | Animator 数 | 具体节点 |
|------|:--:|------|
| MainUIView | 4 | 根 Animator + 3 个子 Animator |
| LotteryDrawFinishView | 多处 | light_orange 内等 |
| HeroRecruitView | 多处 | caiguang2, gyunlizi3/7 等 |

Animator 状态机包含：
- Controller（`.controller` 资源，独立的 Asset）
- 状态参数（float/int/bool）
- 状态转换条件
- 触发时机（IL 代码中的 `SetTrigger`/`SetFloat` 调用）

#### IL 中已找到的 Animator 触发

从 MainUIView IL：
- `Animator::SetTrigger("Show")` — 面板显示
- `Animator::SetTrigger("Hide")` — 面板隐藏
- `Animator::SetBool("IsOpen", true/false)` — 开放状态

#### 解决方案

Animator Controller 是一个独立的 Unity Asset，存储在单独的 bundle 中。需要：
1. 找到 `.controller` 文件的 bundle
2. 解析 AnimatorController 的 StateMachine/State/Transition 结构
3. 映射为 Godot AnimationPlayer 动画

**MVP 必需度**: 🟠 低 — 对于单机 MVP，可用 `Tween` 简单动画替代。Animator 的循环/待机动画（如按钮呼吸效果）可暂用静态替代。

---

### 5. ParticleSystem 参数

#### 现状

| View | PS 数 | 主要节点 | 用途 |
|------|:--:|------|------|
| LotteryDrawFinishView | 190 | gzhu/gzhu2~gzhu6 | 光柱特效 |
| HeroRecruitView | 12 | caiguang2×3, glow×2, gyunlizi3/7, vfx×3 | 演出粒子 |
| MainUIView | 10 | btnGal/@fx05, pnlExpeditionSoftGuide/@vfx, pnlHookSoftGuide/@vfx | UI 点击/循环特效 |

ParticleSystem 参数包括：
- Shape（emitter 形状: Box/Sphere/Cone）
- Main Module（duration, loop, startLifetime, startSpeed, startSize, startColor）
- Emission（rate over time/bursts）
- Renderer（material, renderMode）

这些全部在 MonoBehaviour 序列化字段中。需要 UnityPy 深度解析。

**MVP 必需度**: ⚪ 极低 — ParticleSystem 是纯视觉增强，单机 MVP 可用 Godot 内置 `GPUParticles2D` 或跳过。

---

### 6. AudioClip 音频资源

#### 现状

| View | 推测音频 | 触发时机 |
|------|---------|---------|
| LaunchView | BGM 启动音 | 片头播放 |
| LoginView | 按钮点击音 | 登录/注册 |
| MainUIView | UI 交互音 | 按钮点击、面板打开/关闭 |
| LotteryDrawMainView | BGM 切换、按钮音 | 进入抽卡 |
| HeroRecruitView | 抽卡演出音乐 + 音效 | 演出中 |
| LotteryDrawFinishView | 结果展示音效 | 结果出现 |

音频在 Unity 中为 `AudioClip` + `AudioSource` 组件，存储在独立 bundle 中。

**MVP 必需度**: ⚪ 极低 — 单机 MVP 无音频也可运行。

---

## 二、实现层缺口（明确不够的部分）

### 7. Godot 视图栈（View Stack）

#### 当前状态

```
# home_screen.gd / gacha_screen.gd / startup_screen.gd
# 每次切换调用 app._clear() → 销毁所有子节点 → 无法回退
func show_gacha():
    app._clear("喚靈")  # 完全清空 content
    # ... 重新绘制
```

**问题**: 从 MainUIView → LotteryDrawMainView → 按返回 → 丢失 MainUIView 状态。

#### 原始架构（Unity）

```
ViewBehaviour._allViews: List<View>
├── Open(view): _allViews.Add → Hide(下层) → Instantiate mask → SetParent(mid) → OnOpen
├── Close(): OnClose → Destroy mask → _allViews.Remove → Show(下层) → Destroy
└── DestroyAllMidPriorityView(): 场景切换时全清
```

#### Godot 实现方案

```gdscript
# view_stack.gd — Autoload 单例
extends Node

var _all_views: Array = []
var _current_view = null
var _canvas_layers: Dictionary = {}

# 5 层 CanvasLayer
const LAYER_HIGHEST = 5  # 系统弹窗
const LAYER_HIGH = 4      # PopUp / 工具箱
const LAYER_MID = 3       # 主界面 View
const LAYER_LOW = 2       # 备用底层
const LAYER_ROOT = 1      # Canvas 根容器
const LAYER_LOCK = 0      # 锁屏

func _ready():
    _setup_layers()

func _setup_layers():
    for i in range(6):
        var layer = CanvasLayer.new()
        layer.layer = i * 10  # Godot CanvasLayer.layer 值
        layer.name = ["lock", "root", "low", "mid", "high", "highest"][i]
        add_child(layer)
        _canvas_layers[i] = layer

func push_view(view_scene: PackedScene, params: Dictionary = {}) -> void:
    if _current_view:
        _current_view.hide()  # 隐藏但不销毁
    var view = view_scene.instantiate()
    _canvas_layers[LAYER_MID].add_child(view)
    view.call("on_open", params)
    _all_views.append(view)
    _current_view = view

func pop_view() -> void:
    if _all_views.is_empty():
        return
    var view = _all_views.pop_back()
    view.call("on_close")
    view.queue_free()
    if not _all_views.is_empty():
        _current_view = _all_views.back()
        _current_view.show()

func clear_mid_layer():
    for view in _all_views:
        view.queue_free()
    _all_views.clear()
    _current_view = null
```

#### 工作量

| 子任务 | 描述 | 估算 |
|--------|------|:--:|
| `view_stack.gd` Autoload | 5 层 CanvasLayer + push/pop API | 1h |
| 适配 3 个现有 screen | `home_screen.gd` → `push_view` 模式 | 1h |
| 添加 4 个新 screen | HeroRecruit / LotteryFinish / Login / Launch | 2h |
| 遮罩/动画 | ViewMask + DOTween → Godot Tween | 1h |
| **合计** | | **5h** |

---

### 8. 5 层 CanvasLayer 系统

#### 层级映射

```
Unity                         →  Godot CanvasLayer
─────────────────────────────────────────────────
highestPriorityLayer (系统弹窗) → CanvasLayer layer=50  "highest"
highPriorityLayer    (PopUp)   → CanvasLayer layer=40  "high"
midPriorityLayer     (主View)  → CanvasLayer layer=30  "mid"
lowPriorityLayer     (背景)    → CanvasLayer layer=20  "low"
rootLayer            (根)      → CanvasLayer layer=10  "root"
lockView             (锁屏)    → CanvasLayer layer=0   "lock"
```

#### 层内排序

在 `mid` 层内，多个 View 通过 `move_child(node, get_child_count()-1)` 控制前后顺序：

```gdscript
# 相当于 Unity 的 SetAsLastSibling()
func bring_to_front(node):
    node.get_parent().move_child(node, node.get_parent().get_child_count() - 1)
```

#### 场景切换时清理

```
Unity 场景切换:
  DestroyAllMidPriorityView()    → 清空 mid
  ClearHighPriorityLayer(true)   → 清空 high
  ClearHighestPriorityLayer(true)→ 清空 highest

Godot 场景切换:
  _change_scene() 只影响当前场景树
  Autoload 中的 CanvasLayer 不受影响
  → 需要手动清理对应层
```

**结论**: Godot 的 CanvasLayer 是 Unity Canvas 层级的最直接映射。只需要在 Autoload 中预创建 6 个 CanvasLayer 即可。

---

### 9. CanvasGroup 面板显隐系统

#### MainUIView 的 34 个 CanvasGroup

布局分析中已确定每个 CanvasGroup 对应一个可独立显隐的面板（Panel）。CanvasGroup 实现方式：
- Unity: `CanvasGroup.alpha = 0/1` + `interactable = false/true`
- Godot: `modulate.a = 0/1` + `mouse_filter = MOUSE_FILTER_IGNORE/PASS`

#### 关键 CanvasGroup → 面板映射

| CanvasGroup | 父节点 | 用途 |
|-------------|--------|------|
| irole | — | Spine 角色渲染区 |
| @TopBar | — | 顶部状态栏 |
| pnlPlayerInfo | — | 玩家信息面板 |
| pnlFunnyContent | — | 功能按钮区（唤灵/竞技/冒险/祈愿） |
| pnlStory | — | 主线故事入口 |
| pnlCharge | — | 充值入口区 |
| btnMenu | — | 菜单按钮 |
| btnAssist | — | 援助按钮 |
| pnlCommercialization | — | 商业化入口 |
| @pnlAlternate | — | 活动轮播 |
| pnlGift | — | 礼包入口 |
| btnChapterInfo | — | 章节任务 |
| pnlBottom | — | 底部按钮栏 |
| pnlChat | — | 聊天条 |
| btnGal | — | 约会入口 |
| btnEye | — | 显隐切换 |
| btnChange | — | 壁纸切换 |
| btnHarvest | — | 收获按钮 |
| 12×LimitIconView | — | 限时图标 |
| @Question | — | 问答入口 |
| @BuryGift | — | 埋藏礼包 |
| @DiscountLimitGift | — | 限时折扣 |

#### 面板显隐逻辑（从 IL 提取）

```gdscript
# MainUIView::ShowOrHide() 逻辑
func show_or_hide(show_all: bool):
    var panels = [pnlChat, pnlFunny, pnlPlayerInfo, 
                  pnlCommercialization, btnChapterInfo, pnlBottom]
    for panel in panels:
        panel.visible = show_all
    top_bar.visible = show_all
    btn_body_mask.visible = show_all
    btn_eye.visible = show_all
    btn_change.visible = show_all
```

**Godot 实现**: 每个面板是一个 `Control` 节点，通过 `visible` 属性控制。`ShowOrHide()` 是面板模式切换的关键入口（三态：normal / wallpaper_focus / gal_entry）。

**工作量**: 约 2 小时（34 个面板的显隐逻辑映射到 Godot）

---

### 10. 抽卡演出/结果界面（HeroRecruitView + LotteryDrawFinishView）

#### 当前状态

- `gacha_screen.gd`: LotteryDrawMainView 第一屏（池子选择 + 抽卡按钮）
- `gacha_result_screen.gd`: 简化版结果展示
- **缺失**: 完整抽卡演出流程（HeroRecruitView 的 12 个 ParticleSystem + 9 Canvas 光效层）

#### 完整流程

```
LotteryDrawMainView (gacha_screen.gd)
  ├── 选择池子 → 点"唤灵×1" 或 "唤灵×10"
  ├── DOTween 聚焦动画 → Close
  ↓
HeroRecruitView (缺失 — Godot 未实现)
  ├── 全屏黑幕 → DOTween 入场
  ├── 5 个 Hero Spine 角色逐个显示（剪影 → 高亮 → 揭晓）
  ├── caiguang2×3 光柱闪动
  ├── gyunlizi3/7 粒子结尾
  ├── pnlVideo 视频覆盖（可跳过）
  ├── 演出完成 → Close
  ↓
LotteryDrawFinishView (gacha_result_screen.gd 简化版)
  ├── 10 张卡牌结果展示
  ├── light01_mask~light10_mask 光效遮罩层
  ├── imgBg DOTween 缩放动画
  ├── 用户确认 → Close
  ↓
LotteryDrawMainView (恢复)
```

#### Godot 实现优先级

| 阶段 | 实现 | 优先级 |
|------|------|:--:|
| LotteryDrawMainView | ✅ 已有骨架 | — |
| HeroRecruitView 演出 | 需新建 screen | 🔴 核心 |
| HeroRecruitView 粒子 | 用 Godot 简化替代 | 🟡 次要 |
| LotteryDrawFinishView | 需扩展结果为多卡牌 | 🔴 核心 |
| LotteryDrawFinishView 光效 | 用 modulate + Tween 替代 | 🟡 次要 |

**工作量**: 约 4 小时（含 Spine 角色数据绑定 + 演出流程）

---

### 11. 非 MainUI 界面完整实现

#### 当前覆盖（Godot MVP）

| View | Godot 状态 | 覆盖率 |
|------|:--:|:--:|
| LaunchView | ☑️ `startup_screen.gd` (骨架) | ~30% |
| LoginView | ☑️ `startup_screen.gd` (骨架) | ~25% |
| LoadingView | ☑️ `startup_screen.gd` (骨架) | ~20% |
| MainUIView | ✅ `home_screen.gd` (主体) | ~60% |
| LotteryDrawMainView | ✅ `gacha_screen.gd` (主体) | ~50% |
| HeroRecruitView | ❌ 无 | 0% |
| LotteryDrawFinishView | ☑️ `gacha_result_screen.gd` (简化) | ~25% |
| TopResGrid | ❌ 无 | 0% |

#### 各界面实现难度

| View | layout.json 节点数 | CanvasGroup 数 | PS 数 | 复杂度 | 预计工时 |
|------|:--:|:--:|:--:|------|:--:|
| MainUIView | 212 | 34 | 10 | 🔴 最高 | 4h (完善) |
| LotteryDrawMainView | ~150 | 32 | 0 | 🔴 高 | 3h |
| LoginView | ~100 | 2 | 0 | 🟡 中 | 1.5h |
| HeroRecruitView | ~80 | 8 | 12 | 🟡 中 | 2h |
| LotteryDrawFinishView | ~120 | 多处 | 190 | 🔴 高 | 3h |
| LaunchView | ~30 | 0 | 0 | 🟢 低 | 0.5h |
| LoadingView | ~40 | 0 | 0 | 🟢 低 | 0.5h |
| TopResGrid | ~20 | 0 | 0 | 🟢 低 | 0.5h |
| **合计** | | | | | **~15h** |

---

### 12. DOTween 动画系统

#### Unity 中的使用

从 IL 提取的 DOTween 调用：
```
MainUIView: 入口/退出淡入淡出
LotteryDrawMainView: 池子切换缩放、抽卡按钮弹跳
HeroRecruitView: 黑幕渐变、角色逐个揭晓（序列动画）
LotteryDrawFinishView: 卡牌翻转、imgBg 缩放、光效闪烁
```

#### Godot 替代方案

```gdscript
# Godot Tween 可直接替代 DOTween
# 核心原语：
var tween = create_tween()

# 淡入
tween.tween_property(node, "modulate:a", 1.0, 0.3)

# 缩放
tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.2) \
     .set_ease(Tween.EASE_OUT_BACK)

# 序列动画
tween.tween_property(card1, "modulate:a", 1.0, 0.15)
tween.tween_callback(card1.reveal)
tween.tween_interval(0.1)
tween.tween_property(card2, "modulate:a", 1.0, 0.15)
# ...

# 位置弹跳
tween.tween_property(btn, "position", target_pos, 0.25) \
     .set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
```

**结论**: 🟢 Godot Tween 与 DOTween API 高度相似，1:1 映射即可。不需要第三方插件。

---

## 三、缺口闭合优先级矩阵

### 按 MVP 核心路径排列

```
LaunchView → LoginView → LoadingView → MainUIView → LotteryDrawMainView
                                                       ↓
                                            HeroRecruitView → LotteryDrawFinishView
```

| 优先级 | 缺口 | 分类 | 闭合方式 | 工时 | 阻塞什么 |
|:--:|------|------|------|:--:|------|
| P0 | Godot 视图栈 | 实现层 | 写 `view_stack.gd` Autoload | 1h | 所有界面切换 |
| P0 | 5 层 CanvasLayer | 实现层 | 写入 view_stack.gd | 含在上项 | 渲染层级 |
| P0 | HeroRecruitView 演出 | 实现层 | 新 screen 脚本 | 2h | 抽卡核心体验 |
| P0 | LotteryDrawFinishView 完善 | 实现层 | 扩展 gacha_result | 2h | 抽卡结果 |
| P1 | MainUIView 完善 | 实现层 | 34 CG 面板映射 | 2h | 主界面交互 |
| P1 | LoginView 完善 | 实现层 | 分离 startup_screen | 1.5h | 启动流程 |
| P1 | DOTween → Tween | 实现层 | 逐屏加动画 | 2h | 过渡流畅感 |
| P2 | Image→Sprite 精确绑定 | 数据层 | 增强 inspect 工具 | 2h | 像素级视觉 |
| P2 | LayoutGroup → 硬编码 | 数据层 | layout.json 坐标 | 0h | (使用现成数据) |
| P3 | Animator 状态 | 数据层 | 替换为 Tween | 0h | — |
| P4 | ParticleSystem 参数 | 数据层 | 跳过或用简化版 | 0h | — |
| P4 | AudioClip | 数据层 | 跳过 | 0h | — |

### 工时汇总

| 层级 | 工时 |
|------|:--:|
| P0 实现（阻塞性） | **5h** |
| P1 实现（体验提升） | **5.5h** |
| P2 数据补齐 | **2h** |
| P3-P4 锦上添花 | 跳过 |
| **总计可行 MVP** | **12.5h** |

---

## 四、建议执行路径

### 阶段 1: 地基 (P0, ~5h)

```
1. view_stack.gd — Autoload 单例 + 6 层 CanvasLayer
2. 改造 home_screen.gd 接入 push_view / pop_view
3. 实现 HeroRecruitView 骨架（Layout + Spine 剪影→揭晓）
4. 扩展 gacha_result_screen.gd 为多卡牌
```

完成后的 MVP 可跑通：`启动 → 主界面 → 抽卡 → 演出 → 结果 → 返回主界面`

### 阶段 2: 血肉 (P1, ~5.5h)

```
5. home_screen.gd: 34 个 CG 面板显隐 + ShowOrHide 三态
6. 分离 LoginView / LaunchView / LoadingView 为独立 screen
7. 逐屏加 Tween 动画
```

完成后 MVP 具备完整 UI 交互 + 流畅过渡

### 阶段 3: 精修 (P2, ~2h)

```
8. 增强 inspect_unity_prefab_layout.py 支持 MonoBehaviour 字段提取
9. 批量提取所有 Image.sprite 映射
10. 用精确 sprite 替换现有肉眼猜测的绑定
```

完成后 MVP 视觉像素级匹配原版

---

## 五、关键发现总结

| # | 发现 | 影响 |
|:--:|------|------|
| 1 | `lang_extra.bytes` 是 JSON 不是 MemoryPack 二进制，100% 解析完成 | 文本缺口闭合 |
| 2 | `inspect_unity_prefab_layout.py` 需要扩展才能提取 Image.sprite 绑定 | 需 2h 工具增强 |
| 3 | `layout.json` 已包含 LayoutGroup 计算后的最终坐标，可直接硬编码 | 不需要 LayoutGroup 参数 |
| 4 | Godot CanvasLayer 是 Unity Canvas 层级的最直接映射 | 架构方案明确 |
| 5 | Godot Tween 是 DOTween 的语义等效替代，无需第三方插件 | 动画方案明确 |
| 6 | 当前 MVP 的 `_clear()` 全清模式是最大架构缺陷 | P0 优先修复 |
