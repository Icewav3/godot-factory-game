shader_type canvas_item;

// Build progress from 0.0 to 1.0 (0% to 100%)
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Construction colors
uniform vec4 construction_color : source_color = vec4(0.3, 0.7, 1.0, 0.8); // Light blue
uniform vec4 edge_color : source_color = vec4(0.5, 0.9, 1.0, 1.0); // Bright blue edges
uniform float edge_width : hint_range(0.01, 0.1) = 0.03;

// Noise function for organic construction pattern
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Multi-octave noise for more organic patterns
float fbm(vec2 uv) {
    float value = 0.0;
    float amplitude = 0.5;
    
    for (int i = 0; i < 3; i++) {
        value += amplitude * noise(uv);
        uv *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Generate construction noise pattern
    float construction_noise = fbm(UV * 8.0);
    
    // Create construction threshold with noise
    float threshold = progress + (construction_noise * 0.3 - 0.15);
    
    // Determine if this pixel is "constructed" yet
    float constructed = smoothstep(-0.05, 0.05, threshold);
    
    // Create edge detection for bright blue glow
    float edge_mask = smoothstep(-edge_width, edge_width, threshold - 0.02);
    edge_mask = edge_mask * (1.0 - smoothstep(edge_width, edge_width * 2.0, threshold - 0.02));
    
    if (constructed > 0.5) {
        // This area is constructed - show actual texture with possible edge glow
        vec4 final_color = tex_color;
        
        // Add bright blue edge glow
        if (edge_mask > 0.1) {
            final_color = mix(final_color, edge_color, edge_mask * 0.6);
        }
        
        COLOR = final_color;
    } else {
        // This area is not constructed yet - show transparent blue construction material
        COLOR = vec4(construction_color.rgb, construction_color.a * tex_color.a);
    }
}