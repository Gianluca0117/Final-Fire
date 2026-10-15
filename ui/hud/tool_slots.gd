class_name ToolSlots
extends Control
## Ranura de herramienta de cada jugador humano local (bajo «VIVOS»): icono y nombre de la
## herramienta que lleva, tecla para usarla y cuenta atrás cuando va a caducar.
## Útil sobre todo en el modo de 2 jugadores con el mismo teclado.
## Solo se redibuja al cambiar la herramienta o mientras parpadea por caducar.

const KEYS := ["E", ","]

var match_ctl: MatchController
var _time := 0.0


func _init() -> void:
	custom_minimum_size = Vector2(300, 64)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	if match_ctl and match_ctl.tools.expiring:
		queue_redraw()


func _draw() -> void:
	if match_ctl == null:
		return
	var y := 0.0
	var i := 0
	for p in match_ctl.participants:
		if p.kind != Participant.Kind.HUMAN_LOCAL:
			continue
		var def := match_ctl.tools.held_by(p)
		UiTheme.draw_panel(self, Rect2(0, y, 300, 30), 10.0)
		DrawKit.text(self, Vector2(10, y + 21), p.display_name, 16, p.color.lightened(0.25), -1, HORIZONTAL_ALIGNMENT_LEFT, 4)
		if def:
			var a := 1.0
			if match_ctl.tools.expiring:
				a = 0.4 + 0.6 * absf(sin(_time * 9.0))
			var col := Color(ToolIcons.color_of(def.kind), a)
			ToolIcons.draw(self, def.kind, Vector2(56, y + 15), 20.0, col, 2.0)
			var text := def.display_name.to_upper()
			if not p.alive:
				text = "—"
			elif match_ctl.tools.expiring:
				text += "  caduca en %d s" % ceili(match_ctl.tools.phase_left())
			elif i < KEYS.size() and not OS.has_feature("mobile"):
				text += "  (tecla %s)" % KEYS[i]
			DrawKit.text(self, Vector2(74, y + 21), text, 15, col, -1, HORIZONTAL_ALIGNMENT_LEFT, 4)
		else:
			draw_rect(Rect2(46, y + 6, 20, 18), Color(1, 1, 1, 0.3), false, 1.5)
			DrawKit.text(self, Vector2(74, y + 21), "sin herramienta", 15, Color(1, 1, 1, 0.5), -1, HORIZONTAL_ALIGNMENT_LEFT, 4)
		y += 34.0
		i += 1
