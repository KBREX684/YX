# 美术风格与制作底基 Art Direction

版本：v1.0.0
关联总设定版本：v0.8.1
状态：美术底基定案
创建日期：2026-05-14
最后更新：2026-05-14

## 用途

本文档是 YX 项目的视觉最高规约，用于约束角色、原形、怪物、场景、动画、特效、UI、占位资源、外包素材和 AI 辅助出图。

当视觉表现与工程实现发生冲突时：

1. 先服从 `docs/00-design-pillars.md`。
2. 再服从本文档的美术方向与制作底基。
3. 最后由 `docs/00-tech-constraints.md` 决定 Godot 内实现方式。

## 一、核心美术定位

**2.5D Live 表现 + 厚涂精美二次元风格 + R16+ 恐怖。**

目标不是像素恐怖，也不是写实 3D 恐怖。画面应该像一张会呼吸、会腐坏、会注视玩家的厚涂二次元插画：角色和原形有魅力，场景有体积和湿冷质感，怪物在大多数时间只通过影子、声音、光线和环境变化存在。

## 二、制作底基定案

第一阶段采用 **Godot 原生 2D Live 管线**：

当前制作答案：

- **画什么用什么：** 源文件可用 Krita / Clip Studio Paint / Photoshop；默认免费底基推荐 Krita，商业团队或外包可按自身习惯使用 CSP/PS，但交付必须是可切层源文件 + PNG 运行资源。
- **动画在哪里做：** 第一阶段角色、原形、怪物现形和场景动效都在 Godot 编辑器内制作和预览，以 `AnimationPlayer` 为主，`Skeleton2D` / `Bone2D` / `Polygon2D` 负责骨骼与局部变形。
- **2.5D Live 怎么做：** 分层厚涂 PNG + Godot 原生节点 + 视差 + 光影 + Shader 参数动画；不是 Live2D Cubism 项目，也不是 Spine 项目。
- **什么时候评估外部工具：** 垂直切片证明 Godot 原生管线无法支撑高价值角色演出后，第二阶段再评估 Spine 或 Live2D。

| 用途 | 第一阶段底基 | 可选辅助 | 不作为第一阶段底基 |
|---|---|---|---|
| 分层绘制 | Krita / Clip Studio Paint / Photoshop 均可；交付以分层源文件 + PNG 导出为准 | Blender 仅可用于透视灰盒和光影参考 | 只交付单张扁平图 |
| 角色与原形动画 | Godot `AnimationPlayer` + `Skeleton2D` / `Bone2D` / `Polygon2D` / `Sprite2D` | `AnimationTree` 仅在需要混合状态时启用 | Live2D Cubism 运行时 |
| 场景 2.5D | `Node2D` 场景嵌套 + `Sprite2D` 分层 + `Parallax2D` + 遮挡层 | Blender blockout 后 paintover | 运行时完整 3D 场景 |
| 恐怖表现 | `ShaderMaterial` + `CanvasModulate` + `Light2D` + `GPUParticles2D` + 音频同步 | 帧序列特效可用于关键现形 | 大量视频贴片 |
| 外部骨骼工具 | 暂不引入 | Spine 可在第二阶段评估 | DragonBones / 未维护运行时 |

**结论：**

- 第一阶段不使用 Live2D Cubism 作为底基，因为官方 SDK 平台不包含 Godot，Godot 接入通常依赖非官方扩展或额外原生适配。
- 第一阶段不使用 Spine 作为底基，虽然 Spine 已有 Godot runtime，但会引入额外授权、GDExtension/自定义模块和素材导入流程；等垂直切片证明角色演出确实需要后再评估。
- 第一阶段所有 2.5D Live 动画必须能用 Godot 原生节点、资源和 `.tscn` / `.tres` 管理。

## 三、风格边界

### 必须保留

- 厚涂体积感：角色、原形和怪物都有明确受光面、背光面和材质层次。
- 精美二次元：五官、发丝、服装、姿态具有角色吸引力，但不走 Q 版和纯萌系。
- 恐怖污损：破损、霉斑、潮湿、旧纸、锈迹、灰尘、荧光灯污染、血迹残留可以出现，但不过度血腥。
- 固定镜头构图：场景以横向箱庭空间组织，强调前景遮挡、中景可交互、背景压迫。
- “看不清但能学会”：怪物本体不常亮相，视觉反馈必须服务规则推理。

### 禁止项

- 像素风、低多边形手绘、Q 版、卡通扁平、欧美写实血浆恐怖。
- 用单色滤镜替代美术设计。
- 角色完全偶像化、基地完全温馨化，从而消解异常危险。
- 怪物长期完整展示，导致“看不见的怪物”失效。
- 第一阶段为追求演出引入不可维护的外部运行时或自研动画框架。

