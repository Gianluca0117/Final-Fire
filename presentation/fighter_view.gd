class_name FighterView
extends Node2D
## Vista provisional del personaje (formas simples). Solo lee el estado y las señales
## del Fighter; nunca cambia la simulación.

var fighter: Fighter

var _squash := Vector2.ONE
var _push_flash := 0.0
var _hit_flash := 0.0
var _burn := -1.0
var _embers: Array[Vector3] = []   # x, y, vida
var _time := 0.0


func _ready() -> void:
	fighter = get_parent() as Fighter
	z_index = 5
	fighter.jumped.connect(func() -> void: _squash = Vector2(0.75, 1.3))
	fighter.landed.connect(func() -> void: _squash = Vector2(1.3, 0.72))
	fighter.pushed.connect(func(_t: Array) -> void: _push_flash = 0.18)
	fighter.was_pushed.connect(func(_by: Fighter, s: float) -> void: _hit_flash = 0.25 * clampf(s, 0.3, 1.0))
	fighter.eliminated.connect(_on_eliminated)


func _process(delta: float) -> void:
	_time += delta
	_squash = _squash.lerp(Vector2.ONE, minf(delta * 12.0, 1.0))
	_push_flash = maxf(_push_flash - delta, 0.0)
	_hit_flash = maxf(_hit_flash - delta, 0.0)
	if _burn >= 0.0:
		_burn += delta
		for i in _embers.size():
			var e := _embers[i]
			_embers[i] = Vector3(e.x + sin(_time * 6.0 + i) * 20.0 * delta, e.y - 90.0 * delta, e.z - delta)
		if _burn > 1.2:
			visible = false
	queue_redraw()


func _draw() -> void:
	var size := fighter.stats.body_size
	var col := fighter.color
	if _burn >= 0.0:
		var t := clampf(_burn / 0.8, 0.0, 1.0)
		var r := Rect2(-size * 0.5 * (1.0 - t * 0.5), size * (1.0 - t * 0.5))
		draw_rect(r, col.lerp(Color(1, 0.4, 0.1), t) * Color(1, 1, 1, 1.0 - t))
		for e in _embers:
			if e.z > 0.0:
				draw_circle(Vector2(e.x, e.y), 3.0 + e.z * 3.0, Color(1, 0.6, 0.15, e.z))
		return

	var bob := 0.0
	if fighter.state == Fighter.State.RUN:
		bob = sin(_time * 18.0) * 2.0
	var shake := Vector2.ZERO
	if fighter.state == Fighter.State.STUNNED:
		shake = Vector2(sin(_time * 70.0) * 2.5, 0)
	var s := size * _squash
	var base := Vector2(0, size.y * 0.5)  # los pies quedan en su sitio al deformarse
	var body := Rect2(base + Vector2(-s.x * 0.5, -s.y + bob) + shake, s)
	var dir := float(fighter.facing)

	# Capa / bufanda
	var cape := PackedVector2Array([
		body.position + Vector2(s.x * 0.5 - dir * s.x * 0.3, s.y * 0.28),
		body.position + Vector2(s.x * 0.5 - dir * s.x * 0.95, s.y * 0.38 + sin(_time * 10.0) * 3.0),
		body.position + Vector2(s.x * 0.5 - dir * s.x * 0.3, s.y * 0.5),
	])
	draw_colored_polygon(cape, col.darkened(0.25))
	# Cuerpo y capucha
	draw_rect(body, col.darkened(0.1))
	var hood := PackedVector2Array([
		body.position + Vector2(-2, s.y * 0.42),
		body.position + Vector2(s.x * 0.5 - dir * s.x * 0.25, -s.y * 0.22),
		body.position + Vector2(s.x + 2, s.y * 0.42),
	])
	draw_colored_polygon(hood, col)
	# Cara y ojos (miran hacia donde se mueve)
	var face := Rect2(body.position + Vector2(s.x * 0.5 - s.x * 0.32 + dir * 4.0, s.y * 0.18), Vector2(s.x * 0.64, s.y * 0.26))
	draw_rect(face, Color(0.98, 0.85, 0.72))
	var eye_y := face.position.y + face.size.y * 0.5
	for ex in [0.32, 0.72]:
		draw_rect(Rect2(Vector2(face.position.x + face.size.x * ex - 2.0 + dir * 2.0, eye_y - 3.0), Vector2(4, 6)), Color(0.1, 0.08, 0.1))

	# Brazo extendido al empujar
	if _push_flash > 0.0:
		var arm_y := body.position.y + s.y * 0.6
		var arm_x := body.position.x + (s.x if dir > 0.0 else 0.0)
		draw_rect(Rect2(Vector2(arm_x if dir > 0.0 else arm_x - 22.0, arm_y - 5.0), Vector2(22, 10)), col.lightened(0.2))
		for i in 3:
			var x := arm_x + dir * (30.0 + i * 9.0)
			draw_line(Vector2(x, arm_y - 12 + i * 8), Vector2(x + dir * 10.0, arm_y - 12 + i * 8), Color(1, 1, 1, _push_flash * 5.0), 2.0)
	# Golpe recibido
	if _hit_flash > 0.0:
		draw_rect(body.grow(2.0), Color(1, 1, 1, _hit_flash * 2.5), false, 2.0)
	# Protección
	if fighter.is_shielded():
		var r := maxf(size.x, size.y) * 0.75
		draw_circle(Vector2(0, 0), r, Color(0.55, 0.85, 1.0, 0.22))
		draw_arc(Vector2(0, 0), r, 0, TAU, 32, Color(0.7, 0.95, 1.0, 0.9), 3.0)
	# Etiqueta con el nombre
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-30, body.position.y - 10), fighter.display_name, HORIZONTAL_ALIGNMENT_CENTER, 60, 15, Color(1, 1, 1, 0.9))


func _on_eliminated(_cause: StringName, _by: Fighter) -> void:
	_burn = 0.0
	var size := fighter.stats.body_size
	for i in 10:
		_embers.append(Vector3(randf_range(-size.x * 0.5, size.x * 0.5), randf_range(-size.y * 0.3, size.y * 0.5), randf_range(0.5, 1.0)))
