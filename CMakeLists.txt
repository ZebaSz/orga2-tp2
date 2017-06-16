cmake_minimum_required(VERSION 2.8)
project(orga2_tp2)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -pedantic -O3 -ggdb -lm -std=c99")


set(BASE_FILES
        src/rdtsc.h
        src/run.h
        src/tp2.c)

set(DATA_RUNNER src/data/data.c)

set(DEF_RUNNER src/run.c)

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
            src/filters/ASM_maxCloser.asm
            #src/filters/ASM_convert_1pixel.asm
            #src/filters/ASM_linearZoom_shuf.asm
            #src/filters/ASM_fourCombine_antiCache.asm
            #src/filters/ASM_maxCloser5.asm
    )
    set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -f elf64 -g -F DWARF")
endif(CMAKE_ASM_NASM_COMPILER_LOADED)

set(BMP_FILES
        src/bmp/bmp.c
        src/bmp/bmp.h)

add_library(bmp ${BMP_FILES})

add_executable(diff ${DIFF_FILES})
target_link_libraries(diff bmp)
add_executable(bmp_example src/bmp/example.c)
target_link_libraries(bmp_example bmp)

add_library(tp2_base ${BASE_FILES} ${FILTER_FILES})

add_executable(tp2 ${DEF_RUNNER})
target_link_libraries(tp2 tp2_base bmp)

add_executable(tp2_data ${DATA_RUNNER})
target_link_libraries(tp2_data tp2_base bmp)
