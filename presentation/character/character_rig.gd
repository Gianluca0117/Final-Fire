class_name CharacterRig
## Dibujo del personaje base (estilo cartoon, contorno grueso) a partir de una RigPose y un
## CharacterLook. Coordenadas locales del personaje mirando a la DERECHA: origen en el centro
## de la colisión (40×56), pies en y = 28. La vista aplica el giro (facing) y la deformación.
## No toca la simulación ni las colisiones.

const FEET_Y := 28.0
const HIP_Y := 13.0
const CHARCOAL := Color("2a1a1c")
const BOOT := Color("3b2620")
const ARM_LEN := 13.0


## Dibuja el personaje completo. `burn` (0..1) lo carboniza al ser eliminado.
static func draw(ci: CanvasItem, pose: RigPose, look: CharacterLook, t: float, burn := 0.0) -> void:
	var hip := Vector2(0, HIP_Y + pose.bob)
	var lean := deg_to_rad(pose.lean)
	var body := Transform2D(lean, hip)
	var main := _c(look.main, burn)
	var dark := _c(look.dark, burn)
	var light := _c(look.light, burn)

	_scarf(ci, body, pose, look, t, burn)
	# Pierna y brazo traseros (más oscuros para dar profundidad)
	_leg(ci, hip + Vector2(-4, 0), pose.leg_back, pose.leg_tuck + pose.tuck_back, _c(look.dark.darkened(0.25), burn), burn)
	_arm(ci, body * Vector2(-7, -11), pose.arm_back - pose.lean, ARM_LEN + pose.arm_reach, dark.darkened(0.2), burn)
	# Torso: túnica con cinturón y detalle de pecho
	var torso := body * DrawKit.rounded_rect(Rect2(-12, -16, 24, 19), 7.0, 3)
	ci.draw_colored_polygon(torso, main)
	ci.draw_colored_polygon(body * DrawKit.rounded_rect(Rect2(-12, -16, 9, 19), 5.0, 2), dark.lerp(main, 0.35))
	DrawKit.poly(ci, torso, Color(0, 0, 0, 0))
	var belt := body * PackedVector2Array([Vector2(-10.5, -3.5), Vector2(10.5, -3.5), Vector2(10.5, 0.5), Vector2(-10.5, 0.5)])
	ci.draw_colored_polygon(belt, dark)
	ci.draw_colored_polygon(body * DrawKit.rounded_rect(Rect2(-3, -4.5, 6, 6), 1.5, 2), _c(Color("e8c25a"), burn))
	if look.accessory == CharacterLook.Accessory.POMPOM:
		var bolt := PackedVector2Array([Vector2(1, -14), Vector2(-3, -8.5), Vector2(0, -8.5), Vector2(-2, -5), Vector2(3.5, -10), Vector2(0.5, -10)])
		ci.draw_colored_polygon(body * bolt, _c(look.accent, burn))
	ci.draw_colored_polygon(body * PackedVector2Array([Vector2(-9, -15), Vector2(-2, -15), Vector2(-9, -8)]), Color(light, 0.55))
	# Pierna delantera, cabeza y brazo delantero
	_leg(ci, hip + Vector2(4, 0), pose.leg_front, pose.leg_tuck + pose.tuck_front, _c(look.dark.darkened(0.1), burn), burn)
	var neck := body * Vector2(0, -17)
	var head := Transform2D(lean + deg_to_rad(pose.head_tilt), neck) * Transform2D(0, Vector2(0, -10))
	var raised := absf(pose.arm_front) > 110.0
	if raised:
		_arm(ci, body * Vector2(7, -11), pose.arm_front - pose.lean, ARM_LEN + pose.arm_reach, main, burn)
	draw_head(ci, head, pose, look, t, burn)
	if not raised:
		_arm(ci, body * Vector2(7, -11), pose.arm_front - pose.lean, ARM_LEN + pose.arm_reach, main, burn)


