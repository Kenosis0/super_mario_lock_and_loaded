shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float crt_curve = 0.02;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float aperture_grille_rate = 0.4;
uniform float white_noise_rate = 0.02;

float random(vec2 pos){ 
    return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// Curvature
	vec2 cc = uv - 0.5;
	float dist = dot(cc, cc);
	uv += cc * dist * crt_curve;

	// Sample screen
	vec3 col = texture(screen_texture, uv).rgb;

	// Scanlines
	// Colored scanlines (RGB variation)
	float line = sin(uv.y * 800.0);

	// Create slight RGB variation per line
	vec3 scan_color = vec3(
		sin(uv.y * 800.0 + 0.0),
		sin(uv.y * 800.0 + 2.094), // 120° offset
		sin(uv.y * 800.0 + 4.188)  // 240° offset
	);

	// Normalize to 0–1
	scan_color = scan_color * 0.5 + 0.5;

	// Apply intensity
	col *= mix(vec3(1.0), scan_color, scanline_intensity);

	// Noise
	col += (random(uv + TIME) - 0.5) * white_noise_rate;

	COLOR = vec4(col, 1.0);
}