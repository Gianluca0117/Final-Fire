extends SceneTree
## Mide el rendimiento real de partidas renderizadas (necesita GPU, sin --headless):
##   Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -s res://tools/bench_render.gd -- 20 6
## Argumentos: segundos a medir y número de maniquíes. Si quedan menos de 4 en pie se
## empieza otra partida (los fotogramas del cambio no cuentan), para que la carga sea parecida.
## Muestra FPS medio, FPS del 1 % peor, milisegundos por fotograma y llamadas de dibujo.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var seconds := float(args[0]) if args.size() > 0 else 20.0
	var count := int(args[1]) if args.size() > 1 else 6
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var match_seed := 1000
	var m := _new_match(count, match_seed)
	var frame_ms: Array[float] = []
	var draw_calls: Array[float] = []
	var cpu_ms: Array[float] = []
	var skip := 30
	var t0 := Time.get_ticks_usec()
	var last := t0
	while (Time.get_ticks_usec() - t0) / 1e6 < seconds:
		await process_frame
		var now := Time.get_ticks_usec()
		if skip > 0:
			skip -= 1
		else:
			frame_ms.append((now - last) / 1000.0)
			draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			cpu_ms.append((Performance.get_monitor(Performance.TIME_PROCESS) + Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0)
		last = now
		var ctl: MatchController = m.match_ctl
		if ctl.alive_participants().size() < 4 or ctl.phase == MatchController.Phase.FINISHED:
			m.queue_free()
			match_seed += 1
			m = _new_match(count, match_seed)
			skip = 10
	frame_ms.sort()
	var avg := 0.0
	for f in frame_ms:
		avg += f
	avg /= frame_ms.size()
	var p99: float = frame_ms[int(frame_ms.size() * 0.99) - 1]
	var dc := 0.0
	for d in draw_calls:
		dc += d
	dc /= draw_calls.size()
	var cpu := 0.0
	for c in cpu_ms:
		cpu += c
	cpu /= cpu_ms.size()
	print("BENCH frames=%d  fps_medio=%.0f  fps_1%%peor=%.0f  ms_medio=%.2f  ms_p99=%.2f  draw_calls=%.0f  cpu_scripts_ms=%.2f  partidas=%d  adaptador=%s" % [
		frame_ms.size(), 1000.0 / avg, 1000.0 / p99, avg, p99, dc, cpu, match_seed - 999, RenderingServer.get_video_adapter_name()])
	quit()


func _new_match(count: int, match_seed: int) -> Node:
	var m: Node = load("res://scenes/match.tscn").instantiate()
	root.add_child(m)
	m.configure(0, count, match_seed)
	m.hud.set_touch_visible(true)
	var opts := OS.get_cmdline_user_args()
	if opts.has("nobg"):
		for c in m.get_children():
			if c is BackgroundView:
				c.visible = false
	if opts.has("nohud"):
		m.hud.visible = false
		for c in m.hud.get_children():
			if c is CanvasItem:
				c.visible = false
	if opts.has("nolava"):
		m.arena.lava_pool.visible = false
	if opts.has("nofighters"):
		for f in m.match_ctl.get_fighters():
			f.visible = false
	if opts.has("noarena"):
		for p in m.arena.platforms:
			p.visible = false
		for sg in m.arena.segments:
			sg.visible = false
		for b in m.arena.blocks:
			b.visible = false
	if opts.has("novfx"):
		for c in m.get_children():
			if c is VfxLayer or c is ToolsView:
				c.visible = false
	return m
