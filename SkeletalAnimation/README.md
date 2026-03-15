# DragonBones 骨骼动画 × PixiJS 5 接入教程

> 本示例展示如何在浏览器中，使用 **PixiJS 5** + **pixi-dragonbones 5.7** 加载并播放 DragonBones 导出的骨骼动画资源，包含多角色切换、多纹理图集、动画列表动态生成等完整实现。

---

## 快速预览

```bash
# 在目录下启动任意静态服务器
npx serve .
# 或
python -m http.server 8765
```

打开 `http://localhost:8765/index.html`，左侧点击角色名即可切换，底部按钮切换动画。

---

## 目录结构

```
guangmingnvshen/
├── index.html              # 演示入口（核心代码均在此文件）
├── assets/                 # 骨骼动画资源
│   ├── *_ske_*.dbbin       # 骨骼数据（二进制格式）
│   ├── *_tex_*.txt / .json # 纹理图集描述（JSON 格式）
│   └── *_tex_*.png         # 纹理图集图片
└── npm_libs/               # 本地依赖
    └── node_modules/
        ├── pixi.js/        # PixiJS 5.x
        └── pixi-dragonbones/ # DragonBones PIXI 适配层 5.7
```

---

## DragonBones 资源说明

DragonBones 导出的每个角色由 **三类文件** 组成：

| 文件 | 格式 | 作用 |
|------|------|------|
| `角色名_ske_版本.dbbin` | 二进制 | 骨骼结构、动画曲线、Mesh 顶点数据 |
| `角色名_tex_版本.txt` | JSON | 纹理图集描述：每张子图在图集中的位置（region）和原始尺寸（frame） |
| `角色名_tex_版本.png` | PNG | 将所有部件打包进一张大图的纹理图集 |

部分角色拥有 **多张纹理图集**（`_tex_0_`、`_tex_1_`、`_tex_2_`），所有图集共用同一套骨骼数据，需要全部注册到同一个 `dbName` 下。

### 纹理图集 JSON 格式示例

```json
{
  "name": "shouhunvshen_h",
  "imagePath": "shouhunvshen_h_tex_0.png",
  "width": 2048,
  "height": 2048,
  "SubTexture": [
    {
      "name": "body/torso",
      "x": 120, "y": 44, "width": 96, "height": 128,
      "frameX": -8, "frameY": -12, "frameWidth": 112, "frameHeight": 148
    }
  ]
}
```

- `x / y / width / height`：子图在图集 PNG 中的像素坐标（**region**）
- `frameX / frameY / frameWidth / frameHeight`：导出时被裁掉的空白边信息（**trim**），frameX/Y 为负值，表示可见内容在原始帧内的偏移

---

## 核心代码解析

### 1. 加载流程

```js
// ① 加载骨骼二进制
const skeBuffer = await fetch('assets/shouhunvshen_ske_0_21234.dbbin').then(r => r.arrayBuffer());

// ② 加载纹理图集（多图集循环执行）
const jsonText = await fetch('assets/shouhunvshen_tex_0_21234.txt').then(r => r.text());
const bt = await loadBaseTexture('assets/shouhunvshen_tex_0_21021.png'); // → PIXI.BaseTexture

// ③ 注册到工厂（同一 dbName 多次调用 parseTextureAtlasData）
const factory = dragonBones.PixiFactory.factory;
factory.parseDragonBonesData(skeBuffer, 'shouhunvshen_h');
factory.parseTextureAtlasData(JSON.parse(jsonText), bt, 'shouhunvshen_h');

// ④ 构建骨架并播放
const armatureDisplay = factory.buildArmatureDisplay('Armature', 'shouhunvshen_h');
armatureDisplay.animation.play('idle', 0); // 0 = 循环
app.stage.addChild(armatureDisplay);
```

> **关键**：`parseTextureAtlasData` 的第二个参数必须传 **`PIXI.BaseTexture`**，而不是 `PIXI.Texture`。DragonBones 内部会用它构造每个 SubTexture：`new PIXI.Texture(baseTexture, region)`。

---

### 2. PIXI 5 兼容 Patch（重要！）

