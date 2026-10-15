class_name FighterView
extends Node2D
## Vista del personaje (estilo v2). Elige el fotograma según el estado de la simulación y el
## momento del movimiento, y dibuja UN rectángulo con textura de su hoja de sprites.
## Peso y personalidad (solo visuales, la simulación no cambia):
## - salto: impulso → subida → ápice → caída;
## - aterrizaje: aplastado proporcional a la velocidad de caída, luego recuperación;
## - carrera con derrape al cambiar de sentido; mirar alrededor en reposo;
## - empujón: golpe y recuperación; impacto: pausa breve («hit stop») y destello.
## El dibujo es un 12 % mayor que la colisión (40×56), igual para todos.

const VISUAL_SCALE := 1.12

var fighter: Fighter
var look: CharacterLook
## Índice de variante (0–5); por defecto, el del participante.
var variant := -1

var _t := 0.0
var _run_phase := 0.0
var _blink := 0.0
var _next_blink := 2.0
var _look_t := 0.0
var _next_look := 5.0
var _impact := Vector2.ONE
var _burn := -1.0
var _land_t := 1.0
var _land_k := 0.0
var _takeoff_t := 1.0
var _state_t := 0.0
var _last_state := -1
var _hitstop := 0.0
var _flash := 0.0
var _prev_vy := 0.0
var _frozen_frame := -1


func _ready() -> void:
	fighter = get_parent() as Fighter
	z_index = 5
	var idx := variant if variant >= 0 else maxi(fighter.participant_id, 0)
	look = CharacterLook.for_index(idx, fighter.color)
	CharacterSprites.request(get_tree(), look)
	_t = randf() * 10.0
	_next_look = randf_range(4.0, 8.0)
	fighter.landed.connect(_on_landed)
	fighter.jumped.connect(func() -> void:
		_takeoff_t = 0.0
		_impact = Vector2(0.88, 1.14))
	fighter.was_pushed.connect(func(_by: Fighter, s: float) -> void:
		if s > 0.3:
			_hitstop = 0.07
			_flash = 0.12
			_impact = Vector2(0.82, 1.14))
	fighter.eliminated.connect(func(_c: StringName, _by: Fighter) -> void: _burn = 0.0)


func _on_landed() -> void:
	# Cuanto más rápido cae, más se aplasta y más dura la recuperación.
	_land_k = clampf(_prev_vy / 900.0, 0.35, 1.0)
	_land_t = 0.0
	_impact = Vector2(1.0 + 0.12 * _land_k, 1.0 - 0.14 * _land_k)


func _process(delta: float) -> void:
	_t += delta
	if _hitstop > 0.0:
		_hitstop -= delta
		_flash = maxf(_flash - delta, 0.0)
		queue_redraw()
		return
	_flash = maxf(_flash - delta, 0.0)
	_impact = _impact.lerp(Vector2.ONE, minf(delta * 9.0, 1.0))
	_land_t += delta
	_takeoff_t += delta
	if int(fighter.state) != _last_state:
		_last_state = int(fighter.state)
		_state_t = 0.0
	_state_t += delta
	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink = 0.12
		_next_blink = randf_range(2.2, 4.5)
	_blink -= delta
	_next_look -= delta
	if _next_look <= 0.0:
		_look_t = 0.7
		_next_look = randf_range(5.0, 9.0)
	_look_t -= delta
	if fighter.state == Fighter.State.RUN:
		_run_phase += maxf(absf(fighter.velocity.x), 140.0) * delta * 0.052
	if not fighter.is_on_floor():
		_prev_vy = fighter.velocity.y
	if _burn >= 0.0:
		_burn += delta
		modulate.a = 1.0 - clampf((_burn - 0.5) / 0.5, 0.0, 1.0)
		if _burn > 1.0:
			visible = false
	queue_redraw()


