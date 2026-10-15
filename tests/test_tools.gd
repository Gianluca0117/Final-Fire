extends TestSuite
## Herramienta única por fase: ciclo de fases y aviso previo, recogida (también simultánea),
## una por jugador, portador eliminado, fin de fase, Ancla (incluido su final) y Gancho
## (destino válido, obstáculos, fuera del escenario, fuera de alcance).


func run() -> void:
	await _phase_cycle()
	await _pickup_one_holder()
	await _simultaneous_pickup()
	await _carrier_eliminated_respawn()
	await _carrier_eliminated_lose()
	await _anchor()
	await _anchor_saves_collapse()
	await _anchor_invalid()
	await _hook_valid()
	await _hook_blocked_by_obstacle()
	await _hook_outside_arena()
	await _hook_out_of_range()


## Suelo, dos personajes y un punto de herramienta; devuelve [partida, arena].
func _world(rules: MatchRules, spawns: Array[Vector2], tool_at: Vector2, rng_seed := 1) -> MatchController:
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(640, 620), Vector2(1600, 40))
	for s in spawns:
		TestWorld.add_spawn(a, s)
	TestWorld.add_tool_spawn(a, tool_at)
	return TestWorld.start_match(tree.root, a, rules, rng_seed)


func _phase_cycle() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def(), TestWorld.hook_def()]
	var rules := TestWorld.tool_rules(pool, 2.0, 0.2, 0.3, 0.5)
	var m := _world(rules, [Vector2(200, 560), Vector2(1000, 560)], Vector2(640, 300))
	var t := m.tools
	var log: Array[String] = []
	var kinds := []
	var max_active := [0]
	t.phase_started.connect(func(i: int, _p: PhaseDefinition) -> void: log.append("fase%d" % i))
	t.tool_announced.connect(func(d: ToolDefinition, pos: Vector2, s: float) -> void:
		log.append("aviso")
		kinds.append(d.id)
		check(pos == Vector2(640, 300) and is_equal_approx(s, 0.3) and t.state == ToolSystem.State.ANNOUNCED, "el aviso indica ubicación, tipo (%s) y tiempo antes de aparecer" % d.display_name))
	t.tool_spawned.connect(func(_d: ToolDefinition, _p: Vector2) -> void: log.append("aparece"))
	t.tool_expiring.connect(func(_d: ToolDefinition, s: float) -> void: log.append("caduca_pronto(%.1f)" % s))
	t.tool_expired.connect(func(_d: ToolDefinition, r: StringName) -> void: log.append("caduca:" + r))
	await wait_until(func() -> bool:
		max_active[0] = maxi(max_active[0], 1 if t._is_active() else 0)
		return t.phase_index >= 2, 60 * 6)
	var seq := ", ".join(log)
	check(log.slice(0, 6) == ["fase0", "aviso", "aparece", "caduca_pronto(0.5)", "caduca:phase_end", "fase1"], "orden: fase → aviso → aparece → aviso de caducidad → caduca → nueva fase (%s)" % seq)
	check(log.find("aviso", 2) > log.find("caduca:phase_end"), "la siguiente herramienta solo se anuncia tras caducar la anterior")
	check(kinds.size() >= 2 and kinds[0] != kinds[1], "fases seguidas no repiten herramienta (%s)" % str(kinds))
	await cleanup(TestWorld.holder_of(m))


func _pickup_one_holder() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def()]
	var rules := TestWorld.tool_rules(pool, 2.0, 0.2, 0.3, 0.5)
	var m := _world(rules, [Vector2(400, 560), Vector2(1000, 560)], Vector2(400, 572))
	var t := m.tools
	var pa := m.participants[0]
	var pb := m.participants[1]
	var picks := []
	t.tool_picked.connect(func(_d: ToolDefinition, by: Participant) -> void: picks.append(by))
	check(await wait_until(func() -> bool: return t.holds(pa), 60), "quien está encima recoge la herramienta al aparecer")
	pb.fighter.global_position = Vector2(400, 572)   # el rival llega al mismo punto
	await frames(10)
	check(picks.size() == 1 and t.holds(pa) and not t.holds(pb), "una herramienta en manos de alguien no la puede recoger otro")
	check(await wait_until(func() -> bool: return t.phase_index == 1, 120), "llega el final de la fase")
	check(not t.holds(pa) and t.held_by(pa) == null, "al terminar la fase el portador pierde la herramienta (caduca)")
	pb.fighter.global_position = Vector2(1000, 572)
	check(await wait_until(func() -> bool: return t.holds(pa), 60), "en la fase siguiente puede recoger la nueva")
	check(picks.size() == 2, "cada jugador lleva como mucho una herramienta (recogidas: %d)" % picks.size())
	await cleanup(TestWorld.holder_of(m))


