/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion fourCombine                                */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_fourCombine(uint8_t* src, uint32_t srcw, uint32_t srch,
                   uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
    RGBA (*mSrc)[srcw] = (RGBA (*)[srcw]) src;
    RGBA (*mDst)[dstw] = (RGBA (*)[dstw]) dst;
    uint32_t halfHeight = srch>>1;
    uint32_t halfWidth = srcw>>1;
    for(uint32_t h = 0; h < srch ; h++) {
        for(uint32_t w = 0; w < srcw; w++) {
            uint32_t offsetH = (h % 2 == 0) ? 0 : halfHeight;
            uint32_t offsetW = (w % 2 == 0) ? 0 : halfWidth;
            mDst[offsetH + (h >> 1)][offsetW + (w >> 1)] = mSrc[h][w];
        }
    }
}

                    
                    
                    
                    

                    
                    
                    
                    