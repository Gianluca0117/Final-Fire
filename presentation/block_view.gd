class_name BlockView
extends Node2D
## Bloque de piedra sólido.

func _draw() -> void:
	var b := get_parent() as SolidBlock
	var r := Rect2(-b.size * 0.5, b.size)
	draw_rect(r, ViewPalette.STONE)
	draw_rect(Rect2(r.position, Vector2(r.size.x, 6)), ViewPalette.STONE_TOP)
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 5), Vector2(r.size.x, 5)), ViewPalette.STONE_DARK)
	var x := r.position.x + 30.0
	while x < r.end.x - 10.0:
		draw_line(Vector2(x, r.position.y + 8), Vector2(x, r.end.y - 6), ViewPalette.STONE_DARK, 2.0)
		x += 44.0
