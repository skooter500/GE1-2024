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
float cross2( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }
// signed distance to a quadratic bezier
vec2 sdBezier( in vec2 pos, in vec2 A, in vec2 B, in vec2 C ) {	
	vec2 a = B - A;
	vec2 b = A - 2.0*B + C;
	vec2 c = a * 2.0;
	vec2 d = A - pos;
	float kk = 1.0/dot(b,b);
	float kx = kk * dot(a,b);
	float ky = kk * (2.0*dot(a,a)+dot(d,b))/3.0;
	float kz = kk * dot(d,a);	  
	float res = 0.0;
	float sgn = 0.0;
	float p = ky - kx*kx;
	float p3 = p*p*p;
	float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
	float h = q*q + 4.0*p3;
	float rvx;
	if( h>=0.0 ) { // 1 root
		h = sqrt(h);
		vec2 x = (vec2(h,-h)-q)/2.0;
		vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
		rvx = uv.x+uv.y-kx;
		float t = clamp(rvx, 0.0, 1.0);
		vec2 q2 = d+(c+b*t)*t;
		res = dot(q2, q2);
		sgn = cross2(c+2.0*b*t, q2);
	} else {   // 3 roots
		float z = sqrt(-p);
		float v = acos(q/(p*z*2.0))/3.0;
		float m = cos(v);
		float n = sin(v)*1.732050808;
		vec3  t = clamp(vec3(m+m,-n-m,n-m)*z-kx, 0.0, 1.0);
		vec2  qx=d+(c+b*t.x)*t.x; float dx=dot(qx, qx), sx = cross2(c+2.0*b*t.x,qx);
		vec2  qy=d+(c+b*t.y)*t.y; float dy=dot(qy, qy), sy = cross2(c+2.0*b*t.y,qy);
		if( dx<dy ) { res=dx; sgn=sx; rvx = t.x; } else { res=dy; sgn=sy; rvx = t.y; }
	}
	
	return vec2(rvx, sqrt(res)*sign(sgn));
}
vec2 sdLine(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p-a, ba = b-a;
	float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
	return vec2(length(pa-ba*h), h);
}
float sd_box(vec2 uv, vec2 size) {
	vec2 d = abs(uv)-size;
	return length(max(d, vec2(0)))+min(max(d.x, d.y), 0.0);
}
float s(vec2 uv, vec2 A, vec2 B, vec2 C) { return abs(sdBezier(uv, A, B, C).y); }
float l(vec2 uv, vec2 A, vec2 B) { return sdLine(uv, A, B).x; }
float k1(vec2 uv) { // a
	float d = s(uv, vec2(0.084, -0.004), vec2(0.399, -0.195),vec2(0.26, -0.28));
	d = min(d, s(uv, vec2(-0.278, 0.318), vec2(-0.009, 0.227),vec2(-0.021, -0.133)));
	d = min(d, l(uv, vec2(-0.31, -0.28), vec2(0.26, -0.28)));
	return d;
}
float k2(vec2 uv) // i
{
	float d = s(uv, vec2(0.264, -0.319), vec2(0, -0.051),vec2(-0.309, 0.045));
	d = min(d, l(uv, vec2(0.0385, 0.3155), vec2(0.0385, -0.1088)));
	return d;
}
float k3(vec2 uv) // u
{
	float d = s(uv, vec2(0.289, -0.194), vec2(0.297, 0.234),vec2(-0.117, 0.324));
	d = min(d, l(uv, vec2(0, -0.21), vec2(0, -0.3281)));
	d = min(d, l(uv, vec2(-0.27, -0.21), vec2(0.2878, -0.21)));
	d = min(d, l(uv, vec2(-0.28, 0), vec2(-0.28, -0.2066)));
	return d;
}
float k4(vec2 uv) // e
{
	float d = l(uv, vec2(0.28, -0.25), vec2(-0.28, -0.25));
	d = min(d, l(uv, vec2(0, -0.25), vec2(0, 0.25)));
	d = min(d, l(uv, vec2(0.34, 0.25), vec2(-0.34, 0.25)));
	return d;
}
float k5(vec2 uv) // o
{
	float d = s(uv, vec2(0.09, -0.183), vec2(-0.013, 0.065),vec2(-0.325, 0.228));
	d = min(d, l(uv, vec2(0.12, -0.33), vec2(0.12, 0.33)));
	d = min(d, l(uv, vec2(-0.31, -0.19), vec2(0.31, -0.19)));
	return d;
}
float k6(vec2 uv) // ka
{
	float d = s(uv, vec2(-0.039, -0.334136), vec2(0.006, 0.105),vec2(-0.319, 0.302));
	d = min(d, l(uv, vec2(-0.29, -0.19), vec2(0.28, -0.19)));
	d = min(d, s(uv, vec2(0.246, 0.217), vec2(0.231, 0.325),vec2(0.054, 0.28)));
	d = min(d, l(uv, vec2(0.2469, 0.2153), vec2(0.28, -0.19)));
	return d;
}
float k7(vec2 uv) // ki
{
	float d = l(uv, vec2(0.07, 0.33), vec2(-0.07, -0.33));
	d = min(d, l(uv, vec2(0.25, -0.23), vec2(-0.31, -0.14)));
	d = min(d, l(uv, vec2(0.31, 0), vec2(-0.33, 0.1)));
	return d;
}
float k8(vec2 uv) // ku
{
	float d = s(uv, vec2(-0.212, 0.319), vec2(0.281, 0.158),vec2(0.259, -0.21));
	d = min(d, s(uv, vec2(-0.053, -0.328), vec2(-0.141, -0.11),vec2(-0.295, -0.023)));
	d = min(d, l(uv, vec2(0.2565, -0.22), vec2(-0.0918, -0.2193)));
	return d;
}
float k9(vec2 uv) // ke
{
	float d = s(uv, vec2(-0.192, 0.319), vec2(0.136, 0.167),vec2(0.128, -0.181));
	d = min(d, s(uv, vec2(-0.124, -0.332), vec2(-0.198, -0.131),vec2(-0.336, -0.01)));
	d = min(d, l(uv, vec2(0.3279, -0.19), vec2(-0.19, -0.19)));
	return d;
}
float k10(vec2 uv) // ko
{
	float d = l(uv, vec2(0.25, -0.24), vec2(-0.27, -0.24));
	d = min(d, l(uv, vec2(0.25, -0.24), vec2(0.25, 0.25)));
	d = min(d, l(uv, vec2(-0.28, 0.25), vec2(0.25, 0.25)));
	return d;
}
float k11(vec2 uv) // sa
{
	float d = l(uv, vec2(-0.342, -0.1604), vec2(0.34, -0.16));
	d = min(d, l(uv, vec2(-0.17, -0.33), vec2(-0.17, 0.0844)));
	d = min(d, s(uv, vec2(0.17, -0.068), vec2(0.176, 0.287),vec2(-0.11, 0.315)));
	d = min(d, l(uv, vec2(0.17, -0.33), vec2(0.17, -0.03)));
	return d;
}
float k12(vec2 uv) // shi
{
	float d = s(uv, vec2(-0.22, -0.306), vec2(-0.117, -0.267),vec2(-0.03, -0.204));
	d = min(d, s(uv, vec2(0.313, -0.153), vec2(0.177, 0.267),vec2(-0.273, 0.299)));
	d = min(d, s(uv, vec2(-0.289, -0.098), vec2(-0.154, -0.05),vec2(-0.087, 0.013)));
	return d;
}
float k13(vec2 uv) // su
{
	float d = s(uv, vec2(0.057, 0.044), vec2(0.195, 0.126),vec2(0.314, 0.286));
	d = min(d, s(uv, vec2(0.221, -0.269), vec2(0.1, 0.14),vec2(-0.316, 0.288)));
	d = min(d, l(uv, vec2(-0.27, -0.27), vec2(0.22, -0.27)));
	return d;
}
float k14(vec2 uv) // se
{
	float d = s(uv, vec2(0.252, -0.182), vec2(0.41, -0.176),vec2(0.119, 0.078));
	d = min(d, s(uv, vec2(-0.137, 0.15), vec2(-0.142, 0.352),vec2(0.278, 0.269)));
	d = min(d, l(uv, vec2(-0.1353, -0.3247), vec2(-0.1373, 0.1509)));
	d = min(d, l(uv, vec2(-0.3301, -0.0978), vec2(0.2521, -0.1818)));
	return d;
}
float k15(vec2 uv) // so
{
	float d = s(uv, vec2(0.265, -0.28), vec2(0.257, 0.135),vec2(-0.194, 0.309));
	d = min(d, s(uv, vec2(-0.276, -0.285), vec2(-0.199, -0.188),vec2(-0.148, -0.033)));
	return d;
}
float k16(vec2 uv) // ta
{
	float d = s(uv, vec2(-0.212, 0.319), vec2(0.281, 0.158),vec2(0.259, -0.21));
	d = min(d, s(uv, vec2(-0.053, -0.328), vec2(-0.141, -0.11),vec2(-0.295, -0.023)));
	d = min(d, l(uv, vec2(0.2565, -0.22), vec2(-0.0918, -0.2193)));
	d = min(d, s(uv, vec2(-0.102, -0.058), vec2(0.028, 0.025),vec2(0.126, 0.122)));
	return d;
}
float k17(vec2 uv) // chi
{
	float d = s(uv, vec2(-0.269, -0.23), vec2(0.044, -0.237),vec2(0.265, -0.316));
	d = min(d, l(uv, vec2(0.338, -0.04), vec2(-0.3238, -0.04)));
	d = min(d, s(uv, vec2(-0.213, 0.324), vec2(0.044, 0.229),vec2(0.04, -0.038)));
	d = min(d, l(uv, vec2(0.04, -0.249), vec2(0.04, -0.0363)));
	return d;
}
float k18(vec2 uv) // tsu
{
	float d = s(uv, vec2(-0.175, 0.296), vec2(0.228, 0.222),vec2(0.292, -0.271));	
	d = min(d, s(uv, vec2(-0.071, -0.297), vec2(0, -0.144),vec2(0.013, -0.068)));
	d = min(d, s(uv, vec2(-0.29, -0.253), vec2(-0.222, -0.11),vec2(-0.204, -0.032)));
	return d;
}
float k19(vec2 uv) // te
{
	float d = l(uv, vec2(-0.25, -0.29), vec2(0.25, -0.29));
	d = min(d, l(uv, vec2(-0.33, -0.0704), vec2(0.33, -0.07)));
	d = min(d, s(uv, vec2(-0.225, 0.32), vec2(0.029, 0.261),vec2(0.03, -0.068)));
	return d;
}
float k20(vec2 uv) { // to
	float d = s (uv, vec2(-0.159, -0.093), vec2(0.104, -0.02),vec2(0.294, 0.08));
	return min(d, l(uv, vec2(-0.16, -0.3254), vec2(-0.16, 0.32)));
}
float k21(vec2 uv) { // na
	float d = s(uv, vec2(-0.252, 0.32), vec2(0.045, 0.253),vec2(0.039, -0.118));
	d = min(d, l(uv, vec2(0.039, -0.1141), vec2(0.0393, -0.33)));
	d = min(d, l(uv, vec2(-0.32, -0.12), vec2(0.33, -0.12)));
	return d;
}
float k22(vec2 uv) { // ni
	float d = l(uv, vec2(-0.24, -0.23), vec2(0.25, -0.23));
	d = min(d, l(uv, vec2(-0.33, 0.24), vec2(0.33, 0.24)));
	return d;
}
float k23(vec2 uv) { // nu
	float d = s(uv, vec2(-0.268, 0.311), vec2(0.178, 0.145),vec2(0.266, -0.28));
	d = min(d, s(uv, vec2(-0.143, -0.092), vec2(0.125, 0.079),vec2(0.253, 0.23)));
	return min(d, l(uv, vec2(-0.2553, -0.28), vec2(0.2661, -0.28)));
}
float k24(vec2 uv) { // ne
	float d = l(uv, vec2(0, -0.2201), vec2(0, -0.35));
	d = min(d, l(uv, vec2(0, 0.0031), vec2(0, 0.34)));
	d = min(d, s(uv, vec2(-0.327, 0.144), vec2(0.134, -0.013),vec2(0.25, -0.219)));
	d = min(d, s(uv, vec2(0.333, 0.161), vec2(0.125, 0.041),vec2(0, 0.005)));
	return min(d, l(uv, vec2(-0.27, -0.22), vec2(0.25, -0.22)));
}
float k25(vec2 uv) { // no
	return s(uv, vec2(-0.284, 0.284), vec2(0.19, 0.094),vec2(0.24, -0.294));
}
float k26(vec2 uv) { // ha
	uv.x = -abs(uv.x);
	return s(uv, vec2(-0.329, 0.271), vec2(-0.178, 0.12946),vec2(-0.148, -0.283));
}
float k27(vec2 uv) { // hi
	float d = s(uv, vec2(0.269, 0.262), vec2(-0.208, 0.326),vec2(-0.21, 0.18));
	d = min(d, s(uv, vec2(-0.212, -0.049), vec2(0.057, -0.09),vec2(0.235, -0.186)));
	return min(d, l(uv, vec2(-0.2159, -0.3062), vec2(-0.21, 0.18)));
}
float k28(vec2 uv) { // fu
	float d = s(uv, vec2(-0.193, 0.302), vec2(0.298, 0.141),vec2(0.28, -0.27));
	return min(d, l(uv, vec2(-0.28, -0.27), vec2(0.28, -0.27)));
}
float k29(vec2 uv) { // he
	float d = l(uv, vec2(-0.0793, -0.222), vec2(0.3384, 0.2195));
	return min(d, l(uv, vec2(-0.0793, -0.222), vec2(-0.3366, 0.0766)));
}
float k30(vec2 uv) { // ho
	float d = l(uv, vec2(0, -0.33), vec2(0, 0.32));
	d = min(d, l(uv, vec2(-0.33, -0.21), vec2(0.33, -0.21)));
	uv.x = -abs(uv.x);
	return min(d, s(uv, vec2(-0.328, 0.249), vec2(-0.215, 0.059),vec2(-0.208, -0.047)));
}
float k31(vec2 uv) { // ma
	float d = s(uv, vec2(0.31, -0.25), vec2(0.311, -0.135),vec2(-0.024, 0.136));
	d = min(d, s(uv, vec2(0.115, 0.314), vec2(-0.009, 0.136),vec2(-0.208, -0.047)));
	return min(d, l(uv, vec2(-0.32, -0.25), vec2(0.31, -0.25)));
}
float k32(vec2 uv) { // mi
	float d = s(uv, vec2(-0.211, -0.303), vec2(0.055, -0.276),vec2(0.249, -0.215));
	d = min(d, s(uv, vec2(0.219, 0.019), vec2(-0.017, -0.05),vec2(-0.228, -0.072)));
	return min(d, s(uv, vec2(0.27, 0.309), vec2(-0.017, 0.211),vec2(-0.288, 0.174)));
}
float k33(vec2 uv) { // mu
	float d = s(uv, vec2(-0.335, 0.265), vec2(0.068, 0.262),vec2(0.287, 0.198));
	d = min(d, s(uv, vec2(-0.244, 0.264), vec2(-0.139, 0.064),vec2(-0.021, -0.331)));
	return min(d, s(uv, vec2(0.33, 0.304), vec2(0.253, 0.09),vec2(0.128, -0.094)));
}
float k34(vec2 uv) { // me
	float d = s(uv, vec2(-0.283, 0.293), vec2(0.069, 0.165),vec2(0.219, -0.315));
	return min(d, s(uv, vec2(-0.19, -0.191), vec2(0.076, -0.021),vec2(0.258, 0.211)));
}
float k35(vec2 uv) { // mo
	float d = l(uv, vec2(-0.28, -0.28), vec2(0.28, -0.28));
	d = min(d, s(uv, vec2(-0.07, 0.171), vec2(-0.077, 0.351),vec2(0.32, 0.267)));
	d = min(d, l(uv, vec2(-0.07, -0.28), vec2(-0.07, 0.17)));
	return min(d, l(uv, vec2(-0.32, -0.04), vec2(0.33, -0.04)));
}
float k36(vec2 uv) { // ya
	float d = l(uv, vec2(-0.1546, -0.3368), vec2(-0.0156, 0.3389));
	d = min(d, s(uv, vec2(0.107, 0.07), vec2(0.41, -0.144),vec2(0.265, -0.222)));
	return min(d,l(uv, vec2(-0.325, -0.1285), vec2(0.2631, -0.2219)));
}
float k37(vec2 uv) { // yu
	float d = s(uv, vec2(0.103, 0.239), vec2(0.216, -0.251),vec2(0.143, -0.248));
	d = min(d, l(uv, vec2(-0.26, -0.25), vec2(0.1425, -0.248)));
	return min(d, l(uv, vec2(-0.33, 0.24), vec2(0.34, 0.24)));
}
float k38(vec2 p) { // yo
	const vec2 a = vec2(0);
    const float b = 0.25;
    float c = abs(p.y)-0.25;
    float d = length(max(vec2(abs(c),p.x-b),a));
    float d1 = min(d, length(max(vec2(abs(p.y),p.x-b),a)));
    d = min(d, length(max(vec2(abs(p.x-b),c),a)));
    d = length(max(vec2(d,-p.x-0.25),a));
    d = min(d,length(max(vec2(d1,-p.x-0.22),a)));
	return d;
}
float k39(vec2 uv) { // ra
	float d = s(uv, vec2(0.27, -0.1), vec2(0.264, 0.221),vec2(-0.159, 0.319));
	d = min(d, l(uv, vec2(-0.3, -0.1), vec2(0.27, -0.1)));
	return min(d, l(uv, vec2(-0.23, -0.3), vec2(0.23, -0.3)));
}
float k40(vec2 uv) { // ri
	float d = l(uv, vec2(-0.21, -0.31), vec2(-0.21, 0.06));
	d = min(d, s(uv, vec2(0.21, -0.07), vec2(0.218, 0.254),vec2(-0.148, 0.317)));
	return min(d, l(uv, vec2(0.21, -0.31), vec2(0.21, -0.07)));
}
float k41(vec2 uv) { // ru
	float d = s(uv, vec2(0.05, 0.237), vec2(0.109, 0.416),vec2(0.354, 0.052));
	d = min(d, s(uv, vec2(-0.169, -0.301), vec2(-0.144, 0.2),vec2(-0.322, 0.317)));
	return min(d, l(uv, vec2(0.05, -0.31), vec2(0.05, 0.2371)));
}
float k42(vec2 uv) { // re
	float d = s(uv, vec2(-0.21, 0.237), vec2(-0.216, 0.348),vec2(0.003, 0.26));
	d = min(d, s(uv, vec2(0, 0.261), vec2(0.171, 0.192),vec2(0.322, -0.021)));
	return min(d, l(uv, vec2(-0.21, -0.31), vec2(-0.21, 0.2371)));
}
float k43(vec2 uv) { // ro
	return abs(sd_box(uv ,vec2(0.25,0.25)));
}
float k44(vec2 uv) { // wa
	float d = l(uv, vec2(-0.271, -0.28), vec2(-0.271, -0.04));
	d = min(d, s(uv, vec2(0.28, -0.28), vec2(0.303, 0.193),vec2(-0.115, 0.313)));
	return min(d, l(uv, vec2(-0.271, -0.28), vec2(0.28, -0.28)));
}
float k45(vec2 uv) { // wo
	return min(l(uv, vec2(-0.255, -0.058), vec2(0.25, -0.058)),k28(uv));
}
float k46(vec2 uv) { // n
	float d = s(uv, vec2(0.313, -0.196), vec2(0.221, 0.217),vec2(-0.267, 0.279));
	return min(d, s(uv, vec2(-0.078, -0.099), vec2(-0.14, -0.181),vec2(-0.273, -0.268)));
}
float wrap(float value, float max, float min)
{
  float range = max - min;
  return (range != 0.0) ? value - (range * floor((value - min) / range)) : min;
}
float katakana(vec2 p, int char, float scale)
{
	char = int(wrap(float(char),0.0,46.0));
	float s = 1.0/scale;
	p *= s;
	float k[] = {
		k1(p),  k2(p),  k3(p),  k4(p),  k5(p),
		k6(p),  k7(p),  k8(p),  k9(p),  k10(p), 	
		k11(p), k12(p), k13(p), k14(p), k15(p),
		k16(p), k17(p), k18(p), k19(p), k20(p),
		k21(p), k22(p), k23(p), k24(p), k25(p),
		k26(p), k27(p), k28(p), k29(p), k30(p),
		k31(p), k32(p), k33(p), k34(p), k35(p),
		k36(p), k37(p), k38(p), k39(p), k40(p),
		k41(p), k42(p), k43(p), k44(p), k45(p),
        k46(p)};
	
	return k[char-1]/s;
}
float kc(vec2 p, int char, float scale, int gs) {
	if(gs > 1) {
		float g = float(gs);
		p += 0.5;
		vec2 a = floor(p*g)/vec2(g);
		p = fract(p*g) - 0.5;
		float c = g*(a.x+floor(1.0/g)) + a.y*g*g+1.0;
		return katakana(p,int(c),scale);
	}
	return katakana(p,char,scale);
}
// Display modes
const bool ASCII_DISPLAY = true;
const bool CUSTOM_DISPLAY = false;
// ASCII Character configurations (31-125)
// 31 reserved to display all segments
const float CHARS[] = {
	float(0xFFFF), float(0x0000), float(0x0202), float(0x0022),
    float(0xE722), float(0xE774), float(0xCF71), float(0xB1E8),
	float(0x0020), float(0x0081), float(0x0808), float(0xCCA9),
	float(0xC420), float(0x0800), float(0x8400), float(0x0000),
	float(0x0801), float(0x3B57), float(0x0203), float(0xB546),
	float(0x2746), float(0x8612), float(0xA1D4), float(0xB754),
	float(0x0246), float(0xB756), float(0xA756), float(0x4020),
	float(0x0820), float(0x8081), float(0xA500), float(0x0C08),
	float(0x4446), float(0x3576), float(0x9656), float(0x6766),
	float(0x3154), float(0x6366), float(0xB154), float(0x9054),
	float(0x3754), float(0x9612), float(0x6164), float(0x3302),
	float(0x9091), float(0x3110), float(0x121B), float(0x129A),
	float(0x3356), float(0x9456), float(0x33D6), float(0x94D6),
	float(0xA754), float(0x4064), float(0x3312), float(0x1811),
	float(0x1A92), float(0x0889), float(0xA712), float(0x2945),
	float(0x4124), float(0x0088), float(0x6060), float(0x0880),
	float(0x2100), float(0x0008), float(0xF100), float(0xF010),
	float(0xB000), float(0x4702), float(0xB800), float(0xC424),
	float(0xE070), float(0xD010), float(0x4000), float(0x7020),
	float(0x40A1), float(0x1010), float(0xD600), float(0xD000),
	float(0xF000), float(0x9070), float(0x0626), float(0x9000),
	float(0xE050), float(0xB010), float(0x7000), float(0x1800),
	float(0x1A80), float(0x0889), float(0x0722), float(0xA800),
	float(0xC124), float(0x4020), float(0x6460)
};
/*
 bit position mapping:
  _10__ __14__
 | \   |   /  |
 12 13 11 16  15
 |    \|/     |
  __1__ __6___
 |    /|\     |
 4  5  2  9   7
 | /   |   \  |
  __3__|__8___
 1  4    8   12    16
 |  |    |    |    |        
 0000 0000 0000 0000
 e.g. M = 0001 0010 0001 1011 (binary) = 4635 (dec) = 0x121B (hex) 
*/
float m(vec4 d) { return max(max(d.x,d.y),max(d.z,d.w)); }
float fs(vec2 p, float st, float sl, vec4 s14, float s5, bool sf, float da)
{
	const vec2 h = vec2(1,-1);
	da *= 0.017453;
	
	sl *= 0.1;
	st *= 0.5;
	sl = clamp(sl, 0,1);
	p = 2.0 * (p - 0.5);
	vec2 p1 = p;
	vec2 p2 = p;
	vec2 _p = p;
	
	p = abs(p) - vec2(0.25,0.4);
	
	float f = -max(p.x, p.y);
	float ism = f - st - (sl*1.625);
	float isg = min(ism, st-abs(dot(normalize(vec2(sin(da),cos(da))),_p*vec2(sf ? 1.0:-1.0 ,1.0))));
	
	float d = min(st - abs(f), min(-dot(p, normalize(h.xx)), abs(dot(p, normalize(h)))) - sl);
	p1.x = abs(p1.x); p2.y = abs(p2.y);
	p1 += vec2(0.15, 0.0); p2 -= vec2(0.0, 0.15);
	float q1 = -dot(p1,h.xx);
	float q2 = min(p2.x, -dot(p2,h.yx));
	float q3 = dot(p1, h.yx);
	float q4 = min(-p2.x, -dot(p2,h.xx));
	
	vec4 qv4 = vec4(q1,q2,q3,q4);
	qv4 = min(qv4,s14);
	
	return max(m(min(vec4(d),qv4)), min(isg,s5));
}
float i(float n, int b) { b = 16 - b; return float(mod(floor(n / exp2(floor(float(b)))), 2.0) != 0.0); }
float xvisd(vec2 uv, float st, float sl, float bevel, float a, float dps, vec2 dpo, float da, bool is_ascii, bool dp)
{
	float d;
	const vec2 b = vec2(1,0);
	int n = int(clamp(a, 31.0, 125.0) - 31.0);
	float ch = is_ascii ? CHARS[n] : a;
	float dpt = is_ascii ? (( n == 0 || n == 15 || n == 32 ) ? 1.0 : 0.0) : float(dp);
	
	st = clamp(st, 0, 1) * 0.5;
	float d1 = fs(uv+vec2(0.125, -0.2), st, sl, vec4(i(ch,1), i(ch,2), i(ch,3), i(ch,4)), i(ch,5) ,true, da );
	float d2 = fs(uv-vec2(0.125,  0.2), st, sl, vec4(i(ch,6), i(ch,7), i(ch,8), 0), i(ch,9) ,false, da);
	float d3 = fs(uv+vec2(0.125,  0.2), st, sl, vec4(i(ch,10), i(ch,11),0, i(ch,12)), i(ch,13) ,false, da);
	float d4 = fs(uv-vec2(0.125, -0.2), st, sl, vec4(i(ch,14), i(ch,15),0,0), i(ch,16), true, da);
	
	d = m(vec4(d1,d2,d3,d4));
	d = max(d,(-distance(uv-0.5,dpo)*3.0)+0.1*dps*dpt);
	return clamp(d/max(bevel, 1e-4), 0, 1);
}
float xvisd_custom(vec2 uv, float st, float sl, float bevel, float a, float dps, vec2 dpo, float da, bool dp)
{
	return xvisd(uv, st, sl, bevel, a, dps, dpo, da, CUSTOM_DISPLAY, dp);
}
float xvisd_ascii(vec2 uv, float st, float sl, float bevel, float a, float dps, vec2 dpo, float da, bool dp)
{
	return xvisd(uv, st, sl, bevel, a, dps, dpo, da, ASCII_DISPLAY, dp);
}
float all_seg(vec2 uv, float st, float sl, float dps, vec2 dpo, float da)
{
	return xvisd(uv, st, sl, 0, 31.0, dps, dpo, da, ASCII_DISPLAY, false);
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
const float p_o203818_amount = 1.000000000;
const float p_o203820_d_in1_x = 0.000000000;
const float p_o203820_d_in1_y = 0.000000000;
const float p_o203820_d_in1_z = 0.000000000;
const float p_o203820_d_in2_x = 8.000000000;
const float p_o203820_d_in2_y = 8.000000000;
const float p_o203820_d_in2_z = 8.000000000;
const float p_o203819_amount = 1.000000000;
const float p_o203789_amount = 1.000000000;
const float p_o203775_min = -1.410000000;
const float p_o203775_max = 3.350000000;
const float p_o203775_step = 0.000000000;
const float p_o203774_default_in1 = 0.000000000;
const float p_o203774_default_in2 = 0.000000000;
const float p_o203827_amount = 1.000000000;
const float p_o203803_bevel = 0.033500000;
const float p_o203803_base = 0.000000000;
const float p_o203802_char = 1.000000000;
const float p_o203802_scale = 1.173800000;
const float p_o203802_rad = 0.063000000;
const float p_o203802_gs = 1.000000000;
const float p_o203768_min = 0.000000000;
const float p_o203768_max = 50.000000000;
const float p_o203768_step = 0.000000000;
const float p_o203796_default_in1 = 0.000000000;
const float p_o203796_default_in2 = 0.000000000;
const float p_o203793_default_in1 = 0.000000000;
const float p_o203793_default_in2 = 0.000000000;
const float p_o203795_default_in1 = 0.000000000;
const float p_o203795_default_in2 = 0.000000000;
const float p_o203794_min = 2.000000000;
const float p_o203794_max = 1.000000000;
const float p_o203794_step = 0.000000000;
const float p_o203773_default_in1 = 0.000000000;
const float p_o203773_default_in2 = 0.000000000;
const float p_o203772_default_in1 = 0.000000000;
const float p_o203772_default_in2 = 0.000000000;
const float p_o203791_default_in1 = 0.000000000;
const float p_o203791_default_in2 = 80.000000000;
const float p_o203771_default_in1 = 0.000000000;
const float p_o203771_default_in2 = 0.000000000;
const float p_o203770_default_in1 = 0.000000000;
const float p_o203770_default_in2 = 50.000000000;
const float p_o203759_translate_x = 0.000000000;
const float p_o203759_translate_y = 0.000000000;
const float p_o203759_rotate = 0.000000000;
const float p_o203759_scale_x = 1.000000000;
const float p_o203759_scale_y = 1.000000000;
const float p_o203792_default_in1 = 0.000000000;
const float p_o203763_default_in1 = 0.000000000;
const float p_o203763_default_in2 = 178.550000000;
const float seed_o203760 = 0.216814000;
const float p_o203760_edgecolor = 1.000000000;
const float p_o203762_d_in1_x = 0.000000000;
const float p_o203762_d_in1_y = 0.000000000;
const float p_o203762_d_in1_z = 0.000000000;
const float p_o203762_d_in2_x = 0.000000000;
const float p_o203762_d_in2_y = 0.000000000;
const float p_o203762_d_in2_z = 0.000000000;
const float p_o203761_d_in1_x = 0.000000000;
const float p_o203761_d_in1_y = 0.000000000;
const float p_o203761_d_in1_z = 0.000000000;
const float p_o203761_d_in2_x = 50.000000000;
const float p_o203761_d_in2_y = 0.000000000;
const float p_o203761_d_in2_z = 0.000000000;
const float p_o203822_default_in1 = 0.000000000;
const float p_o203822_default_in2 = 0.000000000;
const float p_o203823_min = 7.000000000;
const float p_o203823_max = 15.000000000;
const float p_o203823_step = 0.000000000;
const float p_o203798_default_in1 = 0.000000000;
const float p_o203798_default_in2 = 0.000000000;
const float p_o203797_default_in1 = 0.000000000;
const float seed_o203767 = 0.822669000;
const float p_o203767_edgecolor = 1.000000000;
const float p_o203766_d_in1_x = 0.000000000;
const float p_o203766_d_in1_y = 0.000000000;
const float p_o203766_d_in1_z = 0.000000000;
const float p_o203766_d_in2_x = 0.000000000;
const float p_o203766_d_in2_y = 0.000000000;
const float p_o203766_d_in2_z = 0.000000000;
const float p_o203764_d_in1_x = 0.000000000;
const float p_o203764_d_in1_y = 0.000000000;
const float p_o203764_d_in1_z = 0.000000000;
const float p_o203764_d_in2_x = 50.000000000;
const float p_o203764_d_in2_y = 50.000000000;
const float p_o203764_d_in2_z = 0.000000000;
const float p_o203804_translate_x = 0.000000000;
const float p_o203804_translate_y = 0.000000000;
const float p_o203804_rotate = 0.000000000;
const float p_o203804_scale_x = -1.000000000;
const float p_o203804_scale_y = 1.000000000;
const float p_o203765_d_in1_x = 0.000000000;
const float p_o203765_d_in1_y = 0.000000000;
const float p_o203765_d_in1_z = 0.000000000;
const float p_o203765_d_in2_x = 0.000000000;
const float p_o203765_d_in2_y = 0.000000000;
const float p_o203765_d_in2_z = 0.000000000;
const float p_o203824_a = 0.000000000;
const float p_o203824_sl = 0.000000000;
const float p_o203824_st = 0.367600000;
const float p_o203824_dps = 0.684480000;
const float p_o203824_dpx = 0.196945000;
const float p_o203824_dpy = 0.395530000;
const float p_o203824_da = 60.000000000;
const float p_o203824_b = 0.029300000;
const float p_o203825_min = 32.000000000;
const float p_o203825_max = 125.000000000;
const float p_o203825_step = 0.000000000;
const float p_o203826_value = 0.405800000;
const float p_o203826_width = 0.000000000;
const float p_o203776_gradient_0_pos = 0.510099000;
const vec4 p_o203776_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o203776_gradient_1_pos = 0.998661000;
const vec4 p_o203776_gradient_1_col = vec4(0.132247999, 0.288527995, 0.116594002, 1.000000000);
vec4 o203776_gradient_gradient_fct(float x) {
  if (x < p_o203776_gradient_0_pos) {
    return p_o203776_gradient_0_col;
  } else if (x < p_o203776_gradient_1_pos) {
    return mix(p_o203776_gradient_0_col, p_o203776_gradient_1_col, ((x-p_o203776_gradient_0_pos)/(p_o203776_gradient_1_pos-p_o203776_gradient_0_pos)));
  }
  return p_o203776_gradient_1_col;
}
const float p_o203799_amount = 1.000000000;
const float p_o203805_gradient_0_pos = 0.964525000;
const vec4 p_o203805_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o203805_gradient_1_pos = 1.000000000;
const vec4 p_o203805_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o203805_gradient_gradient_fct(float x) {
  if (x < p_o203805_gradient_0_pos) {
    return p_o203805_gradient_0_col;
  } else if (x < p_o203805_gradient_1_pos) {
    return mix(p_o203805_gradient_0_col, p_o203805_gradient_1_col, ((x-p_o203805_gradient_0_pos)/(p_o203805_gradient_1_pos-p_o203805_gradient_0_pos)));
  }
  return p_o203805_gradient_1_col;
}
const vec4 p_o203800_color = vec4(0.185112000, 0.243324995, 0.587750018, 1.000000000);
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o203759_0_1_rgba = vec4(((transform2((uv), vec2(p_o203759_translate_x*(2.0*1.0-1.0), p_o203759_translate_y*(2.0*1.0-1.0)), p_o203759_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o203759_scale_x*(2.0*1.0-1.0), p_o203759_scale_y*(2.0*1.0-1.0))))), 0.0, 1.0);
float o203769_1_1_f = o203759_0_1_rgba.g;
float o203770_0_clamp_false = o203769_1_1_f*p_o203770_default_in2;
float o203770_0_clamp_true = clamp(o203770_0_clamp_false, 0.0, 1.0);
float o203770_0_2_f = o203770_0_clamp_false;
float o203771_0_clamp_false = floor(o203770_0_2_f);
float o203771_0_clamp_true = clamp(o203771_0_clamp_false, 0.0, 1.0);
float o203771_0_1_f = o203771_0_clamp_false;
float o203791_0_clamp_false = o203771_0_1_f/p_o203791_default_in2;
float o203791_0_clamp_true = clamp(o203791_0_clamp_false, 0.0, 1.0);
float o203791_0_2_f = o203791_0_clamp_false;
vec3 o203761_0_clamp_false = ((o203759_0_1_rgba).rgb)*vec3(p_o203761_d_in2_x, p_o203761_d_in2_y, p_o203761_d_in2_z);
vec3 o203761_0_clamp_true = clamp(o203761_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203761_0_2_rgb = o203761_0_clamp_false;
vec3 o203762_0_clamp_false = floor(o203761_0_2_rgb);
vec3 o203762_0_clamp_true = clamp(o203762_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203762_0_1_rgb = o203762_0_clamp_false;
vec4 o203760_0_bb = vec4(o203762_0_1_rgb, 1.0);float o203760_0_1_f = mix(p_o203760_edgecolor, rand(vec2(float((seed_o203760+fract(_seed_variation_))), rand(vec2(rand(o203760_0_bb.xy), rand(o203760_0_bb.zw))))), step(0.0000001, dot(o203760_0_bb.zw, vec2(1.0))));
float o203763_0_clamp_false = o203760_0_1_f*p_o203763_default_in2;
float o203763_0_clamp_true = clamp(o203763_0_clamp_false, 0.0, 1.0);
float o203763_0_2_f = o203763_0_clamp_false;
float o203821_0_1_f = (elapsed_time);
float o203823_0_x = o203760_0_1_f*(p_o203823_max-p_o203823_min);float o203823_0_1_f = p_o203823_min+o203823_0_x-mod(o203823_0_x, max(p_o203823_step, 0.00000001));
float o203822_0_clamp_false = o203821_0_1_f/o203823_0_1_f;
float o203822_0_clamp_true = clamp(o203822_0_clamp_false, 0.0, 1.0);
float o203822_0_1_f = o203822_0_clamp_false;
float o203792_0_clamp_false = o203763_0_2_f+o203822_0_1_f;
float o203792_0_clamp_true = clamp(o203792_0_clamp_false, 0.0, 1.0);
float o203792_0_1_f = o203792_0_clamp_false;
float o203772_0_clamp_false = o203791_0_2_f-o203792_0_1_f;
float o203772_0_clamp_true = clamp(o203772_0_clamp_false, 0.0, 1.0);
float o203772_0_1_f = o203772_0_clamp_false;
float o203773_0_clamp_false = fract(o203772_0_1_f);
float o203773_0_clamp_true = clamp(o203773_0_clamp_false, 0.0, 1.0);
float o203773_0_1_f = o203773_0_clamp_false;
float o203794_0_x = o203773_0_1_f*(p_o203794_max-p_o203794_min);float o203794_0_1_f = p_o203794_min+o203794_0_x-mod(o203794_0_x, max(p_o203794_step, 0.00000001));
float o203795_0_clamp_false = o203794_0_1_f+p_o203795_default_in2;
float o203795_0_clamp_true = clamp(o203795_0_clamp_false, 0.0, 1.0);
float o203795_0_2_f = o203795_0_clamp_true;
float o203793_0_clamp_false = fract(o203795_0_2_f);
float o203793_0_clamp_true = clamp(o203793_0_clamp_false, 0.0, 1.0);
float o203793_0_1_f = o203793_0_clamp_false;
vec3 o203764_0_clamp_false = ((o203759_0_1_rgba).rgb)*vec3(p_o203764_d_in2_x, p_o203764_d_in2_y, p_o203764_d_in2_z);
vec3 o203764_0_clamp_true = clamp(o203764_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203764_0_2_rgb = o203764_0_clamp_false;
vec3 o203766_0_clamp_false = floor(o203764_0_2_rgb);
vec3 o203766_0_clamp_true = clamp(o203766_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203766_0_1_rgb = o203766_0_clamp_false;
vec4 o203767_0_bb = vec4(o203766_0_1_rgb, 1.0);float o203767_0_1_f = mix(p_o203767_edgecolor, rand(vec2(float((seed_o203767+fract(_seed_variation_))), rand(vec2(rand(o203767_0_bb.xy), rand(o203767_0_bb.zw))))), step(0.0000001, dot(o203767_0_bb.zw, vec2(1.0))));
float o203797_0_clamp_false = o203767_0_1_f+(elapsed_time/100.0);
float o203797_0_clamp_true = clamp(o203797_0_clamp_false, 0.0, 1.0);
float o203797_0_2_f = o203797_0_clamp_false;
float o203798_0_clamp_false = fract(o203797_0_2_f);
float o203798_0_clamp_true = clamp(o203798_0_clamp_false, 0.0, 1.0);
float o203798_0_1_f = o203798_0_clamp_false;
float o203796_0_clamp_false = o203793_0_1_f+o203798_0_1_f;
float o203796_0_clamp_true = clamp(o203796_0_clamp_false, 0.0, 1.0);
float o203796_0_1_f = o203796_0_clamp_false;
float o203768_0_x = o203796_0_1_f*(p_o203768_max-p_o203768_min);float o203768_0_1_f = p_o203768_min+o203768_0_x-mod(o203768_0_x, max(p_o203768_step, 0.00000001));
vec4 o203759_0_5_rgba = vec4(((transform2((transform2((uv), vec2(p_o203804_translate_x*(2.0*1.0-1.0), p_o203804_translate_y*(2.0*1.0-1.0)), p_o203804_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o203804_scale_x*(2.0*1.0-1.0), p_o203804_scale_y*(2.0*1.0-1.0)))), vec2(p_o203759_translate_x*(2.0*1.0-1.0), p_o203759_translate_y*(2.0*1.0-1.0)), p_o203759_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o203759_scale_x*(2.0*1.0-1.0), p_o203759_scale_y*(2.0*1.0-1.0))))), 0.0, 1.0);
vec3 o203764_3_clamp_false = ((o203759_0_5_rgba).rgb)*vec3(p_o203764_d_in2_x, p_o203764_d_in2_y, p_o203764_d_in2_z);
vec3 o203764_3_clamp_true = clamp(o203764_3_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203764_0_5_rgb = o203764_3_clamp_false;
vec3 o203765_0_clamp_false = fract(o203764_0_5_rgb);
vec3 o203765_0_clamp_true = clamp(o203765_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203765_0_1_rgb = o203765_0_clamp_false;
vec4 o203804_0_1_rgba = vec4(o203765_0_1_rgb, 1.0);
float o203802_0_1_sdf2d = kc(((o203804_0_1_rgba).rgb).xy-0.5, int(p_o203802_char*o203768_0_1_f), p_o203802_scale, int(p_o203802_gs)) - p_o203802_rad;
float o203803_0_1_f = clamp(p_o203803_base-o203802_0_1_sdf2d/max(p_o203803_bevel, 0.00001), 0.0, 1.0);
float o203825_0_x = o203796_0_1_f*(p_o203825_max-p_o203825_min);float o203825_0_1_f = p_o203825_min+o203825_0_x-mod(o203825_0_x, max(p_o203825_step, 0.00000001));
float o203824_0_1_f = xvisd_ascii(((o203804_0_1_rgba).rgb).xy, p_o203824_st, p_o203824_sl, p_o203824_b*1.0, (p_o203824_a == 0.0 ? o203825_0_1_f: p_o203824_a), p_o203824_dps, vec2(p_o203824_dpx, p_o203824_dpy), p_o203824_da, false);
vec3 o203826_0_false = clamp((vec4(vec3(o203767_0_1_f), 1.0).rgb-vec3(p_o203826_value))/max(0.0001, p_o203826_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o203826_0_true = vec3(1.0)-o203826_0_false;vec4 o203826_0_1_rgba = vec4(o203826_0_false, vec4(vec3(o203767_0_1_f), 1.0).a);
vec4 o203827_0_s1 = vec4(vec3(o203803_0_1_f), 1.0);
vec4 o203827_0_s2 = vec4(vec3(o203824_0_1_f), 1.0);
float o203827_0_a = p_o203827_amount*(dot((o203826_0_1_rgba).rgb, vec3(1.0))/3.0);
vec4 o203827_0_1_rgba = vec4(blend_normal((uv), o203827_0_s1.rgb, o203827_0_s2.rgb, o203827_0_a*o203827_0_s1.a), min(1.0, o203827_0_s2.a+o203827_0_a*o203827_0_s1.a));
float o203774_0_clamp_false = (dot((o203827_0_1_rgba).rgb, vec3(1.0))/3.0)*o203773_0_1_f;
float o203774_0_clamp_true = clamp(o203774_0_clamp_false, 0.0, 1.0);
float o203774_0_1_f = o203774_0_clamp_true;
float o203775_0_x = o203774_0_1_f*(p_o203775_max-p_o203775_min);float o203775_0_1_f = p_o203775_min+o203775_0_x-mod(o203775_0_x, max(p_o203775_step, 0.00000001));
vec4 o203776_0_1_rgba = o203776_gradient_gradient_fct(o203773_0_1_f);
vec4 o203789_0_s1 = vec4(vec3(o203775_0_1_f), 1.0);
vec4 o203789_0_s2 = o203776_0_1_rgba;
float o203789_0_a = p_o203789_amount*1.0;
vec4 o203789_0_2_rgba = vec4(blend_multiply((uv), o203789_0_s1.rgb, o203789_0_s2.rgb, o203789_0_a*o203789_0_s1.a), min(1.0, o203789_0_s2.a+o203789_0_a*o203789_0_s1.a));
vec4 o203805_0_1_rgba = o203805_gradient_gradient_fct(o203773_0_1_f);
vec4 o203800_0_1_rgba = p_o203800_color;
vec4 o203799_0_s1 = o203805_0_1_rgba;
vec4 o203799_0_s2 = o203800_0_1_rgba;
float o203799_0_a = p_o203799_amount*1.0;
vec4 o203799_0_2_rgba = vec4(blend_multiply((uv), o203799_0_s1.rgb, o203799_0_s2.rgb, o203799_0_a*o203799_0_s1.a), min(1.0, o203799_0_s2.a+o203799_0_a*o203799_0_s1.a));
vec4 o203819_0_s1 = o203789_0_2_rgba;
vec4 o203819_0_s2 = o203799_0_2_rgba;
float o203819_0_a = p_o203819_amount*1.0;
vec4 o203819_0_2_rgba = vec4(blend_multiply((uv), o203819_0_s1.rgb, o203819_0_s2.rgb, o203819_0_a*o203819_0_s1.a), min(1.0, o203819_0_s2.a+o203819_0_a*o203819_0_s1.a));
vec3 o203820_0_clamp_false = ((o203819_0_2_rgba).rgb)*vec3(p_o203820_d_in2_x, p_o203820_d_in2_y, p_o203820_d_in2_z);
vec3 o203820_0_clamp_true = clamp(o203820_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o203820_0_2_rgb = o203820_0_clamp_false;
vec4 o203818_0_s1 = vec4(o203820_0_2_rgb, 1.0);
vec4 o203818_0_s2 = o203789_0_2_rgba;
float o203818_0_a = p_o203818_amount*(dot((o203805_0_1_rgba).rgb, vec3(1.0))/3.0);
vec4 o203818_0_1_rgba = vec4(blend_normal((uv), o203818_0_s1.rgb, o203818_0_s2.rgb, o203818_0_a*o203818_0_s1.a), min(1.0, o203818_0_s2.a+o203818_0_a*o203818_0_s1.a));

	vec4 color_tex = o203818_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



