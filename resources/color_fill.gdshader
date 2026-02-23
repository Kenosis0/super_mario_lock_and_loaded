shader_type canvas_item;

uniform vec4 fill_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fill_amount : hint_range(0.0, 1.0) = 1.0; 
// 0 = original texture, 1 = fully filled

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Blend texture -> solid fill
    vec3 rgb = mix(tex.rgb, fill_color.rgb, fill_amount);

    // Keep original sprite shape / transparency
    COLOR = vec4(rgb, tex.a);
}