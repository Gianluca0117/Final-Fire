extends CanvasLayer
## Interfaz táctil adaptable: los botones están anclados a las esquinas y se
## separan del área segura (muescas / barras del sistema en Android e iOS).
## Tab muestra/oculta los controles táctiles en PC.

@onready var _margin: MarginContainer = $Margin
@onready var _touch: Control = $Margin/Touch
@onready var _info: Label = $Margin/Info

const BASE_MARGIN := 24


func _ready() -> void:
	get_viewport().size_changed.connect(_apply_safe_area)
	_apply_safe_area()
	_info.text = "Final Fire · prueba de entorno  |  %s  |  Godot %s" % [
		OS.get_name(), Engine.get_version_info().string]


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event as InputEventKey).physical_keycode == KEY_TAB:
		_touch.visible = not _touch.visible


func _apply_safe_area() -> void:
	# get_display_safe_area() está en píxeles de pantalla; se convierte a las
	# coordenadas del lienzo (que dependen del estiramiento canvas_items).
	var vp := get_viewport()
	var visible_rect := vp.get_visible_rect()
	var screen := DisplayServer.screen_get_size()
	var safe := DisplayServer.get_display_safe_area()
	var left := BASE_MARGIN
	var top := BASE_MARGIN
	var right := BASE_MARGIN
	var bottom := BASE_MARGIN
	if OS.has_feature("mobile") and screen.x > 0 and screen.y > 0 and safe.size.x > 0:
		var ratio := visible_rect.size / Vector2(screen)
		left += int(safe.position.x * ratio.x)
		top += int(safe.position.y * ratio.y)
		right += int((screen.x - safe.end.x) * ratio.x)
		bottom += int((screen.y - safe.end.y) * ratio.y)
	_margin.add_theme_constant_override("margin_left", left)
	_margin.add_theme_constant_override("margin_top", top)
	_margin.add_theme_constant_override("margin_right", right)
	_margin.add_theme_constant_override("margin_bottom", bottom)
