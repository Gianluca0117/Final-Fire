extends SceneTree
## Une dos capturas del MISMO tamaño en una imagen comparativa (lado a lado, con franja de título).
## Uso: godot --headless -s res://tools/compose_comparison.gd -- antes.png despues.png salida.png
## No escala ninguna de las dos: ambas se copian píxel a píxel para comparar a igual tamaño.

const BAR := 36


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() < 3:
		push_error("uso: -- antes.png despues.png salida.png")
		quit(1)
		return
	var before := Image.load_from_file(a[0])
	var after := Image.load_from_file(a[1])
	if before == null or after == null or before.get_size() != after.get_size():
		push_error("las dos capturas deben existir y tener el mismo tamaño")
		quit(1)
		return
	before.convert(Image.FORMAT_RGBA8)
	after.convert(Image.FORMAT_RGBA8)
	var s := before.get_size()
	var out := Image.create(s.x * 2 + 8, s.y + BAR, false, Image.FORMAT_RGBA8)
	out.fill(Color("140a10"))
	# Franjas de título: gris para «antes», naranja para «después» (sin texto: fuente no disponible en Image)
	out.fill_rect(Rect2i(0, 0, s.x, BAR - 6), Color("5a5560"))
	out.fill_rect(Rect2i(s.x + 8, 0, s.x, BAR - 6), Color("ff8c26"))
	out.blit_rect(before, Rect2i(Vector2i.ZERO, s), Vector2i(0, BAR))
	out.blit_rect(after, Rect2i(Vector2i.ZERO, s), Vector2i(s.x + 8, BAR))
	var err := out.save_png(a[2])
	print("%s (%dx%d cada lado) -> %s" % ["OK" if err == OK else "ERROR", s.x, s.y, a[2]])
	quit(0 if err == OK else 1)