## Cabeza (capucha, cara, expresión y accesorio). También la usa el HUD a tamaño pequeño.
static func draw_head(ci: CanvasItem, xf: Transform2D, pose: RigPose, look: CharacterLook, t: float, burn := 0.0) -> void:
	var main := _c(look.main, burn)
	var dark := _c(look.dark, burn)
	var light := _c(look.light, burn)
	var accent := _c(look.accent, burn)
	var acc := look.accessory
	# Detrás de la capucha: punta / aletas
	match acc:
		CharacterLook.Accessory.HEADBAND:
			DrawKit.poly(ci, xf * PackedVector2Array([Vector2(-8, -12), Vector2(-19, -19), Vector2(-14, -6)]), main)
		CharacterLook.Accessory.POMPOM:
			DrawKit.poly(ci, xf * PackedVector2Array([Vector2(-6, -13), Vector2(-17, -24), Vector2(-14, -8)]), main)
			DrawKit.circle(ci, xf * Vector2(-17.5, -25.0), 4.6, accent)
		CharacterLook.Accessory.MASK:
			var sway := sin(t * 3.0) * 2.0
			DrawKit.poly(ci, xf * PackedVector2Array([Vector2(-6, -14), Vector2(-20, -10 + sway), Vector2(-26, 2 + sway), Vector2(-21, 4 + sway), Vector2(-15, -2), Vector2(-12, -4)]), main)
		CharacterLook.Accessory.FINS:
			for s in [-1.0, 1.0]:
				var base := Vector2(s * 13.0, -3.0)
				DrawKit.poly(ci, xf * PackedVector2Array([base + Vector2(0, -6), base + Vector2(s * 9.0, -9), base + Vector2(s * 6.0, 4), base + Vector2(0, 4)]), accent)
		CharacterLook.Accessory.SPROUT:
			ci.draw_line(xf * Vector2(-1, -15), xf * Vector2(-2, -21), DrawKit.OUTLINE, 3.0)
			DrawKit.poly(ci, xf * DrawKit.ellipse(Vector2(-7, -22), 6.0, 3.0, 10), accent, DrawKit.OUTLINE, 2.0)
			DrawKit.poly(ci, xf * DrawKit.ellipse(Vector2(3, -23), 5.0, 2.6, 10), accent.lightened(0.15), DrawKit.OUTLINE, 2.0)
	# Capucha
	var hood := xf * DrawKit.ellipse(Vector2.ZERO, 16.5, 15.5, 22)
	ci.draw_colored_polygon(hood, main)
	ci.draw_colored_polygon(xf * DrawKit.ellipse(Vector2(-6.5, 2.0), 10.0, 13.2, 16), dark.lerp(main, 0.3))
	DrawKit.poly(ci, hood, Color(0, 0, 0, 0))
	ci.draw_colored_polygon(xf * DrawKit.ellipse(Vector2(-6, -7), 5.0, 3.0, 10), Color(light, 0.6))
	# Abertura de la cara
	var face := xf * DrawKit.ellipse(Vector2(3.5, 1.5), 11.0, 9.5, 18)
	DrawKit.poly(ci, face, _c(look.skin, burn), dark, 2.0)
	ci.draw_circle(xf * Vector2(-3.0, 5.0), 2.2, Color(1.0, 0.55, 0.55, 0.45 * (1.0 - burn)))
	# Accesorios delante
	match acc:
		CharacterLook.Accessory.HEADBAND:
			ci.draw_line(xf * Vector2(-14, -7), xf * Vector2(14, -8), DrawKit.OUTLINE, 6.0)
			ci.draw_line(xf * Vector2(-14, -7), xf * Vector2(14, -8), accent, 3.5)
			var flow := sin(t * 9.0) * 2.0
			for k in 2:
				var end := Vector2(-24 - k * 3, -5 + k * 6 + flow * (1 - k * 2))
				DrawKit.capsule(ci, xf * Vector2(-14, -7), xf * end, 2.5, accent, DrawKit.OUTLINE, 1.5)
		CharacterLook.Accessory.GOGGLES:
			ci.draw_line(xf * Vector2(-15, -9), xf * Vector2(15, -9), DrawKit.OUTLINE, 3.0)
			for gx in [0.0, 9.0]:
				DrawKit.circle(ci, xf * Vector2(gx, -10.0), 3.8, Color(0.6, 0.85, 1.0).lerp(CHARCOAL, burn), accent, 2.0)
	_eyes(ci, xf, pose.eyes, look, burn, t)
	if acc == CharacterLook.Accessory.MASK:
		var band := xf * DrawKit.rounded_rect(Rect2(-6.5, -4.5, 19, 6.5), 3.0, 2)
		ci.draw_colored_polygon(band, accent)
		_eyes(ci, xf, pose.eyes, look, burn, t, DrawKit.antialias)
	_mouth(ci, xf, pose.mouth, burn)