## Índice del fotograma de la hoja para el estado actual (público para pruebas y galería).
func frame_index() -> int:
	var c := CharacterAnimations.CLIPS
	var f := fighter
	match f.state:
		Fighter.State.IDLE:
			if _land_t < 0.18:
				return c["land"][0] if _land_t < 0.07 else c["land"][1]
			if _blink > 0.0:
				return c["blink"][0]
			if _look_t > 0.0:
				return c["look"][0]
			return c["idle"][int(_t * 5.0) % 4]
		Fighter.State.RUN:
			if _land_t < 0.1:
				return c["land"][1]
			# Derrape: se mueve en sentido contrario a donde mira (cambio de dirección).
			if absf(f.velocity.x) > 80.0 and signf(f.velocity.x) != float(f.facing):
				return c["skid"][0]
			return c["run"][int(_run_phase / TAU * 8.0) % 8]
		Fighter.State.JUMP:
			if _takeoff_t < 0.08:
				return c["takeoff"][0]
			return c["apex"][0] if f.velocity.y > -180.0 else c["jump"][0]
		Fighter.State.FALL:
			if f.velocity.y < 160.0:
				return c["apex"][0]
			return c["fall"][int(_t * 10.0) % 2]
		Fighter.State.PUSH:
			return c["push"][0] if _state_t < 0.09 else c["push_recover"][0]
		Fighter.State.SHIELDED:
			return c["shield"][0]
		Fighter.State.STUNNED:
			return c["hit"][0] if _state_t < 0.12 else c["hit"][1 if int(_t * 8.0) % 2 == 0 else 0]
		Fighter.State.HOOKING:
			var to := (f.hook_point - f.global_position).normalized()
			var arm := rad_to_deg(atan2(to.x * f.facing, to.y))
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
		draw_colored_polygon(DrawKit.ellipse(Vector2(0, feet + 1.0), 19.0 * _impact.x, 4.5, 12), Color(0, 0, 0, 0.35))
	# Estiramiento en el aire según la velocidad vertical (da sensación de velocidad y peso).
	var air := Vector2.ONE
	if not dead and not fighter.is_on_floor():
		var k := clampf(absf(fighter.velocity.y) / 1100.0, 0.0, 1.0) * 0.08
		air = Vector2(1.0 - k, 1.0 + k)
	var sq := _impact * air * shrink * VISUAL_SCALE
	var xf := Transform2D(0, Vector2(0, feet + rise)) * Transform2D.IDENTITY.scaled(Vector2(fighter.facing * sq.x, sq.y)) * Transform2D(0, Vector2(0, -feet))
	draw_set_transform_matrix(xf)
	if _hitstop <= 0.0 or _frozen_frame < 0:
		_frozen_frame = frame_index() if not dead or _burn > 0.08 else CharacterAnimations.CLIPS["fall"][0]
	var tint := Color(1, 1, 1) if _flash <= 0.0 else Color(1.9, 1.9, 1.9)
	draw_texture_rect_region(tex, Rect2(-CharacterSprites.ORIGIN, CharacterSprites.CELL), CharacterSprites.region(_frozen_frame), tint)
	if dead and _burn < 0.12:
		draw_circle(Vector2(0, -2), 30.0, Color(1, 0.95, 0.8, 0.7 * (1.0 - _burn / 0.12)))
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if dead:
		return

	if fighter.is_shielded():
		var pts := PackedVector2Array()
		for i in 6:
			var a := TAU * i / 6.0 + _t * 0.6
			pts.append(Vector2(cos(a), sin(a)) * 40.0 + Vector2(0, -4))
		draw_colored_polygon(pts, Color(0.55, 0.88, 1.0, 0.2))
		pts.append(pts[0])
		draw_polyline(pts, DrawKit.OUTLINE, 5.0)
		draw_polyline(pts, Color(0.7, 0.95, 1.0, 0.95), 3.0)
	if fighter.state == Fighter.State.STUNNED:
		for i in 3:
			var a := _t * 7.0 + TAU * i / 3.0
			draw_colored_polygon(DrawKit.star_points(Vector2(cos(a) * 18.0, -46.0 + sin(a) * 4.0), 5.0, 2.2), Color("ffd23f"))
	# Etiqueta con el nombre: pequeña, del color del jugador
	var font := UiFonts.display()
	var w := 12.0 + fighter.display_name.length() * 8.0
	var tag := Rect2(-w * 0.5, -66, w, 15)
	draw_rect(tag.grow(1.5), DrawKit.OUTLINE)
	draw_rect(tag, fighter.color.darkened(0.2))
	draw_string(font, Vector2(-w * 0.5, -54.0), fighter.display_name, HORIZONTAL_ALIGNMENT_CENTER, w, 12, Color.WHITE)
