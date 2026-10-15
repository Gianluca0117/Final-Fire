extends SceneTree
## Ejecuta todas las pruebas automáticas sin ventana:
##   Godot_v4.7.2-stable_win64_console.exe --headless --fixed-fps 60 --path . -s res://tests/run_tests.gd
## --fixed-fps hace que la simulación avance tan rápido como permita el equipo.
## Tras "--" se pueden indicar suites concretas: -- Personaje Arena
## Devuelve código 0 si todo pasa.

const SUITES := {
	"Entradas": "res://tests/test_input.gd",
	"Personaje": "res://tests/test_fighter.gd",
	"Arena": "res://tests/test_arena.gd",
	"Partida": "res://tests/test_match.gd",
	"Herramientas": "res://tests/test_tools.gd",
	"Completas": "res://tests/test_full_match.gd",
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var passed := 0
	var failed := 0
	var failures := PackedStringArray()
	var only := OS.get_cmdline_user_args()
	var t0 := Time.get_ticks_msec()
	for title in SUITES:
		if not only.is_empty() and not only.has(title):
			continue
		print("\n== %s" % title)
		var suite: TestSuite = load(SUITES[title]).new()
		suite.tree = self
		suite.title = title
		await suite.run()
		passed += suite.passed
		failed += suite.failed
		failures.append_array(suite.failures)
	print("\nPRUEBAS: %d aprobadas, %d fallidas (%.1f s reales)" % [passed, failed, (Time.get_ticks_msec() - t0) / 1000.0])
	for f in failures:
		print("  FALLO: " + f)
	quit(1 if failed > 0 else 0)
