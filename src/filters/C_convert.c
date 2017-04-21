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
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
    RGBA (*mSrc)[srcw] = (RGBA (*)[srcw]) src;
    YUVA (*mDst)[dstw] = (YUVA (*)[dstw]) dst;
    for(uint32_t i = 0; i < srch ; i++) {
        for(uint32_t j = 0; j < srcw; j++) {
            int r = mSrc[i][j].r;
            int g = mSrc[i][j].g;
            int b = mSrc[i][j].b;
            mDst[i][j].y = saturate(((128 + 66 * r + 129 * g + 25 * b) >> 8) + 16);
            mDst[i][j].u = saturate(((128 - 38 * r - 74 * g + 112 * b) >> 8) + 128);
            mDst[i][j].v = saturate(((128 + 112 * r - 94 * g - 18 * b) >> 8) + 128);
        }
    }
}

void C_convertYUVtoRGB(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
    YUVA (*mSrc)[srcw] = (YUVA (*)[srcw]) src;
    RGBA (*mDst)[dstw] = (RGBA (*)[dstw]) dst;
    for(uint32_t i = 0; i < srch ; i++) {
        for(uint32_t j = 0; j < srcw; j++) {
            int y = 298 * (mSrc[i][j].y - 16);
            int u = mSrc[i][j].u - 128;
            int v = mSrc[i][j].v - 128;
            mDst[i][j].r = saturate((128 + y + 409 * v) >> 8);
            mDst[i][j].g = saturate((128 + y - 100 * u - 208 * v) >> 8);
            mDst[i][j].b = saturate((128 + y + 516 * u) >> 8);
        }
    }
}
