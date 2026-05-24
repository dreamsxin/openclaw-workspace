# MainUI 资源分析

时间：2026-05-23

## 1. 导出源

MainUI 大部分 Sprite 在同一个 YooAsset bundle 中：

| 字段 | 值 |
|---|---|
| Bundle hash | `ffa3b401f54b74b5ba41f31bb1f03c7b` |
| 物理路径 | `files\yoo\Default\UnpackBundleFiles\ff\ffa3b401f54b74b5ba41f31bb1f03c7b\__data` |
| Bundle 大小 | 261,250 bytes |
| 包含资源 | 1 个 SpriteAtlas + 71 个 Sprite |
| SpriteAtlas 尺寸 | 1024 × 2048 (ASTC 6×6) |

## 2. 导出产物

已导出到 `standalone/godot-mvp/assets/ui/mainui/`：

| 类别 | 数量 | 命名模式 |
|---|---|---|
| 按钮图 | 25 | `mainui_btn_01.png` ~ `mainui_btn_25.png` |
| 装饰图 | 25 | `mainui_img_02.png` ~ `mainui_img_45.png`（含独立 bundle 的 01/10/12/44） |
| 文本标签 | 9 | `mainui_txt_01.png` ~ `mainui_txt_09.png` |

## 3. 关键图片用途分析

### 大型装饰 (img)
| 文件 | 大小 | 视觉内容 | 推测用途 |
|---|---|---|---|
| `mainui_img_01.png` | 640KB | 全屏主城背景 | `imgBackGround` — WallpaperPanel 背景 |
| `mainui_img_44.png` | 201KB | 全屏界面背景 | MainUIView 整屏替代背景 |
| `mainui_img_05.png` | 53KB | "新手狂欢"横幅 | pnlGift 活动入口横幅 |
| `mainui_img_37.png` | 88KB | 同款横幅(大) | 横幅轮播 (@pnlAlternate) |
| `mainui_img_02.png` | 17KB | 橙金发光边框面板 | pnlPlayerInfo / 任务面板底框 |
| `mainui_img_12.png` | 70KB | 装饰面板 | 主界面装饰候选 |

### 头像相关 (img)
| 文件 | 视觉内容 | 推测用途 |
|---|---|---|
| `mainui_img_03.png` | 白色圆环 | `imgHeadBg` 头像外框 |
| `mainui_img_04.png` | 金色发光圆环 | `imgExp` 等级/EXP 进度环 |
| `mainui_img_10.png` | 金色装饰条 | `@TopBar` 顶部装饰 |

### 按钮入口 (btn)
| 文件 | 大小 | 视觉内容 | 推测用途 |
|---|---|---|---|
| `mainui_btn_22.png` | 32KB | 华丽拱门·漩涡中心 | 喚靈/pnlFunnyContent 主入口 |
| `mainui_btn_25.png` | 39KB | 华丽拱门·星冠顶 | 祈願 主入口 |
| `mainui_btn_14~20.png` | 13~15KB | 中型按钮 | 底部栏/功能按钮 |
| `mainui_btn_01~13.png` | 1~12KB | 小型图标 | 装饰/红点/小按钮 |

### 文本标签 (txt)
| 文件 | 视觉内容 | 推测用途 |
|---|---|---|
| `mainui_txt_01.png` | 米白圆角面板 | 公告/对话气泡背景 |
| `mainui_txt_02~09.png` | 文字标签 | 按钮文字/标题标签 |

### 背景 (bg)
| 文件 | 视觉内容 | 推测用途 |
|---|---|---|
| `mainui_bg_01~08.png` | 主城背景图 | 不同时段/主题的 WallpaperPanel 背景 |

## 4. 经验总结

### 4.1 SpriteAtlas 导出
- SpriteAtlas 打包的 sprite 每个有独立 `m_Rect`，UnityPy 可正确裁剪导出
- 所有 sprite 共享同一张 Texture2D (1024×2048)
- 导出时需确保 UnityPy 版本支持 SpriteAtlas 读取

### 4.2 复刻策略
- **不要用色块模拟原图**，必须使用真实图片资源
- 按钮图是带文字的完整图片，不是"背景+文字叠加"
- SpriteAtlas 中的图片打包紧密，导出为独立 PNG 后尺寸质量完好
- 优先使用 `mainui_btn_22/25`（拱门）作为喚靈/祈願入口，`mainui_img_02` 作为面板背景

### 4.3 资源缺口
- 底部栏 (pnlBottom) 的独立按钮图未在 MainUI.spriteatlas 中；可能在 Common spriteatlas 或独立 bundle
- `btnChapterInfo` 的章节任务面板背景图未定位
- pnlChat 世界聊天条背景未定位
- svRes (TopResGrid) 的资源图标（金币/钻石/券）在 `Sprite/Item/ItemResources` 中
