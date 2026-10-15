class_name InputFrame
extends RefCounted
## Acciones de un participante durante un tick de simulación.
## Es el único contrato entre controladores (humano, maniquí, bot, red) y el personaje:
## todos producen lo mismo y el personaje aplica las mismas reglas.

var tick := 0
var move_x := 0.0           ## -1 (izquierda) .. 1 (derecha)
var jump_pressed := false   ## se pulsó salto en este tick
var jump_held := false      ## salto mantenido (salto de altura variable)
var push_pressed := false
var shield_pressed := false


static func idle(p_tick := 0) -> InputFrame:
	var f := InputFrame.new()
	f.tick = p_tick
	return f


## Devuelve una copia con valores dentro de rango. La autoridad la usará para validar
## lo que llegue por red (F3).
func sanitized() -> InputFrame:
	var f := InputFrame.new()
	f.tick = tick
	f.move_x = 0.0 if is_nan(move_x) else clampf(move_x, -1.0, 1.0)
	f.jump_pressed = jump_pressed
	f.jump_held = jump_held or jump_pressed
	f.push_pressed = push_pressed
	f.shield_pressed = shield_pressed
	return f
