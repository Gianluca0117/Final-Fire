extends TestSuite
## Arena: inclinación, desgaste y caída, suelo de lava con aviso, subida de lava.


func run() -> void:
	await _tilt_and_slide()
	await _wear_and_respawn()
	await _floor_waves()
	await _pool_rise()
	await _same_seed_same_hazards()


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
	check(max_tilt[0] > 5.0, "la plataforma se inclina hacia el lado cargado (máx. %.1f°)" % max_tilt[0])
	check(max_tilt[0] <= params.max_tilt_deg + 0.01, "la inclinación respeta el máximo")
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
	check(events.has("CRACKED") and events.has("CRITICAL") and events.has("RESPAWNING"), "pasa por agrietada, crítica y reapareciendo")
	await cleanup(TestWorld.holder_of(m))


func _floor_waves() -> void:
	var phase := PhaseDefinition.new()
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
	check(seg.stage == LavaFloorSegment.Stage.WARNING, "durante el aviso el tramo todavía es seguro")
	var victims := m.participants.filter(func(p: Participant) -> bool:
		return p.fighter.floor_body is LavaFloorSegment and warned.has(p.fighter.floor_body))
	check(await wait_until(func() -> bool: return seg.stage == LavaFloorSegment.Stage.LAVA, 30), "tras el aviso el tramo se convierte en lava")
	await frames(2)
	var burned := victims.all(func(p: Participant) -> bool: return not p.alive and p.elimination_cause == &"lava")
	check(victims.size() > 0 and burned, "quien estaba encima es eliminado por la lava (%d)" % victims.size())
	check(await wait_until(func() -> bool: return seg.stage == LavaFloorSegment.Stage.SAFE, 60), "la lava del suelo se enfría después")
	await cleanup(TestWorld.holder_of(m))


func _pool_rise() -> void:
	var phase := PhaseDefinition.new()
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
	check(m.participants[1].alive and m.participants[2].alive, "quienes están a salvo en alto siguen vivos")
	await cleanup(TestWorld.holder_of(m))


func _same_seed_same_hazards() -> void:
	var runs := []
	for r in 2:
		var phase := PhaseDefinition.new()
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
	check(runs[0].size() > 3 and runs[0] == runs[1], "misma semilla → mismos peligros (%s)" % str(runs[0]))
