extends TestSuite
## Partidas completas con las escenas reales (menú → partida → resultados) y maniquíes.
## Comprueban que siempre hay un final (ganador o empate) y que nada se bloquea.

const SEEDS := [11, 22, 33]


func run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(main)
	await frames(2)
	check(main.get_node_or_null("MainMenu") != null, "el juego arranca en el menú")
	main._start(0, 4)
	await frames(2)
	check(main.get_node_or_null("MainMenu") == null and main._match != null, "desde el menú se inicia una partida")
	main._match.queue_free()
	main._match = null
	await frames(1)
	# Modo de 2 jugadores con el mismo teclado (para probar la disputa por la herramienta).
	main._start(2, 0)
	await frames(2)
	var duo: MatchController = main._match.match_ctl
	var humans := duo.participants.filter(func(p: Participant) -> bool: return p.kind == Participant.Kind.HUMAN_LOCAL)
	check(humans.size() == 2 and duo.participants.size() == 2, "modo 2 jugadores: J1 y J2 humanos en la misma partida")
	check(duo.tools.enabled(), "en la partida real la herramienta compartida está activa")
	main._match.queue_free()
	main._match = null
	await frames(1)

	for s in SEEDS:
		# Configuración con semilla fija para que la prueba sea reproducible.
		var match_node: Node = load("res://scenes/match.tscn").instantiate()
		main.add_child(match_node)
		var m: MatchController = match_node.match_ctl
		var announced := [0]
		m.tools.tool_announced.connect(func(_d: ToolDefinition, _p: Vector2, _s: float) -> void: announced[0] += 1)
		match_node.configure(0, 4, s)
		var ok := await wait_until(func() -> bool: return m.phase == MatchController.Phase.FINISHED, 60 * 180)
		var winner := m.winner.display_name if m.winner else "empate"
		check(ok, "semilla %d: la partida termina (%.1f s simulados, ganador: %s)" % [s, m.elapsed, winner])
		var fallen := m.participants.filter(func(p: Participant) -> bool: return not p.alive)
		var causes := PackedStringArray()
		for p in fallen:
			causes.append("%s %s a los %.1f s%s" % [p.display_name, p.elimination_cause, p.eliminated_at, (" por " + p.eliminated_by.display_name) if p.eliminated_by else ""])
		check(fallen.size() >= m.participants.size() - 1, "semilla %d: %d eliminados de %d (%s)" % [s, fallen.size(), m.participants.size(), "; ".join(causes)])
		var stuck := m.participants.filter(func(p: Participant) -> bool: return not p.alive and m.tools.holds(p))
		check(announced[0] >= 1 and stuck.is_empty(), "semilla %d: aparecieron %d herramientas y ningún eliminado conserva una" % [s, announced[0]])
		await frames(2)
		check(match_node.hud._results.visible, "semilla %d: se muestran los resultados" % s)
		match_node.queue_free()
		await frames(1)
	main.queue_free()
	await frames(1)
