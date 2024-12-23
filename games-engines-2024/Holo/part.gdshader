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
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
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
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
const float p_o340095_translate_x = 0.000000000;
const float p_o340095_translate_y = 0.035000000;
const float p_o340095_rotate = 0.000000000;
const float p_o340095_scale_x = 1.500000000;
const float p_o340095_scale_y = 1.395000000;
const float p_o340098_translate_x = 0.300000000;
const float p_o340098_translate_y = 0.050000000;
const float p_o340098_rotate = 0.000000000;
const float p_o340098_scale_x = 1.000000000;
const float p_o340098_scale_y = 1.000000000;
const float p_o339546_amount1 = 1.000000000;
const float seed_o339549 = 0.352859154;
const float p_o339549_count = 100.000000000;
const float p_o339549_rings = 1.000000000;
const float p_o339549_scale_x = 1.000000000;
const float p_o339549_scale_y = 1.000000000;
const float p_o339549_radius = 0.030000000;
const float p_o339549_spiral = 0.000000000;
const float p_o339549_i_rotate = 0.000000000;
const float p_o339549_i_scale = 0.000000000;
const float p_o339549_rotate = 0.000000000;
const float p_o339549_scale = 0.000000000;
const float p_o339549_value = 0.100000000;
const float p_o339542_amount1 = 1.000000000;
const float p_o339542_amount2 = 1.000000000;
const float seed_o339554 = 1.000524998;
const float p_o339554_translate_x = 0.080000000;
const float p_o339554_translate_y = -0.350000000;
const float p_o339554_scale_x = 1.000000000;
const float p_o339554_scale_y = 1.000000000;
const float seed_o339544 = 0.983210862;
const float seed_o339553 = 1.070676446;
const float p_o339555_sides = 4.000000000;
const float p_o339555_radius = 0.400000000;
const float p_o339555_edge = 0.100000000;
const float seed_o339548 = 0.949579835;
const float p_o339548_in_min = 0.000000000;
const float p_o339548_in_max = 1.000000000;
const float p_o339548_out_max = 0.000000000;
const float p_o339541_default_in1 = 0.000000000;
const float p_o339541_default_in2 = 0.000000000;
const float seed_o339547 = 0.385463282;
const float p_o339547_in_min = 0.000000000;
const float p_o339547_out_min = 3.000000000;
const float p_o339547_out_max = 0.000000000;
const float seed_o339543 = 1.060066521;
const float p_o339543_in_min = 0.000000000;
const float p_o339543_out_min = 0.000000000;
const float p_o339543_out_max = 1.000000000;
float o339549_input_in(vec2 uv, float _seed_variation_) {
float o339544_0_1_f = (param_rnd(0,1, (seed_o339544+fract(_seed_variation_))+0.841471));
float o339553_0_1_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339553+fract(_seed_variation_))+0.420167)));
float o339553_0_3_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339553+fract(_seed_variation_))+0.420167)));
float o339541_0_clamp_false = smoothstep(0.0, 1.0, o339553_0_3_f);
float o339541_0_clamp_true = clamp(o339541_0_clamp_false, 0.0, 1.0);
float o339541_0_1_f = o339541_0_clamp_false;
vec4 o339548_0_1_rgba = vec4(vec3((param_rnd(0,.5, (seed_o339548+fract(_seed_variation_))+34.841471)))+(vec4(vec3(o339541_0_1_f), 1.0).rgb-vec3(p_o339548_in_min))*vec3((p_o339548_out_max-((param_rnd(0,.5, (seed_o339548+fract(_seed_variation_))+34.841471))))/(p_o339548_in_max-(p_o339548_in_min))), vec4(vec3(o339541_0_1_f), 1.0).a);
float o339555_0_1_f = shape_polygon((transform2_clamp(transform2((uv), vec2(p_o339554_translate_x*(2.0*o339544_0_1_f-1.0), p_o339554_translate_y*(2.0*o339553_0_1_f-1.0)), (elapsed_time*param_rnd(-200,200, (seed_o339554+fract(_seed_variation_))+34.656987)+param_rnd(100,200, (seed_o339554+fract(_seed_variation_))+34.017702))*0.01745329251*(2.0*1.0-1.0), vec2(p_o339554_scale_x*(2.0*1.0-1.0), p_o339554_scale_y*(2.0*1.0-1.0))))), p_o339555_sides, p_o339555_radius*(dot((o339548_0_1_rgba).rgb, vec3(1.0))/3.0), p_o339555_edge*1.0);
vec4 o339554_0_1_rgba = vec4(vec3(o339555_0_1_f), 1.0);
vec4 o339547_0_1_rgba = vec4(vec3(p_o339547_out_min)+(vec4(vec3(o339553_0_1_f), 1.0).rgb-vec3(p_o339547_in_min))*vec3((p_o339547_out_max-(p_o339547_out_min))/((param_rnd(.2,1, (seed_o339547+fract(_seed_variation_))+17.841471))-(p_o339547_in_min))), vec4(vec3(o339553_0_1_f), 1.0).a);
vec4 o339543_0_1_rgba = vec4(vec3(p_o339543_out_min)+(vec4(vec3(o339553_0_1_f), 1.0).rgb-vec3(p_o339543_in_min))*vec3((p_o339543_out_max-(p_o339543_out_min))/((param_rnd(0,.3, (seed_o339543+fract(_seed_variation_))+17.841471))-(p_o339543_in_min))), vec4(vec3(o339553_0_1_f), 1.0).a);
vec4 o339542_0_b = o339554_0_1_rgba;
vec4 o339542_0_l;
float o339542_0_a;
o339542_0_l = o339547_0_1_rgba;
o339542_0_a = p_o339542_amount1*1.0;
o339542_0_b = vec4(blend_multiply((uv), o339542_0_l.rgb, o339542_0_b.rgb, o339542_0_a*o339542_0_l.a), min(1.0, o339542_0_b.a+o339542_0_a*o339542_0_l.a));
o339542_0_l = o339543_0_1_rgba;
o339542_0_a = p_o339542_amount2*1.0;
o339542_0_b = vec4(blend_darken((uv), o339542_0_l.rgb, o339542_0_b.rgb, o339542_0_a*o339542_0_l.a), min(1.0, o339542_0_b.a+o339542_0_a*o339542_0_l.a));
vec4 o339542_0_2_rgba = o339542_0_b;
return (dot((o339542_0_2_rgba).rgb, vec3(1.0))/3.0);
}
float o339549_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o339549(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o339549_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o339549_radius*mix(rings_distance, spiral_distance, p_o339549_spiral)*vec2(cos(a), sin(a));
		float mask = o339549_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o339549_rotate * 0.01745329251 + (a+1.57079632679) * p_o339549_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o339549_i_scale);
			pv /= vec2(p_o339549_scale_x, p_o339549_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o339549_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o339549_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o339549_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o339527_gradient_0_pos = 0.036364000;
const vec4 p_o339527_gradient_0_col = vec4(0.735337019, 0.371612996, 0.960937977, 1.000000000);
const float p_o339527_gradient_1_pos = 0.645455000;
const vec4 p_o339527_gradient_1_col = vec4(0.377196997, 0.569800973, 0.937500000, 1.000000000);
vec4 o339527_gradient_gradient_fct(float x) {
  if (x < p_o339527_gradient_0_pos) {
    return p_o339527_gradient_0_col;
  } else if (x < p_o339527_gradient_1_pos) {
    return mix(p_o339527_gradient_0_col, p_o339527_gradient_1_col, (x-p_o339527_gradient_0_pos)/(p_o339527_gradient_1_pos-p_o339527_gradient_0_pos));
  }
  return p_o339527_gradient_1_col;
}
const float p_o340099_translate_x = -0.300000000;
const float p_o340099_translate_y = 0.045000000;
const float p_o340099_rotate = 0.000000000;
const float p_o340099_scale_x = 1.000000000;
const float p_o340099_scale_y = 1.000000000;
const float p_o339677_amount1 = 1.000000000;
const float seed_o339671 = 0.840738416;
const float p_o339671_count = 100.000000000;
const float p_o339671_rings = 1.000000000;
const float p_o339671_scale_x = 1.000000000;
const float p_o339671_scale_y = 1.000000000;
const float p_o339671_radius = 0.000000000;
const float p_o339671_spiral = 0.000000000;
const float p_o339671_i_rotate = 0.000000000;
const float p_o339671_i_scale = 0.000000000;
const float p_o339671_rotate = 0.000000000;
const float p_o339671_scale = 0.000000000;
const float p_o339671_value = 0.100000000;
const float p_o339685_amount1 = 1.000000000;
const float p_o339685_amount2 = 1.000000000;
const float seed_o339669 = 0.863864899;
const float p_o339669_translate_x = 0.120000000;
const float p_o339669_translate_y = -0.350000000;
const float p_o339669_scale_x = 1.000000000;
const float p_o339669_scale_y = 1.000000000;
const float seed_o339679 = 0.846550763;
const float seed_o339670 = 0.934016347;
const float p_o339668_sides = 3.000000000;
const float p_o339668_radius = 0.340000000;
const float p_o339668_edge = 0.100000000;
const float seed_o339675 = 0.812919736;
const float p_o339675_in_min = 0.000000000;
const float p_o339675_in_max = 1.000000000;
const float p_o339675_out_max = 0.000000000;
const float p_o339686_default_in1 = 0.000000000;
const float p_o339686_default_in2 = 0.000000000;
const float seed_o339676 = 0.248803183;
const float p_o339676_in_min = 0.000000000;
const float p_o339676_out_min = 3.000000000;
const float p_o339676_out_max = 0.000000000;
const float seed_o339684 = 0.923406422;
const float p_o339684_in_min = 0.000000000;
const float p_o339684_out_min = 0.000000000;
const float p_o339684_out_max = 1.000000000;
float o339671_input_in(vec2 uv, float _seed_variation_) {
float o339679_0_1_f = (param_rnd(0,1, (seed_o339679+fract(_seed_variation_))+0.841471));
float o339670_0_1_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339670+fract(_seed_variation_))+0.420167)));
float o339670_0_3_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339670+fract(_seed_variation_))+0.420167)));
float o339686_0_clamp_false = smoothstep(0.0, 1.0, o339670_0_3_f);
float o339686_0_clamp_true = clamp(o339686_0_clamp_false, 0.0, 1.0);
float o339686_0_1_f = o339686_0_clamp_false;
vec4 o339675_0_1_rgba = vec4(vec3((param_rnd(0,.4, (seed_o339675+fract(_seed_variation_))+34.841471)))+(vec4(vec3(o339686_0_1_f), 1.0).rgb-vec3(p_o339675_in_min))*vec3((p_o339675_out_max-((param_rnd(0,.4, (seed_o339675+fract(_seed_variation_))+34.841471))))/(p_o339675_in_max-(p_o339675_in_min))), vec4(vec3(o339686_0_1_f), 1.0).a);
float o339668_0_1_f = shape_polygon((transform2_clamp(transform2((uv), vec2(p_o339669_translate_x*(2.0*o339679_0_1_f-1.0), p_o339669_translate_y*(2.0*o339670_0_1_f-1.0)), (elapsed_time*param_rnd(-200,200, (seed_o339669+fract(_seed_variation_))+34.656987)+param_rnd(100,200, (seed_o339669+fract(_seed_variation_))+34.017702))*0.01745329251*(2.0*1.0-1.0), vec2(p_o339669_scale_x*(2.0*1.0-1.0), p_o339669_scale_y*(2.0*1.0-1.0))))), p_o339668_sides, p_o339668_radius*(dot((o339675_0_1_rgba).rgb, vec3(1.0))/3.0), p_o339668_edge*1.0);
vec4 o339669_0_1_rgba = vec4(vec3(o339668_0_1_f), 1.0);
vec4 o339676_0_1_rgba = vec4(vec3(p_o339676_out_min)+(vec4(vec3(o339670_0_1_f), 1.0).rgb-vec3(p_o339676_in_min))*vec3((p_o339676_out_max-(p_o339676_out_min))/((param_rnd(.2,1, (seed_o339676+fract(_seed_variation_))+17.841471))-(p_o339676_in_min))), vec4(vec3(o339670_0_1_f), 1.0).a);
vec4 o339684_0_1_rgba = vec4(vec3(p_o339684_out_min)+(vec4(vec3(o339670_0_1_f), 1.0).rgb-vec3(p_o339684_in_min))*vec3((p_o339684_out_max-(p_o339684_out_min))/((param_rnd(0,.3, (seed_o339684+fract(_seed_variation_))+17.841471))-(p_o339684_in_min))), vec4(vec3(o339670_0_1_f), 1.0).a);
vec4 o339685_0_b = o339669_0_1_rgba;
vec4 o339685_0_l;
float o339685_0_a;
o339685_0_l = o339676_0_1_rgba;
o339685_0_a = p_o339685_amount1*1.0;
o339685_0_b = vec4(blend_multiply((uv), o339685_0_l.rgb, o339685_0_b.rgb, o339685_0_a*o339685_0_l.a), min(1.0, o339685_0_b.a+o339685_0_a*o339685_0_l.a));
o339685_0_l = o339684_0_1_rgba;
o339685_0_a = p_o339685_amount2*1.0;
o339685_0_b = vec4(blend_darken((uv), o339685_0_l.rgb, o339685_0_b.rgb, o339685_0_a*o339685_0_l.a), min(1.0, o339685_0_b.a+o339685_0_a*o339685_0_l.a));
vec4 o339685_0_2_rgba = o339685_0_b;
return (dot((o339685_0_2_rgba).rgb, vec3(1.0))/3.0);
}
float o339671_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o339671(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o339671_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o339671_radius*mix(rings_distance, spiral_distance, p_o339671_spiral)*vec2(cos(a), sin(a));
		float mask = o339671_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o339671_rotate * 0.01745329251 + (a+1.57079632679) * p_o339671_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o339671_i_scale);
			pv /= vec2(p_o339671_scale_x, p_o339671_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o339671_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o339671_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o339671_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o339688_gradient_0_pos = 0.274302000;
const vec4 p_o339688_gradient_0_col = vec4(1.000000000, 0.574218988, 0.574218988, 1.000000000);
const float p_o339688_gradient_1_pos = 0.659994000;
const vec4 p_o339688_gradient_1_col = vec4(0.671875000, 0.399827987, 0.110229000, 1.000000000);
vec4 o339688_gradient_gradient_fct(float x) {
  if (x < p_o339688_gradient_0_pos) {
    return p_o339688_gradient_0_col;
  } else if (x < p_o339688_gradient_1_pos) {
    return mix(p_o339688_gradient_0_col, p_o339688_gradient_1_col, (x-p_o339688_gradient_0_pos)/(p_o339688_gradient_1_pos-p_o339688_gradient_0_pos));
  }
  return p_o339688_gradient_1_col;
}
const float p_o340097_translate_x = 0.300000000;
const float p_o340097_translate_y = -0.300000000;
const float p_o340097_rotate = 0.000000000;
const float p_o340097_scale_x = 1.000000000;
const float p_o340097_scale_y = 1.000000000;
const float p_o339821_amount1 = 1.000000000;
const float seed_o339815 = 0.840738416;
const float p_o339815_count = 200.000000000;
const float p_o339815_rings = 1.000000000;
const float p_o339815_scale_x = 1.000000000;
const float p_o339815_scale_y = 1.000000000;
const float p_o339815_radius = 0.000000000;
const float p_o339815_spiral = 0.000000000;
const float p_o339815_i_rotate = 0.000000000;
const float p_o339815_i_scale = 0.000000000;
const float p_o339815_rotate = 0.000000000;
const float p_o339815_scale = 0.000000000;
const float p_o339815_value = 0.100000000;
const float p_o339825_amount1 = 1.000000000;
const float p_o339825_amount2 = 1.000000000;
const float seed_o339841 = 0.863864899;
const float p_o339841_translate_x = 0.120000000;
const float p_o339841_translate_y = -0.350000000;
const float p_o339841_scale_x = 1.000000000;
const float p_o339841_scale_y = 1.000000000;
const float seed_o339823 = 0.846550763;
const float seed_o339814 = 0.934016347;
const float p_o339813_sides = 3.000000000;
const float p_o339813_radius = 0.340000000;
const float p_o339813_edge = 0.100000000;
const float seed_o339819 = 0.812919736;
const float p_o339819_in_min = 0.000000000;
const float p_o339819_in_max = 1.000000000;
const float p_o339819_out_max = 0.000000000;
const float p_o339826_default_in1 = 0.000000000;
const float p_o339826_default_in2 = 0.000000000;
const float seed_o339820 = 0.248803183;
const float p_o339820_in_min = 0.000000000;
const float p_o339820_out_min = 3.000000000;
const float p_o339820_out_max = 0.000000000;
const float seed_o339824 = 0.923406422;
const float p_o339824_in_min = 0.000000000;
const float p_o339824_out_min = 0.000000000;
const float p_o339824_out_max = 1.000000000;
float o339815_input_in(vec2 uv, float _seed_variation_) {
float o339823_0_1_f = (param_rnd(0,1, (seed_o339823+fract(_seed_variation_))+0.841471));
float o339814_0_1_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339814+fract(_seed_variation_))+0.420167)));
float o339814_0_3_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339814+fract(_seed_variation_))+0.420167)));
float o339826_0_clamp_false = smoothstep(0.0, 1.0, o339814_0_3_f);
float o339826_0_clamp_true = clamp(o339826_0_clamp_false, 0.0, 1.0);
float o339826_0_1_f = o339826_0_clamp_false;
vec4 o339819_0_1_rgba = vec4(vec3((param_rnd(0,.4, (seed_o339819+fract(_seed_variation_))+34.841471)))+(vec4(vec3(o339826_0_1_f), 1.0).rgb-vec3(p_o339819_in_min))*vec3((p_o339819_out_max-((param_rnd(0,.4, (seed_o339819+fract(_seed_variation_))+34.841471))))/(p_o339819_in_max-(p_o339819_in_min))), vec4(vec3(o339826_0_1_f), 1.0).a);
float o339813_0_1_f = shape_circle((transform2_clamp(transform2((uv), vec2(p_o339841_translate_x*(2.0*o339823_0_1_f-1.0), p_o339841_translate_y*(2.0*o339814_0_1_f-1.0)), (elapsed_time*param_rnd(-200,200, (seed_o339841+fract(_seed_variation_))+34.656987)+param_rnd(100,200, (seed_o339841+fract(_seed_variation_))+34.017702))*0.01745329251*(2.0*1.0-1.0), vec2(p_o339841_scale_x*(2.0*1.0-1.0), p_o339841_scale_y*(2.0*1.0-1.0))))), p_o339813_sides, p_o339813_radius*(dot((o339819_0_1_rgba).rgb, vec3(1.0))/3.0), p_o339813_edge*1.0);
vec4 o339841_0_1_rgba = vec4(vec3(o339813_0_1_f), 1.0);
vec4 o339820_0_1_rgba = vec4(vec3(p_o339820_out_min)+(vec4(vec3(o339814_0_1_f), 1.0).rgb-vec3(p_o339820_in_min))*vec3((p_o339820_out_max-(p_o339820_out_min))/((param_rnd(.2,1, (seed_o339820+fract(_seed_variation_))+17.841471))-(p_o339820_in_min))), vec4(vec3(o339814_0_1_f), 1.0).a);
vec4 o339824_0_1_rgba = vec4(vec3(p_o339824_out_min)+(vec4(vec3(o339814_0_1_f), 1.0).rgb-vec3(p_o339824_in_min))*vec3((p_o339824_out_max-(p_o339824_out_min))/((param_rnd(0,.3, (seed_o339824+fract(_seed_variation_))+17.841471))-(p_o339824_in_min))), vec4(vec3(o339814_0_1_f), 1.0).a);
vec4 o339825_0_b = o339841_0_1_rgba;
vec4 o339825_0_l;
float o339825_0_a;
o339825_0_l = o339820_0_1_rgba;
o339825_0_a = p_o339825_amount1*1.0;
o339825_0_b = vec4(blend_multiply((uv), o339825_0_l.rgb, o339825_0_b.rgb, o339825_0_a*o339825_0_l.a), min(1.0, o339825_0_b.a+o339825_0_a*o339825_0_l.a));
o339825_0_l = o339824_0_1_rgba;
o339825_0_a = p_o339825_amount2*1.0;
o339825_0_b = vec4(blend_darken((uv), o339825_0_l.rgb, o339825_0_b.rgb, o339825_0_a*o339825_0_l.a), min(1.0, o339825_0_b.a+o339825_0_a*o339825_0_l.a));
vec4 o339825_0_2_rgba = o339825_0_b;
return (dot((o339825_0_2_rgba).rgb, vec3(1.0))/3.0);
}
float o339815_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o339815(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o339815_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o339815_radius*mix(rings_distance, spiral_distance, p_o339815_spiral)*vec2(cos(a), sin(a));
		float mask = o339815_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o339815_rotate * 0.01745329251 + (a+1.57079632679) * p_o339815_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o339815_i_scale);
			pv /= vec2(p_o339815_scale_x, p_o339815_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o339815_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o339815_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o339815_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o339828_gradient_0_pos = 0.274302000;
const vec4 p_o339828_gradient_0_col = vec4(0.573297977, 0.656250000, 0.097411998, 1.000000000);
const float p_o339828_gradient_1_pos = 0.659994000;
const vec4 p_o339828_gradient_1_col = vec4(0.041198999, 0.656583011, 0.703125000, 1.000000000);
vec4 o339828_gradient_gradient_fct(float x) {
  if (x < p_o339828_gradient_0_pos) {
    return p_o339828_gradient_0_col;
  } else if (x < p_o339828_gradient_1_pos) {
    return mix(p_o339828_gradient_0_col, p_o339828_gradient_1_col, (x-p_o339828_gradient_0_pos)/(p_o339828_gradient_1_pos-p_o339828_gradient_0_pos));
  }
  return p_o339828_gradient_1_col;
}
const float p_o340100_translate_x = -0.300000000;
const float p_o340100_translate_y = -0.300000000;
const float p_o340100_rotate = 0.000000000;
const float p_o340100_scale_x = 1.000000000;
const float p_o340100_scale_y = 1.000000000;
const float p_o339982_amount1 = 1.000000000;
const float seed_o339957 = 0.840738416;
const float p_o339957_count = 100.000000000;
const float p_o339957_rings = 1.000000000;
const float p_o339957_scale_x = 1.000000000;
const float p_o339957_scale_y = 1.000000000;
const float p_o339957_radius = 0.040000000;
const float p_o339957_spiral = 0.000000000;
const float p_o339957_i_rotate = 0.000000000;
const float p_o339957_i_scale = 0.000000000;
const float p_o339957_rotate = 0.000000000;
const float p_o339957_scale = 0.000000000;
const float p_o339957_value = 0.100000000;
const float p_o339966_amount1 = 1.000000000;
const float p_o339966_amount2 = 1.000000000;
const float seed_o339955 = 0.863864899;
const float p_o339955_translate_x = 0.120000000;
const float p_o339955_translate_y = -0.350000000;
const float p_o339955_scale_x = 1.000000000;
const float p_o339955_scale_y = 1.000000000;
const float seed_o339964 = 0.846550763;
const float seed_o339956 = 0.934016347;
const float seed_o339954 = 0.993249476;
const float p_o339954_radius = 0.340000000;
const float p_o339954_edge = 0.100000000;
const float seed_o339961 = 0.812919736;
const float p_o339961_in_min = 0.000000000;
const float p_o339961_in_max = 1.000000000;
const float p_o339961_out_max = 0.000000000;
const float p_o339967_default_in1 = 0.000000000;
const float p_o339967_default_in2 = 0.000000000;
const float seed_o339962 = 0.248803183;
const float p_o339962_in_min = 0.000000000;
const float p_o339962_out_min = 3.000000000;
const float p_o339962_out_max = 0.000000000;
const float seed_o339965 = 0.923406422;
const float p_o339965_in_min = 0.000000000;
const float p_o339965_out_min = 0.000000000;
const float p_o339965_out_max = 1.000000000;
float o339957_input_in(vec2 uv, float _seed_variation_) {
float o339964_0_1_f = (param_rnd(0,1, (seed_o339964+fract(_seed_variation_))+0.841471));
float o339956_0_1_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339956+fract(_seed_variation_))+0.420167)));
float o339956_0_3_f = (fract(elapsed_time+param_rnd(-1,1, (seed_o339956+fract(_seed_variation_))+0.420167)));
float o339967_0_clamp_false = smoothstep(0.0, 1.0, o339956_0_3_f);
float o339967_0_clamp_true = clamp(o339967_0_clamp_false, 0.0, 1.0);
float o339967_0_1_f = o339967_0_clamp_false;
vec4 o339961_0_1_rgba = vec4(vec3((param_rnd(0,.4, (seed_o339961+fract(_seed_variation_))+34.841471)))+(vec4(vec3(o339967_0_1_f), 1.0).rgb-vec3(p_o339961_in_min))*vec3((p_o339961_out_max-((param_rnd(0,.4, (seed_o339961+fract(_seed_variation_))+34.841471))))/(p_o339961_in_max-(p_o339961_in_min))), vec4(vec3(o339967_0_1_f), 1.0).a);
float o339954_0_1_f = shape_polygon((transform2_clamp(transform2((uv), vec2(p_o339955_translate_x*(2.0*o339964_0_1_f-1.0), p_o339955_translate_y*(2.0*o339956_0_1_f-1.0)), (elapsed_time*param_rnd(-200,200, (seed_o339955+fract(_seed_variation_))+34.656987)+param_rnd(100,200, (seed_o339955+fract(_seed_variation_))+34.017702))*0.01745329251*(2.0*1.0-1.0), vec2(p_o339955_scale_x*(2.0*1.0-1.0), p_o339955_scale_y*(2.0*1.0-1.0))))), (floor(param_rnd(3,10, (seed_o339954+fract(_seed_variation_))+0.656987))), p_o339954_radius*(dot((o339961_0_1_rgba).rgb, vec3(1.0))/3.0), p_o339954_edge*1.0);
vec4 o339955_0_1_rgba = vec4(vec3(o339954_0_1_f), 1.0);
vec4 o339962_0_1_rgba = vec4(vec3(p_o339962_out_min)+(vec4(vec3(o339956_0_1_f), 1.0).rgb-vec3(p_o339962_in_min))*vec3((p_o339962_out_max-(p_o339962_out_min))/((param_rnd(.2,1, (seed_o339962+fract(_seed_variation_))+17.841471))-(p_o339962_in_min))), vec4(vec3(o339956_0_1_f), 1.0).a);
vec4 o339965_0_1_rgba = vec4(vec3(p_o339965_out_min)+(vec4(vec3(o339956_0_1_f), 1.0).rgb-vec3(p_o339965_in_min))*vec3((p_o339965_out_max-(p_o339965_out_min))/((param_rnd(0,.3, (seed_o339965+fract(_seed_variation_))+17.841471))-(p_o339965_in_min))), vec4(vec3(o339956_0_1_f), 1.0).a);
vec4 o339966_0_b = o339955_0_1_rgba;
vec4 o339966_0_l;
float o339966_0_a;
o339966_0_l = o339962_0_1_rgba;
o339966_0_a = p_o339966_amount1*1.0;
o339966_0_b = vec4(blend_multiply((uv), o339966_0_l.rgb, o339966_0_b.rgb, o339966_0_a*o339966_0_l.a), min(1.0, o339966_0_b.a+o339966_0_a*o339966_0_l.a));
o339966_0_l = o339965_0_1_rgba;
o339966_0_a = p_o339966_amount2*1.0;
o339966_0_b = vec4(blend_darken((uv), o339966_0_l.rgb, o339966_0_b.rgb, o339966_0_a*o339966_0_l.a), min(1.0, o339966_0_b.a+o339966_0_a*o339966_0_l.a));
vec4 o339966_0_2_rgba = o339966_0_b;
return (dot((o339966_0_2_rgba).rgb, vec3(1.0))/3.0);
}
float o339957_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o339957(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o339957_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o339957_radius*mix(rings_distance, spiral_distance, p_o339957_spiral)*vec2(cos(a), sin(a));
		float mask = o339957_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o339957_rotate * 0.01745329251 + (a+1.57079632679) * p_o339957_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o339957_i_scale);
			pv /= vec2(p_o339957_scale_x, p_o339957_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o339957_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o339957_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o339957_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o339969_gradient_0_pos = 0.274302000;
const vec4 p_o339969_gradient_0_col = vec4(0.875000000, 0.311035007, 0.311035007, 1.000000000);
const float p_o339969_gradient_1_pos = 0.659994000;
const vec4 p_o339969_gradient_1_col = vec4(0.751999021, 0.326660007, 0.871093988, 1.000000000);
vec4 o339969_gradient_gradient_fct(float x) {
  if (x < p_o339969_gradient_0_pos) {
    return p_o339969_gradient_0_col;
  } else if (x < p_o339969_gradient_1_pos) {
    return mix(p_o339969_gradient_0_col, p_o339969_gradient_1_col, (x-p_o339969_gradient_0_pos)/(p_o339969_gradient_1_pos-p_o339969_gradient_0_pos));
  }
  return p_o339969_gradient_1_col;
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec3 o339549_0_instance_uv = vec3(0.0);
vec4 o339549_0_rch = splatter_o339549((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))), vec2(p_o340098_translate_x*(2.0*1.0-1.0), p_o340098_translate_y*(2.0*1.0-1.0)), p_o340098_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340098_scale_x*(2.0*1.0-1.0), p_o340098_scale_y*(2.0*1.0-1.0)))), int(p_o339549_count), int(p_o339549_rings), o339549_0_instance_uv, vec2(float((seed_o339549+fract(_seed_variation_)))), _seed_variation_);float o339549_0_1_f = o339549_0_rch.a;
vec4 o339527_0_1_rgba = o339527_gradient_gradient_fct(o339549_0_1_f);
vec4 o339546_0_b = vec4(vec3(o339549_0_1_f), 1.0);
vec4 o339546_0_l;
float o339546_0_a;

