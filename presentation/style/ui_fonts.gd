class_name UiFonts
## Tipografía del estilo: Lilita One (licencia OFL, assets/fonts/OFL.txt) para títulos, HUD
## y etiquetas. Los símbolos que no tiene se toman de la fuente por defecto de Godot.

static var _display: Font


static func display() -> Font:
	if _display == null:
		var f: FontFile = load("res://assets/fonts/LilitaOne-Regular.ttf")
		f.fallbacks = [ThemeDB.fallback_font]
		_display = f
	return _display
