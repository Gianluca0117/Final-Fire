class_name TouchControls
extends Control
## Disposición de controles táctiles según la referencia visual: joystick abajo a la
## izquierda; salto (el más grande), empujar y protección abajo a la derecha.
## La ranura de herramienta llegará con las herramientas (F2).

var joystick: TouchJoystick
var jump: TouchActionButton
var push: TouchActionButton
var shield: TouchActionButton


func _init(prefix := "p1_") -> void:
	name = "TouchControls"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	joystick = TouchJoystick.new()
	joystick.action_left = StringName(prefix + "left")
	joystick.action_right = StringName(prefix + "right")
	_place(joystick, Control.PRESET_BOTTOM_LEFT, Vector2(230, 230), Vector2(0, 0))

	jump = _button(prefix + "jump", TouchActionButton.Icon.JUMP, "")
	_place(jump, Control.PRESET_BOTTOM_RIGHT, Vector2(170, 170), Vector2(0, 0))
	push = _button(prefix + "push", TouchActionButton.Icon.PUSH, "")
	_place(push, Control.PRESET_BOTTOM_RIGHT, Vector2(124, 124), Vector2(-190, -10))
	shield = _button(prefix + "shield", TouchActionButton.Icon.SHIELD, "")
	_place(shield, Control.PRESET_BOTTOM_RIGHT, Vector2(112, 112), Vector2(-20, -190))


func _button(action: String, icon: TouchActionButton.Icon, text: String) -> TouchActionButton:
	var b := TouchActionButton.new()
	b.action = StringName(action)
	b.icon = icon
	b.label = text
	return b


## Ancla `c` a una esquina con tamaño fijo y desplazamiento hacia dentro.
func _place(c: Control, preset: Control.LayoutPreset, size_px: Vector2, offset: Vector2) -> void:
	add_child(c)
	c.set_anchors_preset(preset)
	var right := preset == Control.PRESET_BOTTOM_RIGHT
	c.offset_left = (-size_px.x if right else 0.0) + offset.x
	c.offset_right = (0.0 if right else size_px.x) + offset.x
	c.offset_top = -size_px.y + offset.y
	c.offset_bottom = offset.y
	c.grow_horizontal = Control.GROW_DIRECTION_BEGIN if right else Control.GROW_DIRECTION_END
	c.grow_vertical = Control.GROW_DIRECTION_BEGIN
