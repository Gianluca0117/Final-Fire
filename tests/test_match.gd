extends TestSuite
## Partida: cuenta atrás, eliminación con autoría del empujón, ganador y empate.


func run() -> void:
	await _countdown()
	await _push_into_lava()
	await _draw()


func _countdown() -> void:
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(640, 620), Vector2(1600, 40))
	TestWorld.add_spawn(a, Vector2(400, 560))
	TestWorld.add_spawn(a, Vector2(800, 560))
	var rules := TestWorld.quiet_rules()
	rules.countdown = 1.0
	var m := TestWorld.start_match(tree.root, a, rules)
	var ticks := []
	m.countdown_changed.connect(func(n: int) -> void: ticks.append(n))
	var started := [false]
	m.match_started.connect(func() -> void: started[0] = true)
	TestWorld.ctl_of(m, 0).move_x = 1.0
	await frames(30)
	var f := m.participants[0].fighter
	check(m.phase == MatchController.Phase.COUNTDOWN and absf(f.global_position.x - 400.0) < 1.0, "durante la cuenta atrás nadie se mueve")
	check(await wait_until(func() -> bool: return started[0], 60), "la partida empieza al terminar la cuenta atrás")
	check(ticks.has(0), "la cuenta atrás termina en 0 (¡YA!)")
	await frames(20)
	check(f.global_position.x > 450.0, "después ya se puede mover")
	await cleanup(TestWorld.holder_of(m))


func _push_into_lava() -> void:
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(300, 620), Vector2(600, 40))   # el suelo acaba en x = 600
	a.get_child(0).start_level_y = 700.0
	TestWorld.add_spawn(a, Vector2(500, 560))
	TestWorld.add_spawn(a, Vector2(565, 560))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules())
	var pa := m.participants[0]
	var pb := m.participants[1]
	var eliminated := []
	m.participant_eliminated.connect(func(p: Participant, cause: StringName, by: Participant) -> void: eliminated.append([p, cause, by]))
	var result := [null, false]
	m.match_finished.connect(func(w: Participant) -> void:
		result[0] = w
		result[1] = true)
	await frames(30)
	pa.fighter.facing = 1
	TestWorld.ctl_of(m, 0).press_push()
	check(await wait_until(func() -> bool: return result[1], 180), "la partida termina cuando queda uno")
	check(eliminated.size() == 1 and eliminated[0][0] == pb and eliminated[0][1] == &"lava", "el empujado cae a la lava y es eliminado")
	check(eliminated.size() == 1 and eliminated[0][2] == pa and pa.eliminations == 1, "la eliminación cuenta para quien empujó")
	check(result[0] == pa and pa.place == 1 and pb.place == 2, "gana el último en pie (puestos 1 y 2)")
	check(pb.fighter.state == Fighter.State.ELIMINATED, "el personaje eliminado queda inactivo")
	await cleanup(TestWorld.holder_of(m))


func _draw() -> void:
	var a := TestWorld.arena()
	var s1 := TestWorld.add_segment(a, Vector2(400, 620))
	var s2 := TestWorld.add_segment(a, Vector2(800, 620))
	TestWorld.add_spawn(a, Vector2(400, 560))
	TestWorld.add_spawn(a, Vector2(800, 560))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules())
	var result := [false, null]
	m.match_finished.connect(func(w: Participant) -> void:
		result[0] = true
		result[1] = w)
	await frames(30)
	s1.warn(0.1, 5.0)
	s2.warn(0.1, 5.0)
	check(await wait_until(func() -> bool: return result[0], 60), "la partida termina")
	check(result[1] == null and m.participants.all(func(p: Participant) -> bool: return p.place == 1), "si los últimos caen a la vez hay empate")
	await cleanup(TestWorld.holder_of(m))
