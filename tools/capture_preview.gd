extends SceneTree
## Captura vistas previas reales con el renderizador activo (necesita GPU, sin --headless):
##   Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -s res://tools/capture_preview.gd -- menu docs/previews/menu.png
##   Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -s res://tools/capture_preview.gd -- match docs/previews/partida.png 7.0 11 touch
## Argumentos: modo (menu | match | gallery | sheets), salida, segundos de partida, semilla, "touch" para mostrar
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

	if mode == "sheets":
		# Exporta las hojas de sprites generadas (para revisar el arte fotograma a fotograma).
		var rules: MatchRules = load("res://data/rules/local_match.tres")
		var looks: Array[CharacterLook] = []
		for i in 6:
			looks.append(CharacterLook.for_index(i, rules.colors[i]))
			CharacterSprites.request(self, looks[i])
		while not looks.all(func(l: CharacterLook) -> bool: return CharacterSprites.is_ready(l)):
			await process_frame
		for i in 6:
			var path := ProjectSettings.globalize_path("res://%s_%d.png" % [out_path.get_basename(), i + 1])
			CharacterSprites.sheet(looks[i]).get_image().save_png(path)
			print("hoja -> ", path)
		quit()
		return
	if mode == "gallery":
		root.add_child(load("res://scenes/dev/style_gallery.tscn").instantiate())
		# Mínimo de fotogramas además del tiempo: al arrancar se compilan shaders y se generan
		# las hojas de sprites, y el primer segundo puede tener muy pocos fotogramas.
		var t0 := Time.get_ticks_msec()
		var n := 0
		while (Time.get_ticks_msec() - t0) / 1000.0 < seconds or n < 40:
			await process_frame
			n += 1
	elif mode == "menu":
		root.add_child(load("res://scenes/main.tscn").instantiate())
		for i in 40:
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
