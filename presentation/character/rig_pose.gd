class_name RigPose
extends RefCounted
## Pose del personaje (ángulos en grados, 0 = hacia abajo; positivo = hacia delante).
## Las poses se mezclan entre sí para que los cambios de animación sean suaves.

enum Eyes { NORMAL, DETERMINED, WIDE, DIZZY, CLOSED, X }
enum Mouth { SMILE, OPEN, GRIT, WAVY, FLAT }

var lean := 0.0          ## inclinación del cuerpo
var bob := 0.0           ## desplazamiento vertical del cuerpo
var squash := Vector2.ONE
var head_tilt := 0.0
var arm_back := 0.0
var arm_front := 0.0
var arm_reach := 0.0     ## alargamiento de brazos (empujar, gancho)
var leg_back := 0.0
var leg_front := 0.0
var leg_tuck := 0.0      ## 0 recta, 1 recogida (salto)
var scarf_lift := 0.0    ## -1 cae, 0 normal, 1 hacia arriba
var scarf_stream := 0.0  ## 0 colgando, 1 ondeando hacia atrás
var eyes: Eyes = Eyes.NORMAL
var mouth: Mouth = Mouth.SMILE


func copy() -> RigPose:
	var p := RigPose.new()
	p.lean = lean
	p.bob = bob
	p.squash = squash
	p.head_tilt = head_tilt
	p.arm_back = arm_back
	p.arm_front = arm_front
	p.arm_reach = arm_reach
	p.leg_back = leg_back
	p.leg_front = leg_front
	p.leg_tuck = leg_tuck
	p.scarf_lift = scarf_lift
	p.scarf_stream = scarf_stream
	p.eyes = eyes
	p.mouth = mouth
	return p


## Acerca esta pose a `to` (t = 0..1). La expresión cambia de golpe (más legible).
func blend_to(to: RigPose, t: float) -> void:
	lean = lerpf(lean, to.lean, t)
	bob = lerpf(bob, to.bob, t)
	squash = squash.lerp(to.squash, t)
	head_tilt = lerpf(head_tilt, to.head_tilt, t)
	arm_back = lerpf(arm_back, to.arm_back, t)
	arm_front = lerpf(arm_front, to.arm_front, t)
	arm_reach = lerpf(arm_reach, to.arm_reach, t)
	leg_back = lerpf(leg_back, to.leg_back, t)
	leg_front = lerpf(leg_front, to.leg_front, t)
	leg_tuck = lerpf(leg_tuck, to.leg_tuck, t)
	scarf_lift = lerpf(scarf_lift, to.scarf_lift, t)
	scarf_stream = lerpf(scarf_stream, to.scarf_stream, t)
	eyes = to.eyes
	mouth = to.mouth
