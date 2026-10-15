extends Node
## Punto de entrada: menú ↔ partida local.

const MATCH_SCENE := preload("res://scenes/match.tscn")

var _menu: MainMenu
var _match: Node2D
var _last := Vector2i(1, 3)


func _ready() -> void:
	get_tree().set_auto_accept_quit(true)
	_show_menu()


func _notification(what: int) -> void:
	# Botón «atrás» de Android: en partida pausa; en el menú sale.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _match:
			_match.toggle_pause()
		else:
			get_tree().quit()


func _show_menu() -> void:
	_free_match()
	_menu = MainMenu.new()
	_menu.start_requested.connect(_start)
	add_child(_menu)


func _start(humans: int, dummies: int) -> void:
	_last = Vector2i(humans, dummies)
	if _menu:
		_menu.queue_free()
		_menu = null
	_free_match()
	get_tree().paused = false
	_match = MATCH_SCENE.instantiate()
	add_child(_match)
	_match.configure(humans, dummies)
	_match.menu_requested.connect(_show_menu, CONNECT_DEFERRED)
	_match.rematch_requested.connect(func() -> void: _start(_last.x, _last.y), CONNECT_DEFERRED)


func _free_match() -> void:
	if _match:
		_match.queue_free()
		_match = null
