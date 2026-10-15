class_name HumanController
extends FighterController
## Jugador humano local. Lee acciones del InputMap con uno o varios prefijos
## ("p1_", "p2_"). Teclado, mando y controles táctiles generan las mismas acciones.
##
## Herramienta: se usa al SOLTAR el botón; mientras se mantiene, se apunta y se ve el destino.
## Apuntado: si hay acciones de apuntado (botón táctil arrastrado), mandan ellas; si no,
## hacia arriba inclinado hacia donde se mueve (teclado / joystick).

var _left: Array[StringName] = []
var _right: Array[StringName] = []
var _jump: Array[StringName] = []
var _push: Array[StringName] = []
var _shield: Array[StringName] = []
var _tool: Array[StringName] = []
var _aim: Array = []   # [left, right, up, down] por prefijo, solo si existen
var _held_aim := Vector2.ZERO


## Con varios prefijos (p. ej. ["p1_", "p2_"]) un solo jugador puede usar ambos juegos de teclas.
func _init(prefixes: PackedStringArray = PackedStringArray(["p1_"])) -> void:
	for p in prefixes:
		_left.append(StringName(p + "left"))
		_right.append(StringName(p + "right"))
		_jump.append(StringName(p + "jump"))
		_push.append(StringName(p + "push"))
		_shield.append(StringName(p + "shield"))
		_tool.append(StringName(p + "tool"))
		var aim_actions := [StringName(p + "aim_left"), StringName(p + "aim_right"), StringName(p + "aim_up"), StringName(p + "aim_down")]
		if aim_actions.all(func(a: StringName) -> bool: return InputMap.has_action(a)):
			_aim.append(aim_actions)


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
	f.tool_held = _any(_tool, Input.is_action_pressed)
	f.tool_pressed = _any(_tool, Input.is_action_just_released)

	var aim := Vector2.ZERO
	for a in _aim:
		aim += Vector2(Input.get_action_strength(a[1]) - Input.get_action_strength(a[0]),
			Input.get_action_strength(a[3]) - Input.get_action_strength(a[2]))
	if aim.length() < 0.2:
		aim = Vector2(f.move_x, -1.0).normalized()
	aim = aim.limit_length(1.0)
	# Al soltar, se usa la dirección que se tenía mientras se apuntaba.
	if f.tool_held:
		_held_aim = aim
	f.aim = _held_aim if f.tool_pressed and _held_aim != Vector2.ZERO else aim
	if not f.tool_held and not f.tool_pressed:
		_held_aim = Vector2.ZERO
	return f


static func _any(actions: Array[StringName], test: Callable) -> bool:
	for a in actions:
		if test.call(a):
			return true
	return false
