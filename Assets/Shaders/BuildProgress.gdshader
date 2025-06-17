shader_type canvas_item;

// Build progress from 0.0 to 1.0 (0% to 100%)
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Progress mapping controls
uniform float progress_min : hint_range(-1.0, 1.0) = -0.175;
uniform float progress_max : hint_range(0.0, 1) = 0.793;

// Construction colors
uniform vec4 construction_color : source_color = vec4(0.3, 0.7, 1.0, 0.8); // Light blue
uniform vec4 edge_color : source_color = vec4(0.5, 0.9, 1.0, 1.0); // Bright blue edges
uniform float edge_width : hint_range(0.01, 0.5) = 0.2;

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

// Custom remap function using mix (since Godot doesn't have built-in remap)
float remap(float value, float from_min, float from_max, float to_min, float to_max) {
    // Normalize the input value to 0-1 range
    float normalized = (value - from_min) / (from_max - from_min);
    // Map to target range using mix
    return mix(to_min, to_max, normalized);
}

// Function to remap noise to ensure full 0-1 distribution
float remap_noise_to_full_range(vec2 uv) {
    // Get raw noise value
    float raw_noise = fbm(uv);
    
    // Use a combination of multiple noise layers to ensure better distribution
    float noise1 = fbm(uv * 1.0);
    float noise2 = fbm(uv * 2.3 + vec2(100.0)); // Offset to decorrelate
    float noise3 = fbm(uv * 0.7 + vec2(200.0, 300.0));
    
    // Combine and normalize to ensure we use full 0-1 range
    float combined = (noise1 + noise2 + noise3) / 3.0;
    
    // Apply a more aggressive contrast curve to guarantee full 0-1 range
    // This ensures we definitely have pixels at both extremes
    float remapped = combined;
    
    // Apply power curve to spread distribution more evenly
    remapped = pow(remapped, 1.2);
    
    // Apply smoothstep for S-curve contrast
    remapped = smoothstep(0.05, 0.95, remapped);
    
    // Final step: explicitly map to ensure we use absolute full range
    // This guarantees some pixels will be exactly 0.0 and others exactly 1.0
    remapped = clamp(remapped * 1.1 - 0.05, 0.0, 1.0);
    
    return remapped;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Map progress using the configurable min/max values
    float mapped_progress = remap(progress, 0.0, 1.0, progress_min, progress_max);
    
    // Generate construction noise pattern with full 0-1 distribution
    float construction_noise = remap_noise_to_full_range(UV * 8.0);
    
    // Map the noise to the same range as progress for fair comparison
    float noise_threshold = construction_noise;
    
    // Determine if this pixel is "constructed" yet
    // Use a smaller smoothstep range centered on the actual threshold
    float threshold_diff = mapped_progress - noise_threshold;
    float constructed = smoothstep(-0.01, 0.01, threshold_diff);
    
    // Create edge detection for bright blue glow
    // Edge appears where progress is close to noise_threshold
    float edge_distance = abs(threshold_diff);
    float edge_mask = 1.0 - smoothstep(0.0, edge_width, edge_distance);
    edge_mask *= (1.0 - constructed); // Only show edge on unconstructed side
    
    if (constructed > 0.5) {
        // This area is constructed - show actual texture with possible edge glow
        vec4 final_color = tex_color;
        
        // Add bright blue edge glow
        if (edge_mask > 0.1) {
            final_color = mix(final_color, edge_color, edge_mask * 0.8);
        }
        
        COLOR = final_color;
    } else {
        // This area is not constructed yet - show transparent blue construction material
        vec4 final_color = vec4(construction_color.rgb, construction_color.a * tex_color.a);
        
        // Add edge glow to construction material too
        if (edge_mask > 0.1) {
            final_color = mix(final_color, edge_color, edge_mask * 0.4);
        }
        
        COLOR = final_color;
    }
}