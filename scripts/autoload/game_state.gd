extends Node
## GameState —— 全局游戏状态与副本/基地切换
##
## TASK-P0-3：仅声明接口与占位字段，业务逻辑在后续阶段实现。
## 红线：本文件禁止 preload 其他 Autoload 的具体类，跨模块通信走 EventBus 信号。

enum SceneId { MAIN_MENU, BASE, DUNGEON, SETTLEMENT }

## 当前所处的高级场景标识。
var current_scene: SceneId = SceneId.MAIN_MENU

## 当前副本 ID（基地中为空字符串）。
var current_dungeon_id: String = ""

## 当前携带进入副本的原形 ID（可空）。
var carried_origin_id: String = ""

## 全局污染度（详见 docs/modules/10-base-management-research.md）。
var contamination: float = 0.0


func _ready() -> void:
	pass


## 切换到指定高级场景。仅占位，实际加载逻辑在 TASK-P5-* 实现。
func goto_scene(_target: SceneId) -> void:
	push_warning("GameState.goto_scene: not implemented")


## 进入副本前的快照（带入资源、原形状态）。
func snapshot_loadout() -> Dictionary:
	push_warning("GameState.snapshot_loadout: not implemented")
	return {}


## 副本失败后的资源损失结算。
func apply_dungeon_loss(_payload: Dictionary) -> void:
	push_warning("GameState.apply_dungeon_loss: not implemented")
