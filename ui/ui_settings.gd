class_name UiSettings
## Ajustes del jugador guardados en el dispositivo (user://settings.cfg).
## Controles táctiles: tamaño (75–130 %) y opacidad (25–100 %).

const PATH := "user://settings.cfg"

static var touch_scale := 1.0
static var touch_opacity := 0.6
static var _loaded := false


static func load_settings() -> void:
	if _loaded:
		return
	_loaded = true
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		touch_scale = clampf(cfg.get_value("touch", "scale", 1.0), 0.75, 1.3)
		touch_opacity = clampf(cfg.get_value("touch", "opacity", 0.6), 0.25, 1.0)


static func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("touch", "scale", touch_scale)
	cfg.set_value("touch", "opacity", touch_opacity)
	cfg.save(PATH)
