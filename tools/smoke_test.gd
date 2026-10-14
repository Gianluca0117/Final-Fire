extends SceneTree
## Prueba automática de la escena mínima (sin ventana):
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_test.gd
## Comprueba acciones de entrada, gravedad/suelo, movimiento, salto y botones táctiles.

var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for a in [&"move_left", &"move_right", &"jump", &"restart"]:
		_check(InputMap.has_action(a) and not InputMap.action_get_events(a).is_empty(), "acción '%s' con teclas" % a)

	var level: Node = load("res://scenes/test_level.tscn").instantiate()
	root.add_child(level)
	var player: CharacterBody2D = level.get_node("Player")

	await _frames(90)
	_check(player.is_on_floor(), "el personaje cae y se apoya en el suelo")

	var x0 := player.global_position.x
	Input.action_press(&"move_right")
	await _frames(40)
	Input.action_release(&"move_right")
	_check(player.global_position.x > x0 + 50.0, "se mueve a la derecha (%.0f -> %.0f)" % [x0, player.global_position.x])

	await _frames(30)
	var y0 := player.global_position.y
	Input.action_press(&"jump")
	await _frames(15)
	_check(player.global_position.y < y0 - 40.0, "salta (%.0f -> %.0f)" % [y0, player.global_position.y])
	Input.action_release(&"jump")
	await _frames(120)
	_check(player.is_on_floor(), "aterriza tras el salto")

	# Botón táctil: un toque dentro del botón "Right" debe pulsar move_right.
	var btn: Control = level.get_node("HUD/Margin/Touch/Right")
	var touch := InputEventScreenTouch.new()
	touch.index = 3
	touch.pressed = true
	touch.position = btn.get_global_rect().get_center()
	root.push_input(touch, true)
	_check(Input.is_action_pressed(&"move_right"), "botón táctil pulsa move_right")
	touch.pressed = false
	root.push_input(touch, true)
	_check(not Input.is_action_pressed(&"move_right"), "soltar el toque libera move_right")

	# Multitáctil: mantener "Right" con un dedo y pulsar "Jump" con otro.
	var jump_btn: Control = level.get_node("HUD/Margin/Touch/Jump")
	var t1 := InputEventScreenTouch.new()
	t1.index = 0
	t1.pressed = true
	t1.position = btn.get_global_rect().get_center()
	var t2 := InputEventScreenTouch.new()
	t2.index = 1
	t2.pressed = true
	t2.position = jump_btn.get_global_rect().get_center()
	root.push_input(t1, true)
	root.push_input(t2, true)
	_check(Input.is_action_pressed(&"move_right") and Input.is_action_pressed(&"jump"), "multitáctil: derecha + salto a la vez")
	t1.pressed = false
	t2.pressed = false
	root.push_input(t1, true)
	root.push_input(t2, true)

	player.global_position.y = 5000.0
	await _frames(3)
	_check(player.global_position.y < 1000.0, "reaparece al caer fuera del nivel")

	print("SMOKE TEST: %s" % ("OK" if _failures == 0 else "%d FALLO(S)" % _failures))
	quit(1 if _failures else 0)


func _frames(n: int) -> void:
	for i in n:
		await physics_frame


func _check(ok: bool, what: String) -> void:
	print(("  [OK]    " if ok else "  [FALLO] ") + what)
	if not ok:
		_failures += 1
