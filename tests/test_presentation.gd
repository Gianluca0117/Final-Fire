extends TestSuite
## Presentación (estilo v1): el arte está separado de la simulación.
## - Con o sin vistas, la misma partida da exactamente el mismo resultado.
## - Las colisiones no cambian al añadir el arte.
## - Los efectos son breves, semitransparentes y quedan por debajo de los avisos.
## - Las seis variantes se distinguen por color y por detalle; todas las poses se calculan.

const FRAMES := 420


func run() -> void:
	var plain := await _run_match(false)
	var drawn := await _run_match(true)
	check(plain.views == 0 and drawn.views > 0, "la partida de control no tiene vistas y la otra sí (%d vistas)" % drawn.views)
	check(plain.positions == drawn.positions, "con y sin gráficos, la simulación da las mismas posiciones tras %d ticks" % FRAMES)
	check(plain.alive == drawn.alive and plain.elapsed == drawn.elapsed, "y los mismos supervivientes (%s)" % str(plain.alive))
	check(drawn.collisions_ok, "las colisiones (personajes, plataformas, bloques y suelo) no cambian con el arte")

	check(VfxLayer.Z < 9, "los efectos (z %d) se dibujan por debajo de la capa de avisos (z 9)" % VfxLayer.Z)
	check(VfxLayer.MAX_ALPHA <= 0.6 and VfxLayer.MAX_RADIUS <= 44.0, "los efectos son semitransparentes (≤ 0,6) y pequeños (≤ 44 px)")
	var overlays_ok := true
	for o in [PlatformOverlay.new(), SegmentOverlay.new()]:
		o._ready()
		overlays_ok = overlays_ok and o.z_index == 9 and not o.z_as_relative
		o.free()
	check(overlays_ok, "los avisos de plataformas y suelo van en la capa de avisos (z 9 absoluto)")

	var rules: MatchRules = load("res://data/rules/local_match.tres")
	var accessories := {}
	var colors := {}
	for i in 6:
		var l := CharacterLook.for_index(i, rules.colors[i])
		accessories[l.accessory] = true
		colors[l.main.to_html()] = true
	check(accessories.size() == 6 and colors.size() == 6, "seis variantes con color y detalle de silueta distintos")

	# Todas las poses se calculan sin errores para cada estado
	var f := Fighter.new()
	f.stats = rules.character_stats
	f.color = rules.colors[0]
	tree.root.add_child(f)
	var v := FighterView.new()
	f.add_child(v)
	var ok := true
	var used := {}
	for st in Fighter.State.values():
		f.state = st
		f.velocity = Vector2(300, 0)
		var idx := v.frame_index()
		ok = ok and idx >= 0 and idx < CharacterAnimations.FRAME_COUNT
		used[idx] = true
	check(ok, "cada uno de los %d estados del personaje tiene un fotograma válido" % Fighter.State.size())
	var needed := ["takeoff", "apex", "land", "skid", "push_recover", "hit", "look"]
	check(needed.all(func(k: String) -> bool: return CharacterAnimations.CLIPS.has(k)), "hay fotogramas de impulso, ápice, aterrizaje, derrape, recuperación del empujón e impacto")
	check(CharacterAnimations.frames().size() == CharacterAnimations.FRAME_COUNT, "la hoja define %d fotogramas" % CharacterAnimations.FRAME_COUNT)
	f.queue_free()
	await frames(1)


func _run_match(views: bool) -> Dictionary:
	var m: Node = load("res://scenes/match.tscn").instantiate()
	m.force_views = views
	tree.root.add_child(m)
	m.configure(0, 4, 777)
	var ctl: MatchController = m.match_ctl
	var shapes_before := _shapes(ctl)
	await frames(FRAMES)
	var res := {
		"positions": ctl.get_fighters().map(func(f: Fighter) -> Vector2: return f.global_position.snapped(Vector2(0.001, 0.001))),
		"alive": ctl.participants.map(func(p: Participant) -> bool: return p.alive),
		"elapsed": snappedf(ctl.elapsed, 0.0001),
		"views": _count_views(m),
		"collisions_ok": shapes_before == _shapes(ctl),
	}
	m.queue_free()
	await frames(2)
	return res


func _shapes(ctl: MatchController) -> Array:
	var out := []
	for f in ctl.get_fighters():
		out.append(["f", (f.get_node("Collision").shape as RectangleShape2D).size])
	for p in ctl.arena.platforms:
		out.append(["p", (p._col.shape as RectangleShape2D).size])
	for b in ctl.arena.blocks:
		for c in b.get_children():
			if c is CollisionShape2D:
				out.append(["b", (c.shape as RectangleShape2D).size])
	for s in ctl.arena.segments:
		for c in s.get_children():
			if c is CollisionShape2D:
				out.append(["s", (c.shape as RectangleShape2D).size])
	return out


func _count_views(n: Node) -> int:
	var count := 0
	for c in n.get_children():
		if c is FighterView or c is PlatformView or c is SegmentView or c is BlockView or c is LavaPoolView or c is VfxLayer or c is ToolsView or c is BackgroundView:
			count += 1
		count += _count_views(c)
	return count
