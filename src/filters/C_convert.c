/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion convertRGBtoYUV y convertYUVtoRGB          */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

uint8_t saturate(int x) {
    if(x < 0) {
        return 0;
    }
    if(x > 255){
        return 255;
    }
    return (uint8_t)x;
}

void C_convertRGBtoYUV(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw __attribute__((unused)),
                       uint32_t dsth __attribute__((unused))) {
    RGBA* mSrc = (RGBA*) src;
    YUVA* mDst = (YUVA*) dst;
    for(uint32_t i = 0; i < srch * srcw ; i++) {
        int r = mSrc[i].r;
        int g = mSrc[i].g;
        int b = mSrc[i].b;
        mDst[i].y = saturate(((128 + 66 * r + 129 * g + 25 * b) >> 8) + 16);
        mDst[i].u = saturate(((128 - 38 * r - 74 * g + 112 * b) >> 8) + 128);
        mDst[i].v = saturate(((128 + 112 * r - 94 * g - 18 * b) >> 8) + 128);
    }
}

void C_convertYUVtoRGB(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw __attribute__((unused)),
                       uint32_t dsth __attribute__((unused))) {
    YUVA* mSrc = (YUVA*) src;
    RGBA* mDst = (RGBA*) dst;
    for(uint32_t i = 0; i < srch * srcw; i++) {
        int y = 298 * (mSrc[i].y - 16);
        int u = mSrc[i].u - 128;
        int v = mSrc[i].v - 128;
        mDst[i].r = saturate((128 + y + 409 * v) >> 8);
        mDst[i].g = saturate((128 + y - 100 * u - 208 * v) >> 8);
        mDst[i].b = saturate((128 + y + 516 * u) >> 8);
    }
}