func _simultaneous_pickup() -> void:
	var winners := {}
	for s in [3, 4, 5, 6, 7, 8]:
		var pool: Array[ToolDefinition] = [TestWorld.anchor_def()]
		var rules := TestWorld.tool_rules(pool, 5.0, 0.2, 0.3, 0.5)
		# Los dos a la misma distancia (35 px) del punto de aparición cuando aparece.
		var m := _world(rules, [Vector2(605, 560), Vector2(675, 560)], Vector2(640, 572), s)
		var picks := []
		m.tools.tool_picked.connect(func(_d: ToolDefinition, by: Participant) -> void: picks.append(by))
		await wait_until(func() -> bool: return not picks.is_empty(), 60)
		await frames(5)
		var holders := m.participants.filter(func(p: Participant) -> bool: return m.tools.holds(p))
		check(picks.size() == 1 and holders.size() == 1, "semilla %d: recogida simultánea → un solo portador (%s)" % [s, picks[0].display_name if picks.size() > 0 else "nadie"])
		if holders.size() == 1:
			winners[holders[0].display_name] = true
		await cleanup(TestWorld.holder_of(m))
	check(winners.size() == 2, "el empate exacto se sortea con la semilla: ganan ambos según la partida (%s)" % str(winners.keys()))


func _carrier_eliminated_respawn() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def()]
	var rules := TestWorld.tool_rules(pool, 12.0, 0.2, 0.3, 0.5)
	var m := _world(rules, [Vector2(400, 560), Vector2(900, 560), Vector2(1100, 560)], Vector2(400, 572))
	var t := m.tools
	var pa := m.participants[0]
	var log: Array[String] = []
	t.tool_dropped.connect(func(_d: ToolDefinition, by: Participant) -> void: log.append("pierde:" + by.display_name))
	t.tool_announced.connect(func(_d: ToolDefinition, pos: Vector2, s: float) -> void: log.append("aviso(%d,%d,%.1f)" % [pos.x, pos.y, s]))
	await wait_until(func() -> bool: return t.holds(pa), 60)
	pa.fighter.global_position = Vector2(400, 1000)   # cae a la lava
	check(await wait_until(func() -> bool: return not pa.alive, 10), "el portador es eliminado")
	check(not t.holds(pa) and log.has("pierde:P0"), "pierde la herramienta al ser eliminado")
	check(log.back() == "aviso(400,572,1.5)", "con tiempo de fase suficiente, reaparece con aviso en su punto (%s)" % ", ".join(log))
	var pb := m.participants[1]
	pb.fighter.global_position = Vector2(400, 572)
	check(await wait_until(func() -> bool: return t.holds(pb), 150), "otro jugador puede recogerla después")
	await cleanup(TestWorld.holder_of(m))


func _carrier_eliminated_lose() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def()]
	var rules := TestWorld.tool_rules(pool, 3.0, 0.2, 0.3, 0.5)   # quedan < 5 s de fase
	var m := _world(rules, [Vector2(400, 560), Vector2(900, 560), Vector2(1100, 560)], Vector2(400, 572))
	var t := m.tools
	var pa := m.participants[0]
	var expired := []
	t.tool_expired.connect(func(_d: ToolDefinition, r: StringName) -> void: expired.append(r))
	await wait_until(func() -> bool: return t.holds(pa), 60)
	pa.fighter.global_position = Vector2(400, 1000)
	await wait_until(func() -> bool: return not pa.alive, 10)
	check(expired == [&"carrier_eliminated"] and t.state == ToolSystem.State.GONE, "sin tiempo de fase suficiente, se pierde hasta la fase siguiente")
	await cleanup(TestWorld.holder_of(m))


## Plataforma con desgaste rápido; el portador del Ancla en el lado derecho.
func _anchor_world(rules: MatchRules, wear: float) -> MatchController:
	var params := PlatformParams.new()
	params.wear_per_occupant = wear
	params.respawn_delay = 0.0
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(640, 640), Vector2(1600, 40))
	TestWorld.add_platform(a, Vector2(640, 400), params)
	TestWorld.add_spawn(a, Vector2(705, 340))
	TestWorld.add_spawn(a, Vector2(655, 340))
	TestWorld.add_spawn(a, Vector2(150, 560))
	TestWorld.add_tool_spawn(a, Vector2(705, 360))
	return TestWorld.start_match(tree.root, a, rules)


