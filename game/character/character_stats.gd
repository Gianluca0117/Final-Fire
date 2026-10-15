class_name CharacterStats
extends Resource
## Parámetros del personaje. Los valores de juego se ajustan en data/characters/*.tres.

@export_group("Movimiento")
@export var max_speed := 360.0
@export var ground_accel := 2600.0
@export var ground_friction := 3000.0
@export var air_accel := 1700.0
@export var air_friction := 500.0
## Velocidad a la que se resbala en una plataforma inclinada (por unidad de pendiente).
@export var slope_slide_speed := 520.0

@export_group("Salto")
@export var gravity := 1900.0
@export var max_fall_speed := 1100.0
@export var jump_velocity := -900.0
## Al soltar el salto mientras sube, la velocidad vertical se multiplica por esto.
@export var jump_cut := 0.45
@export var coyote_time := 0.1
@export var jump_buffer := 0.12

@export_group("Empujón")
@export var push_range := 46.0
@export var push_force := 640.0
@export var push_lift := -300.0
@export var push_cooldown := 0.55
@export var push_active_time := 0.16
## Tiempo con control reducido tras recibir un empujón.
@export var stun_time := 0.38
@export var stun_control := 0.15
@export var knockback_friction := 700.0
## Multiplica la fuerza de los empujones recibidos (1 = normal).
@export var knockback_resistance := 1.0
## Fracción de la fuerza que rebota al empujar a alguien protegido.
@export var shield_recoil := 0.45

@export_group("Protección")
@export var shield_time := 0.7
@export var shield_cooldown := 2.4
@export var shield_knockback_factor := 0.15
@export var shield_move_factor := 0.55

@export_group("Cuerpo")
@export var body_size := Vector2(40, 56)