o339546_0_l = o339527_0_1_rgba;
o339546_0_a = p_o339546_amount1*1.0;
o339546_0_b = vec4(blend_multiply((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))), vec2(p_o340098_translate_x*(2.0*1.0-1.0), p_o340098_translate_y*(2.0*1.0-1.0)), p_o340098_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340098_scale_x*(2.0*1.0-1.0), p_o340098_scale_y*(2.0*1.0-1.0)))), o339546_0_l.rgb, o339546_0_b.rgb, o339546_0_a*o339546_0_l.a), min(1.0, o339546_0_b.a+o339546_0_a*o339546_0_l.a));

vec4 o339546_0_2_rgba = o339546_0_b;
vec4 o340098_0_1_rgba = o339546_0_2_rgba;
vec3 o339671_0_instance_uv = vec3(0.0);
vec4 o339671_0_rch = splatter_o339671((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))-vec2(1.0, 0.0)), vec2(p_o340099_translate_x*(2.0*1.0-1.0), p_o340099_translate_y*(2.0*1.0-1.0)), p_o340099_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340099_scale_x*(2.0*1.0-1.0), p_o340099_scale_y*(2.0*1.0-1.0)))), int(p_o339671_count), int(p_o339671_rings), o339671_0_instance_uv, vec2(float((seed_o339671+fract(_seed_variation_)))), _seed_variation_);float o339671_0_1_f = o339671_0_rch.a;
vec3 o339671_1_2_rgb = o339671_0_rch.rgb;
vec4 o339688_0_1_rgba = o339688_gradient_gradient_fct((dot(o339671_1_2_rgb, vec3(1.0))/3.0));
vec4 o339677_0_b = vec4(vec3(o339671_0_1_f), 1.0);
vec4 o339677_0_l;
float o339677_0_a;

