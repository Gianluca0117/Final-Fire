// Lava animada en un solo rectángulo (barata en móviles): oleaje en el borde superior,
// cresta brillante, vetas calientes que se mueven y burbujas que revientan.
shader_type canvas_item;

uniform vec4 deep : source_color = vec4(0.66, 0.11, 0.05, 1.0);
uniform vec4 body : source_color = vec4(1.0, 0.35, 0.08, 1.0);
uniform vec4 hot : source_color = vec4(1.0, 0.7, 0.12, 1.0);
uniform vec4 crest : source_color = vec4(1.0, 0.94, 0.65, 1.0);
uniform vec2 size = vec2(1760.0, 600.0);
uniform float surface = 14.0;

float hash(float n) { return fract(sin(n) * 43758.5453); }

void fragment() {
	vec2 px = UV * size;
	float wave = surface + sin(px.x * 0.028 + TIME * 2.1) * 4.0 + sin(px.x * 0.071 - TIME * 1.4) * 2.0;
	float d = px.y - wave;
	if (d < 0.0) {
		discard;
	}
	vec3 col = mix(hot.rgb, body.rgb, smoothstep(2.0, 26.0, d));
	col = mix(col, deep.rgb, smoothstep(26.0, 120.0, d));
	// Vetas calientes en movimiento
	float n = sin(px.x * 0.045 + TIME * 0.8 + sin(px.y * 0.09 + TIME * 0.6) * 2.0) * sin(px.y * 0.07 - TIME * 0.9);
	col = mix(col, hot.rgb, smoothstep(0.55, 0.85, n) * (1.0 - smoothstep(10.0, 140.0, d)) * 0.8);
	// Cresta brillante con contorno oscuro justo encima
	col = mix(col, crest.rgb, 1.0 - smoothstep(0.0, 3.5, d));
	// Burbujas
	for (int i = 0; i < 8; i++) {
		float fi = float(i);
		float cycle = fract(TIME * (0.25 + hash(fi) * 0.25) + hash(fi + 3.1));
		vec2 c = vec2(hash(fi * 7.3) * size.x, wave + 18.0 - cycle * 16.0);
		float r = 2.0 + cycle * 4.0;
		float dist = length(px - c);
		float ring = 1.0 - smoothstep(0.0, 1.5, abs(dist - r));
		col = mix(col, crest.rgb, ring * (1.0 - cycle));
	}
	COLOR = vec4(col, 1.0);
}
