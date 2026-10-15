class_name SegmentView
extends Node2D
## Tramo de suelo (estilo v2): losas de roca con una rejilla volcánica de hierro.
## - seguro: horneado (ArtCache);
## - aviso: la rejilla se pone al rojo cada vez más, la losa se calienta y sube calima;
##   encima (capa de avisos) una señal con cuenta atrás que nada puede tapar;
## - lava: superficie fundida con borde de costra y burbujas;
## - al enfriarse: costra oscura que se apaga en 1 s.

var _s: LavaFloorSegment
var _time := 0.0
var _cooling := 0.0
var _overlay: SegmentOverlay
var _ready_art := false


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
	if _s.stage != LavaFloorSegment.Stage.SAFE or _cooling > 0.0 or not _ready_art:
		queue_redraw()
		_overlay.queue_redraw()


func _draw() -> void:
	var r := Rect2(-_s.size * 0.5, _s.size)
	if _s.stage == LavaFloorSegment.Stage.LAVA:
		_draw_lava(r)
		return
	var size := _s.size
	var key := "floor_%dx%d_%s" % [size.x, size.y, _s.name]
	_ready_art = ArtCache.draw(self, key, ArenaArt.bounds(size), func(ci: CanvasItem) -> void: ArenaArt.floor_tile(ci, size, key))
	var heat := 0.0
	if _s.stage == LavaFloorSegment.Stage.WARNING:
		heat = 1.0 - _s.time_left / maxf(_s.stage_duration, 0.01)
	if heat > 0.0:
		var blink := 0.5 + 0.5 * sin(_time * (6.0 + heat * 22.0))
		draw_rect(r, Color(ViewPalette.LAVA_DEEP, heat * 0.35))
		for slot in ArenaArt.grate_slots(size):
			draw_rect(slot, ViewPalette.LAVA.lerp(ViewPalette.LAVA_HOT, heat * blink))
		draw_line(Vector2(r.position.x + 2, r.position.y + 1.5), Vector2(r.end.x - 2, r.position.y + 1.5), Color(ViewPalette.LAVA_HOT, heat), 3.0)
		for k in 4:
			var x := r.position.x + 20.0 + k * (r.size.x - 40.0) / 3.0
			var y := r.position.y - 6.0 - fmod(_time * 40.0 + k * 13.0, 30.0)
			draw_line(Vector2(x, y), Vector2(x + 4.0 * sin(_time * 9.0 + k), y - 8.0), Color(ViewPalette.LAVA_HOT, 0.5 * heat), 2.0)
	if _cooling > 0.0:
		draw_rect(r, Color(0.12, 0.05, 0.04, 0.7 * _cooling))
		for slot in ArenaArt.grate_slots(size):
			draw_rect(slot, Color(ViewPalette.LAVA, 0.6 * _cooling))


func _draw_lava(r: Rect2) -> void:
	draw_rect(r, ViewPalette.LAVA_DEEP)
	var pts := PackedVector2Array()
	var x := r.position.x
	while x <= r.end.x + 0.1:
		pts.append(Vector2(x, r.position.y + 5.0 + sin(_time * 4.0 + x * 0.06) * 2.5))
		x += 10.0
	pts.append(Vector2(r.end.x, r.end.y - 4.0))
	pts.append(Vector2(r.position.x, r.end.y - 4.0))
	draw_colored_polygon(pts, ViewPalette.LAVA)
	for i in range(pts.size() - 3):
		draw_line(pts[i], pts[i + 1], ViewPalette.LAVA_WHITE, 2.5)
	for i in 4:
		var t := fmod(_time * 0.9 + i * 0.27, 1.0)
		var c := Vector2(r.position.x + r.size.x * (0.15 + 0.23 * i), r.position.y + 15.0 - t * 8.0)
		draw_arc(c, 2.0 + t * 3.0, 0, TAU, 10, Color(ViewPalette.LAVA_HOT, 1.0 - t), 2.0)
	# Costra oscura en los bordes: delimita bien la zona peligrosa
	draw_rect(Rect2(r.position.x, r.position.y, 5, r.size.y), Color("2e0f0a"))
	draw_rect(Rect2(r.end.x - 5, r.position.y, 5, r.size.y), Color("2e0f0a"))
	draw_rect(Rect2(r.position.x, r.end.y - 4, r.size.x, 4), Color("2e0f0a"))
