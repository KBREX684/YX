extends Resource
class_name SettlementPayoffResource

@export var escape_material_multiplier := 1.0
@export var kill_material_multiplier := 0.75
@export var contain_material_multiplier := 0.5
@export var miscontain_material_multiplier := 0.25

@export var escape_archive_entries := 1
@export var kill_archive_entries := 2
@export var contain_archive_entries := 4
@export var miscontain_archive_entries := 1

@export var escape_archive_completion_percent := 25
@export var kill_archive_completion_percent := 55
@export var contain_archive_completion_percent := 85
@export var miscontain_archive_completion_percent := 35

@export var kill_origin_quality := "medium"
@export var kill_origin_stability := "low"
@export var contain_origin_quality := "high"
@export var contain_origin_stability := "stable"
@export var miscontain_origin_quality := "unstable"
@export var miscontain_origin_stability := "volatile"

@export var light_error_loss_pct := 0.05
@export var light_error_loss_cap := 3
@export var light_error_invasion_chance := 0.1
@export var medium_error_loss_pct := 0.1
@export var medium_error_loss_cap := 8
@export var medium_error_invasion_chance := 0.3
@export var heavy_error_loss_pct := 0.15
@export var heavy_error_loss_cap := 15
@export var heavy_error_invasion_chance := 0.6

@export var death_resource_return_ratio := 0.0
