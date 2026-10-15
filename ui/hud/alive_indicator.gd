class_name AliveIndicator
extends Control
## "VIVOS n/N" con una capucha de color por participante (tachada si está eliminado).

var participants: Array[Participant] = []


func _init() -> void:
	custom_minimum_size = Vector2(300, 44)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var alive := 0
	for p in participants:
		if p.alive:
			alive += 1
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.45))
	var font := get_theme_default_font()
	draw_string(font, Vector2(12, 30), "VIVOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, Vector2(76, 30), "%d/%d" % [alive, participants.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffd23f"))
	var x := 130.0
	for p in participants:
		var c := p.color if p.alive else Color(p.color, 0.25)
		draw_colored_polygon(PackedVector2Array([Vector2(x, 34), Vector2(x + 13, 10), Vector2(x + 26, 34)]), c)
		draw_rect(Rect2(Vector2(x + 7, 22), Vector2(12, 7)), Color(0.98, 0.85, 0.72, 1.0 if p.alive else 0.25))
		if not p.alive:
			draw_line(Vector2(x, 10), Vector2(x + 26, 34), Color(1, 1, 1, 0.8), 2.0)
		x += 28.0
