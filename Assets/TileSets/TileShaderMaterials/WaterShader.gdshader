shader_type canvas_item;

uniform float time_speed = 1.0; // Controls how fast the waves move
uniform float wave_strength = 0.05; // Controls the strength of the wave distortion
uniform float wave_scale = 20.0; // Controls the scale of the waves (larger = more frequent)
uniform vec2 wave_direction = vec2(0.5, 0.0); // Direction of the wave movement (1.0 for horizontal)
uniform float wave_speed = 0.1; // Speed of the wave movement over time
uniform sampler2D water_texture; // Texture to be used as water

void fragment() {
    float t = TIME * time_speed; // Adjust time to control the animation speed

    vec2 uv = UV;
    uv += wave_direction * (sin(uv.x * wave_scale + t * wave_speed) * wave_strength); // Apply wave effect

    vec4 tex_color = texture(water_texture, uv); // Sample texture with modified UVs

    // Apply color and transparency effects for a realistic look
    tex_color.a *= 0.8; // Optional transparency tweak
    COLOR = tex_color;
}
