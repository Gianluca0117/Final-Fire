@tool
class_name TouchToolButton
extends Control
## Botón táctil de herramienta con apuntado por arrastre (multitáctil):
## - Mantener pulsado = apuntar: el juego muestra el destino y lo resalta.
## - Arrastrar desde el botón = elegir la dirección (como un segundo joystick).
## - Soltar = usar la herramienta en esa dirección. Sin arrastrar, se usa la dirección
##   automática (arriba, inclinada hacia donde mueves el joystick).
## - Si el destino no es válido, la herramienta NO se gasta (lo decide la partida).
## Solo genera acciones del InputMap; no conoce al personaje ni a la herramienta.
## La interfaz le indica qué icono mostrar (tool_kind) o que no hay herramienta (-1).

@export var action: StringName = &"p1_tool"
@export var aim_prefix := "p1_aim_"
## Arrastre mínimo (fracción del radio) para fijar una dirección manual.
@export_range(0.0, 1.0) var drag_deadzone := 0.35

var tool_kind := -1:
	set(value):
		if tool_kind != value:
			tool_kind = value
			queue_redraw()
var expiring := false

var _finger := -1
var _drag := Vector2.ZERO
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_held() -> bool:
	return _finger != -1


func _process(delta: float) -> void:
	_time += delta
	if expiring or _finger != -1:
		queue_redraw()


func _radius() -> float:
	return minf(size.x, size.y) * 0.5 - 2.0


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not is_visible_in_tree():
		return
	var center := get_global_rect().get_center()
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and center.distance_to(event.position) <= _radius() + 10.0:
			_finger = event.index
			_set_drag(Vector2.ZERO)
			Input.action_press(action)
		elif not event.pressed and event.index == _finger:
			_release()
	elif event is InputEventScreenDrag and event.index == _finger:
		_set_drag(event.position - center)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE or (what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree()):
		if _finger != -1:
			_release()


func _release() -> void:
	_finger = -1
	if not Engine.is_editor_hint():
		Input.action_release(action)
		# El controlador recuerda la última dirección apuntada para el tick en que se suelta.
		_set_drag(Vector2.ZERO)
	queue_redraw()


func _set_drag(offset: Vector2) -> void:
	_drag = offset
	if Engine.is_editor_hint():
		return
	var r := maxf(_radius(), 1.0)
	var v := offset / r
	var dir := Vector2.ZERO if v.length() < drag_deadzone else v.normalized()
	_axis(aim_prefix + "left", aim_prefix + "right", dir.x)
	_axis(aim_prefix + "up", aim_prefix + "down", dir.y)
	queue_redraw()


static func _axis(neg: String, pos: String, value: float) -> void:
	if not InputMap.has_action(neg) or not InputMap.has_action(pos):
		return
	if value < -0.01:
		Input.action_press(neg, -value)
		Input.action_release(pos)
	elif value > 0.01:
		Input.action_press(pos, value)
		Input.action_release(neg)
	else:
		Input.action_release(neg)
		Input.action_release(pos)


func _draw() -> void:
	var c := size * 0.5
	var r := _radius()
	var has_tool := tool_kind >= 0
	var pressed := _finger != -1
	var a := 1.0
	if has_tool and expiring:
		a = 0.4 + 0.6 * absf(sin(_time * 9.0))
	draw_circle(c, r, Color(1, 1, 1, (0.3 if pressed else 0.14) if has_tool else 0.05))
	draw_arc(c, r, 0, TAU, 48, Color(1, 1, 1, (0.75 if has_tool else 0.3) * a), 3.0, true)
	if has_tool:
		ToolIcons.draw(self, tool_kind, c, r * 1.1, Color(ToolIcons.color_of(tool_kind), a), 3.0)
		# Contador de usos (como la ranura de la referencia)
		var badge := c + Vector2(r * 0.68, r * 0.68)
		draw_circle(badge, r * 0.24, Color(0.1, 0.08, 0.1, 0.9))
		draw_string(get_theme_default_font(), badge + Vector2(-r * 0.24, r * 0.1), "1", HORIZONTAL_ALIGNMENT_CENTER, r * 0.48, int(r * 0.3), Color.WHITE)
	else:
		draw_rect(Rect2(c - Vector2(r, r) * 0.42, Vector2(r, r) * 0.84), Color(1, 1, 1, 0.25), false, 2.0)
	if pressed and _drag.length() > r * drag_deadzone:
		var tip := c + _drag.limit_length(r * 1.6)
		draw_line(c, tip, Color(1, 1, 1, 0.8), 3.0, true)
		draw_circle(tip, r * 0.18, Color(1, 1, 1, 0.6))
