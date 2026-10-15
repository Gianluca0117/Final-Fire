extends TestSuite
## Arena: inclinaciÃ³n, desgaste y caÃ­da, suelo de lava con aviso, subida de lava.


func run() -> void:
	await _tilt_and_slide()
	await _wear_and_respawn()
	await _floor_waves()
	await _pool_rise()
	await _same_seed_same_hazards()
	await _lava_cave_routes()


func _tilt_and_slide() -> void:
	var params := PlatformParams.new()
	params.wear_enabled = false
	var a := TestWorld.arena()
	var p := TestWorld.add_platform(a, Vector2(640, 400), params)
	TestWorld.add_block(a, Vector2(640, 640), Vector2(1600, 40))
	TestWorld.add_spawn(a, Vector2(705, 340))
	TestWorld.add_spawn(a, Vector2(200, 560))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules())
	var f := m.participants[0].fighter
	check(await wait_until(func() -> bool: return f.floor_body == p, 60), "el personaje queda sobre la plataforma")
	var max_tilt := [0.0]
	var x0 := f.global_position.x
	await wait_until(func() -> bool:
		max_tilt[0] = maxf(max_tilt[0], p.rotation_degrees)
		return f.floor_body != p, 120)
	check(max_tilt[0] > 5.0, "la plataforma se inclina hacia el lado cargado (mÃ¡x. %.1fÂ°)" % max_tilt[0])
	check(max_tilt[0] <= params.max_tilt_deg + 0.01, "la inclinaciÃ³n respeta el mÃ¡ximo")
	check(f.global_position.x > x0 + 20.0, "quieto en la plataforma inclinada se resbala hacia abajo (%.0f px)" % (f.global_position.x - x0))
	check(await wait_until(func() -> bool: return absf(p.rotation_degrees) < 0.5, 120), "sin carga vuelve a nivelarse")
	await cleanup(TestWorld.holder_of(m))


func _wear_and_respawn() -> void:
	var params := PlatformParams.new()
	params.tilt_enabled = false
	params.wear_per_occupant = 0.8
	params.collapse_warning = 0.5
	params.respawn_delay = 0.6
	params.respawn_warning = 0.3
	var a := TestWorld.arena()
	var p := TestWorld.add_platform(a, Vector2(640, 400), params)
	TestWorld.add_block(a, Vector2(640, 640), Vector2(1600, 40))
	TestWorld.add_spawn(a, Vector2(640, 340))
	TestWorld.add_spawn(a, Vector2(200, 560))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules())
	var events: Array[String] = []
	p.stage_changed.connect(func(s: UnstablePlatform.Stage) -> void: events.append(UnstablePlatform.Stage.keys()[s]))
	a.hazard_warned.connect(func(kind: StringName, _r: Rect2, _s: float) -> void: events.append("AVISO:" + kind))
	check(await wait_until(func() -> bool: return p.stage == UnstablePlatform.Stage.FALLING, 200), "se desgasta con alguien encima hasta caer")
	var warn_i := events.find("AVISO:platform_collapse")
	check(warn_i >= 0 and warn_i < events.find("FALLING"), "avisa antes de caer: " + ", ".join(events))
	check(await wait_until(func() -> bool: return p.stage == UnstablePlatform.Stage.GONE, 200), "desaparece tras caer")
	check(await wait_until(func() -> bool: return p.stage == UnstablePlatform.Stage.INTACT, 200), "reaparece entera tras el aviso")
	check(events.has("CRACKED") and events.has("CRITICAL") and events.has("RESPAWNING"), "pasa por agrietada, crÃ­tica y reapareciendo")
	await cleanup(TestWorld.holder_of(m))


