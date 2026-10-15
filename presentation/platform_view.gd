class_name PlatformView
extends Node2D
## Plataforma inestable (estilo v1). El aspecto depende del tipo:
## - frágil (se desgasta): tablones de madera con cuerdas;
## - inclinable: losa de piedra colgada de un pivote central;
## - ambas cosas: losa de piedra con pivote que también se agrieta.
## Estados: segura → agrietada → crítica (bordes al rojo) → a punto de caer (tiembla, aviso «!»)
## → cae → reaparece (silueta). Con Ancla: brillo cian, icono y anillo de tiempo; al ir a
## soltarse parpadea en naranja con «¡SE SUELTA!». Solo redibuja cuando cambia algo.

var _p: UnstablePlatform
var _time := 0.0
var _last_rot := 999.0
var _overlay: PlatformOverlay
## Largo de cuerdas/cadenas hacia arriba; -1 = hasta el techo (y = -20 en el mundo).
var rope_length := -1.0


func _ready() -> void:
	_p = get_parent() as UnstablePlatform
	_p.stage_changed.connect(func(_s: UnstablePlatform.Stage) -> void: _dirty())
	_p.anchored.connect(func(_d: float) -> void: _dirty())
	_p.anchor_released.connect(_dirty)
	_overlay = PlatformOverlay.new()
	_overlay.platform = _p
	add_child(_overlay)


func is_fragile() -> bool:
	return _p.params.wear_enabled and not _p.params.tilt_enabled


func _dirty() -> void:
	queue_redraw()
	_overlay.queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	var st := _p.stage
	var animated := _p.is_anchored() or st == UnstablePlatform.Stage.CRITICAL or st == UnstablePlatform.Stage.COLLAPSING or st == UnstablePlatform.Stage.RESPAWNING
	position = Vector2.ZERO
	if not _p.is_anchored():
		if st == UnstablePlatform.Stage.COLLAPSING:
			position = Vector2(sin(_time * 60.0) * 3.0, cos(_time * 47.0) * 1.5)
		elif st == UnstablePlatform.Stage.CRITICAL:
			position = Vector2(sin(_time * 35.0) * 1.0, 0)
	# Las cadenas son verticales en el mundo: si la plataforma gira, hay que redibujarlas.
	if animated or absf(_p.rotation - _last_rot) > 0.002:
		_last_rot = _p.rotation
		queue_redraw()
	if animated:
		_overlay.queue_redraw()


func _draw() -> void:
	var st := _p.stage
	if st == UnstablePlatform.Stage.GONE:
		return
	var r := Rect2(-_p.size * 0.5, _p.size)
	if st == UnstablePlatform.Stage.RESPAWNING:
		var a := 0.35 + 0.25 * sin(_time * 10.0)
		var pts := DrawKit.rounded_rect(r, 5.0, 2)
		pts.append(pts[0])
		for i in range(0, pts.size() - 1, 2):
			draw_line(pts[i], pts[i + 1], Color(1, 1, 1, a), 2.0)
		return
	var crit := st >= UnstablePlatform.Stage.CRITICAL and not _p.is_anchored()
	if is_fragile():
		_draw_ropes(r)
		_draw_wood(r, st)
	else:
		_draw_pivot(r)
		_draw_slab(r)
	# Grietas según el desgaste
	if _p.params.wear_enabled:
		var cracks := 0
		if st == UnstablePlatform.Stage.CRACKED:
			cracks = 2
		elif st >= UnstablePlatform.Stage.CRITICAL:
			cracks = 4
		for i in cracks:
			var x := r.position.x + r.size.x * (0.2 + 0.2 * i)
			var pts := PackedVector2Array([Vector2(x, r.position.y + 1), Vector2(x + 5, r.position.y + r.size.y * 0.45), Vector2(x - 2, r.position.y + r.size.y * 0.7), Vector2(x + 3, r.end.y - 1)])
			draw_polyline(pts, ViewPalette.CRACK, 2.5)
			if crit:
				draw_polyline(pts, Color(ViewPalette.LAVA_HOT, 0.55 + 0.35 * sin(_time * 8.0 + i)), 1.2)
		# Bordes al rojo cuando está crítica (como en la referencia)
		if crit:
			var glow := 0.45 + 0.3 * sin(_time * 7.0)
			draw_rect(Rect2(r.position.x + 2, r.end.y - 5, r.size.x - 4, 3), Color(ViewPalette.LAVA, glow))
			draw_rect(Rect2(r.position.x + 1, r.position.y + 3, 3, r.size.y - 6), Color(ViewPalette.LAVA, glow))
			draw_rect(Rect2(r.end.x - 4, r.position.y + 3, 3, r.size.y - 6), Color(ViewPalette.LAVA, glow))
	# Ancla: borde cian y estacas que la sujetan
	if _p.is_anchored():
		var col := ViewPalette.ANCHOR
		if _p.anchor_left <= _p.anchor_warning:
			col = Color(1.0, 0.55, 0.2).lerp(col, 0.5 + 0.5 * sin(_time * 16.0))
		var pts := DrawKit.rounded_rect(r.grow(4.0), 7.0, 3)
		pts.append(pts[0])
		draw_polyline(pts, DrawKit.OUTLINE, 6.0, true)
		draw_polyline(pts, col, 3.5, true)
		for cx in [r.position.x + 24.0, r.end.x - 24.0]:
			for k in 3:
				DrawKit.circle(self, Vector2(cx, r.end.y + 8.0 + k * 9.0), 3.2, Color(col, 1.0 - k * 0.25), DrawKit.OUTLINE, 1.5)


