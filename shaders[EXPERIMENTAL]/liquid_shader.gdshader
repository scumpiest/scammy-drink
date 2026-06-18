shader_type canvas_item;

uniform vec4 liquid_color : source_color = vec4(0.9, 0.4, 0.4, 0.85);
uniform float fill_amount : hint_range(0.0, 1.0) = 0.5;
uniform float wave_frequency = 12.0;
uniform float wave_speed = 4.0;
uniform float wave_amplitude = 0.015;
uniform vec2 polygon_min = vec2(0.0, 0.0);
uniform vec2 polygon_max = vec2(192.0, 192.0);

// Fill-level markers: set to -1.0 to disable, 0.0–1.0 to show a line.
uniform float marker_fill_1 : hint_range(-1.0, 1.0) = -1.0;
uniform float marker_fill_2 : hint_range(-1.0, 1.0) = -1.0;
uniform vec4 marker_color : source_color = vec4(1.0, 0.92, 0.25, 1.0);
uniform float marker_thickness : hint_range(0.002, 0.05) = 0.008;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	float range_y = max(polygon_max.y - polygon_min.y, 0.001);
	float range_x = max(polygon_max.x - polygon_min.x, 0.001);
	float norm_x = (local_pos.x - polygon_min.x) / range_x;
	float height = 1.0 - clamp((local_pos.y - polygon_min.y) / range_y, 0.0, 1.0);
	float wave = sin(norm_x * wave_frequency + TIME) * wave_amplitude;

	// Dashed horizontal marker lines — only drawn above the liquid surface.
	bool on_marker = false;
	bool is_dash = fract(norm_x * 7.0) > 0.35;
	if (marker_fill_1 >= 0.0 && abs(height - marker_fill_1) < marker_thickness && is_dash) {
		on_marker = true;
	}
	if (marker_fill_2 >= 0.0 && abs(height - marker_fill_2) < marker_thickness && is_dash) {
		on_marker = true;
	}

	if (on_marker) {
		COLOR = marker_color;
	} else if (height < fill_amount + wave) {
		COLOR = liquid_color;
	} else {
		COLOR = vec4(0.0);
	}
}
