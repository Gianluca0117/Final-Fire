class_name SegmentView
extends Node2D
## Tramo de suelo (estilo v1):
## - seguro: losas de piedra con rejillas oscuras (aprendes que «aquí puede salir lava»);
## - aviso: las rejillas se ponen al rojo cada vez más, con calima; encima (capa de avisos)
##   una señal grande con cuenta atrás que nada puede tapar;
## - lava: superficie fundida con burbujas;
## - al enfriarse: costra oscura que se apaga en 1 s.

var _s: LavaFloorSegment
var _time := 0.0
var _cooling := 0.0
var _overlay: SegmentOverlay


func _ready() -> void:
	_s = get_parent() as LavaFloorSegment
	_s.stage_changed.connect(_on_stage)
	_overlay = SegmentOverlay.new()
	_overlay.segment = _s
	add_child(_overlay)


func _on_stage(stage: LavaFloorSegment.Stage) -> void:
	if stage == LavaFloorSegment.Stage.SAFE:
		_cooling = 1.0
	queue_redraw()
	_overlay.queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if _cooling > 0.0:
		_cooling -= delta
	if _s.stage != LavaFloorSegment.Stage.SAFE or _cooling > 0.0:
		queue_redraw()
		_overlay.queue_redraw()


func _draw() -> void:
	var r := Rect2(-_s.size * 0.5, _s.size)
	match _s.stage:
		LavaFloorSegment.Stage.LAVA:
			_draw_lava(r)
		_:
			_draw_stone(r)


func _draw_stone(r: Rect2) -> void:
	var heat := 0.0
	if _s.stage == LavaFloorSegment.Stage.WARNING:
		heat = 1.0 - _s.time_left / maxf(_s.stage_duration, 0.01)
	var base := ViewPalette.STONE.lerp(Color("6b2c22"), heat * 0.7)
	if _cooling > 0.0:
		base = base.lerp(Color("2b1a1a"), _cooling)
	DrawKit.poly(self, PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), base, DrawKit.OUTLINE, 2.0)
	draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(r.size.x - 2, 6)), ViewPalette.STONE_TOP.lerp(ViewPalette.LAVA_HOT, heat))
	# Rejillas: con el aviso se encienden de naranja a amarillo y parpadean más rápido
	var blink := 0.5 + 0.5 * sin(_time * (6.0 + heat * 22.0))
	var vent := ViewPalette.STONE_SEAM.lerp(ViewPalette.LAVA, heat).lerp(ViewPalette.LAVA_HOT, heat * blink)
	for i in 3:
		var cx := r.position.x + r.size.x * (0.2 + 0.3 * i)
		draw_rect(Rect2(cx - 14, r.position.y + 13, 28, 5), vent)
		draw_rect(Rect2(cx - 14, r.position.y + 13, 28, 5), DrawKit.OUTLINE, false, 1.5)
	# Calima (ondas de calor) sobre el tramo durante el aviso
	if heat > 0.0:
		for k in 4:
			var x := r.position.x + 20.0 + k * (r.size.x - 40.0) / 3.0
			var y := r.position.y - 6.0 - fmod(_time * 40.0 + k * 13.0, 30.0)
			draw_line(Vector2(x, y), Vector2(x + 4.0 * sin(_time * 9.0 + k), y - 8.0), Color(ViewPalette.LAVA_HOT, 0.5 * heat), 2.0)


func _draw_lava(r: Rect2) -> void:
	draw_rect(r, ViewPalette.LAVA_DEEP)
	var pts := PackedVector2Array()
	var x := r.position.x
	while x <= r.end.x + 0.1:
		pts.append(Vector2(x, r.position.y + 4.0 + sin(_time * 4.0 + x * 0.06) * 2.5))
		x += 12.0
	pts.append(Vector2(r.end.x, r.end.y - 6.0))
	pts.append(Vector2(r.position.x, r.end.y - 6.0))
	draw_colored_polygon(pts, ViewPalette.LAVA)
	for i in range(pts.size() - 3):
		draw_line(pts[i], pts[i + 1], ViewPalette.LAVA_WHITE, 2.5)
	for i in 4:
		var t := fmod(_time * 0.9 + i * 0.27, 1.0)
		var c := Vector2(r.position.x + r.size.x * (0.15 + 0.23 * i), r.position.y + 14.0 - t * 8.0)
		draw_arc(c, 2.0 + t * 3.0, 0, TAU, 10, Color(ViewPalette.LAVA_HOT, 1.0 - t), 2.0)
	# Bordes de costra oscura: delimitan bien la zona peligrosa
	draw_rect(Rect2(r.position.x, r.position.y, 4, r.size.y), Color("3a120c"))
	draw_rect(Rect2(r.end.x - 4, r.position.y, 4, r.size.y), Color("3a120c"))
