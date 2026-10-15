class_name AliveIndicator
extends Control
## «VIVOS n/N» con la cabeza de cada personaje, recortada de su hoja de sprites (la misma
## que en el juego): una llamada de dibujo por cabeza. Los eliminados aparecen carbonizados
## y tachados. Solo se redibuja cuando alguien cae (o cuando terminan de generarse las hojas).

## Recorte de la cabeza dentro de un fotograma (coordenadas locales del personaje).
const HEAD := Rect2(-26, -47, 52, 50)
const HEAD_SCALE := 0.62

var participants: Array[Participant] = []:
	set(value):
		participants = value
		_looks.clear()
		for p in participants:
			var l := CharacterLook.for_index(p.id, p.color)
			_looks.append(l)
			if is_inside_tree():
				CharacterSprites.request(get_tree(), l)
		_missing = true
		queue_redraw()

var _looks: Array[CharacterLook] = []
var _missing := true


func _init() -> void:
	custom_minimum_size = Vector2(320, 46)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if _missing and _looks.all(func(l: CharacterLook) -> bool: return CharacterSprites.is_ready(l)):
		_missing = false
		queue_redraw()


func _draw() -> void:
	var alive := 0
	for p in participants:
		if p.alive:
			alive += 1
	var w := 128.0 + participants.size() * 31.0
	UiTheme.draw_panel(self, Rect2(0, 0, w, 46))
	DrawKit.text(self, Vector2(12, 30), "VIVOS", 16, ViewPalette.UI_TEXT, -1, HORIZONTAL_ALIGNMENT_LEFT, 4)
	DrawKit.text(self, Vector2(74, 31), "%d/%d" % [alive, participants.size()], 20, ViewPalette.UI_ACCENT, -1, HORIZONTAL_ALIGNMENT_LEFT, 4)
	for i in participants.size():
		var p := participants[i]
		var tex := CharacterSprites.sheet(_looks[i])
		var c := Vector2(136 + i * 31, 24)
		if tex == null:
			draw_circle(c, 9.0, p.color)
			continue
		var frame: int = CharacterAnimations.CLIPS["idle"][0] if p.alive else CharacterAnimations.CLIPS["dead"][0]
		var cell := CharacterSprites.region(frame)
		var src := Rect2(cell.position + (CharacterSprites.ORIGIN + HEAD.position) * CharacterSprites.SCALE, HEAD.size * CharacterSprites.SCALE)
		var dest := Rect2(c + (HEAD.position + Vector2(0, 22)) * HEAD_SCALE, HEAD.size * HEAD_SCALE)
		draw_texture_rect_region(tex, dest, src)
		if not p.alive:
			draw_line(c + Vector2(-11, -11), c + Vector2(11, 11), DrawKit.OUTLINE, 5.0)
			draw_line(c + Vector2(-11, -11), c + Vector2(11, 11), ViewPalette.WARN, 2.5)
