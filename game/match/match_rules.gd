class_name MatchRules
extends Resource
## Reglas de una partida (data/rules/*.tres).

## Qué pasa con la herramienta si su portador es eliminado.
enum CarrierEliminated {
	RESPAWN,   ## vuelve a su punto de aparición, con aviso, si queda tiempo de fase
	LOSE,      ## se pierde hasta la siguiente fase
}

@export var min_participants := 2
@export var max_participants := 6
@export var countdown := 3.0
## Si alguien cae a la lava hasta estos segundos después de un empujón, cuenta para quien empujó.
@export var push_credit_window := 3.0
## Calendario de peligros de la arena (lava) para toda la partida.
@export var hazards: HazardSchedule
## Fases con herramienta compartida. Tras la última se repite la última. Vacío = sin herramientas.
@export var phases: Array[PhaseDefinition] = []
@export var character_stats: CharacterStats
## Colores de los participantes por orden (como en la referencia visual).
@export var colors: PackedColorArray = PackedColorArray([
	Color("e8433a"), Color("3a7be8"), Color("43b24a"),
	Color("f2c230"), Color("a35ee0"), Color("2ec4c4"),
])

@export_group("Herramientas")
## Distancia (px) entre el centro del personaje y la herramienta para recogerla.
@export var tool_pickup_radius := 40.0
@export var on_carrier_eliminated: CarrierEliminated = CarrierEliminated.RESPAWN
## Tiempo mínimo de fase restante para que la herramienta reaparezca tras eliminar al portador.
@export var tool_respawn_min_time := 5.0
@export var tool_respawn_warning := 1.5
