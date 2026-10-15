class_name PlatformView
extends Node2D
## Plataforma inestable (estilo v2). Cuerpo ilustrado y horneado por tipo y deterioro:
## - frágil (se desgasta): puente de tablones con cuerdas;
## - inclinable: losa de piedra con herrajes, colgada de un pivote central con cadena.
## Deterioro visible: sana → agrietada (grietas, tablón combado) → crítica (trozo que falta,
## quemado y bordes al rojo) → a punto de caer (tiembla, «!»). Ancla: borde cian y estacas.
## Las cuerdas/cadenas se dibujan aparte (RopeView) porque cuelgan verticales al inclinarse.

var _p: UnstablePlatform
var _time := 0.0
var _overlay: PlatformOverlay
var _ropes: RopeView
var _ready_art := false
## Largo de cuerdas/cadenas hacia arriba; -1 = hasta el techo (y = -20 en el mundo).
var rope_length := -1.0


func _ready() -> void:
	_p = get_parent() as UnstablePlatform
	_p.stage_changed.connect(func(_s: UnstablePlatform.Stage) -> void: _dirty())
	_p.anchored.connect(func(_d: float) -> void: _dirty())
	_p.anchor_released.connect(_dirty)
	_ropes = RopeView.new()
	_ropes.view = self
	_ropes.show_behind_parent = true
	add_child(_ropes)
	_overlay = PlatformOverlay.new()
	_overlay.platform = _p
	add_child(_overlay)


func is_fragile() -> bool:
	return _p.params.wear_enabled and not _p.params.tilt_enabled


func _dirty() -> void:
	queue_redraw()
	_ropes.queue_redraw()
	_overlay.queue_redraw()


func _damage() -> int:
	if not _p.params.wear_enabled:
		return 0
	match _p.stage:
		UnstablePlatform.Stage.INTACT, UnstablePlatform.Stage.RESPAWNING:
			return 0
		UnstablePlatform.Stage.CRACKED:
			return 1
	return 2


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
	if animated or not _ready_art:
		queue_redraw()
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
	var dmg := _damage()
	var size := _p.size
	var fragile := is_fragile()
	var key := "%s_%dx%d_d%d" % ["wood" if fragile else "slab", size.x, size.y, dmg]
	_ready_art = ArtCache.draw(self, key, ArenaArt.bounds(size), func(ci: CanvasItem) -> void:
		if fragile:
			ArenaArt.wood_bridge(ci, size, dmg, key)
		else:
			ArenaArt.stone_slab(ci, size, dmg, key))
	# Crítica: bordes y grietas al rojo, latiendo (en directo, pocas líneas)
	if dmg >= 2 and not _p.is_anchored():
		var glow := 0.45 + 0.35 * sin(_time * 7.0)
		draw_line(Vector2(r.position.x + 4, r.end.y - 2), Vector2(r.end.x - 4, r.end.y - 2), Color(ViewPalette.LAVA, glow), 3.0)
		for i in 3:
			var x := r.position.x + r.size.x * (0.25 + 0.25 * i)
			draw_line(Vector2(x, r.position.y + 3), Vector2(x + 3, r.end.y - 3), Color(ViewPalette.LAVA_HOT, glow * 0.8), 1.5)
	if _p.is_anchored():
		var col := ViewPalette.ANCHOR
		if _p.anchor_left <= _p.anchor_warning:
			col = Color(1.0, 0.55, 0.2).lerp(col, 0.5 + 0.5 * sin(_time * 16.0))
		var pts := DrawKit.rounded_rect(r.grow(4.0), 7.0, 3)
		pts.append(pts[0])
		draw_polyline(pts, DrawKit.OUTLINE, 6.0)
		draw_polyline(pts, col, 3.5)
		for cx in [r.position.x + 24.0, r.end.x - 24.0]:
			for k in 3:
				DrawKit.circle(self, Vector2(cx, r.end.y + 8.0 + k * 9.0), 3.2, Color(col, 1.0 - k * 0.25), DrawKit.OUTLINE, 1.5)


## Cuerdas (puente) o cadena con pivote (losa). Verticales en el mundo aunque la plataforma
## gire, así que solo esta parte se redibuja al inclinarse.
class RopeView extends Node2D:
	var view: PlatformView
	var _last_rot := 999.0

	func _process(_delta: float) -> void:
		var p := view._p
		if absf(p.rotation - _last_rot) > 0.002:
			_last_rot = p.rotation
			queue_redraw()

	func _rope(attach: Vector2) -> float:
		if view.rope_length >= 0.0:
			return view.rope_length
		return maxf((get_global_transform() * attach).y + 20.0, 0.0)

	func _draw() -> void:
		var p := view._p
		if p.stage >= UnstablePlatform.Stage.FALLING:
			return
		var r := Rect2(-p.size * 0.5, p.size)
		var inv := get_global_transform().affine_inverse()
		if view.is_fragile():
			for cx in [r.position.x + 8.0, r.end.x - 8.0]:
				var attach := Vector2(cx, r.position.y)
				var top: Vector2 = inv * (get_global_transform() * attach + Vector2(0, -_rope(attach)))
				draw_line(attach, top, DrawKit.OUTLINE, 5.0)
				draw_line(attach, top, Color("c9a46a"), 2.5)
				draw_dashed_line(attach, top, Color("8a6a3c"), 1.2, 4.0)
		else:
			var attach := Vector2(0, r.position.y - 7)
			var top: Vector2 = inv * (get_global_transform() * attach + Vector2(0, -_rope(attach)))
			draw_line(attach, top, DrawKit.OUTLINE, 7.0)
			draw_line(attach, top, ViewPalette.CHAIN, 4.0)
			draw_dashed_line(attach, top, ViewPalette.METAL, 2.0, 5.0)
			DrawKit.poly(self, PackedVector2Array([Vector2(-14, r.position.y + 1), Vector2(14, r.position.y + 1), Vector2(7, r.position.y - 10), Vector2(-7, r.position.y - 10)]), ArenaArt.IRON)
			DrawKit.circle(self, Vector2(0, r.position.y - 4), 3.5, ArenaArt.IRON_LIGHT, DrawKit.OUTLINE, 2.0)
