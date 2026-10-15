extends SceneTree
## Microprueba del coste de dibujar el rig del personaje (necesita GPU):
##   Godot ... --path . --resolution 1280x720 -s res://tools/bench_rig.gd
## Mide, para 6 personajes redibujados cada fotograma, el tiempo de grabar los comandos
## de dibujo (CPU) y el tiempo total por fotograma, con y sin antialiasing.


class RigBench extends Node2D:
	var looks: Array[CharacterLook] = []
	var pose := RigPose.new()
	var record_us := 0.0
	var frames := 0
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var t0 := Time.get_ticks_usec()
		for i in 6:
			draw_set_transform(Vector2(120 + i * 200, 360), 0.0, Vector2(1.5, 1.5))
			pose.bob = sin(t * 3.0 + i)
			CharacterRig.draw(self, pose, looks[i], t)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		record_us += Time.get_ticks_usec() - t0
		frames += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var rules: MatchRules = load("res://data/rules/local_match.tres")
	for aa in [true, false]:
		DrawKit.antialias = aa
		var b := RigBench.new()
		for i in 6:
			b.looks.append(CharacterLook.for_index(i, rules.colors[i]))
		root.add_child(b)
		for i in 20:
			await process_frame
		b.frames = 0
		b.record_us = 0.0
		var t0 := Time.get_ticks_usec()
		var n := 0
		while Time.get_ticks_usec() - t0 < 4_000_000:
			await process_frame
			n += 1
		var total_ms := (Time.get_ticks_usec() - t0) / 1000.0 / n
		print("RIG antialias=%s  ms_por_fotograma=%.2f  ms_grabando_comandos=%.2f  draw_calls=%d" % [aa, total_ms, b.record_us / 1000.0 / maxi(b.frames, 1), Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)])
		b.queue_free()
		await process_frame
	quit()
