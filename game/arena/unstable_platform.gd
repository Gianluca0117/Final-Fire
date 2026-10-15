class_name UnstablePlatform
extends AnimatableBody2D
## Plataforma inestable: se inclina según dónde se apoyen los personajes y se desgasta
## mientras alguien está encima.
## INTACT → CRACKED → CRITICAL → COLLAPSING (aviso) → FALLING → GONE → RESPAWNING → INTACT
## Un Ancla la estabiliza un tiempo: no se inclina, no se desgasta y no se derrumba.

enum Stage { INTACT, CRACKED, CRITICAL, COLLAPSING, FALLING, GONE, RESPAWNING }

signal stage_changed(stage: Stage)
signal anchored(duration: float)
## Quedan `seconds` de Ancla: aviso de que vuelve a ser inestable.
signal anchor_ending(seconds: float)
signal anchor_released

@export var params: PlatformParams
@export var size := Vector2(200, 24)

var stage: Stage = Stage.INTACT
var integrity := 1.0
var occupants := 0
## Segundos restantes del aviso de caída o de reaparición.
var time_left := 0.0
## Segundos de Ancla restantes (0 = sin anclar).
var anchor_left := 0.0
var anchor_duration := 0.0
var anchor_warning := 0.0

var _home := Vector2.ZERO
var _fall_speed := 0.0
var _col: CollisionShape2D
var _anchor_warned := false


func _ready() -> void:
	if params == null:
		params = PlatformParams.new()
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	sync_to_physics = true
	var shape := RectangleShape2D.new()
	shape.size = size
	_col = CollisionShape2D.new()
	_col.shape = shape
	add_child(_col)
	_home = global_position


func is_solid() -> bool:
	return stage <= Stage.FALLING


func is_anchored() -> bool:
	return anchor_left > 0.0


## Se puede anclar si sigue en su sitio (incluso a punto de caer) y no está ya anclada.
func can_anchor() -> bool:
	return anchor_left <= 0.0 and stage <= Stage.COLLAPSING


func anchor(duration: float, warning: float) -> void:
	if not can_anchor():
		return
	anchor_left = duration
	anchor_duration = duration
	anchor_warning = warning
	_anchor_warned = false
	if stage == Stage.COLLAPSING:
		# Se salva del derrumbe: vuelve a «crítica» con un mínimo de integridad.
		integrity = maxf(integrity, 0.15)
		_set_stage(Stage.CRITICAL)
	anchored.emit(duration)


func step(delta: float, fighters: Array, wear_multiplier := 1.0) -> void:
	if anchor_left > 0.0:
		_step_anchored(delta, fighters)
		return
	match stage:
		Stage.INTACT, Stage.CRACKED, Stage.CRITICAL:
			_step_load(delta, fighters, wear_multiplier)
		Stage.COLLAPSING:
			_step_load(delta, fighters, 0.0)
			time_left -= delta
			if time_left <= 0.0:
				_fall_speed = 0.0
				_set_stage(Stage.FALLING)
		Stage.FALLING:
			_fall_speed += params.fall_gravity * delta
			global_position.y += _fall_speed * delta
			if global_position.y > _home.y + 900.0:
				_col.set_deferred("disabled", true)
				time_left = params.respawn_delay
				_set_stage(Stage.GONE)
		Stage.GONE:
			if params.respawn_delay <= 0.0:
				return
			time_left -= delta
			if time_left <= 0.0:
				global_position = _home
				rotation = 0.0
				time_left = params.respawn_warning
				_set_stage(Stage.RESPAWNING)
		Stage.RESPAWNING:
			time_left -= delta
			if time_left <= 0.0:
				integrity = 1.0
				_col.set_deferred("disabled", false)
				_set_stage(Stage.INTACT)


## Rectángulo aproximado (sin rotación) para avisos de peligro.
func rect() -> Rect2:
	return Rect2(_home - size * 0.5, size)


func _step_anchored(delta: float, fighters: Array) -> void:
	anchor_left -= delta
	occupants = _count_occupants(fighters)
	rotation = move_toward(rotation, 0.0, deg_to_rad(params.anchor_level_speed_deg) * delta)
	if not _anchor_warned and anchor_left <= anchor_warning:
		_anchor_warned = true
		anchor_ending.emit(maxf(anchor_left, 0.0))
	if anchor_left <= 0.0:
		anchor_left = 0.0
		anchor_released.emit()


func _count_occupants(fighters: Array) -> int:
	var n := 0
	for f in fighters:
		var fighter := f as Fighter
		if fighter != null and fighter.is_alive() and fighter.floor_body == self:
			n += 1
	return n


func _step_load(delta: float, fighters: Array, wear_multiplier: float) -> void:
	var load := 0.0
	occupants = 0
	for f in fighters:
		var fighter := f as Fighter
		if fighter == null or not fighter.is_alive() or fighter.floor_body != self:
			continue
		occupants += 1
		load += clampf(to_local(fighter.global_position).x / (size.x * 0.5), -1.0, 1.0)

	if params.tilt_enabled:
		var max_tilt := deg_to_rad(params.max_tilt_deg)
		var target := clampf(load * deg_to_rad(params.tilt_per_load_deg), -max_tilt, max_tilt)
		var speed := params.tilt_speed_deg if occupants > 0 else params.return_speed_deg
		rotation = move_toward(rotation, target, deg_to_rad(speed) * delta)

	if params.wear_enabled and occupants > 0 and wear_multiplier > 0.0:
		integrity = maxf(integrity - params.wear_per_occupant * occupants * wear_multiplier * delta, 0.0)
		if integrity <= 0.0:
			time_left = params.collapse_warning
			_set_stage(Stage.COLLAPSING)
		elif integrity < 0.34:
			_set_stage(Stage.CRITICAL)
		elif integrity < 0.67:
			_set_stage(Stage.CRACKED)


func _set_stage(new_stage: Stage) -> void:
	if new_stage == stage:
		return
	stage = new_stage
	stage_changed.emit(stage)
