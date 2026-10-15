class_name ToolSlots
extends Control
## Ranura de herramienta de cada jugador humano local (bajo «VIVOS»): icono y nombre de la
## herramienta que lleva, tecla para usarla y cuenta atrás cuando va a caducar.
## Útil sobre todo en el modo de 2 jugadores con el mismo teclado.

const KEYS := ["E", ","]

var match_ctl: MatchController
var _time := 0.0


func _init() -> void:
	custom_minimum_size = Vector2(300, 64)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if match_ctl == null:
		return
	var font := get_theme_default_font()
	var y := 0.0
	var i := 0
	for p in match_ctl.participants:
		if p.kind != Participant.Kind.HUMAN_LOCAL:
			continue
		var def := match_ctl.tools.held_by(p)
		draw_rect(Rect2(0, y, 300, 28), Color(0, 0, 0, 0.4))
		draw_string(font, Vector2(10, y + 20), p.display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, p.color.lightened(0.2))
		if def:
			var a := 1.0
			if match_ctl.tools.expiring:
				a = 0.4 + 0.6 * absf(sin(_time * 9.0))
			var col := Color(ToolIcons.color_of(def.kind), a)
			ToolIcons.draw(self, def.kind, Vector2(56, y + 14), 20.0, col, 2.0)
			var text := def.display_name.to_upper()
			if not p.alive:
				text = "—"
			elif match_ctl.tools.expiring:
				text += "  caduca en %d s" % ceili(match_ctl.tools.phase_left())
			elif i < KEYS.size() and not OS.has_feature("mobile"):
				text += "  (tecla %s)" % KEYS[i]
			draw_string(font, Vector2(74, y + 20), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, col)
		else:
			draw_rect(Rect2(46, y + 4, 20, 20), Color(1, 1, 1, 0.3), false, 1.5)
			draw_string(font, Vector2(74, y + 20), "sin herramienta", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1, 0.45))
		y += 32.0
		i += 1
