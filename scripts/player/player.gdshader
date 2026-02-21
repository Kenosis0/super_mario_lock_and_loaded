shader_type canvas_item;

uniform vec4 outline1_color : source_color = vec4(0,0,0,1);
uniform float outline1_size_px = 2.0;

uniform bool outline2_enabled = false;
uniform vec4 outline2_color : source_color = vec4(1,1,1,1);
uniform float outline2_size_px = 5.0;

// Negative values pull outline closer / overlap into the fill.
// Typical: -0.02 to -0.10 depending on your viewport resolution.
uniform float overlap = -0.04;

// 0 = crisp, 1..2 = slightly softer (optional)
uniform float edge_softness = 0.0;

float max_neighbor_alpha(sampler2D tex, vec2 uv, vec2 px, float radius_px) {
    vec2 r = px * radius_px;
    float n = 0.0;

    n = max(n, texture(tex, uv + vec2( r.x, 0.0)).a);
    n = max(n, texture(tex, uv + vec2(-r.x, 0.0)).a);
    n = max(n, texture(tex, uv + vec2(0.0,  r.y)).a);
    n = max(n, texture(tex, uv + vec2(0.0, -r.y)).a);

    n = max(n, texture(tex, uv + vec2( r.x,  r.y)).a);
    n = max(n, texture(tex, uv + vec2(-r.x,  r.y)).a);
    n = max(n, texture(tex, uv + vec2( r.x, -r.y)).a);
    n = max(n, texture(tex, uv + vec2(-r.x, -r.y)).a);

    return n;
}

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float a = base.a;

    vec2 px = TEXTURE_PIXEL_SIZE;

    // “inside” with overlap control (negative overlaps into fill)
    float inside = smoothstep(0.0, 0.01, a + overlap);

    float n1 = max_neighbor_alpha(TEXTURE, UV, px, outline1_size_px);
    float o1 = smoothstep(0.0, 0.01 * (edge_softness + 1.0), n1) * (1.0 - inside);

    vec4 col = vec4(0.0);

    if (outline2_enabled) {
        float n2 = max_neighbor_alpha(TEXTURE, UV, px, outline2_size_px);
        float o2 = smoothstep(0.0, 0.01 * (edge_softness + 1.0), n2) * (1.0 - inside);
        col = vec4(outline2_color.rgb, outline2_color.a * o2);
    }

    // inner stroke on top
    col = mix(col, vec4(outline1_color.rgb, outline1_color.a * o1), step(0.0001, o1));

    // base on top
    COLOR = col * (1.0 - inside) + base;
}
