shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const float o366388_rota = 0.000000000; // {default:0, label:Rotate, max:360, min:0, name:rota, step:45, type:named_parameter}
const float o366388_tile = 1.000000000; // {default:1, label:Tile, max:16, min:1, name:tile, step:1, type:named_parameter}
uniform sampler2D texture_1;
const float texture_1_size = 256.0;
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
const float o366379_rota = 45.000000000; // {default:0, label:Rotate, max:360, min:0, name:rota, step:45, type:named_parameter}
const float o366379_tile = 1.000000000; // {default:1, label:Tile, max:16, min:1, name:tile, step:1, type:named_parameter}
uniform sampler2D texture_2;
const float texture_2_size = 256.0;
const float o366397_rota = 225.000000000; // {default:0, label:Rotate, max:360, min:0, name:rota, step:45, type:named_parameter}
const float o366397_tile = 1.000000000; // {default:1, label:Tile, max:16, min:1, name:tile, step:1, type:named_parameter}
uniform sampler2D texture_3;
const float texture_3_size = 256.0;
const float o366406_rota = -180.000000000; // {default:0, label:Rotate, max:360, min:0, name:rota, step:45, type:named_parameter}
const float o366406_tile = 1.000000000; // {default:1, label:Tile, max:16, min:1, name:tile, step:1, type:named_parameter}
uniform sampler2D texture_4;
const float texture_4_size = 256.0;
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
uniform sampler2D texture_5;
const float texture_5_size = 512.0;
vec2 scale(vec2 uv, vec2 center, vec2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const vec4 p_o366299_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o366299_metallic = 0.000000000;
const float p_o366299_roughness = 0.000000000;
const float p_o366299_emission_energy = 0.300000000;
const float p_o366299_normal = 1.000000000;
const float p_o366299_ao = 1.000000000;
const float p_o366299_depth_scale = 0.500000000;
float o366299_input_depth_tex(vec2 uv, float _seed_variation_) {
return 0.0;
}
const float p_o367303_amount1 = 0.190000000;
const float p_o367366_amount = 0.015000000;
const float p_o367366_eps = 0.035000000;
const float p_o367069_default_in1 = 0.000000000;
const float p_o367069_default_in2 = 3.000000000;
const float p_o367059_default_in1 = 0.000000000;
const float p_o367059_default_in2 = 3.000000000;
const float p_o366356_amount1 = 0.500000000;
const float p_o366356_amount2 = 0.250000000;
const float p_o366356_amount3 = 0.125000000;
const float p_o366385_translate_x = 0.000000000;
const float p_o366385_translate_y = 0.000000000;
const float p_o366354_translate_x = 1.000000000;
const float p_o366354_translate_y = 0.000000000;
const float p_o366354_rotate = 0.000000000;
const float p_o366354_scale_x = 1.000000000;
const float p_o366354_scale_y = 1.000000000;
const float p_o366376_translate_x = 0.000000000;
const float p_o366376_translate_y = 0.000000000;
const float p_o366350_translate_x = 1.000000000;
const float p_o366350_translate_y = 0.000000000;
const float p_o366350_rotate = 0.000000000;
const float p_o366350_scale_x = 1.000000000;
const float p_o366350_scale_y = 1.000000000;
const float p_o366394_translate_x = 0.000000000;
const float p_o366394_translate_y = 0.000000000;
const float p_o366348_translate_x = 1.000000000;
const float p_o366348_translate_y = 1.000000000;
const float p_o366348_rotate = 0.000000000;
const float p_o366348_scale_x = 1.000000000;
const float p_o366348_scale_y = 1.000000000;
const float p_o366403_translate_x = 0.000000000;
const float p_o366403_translate_y = 0.000000000;
const float p_o366351_translate_x = 1.000000000;
const float p_o366351_translate_y = 1.000000000;
const float p_o366351_rotate = 0.000000000;
const float p_o366351_scale_x = 1.000000000;
const float p_o366351_scale_y = 1.000000000;
float o367366_input_d(vec2 uv, float _seed_variation_) {
float o366349_0_1_f = (elapsed_time / 32.0);
vec4 o366357_0 = textureLod(texture_1, (transform2((transform2((uv), vec2(p_o366385_translate_x*(2.0*1.0-1.0), p_o366385_translate_y*(2.0*1.0-1.0)), (o366388_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0), ((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0)))), vec2(p_o366354_translate_x*(2.0*o366349_0_1_f-1.0), p_o366354_translate_y*(2.0*1.0-1.0)), p_o366354_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366354_scale_x*(2.0*1.0-1.0), p_o366354_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366354_0_1_rgba = o366357_0;
vec4 o366385_0_1_rgba = o366354_0_1_rgba;
float o366349_0_3_f = (elapsed_time / 32.0);
vec4 o366359_0 = textureLod(texture_2, (transform2((transform2((uv), vec2(p_o366376_translate_x*(2.0*1.0-1.0), p_o366376_translate_y*(2.0*1.0-1.0)), (o366379_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0), ((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0)))), vec2(p_o366350_translate_x*(2.0*o366349_0_3_f-1.0), p_o366350_translate_y*(2.0*1.0-1.0)), p_o366350_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366350_scale_x*(2.0*1.0-1.0), p_o366350_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366350_0_1_rgba = o366359_0;
vec4 o366376_0_1_rgba = o366350_0_1_rgba;
float o366349_0_5_f = (elapsed_time / 32.0);
vec4 o366361_0 = textureLod(texture_3, (transform2((transform2((uv), vec2(p_o366394_translate_x*(2.0*1.0-1.0), p_o366394_translate_y*(2.0*1.0-1.0)), (o366397_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0), ((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0)))), vec2(p_o366348_translate_x*(2.0*o366349_0_5_f-1.0), p_o366348_translate_y*(2.0*1.0-1.0)), p_o366348_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366348_scale_x*(2.0*1.0-1.0), p_o366348_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366348_0_1_rgba = o366361_0;
vec4 o366394_0_1_rgba = o366348_0_1_rgba;
float o366349_0_7_f = (elapsed_time / 32.0);
vec4 o366363_0 = textureLod(texture_4, (transform2((transform2((uv), vec2(p_o366403_translate_x*(2.0*1.0-1.0), p_o366403_translate_y*(2.0*1.0-1.0)), (o366406_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0), ((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0)))), vec2(p_o366351_translate_x*(2.0*o366349_0_7_f-1.0), p_o366351_translate_y*(2.0*1.0-1.0)), p_o366351_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366351_scale_x*(2.0*1.0-1.0), p_o366351_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366351_0_1_rgba = o366363_0;
vec4 o366403_0_1_rgba = o366351_0_1_rgba;
vec4 o366356_0_b = o366385_0_1_rgba;
vec4 o366356_0_l;
float o366356_0_a;
o366356_0_l = o366376_0_1_rgba;
o366356_0_a = p_o366356_amount1*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366394_0_1_rgba;
o366356_0_a = p_o366356_amount2*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366403_0_1_rgba;
o366356_0_a = p_o366356_amount3*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
vec4 o366356_0_2_rgba = o366356_0_b;
float o367059_0_clamp_false = pow((dot((o366356_0_2_rgba).rgb, vec3(1.0))/3.0),p_o367059_default_in2);
float o367059_0_clamp_true = clamp(o367059_0_clamp_false, 0.0, 1.0);
float o367059_0_2_f = o367059_0_clamp_false;
float o367069_0_clamp_false = o367059_0_2_f*p_o367069_default_in2;
float o367069_0_clamp_true = clamp(o367069_0_clamp_false, 0.0, 1.0);
float o367069_0_2_f = o367069_0_clamp_true;
return o367069_0_2_f;
}
vec2 o367366_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o367366_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o367366_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o367366_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o367366_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o367370_cx = 0.000000000;
const float p_o367370_cy = 0.000000000;
const float p_o367370_scale_x = 0.500000000;
const float p_o367370_scale_y = 0.500000000;
const vec4 p_o367304_color = vec4(0.094775997, 0.094775997, 0.094775997, 1.000000000);
const float p_o367071_amount1 = 1.000000000;
const float p_o367071_amount2 = 1.000000000;
const float p_o367072_all = 1.000000000;
const float p_o367072_hue = 0.010000000;
const float p_o367072_value = 0.000000000;
const float p_o367072_saturation = 0.000000000;
const vec4 p_o367073_color = vec4(0.000000000, 0.415686011, 1.000000000, 1.000000000);
const float p_o367068_default_in1 = 0.000000000;
const float p_o367068_default_in2 = 3.000000000;
const float p_o367070_default_in1 = 0.000000000;
const float p_o367070_default_in2 = 1.680000000;
const float p_o367064_amount = -0.035000000;
const float p_o367064_eps = 0.010000000;
float o367064_input_d(vec2 uv, float _seed_variation_) {
float o366349_0_1_f = (elapsed_time / 32.0);
vec4 o366357_0 = textureLod(texture_1, (transform2((transform2((uv), vec2(p_o366385_translate_x*(2.0*1.0-1.0), p_o366385_translate_y*(2.0*1.0-1.0)), (o366388_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0), ((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0)))), vec2(p_o366354_translate_x*(2.0*o366349_0_1_f-1.0), p_o366354_translate_y*(2.0*1.0-1.0)), p_o366354_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366354_scale_x*(2.0*1.0-1.0), p_o366354_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366354_0_1_rgba = o366357_0;
vec4 o366385_0_1_rgba = o366354_0_1_rgba;
float o366349_0_3_f = (elapsed_time / 32.0);
vec4 o366359_0 = textureLod(texture_2, (transform2((transform2((uv), vec2(p_o366376_translate_x*(2.0*1.0-1.0), p_o366376_translate_y*(2.0*1.0-1.0)), (o366379_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0), ((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0)))), vec2(p_o366350_translate_x*(2.0*o366349_0_3_f-1.0), p_o366350_translate_y*(2.0*1.0-1.0)), p_o366350_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366350_scale_x*(2.0*1.0-1.0), p_o366350_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366350_0_1_rgba = o366359_0;
vec4 o366376_0_1_rgba = o366350_0_1_rgba;
float o366349_0_5_f = (elapsed_time / 32.0);
vec4 o366361_0 = textureLod(texture_3, (transform2((transform2((uv), vec2(p_o366394_translate_x*(2.0*1.0-1.0), p_o366394_translate_y*(2.0*1.0-1.0)), (o366397_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0), ((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0)))), vec2(p_o366348_translate_x*(2.0*o366349_0_5_f-1.0), p_o366348_translate_y*(2.0*1.0-1.0)), p_o366348_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366348_scale_x*(2.0*1.0-1.0), p_o366348_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366348_0_1_rgba = o366361_0;
vec4 o366394_0_1_rgba = o366348_0_1_rgba;
float o366349_0_7_f = (elapsed_time / 32.0);
vec4 o366363_0 = textureLod(texture_4, (transform2((transform2((uv), vec2(p_o366403_translate_x*(2.0*1.0-1.0), p_o366403_translate_y*(2.0*1.0-1.0)), (o366406_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0), ((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0)))), vec2(p_o366351_translate_x*(2.0*o366349_0_7_f-1.0), p_o366351_translate_y*(2.0*1.0-1.0)), p_o366351_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366351_scale_x*(2.0*1.0-1.0), p_o366351_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366351_0_1_rgba = o366363_0;
vec4 o366403_0_1_rgba = o366351_0_1_rgba;
vec4 o366356_0_b = o366385_0_1_rgba;
vec4 o366356_0_l;
float o366356_0_a;
o366356_0_l = o366376_0_1_rgba;
o366356_0_a = p_o366356_amount1*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366394_0_1_rgba;
o366356_0_a = p_o366356_amount2*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366403_0_1_rgba;
o366356_0_a = p_o366356_amount3*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
vec4 o366356_0_2_rgba = o366356_0_b;
float o367059_0_clamp_false = pow((dot((o366356_0_2_rgba).rgb, vec3(1.0))/3.0),p_o367059_default_in2);
float o367059_0_clamp_true = clamp(o367059_0_clamp_false, 0.0, 1.0);
float o367059_0_2_f = o367059_0_clamp_false;
float o367069_0_clamp_false = o367059_0_2_f*p_o367069_default_in2;
float o367069_0_clamp_true = clamp(o367069_0_clamp_false, 0.0, 1.0);
float o367069_0_2_f = o367069_0_clamp_true;
return o367069_0_2_f;
}
vec2 o367064_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o367064_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o367064_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o367064_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o367064_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o367060_amount = -0.025000000;
const float p_o367060_eps = 0.005000000;
float o367060_input_d(vec2 uv, float _seed_variation_) {
float o366349_0_1_f = (elapsed_time / 32.0);
vec4 o366357_0 = textureLod(texture_1, (transform2((transform2((uv), vec2(p_o366385_translate_x*(2.0*1.0-1.0), p_o366385_translate_y*(2.0*1.0-1.0)), (o366388_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0), ((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0)))), vec2(p_o366354_translate_x*(2.0*o366349_0_1_f-1.0), p_o366354_translate_y*(2.0*1.0-1.0)), p_o366354_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366354_scale_x*(2.0*1.0-1.0), p_o366354_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366354_0_1_rgba = o366357_0;
vec4 o366385_0_1_rgba = o366354_0_1_rgba;
float o366349_0_3_f = (elapsed_time / 32.0);
vec4 o366359_0 = textureLod(texture_2, (transform2((transform2((uv), vec2(p_o366376_translate_x*(2.0*1.0-1.0), p_o366376_translate_y*(2.0*1.0-1.0)), (o366379_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0), ((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0)))), vec2(p_o366350_translate_x*(2.0*o366349_0_3_f-1.0), p_o366350_translate_y*(2.0*1.0-1.0)), p_o366350_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366350_scale_x*(2.0*1.0-1.0), p_o366350_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366350_0_1_rgba = o366359_0;
vec4 o366376_0_1_rgba = o366350_0_1_rgba;
float o366349_0_5_f = (elapsed_time / 32.0);
vec4 o366361_0 = textureLod(texture_3, (transform2((transform2((uv), vec2(p_o366394_translate_x*(2.0*1.0-1.0), p_o366394_translate_y*(2.0*1.0-1.0)), (o366397_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0), ((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0)))), vec2(p_o366348_translate_x*(2.0*o366349_0_5_f-1.0), p_o366348_translate_y*(2.0*1.0-1.0)), p_o366348_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366348_scale_x*(2.0*1.0-1.0), p_o366348_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366348_0_1_rgba = o366361_0;
vec4 o366394_0_1_rgba = o366348_0_1_rgba;
float o366349_0_7_f = (elapsed_time / 32.0);
vec4 o366363_0 = textureLod(texture_4, (transform2((transform2((uv), vec2(p_o366403_translate_x*(2.0*1.0-1.0), p_o366403_translate_y*(2.0*1.0-1.0)), (o366406_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0), ((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0)))), vec2(p_o366351_translate_x*(2.0*o366349_0_7_f-1.0), p_o366351_translate_y*(2.0*1.0-1.0)), p_o366351_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366351_scale_x*(2.0*1.0-1.0), p_o366351_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366351_0_1_rgba = o366363_0;
vec4 o366403_0_1_rgba = o366351_0_1_rgba;
vec4 o366356_0_b = o366385_0_1_rgba;
vec4 o366356_0_l;
float o366356_0_a;
o366356_0_l = o366376_0_1_rgba;
o366356_0_a = p_o366356_amount1*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366394_0_1_rgba;
o366356_0_a = p_o366356_amount2*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366403_0_1_rgba;
o366356_0_a = p_o366356_amount3*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
vec4 o366356_0_2_rgba = o366356_0_b;
float o367059_0_clamp_false = pow((dot((o366356_0_2_rgba).rgb, vec3(1.0))/3.0),p_o367059_default_in2);
float o367059_0_clamp_true = clamp(o367059_0_clamp_false, 0.0, 1.0);
float o367059_0_2_f = o367059_0_clamp_false;
float o367069_0_clamp_false = o367059_0_2_f*p_o367069_default_in2;
float o367069_0_clamp_true = clamp(o367069_0_clamp_false, 0.0, 1.0);
float o367069_0_2_f = o367069_0_clamp_true;
return o367069_0_2_f;
}
vec2 o367060_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o367060_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o367060_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o367060_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o367060_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o366308_amount = 0.020000000;
float o366308_input_in(vec2 uv, float _seed_variation_) {
float o366349_0_1_f = (elapsed_time / 32.0);
vec4 o366357_0 = textureLod(texture_1, (transform2((transform2((uv), vec2(p_o366385_translate_x*(2.0*1.0-1.0), p_o366385_translate_y*(2.0*1.0-1.0)), (o366388_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0), ((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0)))), vec2(p_o366354_translate_x*(2.0*o366349_0_1_f-1.0), p_o366354_translate_y*(2.0*1.0-1.0)), p_o366354_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366354_scale_x*(2.0*1.0-1.0), p_o366354_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366354_0_1_rgba = o366357_0;
vec4 o366385_0_1_rgba = o366354_0_1_rgba;
float o366349_0_3_f = (elapsed_time / 32.0);
vec4 o366359_0 = textureLod(texture_2, (transform2((transform2((uv), vec2(p_o366376_translate_x*(2.0*1.0-1.0), p_o366376_translate_y*(2.0*1.0-1.0)), (o366379_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0), ((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0)))), vec2(p_o366350_translate_x*(2.0*o366349_0_3_f-1.0), p_o366350_translate_y*(2.0*1.0-1.0)), p_o366350_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366350_scale_x*(2.0*1.0-1.0), p_o366350_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366350_0_1_rgba = o366359_0;
vec4 o366376_0_1_rgba = o366350_0_1_rgba;
float o366349_0_5_f = (elapsed_time / 32.0);
vec4 o366361_0 = textureLod(texture_3, (transform2((transform2((uv), vec2(p_o366394_translate_x*(2.0*1.0-1.0), p_o366394_translate_y*(2.0*1.0-1.0)), (o366397_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0), ((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0)))), vec2(p_o366348_translate_x*(2.0*o366349_0_5_f-1.0), p_o366348_translate_y*(2.0*1.0-1.0)), p_o366348_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366348_scale_x*(2.0*1.0-1.0), p_o366348_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366348_0_1_rgba = o366361_0;
vec4 o366394_0_1_rgba = o366348_0_1_rgba;
float o366349_0_7_f = (elapsed_time / 32.0);
vec4 o366363_0 = textureLod(texture_4, (transform2((transform2((uv), vec2(p_o366403_translate_x*(2.0*1.0-1.0), p_o366403_translate_y*(2.0*1.0-1.0)), (o366406_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0), ((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0)))), vec2(p_o366351_translate_x*(2.0*o366349_0_7_f-1.0), p_o366351_translate_y*(2.0*1.0-1.0)), p_o366351_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366351_scale_x*(2.0*1.0-1.0), p_o366351_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366351_0_1_rgba = o366363_0;
vec4 o366403_0_1_rgba = o366351_0_1_rgba;
vec4 o366356_0_b = o366385_0_1_rgba;
vec4 o366356_0_l;
float o366356_0_a;
o366356_0_l = o366376_0_1_rgba;
o366356_0_a = p_o366356_amount1*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366394_0_1_rgba;
o366356_0_a = p_o366356_amount2*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
o366356_0_l = o366403_0_1_rgba;
o366356_0_a = p_o366356_amount3*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));
vec4 o366356_0_2_rgba = o366356_0_b;
float o367059_0_clamp_false = pow((dot((o366356_0_2_rgba).rgb, vec3(1.0))/3.0),p_o367059_default_in2);
float o367059_0_clamp_true = clamp(o367059_0_clamp_false, 0.0, 1.0);
float o367059_0_2_f = o367059_0_clamp_false;
float o367069_0_clamp_false = o367059_0_2_f*p_o367069_default_in2;
float o367069_0_clamp_true = clamp(o367069_0_clamp_false, 0.0, 1.0);
float o367069_0_2_f = o367069_0_clamp_true;
return o367069_0_2_f;
}
vec3 nm_o366308(vec2 uv, float amount, float size, float _seed_variation_) {
	vec3 e = vec3(1.0/size, -1.0/size, 0);
	vec2 rv;
	if (3 == 0) {
		rv = vec2(1.0, -1.0)*o366308_input_in(uv+e.xy, _seed_variation_);
		rv += vec2(-1.0, 1.0)*o366308_input_in(uv-e.xy, _seed_variation_);
		rv += vec2(1.0, 1.0)*o366308_input_in(uv+e.xx, _seed_variation_);
		rv += vec2(-1.0, -1.0)*o366308_input_in(uv-e.xx, _seed_variation_);
		rv += vec2(2.0, 0.0)*o366308_input_in(uv+e.xz, _seed_variation_);
		rv += vec2(-2.0, 0.0)*o366308_input_in(uv-e.xz, _seed_variation_);
		rv += vec2(0.0, 2.0)*o366308_input_in(uv+e.zx, _seed_variation_);
		rv += vec2(0.0, -2.0)*o366308_input_in(uv-e.zx, _seed_variation_);
		rv *= size*amount/128.0;
	} else if (3 == 1) {
		rv = vec2(3.0, -3.0)*o366308_input_in(uv+e.xy, _seed_variation_);
		rv += vec2(-3.0, 3.0)*o366308_input_in(uv-e.xy, _seed_variation_);
		rv += vec2(3.0, 3.0)*o366308_input_in(uv+e.xx, _seed_variation_);
		rv += vec2(-3.0, -3.0)*o366308_input_in(uv-e.xx, _seed_variation_);
		rv += vec2(10.0, 0.0)*o366308_input_in(uv+e.xz, _seed_variation_);
		rv += vec2(-10.0, 0.0)*o366308_input_in(uv-e.xz, _seed_variation_);
		rv += vec2(0.0, 10.0)*o366308_input_in(uv+e.zx, _seed_variation_);
		rv += vec2(0.0, -10.0)*o366308_input_in(uv-e.zx, _seed_variation_);
		rv *= size*amount/512.0;
	} else if (3 == 2) {
		rv = vec2(2.0, 0.0)*o366308_input_in(uv+e.xz, _seed_variation_);
		rv += vec2(-2.0, 0.0)*o366308_input_in(uv-e.xz, _seed_variation_);
		rv += vec2(0.0, 2.0)*o366308_input_in(uv+e.zx, _seed_variation_);
		rv += vec2(0.0, -2.0)*o366308_input_in(uv-e.zx, _seed_variation_);
		rv *= size*amount/64.0;
	} else {
		rv = vec2(1.0, 0.0)*o366308_input_in(uv+e.xz, _seed_variation_);
		rv += vec2(0.0, 1.0)*o366308_input_in(uv+e.zx, _seed_variation_);
		rv += vec2(-1.0, -1.0)*o366308_input_in(uv, _seed_variation_);
		rv *= size*amount/20.0;
	}
	return vec3(0.5)+0.5*normalize(vec3(rv, -1.0));
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o367366_0_slope = o367366_slope((uv), p_o367366_eps, _seed_variation_);
vec2 o367366_0_warp = o367366_0_slope;vec4 o367343_0 = textureLod(texture_5, scale(((uv)+p_o367366_amount*o367366_0_warp), vec2(0.5+p_o367370_cx, 0.5+p_o367370_cy), vec2(p_o367370_scale_x, p_o367370_scale_y)), 0.0);
vec4 o367370_0_1_rgba = o367343_0;
vec4 o367366_0_1_rgba = o367370_0_1_rgba;
vec4 o367304_0_1_rgba = p_o367304_color;
vec4 o367303_0_b = o367366_0_1_rgba;
vec4 o367303_0_l;
float o367303_0_a;

o367303_0_l = o367304_0_1_rgba;
o367303_0_a = p_o367303_amount1*1.0;
o367303_0_b = vec4(blend_multiply((uv), o367303_0_l.rgb, o367303_0_b.rgb, o367303_0_a*o367303_0_l.a), min(1.0, o367303_0_b.a+o367303_0_a*o367303_0_l.a));

vec4 o367303_0_2_rgba = o367303_0_b;
vec4 o367073_0_1_rgba = p_o367073_color;
float o366349_0_1_f = (elapsed_time / 32.0);
vec4 o366357_0 = textureLod(texture_1, (transform2((transform2((uv), vec2(p_o366385_translate_x*(2.0*1.0-1.0), p_o366385_translate_y*(2.0*1.0-1.0)), (o366388_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0), ((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0)))), vec2(p_o366354_translate_x*(2.0*o366349_0_1_f-1.0), p_o366354_translate_y*(2.0*1.0-1.0)), p_o366354_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366354_scale_x*(2.0*1.0-1.0), p_o366354_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366354_0_1_rgba = o366357_0;
vec4 o366385_0_1_rgba = o366354_0_1_rgba;
float o366349_0_3_f = (elapsed_time / 32.0);
vec4 o366359_0 = textureLod(texture_2, (transform2((transform2((uv), vec2(p_o366376_translate_x*(2.0*1.0-1.0), p_o366376_translate_y*(2.0*1.0-1.0)), (o366379_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0), ((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0)))), vec2(p_o366350_translate_x*(2.0*o366349_0_3_f-1.0), p_o366350_translate_y*(2.0*1.0-1.0)), p_o366350_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366350_scale_x*(2.0*1.0-1.0), p_o366350_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366350_0_1_rgba = o366359_0;
vec4 o366376_0_1_rgba = o366350_0_1_rgba;
float o366349_0_5_f = (elapsed_time / 32.0);
vec4 o366361_0 = textureLod(texture_3, (transform2((transform2((uv), vec2(p_o366394_translate_x*(2.0*1.0-1.0), p_o366394_translate_y*(2.0*1.0-1.0)), (o366397_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0), ((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0)))), vec2(p_o366348_translate_x*(2.0*o366349_0_5_f-1.0), p_o366348_translate_y*(2.0*1.0-1.0)), p_o366348_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366348_scale_x*(2.0*1.0-1.0), p_o366348_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366348_0_1_rgba = o366361_0;
vec4 o366394_0_1_rgba = o366348_0_1_rgba;
float o366349_0_7_f = (elapsed_time / 32.0);
vec4 o366363_0 = textureLod(texture_4, (transform2((transform2((uv), vec2(p_o366403_translate_x*(2.0*1.0-1.0), p_o366403_translate_y*(2.0*1.0-1.0)), (o366406_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0), ((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0)))), vec2(p_o366351_translate_x*(2.0*o366349_0_7_f-1.0), p_o366351_translate_y*(2.0*1.0-1.0)), p_o366351_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366351_scale_x*(2.0*1.0-1.0), p_o366351_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366351_0_1_rgba = o366363_0;
vec4 o366403_0_1_rgba = o366351_0_1_rgba;
vec4 o366356_0_b = o366385_0_1_rgba;
vec4 o366356_0_l;
float o366356_0_a;

o366356_0_l = o366376_0_1_rgba;
o366356_0_a = p_o366356_amount1*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));

o366356_0_l = o366394_0_1_rgba;
o366356_0_a = p_o366356_amount2*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));

o366356_0_l = o366403_0_1_rgba;
o366356_0_a = p_o366356_amount3*1.0;
o366356_0_b = vec4(blend_normal((uv), o366356_0_l.rgb, o366356_0_b.rgb, o366356_0_a*o366356_0_l.a), min(1.0, o366356_0_b.a+o366356_0_a*o366356_0_l.a));

vec4 o366356_0_2_rgba = o366356_0_b;
vec4 o367072_0_rbga = o367073_0_1_rgba;
vec3 o367072_0_hsv = rgb_to_hsv(o367072_0_rbga.rgb);
o367072_0_hsv.x = fract(o367072_0_hsv.x+p_o367072_hue*p_o367072_all*((dot((o366356_0_2_rgba).rgb, vec3(1.0))/3.0)-0.5));
o367072_0_hsv.y = clamp(o367072_0_hsv.y+p_o367072_saturation*p_o367072_all*(0.5-0.5), 0.0, 1.0);
o367072_0_hsv.z = clamp(o367072_0_hsv.z+p_o367072_value*p_o367072_all*(0.5-0.5), 0.0, 1.0);
	vec4 o367072_0_2_rgba = vec4(hsv_to_rgb(o367072_0_hsv), o367072_0_rbga.a);
vec2 o367064_0_slope = o367064_slope((uv), p_o367064_eps, _seed_variation_);
vec2 o367064_0_warp = o367064_0_slope;vec2 o367060_0_slope = o367060_slope(((uv)+p_o367064_amount*o367064_0_warp), p_o367060_eps, _seed_variation_);
vec2 o367060_0_warp = o367060_0_slope;float o366349_0_9_f = (elapsed_time / 32.0);
vec4 o366357_1 = textureLod(texture_1, (transform2((transform2((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), vec2(p_o366385_translate_x*(2.0*1.0-1.0), p_o366385_translate_y*(2.0*1.0-1.0)), (o366388_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0), ((round(mod(o366388_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366388_tile)*(2.0*1.0-1.0)))), vec2(p_o366354_translate_x*(2.0*o366349_0_9_f-1.0), p_o366354_translate_y*(2.0*1.0-1.0)), p_o366354_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366354_scale_x*(2.0*1.0-1.0), p_o366354_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366354_0_4_rgba = o366357_1;
vec4 o366385_0_4_rgba = o366354_0_4_rgba;
float o366349_0_11_f = (elapsed_time / 32.0);
vec4 o366359_1 = textureLod(texture_2, (transform2((transform2((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), vec2(p_o366376_translate_x*(2.0*1.0-1.0), p_o366376_translate_y*(2.0*1.0-1.0)), (o366379_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0), ((round(mod(o366379_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366379_tile)*(2.0*1.0-1.0)))), vec2(p_o366350_translate_x*(2.0*o366349_0_11_f-1.0), p_o366350_translate_y*(2.0*1.0-1.0)), p_o366350_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366350_scale_x*(2.0*1.0-1.0), p_o366350_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366350_0_4_rgba = o366359_1;
vec4 o366376_0_4_rgba = o366350_0_4_rgba;
float o366349_0_13_f = (elapsed_time / 32.0);
vec4 o366361_1 = textureLod(texture_3, (transform2((transform2((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), vec2(p_o366394_translate_x*(2.0*1.0-1.0), p_o366394_translate_y*(2.0*1.0-1.0)), (o366397_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0), ((round(mod(o366397_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366397_tile)*(2.0*1.0-1.0)))), vec2(p_o366348_translate_x*(2.0*o366349_0_13_f-1.0), p_o366348_translate_y*(2.0*1.0-1.0)), p_o366348_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366348_scale_x*(2.0*1.0-1.0), p_o366348_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366348_0_4_rgba = o366361_1;
vec4 o366394_0_4_rgba = o366348_0_4_rgba;
float o366349_0_15_f = (elapsed_time / 32.0);
vec4 o366363_1 = textureLod(texture_4, (transform2((transform2((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), vec2(p_o366403_translate_x*(2.0*1.0-1.0), p_o366403_translate_y*(2.0*1.0-1.0)), (o366406_rota)*0.01745329251*(2.0*1.0-1.0), vec2(((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0), ((round(mod(o366406_rota - 45.0, 90.0)) == 0.0 ? 1.0 / sqrt(2.0) : 1.0) / o366406_tile)*(2.0*1.0-1.0)))), vec2(p_o366351_translate_x*(2.0*o366349_0_15_f-1.0), p_o366351_translate_y*(2.0*1.0-1.0)), p_o366351_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o366351_scale_x*(2.0*1.0-1.0), p_o366351_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o366351_0_4_rgba = o366363_1;
vec4 o366403_0_4_rgba = o366351_0_4_rgba;
vec4 o366356_3_b = o366385_0_4_rgba;
vec4 o366356_3_l;
float o366356_3_a;

o366356_3_l = o366376_0_4_rgba;
o366356_3_a = p_o366356_amount1*1.0;
o366356_3_b = vec4(blend_normal((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), o366356_3_l.rgb, o366356_3_b.rgb, o366356_3_a*o366356_3_l.a), min(1.0, o366356_3_b.a+o366356_3_a*o366356_3_l.a));

o366356_3_l = o366394_0_4_rgba;
o366356_3_a = p_o366356_amount2*1.0;
o366356_3_b = vec4(blend_normal((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), o366356_3_l.rgb, o366356_3_b.rgb, o366356_3_a*o366356_3_l.a), min(1.0, o366356_3_b.a+o366356_3_a*o366356_3_l.a));

o366356_3_l = o366403_0_4_rgba;
o366356_3_a = p_o366356_amount3*1.0;
o366356_3_b = vec4(blend_normal((((uv)+p_o367064_amount*o367064_0_warp)+p_o367060_amount*o367060_0_warp), o366356_3_l.rgb, o366356_3_b.rgb, o366356_3_a*o366356_3_l.a), min(1.0, o366356_3_b.a+o366356_3_a*o366356_3_l.a));

vec4 o366356_0_5_rgba = o366356_3_b;
vec4 o367060_0_1_rgba = o366356_0_5_rgba;
vec4 o367064_0_1_rgba = o367060_0_1_rgba;
float o367070_0_clamp_false = (dot((o367064_0_1_rgba).rgb, vec3(1.0))/3.0)*p_o367070_default_in2;
float o367070_0_clamp_true = clamp(o367070_0_clamp_false, 0.0, 1.0);
float o367070_0_2_f = o367070_0_clamp_true;
float o367068_0_clamp_false = pow(o367070_0_2_f,p_o367068_default_in2);
float o367068_0_clamp_true = clamp(o367068_0_clamp_false, 0.0, 1.0);
float o367068_0_2_f = o367068_0_clamp_true;
vec4 o367071_0_b = o367072_0_2_rgba;
vec4 o367071_0_l;
float o367071_0_a;

o367071_0_l = vec4(vec3(o367068_0_2_f), 1.0);
o367071_0_a = p_o367071_amount1*1.0;
o367071_0_b = vec4(blend_addsub((uv), o367071_0_l.rgb, o367071_0_b.rgb, o367071_0_a*o367071_0_l.a), min(1.0, o367071_0_b.a+o367071_0_a*o367071_0_l.a));

o367071_0_l = o367366_0_1_rgba;
o367071_0_a = p_o367071_amount2*1.0;
o367071_0_b = vec4(blend_multiply((uv), o367071_0_l.rgb, o367071_0_b.rgb, o367071_0_a*o367071_0_l.a), min(1.0, o367071_0_b.a+o367071_0_a*o367071_0_l.a));

vec4 o367071_0_2_rgba = o367071_0_b;
vec3 o366308_0_1_rgb = nm_o366308((uv), p_o366308_amount, 128.000000000, _seed_variation_);

	vec3 albedo_tex = ((o367303_0_2_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o366299_albedo_color.rgb;
	METALLIC = 1.0*p_o366299_metallic;
	ROUGHNESS = 1.0*p_o366299_roughness;
	NORMAL = o366308_0_1_rgb;
	EMISSION = ((o367071_0_2_rgba).rgb)*p_o366299_emission_energy;

}



