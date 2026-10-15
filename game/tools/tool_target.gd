class_name ToolTarget
extends RefCounted
## Resultado de buscar un objetivo para una herramienta. Lo calcula la autoridad al usarla
## y también cada tick para la vista previa del portador.

var valid := false
## Punto de destino (Gancho) o centro de la plataforma (Ancla).
var point := Vector2.ZERO
var body: Object = null
## Motivo si no es válido: &"no_platform", &"already_anchored", &"no_surface",
## &"out_of_range", &"out_of_arena", &"unsafe_surface".
var reason: StringName = &""
## Dirección en la que se buscó (para dibujar la línea aunque no haya destino).
var aim := Vector2.UP


static func ok(p_point: Vector2, p_body: Object, p_aim := Vector2.UP) -> ToolTarget:
	var t := ToolTarget.new()
	t.valid = true
	t.point = p_point
	t.body = p_body
	t.aim = p_aim
	return t


static func fail(p_reason: StringName, p_aim := Vector2.UP) -> ToolTarget:
	var t := ToolTarget.new()
	t.reason = p_reason
	t.aim = p_aim
	return t
