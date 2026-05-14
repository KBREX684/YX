extends Resource
class_name OriginResource
## OriginResource —— 原形（怪物精华）养成数据契约
##
## 关联模块：docs/modules/08-origin-acquisition-growth.md
## TASK-P0-6：仅声明 @export 字段，业务逻辑由原形系统（P4 阶段）实现。
## 三轴养成：拟人 / 恐怖 / 工具，progress 各分量取值 0.0 ~ 100.0。

## 全局唯一原形 ID（如 "origin_big_001"）。
@export var id: String = ""

## 三轴养成进度。x=拟人 / y=恐怖 / z=工具，单位 %（0.0~100.0）。
@export var progress: Vector3 = Vector3.ZERO

## 稳定度（0.0~1.0）。低于阈值时回拨产生代价。
@export_range(0.0, 1.0, 0.01) var stability: float = 1.0

## 当前阶段（0=未成形, 1=幼态, 2=成形, 3=路线锁定）。
@export var stage: int = 0

## 副作用列表。每一项为 Dictionary，键值约定见 08 模块文档。
## 示例：[{"type": "contamination", "value": 0.5}]
@export var side_effects: Array = []

## 是否已锁定路线（progress 任一轴 ≥ 60 后由系统设置为 true）。
@export var locked: bool = false
