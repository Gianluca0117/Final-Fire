class_name Fighter
extends CharacterBody2D
## Personaje (simulación): movimiento, salto, empujón, protección y eliminación.
## No lee Input ni dibuja nada. La partida llama a step() una vez por tick con el
## InputFrame de su controlador; la presentación escucha las señales.

enum State { IDLE, RUN, JUMP, FALL, PUSH, STUNNED, SHIELDED, ELIMINATED }

signal state_changed(old_state: State, new_state: State)
signal jumped
signal landed
signal pushed(targets: Array)
signal was_pushed(by: Fighter, strength: float)
signal shield_started
signal shield_ended
signal eliminated(cause: StringName, by: Fighter)

@export var stats: CharacterStats

var participant_id := -1
var display_name := ""
var color := Color.WHITE
var state: State = State.IDLE
var facing := 1
## Cuerpo sobre el que está apoyado (plataforma, segmento de suelo u otro personaje).
var floor_body: Object = null
var last_pusher: Fighter = null
var last_pushed_at := -1000.0
var sim_time := 0.0

var _coyote := 0.0
var _jump_buffer := 0.0
var _jump_held := false
var _push_cooldown := 0.0
var _push_active := 0.0
var _stun := 0.0
var _shield := 0.0
var _shield_cooldown := 0.0
var _was_on_floor := false


func _ready() -> void:
	if stats == null:
		stats = CharacterStats.new()
	collision_layer = PhysicsLayers.FIGHTERS
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.FIGHTERS
	floor_stop_on_slope = false
	floor_snap_length = 8.0
	var shape := RectangleShape2D.new()
	shape.size = stats.body_size
	var col := CollisionShape2D.new()
	col.name = "Collision"
	col.shape = shape
	add_child(col)


func is_alive() -> bool:
	return state != State.ELIMINATED


func is_shielded() -> bool:
	return _shield > 0.0


func shield_ready() -> bool:
	return _shield_cooldown <= 0.0


func push_ready() -> bool:
	return _push_cooldown <= 0.0


