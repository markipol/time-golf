shader_type spatial;

uniform float min_scale = 0.2;
uniform float mid_scale = 0.6;
uniform float max_scale = 1.0;

uniform vec3 col_min : source_color = vec3(1.0, 1.0, 1.0);   // white
uniform vec3 col_mid : source_color = vec3(1.0, 0.5, 0.0);   // orange
uniform vec3 col_max : source_color = vec3(1.0, 0.0, 0.0);   // red

void fragment() {
	// Read the arrow's world scale (X axis)
    float s = WORLD_MATRIX[0].x;

    // Normalize scale into 0..1
    float t = clamp((s - min_scale) / (max_scale - min_scale), 0.0, 1.0);

    // Blend between white → orange → red
    vec3 col;
    if (t < 0.5) {
        col = mix(col_min, col_mid, t * 2.0);
    } else {
        col = mix(col_mid, col_max, (t - 0.5) * 2.0);
    }

    ALBEDO = col;
}