## 四、资产分层规范

### 角色 / 拟人原形

每个可动角色至少拆分：

- `body_torso`
- `head`
- `hair_back`
- `hair_front`
- `arm_l` / `arm_r`
- `leg_l` / `leg_r`
- `eye_l` / `eye_r`
- `mouth`
- `cloth_front`
- `cloth_back`
- `shadow`

拟人原形额外保留：

- `anomaly_mark`
- `emotion_overlay`
- `corruption_overlay`
- `route_hint_humanoid` / `route_hint_horror` / `route_hint_tool`

### 怪物

怪物默认不按完整角色展示，而按“可感知层”拆分：

- `silhouette_far`
- `silhouette_close`
- `limb_hint`
- `eye_or_face_hint`
- `shadow_cast`
- `trace_footprint`
- `trace_handprint`
- `manifest_fx_mask`

大只第一阶段只需要弱光轮廓、走廊阴影、脚印痕迹、广播室门外剪影和收容末段完整现形。

### 场景

破败校园场景至少分为：

- `bg_far`：远景窗外、远端走廊、暗处轮廓
- `bg_mid`：墙体、门、公告栏、固定大物件
- `playfield`：玩家可走区域、交互物基准层
- `fg_occluder`：前景桌椅、墙角、门框、遮挡物
- `light_shadow`：灯光、阴影、污渍、局部雾
- `fx`：灰尘、闪烁、异常扰动
- `interactable`：门锁、纸条、道具、仪式物

## 五、动画实现规范

### Godot 节点基准

| 对象 | 推荐节点结构 | 说明 |
|---|---|---|
| 玩家 | `CharacterBody2D` + `Sprite2D/Polygon2D` + `Skeleton2D` + `AnimationPlayer` | 移动状态由玩法状态机驱动，动画本身由 `AnimationPlayer` 播放 |
| 拟人原形 | `Node2D` + `Skeleton2D` + `AnimationPlayer` | 跟随、牵手、待机、情绪反应均用短循环 |
| 恐怖原形纹身 | `Sprite2D` + `ShaderMaterial` + `AnimationPlayer` | 以亮暗、扩散、纹路蠕动表现，不做实体跟随 |
| 工具原形 | `Node2D` + `Sprite2D` + `Light2D` + `AnimationPlayer` | 活体手电、地图、钥匙等以功能反馈为主 |
| 怪物现形 | `Node2D` + `Sprite2D/Polygon2D` + Shader + 粒子 | 现形窗口短，重点是剪影、拖影和声音同步 |
| 场景 | `Node2D` + 多层 `Sprite2D` + `Parallax2D` + `Light2D` | 固定镜头下制造纵深 |

### 动画类型

| 类型 | 使用方式 | 目标 |
|---|---|---|
| 待机微动 | `AnimationPlayer` 循环曲线 | 呼吸、头发、衣摆、光影轻微变化 |
| 骨骼摆动 | `Skeleton2D` / `Bone2D` | 角色、拟人原形、局部怪物肢体 |
| 网格/多边形变形 | `Polygon2D` 权重 + 骨骼 | 头发、布料、非人肢体、怪物影子 |
| 状态切换 | `AnimationPlayer`，必要时 `AnimationTree` | idle / walk / crouch / hide / fear 等 |
| 恐怖扰动 | Shader + `AnimationPlayer` 参数轨 | 手电闪烁、理智干扰、现形噪点 |
| 关键帧特效 | 帧序列 PNG 或 `GPUParticles2D` | 现形、污染扩散、纸张燃烧等短效果 |

### 帧率与长度

- 待机循环：3–8 秒，避免肉眼看出机械循环。
- 行走/奔跑：优先骨骼循环，必要时用 12/24 fps 帧序列补关键姿势。
- 现形动画：0.5–3 秒，宁短不长。
- 收容关键动画：允许 3–8 秒，但必须可被打断或失败。
- 所有动画必须能在 Godot 编辑器内预览，不依赖外部软件运行时。

## 六、导出与命名规范

### 源文件

- 源文件可为 `.kra` / `.clip` / `.psd`。
- 若源文件超过 10MB，需评估 Git LFS 或外部源资产库。
- 源文件不是 Godot 运行依赖，运行资源必须导出为 PNG / OGG / WAV / `.tres` / `.tscn`。

### 导出文件

