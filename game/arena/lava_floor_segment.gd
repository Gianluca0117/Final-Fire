class_name LavaFloorSegment
extends StaticBody2D
## Tramo de suelo que, tras un aviso, se convierte en lava durante un tiempo.
## SAFE → WARNING → LAVA → SAFE. Quien esté apoyado encima en estado LAVA es eliminado.

enum Stage { SAFE, WARNING, LAVA }

signal stage_changed(stage: Stage)

@export var size := Vector2(192, 40)

var stage: Stage = Stage.SAFE
var time_left := 0.0
## Duración total del aviso o de la lava actual (para que la vista calcule el progreso).
var stage_duration := 0.0
var _lava_time := 0.0


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)


func is_available() -> bool:
	return stage == Stage.SAFE


func warn(warning: float, lava_time: float) -> void:
	_lava_time = lava_time
	_set_stage(Stage.WARNING, warning)


func step(delta: float) -> void:
	if stage == Stage.SAFE:
		return
	time_left -= delta
	if time_left > 0.0:
		return
	if stage == Stage.WARNING:
		_set_stage(Stage.LAVA, _lava_time)
	else:
		_set_stage(Stage.SAFE, 0.0)


func is_deadly_for(f: Fighter) -> bool:
	return stage == Stage.LAVA and f.floor_body == self


func rect() -> Rect2:
	return Rect2(global_position - size * 0.5, size)


func _set_stage(new_stage: Stage, duration: float) -> void:
	stage = new_stage
	time_left = duration
	stage_duration = duration
	stage_changed.emit(stage)
