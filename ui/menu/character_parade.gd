class_name CharacterParade
extends Control
## Las seis variantes del personaje en reposo, para el menú. Usa las mismas hojas de
## sprites que el juego (y, de paso, las genera antes de empezar la partida).

var _looks: Array[CharacterLook] = []
var _t := 0.0


func _init() -> void:
	custom_minimum_size = Vector2(420, 92)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	var rules: MatchRules = load("res://data/rules/local_match.tres")
	for i in 6:
		var l := CharacterLook.for_index(i, rules.colors[i])
		_looks.append(l)
		CharacterSprites.request(get_tree(), l)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var step := size.x / 6.0
	var idle: Array = CharacterAnimations.CLIPS["idle"]
	for i in 6:
		var tex := CharacterSprites.sheet(_looks[i])
		if tex == null:
			continue
		var c := Vector2(step * (i + 0.5), 52)
		draw_colored_polygon(DrawKit.ellipse(c + Vector2(0, 31), 18.0, 4.0, 10), Color(0, 0, 0, 0.35))
		var frame: int = CharacterAnimations.CLIPS["blink"][0] if fmod(_t + i * 1.3, 4.0) < 0.12 else idle[int(_t * 5.0 + i) % 4]
		draw_texture_rect_region(tex, Rect2(c - CharacterSprites.ORIGIN * 1.1, CharacterSprites.CELL * 1.1), CharacterSprites.region(frame))
