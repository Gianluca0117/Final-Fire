class_name ScriptedController
extends FighterController
## Controlador para pruebas: la prueba decide qué acciones se envían en cada tick.

var move_x := 0.0
var jump_held := false
var _jump := false
var _push := false
var _shield := false


func press_jump() -> void:
	_jump = true
	jump_held = true


func press_push() -> void:
	_push = true


func press_shield() -> void:
	_shield = true


func sample(p_tick: int, _fighter: Fighter, _match: MatchController) -> InputFrame:
	var f := InputFrame.new()
	f.tick = p_tick
	f.move_x = move_x
	f.jump_pressed = _jump
	f.jump_held = jump_held
	f.push_pressed = _push
	f.shield_pressed = _shield
	_jump = false
	_push = false
	_shield = false
	return f
