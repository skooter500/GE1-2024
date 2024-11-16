shader_type spatial;

// Parameters
uniform vec4 wireframe_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float wire_width : hint_range(0.0, 10.0) = 1.0;
uniform float wire_smoothness : hint_range(0.0, 0.1) = 0.01;
uniform bool depth_based_thickness = true;
uniform float min_thickness : hint_range(0.0, 2.0) = 0.5;
uniform float max_thickness : hint_range(0.0, 5.0) = 2.0;
uniform float max_distance : hint_range(1.0, 100.0) = 10.0;
uniform bool use_view_distance = true;

// Varying variables
varying vec3 barycentric;
varying float view_distance;

void vertex() {
    // Calculate barycentric coordinates
    float id = float(VERTEX_ID % 3);
    if (id < 0.5) {
        barycentric = vec3(1.0, 0.0, 0.0);
    } else if (id < 1.5) {
        barycentric = vec3(0.0, 1.0, 0.0);
    } else {
        barycentric = vec3(0.0, 0.0, 1.0);
    }
    
    // Calculate view distance for depth-based effects
    view_distance = length(VERTEX - CAMERA_POSITION_WORLD);
}

float get_wire_thickness() {
    if (!depth_based_thickness || !use_view_distance) {
        return wire_width;
    }
    
    // Calculate thickness based on view distance
    float normalized_distance = clamp(view_distance / max_distance, 0.0, 1.0);
    return mix(max_thickness, min_thickness, normalized_distance);
}

void fragment() {
    // Get adjusted wire thickness
    float thickness = get_wire_thickness();
    
    // Calculate wire edges with adjusted thickness
    vec3 deltas = fwidth(barycentric);
    vec3 smoothing = deltas * thickness;
    vec3 thickness_smooth = smoothstep(vec3(0.0), smoothing + wire_smoothness, barycentric);
    
    // Calculate wire intensity
    float wire = 1.0 - min(min(thickness_smooth.x, thickness_smooth.y), thickness_smooth.z);
    
    // Apply colors
    ALBEDO = mix(base_color.rgb, wireframe_color.rgb, wire);
    ALPHA = mix(base_color.a, wireframe_color.a, wire);
    
    // Basic lighting setup
    METALLIC = 0.0;
    ROUGHNESS = 1.0;
    
    // Optional: Add slight emission to make wireframe pop
    EMISSION = wireframe_color.rgb * wire * 0.5;
}