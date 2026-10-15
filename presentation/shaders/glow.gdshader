// Resplandor vertical (de abajo hacia arriba) que se desvanece: brillo de la lava.
shader_type canvas_item;
uniform vec4 tint : source_color = vec4(1.0, 0.45, 0.1, 1.0);
uniform float strength = 0.28;

void fragment() {
	float a = pow(UV.y, 2.2) * strength;
	COLOR = vec4(tint.rgb, a);
}
