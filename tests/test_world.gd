class_name TestWorld
## Construye mundos de prueba en código: arena, reglas y partida con controladores guionizados.

## Reglas sin cuenta atrás y sin peligros programados (salvo que se pasen otros).
static func quiet_rules(phase: PhaseDefinition = null) -> MatchRules:
	var r := MatchRules.new()
	r.countdown = 0.0
	r.character_stats = load("res://data/characters/default_stats.tres")
	if phase == null:
		phase = PhaseDefinition.new()
		phase.floor_waves_enabled = false
		phase.pool_rise_times = PackedFloat32Array()
		phase.pool_rise_levels = PackedFloat32Array()
		phase.sudden_death_at = 1e9
	r.phase = phase
	return r


static func arena() -> Arena:
	var a := Arena.new()
	a.name = "TestArena"
	a.bounds = Rect2(-400, -800, 2080, 1800)
	var pool := LavaPool.new()
	pool.start_level_y = 900.0
	a.add_child(pool)
	var spawns := Node2D.new()
	spawns.name = "Spawns"
	a.add_child(spawns)
	return a


static func add_block(a: Arena, center: Vector2, size: Vector2) -> SolidBlock:
	var b := SolidBlock.new()
	b.size = size
	b.position = center
	a.add_child(b)
	return b


static func add_segment(a: Arena, center: Vector2) -> LavaFloorSegment:
	var s := LavaFloorSegment.new()
	s.position = center
	a.add_child(s)
	return s


static func add_platform(a: Arena, center: Vector2, params: PlatformParams) -> UnstablePlatform:
	var p := UnstablePlatform.new()
	p.params = params
	p.position = center
	a.add_child(p)
	return p


static func add_spawn(a: Arena, at: Vector2) -> void:
	var m := Marker2D.new()
	m.position = at
	a.get_node("Spawns").add_child(m)


## Crea una partida con un ScriptedController por punto de aparición y la arranca.
static func start_match(root: Node, a: Arena, rules: MatchRules, rng_seed := 1) -> MatchController:
	var holder := Node2D.new()
	holder.name = "TestMatch"
	root.add_child(holder)
	holder.add_child(a)
	var fighters := Node2D.new()
	holder.add_child(fighters)
	var ctl := MatchController.new()
	ctl.rules = rules
	holder.add_child(ctl)
	var list: Array[Participant] = []
	for i in a.get_node("Spawns").get_child_count():
		list.append(Participant.new(0, "P%d" % i, Participant.Kind.DUMMY, ScriptedController.new()))
	ctl.setup(a, list, fighters, rng_seed)
	ctl.start()
	return ctl


static func ctl_of(m: MatchController, i: int) -> ScriptedController:
	return m.participants[i].controller as ScriptedController


static func holder_of(m: MatchController) -> Node:
	return m.get_parent()
