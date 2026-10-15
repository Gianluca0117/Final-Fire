class_name HumanController
extends FighterController
## Jugador humano local. Lee acciones del InputMap con uno o varios prefijos
## ("p1_", "p2_"). Teclado, mando y controles táctiles generan las mismas acciones.

var _left: Array[StringName] = []
var _right: Array[StringName] = []
var _jump: Array[StringName] = []
var _push: Array[StringName] = []
var _shield: Array[StringName] = []


## Con varios prefijos (p. ej. ["p1_", "p2_"]) un solo jugador puede usar ambos juegos de teclas.
func _init(prefixes: PackedStringArray = PackedStringArray(["p1_"])) -> void:
	for p in prefixes:
		_left.append(StringName(p + "left"))
		_right.append(StringName(p + "right"))
		_jump.append(StringName(p + "jump"))
		_push.append(StringName(p + "push"))
		_shield.append(StringName(p + "shield"))


func sample(p_tick: int, _fighter: Fighter, _match: MatchController) -> InputFrame:
	var f := InputFrame.new()
	f.tick = p_tick
	var axis := 0.0
	for i in _left.size():
		axis += Input.get_action_strength(_right[i]) - Input.get_action_strength(_left[i])
	f.move_x = clampf(axis, -1.0, 1.0)
	f.jump_pressed = _any(_jump, Input.is_action_just_pressed)
	f.jump_held = _any(_jump, Input.is_action_pressed)
	f.push_pressed = _any(_push, Input.is_action_just_pressed)
	f.shield_pressed = _any(_shield, Input.is_action_just_pressed)
	return f


static func _any(actions: Array[StringName], test: Callable) -> bool:
	for a in actions:
		if test.call(a):
			return true
	return false