func _anchor() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def(1.5, 0.5)]
	var m := _anchor_world(TestWorld.tool_rules(pool, 10.0, 0.0, 0.05, 0.5), 0.12)
	var t := m.tools
	var pa := m.participants[0]
	var plat: UnstablePlatform = m.arena.platforms[0]
	var warnings := []
	m.arena.hazard_warned.connect(func(kind: StringName, _r: Rect2, s: float) -> void:
		if kind == &"anchor_ending":
			warnings.append([s, plat.anchor_left]))
	var released := [false]
	plat.anchor_released.connect(func() -> void: released[0] = true)
	await wait_until(func() -> bool: return t.holds(pa) and absf(plat.rotation_degrees) > 6.0, 120)
	check(t.holds(pa) and plat.rotation_degrees > 6.0, "con el Ancla en mano la plataforma sigue inclinándose (%.1f°)" % plat.rotation_degrees)
	var used := []
	t.tool_used.connect(func(d: ToolDefinition, by: Participant, _tg: ToolTarget) -> void: used.append([d.id, by]))
	TestWorld.ctl_of(m, 0).press_tool()
	await frames(1)
	check(used.size() == 1 and plat.is_anchored(), "usar el Ancla estabiliza la plataforma donde está")
	check(t.state == ToolSystem.State.GONE and not t.holds(pa), "el Ancla se consume (un solo uso)")
	var integrity := plat.integrity
	await frames(30)
	check(absf(plat.rotation_degrees) < 0.5, "anclada se nivela y no se inclina (%.2f°)" % plat.rotation_degrees)
	check(is_equal_approx(plat.integrity, integrity), "anclada no se desgasta")
	var both_on := m.participants[0].fighter.floor_body == plat and m.participants[1].fighter.floor_body == plat
	check(both_on, "todos los que están encima la aprovechan (2 personajes sobre ella)")
	check(await wait_until(func() -> bool: return released[0], 120), "el Ancla termina al acabar su duración")
	# El aviso salta en el tick en que quedan ≤ 0,5 s (tolerancia de un tick).
	check(warnings.size() == 1 and absf(warnings[0][0] - 0.5) <= 1.0 / 60.0 + 0.001, "avisa antes de soltarse, con %.2f s de margen" % (warnings[0][0] if warnings.size() > 0 else -1.0))
	await frames(40)
	check(absf(plat.rotation_degrees) > 3.0 and plat.integrity < integrity, "al soltarse recupera su comportamiento: se inclina (%.1f°) y se desgasta" % plat.rotation_degrees)
	await cleanup(TestWorld.holder_of(m))


func _anchor_saves_collapse() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def(1.0, 0.3)]
	var m := _anchor_world(TestWorld.tool_rules(pool, 10.0, 0.0, 0.05, 0.5), 3.0)
	var t := m.tools
	var plat: UnstablePlatform = m.arena.platforms[0]
	check(await wait_until(func() -> bool: return plat.stage == UnstablePlatform.Stage.COLLAPSING and t.holds(m.participants[0]), 120), "la plataforma está a punto de caer (aviso)")
	TestWorld.ctl_of(m, 0).press_tool()
	await frames(1)
	check(plat.is_anchored() and plat.stage == UnstablePlatform.Stage.CRITICAL, "el Ancla evita el derrumbe en el último momento")
	await frames(40)
	check(plat.stage == UnstablePlatform.Stage.CRITICAL, "mientras está anclada no cae")
	await cleanup(TestWorld.holder_of(m))


func _anchor_invalid() -> void:
	var pool: Array[ToolDefinition] = [TestWorld.anchor_def()]
	var m := _world(TestWorld.tool_rules(pool, 10.0, 0.0, 0.05, 0.5), [Vector2(400, 560), Vector2(1000, 560)], Vector2(400, 572))
	var t := m.tools
	var fails := []
	t.tool_use_failed.connect(func(_d: ToolDefinition, _b: Participant, r: StringName) -> void: fails.append(r))
	await wait_until(func() -> bool: return t.holds(m.participants[0]), 60)
	TestWorld.ctl_of(m, 0).press_tool()
	await frames(2)
	check(fails == [&"no_platform"] and t.holds(m.participants[0]), "sin plataforma cerca el Ancla no se gasta")
	await cleanup(TestWorld.holder_of(m))


## Mundo para el Gancho: el portador recibe la herramienta en su posición.
func _hook_world(extra: Callable) -> MatchController:
	var pool: Array[ToolDefinition] = [TestWorld.hook_def()]
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(640, 620), Vector2(1600, 40))
	TestWorld.add_spawn(a, Vector2(640, 560))
	TestWorld.add_spawn(a, Vector2(150, 560))
	TestWorld.add_tool_spawn(a, Vector2(640, 572))
	extra.call(a)
	return TestWorld.start_match(tree.root, a, TestWorld.tool_rules(pool, 20.0, 0.0, 0.05, 0.5))


