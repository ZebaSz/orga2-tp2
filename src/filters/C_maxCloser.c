/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

RGBA getMax(uint32_t h, uint32_t w, RGBA **mSrc ){
    RGBA max;
    max.a = 255;
    max.r = 0;
    max.g = 0;
    max.b = 0;
    for(int32_t i = -3; i <= 3; i++){
        for(int32_t j = -3; j <= 3; j++){
            if(i != 0 || j != 0){
                if(mSrc[h + i][w + j].r > max.r){
                    max.r = mSrc[h + i][w + j].r;
                }
                if(mSrc[h + i][w + j].g > max.g){
                    max.g = mSrc[h + i][w + j].g;
                }
                if(mSrc[h + i][w + j].b > max.b){
                    max.b = mSrc[h + i][w + j].b;
                }
            }
        }
    }
    return max;
}

void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch,
                 uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {
    RGBA blanco;
    blanco.a = 255;
    blanco.r = 255;
    blanco.g = 255;
    blanco.b = 255;
    RGBA (*mSrc)[srcw] = (RGBA (*)[srcw]) src;
    RGBA (*mDst)[dstw] = (RGBA (*)[dstw]) dst;
    for(uint32_t h = 0; h < srch; h++) {
        for(uint32_t w = 0; w < srcw; w++) {
            if (h < 2 || w < 2 || h > srch - 3 || w > srcw - 3){
                mDst[h][w] = blanco;
            } else {
                RGBA max = getMax(h, w, mSrc);
                mDst[h][w] = mSrc[h][w];//TODO: combinación lineal entre este nuevo pixel y el pixel original.
            }
        }
    }
}

