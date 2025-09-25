shader_type canvas_item;

uniform bool enabled = true; // just a toggle
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0); // color param

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (enabled) {
        COLOR = vec4(tint.rgb, tex_color.a); // use tint, keep alpha
    } else {
        COLOR = tex_color; // normal sprite
    }
}