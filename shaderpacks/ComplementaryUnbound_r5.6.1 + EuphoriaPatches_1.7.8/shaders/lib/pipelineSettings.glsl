/*
const int colortex0Format = R11F_G11F_B10F; //main color  
const int colortex1Format = RGBA8_SNORM;    //half res normalM
const int colortex2Format = RGBA16F;        //taa | long exposure + long exposure counter in g channel with long exposure enabled | Renko cut data in g channel with Renko cut enabled
const int colortex3Format = RGBA8;          //(cloud/water map on deferred/gbuffer) | translucentMult & bloom & final color
const int colortex4Format = RGBA8_SNORM;    //normalM & reflection strength
const int colortex5Format = RGBA8;          //scene image for water reflections | lightFogLength in r channel only from composite 1 to 5 & volumetric cloud linear depth & volumetric light factor
const int colortex6Format = RGBA8;          //smoothnessD & materialMask & skyLightFactor & lmCoord.x with purkinje mask
const int colortex7Format = RGBA16F;        //(cloud/water map on gbuffer) | reflection temporal image (rgb) & previous depth
const int colortex8Format = RGBA16F;        //SSR results for WSR, topmost translucent opacity
#ifdef SS_BLOCKLIGHT
const int colortex9Format  = RGBA16F;       // Screenspace colored light
const int colortex10Format = RGBA16F;       // Screenspace colored light Blurred
#endif
*/

const bool colortex0Clear = true;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = true;
const bool colortex4Clear = false;
const bool colortex5Clear = false;
const bool colortex6Clear = true;
const bool colortex7Clear = false;
const bool colortex8Clear = true;
const bool colortex9Clear = true;
const bool colortex10Clear = false;

const bool shadowHardwareFiltering = true;
const float shadowDistanceRenderMul = 1.0;
#if END_CRYSTAL_VORTEX_INTERNAL == 0 && DRAGON_DEATH_EFFECT_INTERNAL == 0
    const float entityShadowDistanceMul = 0.125; // Iris feature
#else
    const float entityShadowDistanceMul = 1.0; // Iris feature
#endif

const float drynessHalflife = 300.0;
const float wetnessHalflife = 300.0;

const float ambientOcclusionLevel = 1.0;

/*
Mental Image:
Colortex2 Alpha still available
Colortex5 gb can be used to pass between composites, just reset to 0 at the end
colortex1 alpha available
*/