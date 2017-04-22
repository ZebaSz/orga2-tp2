cmake_minimum_required(VERSION 3.7)
project(orga2_tp2)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99")


set(SOURCE_FILES
        src/rdtsc.h
        src/run.c
        src/run.h
        src/tp2.c)

set(DIFF_FILES src/tools/diff.c)

set(FILTER_FILES
        src/filters/C_convert.c
        src/filters/C_fourCombine.c
        src/filters/C_linearZoom.c
        src/filters/C_maxCloser.c
        src/filters/filter_toX.c
        src/filters/filters.h)

enable_language(ASM_NASM)
if(CMAKE_ASM_NASM_COMPILER_LOADED)
    set(CAN_USE_ASSEMBLER TRUE)
    set(FILTER_FILES ${FILTER_FILES}
            src/filters/ASM_convert.asm
            src/filters/ASM_fourCombine.asm
            src/filters/ASM_linearZoom.asm
            src/filters/ASM_maxCloser.asm)
    set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -g -F DWARF")
endif(CMAKE_ASM_NASM_COMPILER_LOADED)

set(BMP_FILES
        src/bmp/bmp.c
        src/bmp/bmp.h)

add_library(bmp ${BMP_FILES})

add_executable(diff ${DIFF_FILES})
target_link_libraries(diff bmp)
add_executable(bmp_example src/bmp/example.c)
target_link_libraries(bmp_example bmp)
add_executable(tp2 ${SOURCE_FILES} ${FILTER_FILES})
target_link_libraries(tp2 bmp)