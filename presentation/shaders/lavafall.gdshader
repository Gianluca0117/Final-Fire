// Cascada de lava del fondo: franjas que bajan. Más apagada que la lava jugable.
shader_type canvas_item;
uniform vec4 a : source_color = vec4(0.85, 0.3, 0.08, 1.0);
uniform vec4 b : source_color = vec4(1.0, 0.6, 0.15, 1.0);
uniform float dim = 0.24;

void fragment() {
	float stripe = sin(UV.x * 18.0 + sin(UV.y * 6.0) * 1.5) * 0.5 + 0.5;
	float flow = sin(UV.y * 40.0 - TIME * 6.0 + UV.x * 5.0) * 0.5 + 0.5;
	vec3 col = mix(a.rgb, b.rgb, stripe * flow);
	float edge = smoothstep(0.0, 0.18, UV.x) * smoothstep(1.0, 0.82, UV.x);
	COLOR = vec4(col * dim, edge * 0.75);
}
