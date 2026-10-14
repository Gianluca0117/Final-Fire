@tool
class_name TouchActionButton
extends Control
## Botón táctil multitáctil que pulsa una acción del InputMap.
## Usa InputEventScreenTouch con índice de dedo, así se puede mantener
## "derecha" y pulsar "saltar" a la vez (los Button normales no lo permiten).
## Funciona igual en Android e iOS. En PC, el ratón emula toques
## (input_devices/pointing/emulate_touch_from_mouse).

@export var action: StringName = &"jump"
@export var label: String = "A":
	set(value):
		label = value
		queue_redraw()

var _finger := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and get_global_rect().has_point(event.position):
			_press(event.index)
		elif not event.pressed and event.index == _finger:
			_release()
	elif event is InputEventScreenDrag and event.index == _finger:
		# Si el dedo sale del botón, se suelta la acción.
		if not get_global_rect().grow(16.0).has_point(event.position):
			_release()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_release()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_release()


func _press(finger: int) -> void:
	_finger = finger
	Input.action_press(action)
	queue_redraw()


func _release() -> void:
	if _finger == -1:
		return
	_finger = -1
	Input.action_release(action)
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var pressed := _finger != -1
	var fill := Color(1, 1, 1, 0.35 if pressed else 0.18)
	draw_style_box(_box(fill), r)
	var font := get_theme_default_font()
	var font_size := int(size.y * 0.42)
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	if text_size.x > size.x * 0.8 and text_size.x > 0.0:
		font_size = int(font_size * size.x * 0.8 / text_size.x)
		text_size = font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var pos := Vector2((size.x - text_size.x) * 0.5, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5)
	draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, 0.9))


func _box(fill: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = Color(1, 1, 1, 0.6)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(int(min(size.x, size.y) * 0.5))
	return sb