o339677_0_l = o339688_0_1_rgba;
o339677_0_a = p_o339677_amount1*1.0;
o339677_0_b = vec4(blend_multiply((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))-vec2(1.0, 0.0)), vec2(p_o340099_translate_x*(2.0*1.0-1.0), p_o340099_translate_y*(2.0*1.0-1.0)), p_o340099_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340099_scale_x*(2.0*1.0-1.0), p_o340099_scale_y*(2.0*1.0-1.0)))), o339677_0_l.rgb, o339677_0_b.rgb, o339677_0_a*o339677_0_l.a), min(1.0, o339677_0_b.a+o339677_0_a*o339677_0_l.a));

vec4 o339677_0_2_rgba = o339677_0_b;
vec4 o340099_0_1_rgba = o339677_0_2_rgba;
vec3 o339815_0_instance_uv = vec3(0.0);
vec4 o339815_0_rch = splatter_o339815((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))-vec2(0.0, 1.0)), vec2(p_o340097_translate_x*(2.0*1.0-1.0), p_o340097_translate_y*(2.0*1.0-1.0)), p_o340097_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340097_scale_x*(2.0*1.0-1.0), p_o340097_scale_y*(2.0*1.0-1.0)))), int(p_o339815_count), int(p_o339815_rings), o339815_0_instance_uv, vec2(float((seed_o339815+fract(_seed_variation_)))), _seed_variation_);float o339815_0_1_f = o339815_0_rch.a;
vec3 o339815_1_2_rgb = o339815_0_rch.rgb;
vec4 o339828_0_1_rgba = o339828_gradient_gradient_fct((dot(o339815_1_2_rgb, vec3(1.0))/3.0));
vec4 o339821_0_b = vec4(vec3(o339815_0_1_f), 1.0);
vec4 o339821_0_l;
float o339821_0_a;

