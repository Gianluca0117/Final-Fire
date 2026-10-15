class_name DummyController
extends FighterController
## Maniquí de pruebas: se mueve, salta, empuja y se protege con reglas muy simples
## para poder jugar una partida local mientras no existen los bots (fase F4).
## No planifica rutas ni evalúa riesgos; solo huye de la lava que tiene bajo los pies.
## Herramientas: a veces va a por la herramienta; usa el Ancla si su plataforma peligra y
## el Gancho para escapar de la lava (si el destino no es válido, la conserva).
## Usa exactamente las mismas acciones que un humano.

var aggression := 0.55

var _rng := RandomNumberGenerator.new()
var _target_x := 640.0
var _retarget := 0.0
var _jump_cooldown := 0.0
var _hold_jump := 0.0
var _reaction := 0.0
var _tool_think := 0.0


func _init(rng_seed := 0, p_aggression := 0.55) -> void:
	_rng.seed = rng_seed
	aggression = p_aggression
	# Al empezar tardan un poco en atacar, para que nadie caiga en el primer segundo.
	_reaction = _rng.randf_range(1.5, 2.5)


func sample(p_tick: int, fighter: Fighter, match_ctl: MatchController) -> InputFrame:
	var f := InputFrame.new()
	f.tick = p_tick
	var dt := 1.0 / Engine.physics_ticks_per_second
	_retarget -= dt
	_jump_cooldown -= dt
	_hold_jump -= dt
	_reaction -= dt

	var me := fighter.global_position
	var rival := _nearest_rival(fighter, match_ctl)
	if _retarget <= 0.0:
		_retarget = _rng.randf_range(0.8, 2.2)
		var tools := match_ctl.tools
		if tools.state == ToolSystem.State.AVAILABLE and _rng.randf() < 0.6:
			_target_x = tools.position.x
		elif rival and _rng.randf() < aggression:
			_target_x = rival.global_position.x
		else:
			_target_x = _rng.randf_range(220.0, 1060.0)

	var escape := match_ctl.arena.escape_direction(fighter)
	if escape != 0:
		f.move_x = escape
	elif absf(_target_x - me.x) > 24.0:
		f.move_x = signf(_target_x - me.x)
		# No pisar suelo anunciado o con lava.
		if fighter.is_on_floor() and match_ctl.arena.is_floor_danger_at(me.x + f.move_x * 60.0):
			f.move_x = 0.0
			_retarget = 0.0

	# Saltar: a veces al azar, para alcanzar a un rival que está más arriba o para huir.
	var wants_jump := _rng.randf() < 0.008
	if rival and rival.global_position.y < me.y - 80.0 and absf(rival.global_position.x - me.x) < 260.0:
		wants_jump = wants_jump or _rng.randf() < 0.05
	if escape != 0:
		wants_jump = wants_jump or _rng.randf() < 0.04
	if wants_jump and fighter.is_on_floor() and _jump_cooldown <= 0.0:
		f.jump_pressed = true
		_hold_jump = _rng.randf_range(0.1, 0.35)
		_jump_cooldown = 0.7
	# Saltar hacia una herramienta que está más arriba.
	var tl := match_ctl.tools
	if tl.state == ToolSystem.State.AVAILABLE and absf(tl.position.x - me.x) < 120.0 and tl.position.y < me.y - 60.0 and fighter.is_on_floor() and _jump_cooldown <= 0.0 and _rng.randf() < 0.08:
		f.jump_pressed = true
		_hold_jump = 0.35
		_jump_cooldown = 0.7
	f.jump_held = f.jump_pressed or _hold_jump > 0.0
	_use_tool(f, fighter, match_ctl, escape, dt)

	# Empujar o protegerse cuando un rival está cerca (con un pequeño tiempo de reacción).
	if rival and _reaction <= 0.0:
		var d := rival.global_position - me
		if absf(d.x) < 95.0 and absf(d.y) < 40.0:
			_reaction = _rng.randf_range(0.12, 0.3)
			if signf(d.x) == float(fighter.facing) and fighter.push_ready() and _rng.randf() < aggression:
				f.push_pressed = true
			elif fighter.shield_ready() and _rng.randf() < 0.25:
				f.shield_pressed = true
			elif escape == 0 and signf(d.x) != float(fighter.facing):
				# Girarse hacia el rival solo si no está huyendo de la lava.
				f.move_x = signf(d.x)
	return f


func _use_tool(f: InputFrame, fighter: Fighter, match_ctl: MatchController, escape: int, dt: float) -> void:
	_tool_think -= dt
	var me: Participant = null
	for p in match_ctl.participants:
		if p.fighter == fighter:
			me = p
	var def := match_ctl.tools.held_by(me) if me else null
	if def == null or _tool_think > 0.0:
		return
	_tool_think = _rng.randf_range(0.25, 0.6)
	match def.kind:
		ToolDefinition.Kind.ANCHOR:
			var plat := fighter.floor_body as UnstablePlatform
			if plat and plat.can_anchor() and (plat.stage >= UnstablePlatform.Stage.CRITICAL or absf(plat.rotation_degrees) > 8.0):
				f.tool_pressed = true
		ToolDefinition.Kind.HOOK:
			if escape != 0 or _rng.randf() < 0.05:
				f.tool_pressed = true
				f.aim = Vector2(_rng.randf_range(-0.6, 0.6), -1.0).normalized()


func _nearest_rival(fighter: Fighter, match_ctl: MatchController) -> Fighter:
	var best: Fighter = null
	var best_d := INF
	for other in match_ctl.get_fighters():
		if other == fighter or not other.is_alive():
			continue
		var d := fighter.global_position.distance_squared_to(other.global_position)
		if d < best_d:
			best_d = d
			best = other
	return best
