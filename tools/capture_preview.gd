extends SceneTree
## Captura una vista previa real de una escena con el renderizador activo:
##   Godot_v4.7.2-stable_win64_console.exe --path . -s res://tools/capture_preview.gd -- res://scenes/test_level.tscn docs/previews/test_level.png
## (sin --headless: necesita GPU; sirve también para comprobar que Compatibility/OpenGL funciona)

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var scene_path := args[0] if args.size() > 0 else "res://scenes/test_level.tscn"
	var out_path := args[1] if args.size() > 1 else "docs/previews/test_level.png"
	root.add_child(load(scene_path).instantiate())
	for i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var abs_out := ProjectSettings.globalize_path("res://" + out_path)
	DirAccess.make_dir_recursive_absolute(abs_out.get_base_dir())
	var err := img.save_png(abs_out)
	print("renderer=%s adapter=%s size=%s -> %s (%s)" % [
		RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(),
		img.get_size(), out_path, error_string(err)])
	quit(0 if err == OK else 1)