o339821_0_l = o339828_0_1_rgba;
o339821_0_a = p_o339821_amount1*1.0;
o339821_0_b = vec4(blend_multiply((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))-vec2(0.0, 1.0)), vec2(p_o340097_translate_x*(2.0*1.0-1.0), p_o340097_translate_y*(2.0*1.0-1.0)), p_o340097_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340097_scale_x*(2.0*1.0-1.0), p_o340097_scale_y*(2.0*1.0-1.0)))), o339821_0_l.rgb, o339821_0_b.rgb, o339821_0_a*o339821_0_l.a), min(1.0, o339821_0_b.a+o339821_0_a*o339821_0_l.a));

vec4 o339821_0_2_rgba = o339821_0_b;
vec4 o340097_0_1_rgba = o339821_0_2_rgba;
vec3 o339957_0_instance_uv = vec3(0.0);
vec4 o339957_0_rch = splatter_o339957((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))-vec2(1.0, 1.0)), vec2(p_o340100_translate_x*(2.0*1.0-1.0), p_o340100_translate_y*(2.0*1.0-1.0)), p_o340100_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340100_scale_x*(2.0*1.0-1.0), p_o340100_scale_y*(2.0*1.0-1.0)))), int(p_o339957_count), int(p_o339957_rings), o339957_0_instance_uv, vec2(float((seed_o339957+fract(_seed_variation_)))), _seed_variation_);float o339957_0_1_f = o339957_0_rch.a;
vec3 o339957_1_2_rgb = o339957_0_rch.rgb;
vec4 o339969_0_1_rgba = o339969_gradient_gradient_fct((dot(o339957_1_2_rgb, vec3(1.0))/3.0));
vec4 o339982_0_b = vec4(vec3(o339957_0_1_f), 1.0);
vec4 o339982_0_l;
float o339982_0_a;

