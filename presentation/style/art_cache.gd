class_name ArtCache
## Caché de dibujos estáticos: cada pieza (por tipo, tamaño y estado) se dibuja UNA vez en una
## textura mediante un SubViewport y después se pinta con una sola llamada. Mientras se genera
## (1–3 fotogramas) se dibuja en directo, así que nunca aparece vacía.
## En modo headless no se genera nada (no hay GPU).

const SCALE := 2.0

static var _tex := {}
static var _pending := {}


## Dibuja `key` en `rect` (coordenadas locales de `ci`). `painter.call(canvas)` debe dibujar
## en esas mismas coordenadas. Devuelve true si ya se usó la textura.
static func draw(ci: CanvasItem, key: String, rect: Rect2, painter: Callable) -> bool:
	var tex: Texture2D = _tex.get(key)
	if tex:
		ci.draw_texture_rect(tex, rect, false)
		return true
	painter.call(ci)
	if not _pending.has(key) and not PhysicsLayers.is_headless() and ci.is_inside_tree():
		_pending[key] = true
		var b := Baker.new()
		b.key = key
		b.rect = rect
		b.painter = painter
		ci.get_tree().root.add_child.call_deferred(b)
	return false


static func is_ready(key: String) -> bool:
	return _tex.has(key)


class Baker extends Node:
	var key := ""
	var rect := Rect2()
	var painter: Callable

	func _ready() -> void:
		var vp := SubViewport.new()
		vp.size = Vector2i((rect.size * ArtCache.SCALE).ceil())
		vp.transparent_bg = true
		vp.disable_3d = true
		vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		var p := PainterNode.new()
		p.painter = painter
		p.scale = Vector2.ONE * ArtCache.SCALE
		p.position = -rect.position * ArtCache.SCALE
		vp.add_child(p)
		add_child(vp)
		for i in 3:
			await get_tree().process_frame
		var img := vp.get_texture().get_image()
		if img and not img.is_empty():
			ArtCache._tex[key] = ImageTexture.create_from_image(img)
		ArtCache._pending.erase(key)
		queue_free()


class PainterNode extends Node2D:
	var painter: Callable

	func _draw() -> void:
		painter.call(self)
