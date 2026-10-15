extends SceneTree
## Captura vistas previas reales con el renderizador activo (necesita GPU, sin --headless):
##   Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -s res://tools/capture_preview.gd -- menu docs/previews/menu.png
##   Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -s res://tools/capture_preview.gd -- match docs/previews/partida.png 7.0 11 touch
## Argumentos: modo (menu | match), salida, segundos de partida, semilla, "touch" para mostrar
## los controles táctiles. En modo match juegan 4 maniquíes (sin humanos) para que la
## imagen sea reproducible.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode := args[0] if args.size() > 0 else "match"
	var out_path := args[1] if args.size() > 1 else "docs/previews/partida.png"
	var seconds := float(args[2]) if args.size() > 2 else 7.0
	var rng_seed := int(args[3]) if args.size() > 3 else 11
	var show_touch := args.has("touch")

	if mode == "menu":
		root.add_child(load("res://scenes/main.tscn").instantiate())
		for i in 10:
			await process_frame
	else:
		var m: Node = load("res://scenes/match.tscn").instantiate()
		root.add_child(m)
		m.configure(0, 4, rng_seed)
		m.hud.set_touch_visible(show_touch)
		var ctl: MatchController = m.match_ctl
		while ctl.elapsed < seconds and ctl.phase != MatchController.Phase.FINISHED:
			await physics_frame
		for i in 2:
			await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var abs_out := ProjectSettings.globalize_path("res://" + out_path)
	DirAccess.make_dir_recursive_absolute(abs_out.get_base_dir())
	var err := img.save_png(abs_out)
	print("renderer=%s size=%s -> %s (%s)" % [RenderingServer.get_current_rendering_method(), img.get_size(), out_path, error_string(err)])
	quit(0 if err == OK else 1)
