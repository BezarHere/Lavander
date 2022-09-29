shader_type canvas_item;

uniform sampler2D gradient;

void fragment(){
	COLOR = texture(gradient, vec2(UV.x, 0.0));
	COLOR.r = UV.x;
}
