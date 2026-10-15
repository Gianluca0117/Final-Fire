class_name ArenaViews
## Crea las vistas provisionales de una arena y de sus personajes. La llama la escena de
## partida (raíz de composición); en modo headless no se crea ninguna vista.


static func attach(arena: Arena, fighters: Array[Fighter], parent_for_background: Node) -> void:
	if PhysicsLayers.is_headless():
		return
	var bg := BackgroundView.new()
	bg.arena = arena
	parent_for_background.add_child(bg)
	parent_for_background.move_child(bg, 0)
	for b in arena.blocks:
		b.add_child(BlockView.new())
	for p in arena.platforms:
		p.add_child(PlatformView.new())
	for s in arena.segments:
		s.add_child(SegmentView.new())
	if arena.lava_pool:
		arena.lava_pool.add_child(LavaPoolView.new())
	for f in fighters:
		f.add_child(FighterView.new())
