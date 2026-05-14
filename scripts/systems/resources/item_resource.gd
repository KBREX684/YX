extends Resource
class_name ItemResource
## ItemResource —— 道具/资源数据契约
##
## 关联模块：docs/modules/07-looting-resources.md
## TASK-P0-6：仅声明 @export 字段，背包/搜刮逻辑由 P4 阶段实现。

enum Category {
	SURVIVAL = 0,  ## 生存物资（电池、医药）
	PUZZLE = 1,    ## 解谜物资（仪式物、钥匙）
	GROWTH = 2,    ## 养成素材（投喂原形）
}

## 全局唯一道具 ID（如 "item_battery_aa"）。
@export var id: String = ""

## 类别枚举值。
@export var category: Category = Category.SURVIVAL

## 单格堆叠上限（≥1）。
@export var stack_max: int = 1

## 稀有度（0=common, 1=uncommon, 2=rare, 3=epic）。
@export var rarity: int = 0

## 可生成的区域 ID 列表（指向关卡子区域；空数组表示全图可生成）。
@export var spawn_zone_ids: PackedStringArray = []
