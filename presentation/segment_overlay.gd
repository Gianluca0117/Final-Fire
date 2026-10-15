class_name SegmentOverlay
extends Node2D
## Señal de aviso de un tramo de suelo, por encima de personajes y efectos (z 9):
## triángulo «!» con anillo de cuenta atrás y segundos restantes.

var segment: LavaFloorSegment
var _time := 0.0


func _ready() -> void:
	z_index = 9
	z_as_relative = false


func _process(delta: float) -> void:
	_time += delta


func _draw() -> void:
	if segment.stage != LavaFloorSegment.Stage.WARNING:
		return
	var progress := 1.0 - segment.time_left / maxf(segment.stage_duration, 0.01)
	var c := Vector2(0, -segment.size.y * 0.5 - 58.0)
	var pulse := 0.65 + 0.35 * absf(sin(_time * (5.0 + progress * 12.0)))
	DrawKit.circle(self, c, 24.0, Color(0.1, 0.05, 0.06, 0.8), DrawKit.OUTLINE, 2.5)
	draw_arc(c, 24.0, -PI / 2, -PI / 2 + TAU * (1.0 - progress), 32, ViewPalette.LAVA_HOT, 5.0, true)
	var tri := PackedVector2Array([c + Vector2(0, -15), c + Vector2(14, 10), c + Vector2(-14, 10)])
	DrawKit.poly(self, tri, Color(ViewPalette.WARN, pulse), DrawKit.OUTLINE, 2.5)
	DrawKit.text(self, c + Vector2(-20, 8), "!", 20, Color.WHITE, 40, HORIZONTAL_ALIGNMENT_CENTER, 4)
	DrawKit.text(self, c + Vector2(-40, 44), "%.1f" % maxf(segment.time_left, 0.0), 16, ViewPalette.LAVA_HOT, 80)
	# Flechas hacia el tramo que se va a encender (a los lados del número, sin taparlo)
	for sx in [-1.0, 1.0]:
		var ac := c + Vector2(sx * 27.0, 36.0)
		DrawKit.poly(self, PackedVector2Array([ac + Vector2(-5, -4), ac + Vector2(5, -4), ac + Vector2(0, 4)]), Color(ViewPalette.LAVA_HOT, pulse), DrawKit.OUTLINE, 1.5)
