class_name AnchorTool
## Reglas del Ancla: estabiliza una plataforma inestable durante un tiempo.
## Objetivo: la plataforma donde está el portador; si no está sobre una, la más cercana
## dentro del alcance. Todos los que estén encima se benefician.


static func find_target(def: ToolDefinition, fighter: Fighter, arena: Arena) -> ToolTarget:
	var own := fighter.floor_body as UnstablePlatform
	if own:
		if own.can_anchor():
			return ToolTarget.ok(own.global_position, own)
		if own.is_anchored():
			return ToolTarget.fail(&"already_anchored")
	var best: UnstablePlatform = null
	var best_d := INF
	var anchored_near := false
	for p in arena.platforms:
		var d := p.global_position.distance_to(fighter.global_position)
		if d > def.anchor_range:
			continue
		if p.is_anchored():
			anchored_near = true
		elif p.can_anchor() and d < best_d:
			best = p
			best_d = d
	if best:
		return ToolTarget.ok(best.global_position, best)
	return ToolTarget.fail(&"already_anchored" if anchored_near else &"no_platform")


static func apply(def: ToolDefinition, _fighter: Fighter, target: ToolTarget) -> void:
	(target.body as UnstablePlatform).anchor(def.anchor_duration, def.anchor_warning)
