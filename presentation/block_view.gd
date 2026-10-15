class_name BlockView
extends Node2D
## Bloque de piedra seguro (estilo v1): sillares fríos con borde claro arriba y contorno
## oscuro. Se dibuja una sola vez (no se anima): coste casi nulo por fotograma.

func _draw() -> void:
	var b := get_parent() as SolidBlock
	var r := Rect2(-b.size * 0.5, b.size)
	DrawKit.poly(self, DrawKit.rounded_rect(r, 6.0, 3), ViewPalette.STONE)
	# Borde superior iluminado: indica «aquí se puede pisar».
	draw_colored_polygon(DrawKit.rounded_rect(Rect2(r.position + Vector2(2, 2), Vector2(r.size.x - 4, 7)), 3.0, 2), ViewPalette.STONE_TOP)
	draw_rect(Rect2(r.position + Vector2(3, r.size.y - 6), Vector2(r.size.x - 6, 3)), ViewPalette.STONE_DARK)
	# Juntas de sillería en dos hileras alternas
	var row_h := maxf((r.size.y - 9.0) / 2.0, 6.0)
	for row in 2:
		var y0 := r.position.y + 9.0 + row * row_h
		if y0 + 2.0 >= r.end.y - 4.0:
			break
		var x := r.position.x + (14.0 if row == 0 else 34.0)
		while x < r.end.x - 8.0:
			draw_line(Vector2(x, y0 + 1.0), Vector2(x, minf(y0 + row_h - 1.0, r.end.y - 5.0)), ViewPalette.STONE_SEAM, 2.0)
			x += 40.0
		if row == 0 and r.size.y > 24.0:
			draw_line(Vector2(r.position.x + 4, y0 + row_h), Vector2(r.end.x - 4, y0 + row_h), ViewPalette.STONE_SEAM, 1.5)
