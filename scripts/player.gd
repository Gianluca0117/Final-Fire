extends CharacterBody2D
## Personaje provisional: movimiento horizontal y salto.
## Lee acciones del InputMap, así que funciona igual con teclado y con los
## botones táctiles (que pulsan las mismas acciones).

const SPEED := 380.0
const ACCELERATION := 2400.0
const FRICTION := 2800.0
const JUMP_VELOCITY := -720.0
const COYOTE_TIME := 0.1      # margen para saltar justo después de dejar el borde
const JUMP_BUFFER := 0.12     # margen para pulsar salto justo antes de aterrizar
const FALL_LIMIT_Y := 1400.0  # si cae por debajo, reaparece

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _coyote := 0.0
var _jump_buffer := 0.0
var _spawn_position: Vector2


func _ready() -> void:
	_spawn_position = global_position


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote -= delta
		velocity.y += _gravity * delta

	_jump_buffer -= delta
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = JUMP_BUFFER

	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer = 0.0
		_coyote = 0.0

	# Salto de altura variable: soltar el botón corta el ascenso.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	move_and_slide()

	if global_position.y > FALL_LIMIT_Y or Input.is_action_just_pressed("restart"):
		respawn()


func respawn() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
