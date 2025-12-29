#if !defined END_FLASH_SETTINGS_FILE
#define END_FLASH_SETTINGS_FILE

//#define END_FLASH_SHADOW

#if defined END_FLASH_SHADOW && defined IS_IRIS && defined END && MC_VERSION >= 12109
    #define END_FLASH_SHADOW_INTERNAL
#endif

#ifdef END_FLASH_SHADOW
#endif

#endif