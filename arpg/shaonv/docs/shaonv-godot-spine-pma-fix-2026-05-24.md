# Spine Baked 渲染 PMA 修复与性能优化

> 2026-05-24 · 解决嘴部黑边 + 图像模糊 + 动画卡顿

---

## PMA (Pre-Multiplied Alpha) 黑边修复

### 根因

Spine 图集标记 `pma:true`：

```
hero_003Dh.atlas.txt:
  pma:true
  scale:0.33
  filter:Linear,Linear
```

PMA 纹理中 RGB 值已预先乘以 Alpha：
```
正常纹理: final = src.rgb × src.a + dst.rgb × (1 - src.a)
PMA 纹理: final = src.rgb + dst.rgb × (1 - src.a)    ← 不再乘 src.a
```

Godot `draw_polygon` 默认用标准 Alpha 混合。PMA 纹理被套用标准混合后，Alpha 被乘两次：
- 半透明边缘（alpha < 1）→ RGB 变暗 → 黑边/黑圈
- 嘴部、头发边缘等半透明区域最明显

### 修复

在 `spine_baked_preview_canvas.gd` 的 `_ready()` 中设置 PMA 混合模式：

```gdscript
var mat := CanvasItemMaterial.new()
mat.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
material = mat
```

### 验证

全部 5 个角色 atlas 均为 `pma:true`：
- hero_001 (哪吒)、hero_003Dh (莉莉絲)、hero_005 (蔡文姬)
- hero_016 (天狐妲己)、hero_017 (女帝)

修复后嘴部黑边消失，半透明区域显示正常。

---

## 图像清晰度

### 当前状态

| 属性 | 值 | 影响 |
|------|----|------|
| 图集分辨率 | 2048×2048 | ✅ 足够高 |
| 图集比例 | scale:0.33 (1/3 原始) | ⚠️ 相当于 ~676px 有效分辨率 |
| 图集过滤 | Linear,Linear | ✅ 双线性平滑 |
| 显示区域 | ~734×720px | ✅ 足够大 |
| 缩放系数 | min+bounds * 0.98 | ✅ 接近填满（原 0.94→0.98） |

### 已优化

- `scale_factor * 0.94` → `* 0.98`：字符放大 4%，减少浪费的显示空间
- 纹理使用 `ImageTexture` 默认线性过滤，无需额外设置
- 原始 Spine 图集在手机端使用的实际分辨率约为 676px（2048 × 0.33），与 Godot 渲染分辨率接近

### 剩余差距

- Godot 1280×720 视口 < 手机物理分辨率（通常 1080×2400+）
- Godot CanvasItem 在 720p 下通过 `draw_polygon` 渲染，每像素精确定位
- 如需更高清晰度：提升视口尺寸至 1920×1080，等比缩放 UI

---

## 动画卡顿优化

### 当前数据

| 属性 | 值 |
|------|-----|
| Baked FPS | 8 |
| 帧数 | 10 (wait 动画) |
| 时长 | 1.2 秒 |
| 原始 Spine FPS | 30 (推测) |

### 原因

baked 动画以 8fps 烘焙 → 只有 10 帧 → 无法帧间插值。原始 Spine 运行时以 30fps 用骨骼插值生成中间帧，baked 版本丢失了这些中间帧。

### 已优化

- `_process` 中只在帧号变化时调用 `queue_redraw()`（原每帧都 redraw，60fps 下 50 次无效调用）
- 减少约 80% 的 CPU draw 调用

### 进一步优化路径

- 重新烘焙时提高 fps（如 30fps）→ 产生更多帧 → 更流畅
- 或在渲染时对相邻帧的三角形做线性插值 → 需要修改 `_draw_baked_clip`
- 或接入 spine-godot 原生运行时（需要解决 GDExtension 兼容性问题）

---

## 图集规格参考

```
hero_003Dh.png
  尺寸: 2048 × 2048
  过滤: Linear, Linear
  PMA: true
  比例: 0.33
  格式: RGBA8888 (推测，1.8MB)

Baked JSON
  动画: wait (10帧) / wait1 (10帧)
  附着点: 96 个 (全 blend=normal)
  每个附着点: page + uvs + triangles + color[1,1,1,1]
  坐标系: Spine world (Godot 渲染时翻转 Y)
```
