@tool
class_name TouchJoystick
extends Control
## Joystick virtual multitáctil. Convierte la inclinación horizontal en las acciones
## de moverse (con intensidad analógica). Solo genera acciones del InputMap.

@export var action_left: StringName = &"p1_left"
@export var action_right: StringName = &"p1_right"
@export_range(0.0, 0.9) var deadzone := 0.2

var _finger := -1
var _knob := Vector2.ZERO   # -1..1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func value() -> Vector2:
	return _knob


func _radius() -> float:
	return minf(size.x, size.y) * 0.5 - 4.0


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not is_visible_in_tree():
		return
	var center := get_global_rect().get_center()
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and center.distance_to(event.position) <= _radius() * 1.35:
			_finger = event.index
			_update(event.position - center)
		elif not event.pressed and event.index == _finger:
			_finger = -1
			_update(Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == _finger:
		_update(event.position - center)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE or (what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree()):
		_finger = -1
		_update(Vector2.ZERO)


func _update(offset: Vector2) -> void:
	_knob = (offset / maxf(_radius(), 1.0)).limit_length(1.0)
	if Engine.is_editor_hint():
		return
	var x := _knob.x
	var strength := clampf((absf(x) - deadzone) / (1.0 - deadzone), 0.0, 1.0)
	if x < 0.0 and strength > 0.0:
		Input.action_press(action_left, strength)
		Input.action_release(action_right)
	elif x > 0.0 and strength > 0.0:
		Input.action_press(action_right, strength)
		Input.action_release(action_left)
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var r := _radius()
	draw_circle(c, r, Color(1, 1, 1, 0.12))
	draw_arc(c, r, 0, TAU, 48, Color(1, 1, 1, 0.7), 3.0, true)
	var fg := Color(1, 1, 1, 0.75)
	for d in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var tip: Vector2 = c + d * r * 0.8
		var side: Vector2 = Vector2(d.y, d.x) * r * 0.12
		draw_colored_polygon(PackedVector2Array([tip, tip - d * r * 0.16 + side, tip - d * r * 0.16 - side]), fg)
	draw_circle(c + _knob * r * 0.55, r * 0.33, Color(1, 1, 1, 0.45 if _finger != -1 else 0.3))
	draw_arc(c + _knob * r * 0.55, r * 0.33, 0, TAU, 32, Color(1, 1, 1, 0.8), 2.0, true)
