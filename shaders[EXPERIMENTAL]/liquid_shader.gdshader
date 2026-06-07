shader_type canvas_item;

uniform vec4 liquid_color : source_color = vec4(0.9, 0.4, 0.4, 1.0);
uniform float fill_amount : hint_range(0.0, 1.0) = 0.5;
uniform float wave_frequency = 12.0;
uniform float wave_speed = 4.0;
uniform float wave_amplitude = 0.015; // Controlled by physics entry!

void fragment() {
    float height = 1.0 - UV.y;
    float wave = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    
    if (height < fill_amount + wave) {
        COLOR = liquid_color;
    } else {
        COLOR = vec4(0.0);
    }
}
