shader_type canvas_item;

// Controls desaturation (0.0 = full color, 1.0 = grayscale)
uniform float dullness : hint_range(0.0, 1.0) = 1.0;

// Controls contrast reduction (0.0 = normal, 1.0 = flat gray)
uniform float flatness : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 grayscale = vec3(luminance);

	vec3 desaturated = mix(tex_color.rgb, grayscale, dullness);
	vec3 final_color = mix(desaturated, vec3(0.5), flatness * 0.5);

	COLOR = vec4(final_color, tex_color.a);
}