pixi-dragonbones 5.7 是为 PIXI 4 编写的，在 PIXI 5 下需要两处 patch：

#### Patch 1：修复 `_buildSlot` — mesh 初始化崩溃

原始代码用 PIXI 4 API 创建 Mesh：
```js
// DragonBones 原代码（PIXI 4 风格，PIXI 5 下 texture 为 null → render 崩溃）
new PIXI.mesh.Mesh(null, null, null, null, PIXI.mesh.Mesh.DRAW_MODES.TRIANGLES)
```

Patch 后改为 PIXI 5 的 `SimpleMesh`，用合法占位纹理避免 null：
```js
dragonBones.PixiFactory.prototype._buildSlot = function(_dp, slotData, armature) {
  const slot = dragonBones.BaseObject.borrowObject(dragonBones.PixiSlot);
  slot.init(slotData, armature,
    new PIXI.Sprite(PIXI.Texture.WHITE),
    new PIXI.SimpleMesh(PIXI.Texture.WHITE)  // 用 WHITE 而非 null
  );
  return slot;
};
```

#### Patch 2：修复 UV 双重变换 — 蒙皮位置偏移

DragonBones 计算 mesh UV 的方式是**全图集归一化坐标**（直接相对整张 PNG 的 0~1）：

```
uvs[i]   = (region.x + u * region.width)  / atlasWidth
uvs[i+1] = (region.y + v * region.height) / atlasHeight
```

但随后将 mesh.texture 设为子纹理（SubTexture），PIXI 5 的 `MeshMaterial._uvTransform` 会对 UV 再做一次 `frame → baseTexture` 的缩放变换，导致 **UV 被变换两次**，蒙皮全部错位。

修复方法：在 `_updateFrame` 之后，将 mesh.texture 替换为覆盖整张图集的全尺寸 Texture 包装：

```js
dragonBones.PixiSlot.prototype._updateFrame = function() {
  _origUpdateFrame.call(this);        // 先执行原逻辑
  const d = this._renderDisplay;
  if (!(d instanceof PIXI.SimpleMesh)) return;
  if (!d.texture) { d.texture = PIXI.Texture.WHITE; d.visible = false; return; }

  const bt = d.texture.baseTexture;
  if (!bt) { d.texture = PIXI.Texture.WHITE; return; }

  // 替换为全尺寸包装 → PIXI 不再做 sub-texture UV remap
  if (!bt._fullTex) bt._fullTex = new PIXI.Texture(bt, new PIXI.Rectangle(0,0,bt.width,bt.height));
  d.texture = bt._fullTex;
};
```

#### Patch 3：PIXI 4 Mesh API shim

DragonBones 通过 `.uvs`、`.indices`、`.dirty`、`.indexDirty` 属性更新 mesh 数据（PIXI 4 风格）。PIXI 5 的 `SimpleMesh` 需要通过 `geometry.buffers` 更新，通过属性代理桥接：

```js
function defProp(name, getBuf) {
  Object.defineProperty(PIXI.SimpleMesh.prototype, name, {
    get() { return this['_db_' + name]; },
    set(v) {
      this['_db_' + name] = v;
      if (!v || !this.geometry) return;
      const buf = getBuf(this.geometry);
      if (!buf) return;
      if (v instanceof Float32Array || v instanceof Uint16Array) buf.data = v;
      buf.update();
    }
  });
}
defProp('uvs',        g => g.buffers[1]);
defProp('indices',    g => g.indexBuffer);
defProp('dirty',      g => g.buffers[0]);
defProp('indexDirty', g => g.indexBuffer);
```

---

### 3. 多角色管理

每个角色定义为一个配置对象：

```js
const CHARS = [
  {
    label: '守魂女神',
    ske: 'assets/shouhunvshen_ske_0_21234.dbbin',
    texAtlas: [                                        // 多图集：数组
      { json: 'assets/shouhunvshen_tex_0_21234.txt', png: 'assets/shouhunvshen_tex_0_21021.png' },
      { json: 'assets/shouhunvshen_tex_1_21234.txt', png: 'assets/shouhunvshen_tex_1_21235.png' },
    ],
    dbName: 'shouhunvshen_h',  // DragonBones 内部注册名
    armName: 'Armature',       // 骨架名（通常固定为 Armature）
    scale: 0.5,
    offsetY: 230               // 角色垂直偏移（px，相对屏幕中心）
  },
  // ...
];
```

