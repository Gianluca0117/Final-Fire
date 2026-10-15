class_name PhaseDefinition
extends Resource
## Calendario de peligros de una fase (data/phases/*.tres). En F1 hay una sola fase;
## en F2 la partida encadenará varias y añadirá la herramienta compartida.

@export var display_name := "Fase 1"

@export_group("Suelo que se convierte en lava")
@export var floor_waves_enabled := true
@export var first_wave_at := 6.0
@export var wave_interval := 8.0
## Aviso antes de que un segmento se convierta en lava.
@export var wave_warning := 2.0
@export var wave_lava_time := 4.5
@export var segments_first_wave := 1
## Cada cuántas oleadas se añade un segmento más.
@export var segments_increase_every := 2
@export var max_segments_per_wave := 3

@export_group("Lava inferior")
## Momentos (s) en que sube la lava inferior y nivel Y que alcanza en cada subida.
@export var pool_rise_times: PackedFloat32Array = PackedFloat32Array([45.0, 75.0])
@export var pool_rise_levels: PackedFloat32Array = PackedFloat32Array([590.0, 405.0])
@export var pool_rise_warning := 3.0
@export var pool_rise_duration := 2.5
## Desde este momento la lava sube sin parar hasta que quede un ganador.
@export var sudden_death_at := 100.0
@export var sudden_death_speed := 30.0

@export_group("Plataformas")
@export var wear_multiplier := 1.0
