class_name CharacterSprites
## Hojas de sprites del personaje generadas al iniciar el juego: cada variante se dibuja una
## vez (24 fotogramas) en una textura mediante un SubViewport que se renderiza una sola vez.
## Después, cada personaje en pantalla es un único rectángulo con textura (1 llamada de
## dibujo), lo que permite mantener el estilo vectorial en equipos modestos.
## En modo headless no se genera nada (no hay GPU) y las vistas simplemente no dibujan.

const SCALE := 1.5                     ## resolución de la hoja respecto al tamaño en juego
const CELL := Vector2(88, 100)         ## tamaño lógico de cada fotograma
const ORIGIN := Vector2(44, 64)        ## centro de la colisión dentro del fotograma
const COLS := 8

static var _sheets := {}
static var _pending := {}


static func key(look: CharacterLook) -> String:
	return "%d_%s" % [look.index, look.main.to_html(false)]


static func sheet(look: CharacterLook) -> Texture2D:
	return _sheets.get(key(look))


static func is_ready(look: CharacterLook) -> bool:
	return _sheets.has(key(look))


## Encarga la hoja de `look` si aún no existe (se genera en segundo plano en 1–2 fotogramas).
static func request(tree: SceneTree, look: CharacterLook) -> void:
	var k := key(look)
	if _sheets.has(k) or _pending.has(k) or PhysicsLayers.is_headless():
		return
	_pending[k] = true
	var baker := SheetBaker.new()
	baker.look = look
	baker.sheet_key = k
	tree.root.add_child.call_deferred(baker)


## Rectángulo del fotograma `index` dentro de la hoja.
static func region(index: int) -> Rect2:
	return Rect2(Vector2(index % COLS, int(index / float(COLS))) * CELL * SCALE, CELL * SCALE)


static func _store(k: String, tex: Texture2D) -> void:
	_sheets[k] = tex
	_pending.erase(k)


## Genera una hoja y se elimina a sí mismo.
class SheetBaker extends Node:
	var look: CharacterLook
	var sheet_key := ""

	func _ready() -> void:
		var rows := ceili(CharacterAnimations.FRAME_COUNT / float(CharacterSprites.COLS))
		var vp := SubViewport.new()
		vp.size = Vector2i(Vector2(CharacterSprites.COLS, rows) * CharacterSprites.CELL * CharacterSprites.SCALE)
		vp.transparent_bg = true
		vp.disable_3d = true
		vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		var painter := SheetPainter.new()
		painter.look = look
		vp.add_child(painter)
		add_child(vp)
		# Se esperan fotogramas normales (siempre ocurren) para que el SubViewport se haya
		# renderizado al menos una vez; no depende de la señal de fin de dibujo.
		for i in 3:
			await get_tree().process_frame
		var img := vp.get_texture().get_image()
		if img == null or img.is_empty():
			for i in 5:
				await get_tree().process_frame
			img = vp.get_texture().get_image()
		CharacterSprites._store(sheet_key, ImageTexture.create_from_image(img))
		queue_free()


class SheetPainter extends Node2D:
	var look: CharacterLook

	func _draw() -> void:
		var frames := CharacterAnimations.frames()
		for i in frames.size():
			var cell := CharacterSprites.region(i)
			var pose: RigPose = frames[i][0]
			var origin := cell.position + CharacterSprites.ORIGIN * CharacterSprites.SCALE
			var feet := CharacterRig.FEET_Y
			# Deformación de la pose (estirar/aplastar) alrededor de los pies, ya incluida en el sprite.
			var xf := Transform2D(0, origin) * Transform2D.IDENTITY.scaled(Vector2.ONE * CharacterSprites.SCALE) \
				* Transform2D(0, Vector2(0, feet)) * Transform2D.IDENTITY.scaled(pose.squash) * Transform2D(0, Vector2(0, -feet))
			draw_set_transform_matrix(xf)
			CharacterRig.draw(self, pose, look, frames[i][2], frames[i][1])
		draw_set_transform_matrix(Transform2D.IDENTITY)
