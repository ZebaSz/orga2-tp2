/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void sumDiv2(RGBA a, RGBA b, RGBA *dest) {
    dest->r = (uint8_t)(((uint16_t)a.r + b.r) >> 1);
    dest->g = (uint8_t)(((uint16_t)a.g + b.g) >> 1);
    dest->b = (uint8_t)(((uint16_t)a.b + b.b) >> 1);
    dest->a = (uint8_t)(((uint16_t)a.a + b.a) >> 1);
}

void sumDiv4(RGBA a, RGBA b, RGBA c, RGBA d, RGBA *dest) {
    dest->r = (uint8_t)(((uint16_t)a.r + b.r + c.r + d.r) >> 2);
    dest->g = (uint8_t)(((uint16_t)a.g + b.g + c.g + d.g) >> 2);
    dest->b = (uint8_t)(((uint16_t)a.b + b.b + c.b + d.b) >> 2);
    dest->a = (uint8_t)(((uint16_t)a.a + b.a + c.a + d.a) >> 2);
}

/*
 * Matrix is vertically inverted, so src matrix looks like this
 *
 * 2
 * 1
 * 0
 *   0 1 2
 *
 * so if h = 1 and w = 1:
 *
 * 2
 * 1 a b
 * 0 c d
 *   0 1 2
 *
 * so c = [h-1][w] and d is [h-1][w+1]
 *
 * Dest matrix looks like this
 *
 * 5
 * 4
 * 3
 * 2
 * 1
 * 0
 *   0 1 2 3 4 5
 *
 * so for h = 1 and w = 1, h2 = 2 and w2 = 2 and
 *
 * 5
 * 4
 * 3 a X b
 * 2 X X X
 * 1 c X d
 * 0 I I I
 *   0 1 2 3 4 5
 *
 */
void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
    RGBA (*mSrc)[srcw] = (RGBA (*)[srcw]) src;
    RGBA (*mDst)[dstw] = (RGBA (*)[dstw]) dst;
    for(uint32_t h = 0; h < srch; h++) {
        for(uint32_t w = 0; w < srcw; w++) {
            uint32_t h2 = h << 1;
            uint32_t w2 = w << 1;
            RGBA a = mSrc[h][w];
            mDst[h2 + 1][w2] = a;
            if (w == srcw - 1){
                if (h == 0){
                    mDst[0][w2] = a;
                } else {
                    RGBA c = mSrc[h - 1][w];
                    sumDiv2(a, c, &mDst[h2][w2]);
                }
                mDst[h2][w2 + 1] = mDst[h2][w2];
                mDst[h2 + 1][w2 + 1] = mDst[h2 + 1][w2];
            } else {
                RGBA b = mSrc[h][w + 1];
                sumDiv2(a, b, &mDst[h2 + 1][w2 + 1]);
                if (h == 0){
                    mDst[0][w2] = mDst[1][w2];
                    mDst[0][w2 + 1] = mDst[1][w2 + 1];
                } else {
                    RGBA c = mSrc[h - 1][w];
                    RGBA d = mSrc[h - 1][w + 1];
                    sumDiv2(a, c, &mDst[h2][w2]);
                    sumDiv4(a, b, c, d, &mDst[h2][w2 + 1]);
                }
            }
        }
    }
}