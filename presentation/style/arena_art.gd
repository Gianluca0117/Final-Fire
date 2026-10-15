class_name ArenaArt
## Dibujo ilustrado de las piezas de la arena (estilo v2): volumen (cara superior iluminada,
## cara frontal, panza en sombra y luz cálida de la lava por debajo), textura (sillares
## irregulares, vetas de madera, herrajes) y deterioro por estados. Todo en coordenadas
## locales centradas en la pieza; se hornea con ArtCache.

const MORTAR := Color("2a2c37")
const STONE_TONES := [Color("5d6273"), Color("565b6b"), Color("646a7b"), Color("525767")]
const TOP_LIGHT := Color("b3bbcf")
const TOP := Color("8f97ab")
const RIM := Color(1.0, 0.45, 0.15, 0.45)
const WOOD_TONES := [Color("a8673a"), Color("9b5e33"), Color("b3743f")]
const WOOD_DARK := Color("5c3218")
const WOOD_DEEP := Color("3d200f")
const IRON := Color("6d717d")
const IRON_LIGHT := Color("a3a8b5")
const CHAR := Color("2a1610")


## Margen alrededor de la pieza que incluye contorno, goterones y herrajes.
static func bounds(size: Vector2) -> Rect2:
	return Rect2(-size * 0.5 - Vector2(6, 6), size + Vector2(12, 22))


static func _rng(seed_text: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = hash(seed_text)
	return r


# ---------------------------------------------------------------- piedra

## Bloque de roca volcánica seguro (repisas, salientes).
static func stone_block(ci: CanvasItem, size: Vector2, seed_text: String) -> void:
	var rng := _rng(seed_text)
	var r := Rect2(-size * 0.5, size)
	_drips(ci, r, rng, 3)
	var body := _rock_outline(r, rng, 3.0)
	ci.draw_colored_polygon(body, MORTAR)
	_stones(ci, Rect2(r.position + Vector2(4, 8), r.size - Vector2(8, 11)), rng, 2)
	_top_band(ci, r, rng)
	ci.draw_line(Vector2(r.position.x + 6, r.end.y - 1.5), Vector2(r.end.x - 6, r.end.y - 1.5), RIM, 2.0)
	_outline(ci, body, 3.0)


## Losa de piedra con herrajes de hierro en los extremos (plataformas basculantes).
## damage: 0 sana, 1 agrietada, 2 crítica.
static func stone_slab(ci: CanvasItem, size: Vector2, damage: int, seed_text: String) -> void:
	var rng := _rng(seed_text)
	var r := Rect2(-size * 0.5, size)
	_drips(ci, r, rng, 2)
	var body := _rock_outline(r, rng, 1.5)
	ci.draw_colored_polygon(body, MORTAR)
	_stones(ci, Rect2(r.position + Vector2(16, 7), r.size - Vector2(32, 9)), rng, 1)
	_top_band(ci, r, rng)
	_cracks(ci, Rect2(r.position + Vector2(16, 0), r.size - Vector2(32, 0)), damage, rng)
	ci.draw_line(Vector2(r.position.x + 6, r.end.y - 1.5), Vector2(r.end.x - 6, r.end.y - 1.5), RIM, 2.0)
	_outline(ci, body, 3.0)
	for sx in [-1.0, 1.0]:
		var x0: float = r.position.x + 2.0 if sx < 0.0 else r.end.x - 16.0
		var band := DrawKit.rounded_rect(Rect2(x0, r.position.y - 2.0, 14.0, r.size.y + 4.0), 3.0, 2)
		DrawKit.poly(ci, band, IRON, DrawKit.OUTLINE, 2.5)
		ci.draw_line(Vector2(x0 + 3, r.position.y), Vector2(x0 + 11, r.position.y), IRON_LIGHT, 2.0)
		for ry in [r.position.y + 5.0, r.end.y - 5.0]:
			ci.draw_circle(Vector2(x0 + 7.0, ry), 2.0, DrawKit.OUTLINE)
			ci.draw_circle(Vector2(x0 + 6.5, ry - 0.5), 1.1, IRON_LIGHT)


## Tramo de suelo con rejilla volcánica (por ella sale la lava). Estado seguro.
static func floor_tile(ci: CanvasItem, size: Vector2, seed_text: String) -> void:
	var rng := _rng(seed_text)
	var r := Rect2(-size * 0.5, size)
	ci.draw_rect(r, MORTAR)
	_stones(ci, Rect2(r.position + Vector2(2, 8), r.size - Vector2(4, 9)), rng, 2)
	_top_band(ci, r, rng)
	var g := grate_rect(size)
	DrawKit.poly(ci, DrawKit.rounded_rect(g.grow(3.0), 4.0, 2), IRON, DrawKit.OUTLINE, 2.5)
	ci.draw_rect(g, Color("140b0d"))
	for slot in grate_slots(size):
		ci.draw_line(Vector2(slot.position.x - 1.5, g.position.y), Vector2(slot.position.x - 1.5, g.end.y), IRON_LIGHT, 2.0)
	ci.draw_line(Vector2(g.end.x + 1.5, g.position.y), Vector2(g.end.x + 1.5, g.end.y), IRON_LIGHT, 2.0)
	_outline(ci, PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), 2.5)


