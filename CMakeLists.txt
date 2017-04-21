cmake_minimum_required(VERSION 3.7)
project(orga2_tp2)

set(CMAKE_CXX_STANDARD 11)

enable_language(ASM_NASM)

set(SOURCE_FILES
        src/bmp/bmp.c
        src/bmp/bmp.h
        src/bmp/example.c
        src/filters/ASM_convert.asm
        src/filters/ASM_fourCombine.asm
        src/filters/ASM_linearZoom.asm
        src/filters/ASM_maxCloser.asm
        src/filters/C_convert.c
        src/filters/C_fourCombine.c
        src/filters/C_linearZoom.c
        src/filters/C_maxCloser.c
        src/filters/filter_toX.c
        src/filters/filters.h
        src/tools/diff.c
        src/rdtsc.h
        src/run.c
        src/run.h
        src/tp2.c)

add_executable(orga2_tp2 ${SOURCE_FILES})