| 类型 | 格式 | 说明 |
|---|---|---|
| 透明角色层 | PNG | 保留透明通道，启用 Fix Alpha Border |
| 大背景层 | PNG；后续可评估 WebP | 第一阶段优先稳定与画质 |
| 法线图 | PNG，后缀 `_normal` | 给 `Light2D` 使用 |
| 帧序列 | PNG 序列 | 仅用于短特效或关键现形 |
| 动画数据 | `.tscn` / `.tres` | 由 Godot 管理 |

命名格式：

```text
资产类型_对象_部位_状态_序号

char_player_body_idle_01.png
origin_dazhi_hair_front_humanoid_01.png
monster_dazhi_silhouette_far_01.png
env_school_corridor_fg_occluder_01.png
fx_sanity_noise_mask_01.png
```

## 七、破败校园 Demo 视觉基准

### 关键词

潮湿、失修、荧光灯、旧广播、空教室、粉笔灰、发霉木门、贴错的班牌、走廊尽头的高大阴影。

### 色彩

- 主色：低饱和青绿、灰蓝、旧白、霉黄色。
- 危险色：低亮度暗红、脏橙、冷白闪烁。
- 禁止：大面积鲜紫、亮粉、纯黑纯白硬对比、过度赛博霓虹。

### 光影

- 光源主要来自荧光灯、手电、广播室设备灯、窗外冷光。
- 阴影应有层次，不是纯黑色块。
- 手电不是万能照明，而是会暴露规则、触发恐惧或制造误判的工具。

### 大只现形

- 首次现形：远处弱光轮廓，只证明“它很高”。
- 广播室现形：门外正面剪影，证明“广播与它有关”。
- 收容末段：完整现形 5 秒左右，作为高风险奖励。

## 八、外包 / AI 辅助图验收清单

任何外包、采购或 AI 辅助生成图进入项目，需要通过以下检查：

- [ ] 是否符合 2.5D Live + 厚涂精美二次元 + R16+ 恐怖。
- [ ] 是否能拆成可动画的层，而不是只能当静态图。
- [ ] 是否保留异常感，未把原形完全萌宠化。
- [ ] 是否没有明显像素风、低多边形、Q 版或欧美写实恐怖倾向。
- [ ] 是否能在 1080p 固定镜头下阅读清楚。
- [ ] 是否有干净透明边缘，没有 AI 伪影、脏边和无法修复的手部/文字错误。
- [ ] 是否有源文件或足够高分辨率，便于后续切层。
- [ ] 是否满足商用授权。

## 九、后续工具评估门槛

### Spine

第二阶段可以评估 Spine，但必须满足：

- 官方 Godot runtime 与当前 Godot 版本兼容。
- 授权成本和 runtime license 可接受。
- 不破坏 GDScript-first 与低代码优先原则。
- 至少 1 个拟人原形完整流程证明它显著优于 Godot 原生骨骼。

### Live2D Cubism

第二阶段以后才可评估。进入项目必须满足：

- Godot 接入方案通过插件采纳门槛。
- 可导出并稳定运行在 Windows 64-bit。
- 不要求维护自定义引擎分支。
- 只用于高价值角色演出、基地互动或剧情立绘，不用于第一阶段核心副本玩法。

## 十、参考依据

- [Godot 官方 2D 骨骼文档](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html)：`Skeleton2D` / `Bone2D` / `Polygon2D` 可用于 Godot 内建 2D 骨骼变形。
- [Godot 官方 AnimationTree 文档](https://docs.godotengine.org/en/4.0/tutorials/animation/animation_tree.html)：需要混合、过渡和分层动画时使用 `AnimationTree`。
- [Godot 官方 Parallax2D 文档](https://docs.godotengine.org/en/4.5/tutorials/2d/2d_parallax.html)：`Parallax2D` 用于 2D 视差与纵深。
- [Spine 官方 Godot runtime 文档](https://esotericsoftware.com/spine-godot)：Spine 支持 Godot，但会引入额外 runtime 与授权边界。
- [Live2D 官方 SDK 平台文档](https://www.live2d.com/en/sdk/about/)：官方 SDK 平台列表不包含 Godot。
- [Krita 官方网站](https://krita.org/en/)：Krita 是 free/open source painting program，可作为默认免费绘制底基。

## 版本记录

### v1.0.0 - 2026-05-14

- 建立美术风格与制作底基文档。
- 定案第一阶段使用 Godot 原生 2D Live 管线：`AnimationPlayer` + `Skeleton2D` / `Bone2D` / `Polygon2D` + 分层 `Sprite2D` + `Parallax2D` + Shader / Light2D。
- 明确 Live2D Cubism 与 Spine 不作为第一阶段底基，只作为第二阶段后高价值角色演出的候选。
