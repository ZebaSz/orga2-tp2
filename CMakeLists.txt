cmake_minimum_required(VERSION 3.7)
project(orga2_tp2)

set(CMAKE_CXX_STANDARD 11)

enable_language(ASM_NASM)

set(SOURCE_FILES
        src/rdtsc.h
        src/run.c
        src/run.h
        src/tp2.c)

set(DIFF_FILES src/tools/diff.c)

set(FILTER_FILES
        src/filters/ASM_convert.asm
        src/filters/ASM_fourCombine.asm
        src/filters/ASM_linearZoom.asm
        src/filters/ASM_maxCloser.asm
        src/filters/C_convert.c
        src/filters/C_fourCombine.c
        src/filters/C_linearZoom.c
        src/filters/C_maxCloser.c
        src/filters/filter_toX.c
        src/filters/filters.h)

set(BMP_FILES
        src/bmp/bmp.c
        src/bmp/bmp.h)

add_executable(difftool ${DIFF_FILES})
add_executable(bmp_example ${BMP_FILES} src/bmp/example.c)
add_executable(orga2_tp2 ${SOURCE_FILES} ${FILTER_FILES} ${BMP_FILES})