func _floor_waves() -> void:
	var phase := HazardSchedule.new()
	phase.first_wave_at = 0.5
	phase.wave_interval = 100.0
	phase.wave_warning = 0.5
	phase.wave_lava_time = 0.5
	phase.segments_first_wave = 3
	phase.pool_rise_times = PackedFloat32Array()
	phase.pool_rise_levels = PackedFloat32Array()
	phase.sudden_death_at = 1e9
	var a := TestWorld.arena()
	var segs: Array[LavaFloorSegment] = []
	for i in 3:
		segs.append(TestWorld.add_segment(a, Vector2(400 + i * 192, 620)))
	TestWorld.add_spawn(a, Vector2(400, 560))
	TestWorld.add_spawn(a, Vector2(592, 560))
	TestWorld.add_spawn(a, Vector2(784, 560))
	# Dos testigos a salvo para que la partida siga tras las eliminaciones.
	TestWorld.add_block(a, Vector2(1200, 300), Vector2(200, 30))
	TestWorld.add_spawn(a, Vector2(1150, 240))
	TestWorld.add_spawn(a, Vector2(1250, 240))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules(phase))
	var warnings := []
	a.hazard_warned.connect(func(kind: StringName, _r: Rect2, s: float) -> void: warnings.append([kind, s, a.time]))
	check(await wait_until(func() -> bool: return not warnings.is_empty(), 60), "se anuncia una oleada de lava")
	var warned := segs.filter(func(s: LavaFloorSegment) -> bool: return s.stage == LavaFloorSegment.Stage.WARNING)
	check(warned.size() == 2, "se avisa en 2 de 3 tramos: siempre queda uno seguro (%d)" % warned.size())
	check(warnings.size() > 0 and warnings[0][0] == &"floor_lava" and is_equal_approx(warnings[0][1], 0.5), "el aviso indica el tiempo restante (0,5 s)")
	var seg: LavaFloorSegment = warned[0]
	await frames(20)
	check(seg.stage == LavaFloorSegment.Stage.WARNING, "durante el aviso el tramo todavÃ­a es seguro")
	var victims := m.participants.filter(func(p: Participant) -> bool:
		return p.fighter.floor_body is LavaFloorSegment and warned.has(p.fighter.floor_body))
	check(await wait_until(func() -> bool: return seg.stage == LavaFloorSegment.Stage.LAVA, 30), "tras el aviso el tramo se convierte en lava")
	await frames(2)
	var burned := victims.all(func(p: Participant) -> bool: return not p.alive and p.elimination_cause == &"lava")
	check(victims.size() > 0 and burned, "quien estaba encima es eliminado por la lava (%d)" % victims.size())
	check(await wait_until(func() -> bool: return seg.stage == LavaFloorSegment.Stage.SAFE, 60), "la lava del suelo se enfrÃ­a despuÃ©s")
	await cleanup(TestWorld.holder_of(m))


func _pool_rise() -> void:
	var phase := HazardSchedule.new()
	phase.floor_waves_enabled = false
	phase.pool_rise_times = PackedFloat32Array([0.6])
	phase.pool_rise_levels = PackedFloat32Array([500.0])
	phase.pool_rise_warning = 0.4
	phase.pool_rise_duration = 0.3
	phase.sudden_death_at = 1e9
	var a := TestWorld.arena()
	TestWorld.add_block(a, Vector2(640, 620), Vector2(1600, 40))
	TestWorld.add_block(a, Vector2(1100, 300), Vector2(200, 30))
	TestWorld.add_spawn(a, Vector2(400, 560))
	TestWorld.add_spawn(a, Vector2(1060, 240))
	TestWorld.add_spawn(a, Vector2(1140, 240))
	var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules(phase))
	var warned_at := [-1.0]
	a.hazard_warned.connect(func(kind: StringName, _r: Rect2, _s: float) -> void:
		if kind == &"pool_rise":
			warned_at[0] = a.time)
	check(await wait_until(func() -> bool: return a.lava_pool.level_y <= 500.0, 120), "la lava inferior sube al nivel programado")
	check(warned_at[0] > 0.0 and warned_at[0] <= 0.6 - 0.35, "la subida se anuncia antes (a los %.2f s)" % warned_at[0])
	await frames(2)
	check(not m.participants[0].alive and m.participants[0].elimination_cause == &"lava", "quien queda por debajo de la lava es eliminado")
	check(m.participants[1].alive and m.participants[2].alive, "quienes estÃ¡n a salvo en alto siguen vivos")
	await cleanup(TestWorld.holder_of(m))


