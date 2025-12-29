vec2 worldOutlineOffset[4] = vec2[4] (
    vec2(-1.0, 1.0),
    vec2( 0,   1.0),
    vec2( 1.0, 1.0),
    vec2( 1.0, 0)
);

void DoWorldOutline(inout vec3 color, float linearZ0, float pixelFade, vec3 playerPos, float minecraft_far) {
    float outlineFade = 1.0;
    #ifdef DISTANT_HORIZONS
        float horizontalDistance = length(playerPos.xz);
        float verticalDistance = abs(playerPos.y);
        
        float distanceToCamera = max(horizontalDistance, verticalDistance);
        
        float fadeStart = minecraft_far * 0.7;
        float fadeEnd = minecraft_far * 0.9;
        if (fadeStart >= fadeEnd) {
            fadeEnd = fadeStart + max(1.0, minecraft_far * 0.01);
        }
        outlineFade = (1.0 - smoothstep(fadeStart, fadeEnd, distanceToCamera)) * pixelFade;
        if (outlineFade < 0.001) return;
    #endif

    vec2 scale = vec2(1.0 / view);

    float outlines[2] = float[2] (0.0, 0.0);
    float outlined = 1.0;
    float z = linearZ0 * far;
    float totalz = 0.0;
    float maxz = 0.0;
    float sampleza = 0.0;
    float samplezb = 0.0;

    #ifdef ENTITIES_ARE_LIGHT
        #define WORLD_OUTLINE_THICKNESSM 4
    #else
        #define WORLD_OUTLINE_THICKNESSM WORLD_OUTLINE_THICKNESS
    #endif
    int sampleCount = WORLD_OUTLINE_THICKNESSM * 4;

    for (int i = 0; i < sampleCount; i++) {
        vec2 offset = (1.0 + floor(i / 4.0)) * scale * worldOutlineOffset[int(mod(float(i), 4))];
        float depthCheckP = GetLinearDepth(texture2D(depthtex0, texCoord + offset).r) * far;
        float depthCheckN = GetLinearDepth(texture2D(depthtex0, texCoord - offset).r) * far;

        outlined *= clamp(1.0 - ((depthCheckP + depthCheckN) - z * 2.0) * 32.0 / z, 0.0, 1.0);

        if (i <= 4) maxz = max(maxz, max(depthCheckP, depthCheckN));
        totalz += depthCheckP + depthCheckN;
    }

    float outlinea = 1.0 - clamp((z * 8.0 - totalz) * 64.0 / z, 0.0, 1.0) * clamp(1.0 - ((z * 8.0 - totalz) * 32.0 - 1.0) / z, 0.0, 1.0);
    float outlineb = clamp(1.0 + 8.0 * (z - maxz) / z, 0.0, 1.0);
    float outlinec = clamp(1.0 + 64.0 * (z - maxz) / z, 0.0, 1.0);

    float outline = (0.35 * (outlinea * outlineb) + 0.65) * (0.75 * (1.0 - outlined) * outlinec + 1.0);
    outline -= 1.0;

    outline *= WORLD_OUTLINE_I / WORLD_OUTLINE_THICKNESSM;
    if (outline < 0.0) outline = -outline * 0.25;

    outline *= outlineFade;

    #if RETRO_LOOK == 1
        color = outline * 10.0 * vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * RETRO_LOOK_I;
    #elif RETRO_LOOK == 2
        color = mix(color, outline * 10.0 * vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * RETRO_LOOK_I, nightVision);
    #else
        color += min(color * outline * 2.5, vec3(outline));
    #endif
}
