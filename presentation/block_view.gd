class_name BlockView
extends Node2D
## Bloque de roca volcánica seguro (estilo v2), ilustrado con ArenaArt y horneado con ArtCache.

var _ready_art := false


func _process(_delta: float) -> void:
	if not _ready_art:
		queue_redraw()


func _draw() -> void:
	var b := get_parent() as SolidBlock
	var key := "block_%dx%d_%s" % [b.size.x, b.size.y, b.name]
	_ready_art = ArtCache.draw(self, key, ArenaArt.bounds(b.size), func(ci: CanvasItem) -> void: ArenaArt.stone_block(ci, b.size, key))