切换角色时按需加载（已加载的角色缓存在 `loadedSet`，不重复请求）：

```js
async function switchChar(idx) {
  if (loadedSet.has(idx)) { showChar(idx); return; }

  const c = CHARS[idx];
  try {
    const skeBuffer = await fetch(c.ske).then(r => r.arrayBuffer());
    factory.parseDragonBonesData(skeBuffer, c.dbName);

    for (const ta of c.texAtlas) {
      const [jsonText, bt] = await Promise.all([
        fetch(ta.json).then(r => r.text()),
        loadBaseTexture(ta.png)
      ]);
      factory.parseTextureAtlasData(JSON.parse(jsonText), bt, c.dbName);
    }
    loadedSet.add(idx);
  } catch(e) {
    // 加载失败时清理残留数据，避免污染后续角色
    factory.removeDragonBonesData(c.dbName);
    factory.removeTextureAtlasData(c.dbName);
    throw e;
  }

  showChar(idx);
}
```

---

## 资源清单（13 个角色）

| 角色 | dbName | 图集数 |
|------|--------|--------|
| 光明神使 | `guangmingnvsheng_1` | 1 |
| 光明女神 | `光明女神_h` | 1 |
| 疾风剑客 | `jifengzhiying_h` | 1 |
| 守魂女神 | `shouhunvshen_h` | 2 |
| 神秘女神 | `shenminvshen_h` | 1 |
| 小花仙 | `xiaohuaxian_h` | 1 |
| 银龙公主 | `yinlongnvshen` | 1 |
| 月亮女神 | `yueliangnvshen_h` | 2 |
| 战争女神 | `战争女神_h` | 3 |
| 血腥之雨 | `血腥之雨_h01` | 2 |
| 青春女神 | `青春女神_h` | 2 |
| 梅蒂亚 | `meidiya_h` | 2 |
| 暴走龙女 | `baozoulongnv_h` | 2 |

---

## 添加新角色

1. 将 `角色_ske_版本.dbbin`、`角色_tex_版本.txt`、`角色_tex_版本.png` 放入 `assets/` 目录
2. 在 `index.html` 的 `CHARS` 数组中添加一项：

```js
{
  label: '新角色',
  ske: 'assets/新角色_ske_xxxxx.dbbin',
  texAtlas: [
    { json: 'assets/新角色_tex_xxxxx.txt', png: 'assets/新角色_tex_xxxxx.png' }
  ],
  dbName: '新角色_h',   // 从 txt 文件的 "name" 字段获取
  armName: 'Armature',
  scale: 0.5, offsetY: 220
}
```

3. 刷新页面，左侧面板自动出现新按钮。

---

## 依赖版本

| 库 | 版本 | 说明 |
|----|------|------|
| [PixiJS](https://pixijs.com/) | 5.x | 2D 渲染引擎 |
| [pixi-dragonbones](https://github.com/DragonBones/DragonBonesJS) | 5.7 | DragonBones PIXI 适配层 |

> pixi-dragonbones 5.7 官方支持 PIXI 4，在 PIXI 5 下需要本示例中的三处兼容 patch 才能正常工作。

---

## 可清理的文件

以下文件为开发调试过程中产生，不影响演示运行，可直接删除：

```
analyze_bin.py  check_*.py  dump_*.py  find_error.py  inspect.py
parse_dbbin.py  patch_db.py  scan_assets.py
gameCommonSdk.js  gameMainSdk.js
guangmingnvsheng_1_ske_17694.json  guangmingnvsheng_ske_23117.json
*.jpg  (背景图)
anyingsishennvshen_tex_*.png  bingshuangnvshen_tex_*.png  (无骨骼数据的孤立 PNG)
sp_hero*.png / *.json / *.atlas  (Spine 格式资源，非 DragonBones)
citynpc_*.png  god*.png  goddess*.png  ...  (UI/图标，非骨骼动画)
```
