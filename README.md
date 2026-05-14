# YX

> 2.5D 恐怖躲藏探索 + 无限流异常副本 + 怪物原形养成

- **引擎**：Godot 4.6.2（Forward+ 渲染）
- **主脚本语言**：GDScript（强类型）
- **目标平台**：Windows 64-bit 桌面，单机离线
- **美术方向**：2.5D Live + 厚涂精美二次元风格（不使用像素风）
- **当前阶段**：P0 工程底座（垂直切片前置）

---

## 版本规则

仓库工程版本与设定文档 [`docs/game-concept.md`](docs/game-concept.md) 总版本号联动，遵循语义化版本 `v主.次.修订`：

- **主版本**：核心循环或游戏类型重构。
- **次版本**：新增重要系统、阶段验收门禁达成（如完成 P0、P1）。
- **修订版本**：文档微调、补丁修复、内容打磨。

每次提交需遵循 Conventional Commits（`feat: / fix: / docs: / chore:`），见
[`docs/00-tech-constraints.md`](docs/00-tech-constraints.md) §八.1。

---

## 目录结构

```
/project.godot         Godot 项目入口
/addons/               第三方插件（每个插件独立目录）
/assets/               美术与音频原始资源
  sprites/  audio/  fonts/  shaders/
/config/               运行时配置（default.cfg 等）
/data/                 数据驱动资源（.tres / .json）
  monsters/  origins/  rules/  items/  levels/
/scenes/               场景文件 .tscn
  player/  monster/  dungeon/  base/  ui/
/scripts/              GDScript（与 scenes 目录一一对应）
  player/  monster/  systems/  ui/  autoload/
/tests/                GUT 单元测试
/docs/                 设计与工程文档
/tools/                编辑器扩展脚本（@tool）
```

详见 [`docs/00-tech-constraints.md`](docs/00-tech-constraints.md) §三。

---

## 运行方式

在仓库根目录执行：

```bash
godot --path .
```

无头模式（用于 CI 或 sanity check）：

```bash
godot --headless --path . --quit
```

---

## Git LFS

第一阶段 `/assets/audio/` 暂无单文件 > 10MB 的资源，**暂未启用 Git LFS**。
当首次出现大于 10MB 的二进制资源（音频 / 视频）时，按
[`docs/00-tech-constraints.md`](docs/00-tech-constraints.md) §八.2 启用，
并在 `.gitattributes` 中取消相应行注释（已预置占位）。

---

## 文档入口

- 总设定：[`docs/game-concept.md`](docs/game-concept.md)
- 设计支柱：[`docs/00-design-pillars.md`](docs/00-design-pillars.md)
- 技术规约：[`docs/00-tech-constraints.md`](docs/00-tech-constraints.md)
- 实施计划：[`docs/00-implementation-plan.md`](docs/00-implementation-plan.md)
- 工程任务书：[`docs/00-engineering-tasks.md`](docs/00-engineering-tasks.md)
- 垂直切片验收：[`docs/00-vertical-slice.md`](docs/00-vertical-slice.md)
- 模块文档目录：[`docs/modules/`](docs/modules/)
