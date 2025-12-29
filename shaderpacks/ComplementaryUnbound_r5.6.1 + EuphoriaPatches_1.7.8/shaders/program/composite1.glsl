/////////////////////////////////////
// Complementary Shaders by EminGT //
/////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/composite1.glsl"
#include "/lib/shaderSettings/endBeams.glsl"
#include "/lib/shaderSettings/overworldBeams.glsl"
#include "/lib/shaderSettings/longExposure.glsl"
#define NETHER_STORM
#define NETHER_STORM_LOWER_ALT 28 //[-296 -292 -288 -284 -280 -276 -272 -268 -264 -260 -256 -252 -248 -244 -240 -236 -232 -228 -224 -220 -216 -212 -208 -204 -200 -196 -192 -188 -184 -180 -176 -172 -168 -164 -160 -156 -152 -148 -144 -140 -136 -132 -128 -124 -120 -116 -112 -108 -104 -100 -96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -12 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300]
#define NETHER_STORM_HEIGHT 200 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
#define NETHER_STORM_I 0.40 //[0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.22 0.26 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]
#ifndef NETHER
    #undef NETHER_STORM
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

flat in vec3 upVec, sunVec;

#ifdef LIGHTSHAFTS_ACTIVE
    flat in float vlFactor;
#endif

//Pipeline Constants//

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;

vec2 view = vec2(viewWidth, viewHeight);

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

#ifdef LIGHTSHAFTS_ACTIVE
    float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
    float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
    float shadowTime = shadowTimeVar2 * shadowTimeVar2;
    float vlTime = min(abs(SdotU) - 0.05, 0.15) / 0.15;
#endif

//Common Functions//
float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

//Includes//
#include "/lib/atmospherics/fog/waterFog.glsl"
#include "/lib/atmospherics/fog/caveFactor.glsl"

#if defined PBR_REFLECTIONS || WATER_REFLECT_QUALITY > 0 && WORLD_SPACE_REFLECTIONS_INTERNAL > 0
    #include "/lib/materials/materialMethods/reflectionBlurFilter.glsl"
#endif

#ifdef BLOOM_FOG_COMPOSITE1
    #include "/lib/atmospherics/fog/bloomFog.glsl"
#endif

#if defined ATM_COLOR_MULTS || defined SPOOKY
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#ifdef AURORA_INFLUENCE
    #include "/lib/atmospherics/auroraBorealis.glsl"
#endif

#ifdef LIGHTSHAFTS_ACTIVE
    #if defined END && defined END_BEAMS
        #include "/lib/atmospherics/enderBeams.glsl"
    #elif defined OVERWORLD && defined OVERWORLD_BEAMS
        #include "/lib/atmospherics/overworldBeams.glsl"
    #endif
    #include "/lib/atmospherics/volumetricLight.glsl"
#endif

#if WATER_MAT_QUALITY >= 3 || defined NETHER_STORM || defined COLORED_LIGHT_FOG || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL  || (defined END && END_CENTER_LIGHTING > 0)
    #include "/lib/util/spaceConversion.glsl"
#endif

#if WATER_MAT_QUALITY >= 3
    #include "/lib/materials/materialMethods/refraction.glsl"
#endif

#ifdef NETHER_STORM
    #include "/lib/atmospherics/netherStorm.glsl"
#endif

#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#if RAINBOWS > 0 && defined OVERWORLD
    #include "/lib/atmospherics/rainbow.glsl"
#endif

#ifdef COLORED_LIGHT_FOG
    #include "/lib/voxelization/lightVoxelization.glsl"
    #include "/lib/atmospherics/fog/coloredLightFog.glsl"
#endif

#if END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0
    #include "/lib/atmospherics/endCrystalVortex.glsl"
#endif

#ifdef END_PORTAL_BEAM_INTERNAL
    #include "/lib/atmospherics/endPortalBeam.glsl"
#endif

