class_name MatchRules
extends Resource
## Reglas de una partida (data/rules/*.tres).

@export var min_participants := 2
@export var max_participants := 6
@export var countdown := 3.0
## Si alguien cae a la lava hasta estos segundos después de un empujón, cuenta para quien empujó.
@export var push_credit_window := 3.0
@export var phase: PhaseDefinition
@export var character_stats: CharacterStats
## Colores de los participantes por orden (como en la referencia visual).
@export var colors: PackedColorArray = PackedColorArray([
	Color("e8433a"), Color("3a7be8"), Color("43b24a"),
	Color("f2c230"), Color("a35ee0"), Color("2ec4c4"),
])
