class_name SafeAreaMargin
extends MarginContainer
## Margen que respeta el área segura (muescas, isla dinámica, barras del sistema)
## en Android e iOS. En PC solo aplica el margen base.

@export var base_margin := 20


func _ready() -> void:
	get_viewport().size_changed.connect(_apply)
	_apply()


func _apply() -> void:
	var visible_rect := get_viewport().get_visible_rect()
	var screen := DisplayServer.screen_get_size()
	var safe := DisplayServer.get_display_safe_area()
	var m := [base_margin, base_margin, base_margin, base_margin]  # izq, arriba, der, abajo
	if OS.has_feature("mobile") and screen.x > 0 and screen.y > 0 and safe.size.x > 0:
		# El área segura está en píxeles de pantalla; se pasa a coordenadas del lienzo.
		var ratio := visible_rect.size / Vector2(screen)
		m[0] += int(safe.position.x * ratio.x)
		m[1] += int(safe.position.y * ratio.y)
		m[2] += int((screen.x - safe.end.x) * ratio.x)
		m[3] += int((screen.y - safe.end.y) * ratio.y)
	add_theme_constant_override("margin_left", m[0])
	add_theme_constant_override("margin_top", m[1])
	add_theme_constant_override("margin_right", m[2])
	add_theme_constant_override("margin_bottom", m[3])
