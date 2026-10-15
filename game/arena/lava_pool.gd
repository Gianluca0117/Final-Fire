class_name LavaPool
extends Node2D
## Lava inferior. Todo lo que quede por debajo de `level_y` se quema. Puede subir.

signal rise_started(target_y: float, duration: float)

## Nivel inicial (coordenada Y global de la superficie).
@export var start_level_y := 690.0
@export var width := 1760.0

var level_y := 0.0
var _target_y := 0.0
var _speed := 0.0


func _ready() -> void:
	reset()


func reset() -> void:
	level_y = start_level_y
	_target_y = start_level_y
	_speed = 0.0


func rise_to(target_y: float, duration: float) -> void:
	_target_y = minf(target_y, level_y)
	_speed = (level_y - _target_y) / maxf(duration, 0.01)
	rise_started.emit(_target_y, duration)


## Subida continua (muerte súbita).
func rise_forever(speed: float) -> void:
	_target_y = -100000.0
	_speed = speed


func step(delta: float) -> void:
	if level_y > _target_y:
		level_y = maxf(level_y - _speed * delta, _target_y)


func is_deadly_for(f: Fighter) -> bool:
	var feet := f.global_position.y + f.stats.body_size.y * 0.5
	return feet > level_y + 2.0
