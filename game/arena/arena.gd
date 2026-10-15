class_name Arena
extends Node2D
## Arena (simulación): reúne plataformas, suelo de lava, lava inferior y puntos de
## aparición, aplica el calendario de peligros de la fase y responde si un personaje
## está en peligro. Todo peligro se anuncia antes con hazard_warned.

## kind: &"floor_lava", &"pool_rise", &"sudden_death", &"platform_collapse"
signal hazard_warned(kind: StringName, area: Rect2, seconds: float)

## Fuera de este rectángulo un personaje queda eliminado.
@export var bounds := Rect2(-240, -480, 1760, 1300)

var phase: PhaseDefinition
var time := 0.0
var sudden_death := false
var lava_pool: LavaPool
var segments: Array[LavaFloorSegment] = []
var platforms: Array[UnstablePlatform] = []
var blocks: Array[SolidBlock] = []

var _rng := RandomNumberGenerator.new()
var _next_wave := INF
var _wave := 0
var _next_rise := 0
var _rise_warned := -1


## Prepara la arena para una partida. Misma semilla → mismos peligros.
func setup(p_phase: PhaseDefinition, rng_seed: int) -> void:
	phase = p_phase if p_phase != null else PhaseDefinition.new()
	_rng.seed = rng_seed
	segments.clear()
	platforms.clear()
	blocks.clear()
	lava_pool = null
	_collect(self)
	time = 0.0
	sudden_death = false
	_wave = 0
	_next_rise = 0
	_rise_warned = -1
	_next_wave = phase.first_wave_at if phase.floor_waves_enabled else INF
	for p in platforms:
		p.stage_changed.connect(_on_platform_stage.bind(p))


func get_spawn_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	var spawns := get_node_or_null("Spawns")
	if spawns:
		for m in spawns.get_children():
			if m is Node2D:
				points.append((m as Node2D).global_position)
	return points


func step(delta: float, fighters: Array) -> void:
	time += delta
	for p in platforms:
		p.step(delta, fighters, phase.wear_multiplier)
	for s in segments:
		s.step(delta)
	if lava_pool:
		_step_pool()
		lava_pool.step(delta)
	if time >= _next_wave:
		_start_floor_wave()


## Causa de eliminación si el personaje está en peligro, o &"" si está a salvo.
func hazard_for(f: Fighter) -> StringName:
	if not bounds.has_point(f.global_position):
		return &"out_of_bounds"
	if lava_pool and lava_pool.is_deadly_for(f):
		return &"lava"
	for s in segments:
		if s.is_deadly_for(f):
			return &"lava"
	return &""


## Dirección (-1, 0, 1) hacia la que conviene moverse para salir de un peligro anunciado
## o activo bajo los pies. La usan los controladores que no son humanos.
func escape_direction(f: Fighter) -> int:
	var body := f.floor_body
	if body is LavaFloorSegment and (body as LavaFloorSegment).stage != LavaFloorSegment.Stage.SAFE:
		var best := INF
		var dir := 0
		for s in segments:
			if s.stage == LavaFloorSegment.Stage.SAFE:
				var dx := s.global_position.x - f.global_position.x
				if absf(dx) < best:
					best = absf(dx)
					dir = 1 if dx > 0.0 else -1
		return dir
	if body is UnstablePlatform and (body as UnstablePlatform).stage >= UnstablePlatform.Stage.CRITICAL:
		return 1 if f.global_position.x > (body as UnstablePlatform).global_position.x else -1
	return 0


## true si en la coordenada x hay un tramo de suelo anunciado o convertido en lava.
func is_floor_danger_at(x: float) -> bool:
	for s in segments:
		if s.stage != LavaFloorSegment.Stage.SAFE:
			var r := s.rect()
			if x >= r.position.x and x <= r.end.x:
				return true
	return false


func _collect(node: Node) -> void:
	for c in node.get_children():
		if c is LavaFloorSegment:
			segments.append(c)
		elif c is UnstablePlatform:
			platforms.append(c)
		elif c is SolidBlock:
			blocks.append(c)
		elif c is LavaPool:
			lava_pool = c
		_collect(c)


func _start_floor_wave() -> void:
	_next_wave = time + phase.wave_interval
	# Si la lava inferior ya cubre el suelo, no hay más oleadas de suelo.
	if lava_pool and segments.size() > 0 and lava_pool.level_y <= segments[0].rect().position.y:
		_next_wave = INF
		return
	var extra := floori(float(_wave) / maxi(phase.segments_increase_every, 1))
	var count := mini(phase.segments_first_wave + extra, phase.max_segments_per_wave)
	_wave += 1
	var available := segments.filter(func(s: LavaFloorSegment) -> bool: return s.is_available())
	# Siempre queda al menos un segmento seguro.
	count = mini(count, available.size() - 1)
	for i in count:
		var idx := _rng.randi_range(0, available.size() - 1)
		var seg: LavaFloorSegment = available[idx]
		available.remove_at(idx)
		seg.warn(phase.wave_warning, phase.wave_lava_time)
		hazard_warned.emit(&"floor_lava", seg.rect(), phase.wave_warning)


func _step_pool() -> void:
	if not sudden_death and time >= phase.sudden_death_at:
		sudden_death = true
		lava_pool.rise_forever(phase.sudden_death_speed)
		hazard_warned.emit(&"sudden_death", Rect2(bounds.position.x, lava_pool.level_y, bounds.size.x, 10.0), 0.0)
		return
	if _next_rise >= phase.pool_rise_times.size() or _next_rise >= phase.pool_rise_levels.size():
		return
	var at := phase.pool_rise_times[_next_rise]
	var target := phase.pool_rise_levels[_next_rise]
	if _rise_warned < _next_rise and time >= at - phase.pool_rise_warning:
		_rise_warned = _next_rise
		var area := Rect2(bounds.position.x, target, bounds.size.x, lava_pool.level_y - target)
		hazard_warned.emit(&"pool_rise", area, phase.pool_rise_warning)
	if time >= at:
		lava_pool.rise_to(target, phase.pool_rise_duration)
		_next_rise += 1


func _on_platform_stage(stage: UnstablePlatform.Stage, p: UnstablePlatform) -> void:
	if stage == UnstablePlatform.Stage.COLLAPSING:
		hazard_warned.emit(&"platform_collapse", p.rect(), p.params.collapse_warning)