func _same_seed_same_hazards() -> void:
	var runs := []
	for r in 2:
		var phase := HazardSchedule.new()
		phase.first_wave_at = 0.1
		phase.wave_interval = 0.3
		phase.wave_warning = 0.1
		phase.wave_lava_time = 0.1
		phase.pool_rise_times = PackedFloat32Array()
		phase.pool_rise_levels = PackedFloat32Array()
		phase.sudden_death_at = 1e9
		var a := TestWorld.arena()
		for i in 5:
			TestWorld.add_segment(a, Vector2(200 + i * 192, 620))
		TestWorld.add_block(a, Vector2(640, 300), Vector2(1600, 30))
		TestWorld.add_spawn(a, Vector2(300, 240))
		TestWorld.add_spawn(a, Vector2(900, 240))
		var m := TestWorld.start_match(tree.root, a, TestWorld.quiet_rules(phase), 4242)
		var seq := []
		a.hazard_warned.connect(func(_k: StringName, rect: Rect2, _s: float) -> void: seq.append(int(rect.position.x)))
		await frames(90)
		runs.append(seq)
		await cleanup(TestWorld.holder_of(m))
	check(runs[0].size() > 3 and runs[0] == runs[1], "misma semilla â†’ mismos peligros (%s)" % str(runs[0]))


## La arena real: todas las superficies se alcanzan saltando desde el suelo, con la altura de
## salto real (vÂ²/2g) y un margen. AdemÃ¡s, un salto simulado del suelo al puente de madera.
func _lava_cave_routes() -> void:
	var stats: CharacterStats = load("res://data/characters/default_stats.tres")
	var jump_h := stats.jump_velocity * stats.jump_velocity / (2.0 * stats.gravity)
	var max_up := jump_h * 0.88
	var arena: Arena = load("res://game/arena/arenas/lava_cave.tscn").instantiate()
	tree.root.add_child(arena)
	arena.setup(HazardSchedule.new(), 1)
	var surfaces := []   # [nombre, x0, x1, top]
	for s in arena.segments:
		surfaces.append([s.name, s.rect().position.x, s.rect().end.x, s.rect().position.y])
	for b in arena.blocks:
		surfaces.append([b.name, b.global_position.x - b.size.x * 0.5, b.global_position.x + b.size.x * 0.5, b.top_y()])
	for p in arena.platforms:
		surfaces.append([p.name, p.rect().position.x, p.rect().end.x, p.rect().position.y])
	var reached := {}
	for s in surfaces:
		if s[0].begins_with("Segment"):
			reached[s[0]] = true
	var changed := true
	while changed:
		changed = false
		for a_s in surfaces:
			if not reached.has(a_s[0]):
				continue
			for b_s in surfaces:
				if reached.has(b_s[0]):
					continue
				var gap := maxf(0.0, maxf(b_s[1] - a_s[2], a_s[1] - b_s[2]))
				var dy: float = a_s[3] - b_s[3]   # > 0: b estÃ¡ mÃ¡s arriba
				if (dy > 0.0 and dy <= max_up and gap <= 150.0) or (dy <= 0.0 and gap <= 250.0):
					reached[b_s[0]] = true
					changed = true
	var missing := surfaces.filter(func(s: Array) -> bool: return not reached.has(s[0])).map(func(s: Array) -> String: return s[0])
	check(missing.is_empty(), "todas las superficies de la cueva son alcanzables (salto %.0f px; sin alcanzar: %s)" % [jump_h, str(missing)])
	var levels := {}
	for s in surfaces:
		levels[snappedf(s[3], 40.0)] = true
	check(levels.size() >= 5, "la arena usa la altura: %d niveles de superficie" % levels.size())
	arena.queue_free()
	await frames(1)

	# Salto simulado: desde el hueco central del suelo hacia el puente de la izquierda.
	var m: Node = load("res://scenes/match.tscn").instantiate()
	tree.root.add_child(m)
	var ctl := ScriptedController.new()
	var other := ScriptedController.new()
	var list: Array[Participant] = [Participant.new(0, "P0", Participant.Kind.DUMMY, ctl), Participant.new(0, "P1", Participant.Kind.DUMMY, other)]
	var mc: MatchController = m.match_ctl
	var rules := TestWorld.quiet_rules()
	mc.rules = rules
	mc.setup(m.arena, list, m.fighters_root, 1)
	m._configured = true
	mc.start()
	var f := list[0].fighter
	var bridge: UnstablePlatform = m.arena.get_node("Platforms/LeftBridge")
	f.global_position = Vector2(640, 525)
	list[1].fighter.global_position = Vector2(1066, 400)
	await frames(20)
	ctl.move_x = -1.0
	await frames(4)
	ctl.press_jump()
	var landed := await wait_until(func() -> bool: return f.floor_body == bridge, 90)
	ctl.move_x = 0.0
	ctl.jump_held = false
	check(landed, "salto real desde el suelo al puente de madera (ruta alcanzable)")
	m.queue_free()
	await frames(2)
