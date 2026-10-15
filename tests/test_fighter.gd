extends TestSuite
## Personaje: movimiento, salto, empujón, protección.


func run() -> void:
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(640, 620), Vector2(1600, 40))
	TestWorld.add_spawn(a, Vector2(400, 560))
	TestWorld.add_spawn(a, Vector2(490, 560))
	TestWorld.add_spawn(a, Vector2(1100, 560))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules())
	var fa := m.participants[0].fighter
	var fb := m.participants[1].fighter
	var ca := TestWorld.ctl_of(m, 0)
	var cb := TestWorld.ctl_of(m, 1)

	check(await wait_until(func() -> bool: return fa.is_on_floor() and fb.is_on_floor(), 90), "caen y se apoyan en el suelo")

	# Movimiento
	var x0 := fa.global_position.x
	ca.move_x = -1.0
	await frames(30)
	ca.move_x = 0.0
	check(fa.global_position.x < x0 - 100.0, "se mueve a la izquierda (%.0f → %.0f)" % [x0, fa.global_position.x])
	check(absf(fa.velocity.x) <= fa.stats.max_speed + 1.0, "no supera la velocidad máxima")
	await frames(20)
	check(absf(fa.velocity.x) < 1.0, "se detiene al soltar")

	# Salto completo y salto corto
	var top := await _jump_apex(fa, ca, 40)
	var expected := fa.stats.jump_velocity * fa.stats.jump_velocity / (2.0 * fa.stats.gravity)
	check(absf(top - expected) < 25.0, "altura del salto ≈ %.0f px (medido %.0f)" % [expected, top])
	await frames(30)
	var short := await _jump_apex(fa, ca, 2)
	check(short < top * 0.7, "soltar pronto da un salto más bajo (%.0f px)" % short)
	await frames(40)

	# Volver a colocar: A mirando a B, muy cerca
	fa.global_position = Vector2(430, 572)
	fb.global_position = Vector2(490, 572)
	fa.facing = 1
	await frames(5)
	var pushes := [0]
	fa.pushed.connect(func(_t: Array) -> void: pushes[0] += 1)
	ca.press_push()
	await frames(1)
	check(fb.velocity.x > 400.0, "el empujón lanza al rival (vx = %.0f)" % fb.velocity.x)
	check(fb.state == Fighter.State.STUNNED, "el rival queda aturdido")
	check(fb.last_pusher == fa, "se registra quién empujó")
	ca.press_push()
	await frames(1)
	check(pushes[0] == 1, "el enfriamiento impide empujar dos veces seguidas")
	var bx := fb.global_position.x
	await frames(30)
	check(fb.global_position.x > bx + 60.0, "el rival sale desplazado (%.0f px)" % (fb.global_position.x - bx))

	# Empujón fuera de alcance
	await frames(40)
	fa.global_position = Vector2(300, 572)
	fb.global_position = Vector2(600, 572)
	await frames(5)
	ca.press_push()
	await frames(1)
	check(absf(fb.velocity.x) < 1.0, "un rival lejano no recibe el empujón")

	# Protección
	await frames(40)
	fa.global_position = Vector2(430, 572)
	fb.global_position = Vector2(490, 572)
	fa.facing = 1
	await frames(5)
	cb.press_shield()
	await frames(2)
	check(fb.is_shielded(), "se activa la protección")
	ca.press_push()
	await frames(1)
	check(fb.velocity.x < fa.stats.push_force * 0.3, "la protección reduce el empujón (vx = %.0f)" % fb.velocity.x)
	check(fa.velocity.x < -100.0, "quien empuja a un protegido sale rebotado (vx = %.0f)" % fa.velocity.x)
	await frames(60)
	check(not fb.is_shielded(), "la protección dura poco")
	cb.press_shield()
	await frames(1)
	check(not fb.is_shielded(), "la protección tiene enfriamiento")

	await cleanup(TestWorld.holder_of(m))


## Salta manteniendo el botón `hold` ticks y devuelve la altura máxima alcanzada.
func _jump_apex(f: Fighter, c: ScriptedController, hold: int) -> float:
	var y0 := f.global_position.y
	var top := y0
	c.press_jump()
	for i in 90:
		if i == hold:
			c.jump_held = false
		await tree.physics_frame
		top = minf(top, f.global_position.y)
		if i > 5 and f.is_on_floor():
			break
	c.jump_held = false
	return y0 - top