## Cuerdas de un puente colgante (siempre verticales en el mundo).
func _draw_ropes(r: Rect2) -> void:
	var to_local_xf := get_global_transform().affine_inverse()
	for cx in [r.position.x + 10.0, r.end.x - 10.0]:
		var attach := Vector2(cx, r.position.y + 2)
		var top: Vector2 = to_local_xf * (get_global_transform() * attach + Vector2(0, -_rope(attach)))
		draw_line(attach, top, DrawKit.OUTLINE, 5.0)
		draw_line(attach, top, Color("b08a5a"), 2.5)


## Pivote central con una cadena gruesa: indica que la losa puede bascular.
func _draw_pivot(r: Rect2) -> void:
	var to_local_xf := get_global_transform().affine_inverse()
	var attach := Vector2(0, r.position.y - 6)
	var top: Vector2 = to_local_xf * (get_global_transform() * attach + Vector2(0, -_rope(attach)))
	# Cadena: 3 trazos (contorno, eslabones y brillo discontinuo); barato en móviles.
	draw_line(attach, top, DrawKit.OUTLINE, 7.0)
	draw_line(attach, top, ViewPalette.CHAIN, 4.0)
	draw_dashed_line(attach, top, ViewPalette.METAL, 2.0, 5.0)
	DrawKit.poly(self, PackedVector2Array([Vector2(-14, r.position.y + 2), Vector2(14, r.position.y + 2), Vector2(7, r.position.y - 9), Vector2(-7, r.position.y - 9)]), ViewPalette.METAL)
	DrawKit.circle(self, Vector2(0, r.position.y - 3), 3.5, ViewPalette.STONE_TOP, DrawKit.OUTLINE, 2.0)


func _rope(attach: Vector2) -> float:
	if rope_length >= 0.0:
		return rope_length
	return maxf((get_global_transform() * attach).y + 20.0, 0.0)


func _draw_wood(r: Rect2, st: UnstablePlatform.Stage) -> void:
	DrawKit.poly(self, DrawKit.rounded_rect(r, 4.0, 2), ViewPalette.WOOD)
	draw_rect(Rect2(r.position + Vector2(2, 2), Vector2(r.size.x - 4, 5)), ViewPalette.WOOD_LIGHT)
	var plank := 22.0
	var x := r.position.x + plank
	var i := 0
	while x < r.end.x - 4.0:
		draw_line(Vector2(x, r.position.y + 2), Vector2(x, r.end.y - 2), ViewPalette.WOOD_DARK, 2.0)
		# Clavos
		draw_circle(Vector2(x - plank * 0.5, r.position.y + 6), 1.4, ViewPalette.METAL)
		draw_circle(Vector2(x - plank * 0.5, r.end.y - 6), 1.4, ViewPalette.METAL)
		# Tablones desplazados al agrietarse
		if st >= UnstablePlatform.Stage.CRACKED and i % 3 == 1:
			draw_rect(Rect2(x - plank + 1, r.position.y + 2, plank - 2, r.size.y - 4), Color(ViewPalette.WOOD_DARK, 0.45))
		x += plank
		i += 1


func _draw_slab(r: Rect2) -> void:
	DrawKit.poly(self, DrawKit.rounded_rect(r, 5.0, 2), ViewPalette.STONE)
	draw_colored_polygon(DrawKit.rounded_rect(Rect2(r.position + Vector2(2, 2), Vector2(r.size.x - 4, 6)), 3.0, 2), ViewPalette.STONE_TOP)
	var x := r.position.x + 30.0
	while x < r.end.x - 10.0:
		draw_line(Vector2(x, r.position.y + 9), Vector2(x, r.end.y - 3), ViewPalette.STONE_SEAM, 2.0)
		x += 46.0