static func grate_rect(size: Vector2) -> Rect2:
	return Rect2(Vector2(-size.x * 0.32, -size.y * 0.5 + 13.0), Vector2(size.x * 0.64, 9.0))


## Huecos de la rejilla (donde se ve el resplandor durante el aviso).
static func grate_slots(size: Vector2) -> Array[Rect2]:
	var g := grate_rect(size)
	var out: Array[Rect2] = []
	var n := 6
	var w := g.size.x / n
	for i in n:
		out.append(Rect2(g.position + Vector2(i * w + 2.0, 1.0), Vector2(w - 4.0, g.size.y - 2.0)))
	return out


# ---------------------------------------------------------------- madera

## Puente de madera frágil: dos tablones largos, travesaños con clavos y ataduras de cuerda.
## damage: 0 sano, 1 agrietado (grietas, tablón combado), 2 crítico (trozo que falta, quemado).
static func wood_bridge(ci: CanvasItem, size: Vector2, damage: int, seed_text: String) -> void:
	var rng := _rng(seed_text)
	var r := Rect2(-size * 0.5, size)
	var top_h := size.y * 0.58
	var upper := Rect2(r.position, Vector2(r.size.x, top_h))
	var lower := Rect2(r.position + Vector2(6, top_h - 1.0), Vector2(r.size.x - 12, r.size.y - top_h + 1.0))
	# Tablón inferior (más oscuro, en sombra)
	var low_pts := _board(lower, rng, damage >= 2, true)
	DrawKit.poly(ci, low_pts, WOOD_DARK, DrawKit.OUTLINE, 3.0)
	# Tablón superior, troceado en 3 piezas con tonos distintos
	var pieces := 3
	var pw := upper.size.x / pieces
	for i in pieces:
		var pr := Rect2(upper.position + Vector2(i * pw, 0), Vector2(pw + (0.0 if i == pieces - 1 else 1.0), upper.size.y))
		var sag := 2.5 if damage >= 1 and i == 1 else 0.0
		pr.position.y += sag
		var missing := damage >= 2 and i == 2
		var pts := _board(pr, rng, missing, false)
		var tone: Color = WOOD_TONES[i % WOOD_TONES.size()]
		ci.draw_colored_polygon(pts, tone)
		# Vetas
		for k in 2:
			var gy := pr.position.y + 4.0 + k * 4.0
			var gpts := PackedVector2Array()
			var x := pr.position.x + 4.0
			while x < pr.end.x - 4.0:
				gpts.append(Vector2(x, gy + sin(x * 0.15 + i + k) * 0.8))
				x += 6.0
			if gpts.size() > 1:
				ci.draw_polyline(gpts, tone.darkened(0.25), 1.2)
		ci.draw_line(pr.position + Vector2(3, 1.5), Vector2(pr.end.x - 3, pr.position.y + 1.5), tone.lightened(0.25), 2.0)
		if damage >= 2:
			# Bordes quemados
			ci.draw_rect(Rect2(pr.end.x - 10.0, pr.position.y + 1.0, 9.0, pr.size.y - 2.0), Color(CHAR, 0.55))
		_outline(ci, pts, 3.0)
	# Travesaños con clavos
	var x0 := r.position.x + 18.0
	while x0 < r.end.x - 12.0:
		DrawKit.poly(ci, DrawKit.rounded_rect(Rect2(x0 - 4.0, r.position.y + 1.0, 8.0, r.size.y - 1.0), 2.0, 2), WOOD_DEEP, DrawKit.OUTLINE, 2.0)
		ci.draw_circle(Vector2(x0, r.position.y + 5.0), 1.5, IRON_LIGHT)
		ci.draw_circle(Vector2(x0, r.end.y - 5.0), 1.5, IRON_LIGHT)
		x0 += 52.0
	# Ataduras de cuerda en los extremos
	for ex in [r.position.x + 8.0, r.end.x - 8.0]:
		DrawKit.poly(ci, DrawKit.rounded_rect(Rect2(ex - 5.0, r.position.y - 2.0, 10.0, r.size.y + 4.0), 3.0, 2), Color("c9a46a"), DrawKit.OUTLINE, 2.0)
		for k in 3:
			ci.draw_line(Vector2(ex - 4.0, r.position.y + 2.0 + k * 7.0), Vector2(ex + 4.0, r.position.y + 6.0 + k * 7.0), Color("8a6a3c"), 1.5)
	_cracks(ci, Rect2(r.position + Vector2(14, 0), r.size - Vector2(28, 0)), damage, rng)
	if damage >= 2:
		# Astillas sueltas bajo el hueco
		for k in 3:
			var sx := r.end.x - 40.0 + k * 9.0
			ci.draw_line(Vector2(sx, r.end.y), Vector2(sx + 3.0, r.end.y + 7.0 + k * 2.0), WOOD_DARK, 2.5)


