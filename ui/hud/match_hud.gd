class_name MatchHud
extends CanvasLayer
## Interfaz de partida: VIVOS n/N, cronómetro, pausa, cuenta atrás, avisos de peligro
## grandes, controles táctiles y resultados. Solo lee la partida y emite peticiones.

signal rematch_requested
signal menu_requested

var match_ctl: MatchController
var touch: TouchControls

var _alive: AliveIndicator
var _timer: Label
var _center: Label
var _banner: Label
var _banner_time := 0.0
var _pause_overlay: Control
var _results: Control
var _results_title: Label
var _results_list: Label


func _init() -> void:
	name = "HUD"
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS


## Conecta la interfaz a una partida. `show_touch`: mostrar controles táctiles.
func bind(p_match: MatchController, show_touch: bool) -> void:
	match_ctl = p_match
	_build(show_touch)
	_alive.participants = match_ctl.participants
	match_ctl.countdown_changed.connect(_on_countdown)
	match_ctl.match_finished.connect(_on_finished)
	match_ctl.participant_eliminated.connect(_on_eliminated)
	match_ctl.arena.hazard_warned.connect(_on_hazard)


func set_touch_visible(v: bool) -> void:
	touch.visible = v


func _process(delta: float) -> void:
	if match_ctl == null:
		return
	var t := int(match_ctl.elapsed)
	_timer.text = "%02d:%02d" % [floori(t / 60.0), t % 60]
	if match_ctl.arena.sudden_death:
		_timer.text += "  MUERTE SÚBITA"
		_timer.add_theme_color_override("font_color", Color("ff6a1a"))
	if _banner_time > 0.0:
		_banner_time -= delta
		_banner.modulate.a = clampf(_banner_time * 2.0, 0.0, 1.0)
		_banner.visible = _banner_time > 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).physical_keycode == KEY_TAB:
		touch.visible = not touch.visible


func toggle_pause() -> void:
	if match_ctl.phase == MatchController.Phase.FINISHED:
		return
	var paused := not get_tree().paused
	get_tree().paused = paused
	_pause_overlay.visible = paused


func _on_countdown(seconds_left: int) -> void:
	_center.visible = true
	_center.text = str(seconds_left) if seconds_left > 0 else "¡YA!"
	if seconds_left == 0:
		get_tree().create_timer(0.7).timeout.connect(func() -> void:
			if match_ctl.phase == MatchController.Phase.RUNNING:
				_center.visible = false)


func _on_hazard(kind: StringName, _area: Rect2, seconds: float) -> void:
	match kind:
		&"pool_rise":
			_show_banner("¡LA LAVA VA A SUBIR! (%d s)" % ceili(seconds), seconds + 0.5)
		&"sudden_death":
			_show_banner("¡MUERTE SÚBITA! LA LAVA NO PARA", 3.0)


func _on_eliminated(p: Participant, cause: StringName, by: Participant) -> void:
	var how := "cayó a la lava" if cause == &"lava" else "cayó fuera"
	if by:
		_show_banner("%s %s (empujón de %s)" % [p.display_name, how, by.display_name], 2.0)
	else:
		_show_banner("%s %s" % [p.display_name, how], 2.0)


func _on_finished(winner: Participant) -> void:
	_results_title.text = "¡Gana %s!" % winner.display_name if winner else "¡Empate!"
	if winner:
		_results_title.add_theme_color_override("font_color", winner.color.lightened(0.2))
	var ranking := match_ctl.participants.duplicate()
	ranking.sort_custom(func(a: Participant, b: Participant) -> bool: return a.place < b.place)
	var lines := PackedStringArray()
	for p in ranking:
		var detail := "" if p == winner else ("  · eliminado a los %d s" % int(p.eliminated_at))
		var kills := "1 eliminación" if p.eliminations == 1 else "%d eliminaciones" % p.eliminations
		lines.append("%dº  %s%s  · %s" % [p.place, p.display_name, detail, kills])
	_results_list.text = "\n".join(lines)
	_results.visible = true
	touch.visible = false


func _show_banner(text: String, seconds: float) -> void:
	_banner.text = text
	_banner_time = seconds
	_banner.visible = true


# ---------- construcción ----------

func _build(show_touch: bool) -> void:
	var safe := SafeAreaMargin.new()
	safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(root)

	touch = TouchControls.new()
	touch.visible = show_touch
	root.add_child(touch)

	_alive = AliveIndicator.new()
	root.add_child(_alive)

	_timer = _label("00:00", 30)
	_timer.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer.offset_left = -200
	_timer.offset_right = 200
	_timer.offset_bottom = 44
	root.add_child(_timer)

	var pause_btn := Button.new()
	pause_btn.text = "II"
	pause_btn.custom_minimum_size = Vector2(64, 56)
	pause_btn.add_theme_font_size_override("font_size", 26)
	pause_btn.focus_mode = Control.FOCUS_NONE
	pause_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_btn.offset_left = -64
	pause_btn.offset_bottom = 56
	pause_btn.pressed.connect(toggle_pause)
	root.add_child(pause_btn)

	_center = _label("", 110)
	_center.set_anchors_preset(Control.PRESET_CENTER)
	_center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center.offset_left = -300
	_center.offset_right = 300
	_center.offset_top = -120
	_center.offset_bottom = 60
	root.add_child(_center)

	_banner = _label("", 26)
	_banner.add_theme_color_override("font_color", Color("ffd23f"))
	_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.offset_left = -500
	_banner.offset_right = 500
	_banner.offset_top = 64
	_banner.offset_bottom = 110
	_banner.visible = false
	root.add_child(_banner)

	_pause_overlay = _overlay("Pausa", [["Continuar", toggle_pause], ["Salir al menú", _go_menu]])
	_pause_overlay.visible = false
	add_child(_pause_overlay)

	_results = _overlay("", [["Revancha", func() -> void: rematch_requested.emit()], ["Menú", _go_menu]])
	_results.visible = false
	add_child(_results)


func _go_menu() -> void:
	get_tree().paused = false
	menu_requested.emit()


func _label(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_constant_override("outline_size", maxi(4, int(font_size / 6.0)))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	return l


func _overlay(title: String, buttons: Array) -> Control:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	box.custom_minimum_size = Vector2(520, 0)
	box.offset_left = -260
	box.offset_right = 260
	box.offset_top = -200
	box.offset_bottom = 200
	dim.add_child(box)
	var t := _label(title, 52)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	if title == "":
		_results_title = t
		_results_list = _label("", 22)
		_results_list.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(_results_list)
	for b in buttons:
		var btn := Button.new()
		btn.text = b[0]
		btn.custom_minimum_size = Vector2(320, 64)
		btn.add_theme_font_size_override("font_size", 26)
		btn.pressed.connect(b[1])
		box.add_child(btn)
	return dim
