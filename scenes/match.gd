extends Node2D
## Escena de partida local (raíz de composición): une simulación, controladores,
## vistas e interfaz. Es el único sitio que conoce todos los módulos.

signal menu_requested
signal rematch_requested

@onready var arena: Arena = $Arena
@onready var match_ctl: MatchController = $MatchController
@onready var fighters_root: Node2D = $Fighters

var hud: MatchHud
var humans := 1
var dummies := 3
var _configured := false


func _ready() -> void:
	# Si se abre la escena directamente (F6 en el editor), arranca 1 jugador + 3 maniquíes.
	(func() -> void:
		if not _configured:
			configure(1, 3, 0)).call_deferred()


## humans: 1 o 2 jugadores locales; dummies: maniquíes de prueba; seed 0 = aleatoria.
func configure(p_humans: int, p_dummies: int, p_seed := 0) -> void:
	_configured = true
	humans = p_humans
	dummies = p_dummies
	var rng_seed := p_seed if p_seed != 0 else randi()
	var list: Array[Participant] = []
	for i in humans:
		# Con un solo jugador valen las dos combinaciones de teclas; con dos, cada uno la suya.
		var prefixes := PackedStringArray(["p1_", "p2_"]) if humans == 1 else PackedStringArray(["p%d_" % (i + 1)])
		list.append(Participant.new(0, "J%d" % (i + 1), Participant.Kind.HUMAN_LOCAL, HumanController.new(prefixes)))
	for i in dummies:
		list.append(Participant.new(0, "M%d" % (humans + i + 1), Participant.Kind.DUMMY, DummyController.new(rng_seed + 7919 * (i + 1))))
	match_ctl.setup(arena, list, fighters_root, rng_seed)
	ArenaViews.attach(arena, match_ctl.get_fighters(), self)

	hud = MatchHud.new()
	add_child(hud)
	var touch := humans == 1 and (DisplayServer.is_touchscreen_available() or OS.has_feature("mobile"))
	hud.bind(match_ctl, touch)
	hud.rematch_requested.connect(func() -> void: rematch_requested.emit())
	hud.menu_requested.connect(func() -> void: menu_requested.emit())
	match_ctl.start()


func toggle_pause() -> void:
	if hud:
		hud.toggle_pause()
