# 插件采纳核查表 Plugin Vetting

版本：v1.2.0
关联工程任务：TASK-P0-4-plugins-install
创建日期：2026-05-14
最后更新：2026-05-14

## 用途

记录 P0 阶段引入的第三方 Godot 插件版本、来源和采纳门槛。后续升级插件前必须先回看本表。

## 采纳门槛

依据 `docs/00-tech-constraints.md` §五：

- 许可证必须为 MIT / MPL / Apache 类宽松许可。
- GitHub star 数必须大于等于 500。
- 最近 6 个月内有更新或 release。

## 核查表

| 插件 | 锁定版本 | 安装位置 | 来源 | 许可证 | Stars | 最近 release / 更新 | 结论 |
|---|---|---|---|---|---:|---|---|
| LimboAI | v1.7.0 (`gdextension-4.6`) | `addons/limboai/` | https://github.com/limbonaut/limboai | MIT | 2725 | release 2026-03-01；repo updated 2026-05-14 | 通过 |
| Dialogic 2 | 2.0-alpha-19 | `addons/dialogic/` | https://github.com/dialogic-godot/dialogic | MIT | 5557 | release 2026-01-12；repo updated 2026-05-14 | 通过 |
| GUT | v9.6.0 | `addons/gut/` | https://github.com/bitwes/Gut | MIT | 2521 | release 2026-02-24；repo updated 2026-05-13 | 通过 |
| GoPeak | v2.3.7 | `addons/auto_reload/`, `addons/godot_mcp_editor/`, `addons/godot_mcp_runtime/` | https://github.com/HaD0Yun/Gopeak-godot-mcp | MIT | 179 | repo updated 2026-05-13 | dev-only 例外：不满足 star 门槛，不作为正式游戏依赖 |

## 安装记录

- Godot Engine：winget `GodotEngine.GodotEngine`，本机版本 `4.6.2.stable.official.71f334935`。
- 行为树 / 状态机插件：Q-16 定案为 LimboAI。
- 对话 / 剧情插件：Dialogic 2。
- 单元测试插件：GUT。
- `project.godot` 默认启用 `Gut` 与 `Godot MCP Editor` editor plugin。LimboAI 以 GDExtension 形式加载，无 `plugin.cfg`。
- `Dialogic` 已安装并通过采纳门槛，但 P0 默认不启用；该插件启用时会自动注册 `Dialogic` runtime Autoload，后续剧情/线索任务按需接入并重新验证。
- GoPeak 已作为 dev-only MCP 工具安装；`godot_mcp_runtime` 默认不启用，避免影响运行时 Autoload 白名单。

## P0 验证记录

- `godot --version`：`4.6.2.stable.official.71f334935`。
- `godot --headless --path . --quit`：退出码 0，占位主菜单启动成功，运行时 Autoload 为 `GameState / EventBus / SaveSystem / AudioManager / Config`。
- `godot --headless --path . --script res://tools/validate_schemas.gd`：退出码 0，`Checked: 4`，四类示例资源全部通过。
- `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://tests/.gutconfig.json -gexit`：退出码 0，`1/1 passed`。

## 版本记录

### v1.2.0 - 2026-05-14

- 新增 GoPeak v2.3.7 核查记录：MIT、最近更新达标，但 star 数低于正式功能插件门槛，因此仅作为 dev-only MCP 工具引入。
- 记录项目默认启用 `Godot MCP Editor`，不启用 `godot_mcp_runtime`。

### v1.1.0 - 2026-05-14

- 记录 P0 命令行验证结果：Godot 版本、空项目启动、schema 校验、GUT sanity test 均通过。
- 明确 Dialogic 在 P0 仅安装入库、默认不启用 editor plugin；GUT 默认启用用于测试。

### v1.0.0 - 2026-05-14

- 建立插件采纳核查表。
- 记录 LimboAI、Dialogic 2、GUT 三个 P0 插件的版本、来源、许可证、Stars 与最近更新时间。
