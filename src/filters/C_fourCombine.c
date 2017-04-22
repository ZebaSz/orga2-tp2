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
    RGBA (*mDst)[dstw] = (RGBA (*)[dstw]) src;
    uint32_t halfHeight = srch>>1;
    uint32_t halfWidth = srcw>>1;
    for(uint32_t h = 0; h < srch ; h = h + 2) {
        for(uint32_t w = 0; w < srcw; w = w + 2) {
            mDst[h][w] = mSrc[h][w];
            mDst[h][halfWidth + w] = mSrc[h][w + 1];
            mDst[halfHeight + h][w] = mSrc[h + 1][w];
            mDst[halfHeight + h][halfHeight + w] = mSrc[h +1][w +1];
        }
    }
}

                    
                    
                    
                    

                    
                    
                    
                    