shader_type spatial;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
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
uniform sampler2D texture_1;
const float texture_1_size = 2048.0;
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
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
const float p_o193247_r = 7.000000000;
const float p_o193247_a = 0.630000000;
const float p_o193247_cx = 0.000000000;
const float p_o193247_cy = 0.000000000;
const float p_o193246_translate_x = 0.000000000;
const float p_o193246_rotate = 0.000000000;
const float p_o193246_scale_x = 1.000000000;
const float p_o193246_scale_y = 1.000000000;
const float p_o193244_default_in1 = 0.000000000;
const float p_o193244_default_in2 = 0.000000000;
const float p_o193213_default_in1 = 0.000000000;
const float p_o193213_default_in2 = 6.000000000;
const float p_o193210_translate_x = 0.000000000;
const float p_o193210_translate_y = 1.300000000;
const float p_o193210_rotate = 0.000000000;
const float p_o193210_scale_x = 1.000000000;
const float p_o193210_scale_y = 1.000000000;
const float seed_o193212 = 0.000000000;
const float p_o193211_steps = 64.000000000;
const float p_o193197_repeat = 1.000000000;
const float p_o193197_rotate = 0.000000000;
const float p_o193197_gradient_0_pos = 0.000000000;
const vec4 p_o193197_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o193197_gradient_1_pos = 1.000000000;
const vec4 p_o193197_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o193197_gradient_gradient_fct(float x) {
  if (x < p_o193197_gradient_0_pos) {
    return p_o193197_gradient_0_col;
  } else if (x < p_o193197_gradient_1_pos) {
    return mix(p_o193197_gradient_0_col, p_o193197_gradient_1_col, ((x-p_o193197_gradient_0_pos)/(p_o193197_gradient_1_pos-p_o193197_gradient_0_pos)));
  }
  return p_o193197_gradient_1_col;
}
const float p_o193184_repeat = 1.000000000;
const float p_o193184_rotate = 90.000000000;
const float p_o193184_gradient_0_pos = 0.000000000;
const vec4 p_o193184_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o193184_gradient_1_pos = 1.000000000;
const vec4 p_o193184_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o193184_gradient_gradient_fct(float x) {
  if (x < p_o193184_gradient_0_pos) {
    return p_o193184_gradient_0_col;
  } else if (x < p_o193184_gradient_1_pos) {
    return mix(p_o193184_gradient_0_col, p_o193184_gradient_1_col, ((x-p_o193184_gradient_0_pos)/(p_o193184_gradient_1_pos-p_o193184_gradient_0_pos)));
  }
  return p_o193184_gradient_1_col;
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o193247_0_co = vec2(p_o193247_cx+0.5,p_o193247_cy+0.5);
float o193247_0_f = dot(2.0*((uv) - o193247_0_co),2.0*((uv) - o193247_0_co));vec4 o193224_0 = textureLod(texture_1, (transform2((o193247_0_co-(o193247_0_co-(uv))/(sqrt(p_o193247_r-o193247_0_f)*max(p_o193247_a,0.0)+1.0)), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))), 0.0);
float o193197_0_r = 0.5+(cos(p_o193197_rotate*0.01745329251)*((transform2((o193247_0_co-(o193247_0_co-(uv))/(sqrt(p_o193247_r-o193247_0_f)*max(p_o193247_a,0.0)+1.0)), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))).x-0.5)+sin(p_o193197_rotate*0.01745329251)*((transform2((o193247_0_co-(o193247_0_co-(uv))/(sqrt(p_o193247_r-o193247_0_f)*max(p_o193247_a,0.0)+1.0)), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))).y-0.5))/(cos(abs(mod(p_o193197_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o193197_0_1_rgba = o193197_gradient_gradient_fct(fract(o193197_0_r*p_o193197_repeat));
vec4 o193211_0_1_rgba = vec4(floor(o193197_0_1_rgba.rgb*p_o193211_steps)/p_o193211_steps, o193197_0_1_rgba.a);
vec3 o193212_0_rand = ((o193211_0_1_rgba).rgb);vec3 o193212_0_1_rgb = rand3( vec2( float((seed_o193212+fract(_seed_variation_))) + o193212_0_rand.x, rand( o193212_0_rand.yz ) ) );
float o193184_0_r = 0.5+(cos(p_o193184_rotate*0.01745329251)*((transform2((transform2((o193247_0_co-(o193247_0_co-(uv))/(sqrt(p_o193247_r-o193247_0_f)*max(p_o193247_a,0.0)+1.0)), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))), vec2(p_o193210_translate_x*(2.0*1.0-1.0), p_o193210_translate_y*(2.0*(dot(o193212_0_1_rgb, vec3(1.0))/3.0)-1.0)), p_o193210_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193210_scale_x*(2.0*1.0-1.0), p_o193210_scale_y*(2.0*1.0-1.0)))).x-0.5)+sin(p_o193184_rotate*0.01745329251)*((transform2((transform2((o193247_0_co-(o193247_0_co-(uv))/(sqrt(p_o193247_r-o193247_0_f)*max(p_o193247_a,0.0)+1.0)), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))), vec2(p_o193210_translate_x*(2.0*1.0-1.0), p_o193210_translate_y*(2.0*(dot(o193212_0_1_rgb, vec3(1.0))/3.0)-1.0)), p_o193210_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193210_scale_x*(2.0*1.0-1.0), p_o193210_scale_y*(2.0*1.0-1.0)))).y-0.5))/(cos(abs(mod(p_o193184_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o193184_0_1_rgba = o193184_gradient_gradient_fct(fract(o193184_0_r*p_o193184_repeat));
vec4 o193210_0_1_rgba = o193184_0_1_rgba;
float o193213_0_clamp_false = pow((dot((o193210_0_1_rgba).rgb, vec3(1.0))/3.0),p_o193213_default_in2);
float o193213_0_clamp_true = clamp(o193213_0_clamp_false, 0.0, 1.0);
float o193213_0_2_f = o193213_0_clamp_false;
float o193244_0_clamp_false = (dot((o193224_0).rgb, vec3(1.0))/3.0)+o193213_0_2_f;
float o193244_0_clamp_true = clamp(o193244_0_clamp_false, 0.0, 1.0);
float o193244_0_1_f = o193244_0_clamp_false;
vec4 o193245_0_1_rgba = vec4(0.0, o193244_0_1_f, 0.0, 1.0);
vec4 o193246_0_1_rgba = o193245_0_1_rgba;
vec4 o193224_1 = textureLod(texture_1, (transform2((uv), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))), 0.0);
float o193197_2_r = 0.5+(cos(p_o193197_rotate*0.01745329251)*((transform2((uv), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))).x-0.5)+sin(p_o193197_rotate*0.01745329251)*((transform2((uv), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))).y-0.5))/(cos(abs(mod(p_o193197_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o193197_0_3_rgba = o193197_gradient_gradient_fct(fract(o193197_2_r*p_o193197_repeat));
vec4 o193211_0_3_rgba = vec4(floor(o193197_0_3_rgba.rgb*p_o193211_steps)/p_o193211_steps, o193197_0_3_rgba.a);
vec3 o193212_2_rand = ((o193211_0_3_rgba).rgb);vec3 o193212_0_3_rgb = rand3( vec2( float((seed_o193212+fract(_seed_variation_))) + o193212_2_rand.x, rand( o193212_2_rand.yz ) ) );
float o193184_2_r = 0.5+(cos(p_o193184_rotate*0.01745329251)*((transform2((transform2((uv), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))), vec2(p_o193210_translate_x*(2.0*1.0-1.0), p_o193210_translate_y*(2.0*(dot(o193212_0_3_rgb, vec3(1.0))/3.0)-1.0)), p_o193210_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193210_scale_x*(2.0*1.0-1.0), p_o193210_scale_y*(2.0*1.0-1.0)))).x-0.5)+sin(p_o193184_rotate*0.01745329251)*((transform2((transform2((uv), vec2(p_o193246_translate_x*(2.0*1.0-1.0), (elapsed_time*.5)*(2.0*1.0-1.0)), p_o193246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193246_scale_x*(2.0*1.0-1.0), p_o193246_scale_y*(2.0*1.0-1.0)))), vec2(p_o193210_translate_x*(2.0*1.0-1.0), p_o193210_translate_y*(2.0*(dot(o193212_0_3_rgb, vec3(1.0))/3.0)-1.0)), p_o193210_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o193210_scale_x*(2.0*1.0-1.0), p_o193210_scale_y*(2.0*1.0-1.0)))).y-0.5))/(cos(abs(mod(p_o193184_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o193184_0_3_rgba = o193184_gradient_gradient_fct(fract(o193184_2_r*p_o193184_repeat));
vec4 o193210_0_4_rgba = o193184_0_3_rgba;
float o193213_3_clamp_false = pow((dot((o193210_0_4_rgba).rgb, vec3(1.0))/3.0),p_o193213_default_in2);
float o193213_3_clamp_true = clamp(o193213_3_clamp_false, 0.0, 1.0);
float o193213_0_5_f = o193213_3_clamp_false;
float o193244_2_clamp_false = (dot((o193224_1).rgb, vec3(1.0))/3.0)+o193213_0_5_f;
float o193244_2_clamp_true = clamp(o193244_2_clamp_false, 0.0, 1.0);
float o193244_0_3_f = o193244_2_clamp_false;
vec4 o193245_0_4_rgba = vec4(0.0, o193244_0_3_f, 0.0, 1.0);
vec4 o193246_0_4_rgba = o193245_0_4_rgba;
vec4 o193247_0_1_rgba = clamp(mix(o193246_0_1_rgba,o193246_0_4_rgba,step(p_o193247_r,o193247_0_f)),0.0,1.0);

	vec4 color_tex = o193247_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



