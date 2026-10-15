class_name PlatformOverlay
extends Node2D
## Avisos de una plataforma dibujados POR ENCIMA de personajes y efectos (z 9), para que
## nunca queden tapados: «!» antes de caer, icono y tiempo del Ancla, «¡SE SUELTA!».

var platform: UnstablePlatform
var _time := 0.0


func _ready() -> void:
	z_index = 9
	z_as_relative = false


func _process(delta: float) -> void:
	_time += delta
	# Los avisos se leen siempre derechos aunque la plataforma esté inclinada.
	global_rotation = 0.0


func _draw() -> void:
	var p := platform
	var r := Rect2(-p.size * 0.5, p.size)
	if p.is_anchored():
		var col := ViewPalette.ANCHOR
		var ending := p.anchor_left <= p.anchor_warning
		if ending:
			col = Color(1.0, 0.55, 0.2).lerp(col, 0.5 + 0.5 * sin(_time * 16.0))
		var c := Vector2(0, r.position.y - 30.0)
		DrawKit.circle(self, c, 17.0, Color(0.08, 0.05, 0.07, 0.85), DrawKit.OUTLINE, 2.5)
		draw_arc(c, 17.0, -PI / 2, -PI / 2 + TAU * clampf(p.anchor_left / maxf(p.anchor_duration, 0.01), 0.0, 1.0), 28, col, 4.0, true)
		ToolIcons.draw(self, ToolDefinition.Kind.ANCHOR, c, 22.0, col, 2.5)
		if ending:
			DrawKit.text(self, Vector2(r.position.x - 30, r.position.y - 54.0), "¡SE SUELTA! %.1f" % p.anchor_left, 16, col, r.size.x + 60)
	elif p.stage == UnstablePlatform.Stage.COLLAPSING:
		var pulse := 0.6 + 0.4 * absf(sin(_time * 10.0))
		var c := Vector2(0, r.position.y - 30.0)
		var tri := PackedVector2Array([c + Vector2(0, -17), c + Vector2(16, 12), c + Vector2(-16, 12)])
		DrawKit.poly(self, tri, Color(ViewPalette.WARN, pulse), DrawKit.OUTLINE, 3.0)
		DrawKit.text(self, c + Vector2(-20, 9), "!", 22, Color.WHITE, 40, HORIZONTAL_ALIGNMENT_CENTER, 4)
		var pts := DrawKit.rounded_rect(r.grow(3.0), 6.0, 3)
		pts.append(pts[0])
		draw_polyline(pts, Color(ViewPalette.WARN, pulse), 3.0, true)
