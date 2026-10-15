class_name CharacterAnimations
## Fotogramas de animación del personaje base (estilo v2). Se dibujan con CharacterRig una
## sola vez por variante y se guardan en una hoja de sprites (CharacterSprites): en juego
## cada personaje es un único rectángulo con textura.
## v2: carrera con contacto/paso y patada trasera, derrape, impulso de salto, ápice,
## aterrizaje con peso (impacto + recuperación), golpe y recuperación del empujón,
## impacto con dos fotogramas, mirada alrededor en reposo.

## Nombre → índices de fotograma en la hoja.
const CLIPS := {
	"idle": [0, 1, 2, 3],
	"blink": [4],
	"run": [5, 6, 7, 8, 9, 10, 11, 12],
	"skid": [13],
	"takeoff": [14],
	"jump": [15],
	"apex": [16],
	"fall": [17, 18],
	"land": [19, 20],        # impacto (aplastado) y recuperación
	"push": [21],            # golpe
	"push_recover": [22],
	"shield": [23],
	"hit": [24, 25],
	"hook": [26, 27, 28],    # brazo a 90°, 135° y 180° (adelante, diagonal, arriba)
	"dead": [29],
	"look": [30],            # en reposo, mira alrededor de vez en cuando
	"hit_land": [31],
}
const FRAME_COUNT := 32
const HOOK_ANGLES := [90.0, 135.0, 180.0]


## Lista de [RigPose, burn, t] para cada fotograma, en orden.
static func frames() -> Array:
	var out := []
	for i in 4:
		out.append([_idle(TAU * i / 4.0, false), 0.0, i * 0.4])
	out.append([_idle(0.0, true), 0.0, 0.0])
	for i in 8:
		out.append([_run(TAU * i / 8.0), 0.0, i * 0.15])
	out.append([_skid(), 0.0, 0.0])
	out.append([_takeoff(), 0.0, 0.0])
	out.append([_jump(), 0.0, 0.0])
	out.append([_apex(), 0.0, 0.2])
	out.append([_fall(1.0), 0.0, 0.0])
	out.append([_fall(-1.0), 0.0, 0.3])
	out.append([_land(1.0), 0.0, 0.0])
	out.append([_land(0.4), 0.0, 0.1])
	out.append([_push(), 0.0, 0.0])
	out.append([_push_recover(), 0.0, 0.0])
	out.append([_shield(), 0.0, 0.0])
	out.append([_hit(0.0), 0.0, 0.0])
	out.append([_hit(1.0), 0.0, 0.13])
	for a in HOOK_ANGLES:
		out.append([_hook(a), 0.0, 0.0])
	var dead := _idle(0.0, false)
	dead.eyes = RigPose.Eyes.X
	dead.mouth = RigPose.Mouth.OPEN
	out.append([dead, 1.0, 0.0])
	out.append([_look(), 0.0, 0.0])
	out.append([_land(0.8), 0.0, 0.0])
	return out


static func _idle(phase: float, blink: bool) -> RigPose:
	var p := RigPose.new()
	var b := sin(phase)
	p.bob = b * 1.4
	p.squash = Vector2(1.0 + b * 0.015, 1.0 - b * 0.015)   # respiración
	p.arm_back = -12.0 + b * 4.0
	p.arm_front = 12.0 - b * 4.0
	p.leg_back = -6.0
	p.leg_front = 6.0
	p.head_tilt = b * 2.0
	p.eyes = RigPose.Eyes.CLOSED if blink else RigPose.Eyes.NORMAL
	return p


static func _look() -> RigPose:
	var p := _idle(0.0, false)
	p.head_tilt = -10.0
	p.lean = -4.0
	p.arm_front = 30.0
	p.mouth = RigPose.Mouth.FLAT
	return p


## Carrera: contacto (piernas abiertas, cuerpo abajo) y paso (pierna trasera recogida, cuerpo arriba).
static func _run(phase: float) -> RigPose:
	var p := RigPose.new()
	var s := sin(phase)
	var c := cos(phase)
	p.leg_front = s * 58.0
	p.leg_back = -s * 58.0
	p.tuck_back = maxf(c, 0.0) * 0.9      # la pierna que vuelve se recoge (patada)
	p.tuck_front = maxf(-c, 0.0) * 0.9
	p.arm_front = -s * 70.0
	p.arm_back = s * 70.0
	p.lean = 16.0
	p.bob = -absf(c) * 4.0 + 1.0
	p.squash = Vector2(1.0 - absf(c) * 0.04, 1.0 + absf(c) * 0.05)
	p.head_tilt = s * 3.0
	p.scarf_stream = 1.0
	p.eyes = RigPose.Eyes.DETERMINED
	return p


static func _skid() -> RigPose:
	var p := RigPose.new()
	p.lean = -18.0
	p.leg_front = 40.0
	p.leg_back = -10.0
	p.tuck_back = 0.6
	p.arm_front = 140.0
	p.arm_back = 60.0
	p.squash = Vector2(1.08, 0.93)
	p.scarf_stream = 0.6
	p.eyes = RigPose.Eyes.WIDE
	p.mouth = RigPose.Mouth.GRIT
	return p


