class_name BackgroundView
extends Node2D
## Fondo de cueva volcánica (estilo v2) con profundidad por capas, pintado UNA sola vez en una
## textura (SubViewport con UPDATE_ONCE): cada fotograma cuesta un único rectángulo.
## Capas, de atrás adelante: cueva oscura → ruinas lejanas suavizadas por la calima (menos
## contraste) → banda de calima cálida → pilares y arcos intermedios con borde iluminado por la
## lava → marco de rocas en primer término (lo más oscuro). Todo sin contorno y más apagado
## que lo jugable. Animado aparte y barato: dos cascadas lejanas (shader) y brasas.

const BAKE := Rect2(-200, -160, 1680, 1040)
const LAVAFALL_SHADER := preload("res://presentation/shaders/lavafall.gdshader")

var arena: Arena
var _embers: EmberLayer

## Textura ya pintada (se reutiliza en las partidas siguientes: sin tirón al empezar).
static var _cached: Texture2D


func _ready() -> void:
	z_index = -20
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.position = BAKE.position
	add_child(sprite)
	if _cached:
		sprite.texture = _cached
	else:
		_bake(sprite)
	# Cascadas lejanas: estrechas y tenues (están «detrás» de la calima)
	for x in [372.0, 904.0]:
		var fall := ColorRect.new()
		fall.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fall.position = Vector2(x - 17.0, 96.0)
		fall.size = Vector2(34.0, 420.0)
		fall.material = ShaderMaterial.new()
		(fall.material as ShaderMaterial).shader = LAVAFALL_SHADER
		add_child(fall)
		move_child(fall, 0)
		move_child(sprite, 0)
	_embers = EmberLayer.new()
	add_child(_embers)


func _bake(sprite: Sprite2D) -> void:
	if PhysicsLayers.is_headless():
		return
	var vp := SubViewport.new()
	vp.size = Vector2i(BAKE.size)
	vp.transparent_bg = false
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var painter := BackgroundPainter.new()
	painter.position = -BAKE.position
	vp.add_child(painter)
	add_child(vp)
	sprite.texture = vp.get_texture()
	for i in 3:
		await get_tree().process_frame
	if not is_instance_valid(vp):
		return
	var img := vp.get_texture().get_image()
	if img == null or img.is_empty():
		return
	_cached = ImageTexture.create_from_image(img)
	sprite.texture = _cached
	vp.queue_free()