## Coloca al personaje en un punto de aparición y reinicia su estado.
func spawn(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	_coyote = 0.0
	_jump_buffer = 0.0
	_push_cooldown = 0.0
	_push_active = 0.0
	_stun = 0.0
	_shield = 0.0
	_shield_cooldown = 0.0
	last_pusher = null
	floor_body = null
	collision_layer = PhysicsLayers.FIGHTERS
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.FIGHTERS
	_set_state(State.IDLE)


## Un tick de simulación. `others` son todos los personajes de la partida.
func step(frame: InputFrame, delta: float, others: Array) -> void:
	if state == State.ELIMINATED:
		return
	sim_time += delta
	_tick_timers(delta)

	var on_floor := is_on_floor()
	if on_floor:
		_coyote = stats.coyote_time
	else:
		_coyote -= delta

	# Protección
	if frame.shield_pressed and _shield <= 0.0 and _shield_cooldown <= 0.0 and _stun <= 0.0:
		_shield = stats.shield_time
		_shield_cooldown = stats.shield_time + stats.shield_cooldown
		shield_started.emit()

	# Salto (con margen de coyote y buffer) y salto de altura variable
	if frame.jump_pressed:
		_jump_buffer = stats.jump_buffer
	if _jump_buffer > 0.0 and _coyote > 0.0 and _stun <= 0.0:
		velocity.y = stats.jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
		on_floor = false
		jumped.emit()
	if _jump_held and not frame.jump_held and velocity.y < 0.0:
		velocity.y *= stats.jump_cut
	_jump_held = frame.jump_held

	# Movimiento horizontal. En una plataforma inclinada se resbala hacia abajo.
	var move := clampf(frame.move_x, -1.0, 1.0)
	if absf(move) > 0.1 and _stun <= 0.0:
		facing = 1 if move > 0.0 else -1
	var slope := get_floor_normal().x if on_floor else 0.0
	var speed := stats.max_speed * (stats.shield_move_factor if _shield > 0.0 else 1.0)
	var target := move * speed + slope * stats.slope_slide_speed
	var rate: float
	if _stun > 0.0:
		rate = stats.ground_accel * stats.stun_control if absf(move) > 0.01 else stats.knockback_friction
	elif absf(move) > 0.01:
		rate = stats.ground_accel if on_floor else stats.air_accel
	else:
		rate = stats.ground_friction if on_floor else stats.air_friction
	velocity.x = move_toward(velocity.x, target, rate * delta)

	if not on_floor:
		velocity.y = minf(velocity.y + stats.gravity * delta, stats.max_fall_speed)

	# Empujón
	if frame.push_pressed and _push_cooldown <= 0.0 and _shield <= 0.0 and _stun <= 0.0:
		_push_cooldown = stats.push_cooldown
		_push_active = stats.push_active_time
		var hits := find_push_targets(others)
		for target_fighter in hits:
			target_fighter.receive_push(self, facing, stats.push_force)
		pushed.emit(hits)

	move_and_slide()
	_update_floor_body()

	var now_on_floor := is_on_floor()
	if now_on_floor and not _was_on_floor:
		landed.emit()
	_was_on_floor = now_on_floor
	_set_state(_compute_state(now_on_floor))


## Personajes vivos que un empujón alcanzaría ahora mismo (delante y a la misma altura).
func find_push_targets(others: Array) -> Array[Fighter]:
	var hits: Array[Fighter] = []
	var half_w := stats.body_size.x * 0.5
	for o in others:
		var other := o as Fighter
		if other == null or other == self or not other.is_alive():
			continue
		var d := other.global_position - global_position
		if absf(d.y) > stats.body_size.y * 0.8:
			continue
		var ahead := d.x * facing
		var reach := half_w + other.stats.body_size.x * 0.5 + stats.push_range
		if ahead >= -half_w * 0.5 and ahead <= reach:
			hits.append(other)
	return hits


## Recibe un empujón de `by` en la dirección horizontal `dir` (-1 o 1).
func receive_push(by: Fighter, dir: int, force: float) -> void:
	if not is_alive():
		return
	var factor := stats.knockback_resistance
	if _shield > 0.0:
		factor *= stats.shield_knockback_factor
		# La protección devuelve parte del golpe a quien empuja.
		if by != null:
			by._apply_knockback(self, -dir, force * by.stats.shield_recoil)
	_apply_knockback(by, dir, force * factor)
	was_pushed.emit(by, factor)


func eliminate(cause: StringName, by: Fighter = null) -> void:
	if not is_alive():
		return
	velocity = Vector2.ZERO
	_shield = 0.0
	_set_state(State.ELIMINATED)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	eliminated.emit(cause, by)


func _apply_knockback(by: Fighter, dir: int, force: float) -> void:
	velocity.x = dir * force
	var lift := stats.push_lift * clampf(force / stats.push_force, 0.0, 1.0)
	velocity.y = minf(velocity.y, lift)
	_stun = stats.stun_time * clampf(force / stats.push_force, 0.25, 1.0)
	last_pusher = by
	last_pushed_at = sim_time


func _tick_timers(delta: float) -> void:
	_jump_buffer -= delta
	_push_cooldown = maxf(_push_cooldown - delta, 0.0)
	_push_active = maxf(_push_active - delta, 0.0)
	_stun = maxf(_stun - delta, 0.0)
	_shield_cooldown = maxf(_shield_cooldown - delta, 0.0)
	if _shield > 0.0:
		_shield -= delta
		if _shield <= 0.0:
			_shield = 0.0
			shield_ended.emit()


func _update_floor_body() -> void:
	floor_body = null
	if not is_on_floor():
		return
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_normal().y < -0.6:
			floor_body = c.get_collider()
			return
	# Apoyado por «snap» (p. ej. en una plataforma que gira): no hay colisión en la lista
	# del deslizamiento, así que se consulta qué hay justo debajo sin mover el cuerpo.
	var below := move_and_collide(Vector2(0, floor_snap_length), true, safe_margin, true)
	if below and below.get_normal().y < -0.6:
		floor_body = below.get_collider()


func _compute_state(on_floor: bool) -> State:
	if _shield > 0.0:
		return State.SHIELDED
	if _stun > 0.0:
		return State.STUNNED
	if _push_active > 0.0:
		return State.PUSH
	if on_floor:
		return State.RUN if absf(velocity.x) > 20.0 else State.IDLE
	return State.JUMP if velocity.y < 0.0 else State.FALL


func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	var old := state
	state = new_state
	state_changed.emit(old, new_state)
