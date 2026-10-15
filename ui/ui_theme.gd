class_name UiTheme
## Tema de interfaz del estilo v1: paneles oscuros con borde cálido, texto claro con contorno.
## Se aplica al HUD y al menú para que sean coherentes con el juego.


static func make() -> Theme:
	var t := Theme.new()
	t.default_font = UiFonts.display()
	t.set_stylebox("normal", "Button", box(ViewPalette.UI_PANEL, ViewPalette.UI_BORDER))
	t.set_stylebox("hover", "Button", box(Color(0.24, 0.11, 0.1, 0.94), ViewPalette.UI_ACCENT))
	t.set_stylebox("pressed", "Button", box(Color(0.42, 0.18, 0.08, 0.96), ViewPalette.UI_ACCENT))
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), ViewPalette.UI_ACCENT, 14, 4))
	t.set_stylebox("disabled", "Button", box(Color(0.1, 0.08, 0.09, 0.6), Color(0.4, 0.35, 0.35)))
	t.set_color("font_color", "Button", ViewPalette.UI_TEXT)
	t.set_color("font_hover_color", "Button", ViewPalette.UI_ACCENT)
	t.set_color("font_pressed_color", "Button", ViewPalette.UI_ACCENT)
	t.set_color("font_focus_color", "Button", ViewPalette.UI_TEXT)
	t.set_color("font_outline_color", "Button", DrawKit.OUTLINE)
	t.set_constant("outline_size", "Button", 5)
	t.set_color("font_color", "Label", ViewPalette.UI_TEXT)
	t.set_color("font_outline_color", "Label", DrawKit.OUTLINE)
	t.set_constant("outline_size", "Label", 5)
	t.set_stylebox("panel", "PanelContainer", box(ViewPalette.UI_PANEL, ViewPalette.UI_BORDER, 16))
	return t


static func box(bg: Color, border: Color, radius := 14, width := 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.anti_aliasing = true
	return s


## Panel dibujado a mano (para Controls que pintan con _draw).
static func draw_panel(ci: CanvasItem, r: Rect2, radius := 12.0) -> void:
	DrawKit.poly(ci, DrawKit.rounded_rect(r, radius, 3), ViewPalette.UI_PANEL, DrawKit.OUTLINE, 5.0)
	var pts := DrawKit.rounded_rect(r.grow(-1.5), radius - 1.5, 3)
	pts.append(pts[0])
	ci.draw_polyline(pts, ViewPalette.UI_BORDER, 2.5, true)
