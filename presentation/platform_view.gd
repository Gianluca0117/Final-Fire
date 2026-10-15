class_name PlatformView
extends Node2D
## Plataforma inestable: grietas según la integridad, temblor como aviso antes de caer
## y silueta translúcida mientras reaparece.

var _p: UnstablePlatform
var _time := 0.0


func _ready() -> void:
	_p = get_parent() as UnstablePlatform


func _process(delta: float) -> void:
	_time += delta
	position = Vector2.ZERO
	if _p.stage == UnstablePlatform.Stage.COLLAPSING:
		position = Vector2(sin(_time * 60.0) * 3.0, cos(_time * 47.0) * 1.5)
	elif _p.stage == UnstablePlatform.Stage.CRITICAL:
		position = Vector2(sin(_time * 35.0) * 1.0, 0)
	queue_redraw()


func _draw() -> void:
	var st := _p.stage
	if st == UnstablePlatform.Stage.GONE:
		return
	var r := Rect2(-_p.size * 0.5, _p.size)
	if st == UnstablePlatform.Stage.RESPAWNING:
		var a := 0.25 + 0.2 * sin(_time * 10.0)
		draw_rect(r, Color(ViewPalette.STONE_TOP, a))
		draw_rect(r, Color(1, 1, 1, a), false, 2.0)
		return
	# Cadenas que la sostienen (en la referencia cuelgan del techo): siempre verticales
	# en el mundo aunque la plataforma esté inclinada.
	var to_local_xf := get_global_transform().affine_inverse()
	for cx in [r.position.x + 14.0, r.end.x - 14.0]:
		var attach := Vector2(cx, r.position.y)
		var top: Vector2 = to_local_xf * (get_global_transform() * attach + Vector2(0, -260.0))
		draw_line(attach, top, ViewPalette.CHAIN, 3.0)
	draw_rect(r, ViewPalette.STONE)
	draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), ViewPalette.STONE_TOP)
	# Grietas
	var cracks := 0
	if st == UnstablePlatform.Stage.CRACKED:
		cracks = 2
	elif st >= UnstablePlatform.Stage.CRITICAL:
		cracks = 5
	for i in cracks:
		var x := r.position.x + r.size.x * (0.15 + 0.17 * i)
		draw_polyline(PackedVector2Array([Vector2(x, r.position.y), Vector2(x + 6, r.position.y + r.size.y * 0.5), Vector2(x - 3, r.end.y)]), ViewPalette.CRACK, 2.0)
	if st == UnstablePlatform.Stage.COLLAPSING:
		var a := 0.35 + 0.35 * sin(_time * 18.0)
		draw_rect(r.grow(3.0), Color(ViewPalette.WARN, a), false, 3.0)
	# Integridad (barra fina bajo la plataforma)
	if _p.params.wear_enabled and st <= UnstablePlatform.Stage.CRITICAL:
		draw_rect(Rect2(Vector2(r.position.x, r.end.y + 3), Vector2(r.size.x * _p.integrity, 3)), Color(1, 1, 1, 0.35))
