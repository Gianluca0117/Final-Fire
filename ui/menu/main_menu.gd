class_name MainMenu
extends Control
## Menú de inicio de la partida local (F1). Sin red: los rivales son maniquíes de
## prueba hasta que existan los bots (F4) y el multijugador LAN (F3).

signal start_requested(humans: int, dummies: int)

var _dummies := 3
var _dummies_label: Label


func _init() -> void:
	name = "MainMenu"
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _ready() -> void:
	theme = UiTheme.make()
	var bg := ColorRect.new()
	bg.color = Color("140a10")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var safe := SafeAreaMargin.new()
	safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(safe)
	var center := CenterContainer.new()
	safe.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	var title := _label("FINAL FIRE", 76, Color("ff8c26"))
	title.add_theme_constant_override("outline_size", 14)
	box.add_child(title)
	var parade := CharacterParade.new()
	box.add_child(parade)
	box.add_child(_label("Prototipo F2 · partida local con herramientas", 22, Color(1, 1, 1, 0.7)))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.add_child(_label("Maniquíes:", 26, Color.WHITE))
	row.add_child(_button("−", func() -> void: _set_dummies(_dummies - 1), Vector2(64, 60)))
	_dummies_label = _label("", 30, Color("ffd23f"))
	_dummies_label.custom_minimum_size = Vector2(40, 0)
	row.add_child(_dummies_label)
	row.add_child(_button("+", func() -> void: _set_dummies(_dummies + 1), Vector2(64, 60)))
	box.add_child(row)

	box.add_child(_touch_settings_row())

	var solo := _button("Jugar", func() -> void: start_requested.emit(1, _dummies), Vector2(420, 72))
	box.add_child(solo)
	if not OS.has_feature("mobile"):
		box.add_child(_button("2 jugadores (mismo teclado)", func() -> void: start_requested.emit(2, maxi(_dummies - 1, 0)), Vector2(420, 64)))
		box.add_child(_label("J1: A/D mover · W/Espacio saltar · F empujar · G protección · E herramienta\nJ2: ←/→ mover · ↑ saltar · tecla . empujar · tecla - protección · tecla , herramienta\nHerramienta: mantén para apuntar (ves el destino) y suelta para usarla\nEsc/P pausa · Tab muestra los controles táctiles", 16, Color(1, 1, 1, 0.6)))
	else:
		box.add_child(_label("Joystick: moverse · Flecha: saltar · Mano: empujar · Escudo: protección\nHerramienta: mantén y arrastra para apuntar, suelta para usarla", 18, Color(1, 1, 1, 0.6)))
	_set_dummies(_dummies)
	solo.grab_focus.call_deferred()


func _set_dummies(n: int) -> void:
	_dummies = clampi(n, 1, 5)
	_dummies_label.text = str(_dummies)


func _label(text: String, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l


func _button(text: String, cb: Callable, min_size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", 26)
	b.pressed.connect(cb)
	return b


## Fila de ajustes de los controles táctiles: tamaño y opacidad (se guardan en el dispositivo).
func _touch_settings_row() -> Control:
	UiSettings.load_settings()
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.add_child(_label("Controles:", 18, Color(1, 1, 1, 0.75)))
	var size_l := _label("", 18, Color("ffd23f"))
	var op_l := _label("", 18, Color("ffd23f"))
	size_l.custom_minimum_size = Vector2(118, 0)
	op_l.custom_minimum_size = Vector2(138, 0)
	var refresh := func() -> void:
		size_l.text = "tamaño %d%%" % roundi(UiSettings.touch_scale * 100.0)
		op_l.text = "opacidad %d%%" % roundi(UiSettings.touch_opacity * 100.0)
	var change := func(ds: float, dop: float) -> void:
		UiSettings.touch_scale = clampf(UiSettings.touch_scale + ds, 0.75, 1.3)
		UiSettings.touch_opacity = clampf(UiSettings.touch_opacity + dop, 0.25, 1.0)
		UiSettings.save_settings()
		refresh.call()
	row.add_child(_button("−", func() -> void: change.call(-0.05, 0.0), Vector2(44, 40)))
	row.add_child(size_l)
	row.add_child(_button("+", func() -> void: change.call(0.05, 0.0), Vector2(44, 40)))
	row.add_child(_button("−", func() -> void: change.call(0.0, -0.05), Vector2(44, 40)))
	row.add_child(op_l)
	row.add_child(_button("+", func() -> void: change.call(0.0, 0.05), Vector2(44, 40)))
	refresh.call()
	return row
