class_name TouchControls
extends Control
## Controles táctiles (estilo v2): ocupan poco a la vista y tienen áreas de toque cómodas.
## - Joystick flotante: aparece donde apoyas el pulgar en la zona izquierda; en reposo solo
##   se ve un aro tenue.
## - Botones a la derecha: el dibujo es ~70 % del área táctil; las áreas no se solapan.
## - Tamaño y opacidad ajustables (UiSettings, desde el menú).

## Centros (desde la esquina inferior derecha) y radios del ÁREA TÁCTIL a escala 1.
const JUMP := [Vector2(-83, -83), 75.0]
const PUSH := [Vector2(-215, -56), 58.0]
const SHIELD := [Vector2(-56, -215), 52.0]
const TOOL := [Vector2(-205, -200), 55.0]

var joystick: TouchJoystick
var jump: TouchActionButton
var push: TouchActionButton
var shield: TouchActionButton
var tool: TouchToolButton


func _init(prefix := "p1_") -> void:
	name = "TouchControls"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiSettings.load_settings()
	var s := UiSettings.touch_scale

	# Zona del joystick: mitad izquierda inferior de la pantalla.
	joystick = TouchJoystick.new()
	joystick.action_left = StringName(prefix + "left")
	joystick.action_right = StringName(prefix + "right")
	joystick.radius = 58.0 * s
	add_child(joystick)
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.offset_left = 0
	joystick.offset_right = 430
	joystick.offset_top = -330
	joystick.offset_bottom = 0
	joystick.grow_vertical = Control.GROW_DIRECTION_BEGIN
	joystick.rest_center = Vector2(110 * s, 330 - 110 * s)

	jump = _button(prefix + "jump", TouchActionButton.Icon.JUMP)
	_place(jump, JUMP, s)
	push = _button(prefix + "push", TouchActionButton.Icon.PUSH)
	_place(push, PUSH, s)
	shield = _button(prefix + "shield", TouchActionButton.Icon.SHIELD)
	_place(shield, SHIELD, s)
	tool = TouchToolButton.new()
	tool.action = StringName(prefix + "tool")
	tool.aim_prefix = prefix + "aim_"
	_place(tool, TOOL, s)


func _button(action: String, icon: TouchActionButton.Icon) -> TouchActionButton:
	var b := TouchActionButton.new()
	b.action = StringName(action)
	b.icon = icon
	return b


## Coloca el control con su área táctil circular centrada en `spec[0]` (desde la esquina
## inferior derecha) y radio `spec[1]`, ambos multiplicados por la escala elegida.
func _place(c: Control, spec: Array, s: float) -> void:
	add_child(c)
	var center: Vector2 = spec[0] * s
	var r: float = spec[1] * s
	c.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	c.offset_left = center.x - r
	c.offset_right = center.x + r
	c.offset_top = center.y - r
	c.offset_bottom = center.y + r
	c.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	c.grow_vertical = Control.GROW_DIRECTION_BEGIN
