class_name LavaPoolView
extends Node2D
## Lava inferior con oleaje.

var _pool: LavaPool
var _time := 0.0


func _ready() -> void:
	_pool = get_parent() as LavaPool
	z_index = 10


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	# La vista dibuja en coordenadas locales del LavaPool.
	var top := _pool.level_y - _pool.global_position.y
	var half := _pool.width * 0.5
	var pts := PackedVector2Array()
	var x := -half
	while x <= half:
		pts.append(Vector2(x, top + sin(_time * 2.5 + x * 0.03) * 5.0))
		x += 16.0
	pts.append(Vector2(half, top + 1200.0))
	pts.append(Vector2(-half, top + 1200.0))
	draw_colored_polygon(pts, ViewPalette.LAVA)
	draw_rect(Rect2(Vector2(-half, top + 18.0), Vector2(_pool.width, 1200.0)), ViewPalette.LAVA_DEEP)
	for i in 14:
		var bx := -half + fmod(i * 137.0 + _time * 25.0 * (1 + i % 3), _pool.width)
		var by := top + 8.0 + fmod(i * 23.0, 20.0)
		draw_circle(Vector2(bx, by), 3.0 + (i % 3), Color(ViewPalette.LAVA_HOT, 0.6))
