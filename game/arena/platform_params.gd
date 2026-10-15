class_name PlatformParams
extends Resource
## Parámetros de una plataforma inestable (data/platforms/*.tres).

@export_group("Inclinación")
@export var tilt_enabled := true
@export var max_tilt_deg := 16.0
## Grados por unidad de carga (un personaje en el borde = 1 unidad).
@export var tilt_per_load_deg := 12.0
@export var tilt_speed_deg := 40.0
@export var return_speed_deg := 22.0

@export_group("Desgaste")
@export var wear_enabled := true
## Integridad perdida por segundo y por personaje encima (1 = entera).
@export var wear_per_occupant := 0.08
## Aviso (temblor) antes de caer, en segundos.
@export var collapse_warning := 1.0
@export var fall_gravity := 900.0
## Segundos hasta reaparecer tras caer (0 = no reaparece).
@export var respawn_delay := 7.0
@export var respawn_warning := 1.5
