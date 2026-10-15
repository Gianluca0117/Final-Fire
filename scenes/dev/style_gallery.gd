extends Node2D
## Galería de estilo (solo desarrollo, no se exporta): muestra con las vistas REALES del juego
## las 6 variantes del personaje, sus 8 animaciones y las piezas de la arena en cada estado.
## Las piezas no se simulan: se fijan sus estados para poder revisarlos lado a lado.
##   Godot ... --path . --resolution 1280x720 -s res://tools/capture_preview.gd -- gallery docs/previews/estilo.png 1.0

const STATES := [
	["Reposo", Fighter.State.IDLE], ["Correr", Fighter.State.RUN], ["Saltar", Fighter.State.JUMP],
	["Caer", Fighter.State.FALL], ["Empujar", Fighter.State.PUSH], ["Protegerse", Fighter.State.SHIELDED],
	["Impacto", Fighter.State.STUNNED], ["Eliminado", Fighter.State.ELIMINATED],
]

var _eliminated: FighterView
var _labels: Array = []


func _ready() -> void:
	var rules: MatchRules = load("res://data/rules/local_match.tres")
	# Fila 1: las seis variantes en reposo (ampliadas ×2)
	for i in 6:
		var f := _fighter(i, rules.colors[i], Vector2(110 + i * 212, 166), 2.0)
		f.display_name = "J%d" % (i + 1)
		_labels.append([Vector2(110 + i * 212, 252), CharacterLook.NAMES[i]])
	# Fila 2: la variante 0 en cada animación (×1,6)
	for k in STATES.size():
		var pos := Vector2(90 + k * 158, 380)
		var f := _fighter(0, rules.colors[0], pos, 1.6)
		f.display_name = "J1"
		f.state = STATES[k][1]
		if f.state == Fighter.State.RUN:
			f.velocity.x = 360.0
		if f.state == Fighter.State.SHIELDED:
			f._shield = 1000.0   # solo galería: muestra la burbuja de protección
		_labels.append([pos + Vector2(0, 66), STATES[k][0]])
		if f.state == Fighter.State.ELIMINATED:
			_eliminated = f.get_node("View") as FighterView
	_add_arena_section()
	queue_redraw()


func _process(_delta: float) -> void:
	# El eliminado se repite en bucle para poder verlo.
	if _eliminated:
		if _eliminated._burn < 0.0 or _eliminated._burn > 0.45:
			_eliminated._burn = 0.2
			_eliminated.visible = true


func _draw() -> void:
	draw_rect(Rect2(-200, -200, 1680, 1120), Color("1f1218"))
	draw_rect(Rect2(0, 266, 1280, 2), Color(1, 1, 1, 0.08))
	draw_rect(Rect2(0, 462, 1280, 2), Color(1, 1, 1, 0.08))
	DrawKit.text(self, Vector2(0, 24), "Final Fire · estilo v2 provisional (pendiente de aprobación)", 18, ViewPalette.UI_TEXT, 1280)
	for l in _labels:
		DrawKit.text(self, l[0] + Vector2(-80, 0), l[1], 16, ViewPalette.UI_ACCENT, 160)


func _fighter(variant: int, col: Color, pos: Vector2, s: float) -> Fighter:
	var holder := Node2D.new()
	holder.position = pos
	holder.scale = Vector2(s, s)
	add_child(holder)
	var f := Fighter.new()
	f.stats = load("res://data/characters/default_stats.tres")
	f.color = col
	f.participant_id = variant
	holder.add_child(f)
	f.set_physics_process(false)
	var v := FighterView.new()
	v.name = "View"
	v.variant = variant
	f.add_child(v)
	return f


## Sección de arena: plataformas en cada estado, suelo seguro / aviso / lava y lava inferior.
func _add_arena_section() -> void:
	var arena_root := Node2D.new()
	arena_root.name = "ArenaSection"
	add_child(arena_root)
	var section := ArenaSection.new()
	arena_root.add_child(section)
	for item in section.labels:
		_labels.append(item)
