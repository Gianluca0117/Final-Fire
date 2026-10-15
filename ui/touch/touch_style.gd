class_name TouchStyle
## Aspecto común de los controles táctiles (estilo v1): relleno oscuro y aro doble
## (contorno oscuro + aro claro). En reposo son más transparentes para no tapar el suelo
## ni los avisos; al pulsar se iluminan en cálido.


static func ring(ci: CanvasItem, c: Vector2, r: float, pressed: bool, alpha := 1.0) -> void:
	ci.draw_circle(c, r, Color(1.0, 0.62, 0.25, 0.32 * alpha) if pressed else Color(0.08, 0.04, 0.06, 0.22 * alpha))
	ci.draw_arc(c, r, 0, TAU, 48, Color(DrawKit.OUTLINE, 0.75 * alpha), 6.0, true)
	ci.draw_arc(c, r, 0, TAU, 48, Color(1, 1, 1, (0.9 if pressed else 0.5) * alpha), 2.5, true)
