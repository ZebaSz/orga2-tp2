#include <limits.h>
#include "../run.h"
#include "../rdtsc.h"

#define REPETITIONS 100

int open(char* src, BMP** bmp, uint8_t** dataSrc, uint32_t* w, uint32_t* h ) {
    *bmp = bmp_read(src);
    if(*bmp==0) { return -1;}  // open error
    *w = *(bmp_get_w(*bmp));
    *h = *(bmp_get_h(*bmp));
    if(*w%4!=0) { return -1;}  // do not support padding
    *dataSrc = malloc(sizeof(uint8_t)*4*(*w)*(*h));
    if(*(bmp_get_bitcount(*bmp)) == 24)
        to32(*w,*h,bmp_get_data(*bmp),*dataSrc);
    else
        copy32(*w,*h,bmp_get_data(*bmp),*dataSrc);
    return 0;
}

int run_convertRGBtoYUV(int c, char* src, char* dst __attribute__((unused))){
    uint8_t* dataSrc;
    uint8_t* dataDst;
    uint32_t h;
    uint32_t w;
    BMP* bmp;
    if(open(src,&bmp,&dataSrc,&w,&h)) { return -1;}  // open error
    dataDst = malloc(sizeof(uint8_t)*4*h*w);

    FILE* output = fopen("rgb2yuv.csv", "a");
    for (int i = 0; i < REPETITIONS; ++i) {

        unsigned long start, end;
        RDTSC_START(start);

        if (c == 0) C_convertRGBtoYUV(dataSrc, w, h, dataDst, w, h);
        else if (c == 1) ASM_convertRGBtoYUV(dataSrc, w, h, dataDst, w, h);
        else { return -1; }

        RDTSC(end);
        unsigned long delta = end - start;
        fprintf(output, "%d,%u,%lu\n", c, h * w, delta);
    }
    fclose(output);

    free(dataSrc);
    free(dataDst);
    bmp_delete(bmp);
    return 0;
}

int run_convertYUVtoRGB(int c, char* src, char* dst __attribute__((unused))){
    uint8_t* dataSrc;
    uint8_t* dataDst;
    uint32_t h;
    uint32_t w;
    BMP* bmp;
    if(open(src,&bmp,&dataSrc,&w,&h)) { return -1;}  // open error
    dataDst = malloc(sizeof(uint8_t)*4*h*w);

    FILE* output = fopen("yuv2rgb.csv", "a");
    for (int i = 0; i < REPETITIONS; ++i) {
        unsigned long start, end;
        RDTSC_START(start);

        if(c==0)        C_convertYUVtoRGB(dataSrc,w,h,dataDst,w,h);
        else if(c==1) ASM_convertYUVtoRGB(dataSrc,w,h,dataDst,w,h);
        else {return -1;}

        RDTSC(end);
        unsigned long delta = end - start;
        fprintf(output, "%d,%u,%lu\n", c, h * w, delta);
    }
    fclose(output);

    free(dataSrc);
    free(dataDst);
    bmp_delete(bmp);
    return 0;
}

int run_fourCombine(int c, char* src, char* dst __attribute__((unused))){
    uint8_t* dataSrc;
    uint8_t* dataDst;
    uint32_t h;
    uint32_t w;
    BMP* bmp;
    if(open(src,&bmp,&dataSrc,&w,&h)) { return -1;}  // open error
    dataDst = malloc(sizeof(uint8_t)*4*h*w);

    FILE* output = fopen("fourCombine.csv", "a");
    for (int i = 0; i < REPETITIONS; ++i) {
        unsigned long start, end;
        RDTSC_START(start);

        if(c==0)        C_fourCombine(dataSrc,w,h,dataDst,w,h);
        else if(c==1) ASM_fourCombine(dataSrc,w,h,dataDst,w,h);
        else {return -1;}

        RDTSC(end);
        unsigned long delta = end - start;
        fprintf(output, "%d,%u,%lu\n", c, h * w, delta);
    }
    fclose(output);

    free(dataSrc);
    free(dataDst);
    bmp_delete(bmp);
    return 0;
}

int run_linearZoom(int c, char* src, char* dst __attribute__((unused))){
    uint8_t* dataSrc;
    uint8_t* dataDst;
    uint32_t sh,dh;
    uint32_t sw,dw;
    BMP* bmp;
    if(open(src,&bmp,&dataSrc,&sw,&sh)) { return -1;}  // open error
    dh=sh*2;
    dw=sw*2;
    dataDst = malloc(sizeof(uint8_t)*4*dw*dh);

    FILE* output = fopen("linearZoom.csv", "a");
    for (int i = 0; i < REPETITIONS; ++i) {
        unsigned long start, end;
        RDTSC_START(start);

        if(c==0)        C_linearZoom(dataSrc,sw,sh,dataDst,dw,dh);
        else if(c==1) ASM_linearZoom(dataSrc,sw,sh,dataDst,dw,dh);
        else {return -1;}

        RDTSC(end);
        unsigned long delta = end - start;
        fprintf(output, "%d,%u,%lu\n", c, sh * sw, delta);
    }
    fclose(output);

    free(dataSrc);
    free(dataDst);
    bmp_delete(bmp);
    return 0;
}

int run_maxCloser(int c, char* src, char* dst __attribute__((unused)), float val){
    uint8_t* dataSrc;
    uint8_t* dataDst;
    uint32_t h;
    uint32_t w;
    BMP* bmp;
    if(open(src,&bmp,&dataSrc,&w,&h)) { return -1;}  // open error
    dataDst = malloc(sizeof(uint8_t)*4*h*w);

    FILE* output = fopen("maxCloser.csv", "a");
    for (int i = 0; i < REPETITIONS; ++i) {
        unsigned long start, end;
        RDTSC_START(start);

        if(c==0)        C_maxCloser(dataSrc,w,h,dataDst,w,h,val);
        else if(c==1) ASM_maxCloser(dataSrc,w,h,dataDst,w,h,val);
        else {return -1;}

        RDTSC(end);
        unsigned long delta = end - start;
        fprintf(output, "%d,%u,%lu\n", c, h * w, delta);
    }
    fclose(output);

    free(dataSrc);
    free(dataDst);
    bmp_delete(bmp);
    return 0;
}
