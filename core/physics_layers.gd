class_name PhysicsLayers
## Capas de colisión (nombres en project.godot → layer_names).

const WORLD := 1        ## capa 1 "mundo": suelo, plataformas, bloques
const FIGHTERS := 2     ## capa 2 "personajes"


## true si se ejecuta sin gráficos (servidor dedicado o pruebas headless).
static func is_headless() -> bool:
	return OS.has_feature("dedicated_server") or DisplayServer.get_name() == "headless"