o339982_0_l = o339969_0_1_rgba;
o339982_0_a = p_o339982_amount1*1.0;
o339982_0_b = vec4(blend_multiply((transform2((2.0*(transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0))))-vec2(1.0, 1.0)), vec2(p_o340100_translate_x*(2.0*1.0-1.0), p_o340100_translate_y*(2.0*1.0-1.0)), p_o340100_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340100_scale_x*(2.0*1.0-1.0), p_o340100_scale_y*(2.0*1.0-1.0)))), o339982_0_l.rgb, o339982_0_b.rgb, o339982_0_a*o339982_0_l.a), min(1.0, o339982_0_b.a+o339982_0_a*o339982_0_l.a));

vec4 o339982_0_2_rgba = o339982_0_b;
vec4 o340100_0_1_rgba = o339982_0_2_rgba;
vec4 o340094_0_1_rgba = ((transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0)))).y < 0.5) ? (((transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0)))).x < 0.5) ? (o340098_0_1_rgba) : (o340099_0_1_rgba)) : (((transform2((uv), vec2(p_o340095_translate_x*(2.0*1.0-1.0), p_o340095_translate_y*(2.0*1.0-1.0)), p_o340095_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o340095_scale_x*(2.0*1.0-1.0), p_o340095_scale_y*(2.0*1.0-1.0)))).x < 0.5) ? (o340097_0_1_rgba) : (o340100_0_1_rgba));
vec4 o340095_0_1_rgba = o340094_0_1_rgba;

	vec4 color_tex = o340095_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



