# 少女回战故事文本导出与结构分析

分析日期：2026-05-22

目标：整理游戏中的故事文本来源、导出方法、已导出的文本范围，以及单机版可优先使用的剧情文本数据。

## 结论

游戏故事文本不是单一脚本文件，而是由两层数据组成：

```text
1. Static MemoryPack 表
   存储剧情节点、章节结构、角色互动、背景、音频、下一节点等结构化字段。

2. Lang JSON 文本表
   存储 key -> 繁中文本。Static 表中的 plotText/title/summary/name/textId 多数是语言 key。
```

当前已成功导出：

```text
reverse-output\story-texts\gal_plot_resolved.csv
reverse-output\story-texts\gal_plot_resolved.json
reverse-output\story-texts\role_story_chapter_resolved.csv
reverse-output\story-texts\role_story_chapter_resolved.json
reverse-output\story-texts\role_story_resolved.csv
reverse-output\story-texts\date_resolved.csv
reverse-output\story-texts\chapter_resolved.csv
reverse-output\story-texts\story_lang_keys.csv
```

数据规模：

```text
语言表条目        55,361
Gal 剧情节点       7,785
Gal 聊天配置          35
Gal 回忆配置          35
Gal 角色配置          16
角色故事章节          14
角色故事组             2
日期/事件文本         22
章节配置              15
主线 plot 节点       110
故事相关语言 key  22,939
```

## 文本资源位置

TextAsset 干跑扫描定位到关键资源：

```text
resources\assets\yoo\Default\324fcda729f678d13d6dea7bf868e1bc.bundle
  Assets/Game/Static/cht.bytes
  Assets/Game/Static/cn.bytes
  Assets/Game/Static/plot.bytes
  Assets/Game/Static/role_story.bytes
  Assets/Game/Static/role_story_chapter.bytes
  Assets/Game/Static/date.bytes
  Assets/Game/Static/chapter.bytes
  Assets/Game/Static/gal_character.bytes
  Assets/Game/Static/gal_chat.bytes
  Assets/Game/Static/gal_memory.bytes
  Assets/Game/Static/gal_plot.bytes
  Assets/Game/Static/gal_plot_spine.bytes

resources\assets\yoo\Default\d9b9bdbf670710a8292513b8cfafdb4e.bundle
  Assets/Game/Lang/lang.json

resources\assets\yoo\Default\80f715d17a1ca97917c6b587896e60bd.bundle
  Assets/Game/Lang/lang_extra.json
```

注意：UnityPy 导出的 TextAsset 会统一使用 `.bytes` 后缀，所以 `lang.json` 实际落盘为：

```text
reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Lang\lang.bytes
reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Lang\lang_extra.bytes
```

## 导出命令

先扫描所有 TextAsset：

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default `
  reverse-output\assets\unitypy-textasset-dryrun `
  --types TextAsset `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --container-paths `
  --dry-run
```

筛选故事候选：

```powershell
Import-Csv reverse-output\assets\unitypy-textasset-dryrun\unitypy-export-manifest.csv |
  Where-Object {
    $_.name -match 'lang|cht|cn|plot|story|gal|date|favor|guide|chapter|dialog|conversation|rule' -or
    $_.output -match 'lang|cht|cn|plot|story|gal|date|favor|guide|chapter|dialog|conversation|rule'
  } |
  Sort-Object name |
  Export-Csv -NoTypeInformation -Encoding UTF8 reverse-output\assets\unitypy-textasset-dryrun\story-textasset-candidates.csv
```

定向导出关键 TextAsset：

```powershell
python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\324fcda729f678d13d6dea7bf868e1bc.bundle `
  reverse-output\assets\story-textassets-raw `
  --types TextAsset `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --container-paths

python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\d9b9bdbf670710a8292513b8cfafdb4e.bundle `
  reverse-output\assets\story-textassets-raw `
  --types TextAsset `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --container-paths

python reverse-output\scripts\export-unitypy-all-assets.py `
  resources\assets\yoo\Default\80f715d17a1ca97917c6b587896e60bd.bundle `
  reverse-output\assets\story-textassets-raw `
  --types TextAsset `
  --xor-prefix 222 `
  --xor-key 0x16 `
  --container-paths
```

解析静态表并合并语言表：

```powershell
python reverse-output\scripts\export-story-texts.py `
  --static-dir reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Static `
  --lang reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Lang\lang.bytes `
  --lang reverse-output\assets\story-textassets-raw\by_container\Assets\Game\Lang\lang_extra.bytes `
  --out-dir reverse-output\story-texts
