class_name SegmentView
extends Node2D
## Tramo de suelo: piedra normal, aviso parpadeante con cuenta atrás y lava.

var _s: LavaFloorSegment
var _time := 0.0


func _ready() -> void:
	_s = get_parent() as LavaFloorSegment


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var r := Rect2(-_s.size * 0.5, _s.size)
	match _s.stage:
		LavaFloorSegment.Stage.SAFE:
			draw_rect(r, ViewPalette.STONE)
			draw_rect(Rect2(r.position, Vector2(r.size.x, 6)), ViewPalette.STONE_TOP)
		LavaFloorSegment.Stage.WARNING:
			var progress := 1.0 - _s.time_left / maxf(_s.stage_duration, 0.01)
			var blink := 0.5 + 0.5 * sin(_time * (8.0 + progress * 22.0))
			draw_rect(r, ViewPalette.STONE.lerp(ViewPalette.LAVA_DEEP, progress * 0.7))
			draw_rect(Rect2(r.position, Vector2(r.size.x, 6)), ViewPalette.WARN.lerp(ViewPalette.LAVA_HOT, blink))
			draw_rect(r, Color(ViewPalette.WARN, 0.25 + 0.35 * blink), false, 3.0)
			var font := ThemeDB.fallback_font
			draw_string(font, Vector2(r.position.x, r.position.y - 14), "! %.1f" % _s.time_left, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 20, Color(ViewPalette.LAVA_HOT, 0.6 + 0.4 * blink))
		LavaFloorSegment.Stage.LAVA:
			draw_rect(r, ViewPalette.LAVA_DEEP)
			var pts := PackedVector2Array()
			var x := r.position.x
			while x <= r.end.x:
				pts.append(Vector2(x, r.position.y + 3.0 + sin(_time * 4.0 + x * 0.05) * 3.0))
				x += 12.0
			pts.append(Vector2(r.end.x, r.end.y))
			pts.append(Vector2(r.position.x, r.end.y))
			draw_colored_polygon(pts, ViewPalette.LAVA)
			draw_rect(Rect2(r.position + Vector2(0, 2), Vector2(r.size.x, 3)), Color(ViewPalette.LAVA_HOT, 0.7))
