#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform vec2 uOffset;
uniform float uZoom;
uniform float uTime;
uniform float uScale;
uniform vec3 uLightDir;
uniform float uHasNightTexture;

uniform sampler2D uTexture;
uniform sampler2D uTextureNight;

out vec4 fragColor;

const float PI = 3.14159265359;

mat2 rotate2d(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c);
}

float landSignalAt(vec2 uv) {
    vec3 c = texture(uTexture, uv).rgb;
    float blueDominance = c.b - max(c.r, c.g);
    float warmGround = max(c.r * 0.92 + c.g * 0.72 - c.b * 0.92, 0.0);
    float valueSignal = dot(c, vec3(0.35, 0.43, 0.22));
    return clamp(warmGround * 1.45 + valueSignal * 0.28 - blueDominance * 0.85, 0.0, 1.0);
}

float coastlineEdge(vec2 uv) {
    vec2 stepUv = vec2(0.0018, 0.0032);
    float c = landSignalAt(uv);
    float dx = abs(landSignalAt(uv + vec2(stepUv.x, 0.0)) - landSignalAt(uv - vec2(stepUv.x, 0.0)));
    float dy = abs(landSignalAt(uv + vec2(0.0, stepUv.y)) - landSignalAt(uv - vec2(0.0, stepUv.y)));
    float diag = abs(landSignalAt(uv + stepUv) - landSignalAt(uv - stepUv));
    float gradient = max(max(dx, dy), diag * 0.7);
    float notCloud = 1.0 - smoothstep(0.72, 0.93, c);
    return smoothstep(0.055, 0.22, gradient) * notCloud;
}

void main() {
    vec2 pixelPos = FlutterFragCoord().xy;
    vec2 uv = (pixelPos - uResolution * 0.5) / uResolution.y;
    uv.y = -uv.y;

    float camDist = 5.0 / max(uZoom, 0.01);
    float yaw = -uOffset.x / 200.0;
    float pitch = clamp(uOffset.y / 200.0, -1.5, 1.5);

    mat2 rotY = rotate2d(pitch);
    mat2 rotX = rotate2d(yaw);

    vec3 ro = vec3(0.0, 0.0, -camDist);
    ro.yz *= rotY;
    ro.xz *= rotX;

    vec3 target = vec3(0.0, 0.0, 0.0);
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
    vec3 up = cross(fwd, right);
    vec3 rd = normalize(fwd + uv.x * right + uv.y * up);

    float sphereRadius = uScale * 0.5;
    vec3 oc = ro - target;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sphereRadius * sphereRadius;
    float h = b * b - c;

    if (h > 0.0) {
        float t = -b - sqrt(h);
        if (t > 0.0) {
            vec3 p = ro + t * rd;
            vec3 normal = normalize(p);

            float u = 0.5 + atan(normal.z, normal.x) / (2.0 * PI);
            float v = 0.5 - asin(normal.y) / PI;
            vec2 texUv = vec2(u, v);

            vec3 dayTex = texture(uTexture, texUv).rgb;
            vec3 nightTex = texture(uTextureNight, texUv).rgb;

            float landMask = smoothstep(0.18, 0.42, landSignalAt(texUv));
            float edge = coastlineEdge(texUv);

            vec3 waterColor = vec3(0.012, 0.019, 0.033) + dayTex * vec3(0.035, 0.045, 0.075);
            vec3 landColor = dayTex * vec3(0.44, 0.42, 0.37) + vec3(0.075, 0.073, 0.068);
            landColor = mix(landColor, vec3(dot(landColor, vec3(0.32, 0.42, 0.26))), 0.18);

            vec3 lightDir = normalize(uLightDir);
            float NdotL = dot(normal, lightDir);
            float dayBlend = smoothstep(-0.3, 0.72, NdotL);
            float dusk = smoothstep(-0.58, 0.18, NdotL);
            float cityVisibility = 1.0 - smoothstep(-0.34, 0.3, NdotL);

            vec3 surface = mix(waterColor, landColor, landMask);
            surface *= 0.46 + dayBlend * 0.42 + dusk * 0.16;

            float cityLight = max(max(nightTex.r, nightTex.g), nightTex.b);
            cityLight = smoothstep(0.08, 0.55, cityLight) * cityVisibility;
            vec3 cityGlow = vec3(1.0, 0.68, 0.34) * cityLight * 0.95;

            float coastVisibility = 0.46 + dusk * 0.42 + cityVisibility * 0.18;
            vec3 coastGlow = vec3(1.0, 0.55, 0.18) * edge * coastVisibility * 0.72;
            vec3 coastCore = vec3(1.0, 0.76, 0.44) * edge * coastVisibility * 0.24;

            float terminator = smoothstep(-0.18, 0.14, abs(NdotL));
            vec3 finalColor = surface + cityGlow + coastGlow + coastCore * terminator;

            float fresnelBase = 1.0 - max(dot(normal, -rd), 0.0);
            float fresnel = fresnelBase * fresnelBase * fresnelBase;
            finalColor += vec3(0.38, 0.53, 0.62) * fresnel * 0.32;
            finalColor += vec3(0.95, 0.55, 0.2) * fresnel * edge * 0.34;

            fragColor = vec4(finalColor, 1.0);
            return;
        }
    }

    if (b > 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float distToCenter = sqrt(sphereRadius * sphereRadius - h);
    float atmosphereWidth = 0.24 * uScale;

    if (distToCenter < sphereRadius + atmosphereWidth) {
        float d = (distToCenter - sphereRadius) / atmosphereWidth;
        float glowBase = 1.0 - d;
        float glow = glowBase * glowBase * glowBase;
        vec3 atmosphere = vec3(0.38, 0.55, 0.68) * glow * 0.52 + vec3(1.0, 0.56, 0.2) * glow * 0.18;
        fragColor = vec4(atmosphere, glow * 0.62);
    } else {
        fragColor = vec4(0.0);
    }
}
