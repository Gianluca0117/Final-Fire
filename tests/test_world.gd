class_name TestWorld
## Construye mundos de prueba en código: arena, reglas y partida con controladores guionizados.

## Reglas sin cuenta atrás y sin peligros programados (salvo que se pasen otros).
static func quiet_rules(hazards: HazardSchedule = null) -> MatchRules:
	var r := MatchRules.new()
	r.countdown = 0.0
	r.character_stats = load("res://data/characters/default_stats.tres")
	if hazards == null:
		hazards = HazardSchedule.new()
		hazards.floor_waves_enabled = false
		hazards.pool_rise_times = PackedFloat32Array()
		hazards.pool_rise_levels = PackedFloat32Array()
		hazards.sudden_death_at = 1e9
	r.hazards = hazards
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


## Reglas con una sola fase (que se repite) y las herramientas indicadas; sin lava programada.
static func tool_rules(pool: Array[ToolDefinition], duration := 3.0, announce_delay := 0.2, warning := 0.3, expire_warning := 0.5) -> MatchRules:
	var r := quiet_rules()
	var ph := PhaseDefinition.new()
	ph.duration = duration
	ph.tool_pool = pool
	ph.announce_delay = announce_delay
	ph.announce_warning = warning
	ph.expire_warning = expire_warning
	r.phases = [ph]
	return r


static func anchor_def(duration := 1.5, warning := 0.5) -> ToolDefinition:
	var d: ToolDefinition = load("res://data/tools/anchor.tres").duplicate()
	d.anchor_duration = duration
	d.anchor_warning = warning
	return d


static func hook_def() -> ToolDefinition:
	return load("res://data/tools/hook.tres").duplicate()


static func add_tool_spawn(a: Arena, at: Vector2) -> void:
	var node := a.get_node_or_null("ToolSpawns")
	if node == null:
		node = Node2D.new()
		node.name = "ToolSpawns"
		a.add_child(node)
	var m := Marker2D.new()
	m.position = at
	node.add_child(m)
