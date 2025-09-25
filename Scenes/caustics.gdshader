shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D caustics_tex : source_color;

uniform float speed = 0.1;
uniform float strength = 0.3;
uniform float scale = 2.0;
uniform vec3 caustics_color = vec3(0.2, 0.5, 1.0); // bluish tint

void fragment() {
    // Base screen color
    vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Use world coordinates instead of screen UV
    vec2 world_uv = (SCREEN_UV * SCREEN_PIXEL_SIZE) * scale;

    // Animate over time
    world_uv.y += TIME * speed;

    // Tile the texture
    world_uv = fract(world_uv);

    // Sample caustics
    float caustics = texture(caustics_tex, world_uv).r;

    // Blend caustics into scene
    vec3 tint = caustics_color * caustics * strength;
    COLOR = vec4(screen_tex.rgb + tint, screen_tex.a);
}