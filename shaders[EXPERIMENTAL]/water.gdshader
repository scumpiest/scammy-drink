shader_type canvas_item;

// --- Uniforms (Tweak these in the Inspector) ---
uniform float fill_amount : hint_range(0.0, 1.0) = 0.5;
uniform float wave_speed = 3.0;
uniform float wave_frequency = 10.0;
uniform float wave_amplitude = 0.05; // Slightly increased for a more noticeable splash

// --- Splash Control ---
// Set this to 1.0 in your script on splash, then fade it to 0.0 over time
uniform float splash_intensity : hint_range(0.0, 1.0) = 0.0; 

uniform vec4 liquid_color : source_color = vec4(0.2, 0.6, 0.9, 0.8);
uniform vec4 surface_color : source_color = vec4(0.6, 0.9, 1.0, 1.0);
uniform float surface_thickness = 0.02;

void fragment() {
    // 1. Calculate the undulating wave, multiplied by the splash intensity
    float wave = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_amplitude * splash_intensity;
    
    // 2. Godot's UV.y goes from 0 (top) to 1 (bottom). 
    // We invert the fill amount so 1.0 is full and 0.0 is empty.
    float actual_fill = 1.0 - fill_amount;
    float surface_level = actual_fill + wave;
    
    // 3. Read the original texture's alpha to act as a mask
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 4. Determine pixel color based on its vertical position
    if (UV.y < surface_level) {
        // Pixel is above the water line -> make it invisible
        COLOR.a = 0.0;
    } 
    else if (UV.y < surface_level + surface_thickness) {
        // Pixel is exactly at the surface -> draw the rim highlight
        COLOR = surface_color;
        COLOR.a *= tex_color.a; // Keep it inside the sprite's shape
    } 
    else {
        // Pixel is below the surface -> draw the liquid
        COLOR = liquid_color;
        COLOR.a *= tex_color.a; // Keep it inside the sprite's shape
    }
}