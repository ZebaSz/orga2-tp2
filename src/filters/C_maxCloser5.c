/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch,
                 uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {
    int32_t kernelOff = 5;
    RGBA blanco;
    blanco.a = 255;
    blanco.r = 255;
    blanco.g = 255;
    blanco.b = 255;
    RGBA (*mSrc)[srcw] = (RGBA (*)[srcw]) src;
    RGBA (*mDst)[dstw] = (RGBA (*)[dstw]) dst;
    for(uint32_t h = 0; h < srch; h++) {
        for(uint32_t w = 0; w < srcw; w++) {
            if (h < kernelOff || w < kernelOff || h > srch - (kernelOff - 1) || w > srcw - (kernelOff - 1)){
                mDst[h][w] = blanco;
            } else {

                RGBA max;
                max.a = 255;
                max.r = 0;
                max.g = 0;
                max.b = 0;
                for(int32_t i = -kernelOff; i <= kernelOff; i++){
                    for(int32_t j = -kernelOff; j <= kernelOff; j++) {
                        if(mSrc[h + i][w + j].r > max.r) {
                            max.r = mSrc[h + i][w + j].r;
                        }
                        if(mSrc[h + i][w + j].g > max.g) {
                            max.g = mSrc[h + i][w + j].g;
                        }
                        if(mSrc[h + i][w + j].b > max.b) {
                            max.b = mSrc[h + i][w + j].b;
                        }
                    }
                }



                mDst[h][w].r =  (mSrc[h][w].r * (1 - val) + max.r * val);
                mDst[h][w].g =  (mSrc[h][w].g * (1 - val) + max.g * val);
                mDst[h][w].b =  (mSrc[h][w].b * (1 - val) + max.b * val);
            }
        }
    }
}