static func _takeoff() -> RigPose:
	var p := RigPose.new()
	p.squash = Vector2(0.84, 1.2)
	p.leg_front = 8.0
	p.leg_back = -24.0
	p.tuck_back = 0.4
	p.arm_front = 170.0
	p.arm_back = 190.0
	p.lean = 6.0
	p.scarf_lift = -1.0
	p.mouth = RigPose.Mouth.OPEN
	return p


static func _jump() -> RigPose:
	var p := RigPose.new()
	p.leg_front = 55.0
	p.leg_back = -20.0
	p.leg_tuck = 1.0
	p.arm_front = 165.0
	p.arm_back = 200.0
	p.squash = Vector2(0.92, 1.1)
	p.scarf_lift = -1.0
	p.mouth = RigPose.Mouth.OPEN
	return p


static func _apex() -> RigPose:
	var p := RigPose.new()
	p.leg_front = 35.0
	p.leg_back = -10.0
	p.leg_tuck = 0.8
	p.arm_front = 120.0
	p.arm_back = 145.0
	p.squash = Vector2(1.04, 0.97)
	p.scarf_lift = 0.3
	p.eyes = RigPose.Eyes.WIDE
	p.mouth = RigPose.Mouth.SMILE
	return p


static func _fall(w: float) -> RigPose:
	var p := RigPose.new()
	p.leg_front = 18.0 + w * 12.0
	p.leg_back = -18.0 - w * 12.0
	p.leg_tuck = 0.15
	p.arm_front = 135.0 + w * 22.0
	p.arm_back = 215.0 - w * 22.0
	p.squash = Vector2(0.96, 1.05)
	p.scarf_lift = 1.0
	p.eyes = RigPose.Eyes.WIDE
	p.mouth = RigPose.Mouth.OPEN
	return p


## Aterrizaje: k = 1 impacto (aplastado, rodillas flexionadas), menor = recuperación.
static func _land(k: float) -> RigPose:
	var p := RigPose.new()
	p.squash = Vector2(1.0 + 0.22 * k, 1.0 - 0.24 * k)
	p.leg_front = 30.0 * k
	p.leg_back = -30.0 * k
	p.leg_tuck = 0.7 * k
	p.arm_front = 60.0 * k + 10.0
	p.arm_back = 70.0 * k - 10.0
	p.lean = 8.0 * k
	p.bob = 2.0 * k
	p.scarf_lift = 0.6 * k
	p.eyes = RigPose.Eyes.CLOSED if k > 0.9 else RigPose.Eyes.NORMAL
	p.mouth = RigPose.Mouth.FLAT
	return p


static func _push() -> RigPose:
	var p := RigPose.new()
	p.lean = 26.0
	p.arm_front = 98.0
	p.arm_back = 86.0
	p.arm_reach = 10.0
	p.leg_front = 42.0
	p.leg_back = -46.0
	p.tuck_back = 0.3
	p.squash = Vector2(1.12, 0.93)
	p.scarf_stream = 1.0
	p.eyes = RigPose.Eyes.DETERMINED
	p.mouth = RigPose.Mouth.GRIT
	return p


static func _push_recover() -> RigPose:
	var p := RigPose.new()
	p.lean = 10.0
	p.arm_front = 60.0
	p.arm_back = 40.0
	p.arm_reach = 2.0
	p.leg_front = 24.0
	p.leg_back = -26.0
	p.squash = Vector2(1.03, 0.98)
	p.scarf_stream = 0.5
	p.eyes = RigPose.Eyes.DETERMINED
	p.mouth = RigPose.Mouth.SMILE
	return p


static func _shield() -> RigPose:
	var p := RigPose.new()
	p.squash = Vector2(1.1, 0.9)
	p.lean = -6.0
	p.arm_front = 100.0
	p.arm_back = 118.0
	p.arm_reach = -2.0
	p.leg_front = 22.0
	p.leg_back = -22.0
	p.eyes = RigPose.Eyes.DETERMINED
	p.mouth = RigPose.Mouth.FLAT
	return p


## Impacto: k = 0 golpe (cuerpo doblado hacia atrás), 1 mareado.
static func _hit(k: float) -> RigPose:
	var p := RigPose.new()
	p.lean = -28.0 + k * 8.0
	p.head_tilt = -24.0 + k * 10.0
	p.arm_front = 205.0 - k * 20.0
	p.arm_back = -60.0
	p.leg_front = -28.0
	p.leg_back = 30.0
	p.squash = Vector2(0.86 + k * 0.08, 1.12 - k * 0.08)
	p.scarf_lift = 0.6
	p.eyes = RigPose.Eyes.CLOSED if k < 0.5 else RigPose.Eyes.DIZZY
	p.mouth = RigPose.Mouth.OPEN if k < 0.5 else RigPose.Mouth.WAVY
	return p


static func _hook(arm: float) -> RigPose:
	var p := RigPose.new()
	p.arm_front = arm
	p.arm_reach = 6.0
	p.arm_back = -30.0
	p.lean = 12.0
	p.leg_front = -28.0
	p.leg_back = -46.0
	p.leg_tuck = 0.3
	p.squash = Vector2(0.94, 1.08)
	p.scarf_stream = 1.0
	p.eyes = RigPose.Eyes.DETERMINED
	p.mouth = RigPose.Mouth.GRIT
	return p
