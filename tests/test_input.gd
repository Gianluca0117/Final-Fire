extends TestSuite
## Entradas: acciones del InputMap, controlador humano y controles táctiles.


func run() -> void:
	for p in ["p1_", "p2_"]:
		for a in ["left", "right", "jump", "push", "shield"]:
			check(InputMap.has_action(p + a) and not InputMap.action_get_events(p + a).is_empty(), "acción %s%s con teclas" % [p, a])
	check(InputMap.has_action(&"pause"), "acción pause")

	var solo := HumanController.new(PackedStringArray(["p1_", "p2_"]))
	Input.action_press(&"p1_right")
	check(is_equal_approx(solo.sample(0, null, null).move_x, 1.0), "J1 derecha → move_x = 1")
	Input.action_release(&"p1_right")
	Input.action_press(&"p2_left")
	check(is_equal_approx(solo.sample(0, null, null).move_x, -1.0), "un solo jugador también puede usar las teclas de J2")
	Input.action_release(&"p2_left")
	var p2_only := HumanController.new(PackedStringArray(["p2_"]))
	Input.action_press(&"p1_right")
	check(is_zero_approx(p2_only.sample(0, null, null).move_x), "con dos jugadores, J2 no lee las teclas de J1")
	Input.action_release(&"p1_right")
	# La partida muestrea en el tick de física, igual que aquí.
	Input.action_press(&"p1_push")
	await tree.physics_frame
	var f := solo.sample(0, null, null)
	check(f.push_pressed and not f.jump_pressed, "empujón detectado como pulsación en el tick")
	await tree.physics_frame
	check(not solo.sample(1, null, null).push_pressed, "mantenerlo no repite el empujón en el tick siguiente")
	Input.action_release(&"p1_push")

	# Controles táctiles (coordenadas locales del viewport)
	var layer := CanvasLayer.new()
	tree.root.add_child(layer)
	var touch := TouchControls.new()
	layer.add_child(touch)
	await frames(2)
	var jump_c := touch.jump.get_global_rect().get_center()
	var stick_c := touch.joystick.get_global_rect().get_center()
	_touch(0, stick_c, true)
	_drag(0, stick_c + Vector2(90, 0))
	check(Input.get_action_strength(&"p1_right") > 0.5 and not Input.is_action_pressed(&"p1_left"), "joystick a la derecha → p1_right (%.2f)" % Input.get_action_strength(&"p1_right"))
	_touch(1, jump_c, true)
	check(Input.is_action_pressed(&"p1_jump") and Input.is_action_pressed(&"p1_right"), "multitáctil: joystick + salto a la vez")
	_touch(2, touch.push.get_global_rect().get_center(), true)
	check(Input.is_action_pressed(&"p1_push"), "botón de empujar")
	_touch(2, touch.push.get_global_rect().get_center(), false)
	_touch(3, touch.shield.get_global_rect().get_center(), true)
	check(Input.is_action_pressed(&"p1_shield"), "botón de protección")
	_touch(3, touch.shield.get_global_rect().get_center(), false)
	_drag(0, stick_c + Vector2(-90, 0))
	check(Input.is_action_pressed(&"p1_left") and not Input.is_action_pressed(&"p1_right"), "joystick a la izquierda → p1_left")
	_touch(0, stick_c, false)
	_touch(1, jump_c, false)
	check(not Input.is_action_pressed(&"p1_left") and not Input.is_action_pressed(&"p1_jump"), "al soltar se liberan las acciones")
	# Botón de herramienta: mantener = apuntar; arrastrar = dirección; soltar = usar.
	var solo_tool := HumanController.new(PackedStringArray(["p1_", "p2_"]))
	var tool_c := touch.tool.get_global_rect().get_center()
	_touch(4, tool_c, true)
	await tree.physics_frame
	var held := solo_tool.sample(0, null, null)
	check(held.tool_held and not held.tool_pressed, "mantener el botón de herramienta = apuntar (sin usarla)")
	_drag(4, tool_c + Vector2(60, -60))
	await tree.physics_frame
	var aiming := solo_tool.sample(1, null, null)
	check(aiming.aim.x > 0.6 and aiming.aim.y < -0.6, "arrastrar elige la dirección (%.2f, %.2f)" % [aiming.aim.x, aiming.aim.y])
	_touch(4, tool_c + Vector2(60, -60), false)
	await tree.physics_frame
	var fired := solo_tool.sample(2, null, null)
	check(fired.tool_pressed and fired.aim.x > 0.6 and fired.aim.y < -0.6, "al soltar se usa en la dirección apuntada")
	await tree.physics_frame
	check(not solo_tool.sample(3, null, null).tool_pressed, "soltar la usa una sola vez")
	var p2 := HumanController.new(PackedStringArray(["p2_"]))
	Input.action_press(&"p2_tool")
	await tree.physics_frame
	check(p2.sample(0, null, null).tool_held and InputMap.has_action(&"p2_tool"), "J2 tiene su propia tecla de herramienta")
	Input.action_release(&"p2_tool")
	layer.queue_free()
	await frames(1)


func _touch(index: int, pos: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.position = pos
	e.pressed = pressed
	tree.root.push_input(e, true)


func _drag(index: int, pos: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = index
	e.position = pos
	tree.root.push_input(e, true)