func _hook_valid() -> void:
	var m := _hook_world(func(a: Arena) -> void: TestWorld.add_block(a, Vector2(640, 380), Vector2(160, 30)))
	var t := m.tools
	var pa := m.participants[0]
	await wait_until(func() -> bool: return t.holds(pa), 60)
	await frames(2)
	var preview: ToolTarget = t.previews.get(pa)
	check(preview != null and preview.valid and absf(preview.point.y - 395.0) < 2.0, "la vista previa muestra el destino antes de usarlo (%s)" % (str(preview.point) if preview else "nada"))
	var y0 := pa.fighter.global_position.y
	TestWorld.ctl_of(m, 0).press_tool(Vector2.UP)
	var closest := [INF]
	await wait_until(func() -> bool:
		closest[0] = minf(closest[0], pa.fighter.global_position.distance_to(preview.point))
		return pa.fighter.is_hooking(), 5)
	check(pa.fighter.is_hooking() and t.state == ToolSystem.State.GONE, "con destino válido tira del portador y se consume")
	await wait_until(func() -> bool:
		closest[0] = minf(closest[0], pa.fighter.global_position.distance_to(preview.point))
		return not pa.fighter.is_hooking(), 60)
	check(closest[0] < 45.0 and pa.fighter.global_position.y < y0 - 100.0, "llega junto a la superficie (a %.0f px)" % closest[0])
	await cleanup(TestWorld.holder_of(m))


func _hook_blocked_by_obstacle() -> void:
	var lava_ceiling: Array = []
	var m := _hook_world(func(a: Arena) -> void:
		# Un techo de lava (superficie no válida) tapa un bloque válido que queda detrás.
		var s := TestWorld.add_segment(a, Vector2(640, 470))
		s.size = Vector2(500, 20)
		lava_ceiling.append(s)
		TestWorld.add_block(a, Vector2(640, 300), Vector2(500, 30)))
	var t := m.tools
	var pa := m.participants[0]
	await wait_until(func() -> bool: return t.holds(pa), 60)
	(lava_ceiling[0] as LavaFloorSegment).warn(0.0, 100.0)
	await frames(2)
	var target := t.find_target(pa.fighter, Vector2.UP)
	check(not target.valid and target.reason == &"unsafe_surface", "no atraviesa obstáculos: el rayo se detiene en el techo de lava (%s)" % target.reason)
	var y0 := pa.fighter.global_position.y
	TestWorld.ctl_of(m, 0).press_tool(Vector2.UP)
	await frames(10)
	check(t.holds(pa) and not pa.fighter.is_hooking() and absf(pa.fighter.global_position.y - y0) < 2.0, "con destino inválido no se gasta ni se mueve")
	await cleanup(TestWorld.holder_of(m))


func _hook_outside_arena() -> void:
	var m := _hook_world(func(a: Arena) -> void:
		a.play_area = Rect2(0, 0, 1280, 720)
		TestWorld.add_block(a, Vector2(1000, 560), Vector2(40, 200)))
	var t := m.tools
	var pa := m.participants[0]
	await wait_until(func() -> bool: return t.holds(pa), 60)
	await wait_until(func() -> bool: return pa.fighter.is_on_floor(), 30)
	m.arena.play_area = Rect2(0, 0, 900, 720)   # el bloque queda fuera de la zona visible
	var target := t.find_target(pa.fighter, Vector2.RIGHT)
	check(not target.valid and target.reason == &"out_of_arena", "no se engancha fuera del escenario (%s)" % target.reason)
	TestWorld.ctl_of(m, 0).press_tool(Vector2.RIGHT)
	await frames(3)
	check(t.holds(pa), "y no se consume")
	await cleanup(TestWorld.holder_of(m))


func _hook_out_of_range() -> void:
	var m := _hook_world(func(a: Arena) -> void: TestWorld.add_block(a, Vector2(640, 572 - 480), Vector2(300, 30)))
	var t := m.tools
	var pa := m.participants[0]
	await wait_until(func() -> bool: return t.holds(pa), 60)
	var target := t.find_target(pa.fighter, Vector2.UP)
	check(not target.valid and target.reason == &"out_of_range", "una superficie más allá del alcance no vale (%s)" % target.reason)
	TestWorld.ctl_of(m, 0).press_tool(Vector2.UP)
	await frames(3)
	check(t.holds(pa), "y no se consume")
	await cleanup(TestWorld.holder_of(m))
