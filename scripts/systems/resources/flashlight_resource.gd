extends ItemResource
class_name FlashlightResource
## FlashlightResource —— P1 手电参数资源
##
## 业务参数存放在 data/items/flashlight.tres；玩家脚本只读取资源字段。

@export_range(1.0, 999.0, 1.0) var battery_capacity: float = 100.0
@export_range(0.1, 100.0, 0.1) var battery_drain_per_second: float = 8.0
@export_range(0.0, 100.0, 1.0) var low_battery_threshold: float = 20.0
@export_range(0.0, 8.0, 0.05) var full_energy: float = 1.35
@export_range(0.0, 8.0, 0.05) var low_energy: float = 0.45
@export_range(0.0, 8.0, 0.05) var off_energy: float = 0.0
