shader_type spatial;

vec3 hsb2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void vertex() {
    // Normalize Y position to 0-1 range
    float normalized_y = (VERTEX.y + 1.0) * 0.5;

    // Convert to HSB (hue based on y position, full saturation and brightness)
    vec3 hsb = vec3(normalized_y, 1.0, 1.0);

    // Convert HSB to RGB and set as vertex color
    COLOR.rgb = hsb2rgb(hsb);
    COLOR.a = 1.0;
}