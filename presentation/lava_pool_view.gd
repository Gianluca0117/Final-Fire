class_name LavaPoolView
extends Node2D
## Lava inferior (estilo v1): un rectángulo con shader (oleaje, vetas, burbujas) y un
## resplandor encima. Solo se recoloca cuando cambia el nivel. Antes de subir, muestra en el
## mundo (capa de avisos) la línea hasta donde llegará y una cuenta atrás.

const LAVA_SHADER := preload("res://presentation/shaders/lava.gdshader")
const GLOW_SHADER := preload("res://presentation/shaders/glow.gdshader")
const DEPTH := 700.0

var _pool: LavaPool
var _lava: ColorRect
var _glow: ColorRect
var _overlay: Node2D
var _last_level := INF
var _warn_target := INF
var _warn_left := 0.0
var _time := 0.0


func _ready() -> void:
	_pool = get_parent() as LavaPool
	z_index = 10
	_glow = ColorRect.new()
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.material = ShaderMaterial.new()
	(_glow.material as ShaderMaterial).shader = GLOW_SHADER
	add_child(_glow)
	_lava = ColorRect.new()
	_lava.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = LAVA_SHADER
	mat.set_shader_parameter("size", Vector2(_pool.width, DEPTH))
	_lava.material = mat
	add_child(_lava)
	_overlay = Node2D.new()
	_overlay.z_index = 9
	_overlay.z_as_relative = false
	_overlay.draw.connect(_draw_warning)
	add_child(_overlay)
	_place()


## Lo llama la composición cuando la arena anuncia que la lava va a subir.
func warn_rise(target_y: float, seconds: float) -> void:
	_warn_target = target_y
	_warn_left = seconds


func _process(delta: float) -> void:
	_time += delta
	if not is_equal_approx(_pool.level_y, _last_level):
		_place()
	if _warn_left > 0.0:
		_warn_left -= delta
		_overlay.queue_redraw()
		if _warn_left <= 0.0:
			_overlay.queue_redraw()


func _place() -> void:
	_last_level = _pool.level_y
	var top := _pool.level_y - _pool.global_position.y - 14.0
	var half := _pool.width * 0.5
	_lava.position = Vector2(-half, top)
	_lava.size = Vector2(_pool.width, DEPTH)
	_glow.position = Vector2(-half, top - 90.0)
	_glow.size = Vector2(_pool.width, 100.0)


func _draw_warning() -> void:
	if _warn_left <= 0.0:
		return
	var y := _warn_target - _pool.global_position.y
	var half := _pool.width * 0.5
	var pulse := 0.6 + 0.4 * absf(sin(_time * 8.0))
	var x := -half
	while x < half:
		_overlay.draw_line(Vector2(x, y), Vector2(x + 26.0, y), Color(ViewPalette.LAVA_HOT, pulse), 4.0)
		x += 44.0
	for k in 7:
		var ax := -540.0 + k * 180.0
		var tip := Vector2(ax, y + 8.0)
		DrawKit.poly(_overlay, PackedVector2Array([tip, tip + Vector2(12, 18), tip + Vector2(-12, 18)]), Color(ViewPalette.WARN, pulse), DrawKit.OUTLINE, 2.0)
	DrawKit.text(_overlay, Vector2(-300, y - 12.0), "¡LA LAVA SUBE HASTA AQUÍ! %.1f" % maxf(_warn_left, 0.0), 22, ViewPalette.LAVA_HOT, 600)
