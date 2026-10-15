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

	for s in SEEDS:
		# Configuración con semilla fija para que la prueba sea reproducible.
		var match_node: Node = load("res://scenes/match.tscn").instantiate()
		main.add_child(match_node)
		match_node.configure(0, 4, s)
		var m: MatchController = match_node.match_ctl
		var ok := await wait_until(func() -> bool: return m.phase == MatchController.Phase.FINISHED, 60 * 180)
		var winner := m.winner.display_name if m.winner else "empate"
		check(ok, "semilla %d: la partida termina (%.1f s simulados, ganador: %s)" % [s, m.elapsed, winner])
		var fallen := m.participants.filter(func(p: Participant) -> bool: return not p.alive)
		var causes := PackedStringArray()
		for p in fallen:
			causes.append("%s %s a los %.1f s%s" % [p.display_name, p.elimination_cause, p.eliminated_at, (" por " + p.eliminated_by.display_name) if p.eliminated_by else ""])
		check(fallen.size() >= m.participants.size() - 1, "semilla %d: %d eliminados de %d (%s)" % [s, fallen.size(), m.participants.size(), "; ".join(causes)])
		await frames(2)
		check(match_node.hud._results.visible, "semilla %d: se muestran los resultados" % s)
		match_node.queue_free()
		await frames(1)
	main.queue_free()
	await frames(1)
