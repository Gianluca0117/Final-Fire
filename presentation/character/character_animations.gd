class_name CharacterAnimations
## Fotogramas de animación del personaje base (estilo v1). Se dibujan con CharacterRig una
## sola vez por variante y se guardan en una hoja de sprites (CharacterSprites): en juego
## cada personaje es un único rectángulo con textura.

## Nombre → índices de fotograma en la hoja.
const CLIPS := {
	"idle": [0, 1, 2, 3],
	"blink": [4],
	"run": [5, 6, 7, 8, 9, 10, 11, 12],
	"jump": [13],
	"fall": [14, 15],
	"push": [16],
	"shield": [17],
	"hit": [18, 19],
	"hook": [20, 21, 22],   # brazo a 90°, 135° y 180° (adelante, diagonal, arriba)
	"dead": [23],
}
const FRAME_COUNT := 24
const HOOK_ANGLES := [90.0, 135.0, 180.0]


## Lista de [RigPose, burn, t] para cada fotograma, en orden.
static func frames() -> Array:
	var out := []
	for i in 4:
		out.append([_idle(TAU * i / 4.0, false), 0.0, i * 0.4])
	out.append([_idle(0.0, true), 0.0, 0.0])
	for i in 8:
		out.append([_run(TAU * i / 8.0), 0.0, i * 0.15])
	out.append([_jump(), 0.0, 0.0])
	out.append([_fall(1.0), 0.0, 0.0])
	out.append([_fall(-1.0), 0.0, 0.3])
	out.append([_push(), 0.0, 0.0])
	out.append([_shield(), 0.0, 0.0])
	out.append([_hit(), 0.0, 0.0])
	out.append([_hit(), 0.0, 0.13])
	for a in HOOK_ANGLES:
		out.append([_hook(a), 0.0, 0.0])
	var dead := _idle(0.0, false)
	dead.eyes = RigPose.Eyes.X
	dead.mouth = RigPose.Mouth.OPEN
	out.append([dead, 1.0, 0.0])
	return out


static func _idle(phase: float, blink: bool) -> RigPose:
	var p := RigPose.new()
	var b := sin(phase)
	p.bob = b * 1.2
	p.arm_back = -10.0 + b * 4.0
	p.arm_front = 10.0 - b * 4.0
	p.leg_back = -5.0
	p.leg_front = 5.0
	p.eyes = RigPose.Eyes.CLOSED if blink else RigPose.Eyes.NORMAL
	return p


static func _run(phase: float) -> RigPose:
	var p := RigPose.new()
	var s := sin(phase)
	p.leg_front = s * 50.0
	p.leg_back = -s * 50.0
	p.leg_tuck = 0.45
	p.arm_front = -s * 62.0
	p.arm_back = s * 62.0
	p.lean = 15.0
	p.bob = -absf(cos(phase)) * 3.5
	p.scarf_stream = 1.0
	return p


static func _jump() -> RigPose:
	var p := RigPose.new()
	p.leg_front = 55.0
	p.leg_back = -20.0
	p.leg_tuck = 1.0
	p.arm_front = 165.0
	p.arm_back = 200.0
	p.squash = Vector2(0.9, 1.12)
	p.scarf_lift = -1.0
	p.mouth = RigPose.Mouth.OPEN
	return p


static func _fall(w: float) -> RigPose:
	var p := RigPose.new()
	p.leg_front = 18.0 + w * 12.0
	p.leg_back = -18.0 - w * 12.0
	p.leg_tuck = 0.15
	p.arm_front = 135.0 + w * 22.0
	p.arm_back = 215.0 - w * 22.0
	p.scarf_lift = 1.0
	p.eyes = RigPose.Eyes.WIDE
	p.mouth = RigPose.Mouth.OPEN
	return p


static func _push() -> RigPose:
	var p := RigPose.new()
	p.lean = 24.0
	p.arm_front = 98.0
	p.arm_back = 86.0
	p.arm_reach = 9.0
	p.leg_front = 38.0
	p.leg_back = -42.0
	p.squash = Vector2(1.08, 0.95)
	p.scarf_stream = 0.8
	p.eyes = RigPose.Eyes.DETERMINED
	p.mouth = RigPose.Mouth.GRIT
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


static func _hit() -> RigPose:
	var p := RigPose.new()
	p.lean = -22.0
	p.head_tilt = -20.0
	p.arm_front = 200.0
	p.arm_back = -55.0
	p.leg_front = -24.0
	p.leg_back = 28.0
	p.scarf_lift = 0.5
	p.eyes = RigPose.Eyes.DIZZY
	p.mouth = RigPose.Mouth.WAVY
	return p


static func _hook(arm: float) -> RigPose:
	var p := RigPose.new()
	p.arm_front = arm
	p.arm_reach = 5.0
	p.arm_back = -30.0
	p.lean = 10.0
	p.leg_front = -28.0
	p.leg_back = -44.0
	p.leg_tuck = 0.3
	p.scarf_stream = 1.0
	p.eyes = RigPose.Eyes.DETERMINED
	p.mouth = RigPose.Mouth.GRIT
	return p