//Program//
void main() {
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;
    float z0 = texelFetch(depthtex0, texelCoord, 0).r;
    float z1 = texelFetch(depthtex1, texelCoord, 0).r;

    vec4 screenPos = vec4(texCoord, z0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
    viewPos /= viewPos.w;
    float lViewPos = length(viewPos.xyz);

    #if defined DISTANT_HORIZONS && !defined OVERWORLD
        float z0DH = texelFetch(dhDepthTex, texelCoord, 0).r;
        vec4 screenPosDH = vec4(texCoord, z0DH, 1.0);
        vec4 viewPosDH = dhProjectionInverse * (screenPosDH * 2.0 - 1.0);
        viewPosDH /= viewPosDH.w;
        lViewPos = min(lViewPos, length(viewPosDH.xyz));
    #endif

    float dither = texture2DLod(noisetex, texCoord * view / 128.0, 0.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    /* TM5723: The "1.0 - translucentMult" trick is done because of the default color attachment
    value being vec3(0.0). This makes it vec3(1.0) to avoid issues especially on improved glass */
    vec3 translucentMult = 1.0 - texelFetch(colortex3, texelCoord, 0).rgb; //TM5723
    vec4 volumetricEffect = vec4(0.0);

    vec2 texCoordM = texCoord;
    #if WATER_MAT_QUALITY >= 3
        texCoordM = DoRefraction(color, z0, z1, viewPos.xyz, lViewPos);
    #endif

    #if defined PBR_REFLECTIONS || WATER_REFLECT_QUALITY > 0 && WORLD_SPACE_REFLECTIONS_INTERNAL > 0
        if (z0 < 1.0) {
            vec4 compositeReflection = texture2D(colortex7, texCoord);
            float fresnelM = pow2(texture2D(colortex4, texCoord).a); // including attenuation through fog and clouds
            if (abs(fresnelM - 0.5) < 0.5) { // 0.0 fresnel doesnt need ref calculations, and 1.0 fresnel basically means error
                if (z0 == z1 || z0 <= 0.56) { // Solids
                    #ifdef PBR_REFLECTIONS
                        if (fresnelM > 0.00001) {
                            compositeReflection = sampleBlurFilteredReflection(compositeReflection, dither, z0);

                            compositeReflection.rgb = max(compositeReflection.rgb, vec3(0.0)); // We seem to have some negative values for some reason
                            
                            // This physically doesn't make sense but fits Minecraft
                            const float texturePreservation = 0.7;
                            compositeReflection.rgb = mix(compositeReflection.rgb, max(color, compositeReflection.rgb), texturePreservation);

                            color = mix(color, compositeReflection.rgb, fresnelM);
                        }
                    #endif
                }
                #if WORLD_SPACE_REFLECTIONS_INTERNAL > 0
                    else { // Translucents
                        vec4 ssrReflection = texture2D(colortex8, texCoordM);
                        color = max(color - ssrReflection.rgb, vec3(0.0));

                        compositeReflection.rgb *= fresnelM;
                        compositeReflection = mix(compositeReflection, ssrReflection, float(ssrReflection.a > 0.999));
                        vec3 combinedRef = mix(ssrReflection.rgb, compositeReflection.rgb, compositeReflection.a);

                        color += combinedRef;
                    }
                #endif
            }
        }
    #endif

    vec4 screenPos1 = vec4(texCoord, z1, 1.0);
    vec4 viewPos1 = gbufferProjectionInverse * (screenPos1 * 2.0 - 1.0);
    viewPos1 /= viewPos1.w;
    float lViewPos1 = length(viewPos1.xyz);

    #if defined DISTANT_HORIZONS && !defined OVERWORLD
        float z1DH = texelFetch(dhDepthTex1, texelCoord, 0).r;
        vec4 screenPos1DH = vec4(texCoord, z1DH, 1.0);
        vec4 viewPos1DH = dhProjectionInverse * (screenPos1DH * 2.0 - 1.0);
        viewPos1DH /= viewPos1DH.w;
        lViewPos1 = min(lViewPos1, length(viewPos1DH.xyz));
    #endif

    #if defined LIGHTSHAFTS_ACTIVE || RAINBOWS > 0 && defined OVERWORLD
        vec3 nViewPos = normalize(viewPos1.xyz);
        float VdotL = dot(nViewPos, lightVec);
    #endif

    #if defined NETHER_STORM || defined COLORED_LIGHT_FOG || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL || (defined END && END_CENTER_LIGHTING > 0)
        vec3 playerPos = ViewToPlayer(viewPos1.xyz);
        vec3 nPlayerPos = normalize(playerPos);
    #endif

    #if RAINBOWS > 0 && defined OVERWORLD && !defined SPOOKY
        if (isEyeInWater == 0) color += GetRainbow(translucentMult, z0, z1, lViewPos, lViewPos1, VdotL, dither);
    #endif

    float vlFactorM = 0.0;
    #ifdef LIGHTSHAFTS_ACTIVE
        vlFactorM = vlFactor;
        float VdotU = dot(nViewPos, upVec);

        volumetricEffect = GetVolumetricLight(color, vlFactorM, translucentMult, lViewPos, lViewPos1, nViewPos, VdotL, VdotU, texCoord, z0, z1, dither);
    #endif
    float lightFogLength = 0.0;
    #if END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0
        vec4 endCrystalVortex = pow2(EndCrystalVortices(vec3(0.0), playerPos, dither));
        volumetricEffect = sqrt(pow2(volumetricEffect) + endCrystalVortex);
        lightFogLength = sqrt(pow2(lightFogLength) + length(endCrystalVortex.rgb));
    #endif

    #ifdef NETHER_STORM
        volumetricEffect = GetNetherStorm(color, translucentMult, nPlayerPos, playerPos, lViewPos, lViewPos1, dither);
    #endif

    #if defined ATM_COLOR_MULTS || defined SPOOKY
        volumetricEffect.rgb *= GetAtmColorMult();
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        volumetricEffect.rgb *= moonPhaseInfluence;
    #endif

    #ifdef END_PORTAL_BEAM_INTERNAL
        vec4 endPortalBeam = pow2(GetEndPortalBeam(vec3(0.0), playerPos));
        volumetricEffect = sqrt(pow2(volumetricEffect) + endPortalBeam);
        lightFogLength = sqrt(pow2(lightFogLength) + length(endPortalBeam.rgb));
    #endif

    #ifdef NETHER_STORM
        color = mix(color, volumetricEffect.rgb, volumetricEffect.a);
    #endif

    #ifdef COLORED_LIGHT_FOG
        vec3 lightFog = GetColoredLightFog(nPlayerPos, translucentMult, lViewPos, lViewPos1, dither, vlFactorM);
        float lightFogMult = COLORED_LIGHT_FOG_I;
        lightFogLength += length(lightFog);
        //if (heldItemId == 40000 && heldItemId2 != 40000) lightFogMult = 0.0; // Hold spider eye to disable light fog

        #ifdef OVERWORLD
            #ifdef EPIC_THUNDERSTORM
                lightFogMult = mix(lightFogMult, min(lightFogMult * 1.75, 1.7), rainFactor * inRainy);
            #endif
            lightFogMult *= 0.2 + 0.6 * mix(1.0, 1.0 - sunFactor * invRainFactor, eyeBrightnessM);
        #endif
    #endif

    if (isEyeInWater == 1) {
        if (z0 == 1.0) color.rgb = waterFogColor;

        vec3 underwaterMult = vec3(0.80, 0.87, 0.97);
        #if DARKER_DEPTH_OCEANS > 0
            vec4 texture6 = texelFetch(colortex6, texelCoord, 0);
            float renderDistanceFade = lViewPos * 20.0 / far;

            float lightSourceFactor = pow3(1.0 - texture6.a);
            lightSourceFactor += renderDistanceFade;
            lightSourceFactor = clamp01(lightSourceFactor);

            float heldLight = max(heldBlockLightValue, heldBlockLightValue2);
            if (heldLight > 0){
                if (heldItemId == 45032 || heldItemId2 == 45032) heldLight = 15; // Lava Bucket
                heldLight = clamp(heldLight, 0.0, 15.0);
                heldLight = sqrt2(heldLight / 15.0) * -1.0 + 1.0; // Normalize and invert
                heldLight = mix(heldLight, 1.0, clamp01((lViewPos) * 35.0 / far)); // Only do it around the player
            } else {
                heldLight = 1.0;
            }
            float mixFactor = heldLight * lightSourceFactor * (1.0 - nightVision);

            float waterDepthStart = waterAltitude + 10;
            float depthFactor = clamp01(10.0 / abs(min(cameraPosition.y, waterDepthStart + 0.001) - waterDepthStart));
            float depthDarkness = clamp(abs(1.0 - (1.0 - depthFactor) * (1.0 - depthFactor)), DARKER_DEPTH_OCEANS * 0.05, 1.0);

            underwaterMult *= mix(1.0, depthDarkness, mixFactor);
        #endif
        color.rgb *= underwaterMult * 0.85;
        volumetricEffect.rgb *= pow2(underwaterMult * 0.71);

        #ifdef COLORED_LIGHT_FOG
            lightFog *= underwaterMult;
        #endif
    } else if (isEyeInWater == 2) {
        if (z1 == 1.0) color.rgb = fogColor * 5.0;

        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
            color.rgb = changeColorFunction(color.rgb, 1.0, colorSoul, inSoulValley);
        #endif
        #ifdef PURPLE_END_FIRE_INTERNAL
            color.rgb = changeColorFunction(color.rgb, 1.0, colorEndBreath, 1.0);
        #endif

        volumetricEffect.rgb *= 0.0;
        #ifdef COLORED_LIGHT_FOG
            lightFog *= 0.0;
        #endif
    }

    #ifdef COLORED_LIGHT_FOG
        color /= 1.0 + pow2(GetLuminance(lightFog)) * lightFogMult * 2.0;
        color += lightFog * lightFogMult * 0.5;
    #endif

    color = pow(color, vec3(2.2));

    #if defined LIGHTSHAFTS_ACTIVE || defined END_PORTAL_BEAM_INTERNAL
        #ifdef END
            volumetricEffect.rgb *= volumetricEffect.rgb;
        #endif

        color += volumetricEffect.rgb;
    #endif

    #ifdef BLOOM_FOG_COMPOSITE1
        color *= GetBloomFog(lViewPos); // Reminder: Bloom Fog can move between composite1-2-3
    #endif

    #if RETRO_LOOK == 1
        color.rgb *= vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * 0.5 * RETRO_LOOK_I;
    #elif RETRO_LOOK == 2
        color.rgb *= mix(vec3(1.0), vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * 0.5, nightVision) * RETRO_LOOK_I;
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);

    #if LIGHTSHAFT_QUALI_DEFINE > 0 && LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 && defined OVERWORLD || defined END || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL || defined COLORED_LIGHT_FOG
        vec4 texture5 = vec4(0.0);
        #if LENSFLARE_MODE > 0 || defined ENTITY_TAA_NOISY_CLOUD_FIX || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL || defined COLORED_LIGHT_FOG
            texture5 = texelFetch(colortex5, texelCoord, 0); 
            if (viewWidth + viewHeight - gl_FragCoord.x - gl_FragCoord.y > 1.5)
                vlFactorM = texture5.a;
        #endif

        texture5.r = sqrt(pow2(texture5.r) + lightFogLength);

        /* DRAWBUFFERS:05 */
        gl_FragData[1] = vec4(texture5.r, 0.0, 0.0, vlFactorM);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

flat out vec3 upVec, sunVec;

#ifdef LIGHTSHAFTS_ACTIVE
    flat out float vlFactor;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    #ifdef LIGHTSHAFTS_ACTIVE
        #if LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END
            vlFactor = texelFetch(colortex5, ivec2(viewWidth-1, viewHeight-1), 0).a;
        #else
            #if LIGHTSHAFT_BEHAVIOUR == 2
                vlFactor = 0.0;
            #elif LIGHTSHAFT_BEHAVIOUR == 3
                vlFactor = 1.0;
            #endif
        #endif
    #endif
}

#endif
