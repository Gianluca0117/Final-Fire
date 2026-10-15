class_name ToolSystem
extends RefCounted
## Herramienta única compartida por fase (se ejecuta en la autoridad de la partida).
## Gestiona fases, aviso previo (ubicación y tipo), aparición, recogida, uso, caducidad y
## qué ocurre si el portador es eliminado. Sin gráficos ni Input: la interfaz y la
## presentación solo escuchan sus señales y leen su estado.
##
## Garantías:
## - Como mucho existe UNA herramienta a la vez (anunciada, en el suelo o en manos de alguien).
## - La siguiente solo se anuncia tras consumirse o caducar la anterior (al empezar otra fase).
## - Cada participante lleva como mucho una; dos jugadores nunca recogen la misma
##   (la recogida se resuelve en un único sitio, en orden determinista).

enum State { NONE, ANNOUNCED, AVAILABLE, HELD, GONE }

signal phase_started(index: int, phase: PhaseDefinition)
signal tool_announced(def: ToolDefinition, position: Vector2, seconds: float)
signal tool_spawned(def: ToolDefinition, position: Vector2)
signal tool_picked(def: ToolDefinition, by: Participant)
signal tool_used(def: ToolDefinition, by: Participant, target: ToolTarget)
signal tool_use_failed(def: ToolDefinition, by: Participant, reason: StringName)
signal tool_dropped(def: ToolDefinition, by: Participant)
signal tool_expiring(def: ToolDefinition, seconds: float)
## reason: &"phase_end" (fin de fase) o &"carrier_eliminated" (portador eliminado sin tiempo para reaparecer)
signal tool_expired(def: ToolDefinition, reason: StringName)

var rules: MatchRules
var arena: Arena
var phase_index := -1
var phase: PhaseDefinition
var phase_time := 0.0
var state: State = State.NONE
var current: ToolDefinition
var position := Vector2.ZERO
var holder: Participant
var uses_left := 0
## Segundos de aviso restantes antes de aparecer (estado ANNOUNCED).
var time_left := 0.0
var expiring := false
## Vista previa del objetivo para cada portador (Participant → ToolTarget). Solo lectura.
var previews := {}

var _rng := RandomNumberGenerator.new()
var _spawn_point := Vector2.ZERO
var _announced_this_phase := false
var _last_tool_id: StringName = &""


## Desconecta todas las señales. Las funciones conectadas pueden capturar a este objeto
## (ciclo de referencias): sin esto, el sistema no se liberaría al terminar la partida.
func release() -> void:
	for sig in get_signal_list():
		for c in get_signal_connection_list(sig.name):
			disconnect(sig.name, c.callable)
	previews.clear()
	holder = null


func setup(p_rules: MatchRules, p_arena: Arena, rng_seed: int) -> void:
	rules = p_rules
	arena = p_arena
	_rng.seed = rng_seed ^ 0x51F7


func enabled() -> bool:
	return rules != null and not rules.phases.is_empty() and not arena.get_tool_spawn_points().is_empty()


func phase_left() -> float:
	return phase.duration - phase_time if phase else 0.0


func holds(p: Participant) -> bool:
	return state == State.HELD and holder == p


## Herramienta que lleva `p` (o null).
func held_by(p: Participant) -> ToolDefinition:
	return current if holds(p) else null


## Un tick. Se llama después de mover a los personajes y antes de comprobar la lava.
func step(delta: float, participants: Array[Participant]) -> void:
	if not enabled():
		return
	if phase == null:
		_start_phase(0)
	phase_time += delta
	match state:
		State.NONE:
			if not _announced_this_phase and phase_time >= phase.announce_delay:
				_announce(_choose_tool(), _choose_spawn(), phase.announce_warning)
		State.ANNOUNCED:
			time_left -= delta
			if time_left <= 0.0:
				state = State.AVAILABLE
				tool_spawned.emit(current, position)
		State.AVAILABLE:
			_try_pickup(participants)
	if _is_active() and not expiring and phase_left() <= phase.expire_warning:
		expiring = true
		tool_expiring.emit(current, maxf(phase_left(), 0.0))
	if phase_left() <= 0.0:
		if _is_active():
			_expire(&"phase_end")
		_start_phase(phase_index + 1)
	_update_previews()


