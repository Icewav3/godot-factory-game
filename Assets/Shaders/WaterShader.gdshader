shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_enable, filter_nearest;

group_uniforms water;
uniform sampler2D waterNoise : repeat_enable, filter_nearest;
uniform sampler2D waterDistortionNoise : repeat_enable, filter_nearest;
uniform vec4 waterColor : source_color = vec4(0.117, 0.27, 0.58, 1);
uniform float colorCorection : hint_range(0.0, 1.0, 0.01) = 0.35;

group_uniforms water_waves;
uniform float distortionForce : hint_range(0.00, .1, 0.001) = .01;
uniform float WDBrightness : hint_range(0, 3, 0.05) = 1.5;
uniform float WDFreq : hint_range(0.2, .9, 0.05) = 0.6;
uniform float WDSize : hint_range(0.6, 1.2, 0.05) = .9;
uniform float WDSpeed : hint_range(1, 20, 0.05) = 4;
uniform vec2 tiling = vec2(1);
uniform vec2 offSetSpeed = vec2(.1);
uniform float tileSize = 256.0; // Size of your tile in pixels

group_uniforms BG_distortion;
uniform float backGroundDirX : hint_range(-0.1, 0.1) = 0.01;
uniform float backGroundDirY : hint_range(-0.1, 0.1) = 0.01;

group_uniforms blending;
uniform float tileTextureStrength : hint_range(0.0, 1.0, 0.05) = 0.5;
uniform float backgroundStrength : hint_range(0.0, 1.0, 0.05) = 0.3;

// Pass world position from vertex to fragment shader
varying vec2 world_position;

void vertex() {
// Get the world position of this vertex (MODEL_MATRIX transforms local to world)
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 color = vec4(waterColor.rgb , 1);

	// Use actual world position for seamless tiling across tiles
	vec2 worldUV = world_position / tileSize;

	// Apply tiling and animation using world coordinates
	vec2 noiseUV = worldUV * tiling + offSetSpeed * TIME;
	float noiseValue = texture(waterDistortionNoise, noiseUV).r;

	vec2 waterUV = worldUV * tiling;
	waterUV.x += offSetSpeed.x * TIME;
	waterUV.y += cos(TIME * min(1., offSetSpeed.y)) * 0.01;
	waterUV = waterUV + noiseValue * distortionForce * WDSpeed;

	vec4 noiseColor = texture(waterNoise, waterUV);
	float intensity = smoothstep(WDFreq, WDSize, noiseColor.r);
	color.rgb += intensity * vec3(WDBrightness);

	// Distort the tile's own texture UV
	vec2 distortedTileUV = UV;
	distortedTileUV.x += noiseValue * backGroundDirX;
	distortedTileUV.y += noiseValue * backGroundDirY;
	vec4 tileTexture = texture(TEXTURE, distortedTileUV);

	// Distort the background (what's behind this tile)
	vec2 backGroundUV = SCREEN_UV;
	backGroundUV.x += noiseValue * backGroundDirX;
	backGroundUV.y += noiseValue * backGroundDirY;
	vec4 backgroundColor = texture(SCREEN_TEXTURE, backGroundUV);

	// Blend: tile texture + distorted background + water color
	vec4 blended = mix(backgroundColor, tileTexture, tileTextureStrength);
	color = mix(blended, color, backgroundStrength);

	COLOR = mix(color, waterColor, colorCorection);
	COLOR.a = tileTexture.a; // Preserve tile's alpha for proper edges
}