```

## 脚本修正

`export-unitypy-all-assets.py` 已修正 TextAsset 二进制导出。

原因：UnityPy 对二进制 TextAsset 的 `m_Script` 可能返回带 surrogate 的 Python 字符串。原脚本用 `errors="replace"` 会把 `FF FF FF` 等 MemoryPack 字节替换成 `?`，导致静态表损坏。

修正：

```python
value.encode("utf-8", errors="surrogateescape")
```

新增解析脚本：

```text
reverse-output\scripts\export-story-texts.py
```

该脚本支持：

```text
MemoryPack 静态表数组读取
MemoryPack 字符串头解析
导出 CSV/JSON
读取 lang/lang_extra
将语言 key 合并成人可读繁中文本
```

## Static 表结构

### GalPlotStaticItem

主 Gal 剧情节点表，核心字段：

```text
id
sceneType
dialogueType
name
spine
optionType
option
keyOption
trait
traitInterval
nextId
plotText
sound
animation
pic
image
bgType
bg
bgm
skip
skipId
```

导出文件：

```text
reverse-output\story-texts\tables\gal_plot.csv
reverse-output\story-texts\gal_plot_resolved.csv
```

`gal_plot_resolved.csv` 增加：

```text
nameText
plotTextResolved
optionResolved
```

### RoleStoryChapterStaticItem

角色故事章节表：

```text
id
frontChapter
stepId
title
summary
reward
battleTag
army
scene
unlockTime
```

导出文件：

```text
reverse-output\story-texts\role_story_chapter_resolved.csv
```

### RoleStoryStaticItem

角色故事组：

```text
id
chapterId
title
pic
```

导出文件：

```text
reverse-output\story-texts\role_story_resolved.csv
```

### DateStaticItem

日期/事件文本：

```text
id
isSpecial
stepType
name
image
position
state
action
image2
position2
state2
action2
textId
aside
asideBg
num
sound
backgroundSound
background
funName
picture
dataId
changeType
dateName
dateMark
```

导出文件：

```text
reverse-output\story-texts\date_resolved.csv
```

### ChapterStaticItem

主章节配置：

```text
id
name
questId
reward
rewardShow
unlock
description
description1
icon
background
tips
posX
posY
mechaShow
picture
box
rewardDes
```

导出文件：

```text
reverse-output\story-texts\chapter_resolved.csv
```

## 样例

Gal 剧情节点样例：

```text
id=105101010
plotText=gal_map_text_105101010
plotTextResolved=夜晚宿舍內的燈毫無徵兆的熄滅了，似乎是停電了。
nextId=105101020
bg=gal_bg_room_1
```

分支节点样例：

```text
id=105101040
name=gal_name_05
nameText=唐笑笑
plotTextResolved=我們該怎麼辦？快想想辦法！
nextId=105101080|105101090|105101100
```

角色故事章节样例：

```text
id=1001001
titleResolved=PSO-101
summaryResolved=暗夜追獵：消失的身影
scene=BattleScene_09_CZDY
```

Date 事件样例：

```text
id=80002
textResolved=黃金平原的西南方向，佇立著一片完全由城鎮與荒樓等建築佇立的廢墟。
background=Roguelike_bg_01
funName=SpriteFromRogue
```

## 单机版使用建议

第一版单机版可以优先使用 `gal_plot_resolved.csv/json` 做角色互动剧情。

推荐最小播放逻辑：

```text
读取 gal_plot_resolved
以 id 作为节点
显示 nameText 和 plotTextResolved
加载 bg/bgm/sound/spine/animation 字段
如果 nextId 是单个 id，点击继续
如果 nextId 是 a|b|c，显示 option 或默认分支按钮
nextId=-1 结束剧情
```

优先实现：

```text
Gal 对话浏览器
角色故事章节列表
Date/Roguelike 事件文本浏览
剧情文本搜索
```

后续再补：

```text
Spine 演出绑定
语音 sound 播放
背景 bg 资源映射
分支 option 文案完整还原
角色名与 heroId 映射
Gal 亲密度/条件解锁
```

## 仍需补齐

```text
1. gal_plot_spine.bytes 字段结构和 spine 资源映射。
2. gal_character.bytes 与 HeroStatic/CharactersStatic 的角色 ID 对应关系。
3. sound 字段到 AudioClip 的资源路径映射。
4. bg/image/pic 字段到 Sprite/Texture2D 的资源路径映射。
5. DialogueEditor.Graph/GuideAsset 的 ScriptableObject 图节点内容导出。
6. role_story_chapter 的 battleTag/army/scene 与战斗/剧情演出关系。
7. 多语言选择：当前合并的是繁中 lang/lang_extra。
```

