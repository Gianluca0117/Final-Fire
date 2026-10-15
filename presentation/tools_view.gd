class_name ToolsView
extends Node2D
## Vista provisional de la herramienta compartida. Solo lee el estado de ToolSystem:
## - aviso previo: haz de luz, silueta, nombre y cuenta atrás en el punto de aparición;
## - en el suelo: icono sobre un pedestal brillante (parpadea al caducar);
## - en posesión: icono sobre la cabeza del portador con anillo de su color;
## - vista previa del destino para jugadores humanos (resaltada mientras apuntan);
## - cuerda del Gancho mientras tira.

const REASONS := {
	&"no_platform": "sin plataforma cerca",
	&"already_anchored": "ya está anclada",
	&"no_surface": "sin superficie",
	&"out_of_range": "fuera de alcance",
	&"out_of_arena": "fuera del escenario",
	&"unsafe_surface": "superficie no válida",
}

var match_ctl: MatchController
var _time := 0.0


func _init(p_match: MatchController) -> void:
	match_ctl = p_match
	name = "ToolsView"
	z_index = 8


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var tools := match_ctl.tools
	var font := ThemeDB.fallback_font
	var def := tools.current
	if def:
		var col := ToolIcons.color_of(def.kind)
		match tools.state:
			ToolSystem.State.ANNOUNCED:
				var total := maxf(tools.phase.announce_warning if tools.phase else 1.0, 0.01)
				var p := tools.position
				var pulse := 0.5 + 0.5 * sin(_time * 10.0)
				draw_rect(Rect2(p.x - 14, -40, 28, p.y + 40), Color(col, 0.08 + 0.08 * pulse))
				draw_arc(p, 30.0, 0, TAU, 32, Color(col, 0.35), 3.0, true)
				draw_arc(p, 30.0, -PI / 2, -PI / 2 + TAU * clampf(tools.time_left / total, 0.0, 1.0), 32, col, 4.0, true)
				ToolIcons.draw(self, def.kind, p, 34.0, Color(col, 0.4 + 0.4 * pulse))
				draw_string(font, p + Vector2(-80, -44), "¡%s! %.1f" % [ToolIcons.short_name(def), maxf(tools.time_left, 0.0)], HORIZONTAL_ALIGNMENT_CENTER, 160, 18, Color(col, 0.95))
			ToolSystem.State.AVAILABLE:
				var p := tools.position + Vector2(0, sin(_time * 3.0) * 4.0)
				var a := 1.0 if not tools.expiring else 0.35 + 0.65 * absf(sin(_time * 9.0))
				draw_circle(tools.position + Vector2(0, 22), 24.0, Color(col, 0.18))
				draw_circle(p, 24.0, Color(0, 0, 0, 0.45 * a))
				draw_arc(p, 24.0, 0, TAU, 32, Color(col, a), 3.0, true)
				ToolIcons.draw(self, def.kind, p, 32.0, Color(col, a))
				if tools.expiring:
					draw_string(font, p + Vector2(-40, -32), "%d" % ceili(tools.phase_left()), HORIZONTAL_ALIGNMENT_CENTER, 80, 18, Color(1, 0.5, 0.3))
			ToolSystem.State.HELD:
				var h := tools.holder
				if h and h.alive:
					var head := h.fighter.global_position + Vector2(0, -h.fighter.stats.body_size.y * 0.5 - 34)
					var a := 1.0 if not tools.expiring else 0.35 + 0.65 * absf(sin(_time * 9.0))
					draw_circle(head, 15.0, Color(0, 0, 0, 0.55 * a))
					draw_arc(head, 15.0, 0, TAU, 24, Color(h.color, a), 3.0, true)
					ToolIcons.draw(self, def.kind, head, 20.0, Color(col, a), 2.0)
					if tools.expiring:
						draw_string(font, head + Vector2(18, 6), "%d" % ceili(tools.phase_left()), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 0.5, 0.3))
					if h.kind == Participant.Kind.HUMAN_LOCAL and tools.previews.has(h):
						_draw_preview(h, tools.previews[h], def, font)

	# Cuerda del Gancho mientras tira
	for p in match_ctl.participants:
		var f := p.fighter
		if f and f.is_alive() and f.is_hooking():
			draw_line(f.global_position, f.hook_point, Color("d9c08a"), 3.0, true)
			ToolIcons.draw(self, ToolDefinition.Kind.HOOK, f.hook_point, 18.0, ToolIcons.color_of(ToolDefinition.Kind.HOOK), 2.0)


func _draw_preview(h: Participant, t: ToolTarget, def: ToolDefinition, font: Font) -> void:
	var f := h.fighter
	var strong := f.aiming
	var a := 0.95 if strong else 0.45
	var from := f.global_position
	if t.valid:
		var col := Color(0.55, 1.0, 0.6, a)
		if def.kind == ToolDefinition.Kind.HOOK:
			_dashed(from, t.point, col, 3.0 if strong else 2.0)
			draw_arc(t.point, 12.0, 0, TAU, 20, col, 3.0, true)
			draw_circle(t.point, 4.0, col)
		else:
			var plat := t.body as UnstablePlatform
			if plat:
				var xf := plat.global_transform
				var hs := plat.size * 0.5 + Vector2(6, 6)
				var pts := PackedVector2Array([xf * Vector2(-hs.x, -hs.y), xf * Vector2(hs.x, -hs.y), xf * Vector2(hs.x, hs.y), xf * Vector2(-hs.x, hs.y), xf * Vector2(-hs.x, -hs.y)])
				draw_polyline(pts, Color(ToolIcons.color_of(def.kind), a), 3.0 if strong else 2.0, true)
				draw_string(font, plat.global_position + Vector2(-60, -30), "ANCLAR", HORIZONTAL_ALIGNMENT_CENTER, 120, 16, Color(ToolIcons.color_of(def.kind), a))
	else:
		var col := Color(1.0, 0.35, 0.3, a)
		if def.kind == ToolDefinition.Kind.HOOK:
			var end := from + t.aim.normalized() * 110.0
			_dashed(from, end, col, 2.0)
			draw_line(end + Vector2(-7, -7), end + Vector2(7, 7), col, 3.0)
			draw_line(end + Vector2(-7, 7), end + Vector2(7, -7), col, 3.0)
		if strong or def.kind == ToolDefinition.Kind.ANCHOR:
			draw_string(font, from + Vector2(-90, 48), REASONS.get(t.reason, "no válido"), HORIZONTAL_ALIGNMENT_CENTER, 180, 14, col)


func _dashed(a: Vector2, b: Vector2, col: Color, width: float) -> void:
	var length := a.distance_to(b)
	var dir := (b - a) / maxf(length, 0.001)
	var d := 0.0
	while d < length:
		draw_line(a + dir * d, a + dir * minf(d + 12.0, length), col, width, true)
		d += 20.0
