class_name HookTool
## Reglas del Gancho: tira del portador hacia una superficie válida dentro del alcance.
## Busca con rayos en un cono alrededor de la dirección apuntada (la más centrada gana).
## Un rayo se detiene en el primer obstáculo: nunca atraviesa paredes ni plataformas.
## Válido: bloques, plataformas sólidas y suelo que no está en lava, dentro de la zona visible.
## La superficie sobre la que está el portador no cuenta (tirar hacia el propio suelo no sirve).


static func find_target(def: ToolDefinition, fighter: Fighter, arena: Arena, aim: Vector2) -> ToolTarget:
	var dir := aim.normalized() if aim.length() > 0.2 else Vector2.UP
	var space := fighter.get_world_2d().direct_space_state
	var from := fighter.global_position
	var exclude: Array[RID] = [fighter.get_rid()]
	var first_fail: StringName = &""
	var steps := 4
	var step_deg := def.hook_cone_deg / steps
	var offsets: Array[float] = [0.0]
	for i in range(1, steps + 1):
		offsets.append(i * step_deg)
		offsets.append(-i * step_deg)
	for off in offsets:
		var d := dir.rotated(deg_to_rad(off))
		var hit := _ray(space, from, from + d * def.hook_range, exclude)
		if hit.is_empty() or hit.collider == fighter.floor_body:
			continue
		var reason := _invalid_reason(def, hit, from, arena)
		if reason == &"":
			return ToolTarget.ok(hit.position, hit.collider, dir)
		if first_fail == &"":
			first_fail = reason
	if first_fail == &"":
		# Nada al alcance: ¿hay algo un poco más lejos? Así el aviso es más útil.
		var far := _ray(space, from, from + dir * def.hook_range * 1.6, exclude)
		first_fail = &"out_of_range" if not far.is_empty() else &"no_surface"
	return ToolTarget.fail(first_fail, dir)


static func apply(def: ToolDefinition, fighter: Fighter, target: ToolTarget) -> void:
	fighter.start_hook(target.point, def.hook_speed, def.hook_max_time, def.hook_end_boost)


static func _ray(space: PhysicsDirectSpaceState2D, from: Vector2, to: Vector2, exclude: Array[RID]) -> Dictionary:
	var q := PhysicsRayQueryParameters2D.create(from, to, PhysicsLayers.WORLD, exclude)
	return space.intersect_ray(q)


static func _invalid_reason(def: ToolDefinition, hit: Dictionary, from: Vector2, arena: Arena) -> StringName:
	var p: Vector2 = hit.position
	if from.distance_to(p) < def.hook_min_range:
		return &"out_of_range"
	if not arena.play_area.has_point(p):
		return &"out_of_arena"
	var c: Object = hit.collider
	if c is LavaFloorSegment:
		return &"unsafe_surface" if (c as LavaFloorSegment).stage == LavaFloorSegment.Stage.LAVA else &""
	if c is UnstablePlatform:
		return &"" if (c as UnstablePlatform).stage <= UnstablePlatform.Stage.COLLAPSING else &"unsafe_surface"
	if c is SolidBlock:
		return &""
	return &"no_surface"