## Usa la herramienta de `p` apuntando en `aim`. Si el objetivo no es válido no se consume.
func try_use(p: Participant, aim: Vector2) -> bool:
	if not holds(p):
		return false
	var target := find_target(p.fighter, aim)
	if not target.valid:
		tool_use_failed.emit(current, p, target.reason)
		return false
	match current.kind:
		ToolDefinition.Kind.ANCHOR:
			AnchorTool.apply(current, p.fighter, target)
		ToolDefinition.Kind.HOOK:
			HookTool.apply(current, p.fighter, target)
	var used := current
	uses_left -= 1
	if uses_left <= 0:
		state = State.GONE
		holder = null
		previews.clear()
	tool_used.emit(used, p, target)
	return true


func find_target(fighter: Fighter, aim: Vector2) -> ToolTarget:
	if current == null:
		return ToolTarget.fail(&"no_tool")
	match current.kind:
		ToolDefinition.Kind.ANCHOR:
			return AnchorTool.find_target(current, fighter, arena)
		ToolDefinition.Kind.HOOK:
			return HookTool.find_target(current, fighter, arena, aim)
	return ToolTarget.fail(&"no_tool")


## Lo llama la partida cuando un participante es eliminado.
func on_participant_eliminated(p: Participant) -> void:
	if not holds(p):
		return
	var def := current
	holder = null
	previews.clear()
	tool_dropped.emit(def, p)
	if rules.on_carrier_eliminated == MatchRules.CarrierEliminated.RESPAWN and phase_left() >= rules.tool_respawn_min_time:
		# Vuelve a su punto de aparición, con aviso, y conserva sus usos.
		var uses := uses_left
		_announce(def, _spawn_point, rules.tool_respawn_warning)
		uses_left = uses
	else:
		_expire(&"carrier_eliminated")


func _is_active() -> bool:
	return state == State.ANNOUNCED or state == State.AVAILABLE or state == State.HELD


func _start_phase(index: int) -> void:
	phase_index = index
	phase = rules.phases[mini(index, rules.phases.size() - 1)]
	phase_time = 0.0
	state = State.NONE
	current = null
	holder = null
	expiring = false
	previews.clear()
	_announced_this_phase = false
	phase_started.emit(index, phase)


func _announce(def: ToolDefinition, at: Vector2, seconds: float) -> void:
	current = def
	position = at
	_spawn_point = at
	uses_left = def.uses
	time_left = seconds
	state = State.ANNOUNCED
	_announced_this_phase = true
	_last_tool_id = def.id
	tool_announced.emit(def, at, seconds)


func _expire(reason: StringName) -> void:
	var def := current
	state = State.GONE
	holder = null
	previews.clear()
	tool_expired.emit(def, reason)


func _choose_tool() -> ToolDefinition:
	var pool := phase.tool_pool
	if pool.size() > 1:
		# No repetir la misma herramienta dos fases seguidas.
		var others := pool.filter(func(t: ToolDefinition) -> bool: return t.id != _last_tool_id)
		if not others.is_empty():
			return others[_rng.randi_range(0, others.size() - 1)]
	return pool[_rng.randi_range(0, pool.size() - 1)]


func _choose_spawn() -> Vector2:
	var points := arena.get_tool_spawn_points()
	var safe := points.filter(func(p: Vector2) -> bool: return not arena.is_floor_danger_at(p.x) or p.y < 500.0)
	var pick_from := safe if not safe.is_empty() else points
	return pick_from[_rng.randi_range(0, pick_from.size() - 1)]


func _try_pickup(participants: Array[Participant]) -> void:
	var best_d := INF
	var tied: Array[Participant] = []
	for p in participants:
		if not p.alive or holds(p):
			continue
		var d := p.fighter.global_position.distance_to(position)
		if d > rules.tool_pickup_radius:
			continue
		if d < best_d - 0.5:
			best_d = d
			tied = [p]
		elif absf(d - best_d) <= 0.5:
			tied.append(p)
	if tied.is_empty():
		return
	# Recogida simultánea: gana el más cercano; en empate exacto, sorteo con la semilla
	# de la partida (reproducible en la autoridad).
	holder = tied[0] if tied.size() == 1 else tied[_rng.randi_range(0, tied.size() - 1)]
	state = State.HELD
	tool_picked.emit(current, holder)


func _update_previews() -> void:
	previews.clear()
	if state == State.HELD and holder and holder.alive:
		previews[holder] = find_target(holder.fighter, holder.fighter.aim)
