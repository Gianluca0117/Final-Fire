class_name ToolIcons
## Iconos provisionales de las herramientas, dibujados con formas (sin texturas).
## Los usan la vista del mundo, el HUD y el botón táctil.

const COLORS := {
	ToolDefinition.Kind.ANCHOR: Color("6fd3ff"),
	ToolDefinition.Kind.HOOK: Color("ffcf5a"),
}


static func color_of(kind: ToolDefinition.Kind) -> Color:
	return COLORS.get(kind, Color.WHITE)


## Dibuja el icono de `kind` centrado en `c` con tamaño `s` (alto aproximado), con contorno
## oscuro debajo (estilo v1) para que se lea sobre cualquier fondo.
static func draw(ci: CanvasItem, kind: ToolDefinition.Kind, c: Vector2, s: float, col: Color, width := 3.0, outline := true) -> void:
	if outline:
		_strokes(ci, kind, c, s, Color(DrawKit.OUTLINE, col.a), width + 3.0)
	_strokes(ci, kind, c, s, col, width)


static func _strokes(ci: CanvasItem, kind: ToolDefinition.Kind, c: Vector2, s: float, col: Color, width: float) -> void:
	var u := s * 0.5
	match kind:
		ToolDefinition.Kind.ANCHOR:
			ci.draw_arc(c + Vector2(0, -u * 0.78), u * 0.2, 0, TAU, 16, col, width, true)
			ci.draw_line(c + Vector2(0, -u * 0.58), c + Vector2(0, u * 0.8), col, width, true)
			ci.draw_line(c + Vector2(-u * 0.38, -u * 0.32), c + Vector2(u * 0.38, -u * 0.32), col, width, true)
			ci.draw_arc(c + Vector2(0, u * 0.12), u * 0.68, 0.12 * PI, 0.88 * PI, 20, col, width, true)
			for sx in [-1.0, 1.0]:
				var tip := c + Vector2(sx * u * 0.66, u * 0.3)
				ci.draw_line(tip, tip + Vector2(sx * u * 0.18, -u * 0.22), col, width, true)
		ToolDefinition.Kind.HOOK:
			ci.draw_arc(c + Vector2(u * 0.22, -u * 0.82), u * 0.16, 0, TAU, 12, col, width, true)
			ci.draw_line(c + Vector2(u * 0.22, -u * 0.66), c + Vector2(u * 0.22, u * 0.3), col, width, true)
			ci.draw_arc(c + Vector2(-u * 0.14, u * 0.3), u * 0.36, 0, PI, 16, col, width, true)
			ci.draw_line(c + Vector2(-u * 0.5, u * 0.3), c + Vector2(-u * 0.5, -u * 0.05), col, width, true)
			ci.draw_line(c + Vector2(-u * 0.5, -u * 0.05), c + Vector2(-u * 0.3, u * 0.12), col, width, true)


static func short_name(def: ToolDefinition) -> String:
	return def.display_name.to_upper() if def else ""
