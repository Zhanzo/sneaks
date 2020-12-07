shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : hint_color = vec4(1.0);
uniform float outline_width : hint_range(0.0, 20.0) = 1.0;

void fragment()
{
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
	vec4 color = texture(TEXTURE, UV);
	float outline = color.a;

	for (float i = -size.x; i <= size.x; i += size.x)
	{
		for (float j = -size.y; j <= size.y; j += size.y)
		{
			if (i == 0.0 && j == 0.0) continue;
			outline += texture(TEXTURE, UV + vec2(i, j)).a;
		}
	}
	
	outline = min(outline, 1.0);
	COLOR = mix(color, outline_color, outline - color.a);
}