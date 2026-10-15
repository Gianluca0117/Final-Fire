class_name DrawKit
## Utilidades de dibujo del estilo cartoon de Final Fire: formas redondeadas con contorno
## oscuro grueso (siluetas claras en pantallas pequeñas). Todo es vectorial y barato.

const OUTLINE := Color("1b0f14")

## Antialiasing de contornos (suaviza bordes; cuesta CPU). Ajustable para medir.
static var antialias := true


static func rounded_rect(r: Rect2, radius: float, seg := 4) -> PackedVector2Array:
	var pts := PackedVector2Array()
	# Un poco menos de la mitad: si el radio es exactamente la mitad se repiten puntos y el
	# polígono no se puede triangular.
	var rad := maxf(minf(radius, minf(r.size.x, r.size.y) * 0.5 - 0.1), 0.0)
	var corners := [
		[r.position + Vector2(r.size.x - rad, rad), -PI / 2],
		[r.end - Vector2(rad, rad), 0.0],
		[r.position + Vector2(rad, r.size.y - rad), PI / 2],
		[r.position + Vector2(rad, rad), PI],
	]
	for c in corners:
		for i in seg + 1:
			var a: float = c[1] + (PI / 2) * float(i) / seg
			pts.append(c[0] + Vector2(cos(a), sin(a)) * rad)
	return pts


static func ellipse(c: Vector2, rx: float, ry: float, seg := 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in seg:
		var a := TAU * i / seg
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Polígono relleno con contorno (el contorno se dibuja cerrado).
static func poly(ci: CanvasItem, pts: PackedVector2Array, fill: Color, outline := OUTLINE, width := 3.0) -> void:
	ci.draw_colored_polygon(pts, fill)
	if width > 0.0 and outline.a > 0.0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		ci.draw_polyline(closed, outline, width, antialias)


## Extremidad tipo cápsula con contorno: primero el contorno grueso y encima el color.
static func capsule(ci: CanvasItem, a: Vector2, b: Vector2, width: float, fill: Color, outline := OUTLINE, ow := 2.5) -> void:
	ci.draw_line(a, b, outline, width + ow * 2.0)
	ci.draw_circle(a, width * 0.5 + ow, outline)
	ci.draw_circle(b, width * 0.5 + ow, outline)
	ci.draw_line(a, b, fill, width)
	ci.draw_circle(a, width * 0.5, fill)
	ci.draw_circle(b, width * 0.5, fill)


static func circle(ci: CanvasItem, c: Vector2, r: float, fill: Color, outline := OUTLINE, width := 2.5) -> void:
	ci.draw_circle(c, r + width, outline)
	ci.draw_circle(c, r, fill)


static func star_points(c: Vector2, r_out: float, r_in: float, n := 5, rot := 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n * 2:
		var r := r_out if i % 2 == 0 else r_in
		var a := rot - PI / 2 + PI * i / n
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts


## Texto con contorno (legible sobre lava o fondos claros).
static func text(ci: CanvasItem, pos: Vector2, s: String, size: int, col: Color, width := -1.0, align := HORIZONTAL_ALIGNMENT_CENTER, outline := 5) -> void:
	var font := UiFonts.display()
	ci.draw_string_outline(font, pos, s, align, width, size, outline, OUTLINE)
	ci.draw_string(font, pos, s, align, width, size, col)
