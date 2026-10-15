class_name ArenaViews
## Crea las vistas de una arena, sus personajes, la herramienta y los efectos. La llama la
## escena de partida (raíz de composición). En modo headless no se crea ninguna vista,
## salvo que se fuerce (pruebas que comprueban que el arte no altera la simulación).


static func attach(arena: Arena, fighters: Array[Fighter], parent: Node, match_ctl: MatchController = null, force := false) -> void:
	if PhysicsLayers.is_headless() and not force:
		return
	var bg := BackgroundView.new()
	bg.arena = arena
	parent.add_child(bg)
	parent.move_child(bg, 0)
	for b in arena.blocks:
		b.add_child(BlockView.new())
	for p in arena.platforms:
		p.add_child(PlatformView.new())
	for s in arena.segments:
		s.add_child(SegmentView.new())
	if arena.lava_pool:
		var pool_view := LavaPoolView.new()
		arena.lava_pool.add_child(pool_view)
		arena.hazard_warned.connect(func(kind: StringName, area: Rect2, seconds: float) -> void:
			if kind == &"pool_rise":
				pool_view.warn_rise(area.position.y, seconds))
	for f in fighters:
		var v := FighterView.new()
		v.name = "View"
		f.add_child(v)
	if match_ctl:
		parent.add_child(ToolsView.new(match_ctl))
		var vfx := VfxLayer.new()
		parent.add_child(vfx)
		vfx.bind(match_ctl)
