class_name Participant
extends RefCounted
## Un participante de la partida y quién lo controla.

enum Kind { HUMAN_LOCAL, DUMMY, BOT, HUMAN_REMOTE }

var id := 0
var display_name := ""
var color := Color.WHITE
var kind: Kind = Kind.HUMAN_LOCAL
var controller: FighterController
var fighter: Fighter
var alive := true
## Puesto final (1 = ganador). 0 mientras sigue en juego.
var place := 0
var eliminated_at := -1.0
var elimination_cause: StringName = &""
var eliminated_by: Participant = null
var eliminations := 0


func _init(p_id := 0, p_name := "", p_kind := Kind.HUMAN_LOCAL, p_controller: FighterController = null) -> void:
	id = p_id
	display_name = p_name
	kind = p_kind
	controller = p_controller
