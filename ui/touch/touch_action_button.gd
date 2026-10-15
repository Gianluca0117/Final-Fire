@tool
class_name TouchActionButton
extends Control
## Botón táctil multitáctil que pulsa una acción del InputMap.
## Usa InputEventScreenTouch con índice de dedo, así se puede mantener el joystick
## y pulsar otro botón a la vez. Funciona igual en Android e iOS; en PC el ratón
## emula toques (input_devices/pointing/emulate_touch_from_mouse).

enum Icon { TEXT, JUMP, PUSH, SHIELD }

@export var action: StringName = &"p1_jump"
@export var icon: Icon = Icon.TEXT:
	set(value):
		icon = value
		queue_redraw()
@export var label: String = "":
	set(value):
		label = value
		queue_redraw()

var _finger := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_held() -> bool:
	return _finger != -1


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and _hit(event.position):
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
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE:
		_release()


func _hit(pos: Vector2) -> bool:
	# Área circular (los botones son redondos), un poco más grande que el dibujo.
	var r := get_global_rect()
	return r.get_center().distance_to(pos) <= minf(r.size.x, r.size.y) * 0.5 + 10.0


func _press(finger: int) -> void:
	_finger = finger
	Input.action_press(action)
	queue_redraw()


func _release() -> void:
	if _finger == -1:
		return
	_finger = -1
	if not Engine.is_editor_hint():
		Input.action_release(action)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - 2.0
	var pressed := _finger != -1
	draw_circle(c, radius, Color(1, 1, 1, 0.32 if pressed else 0.14))
	draw_arc(c, radius, 0, TAU, 48, Color(1, 1, 1, 0.75), 3.0, true)
	var fg := Color(1, 1, 1, 0.92)
	var u := radius * 0.5
	match icon:
		Icon.JUMP:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -u * 1.1), c + Vector2(u, 0), c + Vector2(u * 0.4, 0), c + Vector2(u * 0.4, u), c + Vector2(-u * 0.4, u), c + Vector2(-u * 0.4, 0), c + Vector2(-u, 0)]), fg)
		Icon.PUSH:
			# Mano abierta simplificada: palma y cuatro dedos
			draw_rect(Rect2(c + Vector2(-u * 0.55, -u * 0.1), Vector2(u * 1.1, u * 0.9)), fg)
			for i in 4:
				draw_rect(Rect2(c + Vector2(-u * 0.55 + i * u * 0.29, -u * 0.85), Vector2(u * 0.22, u * 0.8)), fg)
			draw_rect(Rect2(c + Vector2(-u * 0.95, u * 0.0), Vector2(u * 0.45, u * 0.22)), fg)
		Icon.SHIELD:
			# Escudo: borde superior curvo, lados rectos y punta abajo, con franja central.
			var pts := PackedVector2Array()
			for i in 9:
				var t := float(i) / 8.0
				pts.append(c + Vector2(lerpf(-0.8, 0.8, t) * u, (-0.8 - 0.18 * sin(t * PI)) * u))
			pts.append_array(PackedVector2Array([c + Vector2(u * 0.8, u * 0.1), c + Vector2(0, u * 1.0), c + Vector2(-u * 0.8, u * 0.1)]))
			draw_colored_polygon(pts, fg)
			draw_line(c + Vector2(0, -u * 0.85), c + Vector2(0, u * 0.85), Color(0, 0, 0, 0.35), u * 0.16)
		_:
			pass
	if label != "":
		var font := get_theme_default_font()
		var fs := int(radius * 0.32)
		var y := c.y + radius * 0.62 if icon != Icon.TEXT else c.y + fs * 0.35
		draw_string(font, Vector2(0, y), label, HORIZONTAL_ALIGNMENT_CENTER, size.x, fs, fg)
