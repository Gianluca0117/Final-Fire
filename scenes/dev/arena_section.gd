class_name ArenaSection
extends Node2D
## Sección de arena para la galería de estilo: piezas reales con estados fijados y las
## vistas del juego. Solo desarrollo.

var labels: Array = []


func _ready() -> void:
	var fragile: PlatformParams = load("res://data/platforms/fragile_platform.tres")
	var tilting: PlatformParams = load("res://data/platforms/tilting_platform.tres")
	var y := 510.0
	_block(Vector2(95, y + 4), Vector2(150, 30), "Normal (segura)")
	var states := [
		["Frágil: segura", UnstablePlatform.Stage.INTACT, 1.0, false],
		["Agrietada", UnstablePlatform.Stage.CRACKED, 0.5, false],
		["A punto de caer", UnstablePlatform.Stage.COLLAPSING, 0.0, false],
		["Estabilizada (Ancla)", UnstablePlatform.Stage.CRACKED, 0.5, true],
	]
	for i in states.size():
		var p := _platform(Vector2(300 + i * 175, y), fragile, Vector2(150, 22))
		p.stage = states[i][1]
		p.integrity = states[i][2]
		if states[i][3]:
			p.anchor(6.0, 1.5)
			p.anchor_left = 4.0
		labels.append([Vector2(300 + i * 175, y + 34), states[i][0]])
	var tilt := _platform(Vector2(1110, y - 6), tilting, Vector2(170, 22))
	tilt.rotation_degrees = 12.0
	labels.append([Vector2(1110, y + 34), "Inclinable"])

	var seg_y := 655.0
	var seg_states := [["Suelo seguro", LavaFloorSegment.Stage.SAFE], ["Aviso (1,0 s)", LavaFloorSegment.Stage.WARNING], ["Lava", LavaFloorSegment.Stage.LAVA]]
	for i in seg_states.size():
		var s := LavaFloorSegment.new()
		s.position = Vector2(160 + i * 200, seg_y)
		add_child(s)
		s.stage = seg_states[i][1]
		s.time_left = 1.0
		s.stage_duration = 2.0
		s.add_child(SegmentView.new())
		labels.append([Vector2(160 + i * 200, seg_y + 40), seg_states[i][0]])
	var pool := LavaPool.new()
	pool.position = Vector2(640, 0)
	pool.start_level_y = 702.0
	pool.width = 1400.0
	add_child(pool)
	pool.add_child(LavaPoolView.new())
	labels.append([Vector2(1000, 660), "Lava inferior"])


func _block(pos: Vector2, size: Vector2, label: String) -> void:
	var b := SolidBlock.new()
	b.size = size
	b.position = pos
	add_child(b)
	b.add_child(BlockView.new())
	labels.append([pos + Vector2(0, 30), label])


func _platform(pos: Vector2, params: PlatformParams, size: Vector2) -> UnstablePlatform:
	var p := UnstablePlatform.new()
	p.params = params
	p.size = size
	p.position = pos
	add_child(p)
	var v := PlatformView.new()
	v.rope_length = 40.0
	p.add_child(v)
	return p
