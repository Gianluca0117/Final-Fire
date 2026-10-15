class_name MatchController
extends Node
## Partida (autoridad): avanza la simulación tick a tick en un orden fijo
## (arena → personajes y uso de herramientas → herramienta compartida → peligros → ganador). La interfaz, el audio y la red
## solo escuchan sus señales; nunca cambian el estado directamente.

enum Phase { SETUP, COUNTDOWN, RUNNING, FINISHED }

signal countdown_changed(seconds_left: int)
signal match_started
signal participant_eliminated(participant: Participant, cause: StringName, by: Participant)
## winner es null si hay empate (los últimos caen en el mismo tick).
signal match_finished(winner: Participant)

@export var rules: MatchRules

var arena: Arena
var tools := ToolSystem.new()
var participants: Array[Participant] = []
var phase: Phase = Phase.SETUP
var tick := 0
var elapsed := 0.0
var winner: Participant = null
var rng_seed := 0

var _countdown := 0.0
var _fighters: Array[Fighter] = []
var _by_fighter := {}


## Crea un personaje por participante en los puntos de aparición de la arena.
func setup(p_arena: Arena, p_participants: Array[Participant], fighter_parent: Node, p_seed: int) -> void:
	assert(rules != null, "MatchController necesita MatchRules")
	arena = p_arena
	rng_seed = p_seed
	participants = p_participants
	if participants.size() < rules.min_participants or participants.size() > rules.max_participants:
		push_error("Participantes fuera de rango: %d (permitido %d–%d)" % [participants.size(), rules.min_participants, rules.max_participants])
	arena.setup(rules.hazards, p_seed)
	tools.setup(rules, arena, p_seed)
	var spawns := arena.get_spawn_points()
	_fighters.clear()
	_by_fighter.clear()
	for i in participants.size():
		var p := participants[i]
		p.id = i
		if p.color == Color.WHITE:
			p.color = rules.colors[i % rules.colors.size()]
		var f := Fighter.new()
		f.name = "Fighter%d" % i
		f.stats = rules.character_stats
		f.participant_id = i
		f.display_name = p.display_name
		f.color = p.color
		fighter_parent.add_child(f)
		f.spawn(spawns[i % spawns.size()] if spawns.size() > 0 else Vector2(640, 300))
		f.facing = 1 if f.global_position.x < 640.0 else -1
		p.fighter = f
		_fighters.append(f)
		_by_fighter[f] = p
	phase = Phase.SETUP


func _exit_tree() -> void:
	tools.release()


func start() -> void:
	_countdown = rules.countdown
	phase = Phase.COUNTDOWN
	if _countdown <= 0.0:
		_begin()
	else:
		countdown_changed.emit(ceili(_countdown))


func get_fighters() -> Array[Fighter]:
	return _fighters


func alive_participants() -> Array[Participant]:
	var alive: Array[Participant] = []
	for p in participants:
		if p.alive:
			alive.append(p)
	return alive


func countdown_left() -> float:
	return maxf(_countdown, 0.0)


func _physics_process(delta: float) -> void:
	step(delta)


## Un tick de partida. Público para que las pruebas puedan avanzar a mano.
func step(delta: float) -> void:
	match phase:
		Phase.COUNTDOWN:
			var before := ceili(_countdown)
			_countdown -= delta
			for f in _fighters:
				f.step(InputFrame.idle(tick), delta, _fighters)
			if _countdown <= 0.0:
				_begin()
			elif ceili(_countdown) != before:
				countdown_changed.emit(ceili(_countdown))
		Phase.RUNNING:
			_step_running(delta)


func _begin() -> void:
	phase = Phase.RUNNING
	countdown_changed.emit(0)
	match_started.emit()


func _step_running(delta: float) -> void:
	tick += 1
	elapsed += delta
	arena.step(delta, _fighters)
	for p in participants:
		if p.alive:
			var frame := p.controller.sample(tick, p.fighter, self) if p.controller else InputFrame.idle(tick)
			frame = frame.sanitized()
			p.fighter.step(frame, delta, _fighters)
			if frame.tool_pressed:
				tools.try_use(p, frame.aim)
	tools.step(delta, participants)
	var fallen: Array[Participant] = []
	for p in participants:
		if p.alive:
			var cause := arena.hazard_for(p.fighter)
			if cause != &"":
				fallen.append(p)
				_eliminate(p, cause)
	if not fallen.is_empty():
		_assign_places(fallen)
		_check_winner()


func _eliminate(p: Participant, cause: StringName) -> void:
	p.alive = false
	p.eliminated_at = elapsed
	p.elimination_cause = cause
	var f := p.fighter
	var by: Participant = null
	if f.last_pusher != null and f.sim_time - f.last_pushed_at <= rules.push_credit_window:
		by = _by_fighter.get(f.last_pusher)
		if by == p:
			by = null
	p.eliminated_by = by
	if by:
		by.eliminations += 1
	f.eliminate(cause, f.last_pusher if by else null)
	tools.on_participant_eliminated(p)
	participant_eliminated.emit(p, cause, by)


func _assign_places(fallen: Array[Participant]) -> void:
	# Quienes caen en el mismo tick comparten puesto.
	var place := alive_participants().size() + 1
	for p in fallen:
		p.place = place


func _check_winner() -> void:
	var alive := alive_participants()
	if alive.size() > 1:
		return
	phase = Phase.FINISHED
	winner = alive[0] if alive.size() == 1 else null
	if winner:
		winner.place = 1
	match_finished.emit(winner)
