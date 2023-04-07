shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler2D palette;
uniform int paletteW = 16;
uniform int paletteH = 4;

vec3 getColor(int idx) {
	float hStep = 1.0f / float(paletteW);
	float vStep = 1.0f / float(paletteH);
	float x = float(idx % paletteW)+0.5f;
	float y = float(idx / paletteW)+0.5f;
	vec2 uv = vec2(x*hStep, y*vStep);
	return texture(palette, uv).rgb;
}

int maxPalette() {
	return paletteW * paletteH;
}

void fragment(){
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 new_color = getColor(maxPalette());
	for (int i = 0; i < maxPalette(); i++){
		vec3 pCol = getColor(i);
		if (distance(pCol,color) < distance(new_color, color)){
			new_color = pCol;
		}
		COLOR.rgb = new_color;
		COLOR.a  = texture(TEXTURE,UV).a;
	}
}
