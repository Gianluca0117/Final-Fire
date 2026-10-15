class_name VfxLayer
extends Node2D
## Efectos breves (estilo v1): polvo al aterrizar, impacto del empujón, destello al recoger
## la herramienta y humo al ser eliminado. Reglas para no estorbar:
## - duran ≤ 0,8 s, son semitransparentes (alfa ≤ 0,6) y pequeños (≤ 44 px de radio);
## - se dibujan por DEBAJO de la capa de avisos (z 9) y de la interfaz;
## - solo redibuja mientras hay partículas vivas.
## Solo escucha señales; no cambia la simulación.

const Z := 6
const MAX_ALPHA := 0.6
const MAX_RADIUS := 44.0

var _p: Array[Dictionary] = []


func _init() -> void:
	name = "VfxLayer"
	z_index = Z


func bind(match_ctl: MatchController) -> void:
	for f in match_ctl.get_fighters():
		var fighter := f
		fighter.landed.connect(func() -> void: dust(fighter.global_position + Vector2(0, 28)))
		fighter.pushed.connect(func(targets: Array) -> void:
			for t in targets:
				impact((fighter.global_position + (t as Fighter).global_position) * 0.5 + Vector2(0, -4), fighter.facing))
		fighter.eliminated.connect(func(_c: StringName, _by: Fighter) -> void: smoke(fighter.global_position))
	match_ctl.tools.tool_picked.connect(func(def: ToolDefinition, by: Participant) -> void:
		sparkle(by.fighter.global_position + Vector2(0, -10), ToolIcons.color_of(def.kind)))
	match_ctl.tools.tool_used.connect(func(def: ToolDefinition, _by: Participant, target: ToolTarget) -> void:
		sparkle(target.point, ToolIcons.color_of(def.kind)))


func dust(pos: Vector2) -> void:
	for i in 6:
		var dir := -1.0 if i % 2 == 0 else 1.0
		_add({"k": "dust", "pos": pos + Vector2(dir * 4.0, -2.0), "vel": Vector2(dir * randf_range(50, 110), randf_range(-30, -10)), "life": 0.35, "max": 0.35, "r": randf_range(3.0, 5.0)})


func impact(pos: Vector2, dir: int) -> void:
	_add({"k": "impact", "pos": pos, "dir": dir, "life": 0.22, "max": 0.22})


func sparkle(pos: Vector2, col: Color) -> void:
	_add({"k": "ring", "pos": pos, "col": col, "life": 0.4, "max": 0.4})
	for i in 8:
		var a := TAU * i / 8.0
		_add({"k": "spark", "pos": pos, "vel": Vector2(cos(a), sin(a)) * 110.0, "col": col, "life": 0.4, "max": 0.4})


func smoke(pos: Vector2) -> void:
	for i in 6:
		_add({"k": "smoke", "pos": pos + Vector2(randf_range(-14, 14), randf_range(-10, 10)), "vel": Vector2(randf_range(-15, 15), randf_range(-70, -40)), "life": 0.8, "max": 0.8, "r": randf_range(6.0, 10.0)})
	for i in 6:
		_add({"k": "ember", "pos": pos, "vel": Vector2(randf_range(-60, 60), randf_range(-140, -60)), "life": 0.7, "max": 0.7})


func _add(p: Dictionary) -> void:
	if _p.size() < 120:
		_p.append(p)


func _process(delta: float) -> void:
	if _p.is_empty():
		return
	for p in _p:
		p.life -= delta
		if p.has("vel"):
			p.pos += p.vel * delta
			if p.k == "ember":
				p.vel.y += 200.0 * delta
	_p = _p.filter(func(p: Dictionary) -> bool: return p.life > 0.0)
	queue_redraw()


func _draw() -> void:
	for p in _p:
		var t: float = 1.0 - p.life / p.max   # 0 → 1
		match p.k:
			"dust":
				draw_circle(p.pos, minf(p.r + t * 6.0, MAX_RADIUS), Color(ViewPalette.DUST, MAX_ALPHA * (1.0 - t)))
			"impact":
				var r := 10.0 + t * 22.0
				for i in 7:
					var a := -PI * 0.5 + (i - 3) * 0.4
					var d := Vector2(cos(a) * p.dir, sin(a))
					draw_line(p.pos + d * r * 0.5, p.pos + d * r, Color(1, 0.95, 0.7, MAX_ALPHA * (1.0 - t)), 3.0)
				draw_circle(p.pos, 6.0 * (1.0 - t), Color(1, 1, 1, MAX_ALPHA))
			"ring":
				draw_arc(p.pos, minf(10.0 + t * 34.0, MAX_RADIUS), 0, TAU, 28, Color(p.col, MAX_ALPHA * (1.0 - t)), 3.0, true)
			"spark":
				DrawKit.poly(self, DrawKit.star_points(p.pos, 4.0 * (1.0 - t) + 1.0, 1.6, 4, t * 3.0), Color(p.col, MAX_ALPHA * (1.0 - t) + 0.2), Color(0, 0, 0, 0), 0.0)
			"smoke":
				draw_circle(p.pos, minf(p.r + t * 10.0, MAX_RADIUS), Color(0.18, 0.12, 0.14, 0.5 * (1.0 - t)))
			"ember":
				draw_circle(p.pos, 2.0, Color(1.0, 0.6, 0.2, MAX_ALPHA * (1.0 - t) + 0.3))
