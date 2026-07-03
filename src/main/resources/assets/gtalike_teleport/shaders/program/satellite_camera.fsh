#version 150

uniform sampler2D DiffuseSampler;

// Intensity of camera exposure adaptation (0.0 = none, 1.0 = max overexposure)
uniform float ExposureIntensity;
// Strength of green-olive satellite color grading (0.0 = none, 1.0 = full)
uniform float ColorGradeStrength;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

// Luminance weight (standard Rec. 709)
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec4 color = texture(DiffuseSampler, texCoord);
    vec3 rgb = color.rgb;

    // -------------------------------------------------------------------
    // STEP 1 : Satellite color grade (green-olive / khaki tint like GTA V)
    // Shift red down, green up, blue down — but preserve brightness
    // -------------------------------------------------------------------
    float grade = ColorGradeStrength;
    if (grade > 0.001) {
        vec3 graded = rgb;
        graded.r = rgb.r * (1.0 - grade * 0.18);
        graded.g = rgb.g * (1.0 + grade * 0.14);
        graded.b = rgb.b * (1.0 - grade * 0.30);
        rgb = mix(rgb, graded, grade);
    }

    // -------------------------------------------------------------------
    // STEP 2 : Camera exposure adaptation (the key GTA V effect)
    // Bright pixels blow out first (like a camera adjusting aperture).
    // The brighter the pixel, the more it overexposes.
    // -------------------------------------------------------------------
    float exposure = ExposureIntensity;
    if (exposure > 0.001) {
        float luma = dot(rgb, LUMA);

        // Non-linear response: bright areas overexpose much faster
        // Low-luma pixels: slight lift; high-luma pixels: strong bloom
        float boost = 1.0 + exposure * (0.4 + luma * luma * 2.8);

        vec3 exposed = rgb * boost;

        // Soft clamp using Reinhard tone mapping to preserve some detail
        // in the non-blown-out areas
        vec3 reinhardBase = rgb / (rgb + vec3(1.0));
        vec3 reinhardBoosted = exposed / (exposed + vec3(1.0));
        // Blend: low exposure = mostly Reinhard; high = full blown out
        exposed = mix(reinhardBoosted * (rgb + vec3(1.0)), exposed, exposure * 0.6);

        rgb = exposed;
    }

    // Clamp final output
    rgb = clamp(rgb, 0.0, 1.0);

    fragColor = vec4(rgb, color.a);
}