## Pinta el fondo estático (se ejecuta una vez dentro del SubViewport).
class BackgroundPainter extends Node2D:
	var _rng := RandomNumberGenerator.new()

	func _draw() -> void:
		_rng.seed = 2026
		var b := BAKE
		# 1. Cueva: degradado vertical (techo oscuro → resplandor cálido junto a la lava)
		var bands := 32
		for i in bands:
			var t := float(i) / bands
			var c := Color("0c070a").lerp(Color("1d0b10"), smoothstep(0.0, 0.55, t)).lerp(Color("47150c"), smoothstep(0.6, 1.0, t))
			draw_rect(Rect2(b.position.x, b.position.y + b.size.y * t, b.size.x, b.size.y / bands + 1.0), c)

		# 2. Capa lejana: muro de cueva con arcos y ruinas (bajo contraste por la calima)
		var far := Color("2b1820")
		var far_dark := Color("231219")
		_rock_ridge(Vector2(b.position.x, 120), Vector2(b.end.x, 120), 60.0, far_dark, 7)
		for tw in [[430.0, 150.0, 54.0], [520.0, 205.0, 40.0], [760.0, 175.0, 50.0], [850.0, 130.0, 62.0]]:
			var x: float = tw[0]
			var top: float = tw[1]
			var w: float = tw[2]
			draw_rect(Rect2(x - w * 0.5, top, w, 470.0 - top), far)
			for k in 3:
				draw_rect(Rect2(x - w * 0.5 + k * w / 3.0, top - 10.0, w / 3.0 - 5.0, 10.0), far)
			draw_rect(Rect2(x - 5.0, top + 34.0, 10.0, 16.0), Color(1.0, 0.5, 0.2, 0.12))
		draw_rect(Rect2(400.0, 320.0, 480.0, 150.0), far)
		for k in 5:
			var ax := 440.0 + k * 100.0
			draw_circle(Vector2(ax, 390.0), 26.0, far_dark)
			draw_rect(Rect2(ax - 26.0, 390.0, 52.0, 80.0), far_dark)

		# 3. Banda de calima cálida: separa la capa lejana de la intermedia
		for i in 6:
			draw_rect(Rect2(b.position.x, 360.0 + i * 22.0, b.size.x, 22.0), Color(1.0, 0.38, 0.12, 0.035 + i * 0.012))

		# 4. Capa intermedia: pilares y arcos de roca con borde iluminado por la lava
		var mid := Color("10060a")
		var rim := Color("4a1c12")
		for pl in [[150.0, 250.0, 120.0], [1130.0, 230.0, 130.0], [400.0, 520.0, 90.0], [880.0, 500.0, 100.0]]:
			var x: float = pl[0]
			var top: float = pl[1]
			var w: float = pl[2]
			var pts := PackedVector2Array([Vector2(x - w * 0.55, 800), Vector2(x - w * 0.45, top + 40.0), Vector2(x - w * 0.2, top), Vector2(x + w * 0.25, top + 12.0), Vector2(x + w * 0.5, top + 60.0), Vector2(x + w * 0.6, 800)])
			draw_colored_polygon(pts, mid)
			draw_polyline(PackedVector2Array([pts[1], pts[2], pts[3], pts[4]]), rim, 2.0)
		# Arco natural sobre la zona central (enmarca la plataforma colgante)
		draw_arc(Vector2(640, 260), 330.0, PI * 1.08, PI * 1.92, 40, mid, 46.0)
		draw_arc(Vector2(640, 260), 352.0, PI * 1.1, PI * 1.9, 40, Color("2c1016"), 4.0)
		# Estandartes con calavera colgados del arco (decoración apagada)
		for cx in [470.0, 810.0]:
			var y := -10.0
			while y < 120.0:
				draw_arc(Vector2(cx, y), 3.5, 0, TAU, 8, Color("2a1c24"), 2.0)
				y += 8.0
			draw_colored_polygon(PackedVector2Array([Vector2(cx - 24, 120), Vector2(cx + 24, 120), Vector2(cx + 24, 188), Vector2(cx, 176), Vector2(cx - 24, 188)]), Color("34101a"))
			draw_circle(Vector2(cx, 146), 8.0, Color("4a1e22"))
			draw_rect(Rect2(cx - 4.5, 151, 9, 5), Color("4a1e22"))

		# 5. Primer término: marco de rocas muy oscuras en los bordes y estalactitas
		var near := Color("0b0508")
		draw_colored_polygon(PackedVector2Array([Vector2(b.position.x, b.position.y), Vector2(40, b.position.y), Vector2(70, 120), Vector2(30, 300), Vector2(70, 520), Vector2(20, 800), Vector2(b.position.x, 800)]), near)
		draw_colored_polygon(PackedVector2Array([Vector2(b.end.x, b.position.y), Vector2(1240, b.position.y), Vector2(1210, 140), Vector2(1250, 330), Vector2(1205, 540), Vector2(1260, 800), Vector2(b.end.x, 800)]), near)
		var x0 := b.position.x
		var k := 0
		while x0 < b.end.x:
			var h := 30.0 + fmod(k * 47.0, 70.0)
			draw_colored_polygon(PackedVector2Array([Vector2(x0, b.position.y), Vector2(x0 + 60, b.position.y), Vector2(x0 + 34, 20.0 + h)]), near)
			x0 += 74.0
			k += 1

	func _rock_ridge(a: Vector2, c: Vector2, amp: float, col: Color, seed_offset: int) -> void:
		var pts := PackedVector2Array([Vector2(a.x, -200.0)])
		var x := a.x
		var i := seed_offset
		while x <= c.x:
			pts.append(Vector2(x, a.y + sin(x * 0.013 + i) * amp * 0.5 + _rng.randf_range(-8.0, 8.0)))
			x += 40.0
		pts.append(Vector2(c.x, -200.0))
		draw_colored_polygon(pts, col)


## Brasas que suben despacio (pocas: casi gratis).
class EmberLayer extends Node2D:
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		for i in 12:
			var speed := 18.0 + fmod(i * 7.0, 20.0)
			var y := 680.0 - fmod(_t * speed + i * 97.0, 620.0)
			var x := 140.0 + fmod(i * 173.0, 1000.0) + sin(_t * 0.8 + i) * 14.0
			var a := clampf((y - 60.0) / 300.0, 0.0, 1.0) * 0.45
			draw_circle(Vector2(x, y), 1.5 + fmod(i, 3.0) * 0.5, Color(1.0, 0.6, 0.2, a))
