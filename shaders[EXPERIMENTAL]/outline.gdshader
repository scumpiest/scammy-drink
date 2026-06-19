shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 16.0, 0.1) = 2.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (tex_color.a >= 0.99) {
		COLOR = tex_color;
		return;
	}

	vec2 ps = TEXTURE_PIXEL_SIZE * outline_width;
	float neighbor_alpha = 0.0;
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(ps.x, 0.0)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(-ps.x, 0.0)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(0.0, ps.y)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(0.0, -ps.y)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(ps.x, ps.y)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(-ps.x, ps.y)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(ps.x, -ps.y)).a);
	neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, UV + vec2(-ps.x, -ps.y)).a);

	if (neighbor_alpha > 0.0) {
		COLOR = vec4(outline_color.rgb, outline_color.a * neighbor_alpha);
	} else {
		COLOR = tex_color;
	}
}
