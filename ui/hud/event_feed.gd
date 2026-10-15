class_name EventFeed
extends Control
## Avisos breves y discretos (sustituyen a los mensajes grandes en el centro): una pila de
## hasta 3 líneas pequeñas bajo el marcador, con las cabezas de los personajes e iconos.
## Cada aviso dura 2,5 s y se desvanece. Solo se redibuja mientras hay avisos.

const MAX := 3
const LIFE := 2.6
const HEAD := Rect2(-26, -47, 52, 50)
const SIZE := 17          ## cuerpo de letra de los avisos
const ROW := 34.0
const HEAD_SCALE := 0.62

var _items: Array[Dictionary] = []


func _init() -> void:
	custom_minimum_size = Vector2(300, 90)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## parts: lista de String, Participant (cabeza), StringName de icono (&"flame", &"anchor", &"hook", &"warn").
func push(parts: Array, accent := ViewPalette.UI_TEXT) -> void:
	_items.push_front({"parts": parts, "t": 0.0, "accent": accent})
	if _items.size() > MAX:
		_items.resize(MAX)
	queue_redraw()


func _process(delta: float) -> void:
	if _items.is_empty():
		return
	for it in _items:
		it.t += delta
	_items = _items.filter(func(it: Dictionary) -> bool: return it.t < LIFE)
	queue_redraw()


func _draw() -> void:
	var font := UiFonts.display()
	var y := 0.0
	for it in _items:
		var a := clampf((LIFE - it.t) / 0.4, 0.0, 1.0) * clampf(it.t / 0.12, 0.0, 1.0)
		var x := 10.0
		var widths := []
		var total := 20.0
		for p in it.parts:
			var w := 26.0
			if p is String:
				w = font.get_string_size(p, HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE).x + 6.0
			elif p is Participant:
				w = 30.0 + font.get_string_size(p.display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE).x + 6.0
			widths.append(w)
			total += w
		var box := Rect2(0, y, total, ROW - 4.0)
		draw_colored_polygon(DrawKit.rounded_rect(box, 10.0, 3), Color(ViewPalette.UI_PANEL, 0.8 * a))
		draw_rect(Rect2(0, y + 5, 3, ROW - 14.0), Color(it.accent, a))
		for i in it.parts.size():
			var p = it.parts[i]
			var cy := (ROW - 4.0) * 0.5 + y
			if p is String:
				_text(font, Vector2(x, cy + 6.0), p, Color(it.accent, a), a)
			elif p is Participant:
				_head(p, Vector2(x + 13, cy + 1), a)
				_text(font, Vector2(x + 30, cy + 6.0), p.display_name, Color(p.color.lightened(0.25), a), a)
			elif p is StringName:
				_icon(p, Vector2(x + 11, cy), a)
			x += widths[i]
		y += ROW


func _head(p: Participant, c: Vector2, a: float) -> void:
	var look := CharacterLook.for_index(p.id, p.color)
	var tex := CharacterSprites.sheet(look)
	if tex == null:
		draw_circle(c, 11.0, Color(p.color, a))
		return
	# Siempre la cabeza de pie (la pose «dead» está tumbada); los eliminados, apagados.
	var frame: int = CharacterAnimations.CLIPS["idle"][0]
	var tint := Color(1, 1, 1, a) if p.alive else Color(0.55, 0.5, 0.5, a)
	var cell := CharacterSprites.region(frame)
	var src := Rect2(cell.position + (CharacterSprites.ORIGIN + HEAD.position) * CharacterSprites.SCALE, HEAD.size * CharacterSprites.SCALE)
	draw_texture_rect_region(tex, Rect2(c + (HEAD.position + Vector2(0, 22)) * HEAD_SCALE, HEAD.size * HEAD_SCALE), src, tint)


func _text(font: Font, pos: Vector2, text: String, col: Color, a: float) -> void:
	draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE, 5, Color(DrawKit.OUTLINE, a))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE, col)


func _icon(kind: StringName, c: Vector2, a: float) -> void:
	match kind:
		&"flame":
			var pts := PackedVector2Array([c + Vector2(0, -10), c + Vector2(6, -2), c + Vector2(7, 4), c + Vector2(0, 9), c + Vector2(-7, 4), c + Vector2(-6, -3), c + Vector2(-2, 0)])
			DrawKit.poly(self, pts, Color(ViewPalette.LAVA, a), Color(DrawKit.OUTLINE, a), 2.0)
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -2), c + Vector2(3, 3), c + Vector2(0, 7), c + Vector2(-3, 3)]), Color(ViewPalette.LAVA_HOT, a))
		&"anchor":
			ToolIcons.draw(self, ToolDefinition.Kind.ANCHOR, c, 18.0, Color(ToolIcons.color_of(ToolDefinition.Kind.ANCHOR), a), 2.0)
		&"hook":
			ToolIcons.draw(self, ToolDefinition.Kind.HOOK, c, 18.0, Color(ToolIcons.color_of(ToolDefinition.Kind.HOOK), a), 2.0)
		&"warn":
			DrawKit.poly(self, PackedVector2Array([c + Vector2(0, -9), c + Vector2(9, 7), c + Vector2(-9, 7)]), Color(ViewPalette.WARN, a), Color(DrawKit.OUTLINE, a), 2.0)
		&"push":
			for i in 3:
				draw_line(c + Vector2(-8 + i * 5, -6), c + Vector2(-3 + i * 5, 0), Color(1, 1, 1, a), 2.0)
				draw_line(c + Vector2(-3 + i * 5, 0), c + Vector2(-8 + i * 5, 6), Color(1, 1, 1, a), 2.0)
