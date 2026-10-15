class_name FighterView
extends Node2D
## Vista del personaje (estilo v1, propuesta). Elige el fotograma según el estado de la
## simulación y dibuja UN rectángulo con textura de la hoja de sprites de su variante
## (CharacterSprites). Encima, solo lo que cambia: deformación al saltar/aterrizar,
## burbuja de protección, estrellas al quedar aturdido, quemadura y etiqueta.
## Solo lee al Fighter; nunca cambia la simulación ni su colisión (40×56).

var fighter: Fighter
var look: CharacterLook
## Índice de variante (0–5); por defecto, el del participante.
var variant := -1

var _t := 0.0
var _run_phase := 0.0
var _blink := 0.0
var _next_blink := 2.0
var _impact := Vector2.ONE
var _burn := -1.0


func _ready() -> void:
	fighter = get_parent() as Fighter
	z_index = 5
	var idx := variant if variant >= 0 else maxi(fighter.participant_id, 0)
	look = CharacterLook.for_index(idx, fighter.color)
	CharacterSprites.request(get_tree(), look)
	_t = randf() * 10.0
	fighter.landed.connect(func() -> void: _impact = Vector2(1.22, 0.8))
	fighter.jumped.connect(func() -> void: _impact = Vector2(0.86, 1.16))
	fighter.was_pushed.connect(func(_by: Fighter, s: float) -> void: _impact = Vector2(0.85, 1.12) if s > 0.3 else _impact)
	fighter.eliminated.connect(func(_c: StringName, _by: Fighter) -> void: _burn = 0.0)


func _process(delta: float) -> void:
	_t += delta
	_impact = _impact.lerp(Vector2.ONE, minf(delta * 10.0, 1.0))
	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink = 0.12
		_next_blink = randf_range(2.2, 4.5)
	_blink -= delta
	if fighter.state == Fighter.State.RUN:
		_run_phase += maxf(absf(fighter.velocity.x), 120.0) * delta * 0.05
	if _burn >= 0.0:
		_burn += delta
		modulate.a = 1.0 - clampf((_burn - 0.5) / 0.5, 0.0, 1.0)
		if _burn > 1.0:
			visible = false
	queue_redraw()


## Índice del fotograma de la hoja para el estado actual (público para pruebas y galería).
func frame_index() -> int:
	var c := CharacterAnimations.CLIPS
	match fighter.state:
		Fighter.State.IDLE:
			return c["blink"][0] if _blink > 0.0 else c["idle"][int(_t * 5.0) % 4]
		Fighter.State.RUN:
			return c["run"][int(_run_phase / TAU * 8.0) % 8]
		Fighter.State.JUMP:
			return c["jump"][0]
		Fighter.State.FALL:
			return c["fall"][int(_t * 10.0) % 2]
		Fighter.State.PUSH:
			return c["push"][0]
		Fighter.State.SHIELDED:
			return c["shield"][0]
		Fighter.State.STUNNED:
			return c["hit"][int(_t * 8.0) % 2]
		Fighter.State.HOOKING:
			var to := (fighter.hook_point - fighter.global_position).normalized()
			var arm := rad_to_deg(atan2(to.x * fighter.facing, to.y))
			var best := 0
			for i in CharacterAnimations.HOOK_ANGLES.size():
				if absf(arm - CharacterAnimations.HOOK_ANGLES[i]) < absf(arm - CharacterAnimations.HOOK_ANGLES[best]):
					best = i
			return c["hook"][best]
		Fighter.State.ELIMINATED:
			return c["dead"][0]
	return c["idle"][0]


func _draw() -> void:
	var tex := CharacterSprites.sheet(look)
	if tex == null:
		return
	var feet := CharacterRig.FEET_Y
	var rise := 0.0
	var shrink := 1.0
	var dead := _burn >= 0.0
	if dead:
		rise = -_burn * 30.0
		shrink = 1.0 - clampf(_burn - 0.3, 0.0, 0.7) * 0.6
	elif fighter.is_on_floor():
		# Sombra en el suelo: ayuda a leer dónde está cada uno.
		draw_colored_polygon(DrawKit.ellipse(Vector2(0, feet + 1.0), 17.0, 4.0, 10), Color(0, 0, 0, 0.32))
	var sq := _impact * shrink
	var xf := Transform2D(0, Vector2(0, feet + rise)) * Transform2D.IDENTITY.scaled(Vector2(fighter.facing * sq.x, sq.y)) * Transform2D(0, Vector2(0, -feet))
	draw_set_transform_matrix(xf)
	# En el primer instante de la eliminación se ve el personaje y un destello; luego, carbonizado.
	var idx := frame_index() if not dead or _burn > 0.08 else CharacterAnimations.CLIPS["fall"][0]
	draw_texture_rect_region(tex, Rect2(-CharacterSprites.ORIGIN, CharacterSprites.CELL), CharacterSprites.region(idx))
	if dead and _burn < 0.12:
		draw_circle(Vector2(0, -2), 30.0, Color(1, 0.95, 0.8, 0.7 * (1.0 - _burn / 0.12)))
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if dead:
		return

	if fighter.is_shielded():
		var pts := PackedVector2Array()
		for i in 6:
			var a := TAU * i / 6.0 + _t * 0.6
			pts.append(Vector2(cos(a), sin(a)) * 38.0 + Vector2(0, -2))
		draw_colored_polygon(pts, Color(0.55, 0.88, 1.0, 0.2))
		pts.append(pts[0])
		draw_polyline(pts, DrawKit.OUTLINE, 5.0)
		draw_polyline(pts, Color(0.7, 0.95, 1.0, 0.95), 3.0)
	if fighter.state == Fighter.State.STUNNED:
		for i in 3:
			var a := _t * 7.0 + TAU * i / 3.0
			draw_colored_polygon(DrawKit.star_points(Vector2(cos(a) * 17.0, -40.0 + sin(a) * 4.0), 5.0, 2.2), Color("ffd23f"))
	# Etiqueta con el nombre (color del jugador)
	var w := 14.0 + fighter.display_name.length() * 7.0
	var tag := Rect2(-w * 0.5, -60, w, 15)
	draw_rect(tag.grow(2.0), DrawKit.OUTLINE)
	draw_rect(tag, fighter.color.darkened(0.25))
	draw_string(ThemeDB.fallback_font, Vector2(-w * 0.5, -48.5), fighter.display_name, HORIZONTAL_ALIGNMENT_CENTER, w, 11, Color.WHITE)
