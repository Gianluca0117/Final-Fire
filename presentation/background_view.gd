class_name BackgroundView
extends Node2D
## Fondo de cueva volcánica (estilo v1). La parte estática se pinta UNA sola vez en una
## textura (SubViewport con UPDATE_ONCE): cada fotograma cuesta un único rectángulo.
## Animado aparte y barato: dos cascadas de lava (shader) y unas pocas brasas.
## Sin contornos y más oscuro que el primer plano para que lo jugable destaque.

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
	for x in [300.0, 1010.0]:
		var fall := ColorRect.new()
		fall.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fall.position = Vector2(x - 26.0, 120.0)
		fall.size = Vector2(52.0, 560.0)
		fall.material = ShaderMaterial.new()
		(fall.material as ShaderMaterial).shader = LAVAFALL_SHADER
		add_child(fall)
	_embers = EmberLayer.new()
	add_child(_embers)


func _bake(sprite: Sprite2D) -> void:
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
	_cached = ImageTexture.create_from_image(vp.get_texture().get_image())
	sprite.texture = _cached
	vp.queue_free()


## Pinta el fondo estático (se ejecuta una vez dentro del SubViewport).
class BackgroundPainter extends Node2D:
	func _draw() -> void:
		var b := BAKE
		# Degradado vertical: techo oscuro → resplandor cálido junto a la lava
		var bands := 24
		for i in bands:
			var t := float(i) / bands
			var c := Color("0f080d").lerp(Color("230c10"), smoothstep(0.0, 0.6, t)).lerp(Color("4a160c"), smoothstep(0.55, 1.0, t))
			draw_rect(Rect2(b.position.x, b.position.y + b.size.y * t, b.size.x, b.size.y / bands + 1.0), c)
		# Ruinas de castillo al fondo
		var castle := Color("210f16")
		var win := Color(1.0, 0.5, 0.15, 0.18)
		for tw in [[420.0, 120.0, 70.0], [560.0, 170.0, 54.0], [760.0, 140.0, 64.0], [880.0, 100.0, 80.0]]:
			var x: float = tw[0]
			var top: float = tw[1]
			var w: float = tw[2]
			draw_rect(Rect2(x - w * 0.5, top, w, 470.0 - top), castle)
			for k in 3:
				draw_rect(Rect2(x - w * 0.5 + k * w / 3.0, top - 12.0, w / 3.0 - 6.0, 12.0), castle)
			draw_rect(Rect2(x - 6.0, top + 40.0, 12.0, 20.0), win)
		draw_rect(Rect2(380.0, 300.0, 540.0, 170.0), castle)
		for k in 5:
			var ax := 420.0 + k * 110.0
			draw_circle(Vector2(ax, 380.0), 30.0, Color("170910"))
			draw_rect(Rect2(ax - 30.0, 380.0, 60.0, 90.0), Color("170910"))
		# Paredes de roca laterales
		var rock := Color("1f0e14")
		draw_colored_polygon(PackedVector2Array([Vector2(b.position.x, 0), Vector2(150, 40), Vector2(120, 260), Vector2(190, 520), Vector2(80, 760), Vector2(b.position.x, 760)]), rock)
		draw_colored_polygon(PackedVector2Array([Vector2(b.end.x, 0), Vector2(1130, 60), Vector2(1170, 300), Vector2(1090, 540), Vector2(1200, 760), Vector2(b.end.x, 760)]), rock)
		# Pilares de roca en primer término del fondo, con borde cálido
		for pl in [[230.0, 520.0, 70.0], [640.0, 560.0, 90.0], [1060.0, 510.0, 70.0]]:
			var x: float = pl[0]
			var top: float = pl[1]
			var w: float = pl[2]
			draw_colored_polygon(PackedVector2Array([Vector2(x - w * 0.5, 800), Vector2(x - w * 0.35, top), Vector2(x + w * 0.35, top - 10.0), Vector2(x + w * 0.5, 800)]), Color("190a10"))
			draw_line(Vector2(x - w * 0.35, top), Vector2(x + w * 0.35, top - 10.0), Color("6a2414"), 3.0)
		# Cadenas colgantes con estandartes de calavera (decoración apagada)
		for cx in [520.0, 780.0]:
			var y := -20.0
			while y < 170.0:
				draw_arc(Vector2(cx, y), 4.0, 0, TAU, 8, Color("2e2028"), 2.0)
				y += 9.0
			draw_colored_polygon(PackedVector2Array([Vector2(cx - 28, 170), Vector2(cx + 28, 170), Vector2(cx + 28, 250), Vector2(cx, 236), Vector2(cx - 28, 250)]), Color("35101a"))
			draw_circle(Vector2(cx, 200), 9.0, Color("4a1e22"))
			draw_rect(Rect2(cx - 5, 206, 10, 6), Color("4a1e22"))
			draw_circle(Vector2(cx - 3.5, 199), 2.5, Color("35101a"))
			draw_circle(Vector2(cx + 3.5, 199), 2.5, Color("35101a"))
		# Estalactitas
		var x0 := b.position.x
		var k := 0
		while x0 < b.end.x:
			var h := 40.0 + fmod(k * 53.0, 90.0)
			draw_colored_polygon(PackedVector2Array([Vector2(x0, b.position.y), Vector2(x0 + 56, b.position.y), Vector2(x0 + 28, h)]), Color("1a0c11"))
			x0 += 68.0
			k += 1


## Brasas que suben despacio (pocas: casi gratis).
class EmberLayer extends Node2D:
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		for i in 14:
			var speed := 18.0 + fmod(i * 7.0, 20.0)
			var y := 720.0 - fmod(_t * speed + i * 97.0, 700.0)
			var x := fmod(i * 173.0, 1280.0) + sin(_t * 0.8 + i) * 14.0
			var a := clampf((y - 40.0) / 300.0, 0.0, 1.0) * 0.55
			draw_circle(Vector2(x, y), 1.6 + fmod(i, 3.0) * 0.6, Color(1.0, 0.6, 0.2, a))