## Contorno de un tablón con extremos irregulares; `broken` le quita un trozo a la derecha.
static func _board(r: Rect2, rng: RandomNumberGenerator, broken: bool, lower: bool) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.append(r.position + Vector2(1.5, rng.randf_range(0.0, 1.0)))
	pts.append(Vector2(r.end.x - 1.5, r.position.y + rng.randf_range(0.0, 1.0)))
	if broken:
		pts.append(Vector2(r.end.x - 1.5, r.position.y + r.size.y * 0.3))
		pts.append(Vector2(r.end.x - r.size.x * 0.22, r.position.y + r.size.y * 0.45))
		pts.append(Vector2(r.end.x - r.size.x * 0.32, r.end.y - 1.0))
	else:
		pts.append(Vector2(r.end.x, r.position.y + r.size.y * 0.5))
		pts.append(Vector2(r.end.x - 1.5, r.end.y - 0.5))
	pts.append(Vector2(r.position.x + 1.5, r.end.y - (0.5 if lower else 0.0)))
	pts.append(Vector2(r.position.x, r.position.y + r.size.y * 0.5))
	return pts


# ---------------------------------------------------------------- comunes

static func _rock_outline(r: Rect2, rng: RandomNumberGenerator, taper: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := maxi(int(r.size.x / 14.0), 3)
	for i in n + 1:
		var x := lerpf(r.position.x + 3.0, r.end.x - 3.0, float(i) / n)
		pts.append(Vector2(x, r.position.y + rng.randf_range(-1.2, 1.2)))
	pts.append(Vector2(r.end.x, r.position.y + 6.0))
	pts.append(Vector2(r.end.x - taper, r.end.y - 3.0))
	pts.append(Vector2(r.end.x - taper - 4.0, r.end.y))
	pts.append(Vector2(r.position.x + taper + 4.0, r.end.y))
	pts.append(Vector2(r.position.x + taper, r.end.y - 3.0))
	pts.append(Vector2(r.position.x, r.position.y + 6.0))
	return pts


static func _stones(ci: CanvasItem, area: Rect2, rng: RandomNumberGenerator, rows: int) -> void:
	if area.size.y < 4.0:
		return
	var rh := area.size.y / rows
	for row in rows:
		var x := area.position.x + (0.0 if row % 2 == 0 else -10.0)
		while x < area.end.x:
			var w := rng.randf_range(20.0, 36.0)
			var sx := maxf(x, area.position.x)
			var ex := minf(x + w, area.end.x)
			if ex - sx > 10.0:
				var sr := Rect2(sx + 1.2, area.position.y + row * rh + 1.2, ex - sx - 2.4, rh - 2.4)
				var tone: Color = STONE_TONES[rng.randi_range(0, STONE_TONES.size() - 1)]
				ci.draw_colored_polygon(DrawKit.rounded_rect(sr, minf(4.0, sr.size.y * 0.4), 2), tone)
				ci.draw_line(sr.position + Vector2(2, 0.8), Vector2(sr.end.x - 2, sr.position.y + 0.8), tone.lightened(0.18), 1.4)
				ci.draw_line(Vector2(sr.position.x + 2, sr.end.y - 0.6), Vector2(sr.end.x - 2, sr.end.y - 0.6), tone.darkened(0.3), 1.4)
			x += w


static func _top_band(ci: CanvasItem, r: Rect2, rng: RandomNumberGenerator) -> void:
	var band := PackedVector2Array([r.position + Vector2(2, 0), Vector2(r.end.x - 2, r.position.y), Vector2(r.end.x - 3, r.position.y + 7), Vector2(r.position.x + 3, r.position.y + 7)])
	ci.draw_colored_polygon(band, TOP)
	ci.draw_line(r.position + Vector2(4, 1.8), Vector2(r.end.x - 4, r.position.y + 1.8), TOP_LIGHT, 2.0)
	ci.draw_line(Vector2(r.position.x + 3, r.position.y + 7.5), Vector2(r.end.x - 3, r.position.y + 7.5), MORTAR, 1.5)
	# Guijarros sobre la superficie
	for i in maxi(int(r.size.x / 50.0), 1):
		var px := rng.randf_range(r.position.x + 10.0, r.end.x - 10.0)
		ci.draw_circle(Vector2(px, r.position.y + 4.0), rng.randf_range(1.0, 1.8), TOP.darkened(0.2))


static func _drips(ci: CanvasItem, r: Rect2, rng: RandomNumberGenerator, n: int) -> void:
	for i in n:
		var x := rng.randf_range(r.position.x + 14.0, r.end.x - 14.0)
		var l := rng.randf_range(6.0, 12.0)
		var tri := PackedVector2Array([Vector2(x - 5, r.end.y - 2), Vector2(x + 5, r.end.y - 2), Vector2(x + 0.5, r.end.y + l)])
		DrawKit.poly(ci, tri, MORTAR.lightened(0.05), DrawKit.OUTLINE, 2.0)


static func _cracks(ci: CanvasItem, area: Rect2, damage: int, rng: RandomNumberGenerator) -> void:
	var n := 0 if damage <= 0 else (2 if damage == 1 else 4)
	for i in n:
		var x := lerpf(area.position.x, area.end.x, (i + 0.5) / n) + rng.randf_range(-6.0, 6.0)
		var pts := PackedVector2Array([Vector2(x, area.position.y + 1.0)])
		var y := area.position.y + 1.0
		while y < area.end.y - 2.0:
			y += rng.randf_range(4.0, 7.0)
			x += rng.randf_range(-4.0, 4.0)
			pts.append(Vector2(x, minf(y, area.end.y - 1.0)))
		ci.draw_polyline(pts, DrawKit.OUTLINE, 2.6)
		ci.draw_polyline(pts, Color(1, 1, 1, 0.12), 0.8)


static func _outline(ci: CanvasItem, pts: PackedVector2Array, width: float) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	ci.draw_polyline(closed, DrawKit.OUTLINE, width, true)