static func _c(col: Color, burn: float) -> Color:
	return col if burn <= 0.0 else col.lerp(CHARCOAL, burn)


static func _dir(deg: float) -> Vector2:
	var a := deg_to_rad(deg)
	return Vector2(sin(a), cos(a))


static func _arm(ci: CanvasItem, shoulder: Vector2, angle: float, length: float, col: Color, burn: float) -> void:
	var hand := shoulder + _dir(angle) * length
	DrawKit.capsule(ci, shoulder, hand, 6.5, col)
	DrawKit.circle(ci, hand, 4.0, _c(Color("ffd9b8"), burn), DrawKit.OUTLINE, 2.0)


static func _leg(ci: CanvasItem, hip: Vector2, angle: float, tuck: float, col: Color, burn: float) -> void:
	var knee := hip + _dir(angle) * 6.0
	var foot := knee + _dir(angle - tuck * 95.0) * 6.0
	DrawKit.capsule(ci, hip, knee, 6.5, col)
	DrawKit.capsule(ci, knee, foot, 6.0, col)
	var boot := DrawKit.ellipse(foot + Vector2(2.0, 1.5), 5.4, 3.6, 10)
	DrawKit.poly(ci, boot, _c(BOOT, burn), DrawKit.OUTLINE, 2.0)
	ci.draw_line(foot + Vector2(0.0, 0.0), foot + Vector2(4.0, 0.0), Color(1, 1, 1, 0.25 * (1.0 - burn)), 1.5)


static func _scarf(ci: CanvasItem, body: Transform2D, pose: RigPose, look: CharacterLook, t: float, burn: float) -> void:
	var neck := body * Vector2(0, -15)
	var col := _c(look.dark if look.accessory != CharacterLook.Accessory.FINS else look.accent, burn)
	var stripe := _c(look.main, burn)
	var length := 18.0 if look.accessory != CharacterLook.Accessory.SPROUT else 24.0
	var pts := PackedVector2Array()
	var segs := 5
	for i in segs + 1:
		var k := float(i) / segs
		var wave := sin(t * 10.0 - k * 4.0) * (1.5 + 3.0 * pose.scarf_stream) * k
		var back := -length * k * (0.35 + 0.65 * pose.scarf_stream)
		var down := length * k * (0.75 - 0.75 * pose.scarf_stream) - pose.scarf_lift * 10.0 * k
		pts.append(neck + Vector2(back, down + wave))
	for i in range(pts.size() - 1):
		var w := lerpf(7.0, 4.0, float(i) / segs)
		var c := stripe if look.accessory == CharacterLook.Accessory.FINS and i % 2 == 1 else col
		DrawKit.capsule(ci, pts[i], pts[i + 1], w, c, DrawKit.OUTLINE, 2.0)
	# Nudo del cuello
	ci.draw_colored_polygon(body * DrawKit.rounded_rect(Rect2(-9, -18, 18, 5), 2.5, 2), col)


