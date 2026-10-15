class_name BackgroundView
extends Node2D
## Fondo de cueva provisional: degradado y resplandor de lava que crece al subir.

var arena: Arena


func _ready() -> void:
	z_index = -20


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var b := arena.bounds
	var bands := 12
	for i in bands:
		var t := float(i) / bands
		var c := Color("1a0f14").lerp(Color("4a1a12"), t * t)
		draw_rect(Rect2(b.position.x, b.position.y + b.size.y * t, b.size.x, b.size.y / bands + 1.0), c)
	# Estalactitas
	var x := b.position.x
	var k := 0
	while x < b.end.x:
		var h := 40.0 + fmod(k * 53.0, 90.0)
		draw_colored_polygon(PackedVector2Array([Vector2(x, -20), Vector2(x + 50, -20), Vector2(x + 25, h)]), Color("24161c"))
		x += 70.0
		k += 1
	if arena.lava_pool:
		var y := arena.lava_pool.level_y
		for i in 6:
			draw_rect(Rect2(b.position.x, y - 40.0 * (i + 1), b.size.x, 40.0), Color(1.0, 0.35, 0.1, 0.05))
