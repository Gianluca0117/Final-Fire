@tool
class_name TouchJoystick
extends Control
## Joystick virtual FLOTANTE y multitáctil. El Control es la zona donde se puede apoyar el
## pulgar; la base aparece donde toca. En reposo solo dibuja un aro tenue en `rest_center`.
## Convierte la inclinación horizontal en las acciones de moverse (intensidad analógica).

@export var action_left: StringName = &"p1_left"
@export var action_right: StringName = &"p1_right"
@export_range(0.0, 0.9) var deadzone := 0.2
## Radio visual de la base (px).
@export var radius := 58.0
## Posición del aro de reposo dentro de la zona.
var rest_center := Vector2(110, 220)

var _finger := -1
var _base := Vector2.ZERO    # centro de la base (local), donde se apoyó el dedo
var _knob := Vector2.ZERO    # -1..1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func value() -> Vector2:
	return _knob


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not is_visible_in_tree():
		return
	var rect := get_global_rect()
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and rect.has_point(event.position):
			_finger = event.index
			_base = event.position - rect.position
			_update(Vector2.ZERO)
		elif not event.pressed and event.index == _finger:
			_finger = -1
			_update(Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == _finger:
		_update(event.position - rect.position - _base)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE or (what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree()):
		_finger = -1
		_update(Vector2.ZERO)


func _update(offset: Vector2) -> void:
	_knob = (offset / maxf(radius, 1.0)).limit_length(1.0)
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
	var active := _finger != -1
	var op := UiSettings.touch_opacity
	if not active:
		# Reposo: aro tenue y pequeño (indica dónde va el pulgar, casi no tapa nada)
		draw_arc(rest_center, radius * 0.75, 0, TAU, 40, Color(DrawKit.OUTLINE, 0.5 * op), 5.0, true)
		draw_arc(rest_center, radius * 0.75, 0, TAU, 40, Color(1, 1, 1, 0.45 * op), 2.0, true)
		draw_circle(rest_center, radius * 0.25, Color(1, 1, 1, 0.18 * op))
		return
	TouchStyle.ring(self, _base, radius, true, op)
	for d in [Vector2.LEFT, Vector2.RIGHT]:
		var tip: Vector2 = _base + d * radius * 0.78
		var side: Vector2 = Vector2(0, radius * 0.12)
		DrawKit.poly(self, PackedVector2Array([tip, tip - d * radius * 0.16 + side, tip - d * radius * 0.16 - side]), Color(1, 1, 1, 0.8 * op), DrawKit.OUTLINE, 2.0)
	var k := _base + _knob * radius * 0.6
	DrawKit.circle(self, k, radius * 0.36, Color(1, 0.75, 0.4, 0.75 * op + 0.15), DrawKit.OUTLINE, 3.0)
	draw_arc(k, radius * 0.36, PI * 1.1, PI * 1.6, 10, Color(1, 1, 1, 0.8), 2.0, true)