static func _eyes(ci: CanvasItem, xf: Transform2D, eyes: RigPose.Eyes, look: CharacterLook, burn: float, t: float, mask_pass := false) -> void:
	var white := Color(1, 1, 1).lerp(Color(0.6, 0.55, 0.55), burn)
	var ink := DrawKit.OUTLINE
	for ex in [-0.5, 7.5]:
		var c := xf * Vector2(ex, 0.0)
		match eyes:
			RigPose.Eyes.CLOSED:
				ci.draw_line(c + xf.basis_xform(Vector2(-3, 0)), c + xf.basis_xform(Vector2(3, 0)), ink, 2.0, DrawKit.antialias)
			RigPose.Eyes.X:
				ci.draw_line(c + xf.basis_xform(Vector2(-3, -3)), c + xf.basis_xform(Vector2(3, 3)), ink if burn < 0.5 else Color(1, 0.8, 0.6), 2.2, DrawKit.antialias)
				ci.draw_line(c + xf.basis_xform(Vector2(-3, 3)), c + xf.basis_xform(Vector2(3, -3)), ink if burn < 0.5 else Color(1, 0.8, 0.6), 2.2, DrawKit.antialias)
			RigPose.Eyes.DIZZY:
				ci.draw_circle(c, 3.6, white)
				ci.draw_arc(c, 2.4, t * 12.0, t * 12.0 + PI * 1.5, 8, ink, 1.6, DrawKit.antialias)
			_:
				var ry := 5.0
				var rx := 3.6
				var pupil := 2.3
				if eyes == RigPose.Eyes.WIDE:
					ry = 5.6
					rx = 4.2
					pupil = 1.5
				elif eyes == RigPose.Eyes.DETERMINED:
					ry = 3.8
				if not mask_pass:
					ci.draw_colored_polygon(xf * DrawKit.ellipse(Vector2(ex, 0.0), rx, ry, 12), white)
				ci.draw_circle(xf * Vector2(ex + 0.9, 0.4), pupil, ink)
				ci.draw_circle(xf * Vector2(ex + 1.6, -0.8), 0.8, Color(1, 1, 1, 0.9))
				if eyes == RigPose.Eyes.DETERMINED:
					var y := -4.8
					ci.draw_line(xf * Vector2(ex - 3.2, y - (1.4 if ex < 3.0 else -1.4)), xf * Vector2(ex + 3.2, y + (1.4 if ex < 3.0 else -1.4)), ink, 2.2, DrawKit.antialias)


static func _mouth(ci: CanvasItem, xf: Transform2D, mouth: RigPose.Mouth, burn: float) -> void:
	var ink := DrawKit.OUTLINE
	var c := Vector2(4.5, 6.0)
	match mouth:
		RigPose.Mouth.SMILE:
			ci.draw_polyline(xf * PackedVector2Array([c + Vector2(-2.5, -0.5), c + Vector2(0, 1.2), c + Vector2(2.5, -0.5)]), ink, 1.8, DrawKit.antialias)
		RigPose.Mouth.OPEN:
			DrawKit.poly(ci, xf * DrawKit.ellipse(c + Vector2(0, 0.5), 2.6, 2.2, 10), Color(0.45, 0.1, 0.12).lerp(CHARCOAL, burn), ink, 1.5)
		RigPose.Mouth.GRIT:
			DrawKit.poly(ci, xf * PackedVector2Array([c + Vector2(-3, -1.3), c + Vector2(3, -1.3), c + Vector2(3, 1.5), c + Vector2(-3, 1.5)]), Color(1, 1, 1).lerp(CHARCOAL, burn), ink, 1.5)
			ci.draw_line(xf * (c + Vector2(-3, 0.1)), xf * (c + Vector2(3, 0.1)), ink, 1.0)
		RigPose.Mouth.WAVY:
			ci.draw_polyline(xf * PackedVector2Array([c + Vector2(-3, 0), c + Vector2(-1.5, -1), c + Vector2(0, 0), c + Vector2(1.5, 1), c + Vector2(3, 0)]), ink, 1.6, DrawKit.antialias)
		RigPose.Mouth.FLAT:
			ci.draw_line(xf * (c + Vector2(-2.5, 0)), xf * (c + Vector2(2.5, 0)), ink, 1.8, DrawKit.antialias)
